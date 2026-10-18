"""Reconcile global link-hash growth, records and rollback snapshot requests."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output',type=Path,required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
sources = {}
bundles = [(root, f'{p}sources.json', f'{p}sources.tar.gz')
           for p in ('','input-symbol-','registration-','global-name-','hash-storage-')]
bundles.append((root.parent/'retained-linker-capacity-20261018',
                'source-manifest.json','sources.tar.gz'))
for base, name, archive_name in bundles:
    manifest=json.loads((base/name).read_text())
    assert manifest['commit']=='5e56594815854de5eca35c7c04b11705d0f19c02'
    with tarfile.open(base/archive_name) as archive:
        for row in manifest['files']:
            raw=archive.extractfile(row['path']).read()
            assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256']
            if row['path'] in sources:
                assert sources[row['path']]==raw.decode()
            sources[row['path']]=raw.decode()

def body(path,name):
    text=re.sub(r'/\*.*?\*/','',sources[path],flags=re.S)
    start=text.index('{',text.index('struct '+name+'\n'))+1
    depth=1
    for end in range(start,len(text)):
        depth += (text[end]=='{')-(text[end]=='}')
        if depth==0: return text[start:end]
    raise AssertionError(name)

bits={}
for path,name in [('include/bfdlink.h','bfd_link_hash_entry'),
                  ('bfd/elf-bfd.h','elf_link_hash_entry'),
                  ('bfd/elfxx-x86.h','elf_x86_link_hash_entry')]:
    bits[name]=len(re.findall(r':\s*\d+\s*;',body(path,name)))
assert bits=={'bfd_link_hash_entry':8,'elf_link_hash_entry':27,'elf_x86_link_hash_entry':10}
round8=lambda n:(n+7)&~7
# Charge each bitfield its own four-byte unit, including unused padding.
# All listed nonbitfield members/unions have the reviewed LP64 widths.
base_bound=24+round8(4*bits['bfd_link_hash_entry'])+24
elf_extension_bound=10*8+round8(4*bits['elf_link_hash_entry'])
x86_extension_bound=8+round8(4*bits['elf_x86_link_hash_entry'])+3*8
entry_layout_bound=base_bound+elf_extension_bound+x86_extension_bound
assert entry_layout_bound<=512
anchors={
    'bfd/elflink.c':['size_t tabsize = 0;', 'size_t entsize;',
                      'old_tab = bfd_malloc (tabsize + entsize);',
                      'htab->root.table.count = old_count;',
                      'htab->root.table.size = old_size;',
                      'alloc_mark = bfd_hash_allocate (&htab->root.table, 1);'],
    'bfd/hash.c':['table->count++;','unsigned int size)',
                  'objalloc_alloc ((struct objalloc *) table->memory, alloc)'],
    'include/objalloc.h':['unsigned int current_space;','void *chunks;'],
    'libiberty/objalloc.c':['#define CHUNK_SIZE (4096 - 32)',
                           'CHUNK_HEADER_SIZE + len'],
}
for path, values in anchors.items():
    for value in values: assert value in sources[path],(path,value)
primes=[int(x) for x in re.findall(r'UINT32_C \((\d+)\)',sources['bfd/hash.c'])]
max_capacity=max(p for p in primes if 3*p<=2**32-1)
max_entries=3*max_capacity//4
snapshot=8*max_capacity+(2*512+16)*max_entries
assert (max_capacity,max_entries)==(1073741789,805306341)
assert snapshot<2**63
assert round8(2**32-1)+16<2**63
result=dict(scope='Selected global link-hash record/backbone/snapshot capacity',
            source_files_verified=len(sources),bitfield_counts=bits,
            base_record_layout_bound=base_bound,
            elf_record_extension_bound=elf_extension_bound,
            x86_record_extension_bound=x86_extension_bound,
            combined_record_layout_bound=entry_layout_bound,
            charged_entry_bytes=512,common_record_bytes=16,
            hash_entry_sufficient_limit=max_entries,
            pointer_capacity_limit=max_capacity,
            snapshot_request_bound='8*C + 1040*H',
            snapshot_bytes_at_sufficient_limits=snapshot,
            global_name_payload_sufficient_limit=2**32-2,
            global_name_bound='max(171,L_generated)+2+L_version',
            actual_hash_count_restored_on_rollback=True,
            objalloc_has_cumulative_allocation_counter=False,
            lifetime_constructor_gate_required_for_this_arena=False,
            actual_BFD_alloc_size_counter_included=False,
            source_to_generated_counts_and_lengths_complete=False,
            whole_link_capacity_established=False,native_execution=False)
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(sources=len(sources),record_bound=entry_layout_bound,
                     max_snapshot=snapshot,whole_link_capacity=False)))
