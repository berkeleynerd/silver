"""Bound fixed-input version suffixes, including default-version aliases."""
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
sha = lambda b: hashlib.sha256(b).hexdigest()
record_path = root/'fixed-version-inputs.json'
record = json.loads(record_path.read_text())
inventory_path = root.parent/'retained-link-inputs-20261018/inventory.json'
inventory = json.loads(inventory_path.read_text())
assert sha(inventory_path.read_bytes()) == record['inventory_sha256']
assert sha((root/'fixed-version-regions.tar.gz').read_bytes()) == record['archive_sha256']
expected = [(fi, mi) for fi, f in enumerate(inventory['files'])
            if f['role'] != 'generated-input' and f['kind'] != 'script'
            for mi in (range(len(f['members'])) if f['kind'] == 'archive' else [None])]
assert [(r['file_index'], r['member_index']) for r in record['objects']] == expected

def elf_header(read):
    raw = read(0, 64)
    assert raw[:6] == b'\x7fELF\x02\x01'
    kind, machine = struct.unpack_from('<HH', raw, 16)
    assert kind in (1, 3) and machine == 62
    offset = struct.unpack_from('<Q', raw, 40)[0]
    step, count = struct.unpack_from('<HH', raw, 58)
    assert step == 64
    count = count or struct.unpack_from('<Q', read(offset, 64), 32)[0]
    return kind, [struct.unpack('<IIQQQQIIQQ', read(offset+64*i, 64))
                  for i in range(count)]

def string_at(raw, offset):
    assert 0 <= offset < len(raw)
    return raw[offset:raw.index(0, offset)].decode('ascii')

def read_regions(parts):
    def read(offset, length):
        assert offset >= 0 and length >= 0
        for start, raw in parts:
            if start <= offset and offset+length <= start+len(raw):
                return raw[offset-start:offset-start+length]
        raise AssertionError((offset, length))
    return read

fixed = []
with tarfile.open(root/'fixed-version-regions.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(p['path'] for r in record['objects']
                                               for p in r['regions'])
    for row in record['objects']:
        item = inventory['files'][row['file_index']]
        if row['member_index'] is not None:
            item = item['members'][row['member_index']]
        assert (row['bytes'], row['sha256']) == (item['bytes'], item['sha256'])
        parts = []
        for part in row['regions']:
            raw = archive.extractfile(part['path']).read()
            assert len(raw) == part['bytes'] and sha(raw) == part['sha256']
            parts.append((part['offset'], raw))
        fixed.append((row, read_regions(parts)))

def installed_dso(row):
    assert row['member_index'] is None
    source = inventory['files'][row['file_index']]
    assert source['role'] != 'generated-input' and source['kind'] != 'script'
    raw = Path(source['path']).read_bytes()
    assert len(raw) == row['bytes'] == source['bytes']
    assert sha(raw) == row['sha256'] == source['sha256']
    return raw

if args.capture:
    rows = []
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode='w') as archive:
        for row, read in fixed:
            kind, sections = elf_header(read)
            if kind != 3:
                continue
            original = installed_dso(row)
            for index, section in enumerate(sections):
                if section[1] != 0x6ffffffe:
                    continue
                offset, size = section[4:6]
                payload = original[offset:offset+size]
                assert len(payload) == size
                path = f"{row['file_index']}/{index}"
                item = tarfile.TarInfo(path)
                item.mode = 0o644; item.size = size
                archive.addfile(item, io.BytesIO(payload))
                rows.append(dict(path=path, file_index=row['file_index'],
                                 section_index=index, offset=offset, bytes=size,
                                 sha256=sha(payload)))
    packed = gzip.compress(buffer.getvalue(), mtime=0)
    (root/'fixed-version-need-regions.tar.gz').write_bytes(packed)
    supplement = dict(fixed_input_record_sha256=sha(record_path.read_bytes()),
                      archive_sha256=sha(packed), regions=rows)
    (root/'fixed-version-need-inputs.json').write_text(json.dumps(supplement, indent=2)+'\n')

