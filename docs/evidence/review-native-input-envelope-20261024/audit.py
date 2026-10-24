#!/usr/bin/env python3
"""Independent finite corroboration of the input envelope; no checker replay."""
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
PACKET = ROOT / 'docs/evidence/retained-general-native-capacity-20261024/input-fold'
FREEZE = '4f518ea3151ad1d11c6c3654c84dd730bc4e2aff'
PREVIOUS = '0ed7c10db8e806c4ee05c3c56fa6dfe54f0d132e'
START = datetime(2026, 10, 24, 5, 33, 22, tzinfo=timezone.utc)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(path.read_bytes())


def frozen(commit, path):
    return subprocess.check_output(['git', 'show', f'{commit}:{path}'], cwd=ROOT)


def main():
    started = time.perf_counter()
    inputs = {}
    preserved = []
    for name in ('inputs.json', 'packet-manifest.json'):
        for row in read(PACKET / name)['files']:
            data = (ROOT / row['path']).read_bytes()
            assert len(data) == row['bytes'] and sha(data) == row['sha256']
            assert frozen(FREEZE, row['path']) == data
            inputs[row['path']] = row
            if name == 'inputs.json':
                assert frozen(PREVIOUS, row['path']) == data
                preserved.append(row['path'])
    for path in PACKET.iterdir():
        if path.is_file():
            data = path.read_bytes()
            rel = str(path.relative_to(ROOT))
            assert frozen(FREEZE, rel) == data
            inputs[rel] = dict(path=rel, bytes=len(data), sha256=sha(data))

    sources = {}
    sm = read(PACKET / 'source-manifest.json')
    assert sm['gcc_commit'] == '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
    for archive in sm['archives']:
        path = PACKET / archive['path']
        assert sha(path.read_bytes()) == archive['sha256']
        rows = [r for r in sm['files'] if r['archive'] == archive['path']]
        with tarfile.open(path) as tf:
            members = tf.getmembers()
            assert all(m.isfile() for m in members)
            assert sorted(m.name for m in members) == sorted(r['path'] for r in rows)
            for row in rows:
                data = tf.extractfile(row['path']).read()
                assert len(data) == row['bytes'] and sha(data) == row['sha256']
                origin = read(ROOT / row['retained_identity'])
                if 'source_sha256_key' in row:
                    assert origin['source_commit'] == sm['gcc_commit']
                    expected = origin['source_sha256'][row['source_sha256_key']]
                else:
                    expected, = [r['sha256'] for r in origin['files']
                                 if r['path'] == row['path']]
                assert expected == sha(data)
                assert row['path'] not in sources
                sources[row['path']] = data

    def span(name, low, high):
        return b'\n'.join(sources[name].split(b'\n')[low-1:high]) + b'\n'

    witnesses = read(PACKET / 'source-witnesses.json')['witnesses']
    assert len({r['id'] for r in witnesses}) == len(witnesses)
    for r in witnesses:
        assert sha(span(r['source'], r['first_lf_line'], r['last_lf_line'])) == r['sha256']
    extra_spans = []
    for name, lo, hi in [('gcc/fold-const.cc', 6053, 6254),
                         ('gcc/fold-const.cc', 9774, 9878),
                         ('gcc/fold-const.cc', 9977, 10403),
                         ('gcc/match.pd', 7070, 7192),
                         ('gcc/match.pd', 8426, 8439),
                         ('gcc/match.pd', 8655, 8687),
                         ('gcc/match.pd', 9683, 9736)]:
        extra_spans.append(dict(source=name, first_lf_line=lo,
                                last_lf_line=hi, sha256=sha(span(name, lo, hi))))
    host_config = (ROOT / 'docs/evidence/retained-backend-capacity-20261018/selected-auto-host.h').read_text()
    assert '/* #undef ENABLE_FOLD_CHECKING */' in host_config

    # Literal correspondence, without loading the author's lexical parser.
    # Completeness and the semantic exclusions remain reviewed source arguments.
    matcher = read(PACKET / 'matcher-audit.json')
    lines = sources['gcc/match.pd'].decode().split('\n')
    form_counts = {}
    for kind, expected in [('binary',151), ('conversion',19),
                           ('conditional',65), ('comparison',52)]:
        rows = matcher[kind]['root_patterns']
        assert len(rows) == expected
        for r in rows:
            assert '\n'.join(lines[r['line']-1:]).lstrip().startswith(r['source'])
            assert r['pattern'] in r['source'] and r['disposition']
        form_counts[kind] = len(rows)

    # Detect cycles independently of the author's integer-rank inequalities.
    rank = read(PACKET / 'rank.json')
    graph = {name: [] for name in rank['rank']}
    for a,b in rank['edges']:
        graph[a].append(b)

    def longest(name, active=()):
        assert name not in active
        return max([0] + [1+longest(c, active+(name,)) for c in graph[name]])

    lengths = {name: longest(name) for name in graph}

    # Independently composed candidate vectors (C,U,B,T), modeling the
    # manually reviewed branches, not executing GCC or proving correspondence.
    candidates = {
        'shift_minus_with_clear': (2,0,1,0),
        'distributed_subtract': (0,0,1,1),
        'distributed_plus_with_clear': (2,0,1,1),
        'distributed_mult_with_clear': (2,0,1,1),
        'mult_one_non_lvalue': (0,1,0,0),
        'constant_calculation': (1,0,0,0),
        'terminal_binary_with_clear': (1,0,1,0),
    }
    assert all(all(a <= b for a,b in zip(v,(2,1,1,1))) for v in candidates.values())
    conversion_candidates = [(0,0,0,0), (0,1,0,0), (1,0,0,0), (1,1,0,1)]
    assert all(all(a <= b for a,b in zip(v,(1,1,0,1))) for v in conversion_candidates)

    # Explicit graph identities preserve sharing; occurrence recursion must
    # count the declarations again through the comparison.
    dag = {'L':(), 'H':(), 'one':(), 'zero':(), 'eight':(),
           'X':('L',), 'Y':('H',), 'difference':('Y','X'),
           'length':('difference','one'), 'wide':('length',),
           'product':('wide','eight'), 'comparison':('H','L'),
           'conditional':('comparison','product','zero')}

    def measure(name):
        children = [measure(c) for c in dag[name]]
        return (max([0]+[h+1 for h,q in children]), 1+sum(q for h,q in children))

    def reachable(name):
        return {name}.union(*(reachable(c) for c in dag[name]))

    annotations = []
    for root, expected in [('product',(5,10,10)), ('conditional',(6,15,13))]:
        height, charge = measure(root)
        vertices = len(reachable(root))
        assert (height,charge,vertices) == expected
        # Converted inner children are PLUS and MINUS, not matching retries.
        annotations.append(dict(root=root, height=height, Q=charge,
                                vertices=vertices, active_depth=height+1,
                                converted_inner_retries=0))

    def arithmetic(low, high, width):
        mod = 1 << width
        x, y = low % mod, high % mod
        z = y if high >= low else (x-1) % mod
        length = (1 + (z-x) % mod) % mod
        rewritten = ((y-x+1) % mod) if high >= low else 0
        assert length == rewritten == max(0, high-low+1)
        assert 8*length % 8 == 0
        assert (((x-1) % mod)-x) % mod == mod-1

    reduced_cases = 0
    for scalar_width in range(2,7):
        values = range(-(1 << (scalar_width-1)), 1 << (scalar_width-1))
        for low,high in itertools.product(values,repeat=2):
            arithmetic(low,high,scalar_width+2)
            reduced_cases += 1
    boundary_values = sorted({-(1<<31), -(1<<31)+1, (1<<31)-2, (1<<31)-1}
                            | {s*(2**p+d) for s in (-1,1)
                               for p in (0,4,15,30) for d in (-1,0,1)})
    for low,high in itertools.product(boundary_values,repeat=2):
        arithmetic(low,high,64)
        assert 8*max(0,high-low+1) < 1 << 128
    # This prevents substituting unsigned endpoint order in the argument.
    assert (0 >= -1) and not (0 % (1<<64) >= -1 % (1<<64))

    ledger = read(PACKET / 'ledger.json')
    totals = {key:sum(r['entries_per_Ba']*r['per_entry'][key]
                     for r in ledger['array_rows'])
              for key in ('constants','unary','binary','ternary')}
    assert totals == dict(constants=49,unary=34,binary=18,ternary=24)
    values = (0,1,2,7,127,1024,2**31-1,2**63-1)
    for bs,ba in itertools.product(values,repeat=2):
        c,u,b,t,v = 49*ba,2*bs+34*ba,18*ba,24*ba,2*bs
        helper = 40*c+32*u+40*b+48*t+256*v
        q = 2*ba*15
        assert helper == 576*bs+4920*ba
        assert u+2*b+3*t == 2*bs+142*ba
        assert helper+q*(32*40+32+16) == 576*bs+44760*ba
        assert c+32*q == 1009*ba and u+q == 2*bs+64*ba
        assert 8*(3*q)+4*(11*q)+32*q == 3000*ba
    for db in values:
        assert 2*32*db+24*db+72*db == 160*db
        assert sum(512*((n+511)//512) for n in (32,32,24,72))*db == 2048*db
    assert 83+49+32*30 == 1092
    current = read(PACKET / 'current.json')
    assert current['H_Input_upper'] == 6 and current['Q_per_Input_root_upper'] == 15
    assert current['helper_plus_annotation']['raw_caller_bytes'] == '576Bs+44760Ba'
    for field in ('full_helper_workspace_closed', 'enclosing_fat_pointer_closed',
                  'concat_initializer_transfer_closed', 'all_dynamic_F_Q_closed',
                  'complete_native_capacity_result'):
        assert current[field] is False

    finished = datetime.now(timezone.utc)
    result = dict(status='pass', reviewed_author_commit=FREEZE,
                  accepted_previous_author_commit=PREVIOUS, gcc_commit=sm['gcc_commit'],
                  host=f'{platform.system()} {platform.machine()}',
                  first_review_clock_utc=START.isoformat(),
                  completed_at_utc=finished.isoformat(),
                  review_through_audit_seconds=(finished-START).total_seconds(),
                  audit_elapsed_seconds=time.perf_counter()-started,
                  bound_inputs=sorted(inputs.values(),key=lambda r:r['path']),
                  preserved_inputs=preserved, source_files=len(sources),
                  authored_LF_witnesses=len(witnesses), extra_review_LF_spans=extra_spans,
                  lexical_forms_source_checked=form_counts, rank_states=len(graph),
                  rank_edges=len(rank['edges']), rank_max_path_length=max(lengths.values()),
                  independent_size_entry_candidates=candidates,
                  independent_conversion_entry_candidates=conversion_candidates,
                  annotation_graphs=annotations, reduced_signed_cases=reduced_cases,
                  signed32_boundary_cases=len(boundary_values)**2,
                  coefficient_cases=len(values)**2, template_coefficient_cases=len(values),
                  author_checker_replays=0, predecessor_checker_replays=0,
                  compiler_native_prover_runs=0, semantic_argument_machine_proved=False,
                  selected_reviewer_model='GPT-6 Astra', selected_reviewer_effort='Extra High',
                  runtime_model_and_effort=None, tokens=None, cost=None)
    (HERE/'current.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in {
        'bound_inputs','preserved_inputs','extra_review_LF_spans'}},indent=2))


if __name__ == '__main__':
    main()
