#!/usr/bin/env python3
"""Check a new typed atom projection and bounded save-outcome source excerpts.

Reads frozen capture bytes and the accepted formula/binder certificate. Does not
rerun capture, replay, binder counting, native code, disassembly, or a corpus scan.
The source argument in the companion note is not an OCaml semantic theorem.
"""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
STATE = HERE.parent / 'retained-why-session-save-state-20261019'
WHY = HERE.parent / 'retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = HERE.parent / 'retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
OCAML_PREFIX = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/'
ELF_PATH = Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/'
                'alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3')

EXCERPTS = {
    'why3/src/core/term.ml': [(17, 48), (93, 108), (222, 254), (739, 781), (799, 832)],
    'why3/src/core/ident.ml': [(114, 155), (158, 164), (209, 213), (225, 286)],
    'why3/src/core/trans.ml': [(45, 57), (75, 103), (369, 372)],
    'why3/src/util/weakhtbl.ml': [(97, 122)],
    'why3/src/util/number.ml': [(19, 47)],
    'why3/src/util/constant.ml': [(16, 20), (48, 73)],
    'why3/src/util/bigInt.ml': [(13, 18), (64, 70)],
    'why3/src/session/termcode.ml': [(192, 229), (232, 267), (342, 409), (430, 506), (548, 627)],
    'why3/src/session/session_itp.ml': [(107, 144), (163, 201), (298, 332), (2099, 2156), (2172, 2244)],
    'why3/src/gnat/gnat_main.ml': [(265, 278), (298, 309), (355, 360)],
    'ocaml/stdlib/buffer.ml': [(16, 39), (59, 69), (77, 138), (164, 180)],
    'ocaml/stdlib/format.ml': [(937, 978), (992, 1007)],
    'ocaml/stdlib/stdlib.ml': [(550, 570)],
    'ocaml/stdlib/printexc.ml': [(327, 360)],
    'ocaml/stdlib/sys.ml.in': [(28, 48)],
    'ocaml/runtime/caml/mlvalues.h': [(142, 161)],
}


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def source_excerpts():
    result = []
    with tarfile.open(WHY) as why, tarfile.open(OCAML) as ocaml:
        for name, ranges in EXCERPTS.items():
            archive, member = (why, name) if name.startswith('why3/') else (
                ocaml, OCAML_PREFIX + name[len('ocaml/'):])
            raw = archive.extractfile(member).read()
            lines = raw.decode().splitlines()
            for first, last in ranges:
                assert 1 <= first <= last <= len(lines), (name, first, last)
                result.append({'file': name, 'member': member,
                               'file_identity': identity(raw), 'first': first, 'last': last,
                               'text': '\n'.join(lines[first - 1:last])})
    return result


def runtime_limits():
    """Three new instruction windows from retained disassembly, no tool replay."""
    raw = ELF_PATH.read_bytes()
    assert identity(raw) == {'bytes': 24561432, 'sha256':
        '7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368'}
    header = struct.unpack_from('<16sHHIQQQIHHHHHH', raw)
    assert header[0][:6] == b'\x7fELF\x02\x01' and header[2] == 62
    segments = [struct.unpack_from('<IIQQQQQQ', raw, header[5] + i * header[9])
                for i in range(header[10])]
    windows = [
        {'address': 0x942959, 'hex': '48c7434081000000',
         'meaning': 'Sys.entry stores tagged word_size 129 (64) at module offset 0x40'},
        {'address': 0x94299d, 'hex': '48b8efffffffffffff0348894358',
         'meaning': 'Sys.entry stores tagged max_string_length 0x3ffffffffffffef at offset 0x58'},
        {'address': 0x9d5540, 'hex': 'f30f1efa48b8ffffffffffff7f00c3',
         'meaning': 'caml_sys_const_max_wosize returns tagged 0x7fffffffffffff'},
    ]
    for window in windows:
        address, expected = window['address'], bytes.fromhex(window['hex'])
        segment = next(s for s in segments if s[0] == 1 and
                       s[3] <= address and address + len(expected) <= s[3] + s[5])
        offset = segment[2] + address - segment[3]
        assert raw[offset:offset + len(expected)] == expected, window
    string_limit = (0x3ffffffffffffef - 1) // 2
    word_limit = (0x7fffffffffffff - 1) // 2
    assert string_limit == 8 * word_limit - 1 == 144115188075855863
    assert 1074 < string_limit
    return {'elf_identity': identity(raw), 'windows': windows,
            'checked_bytes': sum(len(bytes.fromhex(w['hex'])) for w in windows),
            'max_string_length': string_limit, 'max_wosize': word_limit,
            'origin': 'existing /tmp/silver-why-callback-closure-disassembly-20261018.txt',
            'disassembler_runs': 0, 'native_executions': 0}


