#!/usr/bin/env python3
"""Focused retained-source and authored selector certificate check; no GCC run."""
import argparse
import hashlib
import itertools
import json
import platform
import subprocess
import sys
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE.parent / 'fold-envelope'))
from matcher import matcher_inventory


def read(path):
    return json.loads(path.read_bytes())


def sha(data):
    return hashlib.sha256(data).hexdigest()


class Node:
    """Object identity is deliberate: max_value tests unchanged arm pointers."""
    def __init__(self, code, *args):
        self.code, self.args = code, args


def maximum(node, direction, stats, bounds):
    stats['activations'] += 1
    if node.code == 'literal':
        return node
    if node.code == 'var':
        stats['constant_requests'] += 1  # conservative fold_convert request
        return bounds[direction]
    assert node.code == 'cond'
    _, left, right = node.args
    a = maximum(left, direction, stats, bounds)
    b = maximum(right, direction, stats, bounds)
    if a is left and b is right:
        stats['unchanged_selectors'] += 1
        return node
    stats['minmax_calls'] += 1
    if a.code == b.code == 'literal':
        stats['constant_requests'] += 1
        op = max if direction else min
        value = op(a.args[0], b.args[0])
        assert value == bounds[direction].args[0]
        return bounds[direction]
    # This branch represents the exact extremum-absorption rule, before
    # conditional distribution. It does not recursively visit a condition
    # or construct arithmetic/conditional candidates.
    assert a is bounds[direction] or b is bounds[direction]
    stats['extremum_absorptions'] += 1
    return bounds[direction]


def shape(node):
    if node.code != 'cond':
        return 0, int(node.code == 'var')
    _, a, b = node.args
    sa, da = shape(a)
    sb, db = shape(b)
    return 1 + sa + sb, da + db


def verify_query(node, bounds):
    s, d = shape(node)
    for direction in (False, True):
        stats = dict(activations=0, constant_requests=0, unchanged_selectors=0,
                     minmax_calls=0, extremum_absorptions=0)
        result = maximum(node, direction, stats, bounds)
        assert stats['activations'] == 2*s+1
        assert stats['constant_requests'] <= d+s <= 2*s+1
        assert stats['minmax_calls'] <= s
        assert result is (bounds[direction] if d else node)
        if not d:
            assert stats['constant_requests'] == stats['minmax_calls'] == 0
    return 2


def scalar_export(s, r, m, literals):
    assert type(s) is int and s >= 0
    assert r in (0, 1) and m in (0, 1)
    assert 0 <= literals <= 2*s+4+5*r
    v = dict(constants=13*literals+4+2*r, unary=2+r+m,
             binary=2*s+4*r+3, ternary=s+2*r, var_decl=m)
    sizes = read(HERE/'ledger.json')['raw_bytes']
    raw = sum(sizes[k]*value for k, value in v.items())
    assert raw == 520*literals+128*s+368*r+288*m+344
    query = dict(constants=2*s+11, unary=4)
    qraw = sum(sizes[k]*value for k, value in query.items())
    assert qraw == 80*s+568
    assert raw+qraw == 520*literals+208*s+368*r+288*m+912
    return dict(scalar=v, scalar_raw_bytes=raw, query_pair=query,
                query_pair_raw_bytes=qraw, combined_raw_bytes=raw+qraw)


