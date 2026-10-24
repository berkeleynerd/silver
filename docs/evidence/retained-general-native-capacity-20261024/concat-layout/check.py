#!/usr/bin/env python3
"""Source identity and authored finite certificates; does not execute GCC."""
import argparse
import hashlib
import itertools
import json
import platform
import subprocess
import sys
import tarfile
import time
from dataclasses import dataclass
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


@dataclass(eq=False)
class Node:
    code: str
    children: tuple = ()
    value: object = None
    width: int = 32
    side_effects: bool = False


def c(value, width=32):
    return Node('const', value=value, width=width)


def v(name):
    return Node('decl', value=name)


def op(code, *children, width=32):
    assert all(type(n.side_effects) is bool and not n.side_effects for n in children)
    return Node(code, children, width=width)


def cv(node, width):
    if node.code == 'const':
        return c(node.value % (1 << width), width)
    return op('convert', node, width=width)


def select(g, a, b, inverted=False, width=32):
    # Separate invocations create separate comparisons over the same g.
    p = op('ne' if inverted else 'eq', g, c(0), width=1)
    return op('cond', p, b if inverted else a, a if inverted else b, width=width)


def map_arms(node, function, width):
    assert node.code == 'cond'
    return op('cond', node.children[0], *(function(x) for x in node.children[1:]),
              width=width)


def shift(node):
    if node.code == 'const':
        return c((node.value - 1) % (1 << 64), 64)
    return op('plus', node, c(-1, 64), width=64)


def measure(node, active=None):
    """All operand occurrences, with the imported conservative annotation Q."""
    active = set() if active is None else active
    assert id(node) not in active, 'cyclic original operand graph'
    assert type(node.side_effects) is bool and not node.side_effects
    if not node.children:
        return 0, 1, 1
    active.add(id(node))
    profiles = [measure(n, active) for n in node.children]
    active.remove(id(node))
    h = 1 + max(p[0] for p in profiles)
    count = 1 + sum(p[1] for p in profiles)
    charge = 1 + sum(p[2] for p in profiles)
    if (node.code == 'plus' and node.children[1].code == 'const'
            and (node.children[1].value % (1 << node.width)) >> (node.width - 1)):
        charge += 1  # synthetic opposite constant; ordinary operand also charged
    elif node.code in ('plus', 'mult') and node.children[1].code == 'const':
        left = node.children[0]
        if left.code == 'convert':
            inner = left.children[0]
            if (inner.code == node.code and inner.children[1].code == 'const'):
                zero_sum = (node.code == 'plus' and
                            (inner.children[1].value + node.children[1].value)
                            % (1 << 64) == 0)
                # annotate_value returns ops[0] immediately for zero sum,
                # even if it is No_Uint: no failed-child retry follows.
                if not zero_sum:
                    charge += measure(inner.children[0])[2] + 1
    elif node.code == 'bit_and' and node.children[1].code == 'const':
        charge += 2
    return h, count, charge


def high(l, g, associated):
    if l.code == 'const' and l.value == 1:
        return g
    if associated:
        return op('plus', op('plus', l, g), c(-1))
    return op('plus', l, op('plus', g, c(-1)))


def product(length):
    return op('mult', cv(length, 128), c(8, 128), width=128)