class Atoms:
    """Typed traversal over all formula children and deferred-substitution values.

    Deduplication is appropriate for atom *coverage*, not occurrence/binder mass.
    The latter is imported from the separately accepted certificate.
    """
    def __init__(self, blocks):
        self.blocks = blocks
        self.identifiers, self.constants = {}, {}
        self.terms, self.patterns, self.active = set(), set(), set()
        self.term_kinds = collections.Counter()
        self.read = set()

    def row(self, pointer):
        assert not pointer & 1
        self.read.add(pointer)
        row = self.blocks[pointer]
        raw = bytes.fromhex(row['payload_hex'])
        assert len(raw) == 8 * row['words']
        assert row['header'] >> 10 == row['words']
        assert row['header'] & 255 == row['tag']
        return row, raw

    def fields(self, pointer, words=None, tag=0):
        row, raw = self.row(pointer)
        assert row['tag'] == tag, (pointer, row['tag'], tag)
        assert words is None or row['words'] == words, (pointer, row['words'], words)
        return struct.unpack('<' + 'Q' * row['words'], raw)

    def string(self, pointer):
        row, raw = self.row(pointer)
        assert row['tag'] == 252 and raw and 0 <= raw[-1] < 8
        length = len(raw) - raw[-1] - 1
        assert raw[length] == 0
        return raw[:length]

    def seq(self, pointer):
        seen, result = set(), []
        while pointer != 1:
            assert pointer not in seen, ('list cycle', pointer)
            seen.add(pointer)
            value, pointer = self.fields(pointer, 2)
            result.append(value)
        return result

    def mapping(self, pointer, active=frozenset()):
        if pointer == 1:
            return []
        assert pointer not in active, ('map cycle', pointer)
        left, key, value, right, height = self.fields(pointer, 5)
        assert height & 1
        return (self.mapping(left, active | {pointer}) + [(key, value)] +
                self.mapping(right, active | {pointer}))

    def ident(self, pointer):
        name, _, _, tag = self.fields(pointer, 4)
        assert tag & 1
        raw = self.string(name)
        self.identifiers[str(pointer)] = {'string_pointer': name, 'name_hex': raw.hex(),
                                          'length': len(raw)}

    def vs(self, pointer):
        self.ident(self.fields(pointer, 2)[0])

    def ls(self, pointer):
        self.ident(self.fields(pointer, 5)[0])

    @staticmethod
    def integer(value):
        assert value & 1, ('non-immediate integer', value)
        return (value if value < 2**63 else value - 2**64) >> 1

    def constant(self, pointer):
        if str(pointer) in self.constants:
            return
        row, _ = self.row(pointer)
        kind = row['tag']
        value, = self.fields(pointer, 1, kind)
        if kind == 0:
            literal_kind, integer = self.fields(value, 2)
            assert literal_kind in (1, 3, 5, 7, 9)
            result = {'kind': 'int', 'parts': [self.integer(integer)]}
        elif kind == 1:
            _, real = self.fields(value, 2)
            result = {'kind': 'real', 'parts': [self.integer(x) for x in self.fields(real, 3)]}
        else:
            assert kind == 2
            raw = self.string(value)
            result = {'kind': 'string', 'length': len(raw), 'hex': raw.hex()}
        self.constants[str(pointer)] = result

    def info(self, pointer):
        _, substitutions = self.fields(pointer, 2)
        for variable, value in self.mapping(substitutions):
            self.vs(variable)
            self.term(value)

    def pattern(self, pointer):
        if pointer in self.patterns:
            return
        assert ('p', pointer) not in self.active
        self.active.add(('p', pointer))
        node, variables, _ = self.fields(pointer, 3)
        for variable, _ in self.mapping(variables):
            self.vs(variable)
        if node & 1:
            assert node == 1
        else:
            row, _ = self.row(node)
            kind = row['tag']
            fields = self.fields(node, (1, 2, 2, 2)[kind], kind)
            if kind == 0:
                self.vs(fields[0])
            elif kind == 1:
                self.ls(fields[0])
                for child in self.seq(fields[1]):
                    self.pattern(child)
            elif kind == 2:
                self.pattern(fields[0])
                self.pattern(fields[1])
            else:
                assert kind == 3
                self.pattern(fields[0])
                self.vs(fields[1])
        self.active.remove(('p', pointer))
        self.patterns.add(pointer)

    def term(self, pointer):
        if pointer in self.terms:
            return
        assert ('t', pointer) not in self.active
        self.active.add(('t', pointer))
        node, _, _, _ = self.fields(pointer, 4)
        if node & 1:
            assert node in (1, 3)
            self.term_kinds['Ttrue' if node == 1 else 'Tfalse'] += 1
        else:
            row, _ = self.row(node)
            kind = row['tag']
            assert kind in range(10)
            self.term_kinds[('Tvar', 'Tconst', 'Tapp', 'Tif', 'Tlet', 'Tcase',
                             'Teps', 'Tquant', 'Tbinop', 'Tnot')[kind]] += 1
            fields = self.fields(node, (1, 1, 2, 3, 2, 2, 1, 2, 3, 1)[kind], kind)
            if kind == 0:
                self.vs(fields[0])
            elif kind == 1:
                self.constant(fields[0])
            elif kind == 2:
                self.ls(fields[0])
                for child in self.seq(fields[1]):
                    self.term(child)
            elif kind == 3:
                for child in fields:
                    self.term(child)
            elif kind in (4, 6):
                if kind == 4:
                    self.term(fields[0])
                variable, info, body = self.fields(fields[1] if kind == 4 else fields[0], 3)
                self.vs(variable)
                self.info(info)
                self.term(body)
            elif kind == 5:
                self.term(fields[0])
                for branch in self.seq(fields[1]):
                    pattern, info, body = self.fields(branch, 3)
                    self.pattern(pattern)
                    self.info(info)
                    self.term(body)
            elif kind == 7:
                assert fields[0] in (1, 3)
                variables, info, triggers, body = self.fields(fields[1], 4)
                for variable in self.seq(variables):
                    self.vs(variable)
                self.info(info)
                for trigger in self.seq(triggers):
                    for child in self.seq(trigger):
                        self.term(child)
                self.term(body)
            elif kind == 8:
                assert fields[0] in (1, 3, 5, 7)
                self.term(fields[1])
                self.term(fields[2])
            else:
                assert kind == 9
                self.term(fields[0])
        self.active.remove(('t', pointer))
        self.terms.add(pointer)


