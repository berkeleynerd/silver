"""Offline reconciliation of selected output section-name String-table bounds."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()
manifest = json.loads((root/'shstrtab-inputs.json').read_text())
assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
for row in manifest['retained_inputs']:
    raw = (root.parent/row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
layout = root.parent/'retained-linker-layout-20261018'
record = json.loads((layout/'sources.json').read_text())
assert record['commit'] == manifest['commit']
assert sha((layout/'sources.tar.gz').read_bytes()) == record['archive_sha256']
sources = {}
with tarfile.open(layout/'sources.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(r['path'] for r in record['files'])
    for row in record['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        sources[row['path']] = raw.decode()
row = manifest['supplement']
packed = (root/'shstrtab-compress.c.gz').read_bytes()
assert sha(packed) == row['archive_sha256']
raw = gzip.decompress(packed)
assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
sources[row['path']] = raw.decode()
anchors = {
    'bfd/elf.c': ['if (abfd->output_has_begun)',
                  'abfd->output_has_begun = true;',
                  'bfd_map_over_sections (abfd, elf_fake_sections, &fsargs);',
                  '_bfd_elf_strtab_clear_all_refs (elf_shstrtab (abfd));',
                  'sizeof ".rela" + strlen (sec_name)',
                  '".symtab_shndx", false);',
                  'if (delay_sh_name_p)',
                  'else if (shdrp->sh_name == -1u)'],
    'bfd/elflink.c': ['const char *prefix = is_rela ? ".rela" : ".rel";',
                      'elf_section_data (sec)->sreloc = reloc_sec;'],
    'ld/ldelf.c': ['secname = ".mbind.bss";', 'secname = ".mbind.data";',
                   'secname = ".mbind.rodata";', 'secname = ".mbind.text";'],
    'ld/ldlang.c': ['secname, address, normal_section, 0, NULL, NULL, NULL, constraint, 0);'],
    'bfd/compress.c': ['bfd_debug_name_to_zdebug', 'bfd_alloc (abfd, len + 2)'],
}
for path, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[path], (path, snippet)
assert 'elf_backend_init_file_header' not in sources['bfd/elf64-x86-64.c']
assert '#define elf_backend_init_file_header' in sources['bfd/elfxx-target.h']

# A name offset can select a suffix of a NUL-delimited run. Taking every
# complete run therefore bounds even unused/suffix-shared section names.
names = json.loads((root/'fixed-name-inputs.json').read_text())
assert sha((root/'fixed-name-regions.tar.gz').read_bytes()) == names['archive_sha256']
fixed_max = 0
with tarfile.open(root/'fixed-name-regions.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(r['path'] for r in names['objects'])
    for row in names['objects']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        fixed_max = max(fixed_max, max(map(len, raw.split(b'\0'))))
assert fixed_max <= 171
counts = json.loads((layout/'check-results.json').read_text())
script_names = counts['script_output_section_names']
assert max(map(len, script_names)) <= 171
S0 = 77484
K0 = 3*S0+4
U0 = 6*S0+7
L0 = 171+11
Nlimit = (2**32-1)//64
Slimit = (Nlimit-5)//3
assert 3*Slimit+4 < 805306341
assert 6*Slimit+7 < 2**32
result = dict(
    scope='Selected output .shstrtab; source-derived generated section names remain inputs',
    source_files_verified=len(sources), prior_input_identities_verified=len(manifest['retained_inputs']),
    fixed_name_tables_verified=len(names['objects']), fixed_name_run_maximum=fixed_max,
    script_name_maximum=max(map(len,script_names)),
    distinct_name_and_add_event_bound='K = 3*S + 4',
    positive_reference_event_bound='U = 6*S + 7',
    name_payload_bound='Lsh = max(171, Lsection_generated) + 11',
    unshared_bytes_bound='1 + (3*S+4)*(Lsh+1)',
    sufficient_conditions=['Lsh <= 2^31-2', '1+(3*S+4)*(Lsh+1) <= 2^32',
                           '64*(3*S+5) <= 2^32-1'],
    section_header_product_also_implies_hash_and_reference_conditions=True,
    fixed_plus_Main_sample_excluding_binder=dict(
        S=S0, name_entries=K0, positive_events=U0,
        payload_length_if_generated_le171=L0, unshared_bytes=1+K0*(L0+1)),
    generated_binder_join_established=False, whole_link_capacity_established=False,
    native_execution=False)
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(sources=len(sources), fixed_name_tables=len(names['objects']),
                     fixed_name_run_maximum=fixed_max, sample_bytes=1+K0*(L0+1))))
