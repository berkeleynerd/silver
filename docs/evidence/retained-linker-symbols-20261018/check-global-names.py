"""Reconcile selected scripts and linker-created global names offline."""
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
    packed = root/f'{prefix}sources.tar.gz'
    assert sha(packed.read_bytes()) == manifest['archive_sha256']
    with tarfile.open(packed) as archive:
        assert sorted(archive.getnames()) == sorted(r['path'] for r in manifest['files'])
        for row in manifest['files']:
            raw = archive.extractfile(row['path']).read()
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
            sources[row['path']] = raw.decode()
    for row in manifest.get('retained_inputs', []):
        raw = (root.parent/row['path']).read_bytes()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']

inputs = root.parent/'retained-link-inputs-20261018'
script = (inputs/'link-script/installed-elf_x86_64.xdc').read_text()
captured = (inputs/'link-script/stdout').read_text()
assert captured.split('==================================================\n')[1] == script+'\n\n'
inventory = json.loads((inputs/'inventory.json').read_text())
scripts = [script]
for row in inventory['files']:
    if row['kind'] == 'script':
        raw = row['text'].encode()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        scripts.append(row['text'])
assert len(scripts) == 3
tokens = [re.sub(r'/\*.*?\*/', '', s, flags=re.S) for s in scripts]
assert all('@' not in s for s in scripts)
# Exact selected scripts are source-reviewed; this lexical check is not an ld parser.
assignments = re.findall(r'([A-Za-z_.][A-Za-z0-9_.]*)\s*=(?!=)', tokens[0])
non_dot = [s for s in assignments if s != '.']
expected = ['__executable_start', '__etext', '_etext', 'etext', '__tdata_start',
            '__preinit_array_start', '__preinit_array_end', '__init_array_start',
            '__init_array_end', '__fini_array_start', '__fini_array_end',
            '_edata', 'edata', '__bss_start', '_end', 'end']
assert non_dot == expected and len(set(non_dot)) == 16
assert len(assignments) == 26
assert all('=' not in s for s in tokens[1:])
assert re.findall(r'\bENTRY\s*\(\s*([^\s)]+)\s*\)', tokens[0]) == ['_start']
assert all(not re.search(r'\b(?:INCLUDE|OVERLAY|VERSION|EXTERN|INSERT)\b', s)
           for s in tokens)

anchors = {
    'ld/ldexp.c': ['case NAME:', 'tree->name.name,', 'tree->assign.dst,'],
    'ld/ldlang.c': ['lang_for_each_statement_worker', 'constructor_list.head,',
                    'lang_add_assignment (exp_provide (buf,'],
    'ld/ldctor.c': ['for (p = sets; p != NULL; p = p->next)',
                    'lang_add_assignment (exp_assign (p->h->root.string,'],
    'bfd/elflink.c': ['flags = BSF_NO_FLAGS;', 'flags = BSF_GLOBAL;',
                      'flags = BSF_WEAK;', 'flags = BSF_GNU_UNIQUE;',
                      '"_GLOBAL_OFFSET_TABLE_"', '"_DYNAMIC"',
                      '"_PROCEDURE_LINKAGE_TABLE_"',
                      'if (info->create_default_symver)',
                      '(info, dynobj, t->name, BSF_GLOBAL, bfd_abs_section_ptr,'],
    'bfd/elf-eh-frame.c': ['"__GNU_EH_FRAME_HDR", BSF_LOCAL,'],
    'bfd/elfxx-x86.c': ['"_TLS_MODULE_BASE_",', 'false, false, false);',
                       'if (tlsbase && tlsbase->type == STT_TLS)'],
    'bfd/elfxx-target.h': ['#define elf_backend_collect false'],
    'bfd/linker.c': ['if (collect && name[0] ==',
                     'else if ((flags & BSF_CONSTRUCTOR) != 0)'],
}
for path, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[path], (path, fragment)
assert 'BSF_CONSTRUCTOR' not in sources['bfd/elflink.c']
assert 'elf_backend_collect' not in sources['bfd/elf64-x86-64.c']
for path in ('ld/emultempl/elf.em', 'ld/emultempl/elf-x86.em',
             'ld/emultempl/elf-x86-64.em', 'ld/emultempl/elf-x86-glibc.em',
             'ld/emultempl/elf-x86-64-glibc.em'):
    assert not re.search(r'\b(?:exp_assign|exp_provide|lang_add_assignment)\s*\(', sources[path])

version = json.loads((root/'version-name-results.json').read_text())
fixed = json.loads((root/'input-symbol-results.json').read_text())
# Constants reproduce the independently retained fixed input/pass inventories.
assert len(version['version_names']) == version['fixed_distinct_version_suffixes_upper'] == 51
fixed_R = fixed['fixed_symbol_record_passes']
fixed_Q = fixed['fixed_section_record_passes']
assert (fixed_R, fixed_Q) == (49081, 36433)
input_events = 3*fixed_R+2*fixed_Q
assert input_events == fixed['fixed_global_entry_constructor_contribution_upper'] == 220109
script_name_budget = len(non_dot)+1
synthetic_names = ['_GLOBAL_OFFSET_TABLE_', '_DYNAMIC',
                   '_PROCEDURE_LINKAGE_TABLE_', '__GNU_EH_FRAME_HDR']
extra = script_name_budget+len(synthetic_names)
assert extra == 21
result = dict(
    scope='Selected scripts and linker-created global names; conditional generated-input join',
    source_files_verified=len(sources), selected_script_count=len(scripts),
    selected_script_bytes=[len(s.encode()) for s in scripts],
    non_dot_assignment_destinations=non_dot,
    all_script_assignments_including_dot=len(assignments),
    selected_assignment_walk_non_dot_visits_upper=16,
    script_global_name_budget=script_name_budget,
    independent_linker_created_names=synthetic_names,
    extra_global_name_budget_excluding_versions=extra,
    global_live_entry_and_traversal_domain_bound='3*R+2*Q+V+21',
    fixed_contribution_when_generated_names_lack_at= input_events+51+extra,
    lifetime_constructor_count_established=False,
    generated_symbol_and_section_name_no_at_premise_required=True,
    additional_version_suffixes_under_that_premise=0,
    version_nodes_under_that_premise_upper=51,
    maximum_version_index_under_that_premise_upper=169,
    dynamic_count_high_water_after_script_and_global_join='285 + 44*R + 24*Q + 2*Q_input + 2*Q_output + 13*V',
    whole_link_capacity_established=False, native_execution=False,
    reachability_basis='Source review; hashes, anchors and lexical inventories do not evaluate C or ld grammar')
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(sources=len(sources), assignment_visits=16,
                     extra_global_names=extra, whole_link_capacity=False)))
