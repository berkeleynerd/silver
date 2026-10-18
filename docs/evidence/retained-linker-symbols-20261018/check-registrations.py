"""Reconcile the selected x86 ELF dynamic-registration schedule offline."""
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
sources = {}
for prefix in ('', 'input-symbol-', 'registration-'):
    manifest = json.loads((root/f'{prefix}sources.json').read_text())
    assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
    archive_path = root/f'{prefix}sources.tar.gz'
    assert hashlib.sha256(archive_path.read_bytes()).hexdigest() == manifest['archive_sha256']
    with tarfile.open(archive_path) as archive:
        assert sorted(archive.getnames()) == sorted(r['path'] for r in manifest['files'])
        for row in manifest['files']:
            raw = archive.extractfile(row['path']).read()
            assert len(raw) == row['bytes']
            assert hashlib.sha256(raw).hexdigest() == row['sha256']
            sources[row['path']] = raw.decode()

# This checks a source-reviewed schedule, not C semantics or call-graph reachability.
def lines_with(path, pattern):
    return [i for i, line in enumerate(sources[path].split('\n'), 1)
            if re.search(pattern, line)]

global_sites = lines_with('bfd/elflink.c', r'\bbfd_elf_link_record_dynamic_symbol\s*\(')
assert global_sites == [592, 828, 839, 1531, 2117, 2290, 3093, 3142, 3303,
                        5688, 5693, 6096, 6111, 7205, 7252, 15741]
x86_sites = lines_with('bfd/elfxx-x86.c', r'\bbfd_elf_link_record_dynamic_symbol\s*\(')
assert x86_sites == [179, 329, 461, 469, 514]
assert lines_with('bfd/elf64-x86-64.c', r'\bbfd_elf_link_record_dynamic_symbol\s*\(') == []
assert lines_with('bfd/elf-ifunc.c', r'\bbfd_elf_link_record_dynamic_symbol\s*\(') == []
assert lines_with('bfd/elf-vxworks.c', r'\bbfd_elf_link_record_dynamic_symbol\s*\(') == [116]

anchors = {
    'bfd/elfxx-x86.h': [
        '#define elf_backend_omit_section_dynsym _bfd_elf_omit_section_dynsym_all',
        '#define elf_backend_fixup_symbol _bfd_x86_elf_fixup_symbol',
        '#define elf_backend_late_size_sections _bfd_x86_elf_late_size_sections'],
    'bfd/elfxx-x86.c': [
        'bfd_zmalloc (amt)',
        'h->dynindx = -1;',
        'elf_link_hash_traverse (&htab->elf, elf_x86_allocate_dynrelocs,',
        'if (h->type == STT_GNU_IFUNC',
        'htab->elf.target_os == is_vxworks',
        '&& !elf_vxworks_create_dynamic_sections'],
    'bfd/elflink.c': [
        'h->dynamic_adjusted = 1;',
        'if (!_bfd_elf_adjust_dynamic_symbol (def, eif))',
        'table->dynsymcount = 1;',
        'elf_hash_table (info)->dynsymcount = dynsymcount;',
        'elf_link_renumber_local_hash_table_dynsyms',
        'elf_link_renumber_hash_table_dynsyms',
        'if (info->create_default_symver)'],
    'ld/ldelf.c': [
        'lang_for_each_statement (ldelf_find_statement_assignment);',
        'if (! (bfd_elf_size_dynamic_sections'],
    'ld/ldlang.c': [
        'lang_symbol_tweaks ();', 'lang_init_startof_sizeof ();',
        'config.emitting_gnu_object_only = true;'],
    'ld/emultempl/elf-x86-64.em': [
        'gld${EMULATION_NAME}_before_allocation ();'],
    'ld/emultempl/elf.em': [
        'ldelf_before_allocation (&audit, &depaudit, ${ELF_INTERPRETER_NAME});'],
}
for path, fragments in anchors.items():
    for fragment in fragments:
        assert ' '.join(fragment.split()) in ' '.join(sources[path].replace(chr(92)+chr(10), ' ').split()), (path, fragment)
assert lines_with('bfd/elflink.c', r'\bdynamic_adjusted\s*=') == [3338]
assert 'elf_backend_omit_section_dynsym' not in sources['bfd/elf64-x86-64.c']
assert 'bfd_elf_link_record_local_dynamic_symbol' not in sources['bfd/elfxx-x86.c']
assert 'bfd_elf_link_record_local_dynamic_symbol' not in sources['bfd/elf64-x86-64.c']
assert 'bfd_elf_link_record_local_dynamic_symbol' not in sources['bfd/elf-ifunc.c']

counts = dict(export=1, version_flag_fix=1, dynamic_adjustment=4,
              x86_relocation_allocation=5)
assert sum(counts.values()) == 11
# Renumbering can reset above an earlier count. Start at H+1, then retain all
# increments, including registrations discarded by rollback or hiding.
result = dict(scope='Selected x86 ELF dynamic-symbol lifetime transfer',
              source_files_verified=len(sources),
              ordinary_elf_global_registration_sites=global_sites,
              x86_global_registration_sites=x86_sites,
              dynamic_section_symbol_prefix=0,
              backend_local_dynamic_list_entries=0,
              global_traversal_registration_coefficient=counts,
              total_global_traversal_registration_coefficient=11,
              start_stop_registration_bound='2*Q_input + 2*Q_output',
              registration_increments_bound='8*R + 11*H + 2*A + V + 2*Q_input + 2*Q_output',
              renumbered_count_bound='H+1',
              dynamic_count_high_water_bound='1 + 8*R + 12*H + 2*A + V + 2*Q_input + 2*Q_output',
              GNU_hash_selected_count_bound='H',
              input_and_global_and_statement_and_section_counts_supplied=False,
              source_to_all_counts_closed=False,
              dynamic_string_other_users_included=False,
              whole_link_capacity_established=False, native_execution=False)
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(source_files_verified=len(sources), section_prefix=0,
                     local_dynamic_list=0, traversal_coefficient=11,
                     whole_link_capacity_established=False)))
