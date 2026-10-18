"""Retain/replay fixed ELF symbol and version tables without executing tools."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import struct
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--capture', action='store_true')
parser.add_argument('--installed', action='store_true')
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
inventory_path = root.parent / 'retained-link-inputs-20261018/inventory.json'
inventory = json.loads(inventory_path.read_text())
sha = lambda b: hashlib.sha256(b).hexdigest()

def header(read):
    raw = read(0, 64)
    assert raw[:6] == b'\x7fELF\x02\x01'
    kind, machine = struct.unpack_from('<HH', raw, 16)
    assert machine == 62 and kind in (1, 3)
    offset = struct.unpack_from('<Q', raw, 40)[0]
    step, count = struct.unpack_from('<HH', raw, 58)
    assert step == 64
    count = count or struct.unpack_from('<Q', read(offset, 64), 32)[0]
    sections = [struct.unpack('<IIQQQQIIQQ', read(offset+64*i, 64))
                for i in range(count)]
    return kind, offset, sections

def inspect(read):
    kind, _, sections = header(read)
    versions = []
    definitions = []
    symbol_count = 0
    for section in sections:
        if section[1] not in (2, 11, 0x6ffffffd):
            continue
        raw = read(section[4], section[5])
        names_section = sections[section[6]]
        assert names_section[1] == 3
        names = read(names_section[4], names_section[5])
        name = lambda i: names[i:names.index(0, i)].decode('ascii')
        if section[1] in (2, 11):
            assert section[9] == 24 and len(raw) % 24 == 0
            symbol_count += len(raw)//24
            for p in range(0, len(raw), 24):
                ni, info, _, index, _, _ = struct.unpack_from('<IBBHQQ', raw, p)
                text = name(ni)
                if kind == 1 and info >> 4 and index != 0 and '@' in text:
                    definitions.append(text)
        else:
            assert kind == 3
            p = 0
            while p < len(raw):
                version, flags, index, count, _, aux, nxt = struct.unpack_from('<HHHHIII', raw, p)
                assert version == 1 and count >= 1 and 0 < index < 32768
                q = p+aux
                auxnames = []
                for i in range(count):
                    ni, following = struct.unpack_from('<II', raw, q)
                    auxnames.append(name(ni))
                    assert (following == 0) == (i == count-1)
                    q += following
                versions.append({'index': index, 'flags': flags, 'names': auxnames})
                if nxt == 0:
                    break
                assert nxt >= 20 and p+nxt < len(raw)
                p += nxt
            assert len(versions) == section[7]
    assert len({v['index'] for v in versions}) == len(versions)
    return {'kind': kind, 'symbol_records': symbol_count,
            'regular_defined_versioned_symbols': definitions, 'versions': versions}

file_cache = {}
def installed_object(row):
    source = inventory['files'][row['file_index']]
    if row['file_index'] not in file_cache:
        raw = Path(source['path']).read_bytes()
        assert len(raw) == source['bytes'] and sha(raw) == source['sha256']
        file_cache[row['file_index']] = raw
    raw = file_cache[row['file_index']]
    if row['member_index'] is not None:
        member = source['members'][row['member_index']]
        offset = member['header_offset']
        assert raw[offset+58:offset+60] == b'`\n'
        assert int(raw[offset+48:offset+58]) == member['bytes']
        raw = raw[offset+60:offset+60+member['bytes']]
        assert sha(raw) == member['sha256']
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    return raw

if args.capture:
    rows = []
    archive_bytes = io.BytesIO()
    with tarfile.open(fileobj=archive_bytes, mode='w') as archive:
        for fi, source in enumerate(inventory['files']):
            if source['role'] == 'generated-input' or source['kind'] == 'script':
                continue
            members = list(enumerate(source['members'])) if source['kind'] == 'archive' else [(None, source)]
            for mi, member in members:
                row = {'file_index': fi, 'member_index': mi, 'bytes': member['bytes'],
                       'sha256': member['sha256'], 'regions': []}
                raw = installed_object(row)
                kind, offset, sections = header(lambda o, n: raw[o:o+n])
                selected = {i for i, s in enumerate(sections) if s[1] in (2, 11, 0x6ffffffd)}
                selected |= {sections[i][6] for i in selected}
                regions = {(0, 64), (offset, 64*len(sections))}
                regions |= {(sections[i][4], sections[i][5]) for i in selected}
                for j, (start, size) in enumerate(sorted(regions)):
                    payload = raw[start:start+size]
                    assert len(payload) == size
                    path = f'{len(rows):04d}/{j}'
                    entry = tarfile.TarInfo(path)
                    entry.size = size; entry.mode = 0o644
                    archive.addfile(entry, io.BytesIO(payload))
                    row['regions'].append({'path': path, 'offset': start, 'bytes': size,
                                           'sha256': sha(payload)})
                rows.append(row)
    packed = gzip.compress(archive_bytes.getvalue(), mtime=0)
    (root/'fixed-version-regions.tar.gz').write_bytes(packed)
    record = {'inventory_sha256': sha(inventory_path.read_bytes()),
              'archive_sha256': sha(packed), 'objects': rows}
    (root/'fixed-version-inputs.json').write_text(json.dumps(record, indent=2)+'\n')

record = json.loads((root/'fixed-version-inputs.json').read_text())
assert sha(inventory_path.read_bytes()) == record['inventory_sha256']
assert sha((root/'fixed-version-regions.tar.gz').read_bytes()) == record['archive_sha256']
expected = [(fi, mi) for fi, f in enumerate(inventory['files'])
            if f['role'] != 'generated-input' and f['kind'] != 'script'
            for mi in (range(len(f['members'])) if f['kind'] == 'archive' else [None])]
assert [(r['file_index'], r['member_index']) for r in record['objects']] == expected
all_symbols = 0
regular_count = 0
dsos = []
with tarfile.open(root/'fixed-version-regions.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(p['path'] for r in record['objects'] for p in r['regions'])
    for row in record['objects']:
        source = inventory['files'][row['file_index']]
        identity = source if row['member_index'] is None else source['members'][row['member_index']]
        assert (row['bytes'], row['sha256']) == (identity['bytes'], identity['sha256'])
        regions = []
        original = installed_object(row) if args.installed or args.capture else None
        for part in row['regions']:
            payload = archive.extractfile(part['path']).read()
            assert len(payload) == part['bytes'] and sha(payload) == part['sha256']
            if original is not None:
                assert payload == original[part['offset']:part['offset']+part['bytes']]
            regions.append((part['offset'], payload))
        def read(offset, length):
            for start, payload in regions:
                if start <= offset and offset+length <= start+len(payload):
                    return payload[offset-start:offset-start+length]
            raise AssertionError((offset, length))
        result = inspect(read)
        assert not result['regular_defined_versioned_symbols']
        all_symbols += result['symbol_records']*source['link_argv_occurrences']
        if result['kind'] == 1:
            regular_count += 1
        else:
            assert row['member_index'] is None
            dsos.append({'path': source['path'], 'versions': result['versions']})
assert all_symbols == inventory['summary']['weighted_fixed_sums']['symbol_records']
assert len(dsos) == 3
assert [len(d['versions']) for d in dsos] == [4, 46, 7]
# Existing fixed-input closure supplies at most nine processings of the loader.
loader = next(d for d in dsos if d['path'] == '/lib64/ld-linux-x86-64.so.2')
version_allowance = sum(len(d['versions']) for d in dsos) + 8*len(loader['versions']) + 4
group_allowance = len(dsos)+8
assert version_allowance == 117 and group_allowance == 11
result = {'scope': 'Fixed inputs only; generated Main/binder and configuration remain caller premises',
          'objects_checked': len(record['objects']), 'regular_objects_checked': regular_count,
          'weighted_symbol_records': all_symbols, 'regular_defined_versioned_symbols': 0,
          'shared_objects': dsos, 'imported_version_allowance_with_revisits_and_backend': version_allowance,
          'dependency_group_allowance': group_allowance,
          'version_need_bytes_upper': 16*(version_allowance+group_allowance),
          'version_index_upper_if_no_generated_version_definitions': 1+version_allowance,
          'installed_bytes_rechecked': args.installed or args.capture,
          'whole_link_capacity_established': False, 'native_execution': False}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k: v for k, v in result.items() if k != 'shared_objects'}))
