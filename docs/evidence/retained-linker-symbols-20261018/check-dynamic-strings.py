"""Reconcile selected dynamic-string names and lifetime positive references."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()
sources = {}
for prefix in ('', 'input-symbol-', 'registration-', 'global-name-'):
    manifest = json.loads((root/f'{prefix}sources.json').read_text())
    assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
    archive_path = root/f'{prefix}sources.tar.gz'
    assert sha(archive_path.read_bytes()) == manifest['archive_sha256']
    with tarfile.open(archive_path) as archive:
        for row in manifest['files']:
            raw = archive.extractfile(row['path']).read()
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
            sources[row['path']] = raw.decode()
    for row in manifest.get('retained_inputs', []):
        raw = (root.parent/row['path']).read_bytes()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']

lines = sources['bfd/elflink.c'].split('\n')
sites = [i for i,s in enumerate(lines,1)
         if re.search(r'\b_bfd_elf_strtab_(add|addref)\s*\(',s)]
assert sites == [659,914,3944,6991,7167,7179,7281,7303,7404,7427,
                 7588,7602,7617,7629,7640,10432]
for p in ('bfd/elfxx-x86.c','bfd/elf64-x86-64.c','bfd/elf-ifunc.c','bfd/elf-eh-frame.c'):
    assert not re.search(r'\b_bfd_elf_strtab_(add|addref)\s*\(',sources[p])
assert 'if (!htab->handling_dt_needed)' in sources['ld/ldelf.c']
assert 'elf_dt_name (abfd) = soname;' in sources['bfd/elflink.c']
assert 't = (struct bfd_elf_version_tree *) bfd_zalloc' in sources['bfd/elflink.c']

inputs = root.parent/'retained-link-inputs-20261018'
inventory = json.loads((inputs/'inventory.json').read_text())
checks = json.loads((inputs/'checks.json').read_text())
fixed = checks['fixed_add_symbol_input_bounds_with_loader_revisits']
assert fixed['input_name_occurrences'] == 72019
assert fixed['unshared_input_name_bytes'] == 1568528
dsos = [row for row in inventory['files']
        if row['kind']=='elf' and row['elf']['elf_type']==3]
assert len(dsos) == 3
sonames = []
for row in dsos:
    tags = row['elf']['dynamic_tags']
    assert str(0x6ffffefc) not in tags  # DT_AUDIT: no input depaudit contribution.
    assert len(row['elf']['soname']) == 1 and row['elf']['soname'][0]
    sonames.extend(row['elf']['soname'])
global_names = json.loads((root/'global-name-results.json').read_text())
versions = json.loads((root/'version-name-results.json').read_text())['version_names']
assert len(versions)==51 and all('@' not in n for n in versions)
backend_versions = ['GLIBC_ABI_DT_RELR','GLIBC_ABI_GNU2_TLS',
                    'GLIBC_ABI_DT_X86_64_PLT','GLIBC_2.36']
extra_names = (global_names['non_dot_assignment_destinations']+['_start']
               +global_names['independent_linker_created_names']
               +versions+backend_versions+sonames+['main'])
assert len(extra_names) == 80
constant_bytes = 1+fixed['unshared_input_name_bytes']+sum(len(s.encode())+1 for s in extra_names)+1
constant_names = fixed['input_name_occurrences']+len(extra_names)+1
max_fixed_payload = max(inventory['summary']['max_fixed_name_bytes'],
                        max(len(s.encode()) for s in extra_names))
assert max_fixed_payload == 171
needed_attempts = 2*(1+1+9)  # Two hooks, conservatively charging every retained DSO processing.
other_ref_constant = needed_attempts+1+117+11+1
assert other_ref_constant == 152
result = dict(
    scope='Selected .dynstr lifetime input transfer; generated-name premise retained',
    source_files_verified=len(sources), elflink_string_add_and_addref_sites=sites,
    all_fixed_DSOs_have_soname_and_no_DT_AUDIT=True,
    extra_name_occurrences_excluding_rpath=len(extra_names),
    extra_names_excluding_rpath=extra_names,
    fixed_name_occurrences_including_rpath=constant_names,
    distinct_name_bound=f'{constant_names} + N_generated',
    unshared_bytes_bound=f'{constant_bytes} + B_generated + L_rpath',
    payload_length_bound='max(171, L_generated, L_rpath)',
    positive_reference_bound='J + V + 152',
    positive_reference_bound_when_V_at_most_51='J + 203',
    J_meaning='8*R + 11*H + 2*A + V + 2*Q_input + 2*Q_output',
    fixed_positive_reference_additions_excluding_version_definition_names=other_ref_constant,
    needed_tag_attempt_upper=needed_attempts,
    generated_name_no_at_required=True,
    generated_counts_lengths_and_section_visits_supplied=False,
    ordinary_symbol_and_section_string_tables_included=False,
    whole_link_capacity_established=False,native_execution=False)
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ('distinct_name_bound','unshared_bytes_bound','positive_reference_bound')}))
