"""Reconcile selected dynamic sizing events and dynamic-tag storage offline."""
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
manifest = json.loads((root/'join-sources.json').read_text())
assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
for row in manifest['retained_inputs']:
    raw = (root.parent/row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
sources = {}
for folder, stem in [(root.parent/'retained-linker-layout-20261018','sources'),
                     (root,'sources'), (root,'join-sources')]:
    record = json.loads((folder/(stem+'.json')).read_text())
    assert record['commit'] == manifest['commit']
    assert sha((folder/(stem+'.tar.gz')).read_bytes()) == record['archive_sha256']
    with tarfile.open(folder/(stem+'.tar.gz')) as archive:
        assert sorted(archive.getnames()) == sorted(r['path'] for r in record['files'])
        for row in record['files']:
            raw = archive.extractfile(row['path']).read()
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
            if row['path'] in sources:
                assert sources[row['path']] == raw.decode()
            sources[row['path']] = raw.decode()
anchors = {
    'bfd/elf64-x86-64.c': ['elf_x86_64_early_size_sections',
                          'elf_x86_64_scan_relocs))',
                          'p->count += 1;', 'p->pc_count += 1;',
                          '#define elf_backend_got_header_size', '(GOT_ENTRY_SIZE*3)'],
    'bfd/elflink.c': ['if (bed->elf_backend_early_size_sections',
                      'if (bed->elf_backend_late_size_sections != NULL',
                      'q->count += p->count;', 'q->pc_count += p->pc_count;',
                      'ind->dyn_relocs = NULL;',
                      'h->dynamic_adjusted = 1;',
                      'newsize = s->size + bed->s->sizeof_dyn;',
                      'dtagcount <= info->spare_dynamic_tags'],
    'bfd/elfxx-x86.c': ['elf_link_hash_traverse (&htab->elf, elf_x86_allocate_dynrelocs,',
                        'if (htab->has_loc_hash_table)',
                        'local_got = elf_local_got_refcounts (ibfd);',
                        'srel->size += htab->sizeof_reloc;',
                        'return _bfd_elf_maybe_vxworks_add_dynamic_tags'],
    'bfd/elfxx-x86.h': ['elf_x86_allocate_local_got_info', '+ 2 * sizeof(char)'],
    'bfd/elf-vxworks.c': ['return (_bfd_elf_add_dynamic_tags',
                         '|| htab->target_os != is_vxworks'],
    'ld/ldmain.c': ['link_info.spare_dynamic_tags = 5;'],
    'ld/ldelf.c': ['link_info.spare_dynamic_tags += 3;'],
    'ld/lexsup.c': ['link_info.spare_dynamic_tags = strtoul (optarg, NULL, 0);'],
}
for path, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[path], (path, snippet)

# Census direct calls by literal LF source locations, including inactive sites.
elf = sources['bfd/elflink.c']
start = elf.index('bfd_elf_size_dynamic_sections (')
end = elf.index('/* Create an entry in an ELF linker hash table.',start)
sites = []
for m in re.finditer(r'_bfd_elf_add_dynamic_entry\s*\(info,\s*([^,]+),',elf[start:end]):
    sites.append(dict(line=elf[:start+m.start()].count('\n')+1,tag=m.group(1)))
assert len(sites) == 31
assert sum(s['tag']=='DT_AUXILIARY' for s in sites) == 1
assert sum(s['tag']=='DT_NULL' for s in sites) == 1
start = elf.index('_bfd_elf_add_dynamic_tags (bfd *output_bfd')
helper_sites = re.findall(r'\badd_dynamic_entry\s*\(DT_[A-Z0-9_]+,',elf[start:])
assert len(helper_sites) == 14  # Charges both REL/RELA alternatives.
target = sources['bfd/elfxx-x86.c']
target_sites = re.findall(r'_bfd_elf_add_dynamic_entry\s*\(info,\s*DT_[A-Z0-9_]+,',target)
assert len(target_sites) == 3
tag_bound = (len(sites)-2) + 9 + 22 + len(helper_sites) + len(target_sites)
assert tag_bound == 77

inventory = json.loads((root.parent/'retained-link-inputs-20261018/inventory.json').read_text())
main = json.loads((root.parent/'retained-assembler-capacity-20261018/object-check-results.json').read_text())
loader = next(r['elf'] for r in inventory['files'] if r['path']=='/lib64/ld-linux-x86-64.so.2')
totals = inventory['summary']['weighted_fixed_sums']
fixed_rel = totals['relocation_records']+8*loader['relocation_records']
R = totals['symbol_records']+8*loader['symbol_records']+main['outgoing_symbol_entries_including_null']
Q = totals['sections']+8*loader['sections']+main['section_headers_including_null']
Trel = fixed_rel+main['relocations_upper']
H = 3*R+2*Q+72
assert (fixed_rel,Trel,R,H) == (546364,546645,49179,220519)
late_payload = 184*H+104*R+24*Trel+80
with_header_and_copy_relocs = late_payload+24+24*H
assert (late_payload,with_header_and_copy_relocs) == (58809672,64102152)
result = dict(
    scope='Selected one-pass x86 GOT/PLT event join and .dynamic tags; binder symbolic',
    source_files_verified=len(sources), prior_input_identities_verified=len(manifest['retained_inputs']),
    fixed_relocation_record_processing_bound=fixed_rel,
    fixed_plus_Main_relocation_bound=Trel,
    event_joins=dict(K='1',W='<=H',L='<=R',Q='<=Trel',N0='0'),
    dynamic_relocation_list_bytes_per_record=32,
    dynamic_relocation_list_record_count='<=Trel',
    local_GOT_metadata_bytes_per_input='18*local_symbol_count <= 18*R',
    late_payload='184*H + 104*R + 24*Trel + 80',
    including_initial_GOT_and_copy_relocations='208*H + 104*R + 24*Trel + 104',
    copy_symbol_storage_included=False,
    Main_substituted_payload='64102152 + 728*R_binder + 416*Q_binder + 24*Trel_binder',
    sufficient_jump_count_condition='H <= 536870911',
    caller_byte_and_counter_conditions_preserved=True,
    generic_size_dynamic_entry_sites=sites,
    generic_add_dynamic_tags_literal_sites=len(helper_sites),
    x86_extra_dynamic_tag_sites=len(target_sites),
    DT_NEEDED_attempt_upper=22,spare_NULL_slot_upper=9,
    dynamic_tag_count_upper=tag_bound,dynamic_tag_record_bytes=16,
    dynamic_table_bytes_upper=16*tag_bound,
    whole_link_capacity_established=False,native_execution=False)
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(sources=len(sources),fixed_plus_Main_payload=with_header_and_copy_relocs,
                     dynamic_tag_bytes=16*tag_bound,whole_link_capacity=False)))