def graph_variants():
    """Authored final supergraphs, not an implementation of GCC's folder."""
    for associated, p_low, p_high in itertools.product((False, True), repeat=3):
        l, g, a, h, image = [v(x) for x in ('L', 'G', 'A', 'H', 'Image_V')]
        d = high(l, g, associated)
        for last_low in (a, c(1)):
            for last_high in (h, op('convert', image), c(0)):
                # Some cross-products overapproximate seed provenance; they
                # cannot introduce a larger original selector depth.
                A = select(g, last_low, l, p_low)
                for B in (select(g, last_high, d, p_high), v('fresh_high_debug')):
                    X = map_arms(A, lambda x: cv(x, 64), 64)
                    Y = map_arms(B, lambda x: cv(x, 64), 64) if B.code == 'cond' else cv(B, 64)
                    C = op('ge', B, A, width=1)
                    S = map_arms(X, shift, 64)
                    Z = op('cond', C, Y, S, width=64)
                    D = op('minus', Z, X, width=64)
                    N = op('plus', D, c(1, 64), width=64)
                    yield 'selector_low', product(N)
                    yield 'selector_low_shortcut', product(op('plus', op('minus', Y, X, width=64), c(1, 64), width=64))

        for A in (l, v('fresh_low_debug')):
            for last_high in (h, op('convert', image), c(0)):
                B = select(g, last_high, d, p_high)
                X = cv(A, 64)
                Y = map_arms(B, lambda x: cv(x, 64), 64)
                C = op('ge', B, A, width=1)
                E = op('minus', Y, X, width=64)
                arm = op('plus', E, c(1, 64), width=64)
                yield 'declaration_low_selector_high', op('cond', C, product(arm), c(0, 128), width=128)

        # Low1 with a surviving nullable selector has last Image provenance.
        image_signed = op('convert', image)
        B = select(g, image_signed, g, p_high)
        C = map_arms(B, lambda x: op('gt', x, c(0), width=1), 1)
        Y = map_arms(B, lambda x: cv(x, 64), 64)
        yield 'constant_low_selector_high', op('cond', C, product(Y), c(0, 128), width=128)

        for A, B in ((l, h), (v('low_debug'), v('high_debug'))):
            X, Y = cv(A, 64), cv(B, 64)
            C = op('ge', B, A, width=1)
            arm = op('plus', op('minus', Y, X, width=64), c(1, 64), width=64)
            yield 'two_declarations', op('cond', C, product(arm), c(0, 128), width=128)
        for A in (l, v('fresh_low_debug')):
            length = op('plus', op('minus', cv(d, 64), cv(A, 64), width=64), c(1, 64), width=64)
            yield 'nonnull_arithmetic', product(length)
        # match.pd:4571 permits this cancellation under undefined signed
        # overflow. Its converted-inner PLUS takes the zero-sum return.
        cancelled_length = op('plus', cv(op('plus', g, c(-1)), 64), c(1, 64), width=64)
        assert measure(cancelled_length) == (3, 6, 7)
        yield 'nonnull_guarded_cancel_zero_sum', product(cancelled_length)
        yield 'low1_decl_superflat', op('cond', op('gt', h, c(0), width=1), product(cv(h, 64)), c(0, 128), width=128)
        yield 'low1_decl_shortcut', product(cv(g, 64))


def distribution_attempt(condition, other, fold_arm, counts):
    """The source guard and success test only; arm folding is explicit input."""
    assert condition.code == 'cond'
    _, left, right = condition.children
    counts['attempts'] += 1
    if (other.code != 'const' and
            (other.side_effects or other.code == 'cond'
             or left.code == 'const' or right.code == 'const')):
        counts['pre_arm_rejections'] += 1
        return None
    out = []
    for arm in (left, right):
        counts['arm_calls'] += 1
        out.append(fold_arm(arm, other))
    if other.code != 'const' and all(n.code != 'const' for n in out):
        counts['post_arm_rejections'] += 1
        return None
    counts['ternary_constructors'] += 1
    return op('cond', condition.children[0], *out, width=condition.width)