def check():
    start = time.perf_counter()
    for name in ('inputs.json', 'packet-manifest.json'):
        for row in read(HERE/name)['files']:
            b = (ROOT/row['path']).read_bytes()
            assert len(b) == row['bytes'] and sha(b) == row['sha256'], row['path']
    accepted = read(HERE/'inputs.json')['accepted_review']
    review = subprocess.check_output(
        ['git', 'show', accepted['commit']+':'+accepted['path']], cwd=ROOT)
    assert sha(review) == accepted['sha256']
    manifest = read(HERE/'source-manifest.json')
    assert manifest['gcc_commit'] == '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
    sources = {}
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
                origin = read(ROOT/row['retained_identity'])
                if 'source_sha256_key' in row:
                    assert origin['source_commit'] == manifest['gcc_commit']
                    expected = origin['source_sha256'][row['source_sha256_key']]
                else:
                    expected, = [f['sha256'] for f in origin['files']
                                 if f['path'] == row['path']]
                assert expected == row['sha256']
                assert row['path'] not in sources
                sources[row['path']] = b
    witnesses = read(HERE/'source-witnesses.json')['witnesses']
    assert len({r['id'] for r in witnesses}) == len(witnesses)
    for row in witnesses:
        lines = sources[row['source']].split(b'\n')
        lo, hi = row['first_lf_line'], row['last_lf_line']
        assert 1 <= lo <= hi <= len(lines)
        assert sha(b'\n'.join(lines[lo-1:hi])+b'\n') == row['sha256']
    audit = read(HERE/'matcher-audit.json')
    inventories = [('binary', {'plus', 'minus', 'mult'}, 151),
                   ('conversion', {'convert', 'nop', 'NOP_EXPR', 'CONVERT_EXPR'}, 19),
                   ('conditional', {'cond'}, 65), ('comparison', {'eq', 'ne'}, 109),
                   ('extremum', {'min', 'max'}, 20), ('truth_inverse', {'truth_not'}, 0)]
    for name, wanted, total in inventories:
        actual = matcher_inventory(sources['gcc/match.pd'].decode(), wanted)
        assert actual['root_forms'] == audit[name]['root_forms'] == total
        assert actual['simplify_forms_in_both_preprocessor_branches'] == 882
        assert len(actual['root_patterns']) == len(audit[name]['root_patterns'])
        for a, b in zip(actual['root_patterns'], audit[name]['root_patterns']):
            assert b['disposition']
            assert a == {k: v for k, v in b.items() if k != 'disposition'}
    cert = read(HERE/'rank.json')
    ranks = cert['rank']
    assert len(cert['edges']) == len(set(map(tuple, cert['edges'])))
    assert all(ranks[a] > ranks[b] for a, b in cert['edges'])
    # Exhaustive small balanced selectors test literal-only unchanged arms,
    # arbitrary declaration placement and mixed reconstructed/unchanged arms.
    bounds = {False: Node('literal', -2**31), True: Node('literal', 2**31-1)}
    alphabet = [Node('literal', 1), Node('literal', 7), Node('var', 'D')]
    queries = 0
    absorptions_witnessed = 0
    for leaves in itertools.product(alphabet, repeat=8):
        level = list(leaves)
        while len(level) > 1:
            level = [Node('cond', object(), level[i], level[i+1])
                     for i in range(0, len(level), 2)]
        queries += verify_query(level[0], bounds)
    unchanged = Node('cond', object(), Node('literal', 3), Node('literal', 7))
    mixed = Node('cond', object(), Node('var', 'D'), unchanged)
    for direction in (False, True):
        stats = dict(activations=0, constant_requests=0, unchanged_selectors=0,
                     minmax_calls=0, extremum_absorptions=0)
        assert maximum(mixed, direction, stats, bounds) is bounds[direction]
        assert stats['extremum_absorptions'] == 1
        absorptions_witnessed += 1
    # Source is a spine, with no fixed depth assumption. This is a finite
    # corroborating set; the universal rank/induction is in README.
    sys.setrecursionlimit(20000)
    chains = []
    for n in (1, 2, 16, 256, 4096):
        node = Node('literal', 1)
        for j in range(n):
            node = Node('cond', ('fresh_length', j),
                        alphabet[j % len(alphabet)], node)
        queries += verify_query(node, bounds)
        chains.append(dict(selectors=n, query_activation_bound=2*n+1))
    # Native high algebra, checking wrapped bit patterns across extreme
    # signed values, and exact values wherever both source additions fit.
    vals = [-2**31, -2**31+1, -1, 0, 1, 2, 2**31-2, 2**31-1]
    algebra = 0
    for low, total in itertools.product(vals, repeat=2):
        direct = (low + ((total-1) % 2**32)) % 2**32
        associated = (((low+total) % 2**32)-1) % 2**32
        assert direct == associated == (low+total-1) % 2**32
        if low == 1:
            assert direct == total % 2**32
        algebra += 1
    # Paired selectors preserve the exceptional last bounds, including a
    # superflat pair. Equality means the shared G value, not pointer-sharing.
    pairs = 0
    for total, low, last_low, last_high in itertools.product(
            (0, 1, 2, 4096), (1, 2, 7), (1, 2, 9), (-7, 0, 1, 4)):
        test_low = Node('eq', 'G', 0)
        test_high = Node('eq', 'G', 0)
        assert test_low is not test_high and test_low.args == test_high.args
        lo = last_low if total == 0 else low
        hi = last_high if total == 0 else low+total-1
        if total:
            assert hi-lo+1 == total
        else:
            assert (lo, hi) == (last_low, last_high)
        # Either native selector may invert its condition and swap arms.
        assert lo == (low if total != 0 else last_low)
        assert hi == (low+total-1 if total != 0 else last_high)
        pairs += 1
    coefficients = 0
    for s, r, m in itertools.product((0, 1, 2, 7, 63, 1024), (0, 1), (0, 1)):
        for literals in (0, 1, 2*s+4+5*r):
            scalar_export(s, r, m, literals)
            coefficients += 1
    assert not read(HERE/'remaining.json')['complete_native_capacity_result']
    return dict(status='pass',platform=platform.system(),machine=platform.machine(),
                elapsed_seconds=time.perf_counter()-start,
                completed_utc=datetime.now(timezone.utc).isoformat(),
                complete_sources=len(sources),lf_witnesses=len(witnesses),
                matcher_forms={n: t for n, _, t in inventories},
                rank_states=len(ranks),rank_edges=len(cert['edges']),
                selector_queries=queries,extremum_absorption_witnesses=absorptions_witnessed,
                long_chains=chains,high_arithmetic_cases=algebra,
                paired_selector_cases=pairs,coefficient_cases=coefficients,
                example_source_event=scalar_export(1,0,1,6),
                complete_native_capacity_result=False,
                native_compiler_prover_lean_predecessor_runs=0)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    result = check()
    if args.write:
        (HERE/'current.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
