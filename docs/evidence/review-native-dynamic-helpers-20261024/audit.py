#!/usr/bin/env python3
"""Independent identity, branch-trace and arithmetic corroboration; no GCC run."""
import hashlib
import importlib.util
import itertools
import json
import platform
import random
import re
import subprocess
import sys
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = ROOT / 'docs/evidence/retained-general-native-capacity-20261024/dynamic-helpers'
FREEZE = '26bd01de61242d49f4680d609b38d09e3a51925f'
PREDECESSOR = '99734327fd77d426fead054d7ba0e12999b00d8a'
START = datetime(2026, 10, 24, 4, 28, 19, tzinfo=timezone.utc)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read_json(path):
    return json.loads(path.read_bytes())


def git_bytes(commit, path):
    return subprocess.check_output(['git', 'show', f'{commit}:{path}'], cwd=ROOT)


def main():
    started = time.perf_counter()
    bound_inputs = {}
    for manifest in ('inputs.json', 'packet-manifest.json'):
        for row in read_json(PACKET / manifest)['files']:
            data = (ROOT / row['path']).read_bytes()
            assert len(data) == row['bytes'] and digest(data) == row['sha256']
            assert git_bytes(FREEZE, row['path']) == data
            bound_inputs[row['path']] = row
    for path in sorted(PACKET.iterdir()):
        if path.is_file():
            rel = str(path.relative_to(ROOT))
            data = path.read_bytes()
            assert git_bytes(FREEZE, rel) == data
            bound_inputs[rel] = {'path': rel, 'bytes': len(data), 'sha256': digest(data)}

    manifest = read_json(PACKET / 'source-manifest.json')
    source = {}
    for item in manifest['archives']:
        path = PACKET / item['path']
        assert digest(path.read_bytes()) == item['sha256']
        rows = [row for row in manifest['files'] if row['archive'] == item['path']]
        with tarfile.open(path) as archive:
            members = archive.getmembers()
            assert all(member.isfile() for member in members)
            assert sorted(member.name for member in members) == sorted(row['path'] for row in rows)
            for row in rows:
                data = archive.extractfile(row['path']).read()
                assert len(data) == row['bytes'] and digest(data) == row['sha256']
                identity = read_json(ROOT / row['retained_identity'])
                origin = [r for r in identity['files'] if r['path'] == row['path']]
                assert len(origin) == 1 and origin[0]['sha256'] == digest(data)
                source[row['path']] = data
    witnesses = read_json(PACKET / 'source-witnesses.json')['witnesses']
    for row in witnesses:
        lines = source[row['source']].split(b'\n')
        data = b'\n'.join(lines[row['first_lf_line'] - 1:row['last_lf_line']]) + b'\n'
        assert digest(data) == row['sha256']
    extra_spans = []
    for name, lo, hi in [('gcc/tree.cc', 5194, 5255),
                         ('gcc/fold-const.cc', 11117, 11138),
                         ('gcc/ada/gcc-interface/decl.cc', 9317, 9521)]:
        data = b'\n'.join(source[name].split(b'\n')[lo-1:hi]) + b'\n'
        extra_spans.append({'source': name, 'first_lf_line': lo, 'last_lf_line': hi,
                            'sha256': digest(data)})

    decl = source['gcc/ada/gcc-interface/decl.cc'].decode()
    body = decl.split('annotate_value (tree gnu_size)\n{')[1].split('\n/* Given GNAT_ENTITY')[0]
    cuts = {'INTEGER_CST', 'COMPONENT_REF', 'PARM_DECL', 'VAR_DECL', 'CALL_EXPR'}
    handled = set(re.findall(r'^\s*case ([A-Z_]+)\s*:', body, re.M)) - cuts
    handled |= {'NOP_EXPR', 'CONVERT_EXPR'}
    codes = {c: int(a) for c, a in re.findall(
        r'DEFTREECODE\s*\(\s*(\w+),\s*"[^"]+",\s*\w+,\s*(\d+)\)',
        source['gcc/tree.def'].decode())}
    assert len(handled) == 31 and max(codes[c] for c in handled) == 3
    assert {c for c in handled if codes[c] == 3} == {'COND_EXPR'}
    assert 'case SAVE_EXPR' not in body and 'case PLACEHOLDER_EXPR' not in body
    assert 'if (List_Representation_Info >= 3 || type_annotate_only)' in body

    preserved = []
    for name in ('check-result.json', 'string-pack-current.json', 'helper-joins/current.json',
                 'helper-joins/README.md'):
        rel = 'docs/evidence/retained-general-native-capacity-20261024/' + name
        assert git_bytes(PREDECESSOR, rel) == (ROOT / rel).read_bytes()
        preserved.append(rel)

    # Import only the two capped arithmetic functions; never call author check().
    spec = importlib.util.spec_from_file_location('reviewed_arithmetic', PACKET / 'check.py')
    author = importlib.util.module_from_spec(spec)
    sys.dont_write_bytecode = True
    spec.loader.exec_module(author)
    exact = [1]
    for _ in range(192):
        exact.append(3 * exact[-1] + 2)
    arithmetic_cases = 0
    rng = random.Random(840201)
    for h, b in enumerate(exact):
        caps = {0, 1, 2, max(0, b - 2), b - 1, b, b + 1, b + 2}
        caps.update(rng.getrandbits(k) for k in (4, 16, 31, 32, 63, 64, 128, 256))
        for cap in caps:
            assert author.charge_capped(h, cap) == min(b, cap + 1)
            arithmetic_cases += 1
        if h:
            p = exact[h - 1]
            assert max(1 + 3*p, 2 + 3*p, 3 + p, 4 + p) <= b
    huge_cases = 0
    for h in (1 << 256, (1 << 256) + 1, (1 << 257) - 1):
        for cap in (0, 1, 2, (1 << 31)-1, (1 << 64), (1 << 256)-1):
            assert author.charge_capped(h, cap) == cap + 1
            huge_cases += 1
    family_cases = 0
    for _ in range(1000):
        roots = [(rng.randrange(17), rng.randrange(20)) for _ in range(rng.randrange(8))]
        cap = rng.getrandbits(rng.randrange(1, 64))
        assert author.sum_capped(roots, cap) == min(sum(m*exact[h] for m,h in roots), cap+1)
        family_cases += 1
    for function, args in [(author.charge_capped, (-1, 0)),
                           (author.charge_capped, (0, -1)),
                           (author.sum_capped, ([], -1)),
                           (author.sum_capped, ([(-1, 0)], 1))]:
        try:
            function(*args)
            raise AssertionError('negative input accepted')
        except ValueError:
            pass

    # Small source-shaped ordered DAGs. Each trace executes early synthetic
    # calls, failed-left retries, ordered failure exits and optional caching.
    # Numerical outcomes are abstract Booleans, not native numerical executions.
    nodes = [('CUT', (), False, False), ('CUT', (), True, False),
             ('INTEGER_CST', (), False, False), ('INTEGER_CST', (), True, False),
             ('INTEGER_CST', (), False, True), ('INTEGER_CST', (), True, True)]
    heights = [0] * len(nodes)
    def add(code, children, synth_ok=True, sign=False):
        nodes.append((code, tuple(children), synth_ok, sign))
        heights.append(1 + max(heights[c] for c in children))
        return len(nodes) - 1
    retry_root = 0
    for _ in range(6):
        inner = add('MULT_EXPR', (retry_root, 3))
        conv = add('NOP_EXPR', (inner,))
        retry_root = add('MULT_EXPR', (conv, 3))
    for _ in range(300):
        pool = [i for i,h in enumerate(heights) if h <= 4]
        a = rng.choice(pool)
        kind = rng.randrange(6)
        if kind == 0:
            add('COND_EXPR', (a, a, a))
        elif kind == 1:
            add('NOP_EXPR', (a,))
        elif kind == 2:
            add('MINUS_EXPR', (a, rng.choice(pool)))
        elif kind in (3, 4):
            add('BIT_AND_EXPR' if kind == 3 else 'PLUS_EXPR',
                (a, rng.randrange(2, 6)), bool(rng.randrange(2)))
        else:
            inner = add('MULT_EXPR', (a, rng.randrange(2, 4)), bool(rng.randrange(2)))
            conv = add('NOP_EXPR', (inner,))
            add('MULT_EXPR', (conv, rng.randrange(2, 4)), bool(rng.randrange(2)))
    trace_cases = max_calls = max_depth = 0
    for root in range(len(nodes)):
        for cache_enabled in (False, True):
            cache = set()
            counts = [0, 0]
            def visit(i, depth):
                counts[0] += 1
                counts[1] = max(counts[1], depth)
                if cache_enabled and i in cache:
                    return True
                code, children, ok, sign = nodes[i]
                if not children:
                    return ok
                if code == 'NOP_EXPR':
                    return visit(children[0], depth+1)
                ops = [False] * len(children)
                def synthetic(negate=False):
                    counts[0] += 2 if negate else 1
                    counts[1] = max(counts[1], depth+(2 if negate else 1))
                    return ok
                if code == 'BIT_AND_EXPR' and nodes[children[1]][0] == 'INTEGER_CST':
                    ops[1] = synthetic(True)
                elif code == 'PLUS_EXPR' and nodes[children[1]][0] == 'INTEGER_CST' and nodes[children[1]][3]:
                    ops[1] = synthetic()
                elif code in {'PLUS_EXPR', 'MULT_EXPR'} and nodes[children[1]][0] == 'INTEGER_CST':
                    left = nodes[children[0]]
                    if left[0] == 'NOP_EXPR':
                        inner = nodes[left[1][0]]
                        if inner[0] == code and nodes[inner[1][1]][0] == 'INTEGER_CST':
                            ops[0] = visit(inner[1][0], depth+1)
                            ops[1] = synthetic()
                for j, child in enumerate(children):
                    if not ops[j]:
                        ops[j] = visit(child, depth+1)
                        if not ops[j]:
                            return False
                if cache_enabled:
                    cache.add(i)
                return True
            visit(root, 1)
            assert counts[0] <= exact[heights[root]]
            assert counts[1] <= (heights[root]+2 if heights[root] else 1)
            if root == retry_root:
                assert counts[0] == 316 and counts[1] == 19
            trace_cases += 1
            max_calls, max_depth = max(max_calls, counts[0]), max(max_depth, counts[1])

    coefficient_cases = 0
    for qc, qd, t in itertools.product((0, 1, 2, 31, 2**31-1), repeat=3):
        gcc = (31*qc+32*qd)*40 + qd*32 + qd*16
        callback = qd*32 + (qc+3*qd+t)*8 + (5*qc+11*qd+3*t)*4
        assert gcc == 1240*qc + 1328*qd
        assert callback == 28*qc + 100*qd + 20*t
        coefficient_cases += 1

    finished = datetime.now(timezone.utc)
    result = {
        'status': 'pass', 'reviewed_commit': FREEZE,
        'accepted_predecessor_author_commit': PREDECESSOR,
        'gcc_commit': manifest['gcc_commit'],
        'platform': f'{platform.system()} {platform.machine()}',
        'completed_at_utc': finished.isoformat(),
        'audit_elapsed_seconds': time.perf_counter()-started,
        'review_start_clock_utc': START.isoformat(),
        'review_through_audit_seconds': (finished-START).total_seconds(),
        'bound_inputs': sorted(bound_inputs.values(), key=lambda r:r['path']),
        'source_files': len(source), 'author_LF_witnesses': len(witnesses),
        'additional_review_LF_spans': extra_spans,
        'handled_codes': len(handled), 'preserved_exports_and_argument': preserved,
        'saturation_comparisons': arithmetic_cases, 'huge_height_comparisons': huge_cases,
        'family_sum_comparisons': family_cases, 'synthetic_DAG_nodes': len(nodes),
        'branch_trace_cases': trace_cases, 'max_observed_trace_calls': max_calls,
        'max_observed_trace_depth': max_depth, 'coefficient_cases': coefficient_cases,
        'author_checker_replays': 0, 'predecessor_checker_replays': 0,
        'native_compiler_prover_runs': 0, 'semantic_proof_machine_checked': False,
        'selected_reviewer_model': 'GPT-6 Astra', 'selected_reviewer_effort': 'Extra High',
        'runtime_model_and_effort': None, 'tokens': None, 'cost': None,
    }
    (HERE / 'current.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in {
        'bound_inputs', 'additional_review_LF_spans', 'preserved_exports_and_argument'}}, indent=2))


if __name__ == '__main__':
    main()
