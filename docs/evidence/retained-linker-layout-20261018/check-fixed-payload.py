"""Read pinned fixed ELF bytes for original payload/alignment/common inputs."""
import argparse
from collections import Counter
import gzip
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
repo = root.parents[2]
sha = lambda b: hashlib.sha256(b).hexdigest()
manifest = json.loads((root / 'sources.json').read_text())
assert sha((root / 'sources.tar.gz').read_bytes()) == manifest['archive_sha256']
sources = {}
with tarfile.open(root / 'sources.tar.gz') as archive:
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        sources[row['path']] = raw.decode()
extra = json.loads((root / 'fixed-payload-source.json').read_text())
raw = gzip.decompress((root / extra['archive']).read_bytes())
assert len(raw) == extra['bytes'] and sha(raw) == extra['sha256']
sources[extra['path']] = raw.decode()
assert re.search(r'#define\s+SHN_COMMON\s+0xFFF2', sources['include/elf/external.h'])
assert re.search(r'#define\s+SHN_LORESERVE\s+0xFF00', sources['include/elf/external.h'])
assert re.search(r'#define\s+SHN_X86_64_LCOMMON\s+\(SHN_LORESERVE \+ 2\)', sources[extra['path']])
for anchor in ['repr->entsize == sec->entsize',
               'repr->alignment_power == sec->alignment_power',
               'repr->output_section == sec->output_section',
               'amt += sec->entsize;',
               'eltalign = ((eltalign ^ (eltalign - 1)) + 1) >> 1;',
               'if (hashp->alignment < alignment)',
               'size += e->len;',
               'secinfo->sec->size = (secinfo->sec->size + align - 1) & -align;']:
    assert anchor in sources['bfd/merge.c'], anchor
