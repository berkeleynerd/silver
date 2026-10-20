#!/usr/bin/env python3
"""Check retained source excerpts and static pinned-ELF root/layout witnesses.
No source retrieval, target execution or debugger invocation.
"""
import hashlib
import json
from pathlib import Path
import struct
import tarfile
import missing_state

HERE = Path(__file__).resolve().parent
E = HERE.parent


def ident(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def symbols(raw):
    h = struct.unpack_from('<16sHHIQQQIHHHHHH', raw)
    assert h[0][:6] == b'\x7fELF\x02\x01'
    sections = [struct.unpack_from('<IIQQQQIIQQ', raw, h[6]+i*h[11]) for i in range(h[12])]
    out = {}
    for section in sections:
        if section[1] != 2:
            continue
        st = sections[section[6]]
        names = raw[st[4]:st[4]+st[5]]
        for i in range(0, section[5], section[9]):
            n, _, _, index, address, size = struct.unpack_from('<IBBHQQ', raw, section[4]+i)
            name = names[n:names.index(0,n)].decode()
            if name in missing_state.SYMBOLS:
                sec = sections[index]
                offset = sec[4] + address - sec[3]
                out[name] = {'elf_value': address, 'size': size, 'file_offset': offset}
    return out


def main():
    plan_path = Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/wfs-20261020/plan.json')
    plan = json.loads(plan_path.read_text())
    binary = Path(plan['inputs'][0]['argv'][0])
    raw = binary.read_bytes()
    binary_id = ident(raw)
    assert binary_id == plan['file_identities'][str(binary)]
    rows = symbols(raw)
    for name, spec in missing_state.SYMBOLS.items():
        assert rows[name]['elf_value'] == spec['elf_value']
        if 'code_hex' in spec:
            expected = bytes.fromhex(spec['code_hex'])
            offset = rows[name]['file_offset']
            assert raw[offset:offset+len(expected)] == expected
    for witness in missing_state.LAYOUT_CHECKS:
        expected = bytes.fromhex(witness['code_hex'])
        offset = rows[witness['symbol']]['file_offset'] + witness['offset']
        assert raw[offset:offset+len(expected)] == expected
    excerpts = []
    inputs = [
        ('retained-why-session-save-state-20261019/sources.tar.gz', 'why3/src/session/session_itp.ml', [(34,81),(109,143),(2021,2110),(2110,2175)]),
        ('retained-why-session-save-state-20261019/sources.tar.gz', 'why3/src/session/termcode.ml', [(234,267),(342,355),(545,559),(640,645)]),
        ('retained-why-session-save-state-20261019/sources.tar.gz', 'why3/src/core/theory.ml', [(470,494)]),
        ('retained-why-session-save-state-20261019/sources.tar.gz', 'why3/src/core/ident.ml', [(110,137)]),
        ('retained-why-session-helper-source-20261019/sources.tar.gz', 'why3/src/driver/whyconf.mli', [(153,170)]),
        ('retained-why-session-helper-source-20261019/sources.tar.gz', 'why3/src/util/extmap.ml', [(96,116)]),
        ('retained-why-session-helper-source-20261019/sources.tar.gz', 'ocaml/stdlib/buffer.ml', [(29,53)]),
        ('retained-why-session-helper-source-20261019/sources.tar.gz', 'why3/src/util/weakhtbl.ml', [(65,105)]),
        ('retained-why-inline-representative-state-20261018/sources.tar.gz', 'ocaml/stdlib/ephemeron.ml', [(135,157),(263,292),(521,584)]),
        ('retained-why-inline-representative-state-20261018/sources.tar.gz', 'ocaml/runtime/weak.c', [(30,46),(110,132)]),
    ]
    for archive, member, ranges in inputs:
        path = E/archive
        with tarfile.open(path) as t:
            content = t.extractfile(member).read()
        lines = content.decode().splitlines(keepends=True)
        for first,last in ranges:
            excerpts.append({'archive': archive, 'archive_identity': ident(path.read_bytes()),
                'member': member, 'member_identity': ident(content), 'first': first, 'last': last,
                'text': ''.join(lines[first-1:last])})
    record = {'scope': 'Retained source-family/runtime/layout premises; no new historical installed-source identity',
        'binary': str(binary), 'binary_identity': binary_id, 'accepted_plan_identity': ident(plan_path.read_bytes()),
        'symbols': rows, 'expected_symbols': missing_state.SYMBOLS,
        'layout_checks': missing_state.LAYOUT_CHECKS,
        'root_meanings': {
            'Shape_buffer': 'Termcode module +0x1c0; check_2028 loads it, then Buffer.position at+8; push_2031 confirms append argument',
            'restore_path': 'Theory.entry+2500 creates restore_path_4035 closure with captured id_to_path at field2, then stores closure to Theory module+0x100; restore_path_4035 loads field2 and delegates Wid.find',
            'weak_container': 'Ephemeron.K1 payload fields link,data,key at offsets0,8,16; accepted table-observer.py already retains the same runtime data/key prefix, while this extension follows only the required data strings',
            'shared_status_tables': 'session fields13=file_state,14=th_state,15=tn_state,16=pn_state; all finite chains/capacities retained'},
        'accepted_weak_layout_witness': ident(Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/wfs-20261020/table-observer.py').read_bytes()),
        'excerpts': excerpts}
    (HERE/'source-layout.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps({'static_symbol_checks':len(rows),'initialization_witness_checks':len(missing_state.LAYOUT_CHECKS),'source_excerpts':len(excerpts),'native_runs':0}))


if __name__=='__main__': main()
