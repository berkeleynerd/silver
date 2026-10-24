#!/usr/bin/env python3
"""Independent, offline receipt for the bounded concat-prefix review.

No author checker/parser is imported. These checks bind the reviewed source
argument and corroborate arithmetic; they are not a GCC execution or proof.
"""
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
UNIT = ROOT / 'docs/evidence/retained-general-native-capacity-20261024/concat-prefix'
AUTHOR = 'fd44328b98f1a977d0cfdbb01aa161940124edcb'
ACCEPTED = '4f518ea3151ad1d11c6c3654c84dd730bc4e2aff'
REVIEW = 'a33e3ef26af3de8a8c105bc9137a79d7d6ee2438'
GCC = '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(path.read_bytes())


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def entry(path, data):
    return dict(path=path, bytes=len(data), sha256=digest(data))


def audit():
    started = time.perf_counter()
    changed = git('diff-tree', '--no-commit-id', '--name-only', '-r', AUTHOR).decode().splitlines()
    assert len(changed) == 13
    exact_inputs = []
    for name in changed:
        data = (ROOT / name).read_bytes()
        assert data == git('show', f'{AUTHOR}:{name}')
        exact_inputs.append(entry(name, data))
    accepted_inputs = []
    for row in read(UNIT / 'inputs.json')['files']:
        data = (ROOT / row['path']).read_bytes()
        assert len(data) == row['bytes'] and digest(data) == row['sha256']
        assert data == git('show', f'{ACCEPTED}:{row["path"]}')
        accepted_inputs.append(row)
    # Reuse all earlier packet files unchanged, not just the supplied anchors.
    prior = 'docs/evidence/retained-general-native-capacity-20261024'
    paths = git('ls-tree', '-r', '--name-only', ACCEPTED, '--', prior).decode().splitlines()
    for name in paths:
        assert (ROOT / name).read_bytes() == git('show', f'{ACCEPTED}:{name}')
    accepted_review_path = 'docs/reviews/review-native-input-envelope-20261024.md'
    review_data = git('show', f'{REVIEW}:{accepted_review_path}')
    assert b'No material defect or required author repair' in review_data

    for row in read(UNIT / 'packet-manifest.json')['files']:
        data = (ROOT / row['path']).read_bytes()
        assert len(data) == row['bytes'] and digest(data) == row['sha256']
    manifest = read(UNIT / 'source-manifest.json')
    assert manifest['gcc_commit'] == GCC
    sources = {}
    for archive in manifest['archives']:
        path = UNIT / archive['path']
        assert digest(path.read_bytes()) == archive['sha256']
        rows = [r for r in manifest['files'] if r['archive'] == archive['path']]
        with tarfile.open(path) as package:
            assert all(m.isfile() for m in package.getmembers())
            assert sorted(package.getnames()) == sorted(r['path'] for r in rows)
            for row in rows:
                data = package.extractfile(row['path']).read()
                assert len(data) == row['bytes'] and digest(data) == row['sha256']
                origin = read(ROOT / row['retained_identity'])
                if 'source_sha256_key' in row:
                    assert origin['source_commit'] == GCC
                    retained = origin['source_sha256'][row['source_sha256_key']]
                else:
                    retained, = [r['sha256'] for r in origin['files'] if r['path'] == row['path']]
                assert retained == digest(data)
                sources[row['path']] = data
    spans = read(UNIT / 'source-witnesses.json')['witnesses']
    for row in spans:
        lines = sources[row['source']].split(b'\n')
        data = b'\n'.join(lines[row['first_lf_line']-1:row['last_lf_line']])+b'\n'
        assert digest(data) == row['sha256']
    additional = []
    for name, lo, hi in [
        ('gcc/ada/exp_util.adb', 7221, 7243),
        ('gcc/ada/exp_util.adb', 12716, 12723),
        ('gcc/ada/exp_util.adb', 14530, 14539),
        ('gcc/fold-const.cc', 11390, 11542),
        ('gcc/fold-const.cc', 11773, 11860),
        ('gcc/ada/gcc-interface/utils.cc', 3085, 3110),
    ]:
        data = b'\n'.join(sources[name].split(b'\n')[lo-1:hi])+b'\n'
        additional.append(dict(source=name, first_lf_line=lo, last_lf_line=hi,
                               sha256=digest(data)))

    # The accepted complete lexical inventory is reused unchanged; only the
    # new domain/dispositions require this review. Verify every retained form
    # against source without executing either author's inventory parser.
    inventories = read(UNIT / 'matcher-audit.json')
    accepted_inventory = read(UNIT.parent / 'fold-envelope/matcher-audit.json')
    match_source = sources['gcc/match.pd'].decode()
    for kind, count in [('binary', 151), ('conversion', 19)]:
        rows = inventories[kind]['root_patterns']
        assert len(rows) == count
        previous = accepted_inventory[kind]['root_patterns']
        assert len(previous) == count
        for row, old in zip(rows, previous):
            assert {k: v for k, v in row.items() if k != 'disposition'} == {
                k: v for k, v in old.items() if k != 'disposition'}
            assert row['source'] in match_source
            suffix = '\n'.join(match_source.split('\n')[row['line']-1:])
            assert suffix.lstrip().startswith(row['source'])
            assert row['disposition']
    rank = read(UNIT / 'rank.json')
    assert len(rank['rank']) == 30 and len(rank['edges']) == 40
    assert len({tuple(edge) for edge in rank['edges']}) == 40
    assert all(rank['rank'][a] > rank['rank'][b] for a, b in rank['edges'])

    # This local model counts only the immediate CONST/DECL/PLUS grammar.
    # A declaration's deliberately hostile initializer must never be visited.
    def maximum(node, take_max, bits):
        lower, upper = -(1 << (bits-1)), (1 << (bits-1))-1
        code, *rest = node
        if code == 'DECL':
            return (upper if take_max else lower), False, 1, 1
        if code == 'CST':
            return rest[0], False, 0, 1
        assert code == 'PLUS'
        left = maximum(rest[0], take_max, bits)
        right = maximum(rest[1], take_max, bits)
        exact = left[0] + right[0]
        overflow = left[1] or right[1] or not lower <= exact <= upper
        return ((exact-lower) % (1 << bits)+lower, overflow,
                left[2]+right[2]+1, left[3]+right[3]+1)

    decl = ('DECL', object())
    maximum_cases = 0
    for bits in (4, 8, 32):
        values = (-(1 << (bits-1)), -1, 0, 1, (1 << (bits-1))-1)
        leaves = [decl] + [('CST', value) for value in values]
        for a, b, take_max in itertools.product(leaves, leaves, (False, True)):
            result = maximum(('PLUS', a, b), take_max, bits)
            assert result[2] <= 3 and result[3] == 3
            if result[1]:
                fallback = (1 << (bits-1))-1 if take_max else -(1 << (bits-1))
                assert -(1 << (bits-1)) <= fallback < (1 << (bits-1))
            maximum_cases += 1
    chains = []
    for length in (2, 3, 31, 4096):
        previous = ('CST', 7)
        for _ in range(length-1):
            initializer = ('PLUS', previous, decl)
            previous = ('DECL', initializer)
        result = maximum(initializer, True, 32)
        assert result[2] <= 3 and result[3] == 3
        chains.append(dict(operands=length, requests=result[2], activations=result[3]))
    arithmetic_cases = 0
    for bits, values in [(8, range(-128, 128)),
                         (32, (-2**31, -2**31+1, -65536, -1, 0, 1, 7,
                               255, 65536, 2**31-2, 2**31-1))]:
        lower = -(1 << (bits-1))
        wrap = lambda n: (n-lower) % (1 << bits)+lower
        for g in values:
            assert wrap(1+wrap(g-1)) == g
            if g != lower:
                assert 1+(g-1) == g
            x = g % 2**64
            assert (1+(x-1) % 2**64) % 2**64 == x
            assert (8*x) % 8 == 0
            arithmetic_cases += 1
    assert -1+1 == 0  # no signed overflow in the association's constant fold
    assert (-1 % 2**64) != (-1 % 2**128)  # preserve the widening barrier

    # Candidate vectors from source analysis, not imported from ledger/check.py.
    vectors = {
        'signed_high_minus': dict(constants=2, unary=0, binary=1),
        'signed_high_outer_plus': dict(constants=1, unary=1, binary=0),
        'maximum_two_declarations': dict(constants=3, unary=0, binary=0),
        'layout_minus': dict(constants=2, unary=0, binary=1),
        'layout_association': dict(constants=1, unary=0, binary=0),
        'layout_multiply_candidate': dict(constants=2, unary=0, binary=1),
    }
    # Every source high entry fits the author's componentwise envelope.
    for key in ('signed_high_minus', 'signed_high_outer_plus'):
        assert all(vectors[key][k] <= v for k, v in dict(constants=2, unary=1, binary=1).items())
    graphs = []
    for conversions in (0, 1, 2):
        graph = ('VAR',)
        for _ in range(conversions):
            graph = ('CONVERT', graph)
        graph = ('MULT', graph, ('CST',))
        def measure(node):
            children = [measure(child) for child in node[1:]]
            return (1+max((v[0] for v in children), default=-1),
                    1+sum(v[1] for v in children))
        h, q = measure(graph)
        assert h <= 3 and q <= 5
        graphs.append(dict(conversions=conversions, height=h, occurrence_charge=q))
    coefficient_cases = 0
    for cs, ca in itertools.product((0, 1, 2, 7, 31, 1024, 2**31-1), repeat=2):
        c, u, b, d = 3*13*cs+2*2*cs+(7+6+17*2+2*3)*ca, 3*cs+13*ca, 2*cs+17*ca, cs
        q = 2*5*ca
        assert (c, u, b) == (43*cs+53*ca, 3*cs+13*ca, 2*cs+17*ca)
        assert 40*c+32*u+40*b+256*d == 2152*cs+3216*ca
        assert 40*(c+32*q)+32*(u+q)+40*b+256*d+16*q == 2152*cs+16496*ca
        assert u+q+2*b == 7*cs+57*ca
        coefficient_cases += 1
    assert 40+32+24+72 == 168 and 4*512 == 2048
    assert 9+43 == 52 and 83+53+320 == 456
    current = read(UNIT / 'current.json')
    remaining = read(UNIT / 'remaining.json')
    for key in ('complete_native_capacity_result', 'full_concat_family_closed',
                'selected_low_null_selector_closed', 'full_helper_workspace_closed',
                'enclosing_fat_pointer_closed', 'semantic_source_argument_machine_proved'):
        assert current[key] is False
    assert remaining['complete_native_capacity_result'] is False
    assert {r['id'] for r in remaining['additional_range_producers']} == {
        'static_max_return_slice', 'assignment_slices'}

    return dict(status='pass', checked_at_utc=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.perf_counter()-started, platform=f'{platform.system()} {platform.machine()}',
        author=AUTHOR, accepted_author=ACCEPTED, accepted_review=REVIEW, gcc_commit=GCC,
        exact_inputs=exact_inputs, accepted_input_anchors=accepted_inputs,
        unchanged_prior_packet_files=len(paths),
        accepted_review_input=entry(f'{REVIEW}:{accepted_review_path}', review_data),
        complete_source_files=manifest['files'], author_LF_spans=len(spans), additional_spans=additional,
        lexical_forms_reused_and_source_bound=170, rank_states=30, rank_edges=40,
        maximum_cases=maximum_cases, declaration_chain_cases=chains,
        arithmetic_cases=arithmetic_cases, reviewed_candidate_vectors=vectors,
        annotation_graphs=graphs, coefficient_cases=coefficient_cases,
        selected_reviewer_model='GPT-6 Astra', selected_reviewer_effort='Extra High',
        runtime_model_and_effort=None, tokens=None, cost=None,
        author_checker_runs=0, predecessor_checker_runs=0, native_target_runs=0,
        compiler_prover_Lean_runs=0, semantic_source_argument_machine_proved=False,
        verdict='accept bounded concat-prefix constructor/annotation and template subcall; no required repair',
        complete_native_capacity_result=False)


if __name__ == '__main__':
    result = audit()
    (HERE / 'current.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: v for k, v in result.items() if k not in {
        'exact_inputs', 'accepted_input_anchors', 'complete_source_files',
        'additional_spans', 'reviewed_candidate_vectors'}}, indent=2))
