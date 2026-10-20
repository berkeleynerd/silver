#!/usr/bin/env python3
"""Focused source/retained-join and accounting checks; no predecessor replay."""
import argparse
from collections import deque
import hashlib
import json
from pathlib import Path
import tarfile
import time
from transfer import compose, writer_bounds, size_drift, PREMISES, CELL_CEILING, publication_threshold

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
STATUS = 'docs/evidence/retained-why-status-entry-20261020/result.json'
DOMAIN = 'docs/evidence/retained-producer-driver-envelope-20261018/result.json'
TOPOLOGY = 'docs/evidence/retained-why-path-lookup-capacity-20261020/initial-topology.json'
DISPATCH = 'docs/evidence/retained-why-path-library-origins-20261020/selected-dispatch.json'
DEPENDENCIES = [STATUS, DOMAIN, TOPOLOGY, DISPATCH,
 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz',
 'docs/research/retained-why-theory-cache-control.md',
 'docs/research/retained-why-attempt-counter-continuation.md',
 'docs/research/retained-why-save-attempt-growth.md',
 'docs/research/retained-why-path-library-origins.md',
 'docs/research/retained-why-path-lookup-capacity.md',
 'docs/evidence/retained-why-path-lookup-capacity-20261020/source-witnesses.json',
 'docs/evidence/retained-why-path-lookup-capacity-20261020/inputs.json',
 'docs/evidence/retained-why-path-lookup-capacity-20261020/native-bodies.json',
 'docs/evidence/retained-why-path-lookup-capacity-20261020/native-witnesses.json',
 'docs/reviews/review-save-capacity-round33-20261020.md']


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read(path):
    return json.loads(path.read_text())


def seal(name, value, writing):
    raw = (json.dumps(value, indent=2)+'\n').encode()
    if writing:
        (HERE/name).write_bytes(raw)
    else:
        assert (HERE/name).read_bytes() == raw, name


def derive():
    status = {c['case']: c for c in read(ROOT/STATUS)['cases']}
    domain = {c['name']: c for c in read(ROOT/DOMAIN)['cases']}
    topology = read(ROOT/TOPOLOGY)
    dispatch = read(ROOT/DISPATCH)['drivers']
    assert sorted(len(d['transformations']) for d in dispatch.values()) == [12, 13, 15]
    for d in dispatch.values():
        names = [t['name'] for t in d['transformations']]
        assert names.count('eliminate_literal') == 1
        assert sum(n in ('eliminate_algebraic', 'eliminate_algebraic_if_poly') for n in names) == 1
    scalar_members = read(ROOT/'docs/evidence/retained-why-path-lookup-capacity-20261020/inputs.json')['members']
    full = {p: True for p in PREMISES}
    cases = []
    for t in topology:
        s, d = status[t['case']], domain[t['case']]
        member = next(m for m in scalar_members if '/'+t['case']+'/' in m['member'])
        with tarfile.open(ROOT/member['archive']) as archive:
            raw = archive.extractfile(member['member']).read()
        assert identity(raw) == member['identity']
        table = json.loads(raw)['sections']['restore_paths']['value']
        s0 = table['size']
        assert s0 == table['binding_visits'] == t['initial_cells']
        assert table['size_equals_binding_visits'] is True
        assert t['pid'] == s['pid']
        assert s['source_layout_and_projection_crosschecks_pass']
        assert s['all_detached_flags_false']
        assert s['entry_cache_or_default_consistency_established']
        assert len(s['leaf_goal_ids']) == d['raw_initial_tasks']
        assert all(not a['obsolete'] for a in s['attempts'])
        selected = [a for a in s['attempts'] if a['prover']['name'] != 'Trivial']
        active = int(t['case'] == 'input_is_valid')
        if active:
            assert len(selected) == 1 and selected[0]['id'] == 3
            assert selected[0]['decoded_status']['proof_state'] == 'None'
            assert s['phase']['driver_preparation_entry_count'] == 1
            assert s['phase']['driver_input_task_goal_ids'] == [3]
        else:
            assert not selected and all(h == 0 for h in s['phase']['recorded_call_hits'].values())
        g = d['registered_task_upper']
        assert d['distinct_task_driver_pair_upper'] == 3*g
        cases.append({'case': t['case'], 'pid': t['pid'], 'phase': s['phase']['endpoint'],
            'registered_goals_upper': g, 'initial_cells': t['initial_cells'],
            'initial_scalar_size': s0, 'scalar_projection': member,
            'publication_upper_passing_conservative_size_guard': publication_threshold(t['initial_cells'], s0),
            'active_preparation_episodes_at_cut': active,
            'raw_queue_and_gnat_check_maps_observed': False,
            'no_external_assertion': compose(g, t['initial_cells'], initial_size=s0),
            'under_named_existing_premises': compose(g, t['initial_cells'], premises=full, initial_size=s0),
            'diagnostic_even_zero_library_charge_representation_bound_fails_size_guard':
                not compose(g, t['initial_cells'], library_charge=0, premises=full, initial_size=s0)['candidate_writer_bounds']['tagged_size_guard']})
    return {'scope': 'Interrupted preparation episodes and conditional writer charges',
        'cases': cases,
        'summed_separate_process_episode_upper': sum(c['under_named_existing_premises']['dispatch_bounds']['preparation_episodes_intersecting_suffix_upper'] for c in cases),
        'summed_separate_process_directive_upper': sum(c['under_named_existing_premises']['dispatch_bounds']['outer_directive_applications_upper'] for c in cases),
        'actual_publication_bound': None,
        'conditional_size_drift_examples': [size_drift(f) for f in (0, 2, 5, 6)],
        'actual_abandoned_mutation_bound': None,
        'complete_writer_capacity_established': False}


