#!/usr/bin/env python3
"""Bounded package review: one archive verification; no capture/analyzer replay."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import runpy
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
PACKET = REPO / 'docs/evidence/retained-why-fixed-session-domain-20261020'
TARGET = 'c285194f00e2ffa9b3296a8a6164e2c657c7241c'
BASE = '36bbcbd3bb200edf016381ef3be61825e34d83ea'


def read(path):
    return json.loads(path.read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    started, timer = datetime.now(timezone.utc).isoformat(), time.perf_counter()
    paths = subprocess.check_output(['git', 'diff', '--name-only', BASE, TARGET],
        cwd=REPO, text=True).splitlines()
    assert len(paths) == 21
    target_identities = []
    for path in paths:
        raw = (REPO / path).read_bytes()
        assert raw == subprocess.check_output(['git', 'show', TARGET + ':' + path], cwd=REPO)
        target_identities.append(dict(path=path, **identity(raw)))
    provenance = read(PACKET / 'provenance.json')
    for row in provenance['files']:
        assert identity((PACKET / row['path']).read_bytes()) == row['identity']
    for row in provenance['repository_dependencies']:
        assert identity((REPO / row['path']).read_bytes()) == row['identity']

    completed = subprocess.run([sys.executable, '-B', str(PACKET / 'verify.py'),
        '--output', str(HERE / 'verification.json')], cwd=REPO, text=True,
        capture_output=True, check=True)
    assert not completed.stderr
    verification = read(HERE / 'verification.json')
    assert verification['status'] == 'passed'
    assert verification['archives_verified'] == 5 and verification['members_verified'] == 136
    assert verification['expanded_bytes_streamed'] == 610836367
    assert verification['analyzer_replays'] == verification['binder_analyses'] == 0

    saved = read(PACKET / 'summary.json')
    fresh = runpy.run_path(str(PACKET / 'summarize.py'))['summarize']()
    saved.pop('summary_only_elapsed_seconds')
    summary_seconds = fresh.pop('summary_only_elapsed_seconds')
    assert fresh == saved
    formula_visit_uses = 0
    checked = []
    for case in saved['cases'][:4]:
        facts = read(REPO / case['source_analysis'])
        cert = facts['full_certificate']
        for index, visit in enumerate(cert['visits']):
            assert visit['index'] == index
            if visit['detached']:
                assert visit['charge'] == 0
                continue
            task = cert['tasks'][str(visit['task'])]
            formula = lambda p: cert['formulas'][str(p)]['opened_binder_occurrences']
            explanation = formula(task['goal_formula'])
            shape = sum(formula(prop['formula']) for prop in task['propositions'])
            assert visit['explanation_upper'] == explanation
            assert visit['all_propositions_shape_upper'] == shape
            assert visit['charge'] == explanation + shape
            formula_visit_uses += 1 + len(task['propositions'])
        assert facts['B_binders'] == cert['B_binders'] == sum(v['charge'] for v in cert['visits'])
        assert facts['forest_visits'] == len(cert['visits'])
        assert len(facts['exact_session_replay']['byte_equal_files']) == 11
        checked.append(dict(case=case['case'], pid=case['pid'], B_binders=facts['B_binders'],
            forest_visits=facts['forest_visits'], distinct_formulas=facts['distinct_formulas'],
            sequential_reads=facts['exact_session_replay']['sequential_reads']))
    assert sum(case['forest_visits'] for case in saved['cases']) == 161
    assert saved['cases'][4]['phase'] == 'first-inline entry'
    assert saved['new_native_cases'] == 4 and saved['reused_prior_cases'] == 1
    assert saved['cases'][4]['pid'] == 97103 and saved['cases'][4]['B_binders'] == 966
    for key in ('ordinary_ending_capacity_established', 'all_pair_preparation_capacity_established',
            'issue153_complete', 'deterministic_input_graph_universalized', 'B966_transferred_to_other_processes'):
        assert saved[key] is False

    # Normalize exactly the reviewed helper extraction and its call sites.
    # Everything after the identity lookups, including replay and counting,
    # must remain byte-identical to the preserved executed analyzer.
    original = (PACKET / 'analyze-original.py').read_text()
    portable = (PACKET / 'analyze.py').read_text()
    helper = portable[portable.index('def verify_input_identities('):portable.index('class Reader:')]
    expected = original.replace('class Reader:', helper + 'class Reader:', 1)
    expected = expected.replace(
        "    assert identity(capture.parent / case['argv'][-1]) == plan['file_identities'][str(capture.parent / case['argv'][-1])]\n",
        '    input_path, observer_path = verify_input_identities(capture, plan, case)\n', 1)
    expected = expected.replace(
        "    observer_path = capture.parent.parent / 'session_observer.py'\n"
        "    assert identity(observer_path) == plan['file_identities'][str(observer_path)]\n", '', 1)
    expected = expected.replace("'input_json': identity(capture.parent / case['argv'][-1]),",
        "'input_json': identity(input_path),", 1)
    assert portable == expected
    result = dict(status='passed', target=TARGET, base=BASE,
        reviewer_selection=dict(model='GPT-6 Astra', effort='Extra High', runtime_confirmation=False),
        host=platform.platform(), started_UTC=started,
        finished_UTC=datetime.now(timezone.utc).isoformat(), elapsed_seconds=time.perf_counter()-timer,
        exact_target_files=target_identities, provenance_file_identities=len(provenance['files']),
        dependency_identities=len(provenance['repository_dependencies']),
        verify_executions=1, verify_elapsed_seconds=verification['elapsed_seconds'],
        summary_equal_except_timing=True, summary_elapsed_seconds=summary_seconds,
        certificates=checked, saved_formula_occurrence_contributions_checked=formula_visit_uses,
        five_forest_visits=161, portable_change_confined_to_identity_lookup=True,
        analyzer_replays=0, binders_recomputed=0, native_executions=0, proof_executions=0,
        whole_future_input_domain_established=False, issue153_complete=False,
        token_and_cost_measurements=None)
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: result[key] for key in ('status', 'verify_elapsed_seconds',
        'summary_elapsed_seconds', 'saved_formula_occurrence_contributions_checked', 'elapsed_seconds')}))


if __name__ == '__main__':
    main()
