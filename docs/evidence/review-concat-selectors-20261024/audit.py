#!/usr/bin/env python3
"""Independent offline receipt; does not import or execute author tooling."""
import hashlib
import itertools
import json
import platform
import subprocess
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
UNIT = ROOT / 'docs/evidence/retained-general-native-capacity-20261024/concat-selectors'
AUTHOR = 'bba92a0c0685cffdf8c9e179f6b36aafea81c4be'
ACCEPTED = 'fd44328b98f1a977d0cfdbb01aa161940124edcb'
REVIEW = '000656e773c6eae24a673afeb5af05f200dc6723'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(path.read_bytes())


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def receipt(name, data):
    return dict(path=name, bytes=len(data), sha256=sha(data))


def audit():
    start = time.perf_counter()
    changed = git('diff-tree', '--no-commit-id', '--name-only', '-r', AUTHOR).decode().splitlines()
    assert len(changed) == 12
    exact = []
    for name in changed:
        data = (ROOT / name).read_bytes()
        assert data == git('show', f'{AUTHOR}:{name}')
        exact.append(receipt(name, data))
    inputs = read(UNIT / 'inputs.json')
    assert inputs['author_input'] == ACCEPTED
    anchors = []
    for row in inputs['files']:
        data = (ROOT / row['path']).read_bytes()
        assert len(data) == row['bytes'] and sha(data) == row['sha256']
        assert data == git('show', f'{ACCEPTED}:{row["path"]}')
        anchors.append(row)
    review = inputs['accepted_review']
    assert review['commit'] == REVIEW
    review_data = git('show', f'{REVIEW}:{review["path"]}')
    assert sha(review_data) == review['sha256']
    previous_files = git('ls-tree', '-r', '--name-only', ACCEPTED, '--',
                        'docs/evidence/retained-general-native-capacity-20261024').decode().splitlines()
    for name in previous_files:
        assert (ROOT / name).read_bytes() == git('show', f'{ACCEPTED}:{name}')
    for row in read(UNIT / 'packet-manifest.json')['files']:
        data = (ROOT / row['path']).read_bytes()
        assert len(data) == row['bytes'] and sha(data) == row['sha256']
    manifest = read(UNIT / 'source-manifest.json')
    assert manifest['gcc_commit'] == '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
    sources = {}
    for archive in manifest['archives']:
        path = UNIT / archive['path']
        assert sha(path.read_bytes()) == archive['sha256']
        rows = [r for r in manifest['files'] if r['archive'] == archive['path']]
        with tarfile.open(path) as package:
            assert all(m.isfile() for m in package.getmembers())
            assert sorted(package.getnames()) == sorted(r['path'] for r in rows)
            for row in rows:
                data = package.extractfile(row['path']).read()
                assert len(data) == row['bytes'] and sha(data) == row['sha256']
                origin = read(ROOT / row['retained_identity'])
                if 'source_sha256_key' in row:
                    assert origin['source_commit'] == manifest['gcc_commit']
                    bound_hash = origin['source_sha256'][row['source_sha256_key']]
                else:
                    bound_hash, = [r['sha256'] for r in origin['files'] if r['path'] == row['path']]
                assert bound_hash == sha(data)
                sources[row['path']] = data
    spans = read(UNIT / 'source-witnesses.json')['witnesses']
    for row in spans:
        data = b'\n'.join(sources[row['source']].split(b'\n')[row['first_lf_line']-1:row['last_lf_line']])+b'\n'
        assert sha(data) == row['sha256']
    extra = []
    for name, lo, hi in [
        ('gcc/match.pd', 6859, 6962),
        ('gcc/match.pd', 7180, 7231),
        ('gcc/fold-const.cc', 13077, 13230),
        ('gcc/genmatch.cc', 3573, 3604),
        ('gcc/ada/gcc-interface/decl.cc', 7534, 7657),
    ]:
        data = b'\n'.join(sources[name].split(b'\n')[lo-1:hi])+b'\n'
        extra.append(dict(source=name, first_lf_line=lo, last_lf_line=hi, sha256=sha(data)))
    # Bind authored lexical forms to exact complete source. Extraction
    # completeness and semantic dispositions are reviewed separately.
    inventory = read(UNIT / 'matcher-audit.json')
    text = sources['gcc/match.pd'].decode()
    totals = dict(binary=151, conversion=19, conditional=65, comparison=109,
                  extremum=20, truth_inverse=0)
    for kind, total in totals.items():
        rows = inventory[kind]['root_patterns']
        assert len(rows) == inventory[kind]['root_forms'] == total
        for row in rows:
            suffix = '\n'.join(text.split('\n')[row['line']-1:])
            assert suffix.lstrip().startswith(row['source'])
            assert row['disposition']
    ranks = read(UNIT / 'rank.json')
    assert len(ranks['rank']) == 15 and len(ranks['edges']) == 18
    assert len({tuple(e) for e in ranks['edges']}) == 18
    assert all(ranks['rank'][a] > ranks['rank'][b] for a, b in ranks['edges'])

    # Bottom-up occurrence summaries for the selector induction. No condition
    # or initializer is represented, so these checks are corroboration only.
    # State=(selectors, declaration leaves, visits, constant requests, changed).
    def leaf(declaration):
        return (0, int(declaration), 1, int(declaration), declaration)
    def join(a, b):
        changed = a[4] or b[4]
        # A changed child is the extremum. Against another extremum/literal,
        # budget one constant; against an unchanged selector, absorption is
        # free. One per changed parent is a conservative upper bound.
        out = (a[0]+b[0]+1, a[1]+b[1], a[2]+b[2]+1,
               a[3]+b[3]+int(changed), changed)
        s, d, calls, constants, changed = out
        assert calls == 2*s+1 and constants <= d+s <= 2*s+1
        assert changed == bool(d)
        if not d:
            assert constants == 0
        return out
    summary_cases = 0
    for leaves in itertools.product((False, True), repeat=8):
        level = [leaf(v) for v in leaves]
        while len(level) > 1:
            level = [join(level[i], level[i+1]) for i in range(0, len(level), 2)]
        summary_cases += 1
    chain_cases = []
    for length in (1, 2, 17, 257, 4097):
        state = leaf(False)
        for j in range(length):
            state = join(leaf(j % 3 == 0), state)
        chain_cases.append(dict(selectors=length, visits=state[2], constant_bound=state[3]))
    extremum_cases = 0
    for bits in (3, 4, 8):
        lower, upper = -(1 << (bits-1)), (1 << (bits-1))-1
        for a, b in itertools.product(range(lower, upper+1), repeat=2):
            # Both possible choices of an unchanged literal-only selector.
            assert max(upper, a) == max(upper, b) == upper
            assert min(lower, a) == min(lower, b) == lower
            extremum_cases += 1

    # Finite source cardinality corroboration over retained operand lists.
    # F/E are fixed positive/last-empty low1; A/B input lows; I Image low1.
    source_cases = 0
    worst = None
    for n in range(2, 7):
        for ops in itertools.product('FAIB', repeat=n-1):
            for last in 'FAIBE':
                seq = ops+(last,)
                if all(v in 'FE' for v in seq):
                    continue
                r = int('F' not in seq)
                def low(v):
                    return 'one' if v in 'FIE' else v
                # Construct source spine from right to left until fixed leaf.
                selected = low(last)
                s = 0
                for v in reversed(ops):
                    if v == 'F':
                        selected, s = 'one', 0
                    elif selected != low(v):
                        selected, s = (low(v), selected), s+1
                def literal_leaves(node):
                    return sum(literal_leaves(x) for x in node) if isinstance(node, tuple) else int(node == 'one')
                m = int(isinstance(selected, tuple))
                source_literals = s+literal_leaves(selected) if m else 0
                source_literals += 2*int(selected == 'one')+1
                if r:
                    source_literals += 2+int(low(last) == 'one')+(2 if last == 'E' else 0)
                assert s <= n-1
                assert source_literals <= 2*s+4+5*r
                source_cases += 1
                if worst is None or source_literals > worst['literal_occurrences']:
                    worst = dict(operands=''.join(seq), s=s, r=r, m=m, literal_occurrences=source_literals)

    algebra_cases = 0
    for bits, values in [(6, range(-32, 32)),
                         (32, (-2**31, -2**31+1, -1, 0, 1, 2, 2**31-2, 2**31-1))]:
        lower, upper, modulus = -(1 << (bits-1)), (1 << (bits-1))-1, 1 << bits
        for l, g in itertools.product(values, repeat=2):
            assert (l+(g-1) % modulus) % modulus == ((l+g) % modulus-1) % modulus
            # Undefined-overflow accounting retains the original association;
            # do not validate reassociation by wrapped arithmetic in that mode.
            if lower <= g-1 <= upper and lower <= l+g-1 <= upper:
                assert l+(g-1) == l+g-1
            algebra_cases += 1
    coefficient_cases = 0
    for s, r, m in itertools.product((0, 1, 2, 17, 257, 4097), (0, 1), (0, 1)):
        for j in (0, 1, 2*s+4+5*r):
            c, u, b, t, d = 13*j+4+2*r, 2+r+m, 2*s+4*r+3, s+2*r, m
            scalar = 40*c+32*u+40*b+48*t+256*d
            query = 40*(2*s+11)+32*4
            assert scalar == 520*j+128*s+368*r+288*m+344
            assert query == 80*s+568
            assert scalar+query == 520*j+208*s+368*r+288*m+912
            coefficient_cases += 1
    paired_cases = 0
    for g, l, last_l, last_h, invert_l, invert_h in itertools.product(
            (0, 1, 7), (1, 9), (1, 13), (-4, 0, 11), (False, True), (False, True)):
        low_test, high_test = object(), object()
        assert low_test is not high_test
        low_cond = g != 0 if invert_l else g == 0
        high_cond = g != 0 if invert_h else g == 0
        low_arms = (l, last_l) if invert_l else (last_l, l)
        high_arms = (l+g-1, last_h) if invert_h else (last_h, l+g-1)
        pair = (low_arms[0 if low_cond else 1], high_arms[0 if high_cond else 1])
        assert pair == ((last_l, last_h) if g == 0 else (l, l+g-1))
        paired_cases += 1
    assert read(UNIT / 'current.json')['complete_native_capacity_result'] is False
    assert read(UNIT / 'remaining.json')['complete_native_capacity_result'] is False
    return dict(status='pass', completed_utc=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.perf_counter()-start, platform=f'{platform.system()} {platform.machine()}',
        reviewed_author=AUTHOR, accepted_author=ACCEPTED, accepted_review=REVIEW,
        exact_author_files=exact, accepted_anchors=anchors, unchanged_previous_packet_files=len(previous_files),
        accepted_review_receipt=receipt(f'{REVIEW}:{review["path"]}', review_data),
        source_files=manifest['files'], source_witnesses=len(spans), additional_source_spans=extra,
        lexical_forms_bound_to_source=totals, rank_states=15, rank_edges=18,
        selector_summary_cases=summary_cases, selector_chains=chain_cases,
        literal_extremum_absorption_cases=extremum_cases, source_cardinality_cases=source_cases,
        largest_finite_literal_example=worst, high_algebra_cases=algebra_cases,
        coefficient_cases=coefficient_cases, separate_condition_polarity_cases=paired_cases,
        selected_reviewer_model='GPT-6 Astra', selected_reviewer_effort='Extra High',
        runtime_model_and_effort=None, tokens=None, cost=None,
        author_checker_runs=0, predecessor_checker_runs=0, native_compiler_prover_Lean_runs=0,
        semantic_source_argument_machine_proved=False, complete_native_capacity_result=False)


if __name__ == '__main__':
    result = audit()
    (HERE / 'current.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: v for k, v in result.items() if k not in {
        'exact_author_files', 'accepted_anchors', 'source_files', 'additional_source_spans'}}, indent=2))
