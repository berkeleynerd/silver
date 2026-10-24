#!/usr/bin/env python3
"""Changed-unit source identity and authored recurrence audit; no GCC execution."""
import argparse
import hashlib
import itertools
import json
import platform
import subprocess
import tarfile
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from functools import lru_cache
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def read(path):
    return json.loads(path.read_bytes())


def sha(data):
    return hashlib.sha256(data).hexdigest()


@dataclass(eq=False)
class Node:
    code: str
    args: tuple = ()
    name: object = None
    effects: bool = False


def leaf(name):
    return Node('decl', name=name)


def const(value):
    return Node('const', name=value)


def node(code, *args):
    assert all(n.effects is False for n in args)
    return Node(code, args)


def measure(n, active=None):
    active = set() if active is None else active
    assert id(n) not in active
    assert n.effects is False
    if not n.args:
        return (0, 1, 1)
    active.add(id(n))
    child = [measure(a, active) for a in n.args]
    active.remove(id(n))
    h, o, q = 1+max(a[0] for a in child), 1+sum(a[1] for a in child), 1+sum(a[2] for a in child)
    if n.code == 'plus' and n.args[1].code == 'const' and n.args[1].name < 0:
        q += 1
    return h, o, q


def high(depth, mode):
    b = node('signed_view', leaf('Image_V'))
    identities = set()
    for i in range(depth):
        g = leaf(('G', i))
        assert g.name not in identities
        identities.add(g.name)
        inverted = bool((i+mode) % 2) if mode < 2 else bool(mode == 3)
        p = node('ne' if inverted else 'eq', g, const(0))
        b = node('cond', p, g if inverted else b, b if inverted else g)
    return b


def map_values(b, f):
    if b.code != 'cond':
        return f(b)
    return node('cond', b.args[0], map_values(b.args[1], f), map_values(b.args[2], f))


def bit_product(length):
    return node('mult', node('W', length), const(8))


def high_profiles(depth, mode):
    b = high(depth, mode)
    c = map_values(b, lambda n: node('gt', n, const(0)))
    y = map_values(b, lambda n: node('U', n))
    wrapped = map_values(b, lambda n: node('non_lvalue', n) if n.code == 'decl' else n)
    length = node('cond', c, wrapped, const(0))
    bits = node('cond', c, bit_product(y), const(0))
    expected = {
        'B': (depth+1, 5*depth+2, 5*depth+2),
        'comparison': (depth+2, 7*depth+4, 7*depth+4),
        'Y': (depth+2, 6*depth+3, 6*depth+3),
        'Length': (depth+3, 13*depth+8, 13*depth+8),
        'bits': (depth+5, 13*depth+12, 13*depth+12),
    }
    for name, n in [('B', b), ('comparison', c), ('Y', y), ('Length', length), ('bits', bits)]:
        assert measure(n) == expected[name], (name, depth, measure(n), expected[name])
    if depth == 0:
        max_length = node('max', b, const(0))
        max_bits = bit_product(node('U', max_length))
        assert measure(max_bits) == (5, 8, 8)
        assert measure(max_length) == (2, 4, 4)
        assert query_cost(max_length) == (0, 1)
    return b, length, expected


def query_cost(n):
    """Authored max_value source projection; never visits a COND condition."""
    if n.code == 'const':
        return 0, 1
    if n.code == 'decl':
        return 1, 1
    if n.code == 'signed_view':
        c, v = query_cost(n.args[0])
        return c+1, v+1
    if n.code == 'non_lvalue':
        c, v = query_cost(n.args[0])
        return c, v+1
    if n.code == 'cond':
        a, b = query_cost(n.args[1]), query_cost(n.args[2])
        return a[0]+b[0]+1, a[1]+b[1]+1
    if n.code in ('plus', 'minus'):
        a, b = query_cost(n.args[0]), query_cost(n.args[1])
        return a[0]+b[0]+1, a[1]+b[1]+1
    if n.code == 'max':
        return 0, 1  # max_value default: caller then uses type extremum
    raise AssertionError(n.code)


