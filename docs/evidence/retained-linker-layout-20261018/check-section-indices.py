"""Offline selected dynamic-section-index count and source reconciliation."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
repo = root.parents[2]
sha = lambda raw: hashlib.sha256(raw).hexdigest()
manifest = json.loads((root/'sources.json').read_text())
assert sha((root/'sources.tar.gz').read_bytes()) == manifest['archive_sha256']
sources = {}
with tarfile.open(root/'sources.tar.gz') as archive:
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        sources[row['path']] = raw.decode()
extra = json.loads((root/'section-index-inputs.json').read_text())
assert extra['commit'] == manifest['commit']
for row in extra['supplement']:
    packed = (root/row['archive']).read_bytes()
    assert sha(packed) == row['archive_sha256']
    raw = gzip.decompress(packed)
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    sources[row['path']] = raw.decode()
for row in extra['retained_inputs']:
    raw = (root/row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
inputs = json.loads((root/'inputs.json').read_text())
for row in inputs:
    raw = (repo/row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']

anchors = {
    'bfd/elf.c': ['case SHT_REL:', 'case SHT_RELA:',
                  'target_sect->flags |= SEC_RELOC;',
                  'target_sect->reloc_count += (NUM_SHDR_ENTRIES (hdr)',
                  'if ((asect->flags & SEC_RELOC) != 0)',
                  'd->this_idx = section_number++;'],
    'bfd/elflink.c': ['|| (o->flags & SEC_RELOC) == 0',
                      '|| o->reloc_count == 0',
                      'elf_section_data (sec)->sreloc = reloc_sec;',
                      'emit_relocs = (bfd_link_relocatable (info)',
                      '|| info->emitrelocations);',
                      'o->reloc_count = 0;',
                      'else if (bed->elf_backend_count_relocs)',
                      'o->flags &=~ SEC_RELOC;',
                      'sym->st_shndx >= (SHN_LORESERVE & 0xffff)'],
    'bfd/elfxx-x86.c': ['for (rel = relocs; rel < rel_end; rel++)',
                       'sreloc = _bfd_elf_make_dynamic_reloc_section'],
    'ld/ldwrite.c': ['case lang_reloc_statement_enum:',
                     'link_order->type = bfd_section_reloc_link_order;',
                     'link_order->type = bfd_symbol_reloc_link_order;'],
}
for name, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[name], (name, snippet)
assert re.search(r'if \(bfd_link_relocatable \(&link_info\)\)\s*'
                 r'lang_add_reloc \(', sources['ld/ldctor.c'])
assert len(re.findall(r'lang_add_reloc\s*\(', sources['ld/ldctor.c'])) == 1
assert 'lang_add_reloc' not in sources['ld/ldgram.y']
assert re.search(r'#define elf_backend_count_relocs\s+NULL',
                 sources['bfd/elfxx-target.h'])
assert 'elf_backend_count_relocs' not in sources['bfd/elf64-x86-64.c']

def count_relocation_headers(raw, prior):
    assert raw[:6] == b'\x7fELF\x02\x01'
    assert struct.unpack_from('<H', raw, 18)[0] == 62
    offset = struct.unpack_from('<Q', raw, 40)[0]
    stride, count = struct.unpack_from('<HH', raw, 58)
    assert stride == 64
    if count == 0:
        count = struct.unpack_from('<Q', raw, offset + 32)[0]
    assert count == prior['sections'] and offset + stride*count <= len(raw)
    return sum(struct.unpack_from('<I', raw, offset + stride*i + 4)[0]
               in (4, 9) for i in range(count))

inventory = json.loads((repo/inputs[0]['path']).read_text())
rows = []
fixed = files = members = 0
loader = None
for item in inventory['files']:
    if item['role'] == 'generated-input':
        continue
    raw = Path(item['path']).read_bytes()
    assert len(raw) == item['bytes'] and sha(raw) == item['sha256']
    files += 1
    if item['kind'] == 'script':
        continue
    subtotal = 0
    for member in item.get('members', [item]):
        if item['kind'] == 'archive':
            start = member['header_offset'] + 60
            data = raw[start:start+member['bytes']]
            assert len(data) == member['bytes'] and sha(data) == member['sha256']
            prior = member
            members += 1
        else:
            data, prior = raw, item['elf']
        subtotal += count_relocation_headers(data, prior)
    multiplicity = item['link_argv_occurrences']
    fixed += multiplicity*subtotal
    rows.append(dict(path=item['path'], argv_occurrences=multiplicity,
                     one_occurrence_relocation_headers=subtotal))
    if item['path'] == '/lib64/ld-linux-x86-64.so.2':
        loader = subtotal
assert fixed == 7897 and loader == 1
processed = fixed + 8*loader
counts = json.loads((root/'check-results.json').read_text())
assert len(counts['script_output_section_names']) == 93
main = json.loads((repo/inputs[3]['path']).read_text())
assert main['section_headers_including_null'] == 22
assert main['relocation_sections_upper'] == 9
Sfixed = 36433 + processed + 3*1481 + 128
Smain = Sfixed + 22 + 9 + 3
assert Sfixed == 48909 and Smain == 48943
result = dict(
    scope='Sharper selected section bound; generated binder terms remain inputs',
    source_files_verified=len(sources), prior_inputs_verified=len(inputs)+len(extra['retained_inputs']),
    fixed_files_verified=files, archive_members_verified=members,
    fixed_relocation_header_files=rows,
    explicit_fixed_relocation_headers=fixed,
    eight_additional_loader_relocation_headers=8*loader,
    processed_fixed_relocation_headers=processed,
    Main_original_relocation_headers_upper=9,
    input_section_bound='Isharp = Q + Qrel + 3*P + 35',
    output_section_bound='Ssharp = Q + Qrel + 3*P + 128',
    hidden_output_REL_RELA_headers=0,
    output_header_bound='Nsharp = Ssharp + 5',
    fixed_output_section_contribution=Sfixed,
    fixed_plus_Main_output_section_contribution=Smain,
    binder_condition='Qbinder + Qrelbinder + 3*Pbinder <= 16336',
    sufficient_dynamic_index_condition='Ssharp < 0xff00',
    generated_binder_join_established=False, whole_link_capacity_established=False,
    generated_objects_read=False, native_execution=False)
assert 0xff00-1-Smain == 16336
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k: result[k] for k in ['source_files_verified',
    'fixed_files_verified','archive_members_verified','processed_fixed_relocation_headers',
    'fixed_plus_Main_output_section_contribution']}))