supplement = json.loads((root/'fixed-version-need-inputs.json').read_text())
assert supplement['fixed_input_record_sha256'] == sha(record_path.read_bytes())
assert supplement['archive_sha256'] == sha((root/'fixed-version-need-regions.tar.gz').read_bytes())
needs = {}
with tarfile.open(root/'fixed-version-need-regions.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(r['path'] for r in supplement['regions'])
    for row in supplement['regions']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        key = (row['file_index'], row['section_index'])
        assert key not in needs
        needs[key] = (row, raw)

version_names = set()
direct_names = set()
dsos = []
consumed = set()
symbol_records = 0
for row, read in fixed:
    kind, sections = elf_header(read)
    original = installed_dso(row) if kind == 3 and (args.installed or args.capture) else None
    definitions = []
    dependencies = []
    for index, section in enumerate(sections):
        if section[1] not in (2, 11, 0x6ffffffd, 0x6ffffffe):
            continue
        names_section = sections[section[6]]
        assert names_section[1] == 3
        strings = read(names_section[4], names_section[5])
        if section[1] == 0x6ffffffe:
            key = (row['file_index'], index)
            meta, raw = needs[key]
            consumed.add(key)
            assert (meta['offset'], meta['bytes']) == section[4:6]
            if original is not None:
                assert raw == original[section[4]:section[4]+section[5]]
        else:
            raw = read(section[4], section[5])
        if section[1] in (2, 11):
            assert section[9] == 24 and len(raw) % 24 == 0
            symbol_records += len(raw)//24
            for p in range(0, len(raw), 24):
                name = string_at(strings, struct.unpack_from('<I', raw, p)[0])
                if '@' in name:
                    direct_names.add(name)
            continue
        assert kind == 3
        p = 0
        occupied = set()
        def claim(start, size):
            assert 0 <= start and start+size <= len(raw)
            cells = set(range(start, start+size))
            assert not occupied.intersection(cells)
            occupied.update(cells)
        for j in range(section[7]):
            if section[1] == 0x6ffffffd:
                claim(p, 20)
                version, flags, number, count, _, aux, nxt = struct.unpack_from('<HHHHIII', raw, p)
                assert version == 1 and count > 0 and 0 < number < 32768
                q = p+aux
                names = []
                for i in range(count):
                    claim(q, 8)
                    ni, following = struct.unpack_from('<II', raw, q)
                    names.append(string_at(strings, ni))
                    assert (following == 0) == (i == count-1)
                    q += following
                definitions.append(names[0])
            else:
                claim(p, 16)
                version, count, file_name, aux, nxt = struct.unpack_from('<HHIII', raw, p)
                assert version == 1 and count > 0
                q = p+aux
                names = []
                for i in range(count):
                    claim(q, 16)
                    _, flags, number, ni, following = struct.unpack_from('<IHHII', raw, q)
                    assert 0 < number < 32768
                    names.append(string_at(strings, ni))
                    assert (following == 0) == (i == count-1)
                    q += following
                dependencies.append(dict(library=string_at(strings, file_name), names=names))
            assert (nxt == 0) == (j == section[7]-1)
            p += nxt
    if kind == 3:
        version_names.update(definitions)
        version_names.update(n for d in dependencies for n in d['names'])
        dsos.append(dict(file_index=row['file_index'], definitions=definitions,
                         dependencies=dependencies))
assert consumed == needs.keys()
assert len(dsos) == 3 and not direct_names
assert all(n and '@' not in n for n in version_names)

# Source identity and the two alias projections are checked from the existing
# full-source bundle. These anchors support, but do not replace, the manual
# caller/lifetime argument in the linked research record.
sources = json.loads((root/'sources.json').read_text())
assert sha((root/'sources.tar.gz').read_bytes()) == sources['archive_sha256']
with tarfile.open(root/'sources.tar.gz') as archive:
    row = next(r for r in sources['files'] if r['path'] == 'bfd/elflink.c')
    raw = archive.extractfile(row['path']).read()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    source = raw.decode()
for text in ['if (strcmp (t->name, version_p) == 0)',
             'memcpy (shortname + shortlen, p + 1, len - shortlen);',
             'elf_tdata (abfd)->verdef[vernum - 1].vd_nodename;',
             'verstr = a->vna_nodename;', 't->name = p;']:
    assert text in source, text

fixed_count = len(version_names)
result = dict(scope='Fixed-input version-name domain under standard ELF alias normalization',
              objects_checked=len(fixed), unweighted_symbol_records=symbol_records,
              raw_symbol_names_containing_at=len(direct_names),
              shared_objects=dsos, version_names=sorted(version_names),
              fixed_distinct_version_suffixes_upper=fixed_count,
              output_definition_bound=f'{fixed_count}+W; W counts additional generated/synthetic suffixes',
              version_index_bound=f'{fixed_count+118}+W',
              max_additional_suffixes_from_version_index=32767-fixed_count-118,
              version_definition_bytes_if_W_zero=28*(fixed_count+1),
              version_need_bytes_upper=2048,
              installed_bytes_rechecked=args.installed or args.capture,
              generated_synthetic_name_join_complete=False,
              whole_link_capacity_established=False, native_execution=False)
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k not in ('shared_objects','version_names')}))