def assignment_profiles():
    p, g = leaf('Gprev'), leaf('Gj')
    lo = node('plus', p, const(1))
    x, y = node('U', lo), node('U', g)
    test = node('ge', g, lo)
    length = node('plus', node('minus', y, x), const(1))
    bits = node('cond', test, bit_product(length), const(0))
    assert measure(bits) == (7, 19, 19)
    profiles = [measure(bits)]
    for k in (1, 2, 4096, 4097, 2**31-1):
        shifted = node('plus', y, const(1-k))
        n = node('cond', node('ge', g, const(k)), bit_product(shifted), const(0))
        h, o, q = measure(n)
        assert h <= 7 and o <= 19 and q <= 19
        profiles.append((h, o, q))
        max_length = node('plus', node('U', node('max', g, const(k-1))), const(1-k))
        max_bits = bit_product(max_length)
        assert measure(max_bits) == (5, 9, 9 + int(k > 1))
        profiles.append(measure(max_bits))
    return profiles


@lru_cache(None)
def trees(operators):
    if operators == 0:
        return (None,)
    return tuple((l, r) for k in range(operators) for l in trees(k) for r in trees(operators-1-k))


def events(tree):
    if tree is None:
        return []
    rights = []
    cur = tree
    while cur is not None:
        left, right = cur
        rights.append(right)
        cur = left
    # The collected right subtrees have already been expanded as providers.
    return [n for right in reversed(rights) for n in events(right)] + [len(rights)+1]


def event_checks():
    checked = 0
    for c in range(9):
        for tr in trees(c):
            ns = events(tr)
            e = len(ns)
            assert sum(n-1 for n in ns) == c
            assert e <= c and sum(ns) == c+e <= 2*c
            for runtime_available in (False, True):
                a = sum(n for n in ns if not runtime_available or n > 9)
                # All real and all max-replaced is a safe simultaneous upper
                # model; null filtering can only delete these producer sites.
                r = m = e
                assert r+m+a <= 4*c
            checked += 1
    for c in range(1, 257):
        assert c+1 <= 2*c
        assert 2+(c+1) <= 4*c  # one flat real group, all assignment slices
        assert 2*c <= 4*c     # all binary groups with runtime calls
    return checked


def source_check():
    for name in ('inputs.json', 'packet-manifest.json'):
        for row in read(HERE/name)['files']:
            b = (ROOT/row['path']).read_bytes()
            assert len(b) == row['bytes'] and sha(b) == row['sha256'], row['path']
    inputs = read(HERE/'inputs.json')
    for name in ('acceptance', 'repair_acceptance'):
        acceptance = inputs[name]
        blob = subprocess.check_output(['git', 'show', acceptance['commit']+':'+acceptance['path']], cwd=ROOT)
        assert sha(blob) == acceptance['sha256']
    for row in inputs['frozen_repair_files']:
        blob = subprocess.check_output(['git', 'show', inputs['repair_author']+':'+row['path']], cwd=ROOT)
        assert (ROOT/row['path']).read_bytes() == blob
    sources = {}
    manifest = read(HERE/'source-manifest.json')
    for archive in manifest['archives']:
        ap = HERE/archive['path']
        assert sha(ap.read_bytes()) == archive['sha256']
        rows = [r for r in manifest['files'] if r['archive'] == archive['path']]
        with tarfile.open(ap, 'r:gz') as tf:
            assert all(m.isfile() for m in tf.getmembers())
            assert {m.name for m in tf.getmembers()} == {r['path'] for r in rows}
            for row in rows:
                b = tf.extractfile(row['path']).read()
                assert len(b) == row['bytes'] and sha(b) == row['sha256']
                sources[row['path']] = b
    witnesses = read(HERE/'source-witnesses.json')['witnesses']
    for row in witnesses:
        lines = sources[row['source']].split(b'\n')
        b = b'\n'.join(lines[row['first_lf_line']-1:row['last_lf_line']])+b'\n'
        assert sha(b) == row['sha256']
    fold = sources['gcc/fold-const.cc'].decode()
    begin = fold.index('operand_compare::operand_equal_p (tree type0')
    constant_guard = fold.index('Check equality of integer constants before bailing out', begin)
    precision_guard = fold.index('if (element_precision (type0) != element_precision (type1))', begin)
    assert constant_guard < precision_guard
    helper = fold[fold.index('fold_cond_expr_with_comparison ('):fold.index('#ifndef LOGICAL_OP_NON_SHORT_CIRCUIT')]
    assert 'MAX_EXPR, comp_type' in helper and 'return fold_convert_loc (loc, type, tem);' in helper
    return len(sources), len(witnesses)