def projection():
    certificate_raw = (STATE / 'binder-certificate.json').read_bytes()
    certificate = json.loads(certificate_raw)
    capture = STATE / 'capture.tar.gz'
    with tarfile.open(capture) as archive:
        member = 'input_is_valid/capture/session-blocks.jsonl'
        raw = archive.extractfile(member).read()
    rows = [json.loads(line) for line in raw.splitlines()]
    blocks = {row['address']: row for row in rows}
    assert len(blocks) == len(rows)
    atoms = Atoms(blocks)
    roots = sorted(map(int, certificate['formulas']))
    assert roots == sorted({p['formula'] for task in certificate['tasks'].values()
                            for p in task['propositions']})
    for root in roots:
        atoms.term(root)
    assert len(roots) == 66 and len(atoms.terms) == 1545
    assert not atoms.patterns and atoms.term_kinds['Tcase'] == 0
    assert len(atoms.identifiers) == 309
    assert collections.Counter(c['kind'] for c in atoms.constants.values()) == {'int': 10}
    values = sorted({v for c in atoms.constants.values() for v in c['parts']})
    assert values == [0, 1, 32, 126, 4096]
    max_name = max(r['length'] for r in atoms.identifiers.values())
    assert max_name == 47 and certificate['B_binders'] == 966
    printer_domain = len(atoms.identifiers) + certificate['B_binders']
    visits_per_task = {
        task: sum(certificate['formulas'][str(p['formula'])]['opened_term_occurrences']
                  for p in value['propositions'])
        for task, value in certificate['tasks'].items()
    }
    printer_calls = max(visits_per_task.values())
    assert printer_calls == 1435
    suffix = len(str(printer_calls))
    alpha_bytes = len(str(certificate['B_binders']))
    constant_bytes = max(len(str(v)) for v in values)
    atom_bytes = max(max_name + suffix, alpha_bytes, constant_bytes, 1)
    extent = 1023 + atom_bytes
    assert printer_domain == 1275 and suffix == 4 and atom_bytes == 51 and extent == 1074
    visits = certificate['visits']
    assert len(visits) == 5 and all(not v['detached'] for v in visits)
    shape_requests = sum(len(certificate['tasks'][str(v['task'])]['propositions']) + 1
                         for v in visits)
    assert shape_requests == 315
    return {
        'capture_member': member, 'capture_member_identity': identity(raw),
        'binder_certificate_identity': identity(certificate_raw),
        'formula_roots': roots, 'term_pointers': sorted(atoms.terms),
        'term_constructor_counts': dict(atoms.term_kinds),
        'pattern_pointers': sorted(atoms.patterns), 'read_pointers': sorted(atoms.read),
        'identifiers': atoms.identifiers, 'constants': atoms.constants,
        'imported_opened_shape_term_visits_per_task': visits_per_task,
        'bounds': {'original_name_bytes': max_name, 'fresh_printer_domain': printer_domain,
                   'fresh_printer_assignment_calls': printer_calls,
                   'decimal_suffix_bytes': suffix, 'alpha_name_bytes': alpha_bytes,
                   'constant_output_bytes': constant_bytes, 'maximum_atom_bytes': atom_bytes,
                   'pre_append_bytes': 1023, 'shape_buffer_extent_bytes': extent,
                   'global_shape_add_requests_per_save': shape_requests},
        'premises': ['accepted same-process forest/formula coverage and source correspondence',
                     'valid typed graph, cached substitutions, noncolliding freshness',
                     'fixed library numeric/string/Format semantics',
                     'no interfering mutation of the local printers or Shape.shape_buffer'],
        'complete_R': None, 'exceptional_identifier_charge': None,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    paths = [STATE / 'capture.tar.gz', STATE / 'binder-certificate.json', WHY, OCAML,
             HERE.parent / 'retained-why-inline-callback-closure-20261018/native.tar.gz']
    inputs = {str(p.relative_to(ROOT)): identity(p.read_bytes()) for p in paths}
    outputs = {'inputs.json': inputs, 'source-excerpts.json': source_excerpts(),
               'atom-certificate.json': projection(), 'runtime-limits.json': runtime_limits()}
    for name, result in outputs.items():
        text = json.dumps(result, indent=2, sort_keys=True) + '\n'
        if args.write:
            (HERE / name).write_text(text)
        else:
            assert (HERE / name).read_text() == text, name
    bounds = outputs['atom-certificate.json']['bounds']
    print(json.dumps({'status': 'passed', 'source_excerpts': len(outputs['source-excerpts.json']),
                      'bounds': bounds, 'seconds': time.monotonic() - start,
                      'native_runs': 0, 'old_checker_replays': 0, 'complete_R': None}))


if __name__ == '__main__':
    main()
