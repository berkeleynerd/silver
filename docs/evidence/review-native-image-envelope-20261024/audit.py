#!/usr/bin/env python3
"""Independent source/finite-envelope corroboration; no compiler/checker replay."""
import hashlib
import itertools
import json
import platform
import re
import subprocess
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = ROOT / 'docs/evidence/retained-general-native-capacity-20261024/fold-envelope'
FREEZE = '0ed7c10db8e806c4ee05c3c56fa6dfe54f0d132e'
PREVIOUS = '26bd01de61242d49f4680d609b38d09e3a51925f'
START = datetime(2026, 10, 24, 4, 59, 26, tzinfo=timezone.utc)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(path.read_bytes())


def git(commit, path):
    return subprocess.check_output(['git', 'show', f'{commit}:{path}'], cwd=ROOT)


def main():
    start = time.perf_counter()
    inputs = {}
    for manifest in ('inputs.json', 'packet-manifest.json'):
        for row in read(AUTHOR / manifest)['files']:
            data = (ROOT / row['path']).read_bytes()
            assert len(data) == row['bytes'] and sha(data) == row['sha256']
            assert git(FREEZE, row['path']) == data
            inputs[row['path']] = row
    for path in AUTHOR.iterdir():
        if path.is_file():
            data = path.read_bytes()
            rel = str(path.relative_to(ROOT))
            assert git(FREEZE, rel) == data
            inputs[rel] = {'path': rel, 'bytes': len(data), 'sha256': sha(data)}
    sources = {}
    sm = read(AUTHOR / 'source-manifest.json')
    for archive in sm['archives']:
        path = AUTHOR / archive['path']
        assert sha(path.read_bytes()) == archive['sha256']
        rows = [r for r in sm['files'] if r['archive'] == archive['path']]
        with tarfile.open(path) as tf:
            members = tf.getmembers()
            assert all(m.isfile() for m in members)
            assert sorted(m.name for m in members) == sorted(r['path'] for r in rows)
            for r in rows:
                data = tf.extractfile(r['path']).read()
                assert len(data) == r['bytes'] and sha(data) == r['sha256']
                prior = read(ROOT / r['retained_identity'])
                if 'source_sha256_key' in r:
                    assert prior['source_commit'] == sm['gcc_commit']
                    expected = prior['source_sha256'][r['source_sha256_key']]
                else:
                    expected, = [x['sha256'] for x in prior['files'] if x['path'] == r['path']]
                assert expected == sha(data)
                sources[r['path']] = data
    witnesses = read(AUTHOR / 'source-witnesses.json')['witnesses']
    for row in witnesses:
        data = b'\n'.join(sources[row['source']].split(b'\n')[
            row['first_lf_line']-1:row['last_lf_line']]) + b'\n'
        assert sha(data) == row['sha256']
    extra = read(HERE / 'extra-source.json')
    assert sha((HERE / extra['archive']).read_bytes()) == extra['archive_sha256']
    with tarfile.open(HERE / extra['archive']) as tf:
        data = tf.extractfile(extra['path']).read()
    assert sha(data) == extra['sha256'] and len(data) == extra['bytes']
    assert read(ROOT / extra['retained_identity'])['source_sha256']['exp_put_image.adb'] == sha(data)
    sources[extra['path']] = data
    put = data.decode().split('\n')
    put_body = '\n'.join(put[1246:1286])
    assert 'Ada_Version < Ada_2022' in put_body
    assert 'Has_Aspect (U_Type, Aspect_Put_Image)' in put_body
    assert 'or else not Is_Scalar_Type (U_Type)' in put_body
    assert 'if Is_Itype (U_Type)' in put_body and 'return False;' in put_body

    extra_spans = []
    for name, lo, hi in [('gcc/ada/exp_put_image.adb', 1247, 1286),
                         ('gcc/ada/exp_imgv.adb', 1042, 1116),
                         ('gcc/fold-const.cc', 9341, 9514),
                         ('gcc/genmatch.cc', 3444, 3482),
                         ('gcc/tree.cc', 4074, 4107)]:
        data = b'\n'.join(sources[name].split(b'\n')[lo-1:hi]) + b'\n'
        extra_spans.append({'source': name, 'first_lf_line': lo, 'last_lf_line': hi,
                            'sha256': sha(data)})

    preserved = []
    for suffix in ('check-result.json', 'string-pack-current.json',
                   'helper-joins/README.md', 'helper-joins/current.json',
                   'dynamic-helpers/README.md', 'dynamic-helpers/check.py',
                   'dynamic-helpers/current.json'):
        rel = 'docs/evidence/retained-general-native-capacity-20261024/' + suffix
        assert git(PREVIOUS, rel) == (ROOT / rel).read_bytes()
        preserved.append(rel)

    # Bind each retained lexical form to its actual source text and line.
    # This does not turn the authored exclusion dispositions into a proof.
    matcher = read(AUTHOR / 'matcher-audit.json')
    raw_match = sources['gcc/match.pd'].decode()
    lines = raw_match.split('\n')
    form_checks = 0
    for kind, count in [('binary', 151), ('conversion', 19)]:
        rows = matcher[kind]['root_patterns']
        assert len(rows) == count
        for row in rows:
            assert '\n'.join(lines[row['line']-1:]).lstrip().startswith(row['source'])
            assert row['pattern'] in row['source'] and row['disposition']
            form_checks += 1
    rank = read(AUTHOR / 'rank.json')
    edges = rank['edges']
    adjacency = {n: [] for n in rank['rank']}
    for a,b in edges:
        adjacency[a].append(b)
    def depth(node, stack=()):
        assert node not in stack
        return max([0] + [1+depth(c, stack+(node,)) for c in adjacency[node]])
    path_lengths = {n: depth(n) for n in adjacency}

    # Independent finite construction envelopes for the reviewed request
    # states. Each vector is (constant, unary, binary); no actual GCC runs.
    terminal_plus = (1, 0, 1)  # conservatively permit overflow-clearing candidate
    negation = (1, 0, 0)
    minus = tuple(a+b for a,b in zip(negation, terminal_plus))
    association = (1, 0, 0)  # exact-type views vanish, final PLUS-zero is identity
    multiplication = [(0, 0, 0), (0, 0, 1), (1, 0, 1)]
    entry_vectors = [minus, terminal_plus, association, (1, 0, 0)] + multiplication
    assert all(c <= 2 and u == 0 and b <= 1 for c,u,b in entry_vectors)

    # All paths in the returned finite annotation grammar, including a shared
    # leaf, are evaluated recursively; no height-only replacement for Q.
    def measure(node):
        if not isinstance(node, tuple):
            return 0, 1, 1
        children = [measure(x) for x in node[1:]]
        return (1+max(x[0] for x in children), 1+sum(x[1] for x in children),
                1+max(x[2] for x in children))
    result_graphs = []
    for n in range(3):
        v = 'readonly Natural declaration'
        for _ in range(n):
            v = ('NOP', v)
        h,q,d = measure(('MULT', v, 'eight'))
        assert h <= 3 and q <= 5 and d <= 4
        result_graphs.append({'conversions': n, 'height': h, 'Q': q, 'active_depth': d})

    cancellation_cases = barrier_cases = 0
    for width in (8, 16, 32, 64, 128):
        mod = 1 << width
        values = set(range(256)) | {mod-2, mod-1, mod, mod+1}
        for x in values:
            assert ((x-1) % mod + 1) % mod == x % mod
            cancellation_cases += 1
    for v in list(range(-128, 128)) + [-2**31, -2**31+1, 2**31-2, 2**31-1]:
        via_u64 = v % (1 << 64)
        direct_u128 = v % (1 << 128)
        assert (via_u64 == direct_u128) == (v >= 0)
        assert (8*via_u64) % 8 == 0
        assert 8*via_u64 < 1 << 128
        barrier_cases += 1
    # The actual nonnegative Natural upper bound is ample for current sizes;
    # it is not used to authorize deleting the native intermediate conversion.
    assert 8*(2**31-1) == 17179869176

    current = read(AUTHOR / 'current.json')
    coefficient_cases = 0
    for s,a in itertools.product((0,1,2,3,19,127,1024,2**31-1,2**63-1), repeat=2):
        constants = 13*s + (7+6+34+2)*a
        unary = s+(7+6)*a
        binary = 17*a
        helper_bytes = 40*constants+32*unary+40*binary+256*s
        q = 2*a*5
        total_bytes = helper_bytes+q*(32*40+32+16)
        assert helper_bytes == 808*s+3056*a
        assert total_bytes == 808*s+16336*a
        assert constants+32*q == 13*s+369*a
        assert unary+q+2*binary == s+57*a
        assert 8*(3*q)+4*(11*q)+32*q == 1000*a
        coefficient_cases += 1
    assert current['H_Image_upper'] == 3 and current['Q_per_Image_root_upper'] == 5
    assert current['helper_plus_annotation']['raw_caller_bytes'] == '808Is+16336Ia'
    assert current['full_helper_workspace_closed'] is False
    assert current['all_dynamic_F_Q_closed'] is False
    assert current['complete_native_capacity_result'] is False

    finished = datetime.now(timezone.utc)
    result = dict(status='pass', reviewed_author_commit=FREEZE,
        accepted_previous_author_commit=PREVIOUS, gcc_commit=sm['gcc_commit'],
        host=f'{platform.system()} {platform.machine()}',
        completed_at_utc=finished.isoformat(), audit_elapsed_seconds=time.perf_counter()-start,
        first_review_clock_utc=START.isoformat(),
        review_through_audit_seconds=(finished-START).total_seconds(),
        bound_inputs=sorted(inputs.values(), key=lambda r:r['path']),
        source_files=len(sources), authored_LF_witnesses=len(witnesses),
        extra_review_LF_spans=extra_spans, preserved_inputs=preserved,
        lexical_forms_source_checked=form_checks, rank_states=len(adjacency),
        rank_edges=len(edges), rank_max_path_length=max(path_lengths.values()),
        independent_entry_envelopes=entry_vectors, annotation_graphs=result_graphs,
        modular_cancellation_cases=cancellation_cases, signed_barrier_cases=barrier_cases,
        coefficient_cases=coefficient_cases, author_checker_replays=0,
        predecessor_checker_replays=0, compiler_native_prover_runs=0,
        semantic_argument_machine_proved=False,
        selected_reviewer_model='GPT-6 Astra', selected_reviewer_effort='Extra High',
        runtime_model_and_effort=None, tokens=None, cost=None)
    (HERE / 'current.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in {
        'bound_inputs','extra_review_LF_spans','preserved_inputs'}},indent=2))


if __name__ == '__main__':
    main()