def guard_checks():
    g, a, b, d = [v(x) for x in ('G', 'A', 'B', 'D')]
    total = 0
    for p, q in itertools.product((False, True), repeat=2):
        left, right = select(g, a, b, p), select(g, a, d, q)
        assert left.children[0] is not right.children[0]
        counts = dict(attempts=0, pre_arm_rejections=0, arm_calls=0,
                      post_arm_rejections=0, ternary_constructors=0)
        def forbidden(*args):
            raise AssertionError('paired conditional guard must precede arm folds')
        assert distribution_attempt(left, right, forbidden, counts) is None
        assert distribution_attempt(right, left, forbidden, counts) is None
        assert counts['arm_calls'] == 0 and counts['pre_arm_rejections'] == 2
        total += 2
    counts = dict(attempts=0, pre_arm_rejections=0, arm_calls=0,
                  post_arm_rejections=0, ternary_constructors=0)
    candidates = []
    def dynamic(x, y):
        candidate = op('minus', x, y)
        candidates.append(candidate)
        return candidate
    assert distribution_attempt(select(g, a, b), d, dynamic, counts) is None
    assert len(candidates) == counts['arm_calls'] == 2
    assert counts['post_arm_rejections'] == 1
    assert counts['ternary_constructors'] == 0
    # A successful outer distribution does not refund those inner candidates.
    before = len(candidates)
    state = iter([op('minus', a, d), c(-1)])
    result = distribution_attempt(select(g, a, b), d, lambda *args: next(state), counts)
    assert result.code == 'cond' and len(candidates) == before
    assert counts['ternary_constructors'] == 1
    # The corrected purity domain is an explicit premise of the graph model.
    for effect in (True, None, 'unknown'):
        try:
            op('cond', Node('eq', side_effects=effect), a, b)
        except AssertionError:
            pass
        else:
            raise AssertionError('unsupported effect witness admitted')
    return dict(paired_attempts=total, discarded_dynamic_candidates=before,
                mixed_counts=counts, rejected_purity_inputs=3,
                nested_u128_pullout=dict(constants=1, unary=3, binary=0, ternary=3))


def arithmetic_checks():
    checked = 0
    def layout(low, high, width):
        mod = 1 << width
        x, y = low % mod, high % mod
        z = y if high >= low else (x - 1) % mod
        return (1 + z - x) % mod
    for width in (3, 4, 5):
        for low in range(-(1 << (width - 1)), 1 << (width - 1)):
            for high in range(-(1 << (width - 1)), 1 << (width - 1)):
                assert layout(low, high, width * 2) == max(0, high - low + 1)
                checked += 1
    boundary = (-(1 << 31), -(1 << 31)+1, -2, -1, 0, 1, 2, (1 << 31)-2, (1 << 31)-1)
    for low, high in itertools.product(boundary, repeat=2):
        assert layout(low, high, 64) == max(0, high-low+1)
        checked += 1
    # Independently built / oppositely polarized tests retain correlated arms.
    polarities = 0
    def choose(g, a, b, inverse):
        return (b if g != 0 else a) if inverse else (a if g == 0 else b)
    for a, l, h, g, p, q in itertools.product(boundary, boundary, boundary, (-1, 0, 1), (False, True), (False, True)):
        d = l + g - 1
        if not -(1 << 31) <= d < (1 << 31):
            continue  # no undefined signed arithmetic input is asserted
        low, high = choose(g, a, l, p), choose(g, h, d, q)
        assert low == (a if g == 0 else l)
        assert high == (h if g == 0 else d)
        assert layout(low, high, 64) == max(0, high-low+1)
        polarities += 1
    assert (1 >= -1) and not (1 % (1 << 64) >= (-1) % (1 << 64))
    assert ((-1) % (1 << 64)) != ((-1) % (1 << 128))
    return dict(signed_endpoint_pairs=checked, correlated_polarity_cases=polarities,
                unsigned_comparison_counterexample=[-1, 1],
                signed_unsigned_widening_counterexample=-1)


