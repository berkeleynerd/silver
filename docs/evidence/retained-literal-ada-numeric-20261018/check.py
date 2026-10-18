#!/usr/bin/env python3
"""Focused new numeric-join checks; no native tool or predecessor suite runs."""
import argparse
import json
from pathlib import Path
import time
from compose import Context, HERE, REPO, backing, compose


def source(lengths, nulls=0, mixed=False):
    calls = [b'Silver_IO.' + (b'Put_Line' if mixed and i % 2 else b'Put') +
             b' ("' + b'x'*n + b'");' for i, n in enumerate(lengths)]
    return (b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin ' +
            b' '.join(calls + [b'null;']*nulls) + b' end Main;')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root', type=Path, required=True)
    parser.add_argument('--gcc-root', type=Path, required=True)
    args = parser.parse_args()
    started = time.monotonic()
    context = Context(args.ada_root, args.gcc_root)
    checks = []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checks.append(name)

    hello = compose((REPO / 'samples/hello_world.adb').read_bytes(), context)
    check('hello exact source-composed numeric demand', hello['demands'] == dict(Uints=28429, Udigits=107797, Ureals=67, Rep_Table=504))
    check('hello numeric backing', {k: v['backing_capacity_bound'] for k, v in hello['tables'].items()} == dict(Uints=56858, Udigits=215594, Ureals=400, Rep_Table=3000))
    check('hello individual objects', {k: v['bytes_with_sentinel'] for k, v in hello['tables'].items()} == dict(Uints=454872, Udigits=862380, Ureals=6416, Rep_Table=96032))
    for c in (1, 2, 7, 31):
        for n in (0, 1, 9):
            result = compose(source([0, 1, 8192, 13][:min(c, 4)] + [2]*max(0, c-4), n, True), context)
            check(f'counts C{c} N{n}', result['demands'] == dict(Uints=28420+9*c, Udigits=107726+71*c, Ureals=67, Rep_Table=504))
            check(f'checks C{c} N{n}', result['all_selected_checks_pass'])
            check(f'scope C{c} N{n}', not result['complete_native_capacity'] and not result['complete_original_gigi'])
    mixed = source([0, 8192], 2, True)
    base = compose(mixed, context)
    for label, raw in [('case', mixed.upper()), ('CRLF', mixed.replace(b';', b';\r\n')), ('comment', b'-- 1E10000 + 9\r' + mixed), ('quoted syntax', source([7]).replace(b'xxxxxxx', b'a""+9 E'))]:
        result = compose(raw, context)
        expected_c = 1 if label == 'quoted syntax' else 2
        check(label, result['demands']['Uints'] == 28420+9*expected_c and result['all_selected_checks_pass'])
    large = compose(source([1]*5000), context)
    check('5000 calls only selected numeric pass', large['all_selected_checks_pass'] and large['demands']['Uints'] == 73420 and not large['complete_native_capacity'])
    # Pure arithmetic boundary: do not allocate an eleven-million-call source
    # or claim this is the whole-pipeline admissibility boundary.
    last = (100000000-28420)//9
    for c, expected in ((last, True), (last+1, False)):
        rows = backing(dict(Uints=28420+9*c, Udigits=107726+71*c, Ureals=67, Rep_Table=504), context)
        check(f'nominal Uint boundary {c}', all(r['all_selected_checks_pass'] for r in rows.values()) == expected)
        check(f'other tables at boundary {c}', all(rows[k]['all_selected_checks_pass'] for k in ('Udigits', 'Ureals', 'Rep_Table')))
    for raw in (b'', source([1])+b' junk', source([1]).replace(b'begin', b'X : Integer := 1; begin'), source([1]).replace(b'x', b'\v')):
        try:
            compose(raw, context)
        except ValueError:
            check('out-of-family bytes rejected ' + str(len(raw)), True)
        else:
            raise AssertionError('out-of-family source accepted')
    check('numeric cache objects preserved', hello['UI_Ints']['static_bucket_array_bytes'] == 8184 and hello['UI_Ints']['individual_wrapper_bytes'] == 16 and not hello['UI_Ints']['aggregate_heap_gate'])
    result = dict(checks=len(checks), passed=checks, elapsed_seconds=time.monotonic()-started,
                  input_identity_records=len(context.identity['files']),
                  source_arithmetic_boundary_calls=last, native_tool_executions=0,
                  predecessor_suites_rerun=False, complete_native_capacity=False)
    (HERE / 'result.json').write_text(json.dumps(hello, indent=2)+'\n')
    (HERE / 'check-results.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k != 'passed'}))


if __name__ == '__main__':
    main()