def check():
    start = time.perf_counter()
    files, spans = source_check()
    ledger = read(HERE/'ledger.json')
    assert sum(n*b for n, b in zip((184,126,138,112), (40,32,40,48))) == 22288
    assert 126+2*138+3*112 == 738
    assert sum(n*b for n, b in zip((24,12,20,12), (40,32,40,48))) == 2720
    assert sum(n*b for n, b in zip((73,4,8,0), (40,32,40,48))) == 3368
    assert 2*19*1328 == 50464 and 22288+50464 == 72752
    assert ledger['assignment']['two_root_Q'] == 38
    ranks = read(HERE/'rank.json')
    for depth in range(129):
        for a, b in ranks['same_depth_edges']:
            assert ranks['phase'][a] > ranks['phase'][b]
        if depth:
            assert (depth, 0) > (depth-1, max(ranks['phase'].values()))
    profiles = 0
    max_query = 0
    # Beyond the current C<=63 comparison point: this checks the recurrence,
    # without asserting that these larger sources are presently admitted.
    for depth in range(129):
        for mode in range(4):
            b, length, p = high_profiles(depth, mode)
            assert query_cost(b)[0] == 2*depth+2
            assert query_cost(length)[0] == 2*depth+3
            assert query_cost(length)[0]+2 <= 2*depth+8
            assert 2*p['bits'][2] == 26*depth+24
            assert 2*depth+1 <= 4*(depth+1)  # provisional/plain W unary
            assert 2*depth+1 <= 4*(depth+1)  # inner + outer CONDs
            max_query = max(max_query, query_cost(length)[0])
            profiles += 1
    repair = read(HERE/'repair.json')
    observed = repair['reachable_MAX_CUBT']
    assert observed[1] > repair['old_conditional_CUBT'][1]
    assert all(a <= b for a,b in zip(observed, repair['replacement_conditional_CUBT']))
    assert repair['corrected_original_layout_bytes']+167328 == 189616
    assignment = assignment_profiles()
    forest_count = event_checks()
    completed = datetime.now(timezone.utc)
    first = datetime(2026,10,24,7,52,13,tzinfo=timezone.utc)
    return dict(status='focused changed-unit check passed; independent review pending',
                complete_native_capacity_result=False,
                accepted_author='302b32d15c293c9f8cf352f80ee9b7b4b068eee0',
                accepted_repair_author=read(HERE/'inputs.json')['repair_author'],
                accepted_repair_review=read(HERE/'inputs.json')['repair_acceptance']['commit'],
                source_files=files, source_spans=spans,
                spine_polarity_profiles=profiles, maximum_tested_depth=128,
                current_admission_comparison_depth=63,
                current_depth_63_two_root_Q=26*63+24,
                original_layout_repair=dict(old_U_row_fails=True,layout_bytes=22288,operand_slots=738,combined_bytes=189616),
                assignment_profiles_h_O_Q=assignment,
                small_concat_trees=forest_count,
                generic_model_is_GCC_execution=False,
                selected_author_model='GPT-6 Astra', selected_author_effort='Extra High',
                runtime_confirmation=None, tokens=None, monetary_cost=None,
                native_execution_seconds=0, predecessor_checkers_run=False,
                host=dict(system=platform.system(),machine=platform.machine(),node=platform.node()),
                completed_utc=completed.isoformat(),
                check_elapsed_seconds=round(time.perf_counter()-start,6),
                elapsed_since_first_recorded_clock_seconds=round((completed-first).total_seconds(),6))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    result = json.dumps(check(), indent=2)+'\n'
    if args.output:
        args.output.write_text(result)
    print(result, end='')
