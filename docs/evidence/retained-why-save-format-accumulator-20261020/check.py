#!/usr/bin/env python3
"""Reconcile new, bounded accumulator evidence; never run predecessor checks."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

from transfer import bounds, PREMISES, MAX_TEMPLATE_NODES, MAIN_CHAIN_LIMIT

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
CORE = 'docs/evidence/retained-why-save-formatter-core-20261020/'
JOIN = 'docs/evidence/retained-why-save-round32-20261020/result.json'
INPUTS = [OCAML, WHY, CORE+'result.json', CORE+'native-witnesses.json', JOIN,
    'docs/research/retained-why-save-formatter-core.md',
    'docs/research/retained-why-save-operational-bounds.md',
    'docs/research/retained-why-save-scalar-format.md',
    'docs/research/retained-why-save-formatter-ownership.md',
    'docs/research/retained-why-save-path-input-join.md']
OSPECS = [
    ('stdlib/camlinternalFormat.ml', 119, 140),
    ('stdlib/camlinternalFormat.ml', 1510, 1605),
    ('stdlib/camlinternalFormat.ml', 1665, 1773),
    ('stdlib/camlinternalFormat.ml', 1967, 2005),
    ('stdlib/camlinternalFormat.ml', 2585, 2668),
    ('stdlib/camlinternalFormat.ml', 2837, 2848),
    ('stdlib/camlinternalFormatBasics.ml', 243, 265),
    ('stdlib/camlinternalFormatBasics.ml', 366, 488),
    ('stdlib/format.ml', 1249, 1398),
    ('runtime/ints.c', 33, 115), ('runtime/ints.c', 137, 140),
]
WSPECS = [('src/session/session_itp.ml', 1935, 1952),
    ('src/session/session_itp.ml', 2019, 2209),
    ('src/session/termcode.ml', 249, 269),
    ('src/util/pp.ml', 29, 40), ('src/util/pp.ml', 93, 121),
    ('src/util/pp.ml', 216, 228)]
NAMES = [
    'camlCamlinternalFormat__make_printf_3510',
    'camlCamlinternalFormat__make_padding_3514',
    'camlCamlinternalFormat__make_int_padding_precision_3515',
    'camlCamlinternalFormat__make_float_padding_precision_3516',
    'camlCamlinternalFormat__fun_6270', 'camlCamlinternalFormat__fun_6280',
    'camlCamlinternalFormat__k$27_3654',
    'camlCamlinternalFormat__fun_6520', 'camlCamlinternalFormat__fun_6559',
    'camlCamlinternalFormat__fun_6659',
    'camlStdlib__Format__fprintf_1781', 'camlStdlib__Format__fun_2984',
    'camlStdlib__Format__kfprintf_1763', 'camlStdlib__Format__fun_2958',
    'camlStdlib__Format__kasprintf_1813', 'camlStdlib__Format__k_1819',
    'camlStdlib__Format__asprintf_1822',
    'camlStdlib__Format__output_acc_1688',
    'camlStdlib__Format__compute_tag_1645',
    'camlCamlinternalFormat__open_box_of_string_4522',
    'camlCamlinternalFormat__parse_spaces_4529',
    'camlCamlinternalFormat__parse_lword_4530',
    'camlCamlinternalFormat__parse_int_4531',
    'parse_intnat', 'parse_sign_and_base', 'caml_int_of_string',
    'caml_curry2', 'caml_curry2_1',
    'camlWhy3__Pp__print_list_pre_608', 'camlWhy3__Pp__print_list_622',
    'camlWhy3__Pp__html_string_1054',
]
INSN = re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read(path):
    return json.loads((ROOT/path).read_text())


def templates(sources):
    rows = []
    for member, a, b in [('why3/src/session/session_itp.ml', 2019, 2209),
                         ('why3/src/session/termcode.ml', 265, 269),
                         ('why3/src/util/pp.ml', 101, 101)]:
        # These exact bounded slices contain no commented-out format call.
        text = ''.join(sources[member].decode().splitlines(keepends=True)[a-1:b])
        pattern = r'(?:fprintf\s+fmt|Format\.asprintf)\s*("(?:\\[\s\S]|[^"\\])*")'
        for m in re.finditer(pattern, text):
            raw = m.group(1)[1:-1]
            value = re.sub(r'\\\n[ \t]*', '', raw)
            value = value.replace('\\"', '"').replace('\\n', '\n')
            assert '\\' not in value
            nodes, i = [], 0
            while i < len(value):
                if value.startswith('@[', i):
                    j = value.index('>', i) + 1
                    annotation = value[i+2:j]
                    assert annotation in ('<h>', '<v 0>', '<v 1>', '<hov 1>')
                    nodes.append({'kind': 'open_box', 'annotation': annotation})
                    i = j
                elif value[i] == '@':
                    token = value[i:i+2]
                    assert token in ('@ ', '@\n', '@]', '@.')
                    nodes.append({'kind': 'formatting_lit', 'text': token})
                    i += 2
                elif value[i] == '%':
                    token = value[i:i+2]
                    assert token in ('%s', '%i', '%d', '%g', '%b', '%a')
                    nodes.append({'kind': 'conversion', 'text': token})
                    i += 2
                else:
                    j = i+1
                    while j < len(value) and value[j] not in '@%':
                        j += 1
                    nodes.append({'kind': 'literal', 'text': value[i:j]})
                    i = j
            boxes = sum(n['kind'] == 'open_box' for n in nodes)
            rows.append({'member': member, 'line': a+text[:m.start()].count('\n'),
                'text': value, 'text_bytes': len(value.encode()), 'nodes': nodes,
                'main_acc_nodes': len(nodes), 'annotation_acc_nodes': boxes,
                'all_acc_nodes': len(nodes)+boxes,
                'alpha_nodes': sum(n.get('text') == '%a' for n in nodes)})
    assert len(rows) == 29
    assert max(r['all_acc_nodes'] for r in rows) == MAX_TEMPLATE_NODES
    assert max(r['main_acc_nodes'] for r in rows) == 26 < MAIN_CHAIN_LIMIT
    assert max(r['alpha_nodes'] for r in rows) == 4
    return rows


def check_native():
    meta = json.loads((HERE/'native-witnesses.json').read_text())
    binary = Path(meta['executable']['path']).read_bytes()
    assert identity(binary) == meta['executable']['identity']
    assert binary[:6] == b'\x7fELF\x02\x01'
    phoff = struct.unpack_from('<Q', binary, 32)[0]
    size, count = struct.unpack_from('<HH', binary, 54)
    loads = []
    for i in range(count):
        kind, flags, off, address, _, filesz, _, _ = struct.unpack_from('<IIQQQQQQ', binary, phoff+i*size)
        if kind == 1 and flags & 1:
            loads.append((address, address+filesz, off))
    bodies = json.loads((HERE/'native-bodies.json').read_text())
    assert set(bodies) == set(NAMES)
    checked = 0
    for name, body in bodies.items():
        assert re.match(r'[0-9a-f]+ <'+re.escape(name)+r'>:', body)
        for line in body.splitlines():
            m = INSN.match(line)
            if not m:
                continue
            address, raw = int(m[1], 16), bytes.fromhex(m[2])
            for lo, hi, off in loads:
                if lo <= address and address+len(raw) <= hi:
                    assert binary[off+address-lo:off+address-lo+len(raw)] == raw
                    break
            else:
                raise AssertionError(name)
            checked += len(raw)
    assert checked == meta['instruction_bytes']
    for template in json.loads((HERE/'template-census.json').read_text()):
        # Corroborates the fixed literal data, not an AST refinement theorem.
        assert template['text'].encode() + b'\0' in binary
    return len(bodies), checked


def compute():
    sources = {}
    witnesses = []
    for archive, specs in [(OCAML, OSPECS), (WHY, WSPECS)]:
        with tarfile.open(ROOT/archive) as t:
            members = {m.name: m for m in t.getmembers() if m.isfile()}
            for suffix, a, b in specs:
                member = next(n for n in members if n.endswith('/'+suffix))
                raw = t.extractfile(member).read()
                sources[member] = raw
                lines = raw.decode().splitlines(keepends=True)
                assert 1 <= a <= b <= len(lines)
                witnesses.append({'archive': archive, 'member': member,
                    'member_identity': identity(raw), 'first': a, 'last': b,
                    'text': ''.join(lines[a-1:b])})
    census = templates(sources)
    core = read(CORE+'result.json')['cases']
    join = read(JOIN)['under_named_existing_external_premises']['cases']
    assert len(core) == len(join) == 5
    rows = []
    for old, current in zip(core, join):
        assert old['pid'] == current['pid']
        parts = old['Q_parts']
        assert 1+sum(parts.values()) == current['Q']
        rows.append({'case': current['case'], 'pid': current['pid'],
            'occurrences': parts, 'joined_U': current['actual_U_under_supplied_external_premises'],
            'without_external_assertion': bounds(parts),
            'under_named_existing_external_premises': bounds(parts, premises={p: True for p in PREMISES})})
    return {'inputs.json': {p: identity((ROOT/p).read_bytes()) for p in INPUTS},
        'source-witnesses.json': witnesses, 'template-census.json': census,
        'result.json': {'scope': 'Selected Session_itp.save typed-format accumulators, including shape asprintf roots and box annotations',
            'template_call_sites': len(census), 'max_main_acc_nodes': 26,
            'max_all_acc_nodes': MAX_TEMPLATE_NODES,
            'static_template_AST_construction_is_before_selected_interval': True,
            'max_synchronously_nested_formatted_calls_per_save': 2,
            'selected_accumulator_construction_evaluation_argument_complete_under_named_relation': True,
            'actual_native_whole_stack_bound': None,
            'actual_whole_formatter_allocation_bound': None,
            'complete_save_capacity_established': False,
            'whole_pipeline_capacity_established': False, 'cases': rows}}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    parser.add_argument('--freeze-native', action='store_true')
    args = parser.parse_args()
    if args.freeze_native:
        meta = read(CORE+'native-witnesses.json')
        raw = Path(meta['existing_disassembly']['path']).read_bytes()
        expected = meta['existing_disassembly']
        assert identity(raw) == {k: expected[k] for k in ('bytes', 'sha256')}
        pattern = r'(?m)^([0-9a-f]+ <([^>]+)>:\n.*?)(?=\n[0-9a-f]+ <|\Z)'
        all_bodies = {name: body for body, name in re.findall(pattern, raw.decode(), re.S)}
        selected = {n: all_bodies[n] for n in NAMES}
        count = sum(len(bytes.fromhex(m[2])) for b in selected.values()
                    for line in b.splitlines() if (m := INSN.match(line)))
        (HERE/'native-bodies.json').write_text(json.dumps(selected, indent=2)+'\n')
        (HERE/'native-witnesses.json').write_text(json.dumps({
            'executable': meta['executable'], 'existing_disassembly': expected,
            'instruction_bytes': count, 'source_native_refinement_proved': False}, indent=2)+'\n')
    computed = compute()
    for name, value in computed.items():
        p = HERE/name
        if args.write:
            p.write_text(json.dumps(value, indent=2)+'\n')
        else:
            assert json.loads(p.read_text()) == value, name
    native_count, native_bytes = check_native()
    complete = {p: True for p in PREMISES}
    parts = computed['result.json']['cases'][0]['occurrences']
    for p in PREMISES:
        missing = dict(complete); del missing[p]
        assert bounds(parts, premises=missing)['accumulator_bounds_under_supplied_named_relation'] is None
        assert bounds(parts, premises={**complete, p: False})['accumulator_bounds_under_supplied_named_relation'] is None
    for bad in (-1, True, 1.5):
        try:
            bounds({**parts, 'G': bad})
        except ValueError:
            pass
        else:
            raise AssertionError('bad occurrence accepted')
    for bad in (0, 4, True):
        try:
            bounds(parts, saves=bad)
        except ValueError:
            pass
        else:
            raise AssertionError('unsupported save budget accepted')
    one, three = bounds(parts, 1, complete)['candidate'], bounds(parts, 3, complete)['candidate']
    assert three['acc_nodes_interval_upper'] == 3*one['acc_nodes_interval_upper']
    assert one['formatted_calls_per_save_upper'] == three['formatted_calls_per_save_upper']
    print(json.dumps({'status': 'pass', 'generated_json_comparisons': len(computed),
        'template_call_sites': 29, 'source_witnesses': len(computed['source-witnesses.json']),
        'native_bodies': native_count, 'native_instruction_bytes': native_bytes,
        'static_template_byte_occurrences_checked': 29,
        'native_runs': 0, 'disassembler_runs': 0, 'predecessor_replays': 0}))


if __name__ == '__main__':
    main()
