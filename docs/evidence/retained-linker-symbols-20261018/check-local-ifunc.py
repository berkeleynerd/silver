"""Reconcile fixed local IFUNC absence and selected empty-table storage."""
import argparse
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
sha = lambda raw: hashlib.sha256(raw).hexdigest()
sources = {}
bundles = [(root, f'{p}sources.json', f'{p}sources.tar.gz')
           for p in ('', 'input-symbol-', 'registration-', 'global-name-',
                     'hash-storage-', 'local-ifunc-')]
bundles.append((root.parent/'retained-linker-capacity-20261018',
                'source-manifest.json', 'sources.tar.gz'))
for base, manifest_name, archive_name in bundles:
    manifest = json.loads((base/manifest_name).read_text())
    assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
    packed = base/archive_name
    if 'archive_sha256' in manifest:
        assert sha(packed.read_bytes()) == manifest['archive_sha256']
    with tarfile.open(packed) as archive:
        assert sorted(archive.getnames()) == sorted(r['path'] for r in manifest['files'])
        for row in manifest['files']:
            raw = archive.extractfile(row['path']).read()
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
            if row['path'] in sources:
                assert sources[row['path']] == raw.decode()
            sources[row['path']] = raw.decode()

inventory_path = root.parent/'retained-link-inputs-20261018/inventory.json'
inventory = json.loads(inventory_path.read_text())
record = json.loads((root/'fixed-version-inputs.json').read_text())
assert sha(inventory_path.read_bytes()) == record['inventory_sha256']
assert sha((root/'fixed-version-regions.tar.gz').read_bytes()) == record['archive_sha256']
expected = [(fi, mi) for fi, f in enumerate(inventory['files'])
            if f['role'] != 'generated-input' and f['kind'] != 'script'
            for mi in (range(len(f['members'])) if f['kind'] == 'archive' else [None])]
assert [(r['file_index'], r['member_index']) for r in record['objects']] == expected
symbol_records = 0
ifuncs = []
with tarfile.open(root/'fixed-version-regions.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(p['path'] for r in record['objects'] for p in r['regions'])
    for row in record['objects']:
        file = inventory['files'][row['file_index']]
        identity = file if row['member_index'] is None else file['members'][row['member_index']]
        assert (row['bytes'], row['sha256']) == (identity['bytes'], identity['sha256'])
        regions = []
        for part in row['regions']:
            raw = archive.extractfile(part['path']).read()
            assert len(raw) == part['bytes'] and sha(raw) == part['sha256']
            regions.append((part['offset'], raw))
        def read(offset, size):
            for start, raw in regions:
                if start <= offset and offset+size <= start+len(raw):
                    return raw[offset-start:offset-start+size]
            raise AssertionError((offset, size))
        header = read(0, 64)
        assert header[:6] == b'\x7fELF\x02\x01'
        kind, machine = struct.unpack_from('<HH', header, 16)
        assert kind in (1, 3) and machine == 62
        offset = struct.unpack_from('<Q', header, 40)[0]
        step, count = struct.unpack_from('<HH', header, 58)
        assert step == 64
        count = count or struct.unpack_from('<Q', read(offset, 64), 32)[0]
        sections = [struct.unpack('<IIQQQQIIQQ', read(offset+64*i, 64)) for i in range(count)]
        for section in sections:
            if section[1] not in (2, 11):
                continue
            raw = read(section[4], section[5])
            assert section[9] == 24 and len(raw) % 24 == 0
            assert section[7] <= len(raw)//24
            symbol_records += len(raw)//24
            for index in range(len(raw)//24):
                info = raw[index*24+4]
                local = index < section[7]
                assert local == (info >> 4 == 0)
                if info & 15 == 10:
                    ifuncs.append(dict(file_index=row['file_index'],
                                       member_index=row['member_index'],
                                       elf_kind=kind, local=local))
assert len(record['objects']) == 1169
assert len(ifuncs) == 82 and all(x['elf_kind'] == 3 and not x['local'] for x in ifuncs)
assert len({x['file_index'] for x in ifuncs}) == 2

source = sources['bfd/elfxx-x86.c']
assert 'ret->loc_hash_table = htab_try_create (1024,' in source
assert 'ret->loc_hash_memory = objalloc_create ();' in source
assert 'if (htab->has_loc_hash_table)' in source
assert 'htab->has_loc_hash_table = 1;' in source
assert source.count('htab->has_loc_hash_table = 1;') == 1
target = sources['bfd/elf64-x86-64.c']
assert target.count('_bfd_elf_x86_get_local_sym_hash (') == 2
calls = re.findall(r'_bfd_elf_x86_get_local_sym_hash\s*\(.*?\);', target, re.S)
assert calls[0].rstrip().endswith('true);') and calls[1].rstrip().endswith('false);')
prime_body = sources['libiberty/hashtab.c'].split('static struct prime_ent const prime_tab[] = {')[1].split('};')[0]
primes = [int(n, 0) for n in re.findall(r'\{\s*(0x[0-9a-f]+|\d+)\s*,', prime_body)]
capacity = min(p for p in primes if p >= 1024)
assert capacity == 2039
assert '#define CHUNK_SIZE (4096 - 32)' in sources['libiberty/objalloc.c']
result = dict(
    scope='Fixed ELF local-IFUNC absence plus empty-table transfer, conditional on generated-name/type projection',
    complete_source_files_verified=len(sources), fixed_elf_objects=len(record['objects']),
    fixed_symbol_records=symbol_records, fixed_ifunc_symbols=82,
    fixed_local_ifunc_symbols=0, generated_local_ifunc_absence_source_premise_required=True,
    selected_local_entries_under_premise=0, initial_pointer_capacity=capacity,
    initial_pointer_bytes=8*capacity, htab_control_bytes_upper=128,
    objalloc_control_bytes=24, initial_objalloc_chunk_bytes=4064,
    later_local_entry_allocations_under_premise=0,
    regular_global_ifunc_path_excluded=False,
    whole_link_capacity_established=False, native_execution=False)
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(sources=len(sources), fixed_objects=len(record['objects']),
                     fixed_local_ifuncs=0, conditional_local_entries=0)))