inputs = json.loads((root / 'inputs.json').read_text())
for row in inputs:
    raw = (repo / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
inventory = json.loads((repo / inputs[0]['path']).read_text())


def cstring(raw, offset):
    assert 0 <= offset < len(raw)
    return raw[offset:raw.index(0, offset)]


def elf(raw, prior):
    assert raw[:6] == b'\x7fELF\x02\x01'
    assert struct.unpack_from('<H', raw, 18)[0] == 62
    offset = struct.unpack_from('<Q', raw, 40)[0]
    stride, count, strings = struct.unpack_from('<HHH', raw, 58)
    assert stride == 64
    zero = struct.unpack_from('<IIQQQQIIQQ', raw, offset)
    count = count or zero[5]
    if strings == 0xffff:
        strings = zero[6]
    assert offset + 64 * count <= len(raw) and strings < count
    headers = [struct.unpack_from('<IIQQQQIIQQ', raw, offset + i * 64)
               for i in range(count)]
    assert count == prior['sections']

    def payload(h):
        assert h[1] != 8 and h[4] + h[5] <= len(raw)
        return raw[h[4]:h[4] + h[5]]

    strings = payload(headers[strings])
    names = [cstring(strings, h[0]) for h in headers]
    assert not any(n.startswith(b'.zdebug') for n in names)
    assert not any(h[2] & 0x800 for h in headers)
    assert all(h[8] == 0 or h[8] & (h[8] - 1) == 0 for h in headers)
    result = Counter(elf_occurrences=1, section_headers=count,
                     symbol_records=0, common_symbols=0,
                     common_size_bytes=0, common_alignment_padding=0,
                     symbol_size_bytes=0, dynamic_symbol_size_bytes=0,
                     all_section_bytes=0, file_backed_section_bytes=0,
                     nobits_section_bytes=0, alloc_section_bytes=0,
                     alloc_alignment_padding=0, merge_section_bytes=0,
                     eh_frame_bytes=0, sframe_bytes=0, ctf_bytes=0,
                     attributes_bytes=0, property_note_bytes=0,
                     sframe_section_types=0, attributes_section_types=0,
                     sframe_named_sections=0, attributes_named_sections=0,
                     merge_input_sections=0, merge_entries=0,
                     merge_entry_bytes=0, merge_entry_alignment_padding=0,
                     merge_final_alignment_padding=0,
                     merge_added_terminator_bytes=0)
    for name, h in zip(names, headers):
        if h[1] == 0:
            continue  # Header zero's extended-count fields are not payload.
        if h[1] != 8:
            payload(h)
        result['all_section_bytes'] += h[5]
        result['nobits_section_bytes' if h[1] == 8 else 'file_backed_section_bytes'] += h[5]
        if h[2] & 2:
            result['alloc_section_bytes'] += h[5]
            result['alloc_alignment_padding'] += max(0, h[8] - 1)
        if h[2] & 0x10:
            result['merge_section_bytes'] += h[5]
            result['merge_input_sections'] += 1
            result['merge_final_alignment_padding'] += max(0, h[8] - 1)
            # Mirror only the blob segmentation and element-alignment
            # arithmetic of record_section/hashit, not linker execution.
            # Charge every input even when relocation/type guards skip it.
            assert h[9] > 0 and h[5] % h[9] == 0
            data = payload(h) + bytes(h[9])
            at = 0
            while at < h[5]:
                if h[2] & 0x20:  # SHF_STRINGS
                    end = at
                    while any(data[end:end + h[9]]):
                        end += h[9]
                    length = end - at + h[9]
                else:
                    length = h[9]
                alignment = max(1, h[8])
                element_alignment = min(at & -at if at else alignment, alignment)
                result['merge_entries'] += 1
                result['merge_entry_bytes'] += length
                result['merge_entry_alignment_padding'] += element_alignment - 1
                result['merge_added_terminator_bytes'] += max(0, at + length - h[5])
                at += length
        if h[1] == 0x6ffffff4:
            result['sframe_section_types'] += 1
        if h[1] == 0x6ffffff5:
            result['attributes_section_types'] += 1
        if name == b'.sframe':
            result['sframe_named_sections'] += 1
        if name == b'.gnu.attributes':
            result['attributes_named_sections'] += 1
        for spelling, key in [(b'.eh_frame', 'eh_frame_bytes'), (b'.sframe', 'sframe_bytes'),
                              (b'.ctf', 'ctf_bytes'), (b'.gnu.attributes', 'attributes_bytes'),
                              (b'.note.gnu.property', 'property_note_bytes')]:
            if name == spelling:
                result[key] += h[5]
        if h[1] not in (2, 11):
            continue
        assert h[9] == 24 and h[5] % 24 == 0
        for at in range(h[4], h[4] + h[5], 24):
            _, _, _, index, value, size = struct.unpack_from('<IBBHQQ', raw, at)
            # No fixed symbol needs an extended section-index companion.
            assert index != 0xffff
            result['symbol_records'] += 1
            result['symbol_size_bytes'] += size
            if h[1] == 11:
                result['dynamic_symbol_size_bytes'] += size
            if index in (0xfff2, 0xff02):
                assert value == 0 or value & (value - 1) == 0
                result['common_symbols'] += 1
                result['common_size_bytes'] += size
                result['common_alignment_padding'] += max(0, value - 1)
    assert result['symbol_records'] == prior['symbol_records']
    assert result['alloc_section_bytes'] == prior['alloc_section_bytes']
    assert result['alloc_alignment_padding'] == prior['alloc_alignment_padding_bound']
    assert result['all_section_bytes'] == result['file_backed_section_bytes'] + result['nobits_section_bytes']
    return result, max(h[8] for h in headers)


fixed = Counter()
rows = []
maximum_alignment = 0
files_verified = 0
members_verified = 0
loader = None
for f in inventory['files']:
    if f['role'] == 'generated-input':
        continue
    raw = Path(f['path']).read_bytes()
    assert len(raw) == f['bytes'] and sha(raw) == f['sha256'], f['path']
    files_verified += 1
    if f['kind'] == 'script':
        continue
    total = Counter()
    alignment = 0
    for member in f.get('members', [f]):
        if f['kind'] == 'archive':
            start = member['header_offset'] + 60
            data = raw[start:start + member['bytes']]
            assert len(data) == member['bytes'] and sha(data) == member['sha256']
            prior = member
            members_verified += 1
        else:
            data = raw
            prior = f['elf']
        counts, member_alignment = elf(data, prior)
        total.update(counts)
        alignment = max(alignment, member_alignment)
    multiplicity = f['link_argv_occurrences']
    fixed.update({k: v * multiplicity for k, v in total.items()})
    maximum_alignment = max(maximum_alignment, alignment)
    rows.append({'path': f['path'], 'sha256': f['sha256'],
                 'argv_occurrences': multiplicity,
                 'one_occurrence_totals': dict(total),
                 'maximum_section_alignment': alignment})
    if f['path'] == '/lib64/ld-linux-x86-64.so.2':
        loader = total
assert loader is not None
assert fixed['elf_occurrences'] == 1473 and fixed['section_headers'] == 36241
assert fixed['all_section_bytes'] == 44226801
assert fixed['file_backed_section_bytes'] == 44102586
assert fixed['nobits_section_bytes'] == 124215
assert fixed['common_symbols'] == 0 and maximum_alignment == 64
assert fixed['sframe_section_types'] == fixed['attributes_section_types'] == 0
assert fixed['sframe_named_sections'] == fixed['attributes_named_sections'] == 0
assert fixed['merge_entries'] == 116433
assert fixed['merge_entry_bytes'] == 3147288
assert fixed['merge_entry_alignment_padding'] == 17428
assert fixed['merge_final_alignment_padding'] == 3483
assert fixed['merge_added_terminator_bytes'] == 0
# Preserve the prior dependency-processing allowance, rather than assuming
# the one explicit loader occurrence is the only one processed.
additional = {k: 8 * v for k, v in loader.items()}
processed = Counter(fixed)
processed.update(additional)
assert processed['elf_occurrences'] == 1481 and processed['section_headers'] == 36433
main = json.loads((repo / inputs[3]['path']).read_text())
main_section_components = {key: main['object_file_components_upper'][key]
    for key in ['ordinary_payload', 'symbol_table', 'relocations',
                'symbol_strings', 'section_strings']}
assert sum(main_section_components.values()) == 12712
merge_bound = (processed['merge_entry_bytes']
               + processed['merge_entry_alignment_padding']
               + processed['merge_final_alignment_padding'])
assert merge_bound == 3168199
result = {
    'scope': 'Original fixed section payload/alignment/common-symbol input; not post-edit layout closure',
    'source_files_verified': len(sources), 'prior_inputs_verified': len(inputs),
    'installed_fixed_files_verified': files_verified,
    'installed_archive_members_verified': members_verified,
    'files': rows, 'explicit_weighted_fixed_totals': dict(fixed),
    'eight_additional_loader_processing_totals': additional,
    'processed_fixed_totals': dict(processed),
    'maximum_fixed_section_alignment': maximum_alignment,
    'source_derived_Main_original_section_components': main_section_components,
    'source_derived_Main_original_section_bytes_upper': 12712,
    'fixed_merge_output_payload_upper': merge_bound,
    'fixed_original_plus_merge_output_payload_upper': processed['all_section_bytes'] + merge_bound,
    'fixed_compressed_or_zdebug_sections': 0,
    'fixed_common_or_large_common_symbols': 0,
    'generated_objects_read': False,
    'post_edit_payload_alignment_or_whole_link_capacity_established': False,
    'native_execution': False,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['source_files_verified',
      'installed_fixed_files_verified', 'installed_archive_members_verified',
      'processed_fixed_totals', 'maximum_fixed_section_alignment']}))