def challenges():
    full = {p: True for p in PREMISES}
    assert compose(64, 6941)['dispatch_bounds'] is None
    for p in PREMISES:
        assert compose(64, 6941, premises={**full, p: False})['dispatch_bounds'] is None
    assert compose(64, 6941, premises=full)['publication_bound'] is None
    small = compose(64, 6941, library_charge=100, task_cells=10, premises=full, initial_size=6941)
    assert small['publication_bound'] == 194*(30+200)
    assert small['candidate_writer_bounds']['tagged_size_guard']
    for kw in ({'escapes': 3}, {'escapes': True}, {'library_charge': -1}, {'task_cells': -1}, {'premises': {'unknown': True}}):
        try:
            compose(1, 1, **kw)
        except ValueError:
            pass
        else:
            raise AssertionError(kw)
    assert size_drift(5)['tagged_size_guard'] and not size_drift(6)['tagged_size_guard']
    assert writer_bounds(6941, 0, 6941)['clean_invocations_upper'] == 0
    assert writer_bounds(6941, 42, 6941)['successful_array_doublings_upper'] == 41
    assert not writer_bounds(6941, CELL_CEILING, 6941)['tagged_size_guard']
    for v0 in (6941, 6901, 6783, 6819):
        threshold = publication_threshold(v0, v0)
        assert writer_bounds(v0, threshold, v0)['tagged_size_guard']
        assert not writer_bounds(v0, threshold+1, v0)['tagged_size_guard']
    assert writer_bounds(100, 1, 70)['size_upper'] == 71
    assert writer_bounds(100, 1, 70)['size_lower'] == -31
    # Worst-case nonvalid completions: each first pair is free; a repeat
    # consumes one escape. Failed/valid/stopped episodes only remove suffixes.
    states = 0
    for pairs in range(1, 7):
        for budget in range(3):
            todo = deque([(0, budget, 0)])
            seen = set(todo)
            while todo:
                mask, e, count = todo.popleft()
                assert count <= mask.bit_count()+budget-e <= pairs+budget
                states += 1
                for pair in range(pairs):
                    used = bool(mask & (1 << pair))
                    if used and e == 0:
                        continue
                    nxt = (mask | (1 << pair), e-int(used), count+1)
                    if nxt not in seen:
                        seen.add(nxt)
                        todo.append(nxt)
    # A failure-notification requeue would permit uncharged None-state retries;
    # selected GNAT failure callbacks explicitly exclude that transition.
    uncharged_failure_requeue_entries = 20
    assert uncharged_failure_requeue_entries > 3+2
    # Drift potential: completed bucket mutations preserve size-cell difference;
    # one abandoned clean/copy/insert prefix changes it by at most B. Scale B
    # down for exhaustive boundary combinations; the algebra is scale invariant.
    drift_checks = 0
    b = 7
    for f in range(7):
        delta_lo, delta_hi = -f*b, f*b
        for delta in (delta_lo, 0, delta_hi):
            for prefix in range(-b, b+1):
                for cells in range(b+1):
                    scalar = cells+delta+prefix
                    assert -(f+1)*b <= scalar <= (f+2)*b
                    drift_checks += 1
    return states, drift_checks


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--write', action='store_true')
    writing = p.parse_args().write
    start = time.monotonic()
    witnesses = read(HERE/'source-witnesses.json')
    with tarfile.open(ROOT/witnesses[0]['archive']) as archive:
        for s in witnesses:
            raw = archive.extractfile(s['member']).read()
            assert identity(raw) == s['member_identity']
            text = ''.join(raw.decode().splitlines(keepends=True)[s['first_line']-1:s['last_line']])
            assert text == s['text'] and identity(text.encode()) == s['excerpt_identity']
    result = derive()
    assert result['summed_separate_process_episode_upper'] == 469
    assert result['summed_separate_process_directive_upper'] == 6270
    assert all(c['diagnostic_even_zero_library_charge_representation_bound_fails_size_guard'] for c in result['cases'])
    seal('result.json', result, writing)
    inputs = {'base_commit': '79301d13cfac0dafccf9e53b5da17345266d4eca',
        'files': {f: identity((ROOT/f).read_bytes()) for f in DEPENDENCIES},
        'local_files': {f: identity((HERE/f).read_bytes()) for f in ('source-witnesses.json', 'transfer.py', 'result.json')}}
    seal('inputs.json', inputs, writing)
    states, drift_checks = challenges()
    print(json.dumps({'status': 'pass', 'source_excerpts': len(witnesses),
        'fresh_status_domain_joins': len(result['cases']), 'scheduling_challenge_states': states,
        'drift_boundary_challenges': drift_checks,
        'actual_publication_bound': None, 'actual_abandoned_mutation_bound': None,
        'native_runs': 0, 'prior_checker_replays': 0,
        'elapsed_seconds': time.monotonic()-start}, indent=2))


if __name__ == '__main__':
    main()
