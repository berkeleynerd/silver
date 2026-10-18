"""Derive selected GNU property rewrite bounds from pinned sources/ELF bytes."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
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
inputs = json.loads((root / 'inputs.json').read_text())
for row in inputs:
    raw = (repo / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
inventory = json.loads((repo / inputs[0]['path']).read_text())
transformation_inputs = json.loads((root / 'transformation-inputs.json').read_text())
for row in transformation_inputs:
    raw = (repo / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
assembler = json.loads((repo / transformation_inputs[2]['path']).read_text())
Main_properties = (assembler['selected_unit_emission']['compiler_property_payload_bytes']
                   + assembler['optional_x86_property_note_payload_bytes'])
assert Main_properties == 144
anchors = {
    'bfd/elf-properties.c': [
        'if (datasz > p->property.pr_datasz)',
        '*pr = p->property;',
        'size += 4 + 4 + datasz;',
        'size = (size + (align_size - 1)) & ~(align_size - 1);',
        'elf_property_list *list, unsigned int size,',
        '_bfd_elf_get_property (first_pbfd, GNU_PROPERTY_1_NEEDED, 4);',
        '_bfd_elf_get_property (first_pbfd, GNU_PROPERTY_MEMORY_SEAL, 0);',
        '_bfd_elf_get_property (first_pbfd, GNU_PROPERTY_STACK_SIZE,',
        'elfclass == ELFCLASS64 ? 3 : 2',
    ],
    'bfd/elfxx-x86.c': [
        'GNU_PROPERTY_X86_FEATURE_1_AND,\n\t\t\t\t\t4);',
        'GNU_PROPERTY_X86_ISA_1_NEEDED,\n\t\t\t\t\t4);',
        '_bfd_x86_elf_link_fixup_gnu_properties',
        'unsigned int class_align = ABI_64_P (info->output_bfd) ? 3 : 2;',
    ],
}
for name, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[name], (name, snippet)
fixup = sources['bfd/elfxx-x86.c'].split('_bfd_x86_elf_link_fixup_gnu_properties', 1)[1].split('\nbool\n', 1)[0]
assert '_bfd_elf_get_property' not in fixup


def properties(raw):
    assert raw[:6] == b'\x7fELF\x02\x01'
    assert struct.unpack_from('<H', raw, 18)[0] == 62
    off = struct.unpack_from('<Q', raw, 40)[0]
    stride, count, string_index = struct.unpack_from('<HHH', raw, 58)
    assert stride == 64 and 0 < count < 0xff00 and string_index < count
    headers = [struct.unpack_from('<IIQQQQIIQQ', raw, off + i * 64)
               for i in range(count)]
    shstr = headers[string_index]
    strings = raw[shstr[4]:shstr[4] + shstr[5]]
    types = Counter()
    notes = 0
    for h in headers:
        if h[1] != 7:
            continue
        name = strings[h[0]:strings.index(0, h[0])]
        data = raw[h[4]:h[4] + h[5]]
        assert len(data) == h[5]
        align = max(4, h[8])
        assert align in (4, 8)
        at = 0
        while at < len(data):
            namesz, descsz, note_type = struct.unpack_from('<III', data, at)
            name_start = at + 12
            desc = (name_start + namesz + align - 1) & -align
            end = (desc + descsz + align - 1) & -align
            assert name_start + namesz <= desc <= desc + descsz <= end <= len(data)
            if note_type == 5 and data[name_start:name_start + namesz] == b'GNU\0':
                # Ensure other note sections cannot hide extra fixed properties.
                assert name == b'.note.gnu.property' and align == 8
                notes += 1
                pos = desc
                while pos < desc + descsz:
                    kind, size = struct.unpack_from('<II', data, pos)
                    assert pos + 8 + size <= desc + descsz
                    types[(kind, size)] += 1
                    pos = (pos + 8 + size + 7) & -8
                assert pos == desc + descsz
            at = end
    return notes, types


types = Counter()
notes = files = members = 0
for f in inventory['files']:
    if f['role'] == 'generated-input':
        continue
    raw = Path(f['path']).read_bytes()
    assert len(raw) == f['bytes'] and sha(raw) == f['sha256']
    files += 1
    if f['kind'] == 'script':
        continue
    for member in f.get('members', [f]):
        if f['kind'] == 'archive':
            start = member['header_offset'] + 60
            data = raw[start:start + member['bytes']]
            assert len(data) == member['bytes'] and sha(data) == member['sha256']
            members += 1
        else:
            data = raw
        count, part = properties(data)
        multiplicity = f['link_argv_occurrences']
        notes += multiplicity * count
        types.update({key: multiplicity * value for key, value in part.items()})
assert notes == 2083
assert dict(types) == {(0xc0000002, 4): 620, (0xc0010002, 4): 1463,
                       (0xc0010001, 4): 1463, (0xc0008002, 4): 2}
fixed_union = sum((8 + size + 7) & -8 for _, size in types)
new_sizes = [4, 4, 4, 0, 8]  # x86 feature/ISA; needed; seal; stack.
new_bytes = sum((8 + size + 7) & -8 for size in new_sizes)
assert fixed_union == 64 and new_bytes == 72
result = {
    'scope': 'Selected GNU property rewrite payload/alignment; binder property input remains symbolic',
    'source_files_verified': len(sources),
    'prior_inputs_verified': len(inputs) + len(transformation_inputs),
    'installed_fixed_files_verified': files, 'installed_archive_members_verified': members,
    'explicit_weighted_fixed_property_notes': notes,
    'fixed_property_types': [{'type': hex(kind), 'data_bytes': size, 'occurrences': count}
                             for (kind, size), count in sorted(types.items())],
    'fixed_union_serialized_property_bytes': fixed_union,
    'extra_loader_processing_adds_no_new_property_type': True,
    'additional_property_data_sizes_charged': new_sizes,
    'additional_property_serialized_bytes': new_bytes,
    'output_note_prefix_bytes': 16,
    'formula': 'Property_output <= 152 + Pgenerated',
    'incoming_Pgenerated': 'Sum of padded serialized property-record bytes across all generated ELF notes; full generated property-note byte sum is sufficient',
    'rewrite_alignment_bytes': 8,
    'source_derived_Main_property_note_bytes_upper': Main_properties,
    'Main_substituted_formula': 'Property_output <= 296 + Pbinder_property',
    'writer_unsigned_size_condition': '152 + Pgenerated <= UINT32_MAX',
    'sum_original_plus_full_rewrite_required_for_per_input_maxima': True,
    'generated_inputs_or_whole_link_capacity_established': False,
    'generated_objects_read': False, 'native_execution': False,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['source_files_verified',
      'installed_fixed_files_verified', 'installed_archive_members_verified',
      'fixed_union_serialized_property_bytes', 'formula']}))
