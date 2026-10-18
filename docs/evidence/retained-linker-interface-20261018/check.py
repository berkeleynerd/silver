"""Offline ELF interface reconciliation; executes no native tool."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import struct
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--prior-repo', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
prior = args.prior_repo.resolve()
sha = lambda b: hashlib.sha256(b).hexdigest()
manifest = json.loads((root/'sources.json').read_bytes())
assert sha((root/'sources.tar.gz').read_bytes()) == manifest['archive_sha256']
with tarfile.open(root/'sources.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(r['path'] for r in manifest['files'])
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
for row in json.loads((root/'inputs.json').read_bytes()):
    raw = (prior/row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']


def elf(raw):
    assert raw[:6] == b'\x7fELF\x02\x01'
    assert struct.unpack_from('<H', raw, 18)[0] == 62
    shoff = struct.unpack_from('<Q', raw, 40)[0]
    stride, count, strings = struct.unpack_from('<HHH', raw, 58)
    assert stride == 64
    zero = struct.unpack_from('<IIQQQQIIQQ', raw, shoff)
    count = count or zero[5]
    strings = zero[6] if strings == 65535 else strings
    assert shoff + count*64 <= len(raw)
    headers = [struct.unpack_from('<IIQQQQIIQQ', raw, shoff+64*i)
               for i in range(count)]

    def payload(h):
        if h[1] == 8:
            return b''
        assert h[4]+h[5] <= len(raw)
        return raw[h[4]:h[4]+h[5]]

    def cstring(b, offset):
        assert 0 <= offset < len(b)
        return b[offset:b.index(0, offset)].decode()

    names_raw = payload(headers[strings])
    names = [cstring(names_raw, h[0]) for h in headers]
    symbols = []
    for h in headers:
        if h[1] not in (2, 11):
            continue
        assert h[9] == 24 and h[5] % 24 == 0
        strs = payload(headers[h[6]])
        local_end = h[7]
        for index, offset in enumerate(range(h[4], h[4]+h[5], 24)):
            name, info, other, sec, value, size = struct.unpack_from('<IBBHQQ', raw, offset)
            bind, typ = info >> 4, info & 15
            assert (index < local_end) == (bind == 0)
            symbols.append(dict(name=cstring(strs, name), bind=bind, type=typ,
                                other=other, section=names[sec] if sec < count else sec,
                                value=value, size=size))
    return dict(header=raw[:40], sections={name: dict(type=h[1], flags=h[2], size=h[5],
                link=h[6], info=h[7], alignment=h[8], entsize=h[9], payload=payload(h))
                for name, h in zip(names, headers)}, symbols=symbols)


capture = json.loads((prior/'docs/evidence/retained-link-no-lto-20261018/capture/result.json').read_bytes())
historical = []
for row, name in zip(capture['objects'], ['historical-main.elf', 'historical-binder.elf']):
    raw = (root/name).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    historical.append(elf(raw))
assert next(c for c in capture['commands'] if c['name'] == 'link')['returncode'] == 0
main, old_binder = historical
accepted_raw = (prior/'docs/evidence/retained-linker-join-20261018/binder-object.elf').read_bytes()
accepted_binder = elf(accepted_raw)
assert sha(accepted_raw) == '368b82296a24b933d1154f07b54bdad7af2f291302d4db23196f9d89128e2883'
main_externals = [s for s in main['symbols'] if s['bind']]
assert main_externals == [dict(name='_ada_main', bind=1, type=2, other=0,
                              section='.text', value=0, size=8)]
assert set(old_binder['sections']) == set(accepted_binder['sections'])
unchanged_payloads, changed_payloads = [], []
for name, a in old_binder['sections'].items():
    b = accepted_binder['sections'][name]
    assert {k:v for k,v in a.items() if k not in ('payload', 'size')} == {
        k:v for k,v in b.items() if k not in ('payload', 'size')}
    if a['payload'] == b['payload']:
        assert a['size'] == b['size']
        unchanged_payloads.append(name)
    else:
        changed_payloads.append(name)
assert changed_payloads == ['.symtab', '.strtab']
assert old_binder['header'] == accepted_binder['header']
assert len(old_binder['symbols']) == len(accepted_binder['symbols']) == 179
changed_symbols = []
for index, (a,b) in enumerate(zip(old_binder['symbols'], accepted_binder['symbols'])):
    if a != b:
        changed_symbols.append(dict(index=index, historical=a, accepted=b))
assert len(changed_symbols) == 1
change = changed_symbols[0]
assert change['historical']['name'] == 'b__main.adb'
assert change['accepted']['name'] == 'b__main~1.adb'
assert change['historical']['bind'] == change['accepted']['bind'] == 0
assert change['historical']['type'] == change['accepted']['type'] == 4
assert {k:v for k,v in change['historical'].items() if k != 'name'} == {
    k:v for k,v in change['accepted'].items() if k != 'name'}
old_externals = [s for s in old_binder['symbols'] if s['bind']]
assert old_externals == [s for s in accepted_binder['symbols'] if s['bind']]
assert len(old_externals) == 169

# Read all retained fixed bytes, including unselected archive members. A
# competing Main definition/type/size cannot be hidden outside the witness.
inventory = json.loads((prior/'docs/evidence/retained-link-inputs-20261018/inventory.json').read_bytes())
counts = Counter()
fixed_main = []
for f in inventory['files']:
    if f['role'] == 'generated-input':
        continue
    raw = Path(f['path']).read_bytes()
    assert len(raw) == f['bytes'] and sha(raw) == f['sha256']
    counts['fixed_files'] += 1
    if f['kind'] == 'script':
        continue
    for m in f.get('members', [f]):
        if f['kind'] == 'archive':
            start = m['header_offset']+60
            data = raw[start:start+m['bytes']]
            assert len(data) == m['bytes'] and sha(data) == m['sha256']
            label = f['path']+':'+m['name']
            counts['archive_members'] += 1
        else:
            data, label = raw, f['path']
        obj = elf(data)
        counts['fixed_ELF_inputs'] += 1
        for sym in obj['symbols']:
            if sym['name'].split('@', 1)[0] == '_ada_main' and sym['bind']:
                fixed_main.append(dict(input=label, **sym))
assert not fixed_main
binder_main = [s for s in old_externals if s['name'] == '_ada_main']
assert binder_main == [dict(name='_ada_main', bind=1, type=0, other=0,
                           section='', value=0, size=0)]
result = dict(scope='Main external-interface and retained fixed-link read projection; not whole linker capacity',
              source_files_verified=len(manifest['files']),
              historical_successful_link_retained=True,
              historical_main_external_symbols=main_externals,
              binder_symbols=179, binder_external_symbols=169,
              binder_unchanged_section_payloads=unchanged_payloads,
              binder_changed_section_payloads=changed_payloads,
              binder_semantic_symbol_changes=changed_symbols,
              binder_main_reference=binder_main,
              counts=dict(counts), fixed_input_Main_external_records=fixed_main,
              source_argument_required=True, exact_variable_Main_bytes_claimed=False,
              complete_link_capacity_established=False, native_tool_executions=0)
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(counts=dict(counts), binder_external_symbols=169,
                     binder_semantic_symbol_changes=len(changed_symbols))))
