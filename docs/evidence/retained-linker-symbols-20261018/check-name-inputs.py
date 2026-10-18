"""Capture/replay fixed ELF section names."""
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
inputs = root.parent/'retained-link-inputs-20261018'
sha = lambda b: hashlib.sha256(b).hexdigest()
inventory_raw = (inputs/'inventory.json').read_bytes()
inventory = json.loads(inventory_raw)
fixed_record_raw = (root/'fixed-version-inputs.json').read_bytes()
fixed_record = json.loads(fixed_record_raw)
assert sha(inventory_raw) == fixed_record['inventory_sha256']
assert sha((root/'fixed-version-regions.tar.gz').read_bytes()) == fixed_record['archive_sha256']

originals = {}
def original(row):
    index = row['file_index']
    f = inventory['files'][index]
    if index not in originals:
        raw = Path(f['path']).read_bytes()
        assert len(raw) == f['bytes'] and sha(raw) == f['sha256']
        originals[index] = raw
    raw = originals[index]
    if row['member_index'] is not None:
        m = f['members'][row['member_index']]
        offset = m['header_offset']
        assert raw[offset+58:offset+60] == b'`\n'
        assert int(raw[offset+48:offset+58]) == m['bytes']
        raw = raw[offset+60:offset+60+m['bytes']]
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    return raw

payloads = {}
with tarfile.open(root/'fixed-version-regions.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(p['path'] for r in fixed_record['objects'] for p in r['regions'])
    for row in fixed_record['objects']:
        for part in row['regions']:
            raw = archive.extractfile(part['path']).read()
            assert len(raw) == part['bytes'] and sha(raw) == part['sha256']
            payloads[part['path']] = raw

def headers(row):
    def read(offset, size):
        for part in row['regions']:
            start = part['offset']
            if start <= offset and offset+size <= start+part['bytes']:
                return payloads[part['path']][offset-start:offset-start+size]
        raise AssertionError((offset, size))
    header = read(0, 64)
    assert header[:6] == b'\x7fELF\x02\x01'
    off = struct.unpack_from('<Q', header, 40)[0]
    step, count, names_index = struct.unpack_from('<HHH', header, 58)
    assert step == 64
    zero = struct.unpack('<IIQQQQIIQQ', read(off, 64))
    count = count or zero[5]
    names_index = names_index if names_index != 65535 else zero[6]
    result = [struct.unpack('<IIQQQQIIQQ', read(off+64*i, 64)) for i in range(count)]
    assert 0 < names_index < count and result[names_index][1] == 3
    return result, result[names_index]

if args.capture:
    rows = []
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode='w') as archive:
        for index, row in enumerate(fixed_record['objects']):
            _, names = headers(row)
            raw = original(row)[names[4]:names[4]+names[5]]
            assert len(raw) == names[5]
            path = f'{index:04d}/shstrtab'
            info = tarfile.TarInfo(path); info.size = len(raw); info.mode = 0o644
            archive.addfile(info, io.BytesIO(raw))
            rows.append(dict(file_index=row['file_index'], member_index=row['member_index'],
                             path=path, offset=names[4], bytes=len(raw), sha256=sha(raw)))
    packed = gzip.compress(buffer.getvalue(), mtime=0)
    (root/'fixed-name-regions.tar.gz').write_bytes(packed)
    record = dict(fixed_version_inputs_sha256=sha(fixed_record_raw),
                  archive_sha256=sha(packed), objects=rows)
    (root/'fixed-name-inputs.json').write_text(json.dumps(record, indent=2)+'\n')

record = json.loads((root/'fixed-name-inputs.json').read_text())
assert sha(fixed_record_raw) == record['fixed_version_inputs_sha256']
assert sha((root/'fixed-name-regions.tar.gz').read_bytes()) == record['archive_sha256']
assert len(record['objects']) == len(fixed_record['objects'])
names_seen = set()
warnings = []
section_count = 0
with tarfile.open(root/'fixed-name-regions.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(r['path'] for r in record['objects'])
    for row, fixed in zip(record['objects'], fixed_record['objects']):
        assert (row['file_index'],row['member_index']) == (fixed['file_index'],fixed['member_index'])
        sections, names_section = headers(fixed)
        raw = archive.extractfile(row['path']).read()
        assert (row['offset'], row['bytes']) == (names_section[4], names_section[5])
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        if args.capture or args.installed:
            assert raw == original(fixed)[row['offset']:row['offset']+row['bytes']]
        for section in sections:
            offset = section[0]
            assert 0 <= offset < len(raw)
            name = raw[offset:raw.index(0,offset)].decode('ascii')
            assert '@' not in name
            names_seen.add(name)
            section_count += 1
            if name.startswith('.gnu.warning.'):
                warnings.append(name)
assert section_count == 29004 and len(warnings) == 28
result = dict(scope='Fixed ELF section-name domain, including warning-name producers',
              verified_objects=len(record['objects']), section_records=section_count,
              distinct_section_names=len(names_seen), warning_sections=warnings,
              fixed_section_names_contain_literal_at=False,
              generated_objects_included=False, linker_synthetic_names_included=False,
              whole_link_capacity_established=False, native_execution=False)
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(objects=len(record['objects']), sections=section_count,
                     warnings=len(warnings), literal_at=False)))
