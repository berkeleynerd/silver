#!/usr/bin/env python3
"""Compare exact installed bytes and two bounded IFUNC resolvers, without running them.

This is a conditional native service bridge, not a C memcpy overlap theorem,
an IFUNC/loader implementation proof, or an observed server GOT attachment.
"""
import argparse
import hashlib
import json
import re
import struct
import tarfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def encode(value):
    return (json.dumps(value, indent=2) + '\n').encode()


class ELF:
    def __init__(self, raw):
        self.raw = raw
        h = struct.unpack_from('<16sHHIQQQIHHHHHH', raw)
        assert h[0][:6] == b'\x7fELF\x02\x01' and h[2] == 62
        self.segments = [struct.unpack_from('<IIQQQQQQ', raw, h[5] + i * h[9])
                         for i in range(h[10])]
        sections = [struct.unpack_from('<IIQQQQIIQQ', raw, h[6] + i * h[11])
                    for i in range(h[12])]
        names = self.slice(sections[h[13]])
        self.sections = {self.string(names, s[0]): s for s in sections}
        self.sections_by_index = sections

    @staticmethod
    def string(raw, offset):
        return raw[offset:raw.index(b'\0', offset)].decode()

    def slice(self, section):
        return self.raw[section[4]:section[4] + section[5]]

    def read(self, address, size):
        s = next(s for s in self.segments if s[0] == 1 and s[3] <= address
                 and address + size <= s[3] + s[5])
        offset = s[2] + address - s[3]
        return self.raw[offset:offset + size]

    def symbols(self, section='.dynsym'):
        s = self.sections[section]
        names = self.slice(self.sections_by_index[s[6]])
        raw = self.slice(s)
        result = []
        for index in range(s[5] // s[9]):
            name, info, other, shndx, value, size = struct.unpack_from('<IBBHQQ', raw, index * s[9])
            result.append(dict(index=index, name=self.string(names, name), type=info & 15,
                               section=shndx, address=value, bytes=size))
        return result


def instructions(path, elf, start, size):
    rows = []
    cursor = start
    for line in path.read_text().splitlines():
        m = re.match(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*(.*)$', line)
        if not m:
            continue
        address, raw = int(m[1], 16), bytes.fromhex(m[2])
        assert address == cursor and raw == elf.read(address, len(raw)), line
        rows.append(dict(address=address, offset=address - start, bytes=raw.hex(), text=m[3]))
        cursor += len(raw)
    assert cursor == start + size
    return rows


def normalize(rows, base):
    result, targets, branches = [], [], []
    for row in rows:
        code = bytes.fromhex(row['bytes'])
        offset = row['offset']
        if '(%rip)' in row['text']:
            # These three 7-byte encodings are the complete RIP-relative
            # instruction family in these two exact bounded bodies.
            assert len(code) == 7 and code[:3] in [bytes.fromhex(x) for x in ['488b0d', '488d05', '488d15']]
            target = base + offset + 7 + int.from_bytes(code[3:], 'little', signed=True)
            result.append(dict(offset=offset, opcode=code[:3].hex(), rip_target=target))
            if code[1] == 0x8d:
                targets.append(target)
        else:
            result.append(dict(offset=offset, bytes=code.hex()))
        if code[0] in [0x74, 0x75, 0x78, 0x79]:
            assert len(code) == 2
            target = offset + 2 + int.from_bytes(code[1:], 'little', signed=True)
            assert target in {r['offset'] for r in rows}
            branches.append(dict(offset=offset, target_offset=target))
    return result, sorted(set(targets)), branches


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    parser.add_argument('--server', type=Path)
    parser.add_argument('--libc', type=Path)
    args = parser.parse_args()
    start = time.monotonic()
    spec = json.loads((HERE / 'inputs.json').read_bytes())
    for name, expected in spec['imports'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    binaries = {}
    for role in ['server', 'libc']:
        raw = (getattr(args, role) or Path(spec[role]['path'])).read_bytes()
        assert identity(raw) == {k: spec[role][k] for k in ['bytes', 'sha256']}
        binaries[role] = ELF(raw)
    for query in json.loads((HERE / 'queries.json').read_bytes()):
        assert identity((HERE / query['output']).read_bytes()) == query['identity']
        assert query['returncode'] == 0 and query['read_only']

    old = json.loads((ROOT / 'docs/evidence/retained-why-native-effect-completeness-20261019/inputs.json').read_bytes())
    # Locate the retained imported libc row without assuming its outer schema.
    def dictionaries(value):
        if isinstance(value, dict):
            yield value
            for v in value.values():
                yield from dictionaries(v)
        elif isinstance(value, list):
            for v in value:
                yield from dictionaries(v)
    libc_provider = next(r for r in dictionaries(old) if r.get('path') == spec['libc']['path'])
    assert libc_provider['sha256'] == spec['libc']['sha256'] and libc_provider['size'] == spec['libc']['bytes']

    cap = ROOT / 'docs/evidence/retained-why-save-state-capture-20261020'
    manifest = json.loads((cap / 'capture-manifest.json').read_bytes())
    archive = next(a for a in manifest['archives'] if a['path'] == 'capture-put-line.tar.gz')
    member = 'registration/put_line/capture/server.json'
    with tarfile.open(cap / archive['path']) as tar:
        raw = tar.extractfile(member).read()
    expected = next(r for r in archive['members'] if r['path'] == member)
    assert identity(raw) == {k: expected[k] for k in ['bytes', 'sha256']}
    server = json.loads(raw)
    assert server['binary'] == {k: spec['server'][k] for k in ['bytes', 'sha256']}
    assert server['actual_argv'][0] == spec['server']['path']
    assert server['actual_environment'] == {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C'}

    elf = binaries['server']
    sym = next(s for s in elf.symbols('.symtab') if s['name'] == 'have_taken')
    assert sym['address'] == 0x2fdb and sym['bytes'] == 82
    body = instructions(HERE / 'server-have-taken.txt', elf, sym['address'], sym['bytes'])
    call = elf.read(0x2ffe, 5)
    assert call[0] == 0xe8 and 0x3003 + int.from_bytes(call[1:], 'little', signed=True) == 0x2590
    plt = instructions(HERE / 'server-plt.txt', elf, 0x2590, 16)
    branch = elf.read(0x2594, 6)
    assert branch[:2] == bytes.fromhex('ff25')
    got = 0x259a + int.from_bytes(branch[2:], 'little', signed=True)
    assert got == 0x7f00
    rels = elf.slice(elf.sections['.rela.plt'])
    matches = [struct.unpack_from('<QQq', rels, i) for i in range(0, len(rels), 24)
               if struct.unpack_from('<Q', rels, i)[0] == got]
    assert len(matches) == 1
    _, info, addend = matches[0]
    assert info & 0xffffffff == 7 and addend == 0
    symbol = elf.symbols()[info >> 32]
    assert symbol['name'] == 'memcpy' and symbol['section'] == 0
    versym = elf.slice(elf.sections['.gnu.version'])
    version_index = struct.unpack_from('<H', versym, 2 * symbol['index'])[0] & 0x7fff
    assert version_index == 6
    assert 'memcpy@GLIBC_2.14' in (HERE / 'server-symbols.txt').read_text()
    assert 'libc.so.6' in (HERE / 'server-dynamic.txt').read_text()

    libc = binaries['libc']
    syms = libc.symbols()
    memcpy = next(s for s in syms if s['name'] == 'memcpy' and s['type'] == 10)
    memmove = next(s for s in syms if s['name'] == 'memmove' and s['type'] == 10)
    assert (memcpy['address'], memmove['address'], memcpy['bytes'], memmove['bytes']) == (0xb8c80, 0xb9600, 257, 257)
    a = instructions(HERE / 'libc-memcpy-resolver.txt', libc, memcpy['address'], memcpy['bytes'])
    b = instructions(HERE / 'libc-memmove-resolver.txt', libc, memmove['address'], memmove['bytes'])
    na, targets_a, branches_a = normalize(a, memcpy['address'])
    nb, targets_b, branches_b = normalize(b, memmove['address'])
    assert na == nb and targets_a == targets_b and branches_a == branches_b
    assert len(targets_a) == 13
    assert na[1] == dict(offset=4, opcode='488b0d', rip_target=0x211eb8)

    src = ROOT / 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
    source_rows = []
    with tarfile.open(src) as tar:
        for name, first, last in [('why3/src/server/readbuf.c', 45, 49),
                                  ('why3/src/server/server-unix.c', 582, 590)]:
            raw = tar.extractfile(name).read()
            source_rows.append(dict(member=name, identity=identity(raw), first=first, last=last,
                                    text=''.join(raw.decode().splitlines(keepends=True)[first - 1:last])))
    assert 'memcpy(b->data, b->data+size, b->len - size)' in source_rows[0]['text']

    result = dict(
        server=dict(identity=server['binary'], retained_metadata_pid=server['pid'],
                    routine='have_taken', address=sym['address'], bytes=sym['bytes'],
                    call_site=0x2ffe, plt=0x2590, got=got, symbol='memcpy@GLIBC_2.14',
                    inline_copy=False, memmove_call_conversion=False),
        libc=dict(identity={k: spec['libc'][k] for k in ['bytes', 'sha256']},
                  memcpy_resolver=memcpy['address'], memmove_resolver=memmove['address'],
                  resolver_bytes_each=257, normalized_identical=True, returned_targets=targets_a,
                  selected_runtime_target=None, historical_server_loaded_libc=None,
                  historical_server_GOT=None),
        native_bridge='same resolver feature data plus ordinary noninterposed exact-libc binding selects the trusted memmove implementation',
        generic_C_memcpy_overlap_valid=False, actual_overlap_observed=False,
        actual_corruption_observed=False, source_undefined_behavior_removed=False,
        selected_server_runtime_binding_observed=False, universal_binary_refinement=False,
        loader_implementation_proved=False, libc_copy_implementation_proved=False,
        server_stream_preservation_unconditional=False, complete_server_capacity=False,
        required_range_premises=['valid live allocation covering data[0:len]',
                                 '0 < size <= len <= capacity',
                                 'source/native ownership and representation relation'],
        executions=dict(target=0, capture=0, debugger=0, solver=0, proof_suite=0, source_fetch=0))
    outputs = {'source-witnesses.json': source_rows,
               'normalized-resolvers.json': dict(instructions=na, branches=branches_a,
                                                 returned_targets=targets_a),
               'result.json': result}
    for name, value in outputs.items():
        if args.write:
            (HERE / name).write_bytes(encode(value))
        else:
            assert json.loads((HERE / name).read_bytes()) == value, name
    print(json.dumps(dict(status='pass', seconds=time.monotonic() - start,
                          native_bytes=82 + 16 + 2 * 257, resolver_instructions=len(a),
                          returned_targets=len(targets_a), runtime_executions=0)))


if __name__ == '__main__':
    main()