def check():
    start = time.perf_counter()
    for name in ('inputs.json', 'packet-manifest.json'):
        for row in read(HERE/name)['files']:
            b = (ROOT/row['path']).read_bytes()
            assert len(b) == row['bytes'] and sha(b) == row['sha256'], row['path']
    accepted = read(HERE/'inputs.json')['accepted_review']
    blob = subprocess.check_output(['git', 'show', accepted['commit']+':'+accepted['path']], cwd=ROOT)
    assert sha(blob) == accepted['sha256']
    manifest = read(HERE.parent/'concat-selectors/source-manifest.json')
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
                sources[row['path']] = b
    witnesses = read(HERE/'source-witnesses.json')['witnesses']
    assert len({row['id'] for row in witnesses}) == len(witnesses)
    for row in witnesses:
        lines = sources[row['source']].split(b'\n')
        low, high = row['first_lf_line'], row['last_lf_line']
        assert sha(b'\n'.join(lines[low-1:high])+b'\n') == row['sha256']
    audit = read(HERE/'matcher-audit.json')
    for name, expected in audit.items():
        result = matcher_inventory(sources['gcc/match.pd'].decode(), set(expected['wanted']))
        assert result['root_forms'] == expected['root_forms'], name
        assert result['simplify_forms_in_both_preprocessor_branches'] == 882
        assert len(result['root_patterns']) == len(expected['root_patterns'])
        for actual, row in zip(result['root_patterns'], expected['root_patterns']):
            assert row['disposition']
            assert actual == {k: v for k, v in row.items() if k != 'disposition'}
    rank = read(HERE/'rank.json')
    for a, b in rank['edges']:
        assert rank['rank'][a] > rank['rank'][b], [a, b]
    for path in rank['resource_paths'].values():
        assert all([a, b] in rank['edges'] for a, b in zip(path, path[1:]))
    profiles, variants = {}, 0
    for name, node in graph_variants():
        profile = measure(node)
        assert all(a <= b for a, b in zip(profile, (9, 59, 63))), (name, profile)
        profiles[name] = [max(a, b) for a, b in zip(profiles.get(name, (0, 0, 0)), profile)]
        variants += 1
    # Deliberate shared retry example verifies Q is not a distinct-node count.
    leaf = v('retry')
    retry = op('mult', cv(op('mult', leaf, c(2)), 64), c(8), width=64)
    assert measure(retry) == (3, 6, 8)
    ledger = read(HERE/'ledger.json')
    total = {k: sum(row['entries']*row['per_entry'][k] for row in ledger['rows'])
             for k in ('constants', 'unary', 'binary', 'ternary')}
    assert total == dict(constants=182, unary=124, binary=137, ternary=111)
    raw = sum(total[k]*ledger['raw_bytes'][k] for k in total)
    assert raw == 22056
    slots = total['unary']+2*total['binary']+3*total['ternary']
    assert slots == 731
    pullout = guard_checks()
    conv = ledger['rows'][1]['per_entry']
    assert all(pullout['nested_u128_pullout'][k] <= conv[k] for k in conv)
    q = 2*63
    assert q == 126 and 1328*q == 167328 and raw+1328*q == 189384
    assert 2*3**9-1 == 39365
    arithmetic = arithmetic_checks()
    completed = datetime.now(timezone.utc)
    first = datetime(2026, 10, 24, 7, 8, 21, tzinfo=timezone.utc)
    return dict(complete_native_capacity_result=False, status='focused check passed; independent review pending',
                author_input=read(HERE/'inputs.json')['author_input'],
                source_files=len(sources), source_witnesses=len(witnesses),
                matcher_root_forms={k: v['root_forms'] for k, v in audit.items()},
                rank_edges=len(rank['edges']), graph_variants=variants,
                graph_profiles_h_O_Q=profiles, guard_checks=pullout,
                arithmetic=arithmetic, layout_constructors=total,
                layout_raw_bytes=raw, layout_operand_slots=slots,
                annotation_Q_per_receiving_array=q,
                annotation_raw_bytes=1328*q, layout_plus_annotation_raw_bytes=raw+1328*q,
                selected_author_model='GPT-6 Astra', selected_author_effort='Extra High',
                runtime_model_effort_confirmation=None, tokens=None, monetary_cost=None,
                native_execution_seconds=0, predecessor_checkers_run=False,
                host=dict(system=platform.system(), machine=platform.machine(), node=platform.node()),
                completed_utc=completed.isoformat(), check_elapsed_seconds=round(time.perf_counter()-start, 6),
                elapsed_since_first_recorded_clock_seconds=round((completed-first).total_seconds(), 6))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    output = json.dumps(check(), indent=2)+'\n'
    if args.output:
        args.output.write_text(output)
    print(output, end='')
