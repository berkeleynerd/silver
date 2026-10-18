"""Reconcile selected ordinary output symbol/String-table capacity transfer."""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()
manifest = json.loads((root/'symtab-sources.json').read_text())
assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
assert sha((root/'symtab-sources.tar.gz').read_bytes()) == manifest['archive_sha256']
sources = {}
with tarfile.open(root/'symtab-sources.tar.gz') as tar:
    assert sorted(tar.getnames()) == sorted(r['path'] for r in manifest['files'])
    for row in manifest['files']:
        raw = tar.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        sources[row['path']] = raw.decode()
inputs = {}
for row in manifest['retained_inputs']:
    raw = (root.parent/row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    inputs[row['path']] = json.loads(raw)
anchors = {
    'bfd/bfd.c': ['unsigned int symcount;'],
    'bfd/archive.c': ['filename = new_areldata->filename;',
                      'if (!bfd_set_filename (n_bfd, filename))'],
    'bfd/elf-bfd.h': ['unsigned char sizeof_rel, sizeof_rela, sizeof_sym, sizeof_dyn, sizeof_note;',
                      'struct elf_sym_strtab', 'unsigned long dest_index;'],
    'bfd/elflink.c': ['if (! sub->output_has_begun)', 'sub->output_has_begun = true;',
                      'filename = lbasename (bfd_get_filename (input_bfd));',
                      'eoinfo.file_sym_done = false;', 'eoinfo->file_sym_done = true;',
                      'strtabsize += strtabsize;', 'if (max_sym_count < 20)',
                      'max_sym_count = 20;',
                      'if (flinfo->indices[symndx] == -1)',
                      'flinfo->indices[symndx] = indx;',
                      'if (flinfo->indices[r_symndx] == -1)',
                      'flinfo->indices[r_symndx] = indx;',
                      'amt = bed->s->sizeof_sym * flinfo->output_bfd->symcount;',
                      'flinfo->output_bfd->symcount += 1;',
                      'if (h->versioned == versioned && h->def_dynamic)',
                      'else if (flinfo->info->unique_symbol'],
    'ld/emultempl/elf.em': ['strcmp (optarg, "unique-symbol") == 0',
                           'link_info.unique_symbol = true;'],
}
for path, values in anchors.items():
    for value in values:
        assert value in sources[path], (path, value)
assert sources['bfd/elflink.c'].count('elf_link_swap_symbols_out (') == 2
for hook in ('elf_backend_output_arch_syms', 'elf_backend_name_local_section_symbols',
             'elf_backend_link_output_symbol_hook'):
    assert hook not in sources['bfd/elf64-x86-64.c']
    assert '#define '+hook in sources['bfd/elfxx-target.h']

fixed = inputs['retained-linker-symbols-20261018/input-symbol-results.json']
versions = inputs['retained-linker-symbols-20261018/version-name-results.json']
layout = inputs['retained-linker-layout-20261018/check-results.json']
main = inputs['retained-assembler-capacity-20261018/object-check-results.json']
inventory = inputs['retained-link-inputs-20261018/inventory.json']
names = []
for row in inventory['files']:
    if row['role'] == 'generated-input' or row['kind'] == 'script':
        continue
    if row['kind'] == 'archive':
        names += [x['name'] for x in row['members']]
    else:
        names.append(Path(row['path']).name)
assert max(map(len, names)) == 26
version_max = max(map(len, versions['version_names']))
assert version_max == 23
R = fixed['fixed_symbol_record_passes']+main['outgoing_symbol_entries_including_null']
Q = layout['fixed_header_record_passes']+main['section_headers_including_null']
P = layout['fixed_processed_ELF_occurrences']+1
V = versions['fixed_distinct_version_suffixes_upper']
H = 3*R+2*Q+V+21
S = 2*Q+3*P+128
Z = R+P+S+3*H+2
assert V == 51 and Z == 10*R+8*Q+4*P+346 == 789704
limit = (2**32-1)//24
assert limit == 178956970
assert 24*limit <= 2**32-1 < 24*(limit+1)
assert 40*2*max(20,limit) < 2**63
result = dict(
    scope='Selected ordinary .symtab/.strtab production; generated counts/lengths remain inputs',
    source_files_verified=len(sources), prior_input_identities_verified=len(inputs),
    output_symbol_bound='Z = R + P + S + 3*H + 2',
    substituted_bound_at_V51='Z = 10*R + 8*Q + 4*P + 346',
    fixed_plus_Main_bound='789704 + 10*R_binder + 8*Q_binder + 4*P_binder',
    fixed_plus_Main_contribution=Z,
    name_payload_bound='L = max(171, L_generated) + 25',
    distinct_names_upper='Z', positive_reference_events_upper='Z',
    unshared_string_bytes_upper='1 + Z*(L+1)',
    output_symbol_uint32_product_limit=limit,
    output_symbol_bytes='24*Z', optional_symbol_index_bytes='4*Z',
    internal_symbol_record_bytes=32, internal_symbol_and_destination_record_bytes=40,
    internal_buffer_capacity_upper='2*max(20,R,Z)',
    sample_payloads_if_binder_contribution_zero_and_Lgenerated_le171={
        'symbol_bytes':24*Z,'index_bytes':4*Z,'string_bytes':1+Z*197},
    sample_is_complete_binder_or_link_bound=False,
    dynamic_symbol_section_index_condition_established=False,
    shstrtab_included=False, whole_link_capacity_established=False, native_execution=False)
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(sources=len(sources), fixed_plus_Main_Z=Z,
                     symbol_product_sufficient_limit=limit, whole_link_capacity=False)))
