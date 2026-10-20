#!/usr/bin/env python3
"""One focused replay and independent boundary/premise checks, without native work."""
from collections import deque
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
PACKET = REPO / 'docs/evidence/retained-why-ordinary-ending-control-20261020'
TARGET = 'f4425cc0b0ae2cf81596354efec38d7ecb8f8385'
BASE = '1f510363e40a7c18558743bef0c28f41d06f83db'


def protocol(ignore_commits):
    """Independent abstract exploration; a third-save witness is a stopping cut.

    Not native/source refinement. Removing ignore demonstrates that the bound
    cannot be reused without that premise. Pre-save failure can return to idle.
    """
    initial = [('idle', ignored, bit, 0) for ignored in (False, True) for bit in (0, 1)]
    seen, work = set(initial), deque(initial)
    while work:
        phase, ignored, pending, saves = work.popleft()
        if saves == 3:
            return dict(third_save_reachable=True, max_saves_observed=3)
        next_states = []
        if phase in ('idle', 'selected') and not ignored:
            next_states.append((phase, ignored, 1, saves))
        if phase == 'idle' and pending:
            next_states.append(('selected', ignored, 0, saves))
        elif phase == 'selected':
            next_states.append(('blocked', ignored, pending, saves))
        elif phase == 'blocked':
            next_states.extend([('idle', ignored, pending, saves),
                ('committed', ignored or ignore_commits, pending, saves)])
        elif phase == 'committed':
            next_states.extend([('idle', ignored, pending, saves),
                ('saving', ignored, pending, saves + 1)])
        elif phase == 'saving':
            next_states.append(('idle', ignored, pending, saves))
        for state in next_states:
            if state not in seen:
                seen.add(state)
                work.append(state)
    return dict(third_save_reachable=False, max_saves_observed=max(s[3] for s in seen))


def main():
    start, started = time.perf_counter(), datetime.now(timezone.utc).isoformat()
    changed = subprocess.check_output(
        ['git', 'diff', '--name-only', BASE, TARGET], cwd=REPO, text=True).splitlines()
    assert len(changed) == 10
    identities = []
    for path in changed:
        raw = (REPO / path).read_bytes()
        assert raw == subprocess.check_output(['git', 'show', TARGET + ':' + path], cwd=REPO)
        identities.append(dict(path=path, bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest()))

    run = subprocess.run([sys.executable, '-B', str(PACKET / 'check.py')],
        cwd=REPO, text=True, capture_output=True, check=True)
    assert not run.stderr
    author_check = json.loads(run.stdout)
    api = runpy.run_path(str(PACKET / 'transfer.py'))
    transfer, tagged, string = api['transfer'], api['TAGGED_MAX'], api['STRING_MAX']
    fields = ('binders', 'shape_insertions', 'apn_visits', 'shape_bytes')
    ready = dict(signal_protocol_established=True, ordinary_source_transfer_established=True,
        remaining_signals=2)
    cases = 0
    for k in (0, 1, 2):
        for field in fields:
            limit = string if field == 'shape_bytes' else tagged
            for value in (0, limit // (1 + k), limit // (1 + k) + 1):
                r = transfer(**dict(ready, remaining_signals=k), **{field: value})
                assert r['mathematical_upper'][field] == (1 + k) * value
                assert r['scalar_product_guards'][field] is ((1 + k) * value <= limit)
                assert all(r['mathematical_upper'][other] is None for other in fields if other != field)
                assert all(r[key] is False for key in ('actual_forest_join_established',
                    'shape_dictionary_consistency_established', 'complete_save_capacity_established',
                    'complete_identifier_counter_established', 'whole_pipeline_capacity_established'))
                cases += 1
    for premise in ('signal_protocol_established', 'ordinary_source_transfer_established'):
        for value in (None, False, 0, 1, 'true'):
            r = transfer(**dict(ready, **{premise: value}), **{field: 1 for field in fields})
            assert r['save_traversals_upper'] is None
            assert all(v is None for v in r['mathematical_upper'].values())
            assert all(v is None for v in r['scalar_product_guards'].values())
            cases += 1
    for field in fields + ('remaining_signals',):
        for value in (-1, True, 1.0, '1'):
            try:
                transfer(**dict(ready, **{field: value}))
            except ValueError:
                pass
            else:
                raise AssertionError((field, value))
            cases += 1

    established, removed = protocol(True), protocol(False)
    assert established == dict(third_save_reachable=False, max_saves_observed=2)
    assert removed == dict(third_save_reachable=True, max_saves_observed=3)
    # Deliberately invalid resumption after nested clear: demonstrates why
    # entry position cannot be silently dropped without the no-return proof.
    old_position, outer_append, nested_append = 100, 1, 1
    stale_resumed_position = old_position + outer_append
    charged_post_clear_bytes = outer_append + nested_append
    assert stale_resumed_position > charged_post_clear_bytes
    result = dict(status='passed', target=TARGET, base=BASE,
        reviewer_selection=dict(model='GPT-6 Astra', effort='Extra High', runtime_confirmation=False),
        host=platform.platform(), started_UTC=started,
        finished_UTC=datetime.now(timezone.utc).isoformat(), elapsed_seconds=time.perf_counter()-start,
        exact_target_files=identities, focused_checker_executions=1, focused_checker=author_check,
        independent_transfer_cases=cases, signal_protocol_abstract=established,
        ignore_premise_removed_abstract=removed,
        forbidden_Buffer_resumption_counterexample=dict(old_position=old_position,
            nested_post_clear_bytes=nested_append, outer_append_bytes=outer_append,
            stale_position=stale_resumed_position, total_new_bytes=charged_post_clear_bytes,
            interpretation='abstract witness if no-return premise is removed, not an actual execution'),
        source_refinement_machine_proved=False, actual_forest_join_established=False,
        complete_save_capacity_established=False, native_executions=0, proof_executions=0,
        broad_suite_executions=0, token_and_cost_measurements=None)
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(status='passed', exact_target_files=len(changed),
        independent_transfer_cases=cases, focused_checker_seconds=author_check['check_seconds'],
        elapsed_seconds=result['elapsed_seconds'])))


if __name__ == '__main__':
    main()
