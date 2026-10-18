#!/usr/bin/env python3
"""Replay fresh Per_Check/no-step-overlay prefix evidence; no native execution.

This checks numeric evidence and common-input joins. Source reachability,
first-event reasoning and external runtime contracts remain inspected premises.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import struct
import subprocess
import sys
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EVIDENCE = HERE.parent
LIMIT = 2**62 - 1


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def archive(path):
    with tarfile.open(path) as stream:
        files = [m for m in stream.getmembers() if m.isfile()]
        assert len(files) == len({m.name for m in files})
        return {m.name: stream.extractfile(m).read() for m in files}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    manifest = json.loads((HERE / 'identity.json').read_bytes())
    for path, expected in manifest['dependencies'].items():
        assert identity((REPO / path).read_bytes()) == expected, path
    raw = archive(HERE / 'observations.tar.gz')
    assert identity((HERE / 'observations.tar.gz').read_bytes()) == manifest['archive']['identity']
    assert {n: identity(b) for n, b in raw.items()} == manifest['archive']['members']
    get = lambda path: json.loads(raw[path])
    prior = EVIDENCE / 'retained-producer-prefix-gc-20261018'
    spec = importlib.util.spec_from_file_location('gc_component', prior / 'check.py')
    gc = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(gc)
    counts_dir = EVIDENCE / 'retained-producer-prefix-counts-20261018'
    old = archive(counts_dir / 'observations.tar.gz')
    old_get = lambda path: json.loads(old[path])
    old_plan = old_get('plan.json')
    old_id = json.loads((counts_dir / 'identity.json').read_bytes())
    plan = get('plan.json')
    root = manifest['capture_root']
    old_root = old_id['capture_root']
    assert plan['source_revision'] == old_plan['source_revision'] == manifest['why3_revision']
    for key in ('runtime_candidate_revision', 'guards', 'protected_start', 'endpoint',
                'state_fields', 'arithmetic_sites'):
        assert plan[key] == old_plan[key]
    assert plan['guards'] == list(gc.GUARDS)
    assert [c['name'] for c in plan['inputs']] == list(gc.CASES)
    for path, expected in old_plan['file_identities'].items():
        assert plan['file_identities'][path.replace(old_root, root)] == expected
    for filename in ('run.py', 'probe.py'):
        assert identity(raw[filename]) == plan['file_identities'][root + '/' + filename]

    # Reuse the established source/identity joins; do not reuse numeric bounds
    # as if configuration changes preserved tags, sharing or memoization.
    for relative in manifest['replay_checkers']:
        subprocess.run([sys.executable, str(REPO / relative)], cwd=REPO,
                       check=True, stdout=subprocess.DEVNULL)

    response = EVIDENCE / 'retained-producer-response-20261018'
    projection = json.loads((response / 'driver-projection.json').read_bytes())
    overlay_names = {'why3.conf', 'cvc5_gnatprove.drv', 'silver_cvc5_no_steps.gen',
                     'z3_gnatprove.drv', 'alt_ergo_gnatprove_smt2.drv'}
    assert set(plan['required_overlay_paths']) == {root + '/overlay/' + n for n in overlay_names}
    assert set(plan['selected_driver_closure']) == set(projection['import_closure'])
    assert len(plan['selected_driver_closure']) == 14
    for name in overlay_names:
        data = raw['overlay/' + name]
        old_name = 'cvc5.gen' if name == 'silver_cvc5_no_steps.gen' else name
        expected = (response / 'proposed-driver-overlay' / old_name).read_bytes()
        if name == 'cvc5_gnatprove.drv':
            assert expected.count(b'import "cvc5.gen"') == 1
            expected = expected.replace(b'import "cvc5.gen"', b'import "silver_cvc5_no_steps.gen"')
        assert data == expected
        assert identity(data) == plan['file_identities'][root + '/overlay/' + name]
        assert b'infer' not in data and b'[#' not in data
        assert not re.search(rb'^steps\s', data, re.M)
    assert raw['overlay/why3.conf'] == b'[main]\nmagic = 14\n'
    assert 'overlay/cvc5.gen' not in raw
    resolution = get('driver-resolution.json')
    assert set(resolution) == set(plan['selected_driver_closure'].values())
    for path, row in resolution.items():
        assert row['identity'] == plan['file_identities'][path]
        assert all(len(i['candidates']) == 1 and i['candidates'][0] in resolution for i in row['imports'])
    observer = plan['observer']
    assert (observer['symbol'], observer['offset'], observer['static_address']) == ('caml_sys_open', 208, 0x9d4700)
    assert observer['first32'] == '4863d8e808eafeff4889efe8903effff83fbff743b488b05ecaf5d004c89a020'

    dimensions = json.loads((prior / 'dimensions-inputs.json').read_bytes())
    dim_sources = archive(prior / 'dimensions-sources.tar.gz')
    text_by_path = {p: dim_sources[r['member']] for p, r in dimensions['installed_text'].items()}
    text_by_path.update({root + '/' + n: b for n, b in raw.items() if n.startswith('overlay/')})
    driver_dir = Path(plan['installed_driver_directory'])
    for path, row in resolution.items():
        data = text_by_path[path]
        assert identity(data) == row['identity']
        parent = Path(path).parent
        dirs = [parent] if parent == driver_dir else [parent, driver_dir]
        imports = []
        for imported in re.findall(rb'^import "([^"]+)"', data, re.M):
            imported = imported.decode()
            matches = [str(d / imported) for d in dirs if str(d / imported) in text_by_path]
            assert len(matches) == 1
            imports.append(dict(name=imported, candidates=matches))
        assert imports == row['imports']
    static_bytes = 0
    for path, row in dimensions['images'].items():
        assert row['identity'] == plan['file_identities'][path]
        static_bytes += row['load_memory_bytes']
    static_words = (static_bytes + 7) // 8
    texts = {r['member']: dim_sources[r['member']] for r in dimensions['installed_text'].values()}
    texts.update({n: b for n, b in raw.items() if n.startswith('overlay/')})
    assert len(texts) == 170
    assert all(b'infer' not in b and b'[#' not in b for b in texts.values())
    max_lines = max(len(b.split(b'\n')) for b in texts.values())
    max_column = max(len(line) for b in texts.values() for line in b.split(b'\n'))

    runs = get('result.json')['cases']
    assert len(runs) == len(plan['inputs']) == 5
    rows = []
    for case, old_case, run in zip(plan['inputs'], old_plan['inputs'], runs):
        name = case['name']
        expected_case = json.loads(json.dumps(old_case).replace(old_root, root))
        expected_case['argv'][expected_case['argv'].index('--proof') + 1] = 'per_check'
        expected_case['argv'][-1:-1] = ['--why3-conf', root + '/overlay/why3.conf']
        assert case == expected_case and run['name'] == name
        for filename in (case['argv'][-1], 'why3.conf'):
            data = raw[name + '/' + filename]
            assert data == old[name + '/' + filename]
            assert identity(data) == plan['file_identities'][case['cwd'] + '/' + filename]
        assert run['completed'] and run['returncode'] == 0 and not run['timed_out']
        assert not run['failures'] and not run['guard_hits']
        process = get(name + '/capture/process.json')
        assert process['environment'] == case['environment'] and process['argv'] == case['argv']
        assert process['initial_threads'] == 1
        summary = get(name + '/capture/summary.json')
        assert summary['completed'] and summary['protected']
        assert not summary['failures'] and not summary['guard_hits'] and not summary['new_threads']
        assert set(summary['guards']) == set(gc.GUARDS)
        old_summary = old_get(name + '/capture/summary.json')
        for label, guard in summary['guards'].items():
            assert guard['first32'] == old_summary['guards'][label]['first32']
        assert [r['guard'] for r in summary['startup_guard_hits']] == [r['guard'] for r in old_summary['startup_guard_hits']]
        assert len(summary['snapshots']) == 3
        start, end = summary['snapshots'][-2:]
        assert summary['baseline'] == start
        assert start['label'] == 'before_first_why3_module' and end['label'] == 'end_of_typing'
        for snap in (start, end):
            s = snap['state']
            assert snap['native_r14'] == snap['state_address']
            assert s['young_limit'] == s['young_trigger'] == s['young_alloc_start']
            assert s['young_alloc_end'] - s['young_alloc_start'] == 8 * 2**28
            assert s['minor_heap_wsz'] == snap['caml_init_minor_heap_wsz'] == 2**28
            assert snap['caml_init_heap_wsz'] == s['stat_heap_wsz'] == 2**24
            assert snap['caml_custom_major_ratio'] == 1000
            assert snap['minor_allocated_words'] == (s['young_alloc_end'] - snap['effective_young_ptr']) // 8
            assert 0 <= snap['minor_allocated_words'] < 2**28
            assert 0 <= snap['caml_allocated_words'] < 2**28
            assert snap['caml_gc_phase'] == 0
            assert all(s[k] == 0 for k in ('in_minor_collection', 'requested_major_slice', 'requested_minor_gc'))
            assert 0 <= s['extra_heap_resources_minor'] < 1
            assert 0 <= snap['caml_extra_heap_resources'] < 1
            assert snap['caml_dependent_size'] == snap['caml_dependent_allocated'] == 0
            for t in snap['tables'].values():
                assert t['used_entries'] == (t['ptr'] - t['base']) // t['entry_size']
                assert t['ptr'] < t['threshold'] == t['limit']
                assert (t['threshold'] - t['base']) // t['entry_size'] == 2**25
        assert all(start['state'][k] == end['state'][k] for k in gc.STATS)
        minor = end['minor_allocated_words'] - start['minor_allocated_words']
        major = end['caml_allocated_words'] - start['caml_allocated_words']
        assert minor >= 0 and major >= 0
        startup = (start['state']['stat_minor_words'] + start['state']['stat_major_words']
                   + start['minor_allocated_words'] + start['caml_allocated_words'])
        assert startup == int(startup)
        assert summary['mapped_files'] == old_summary['mapped_files']
        for path, expected in summary['mapped_files'].items():
            if path in plan['file_identities']:
                assert plan['file_identities'][path] == expected
        assert summary['file_open_site']['first32'] == observer['first32']
        opened = set()
        for event in summary['file_opens']:
            if event['fd'] >= 0 and event['flags'] & 3 == 0:
                assert event['identity'] == plan['file_identities'][event['resolved_path']]
                opened.add(event['resolved_path'])
        assert set(plan['required_overlay_paths']) <= opened
        assert set(plan['selected_driver_closure'].values()) <= opened
        arithmetic = {}
        assert set(summary['arithmetic']) == set(old_id['sites'])
        for label, observed in summary['arithmetic'].items():
            site = old_id['sites'][label]
            assert observed['first32'] == site['first32']
            assert observed['operation'] == site['operation'] and not observed['violations']
            data = raw[name + '/capture/' + label + '.operands']
            assert identity(data) == observed['trace'] and len(data) % 16 == 0
            pairs = list(struct.iter_unpack('<qq', data))
            assert pairs
            values = []
            for left, right in pairs:
                value = left * right if site['operation'] == 'multiply' else left + right
                assert 0 <= left <= LIMIT and 0 <= right <= LIMIT and 0 <= value <= LIMIT
                values.append(value)
            computed = dict(hits=len(pairs), minimum_left=min(a for a, b in pairs),
                            minimum_right=min(b for a, b in pairs), maximum_left=max(a for a, b in pairs),
                            maximum_right=max(b for a, b in pairs), maximum_result=max(values))
            assert computed == {k: observed[k] for k in computed}
            arithmetic[label] = computed
        rows.append(dict(name=name, input_sha256=case['input']['sha256'],
                         allocation_words=minor + major, startup_word_overcount=int(startup),
                         successful_read_paths=len(opened), arithmetic=arithmetic,
                         debugger_seconds=run['duration_seconds']))

    w = max(r['allocation_words'] for r in rows)
    b = w + max(r['startup_word_overcount'] for r in rows) + static_words
    max_count = max(a['maximum_result'] for r in rows for a in r['arithmetic'].values())
    checks = {
        'identity_counter': (w + 1, LIMIT),
        'synthetic_line': (w + 1, 2**47 - 1),
        'physical_words': (b, LIMIT),
        'dependency_rank_and_midpoint': (2*b + 2, LIMIT),
        'projection_height': (b + 65536, LIMIT),
        'byte_length_arithmetic': (16*b + 2, LIMIT),
        'source_line': (max_lines, 2**47 - 1),
        'source_column': (max_column, 2**16 - 1),
        'semantic_count': (max_count, LIMIT),
    }
    assert all(0 <= bound < limit for bound, limit in checks.values())
    task_rows = []
    for packet in ('fixed-check-spines', 'fixed-paths'):
        result = json.loads((EVIDENCE / ('retained-producer-' + packet + '-20261018/result.json')).read_bytes())
        task_rows.extend(result['fixed_inputs'])
    tasks = {r['native_input_sha256']: r for r in task_rows}
    assert len(tasks) == 5
    tail = []
    for row in rows:
        t = tasks[row['input_sha256']]
        assert t['native_input_sha256'] == row['input_sha256']
        g = t.get('source_derived_terminal_task_bound', t.get('terminal_task_bound'))
        r = t['response_record_bound']
        tail.append(dict(name=row['name'], G=g, R=r, N=3*g, A=4*g, S=5*r,
                         raw_response_constant=15245 + 3732*r + 2145*g + 384*4*g + 3075*3*g))
    assert sum(r['G'] for r in tail) == 2981 and sum(r['R'] for r in tail) == 51
    assert sum(r['raw_response_constant'] for r in tail) == 38739343
    events = [json.loads(line) for line in raw['managed/events.jsonl'].splitlines()]
    assert events[-1]['event'] == 'finished' and events[-1]['outcome'] == 'success'
    assert events[-1]['run_id'] == manifest['managed_run']
    failed_events = [json.loads(line) for line in raw['failed/gc6/managed/events.jsonl'].splitlines()]
    assert failed_events[-1]['event'] == 'finished' and failed_events[-1]['outcome'] == 'failure'
    assert failed_events[-1]['run_id'] == manifest['failed_managed_run']
    failed = get('failed/gc6/result.json')['cases']
    assert len(failed) == 1 and failed[0]['name'] == 'put_line' and not failed[0]['completed']
    failed_summary = get('failed/gc6/put_line/capture/summary.json')
    assert not failed_summary['completed'] and not failed_summary['guard_hits']
    assert b'Ambiguous file name found in [' in raw['failed/gc6/put_line/capture/debugger.log']
    result = dict(
        scope='five exact fresh Per_Check prefixes with private no-step driver overlay',
        platform='linux-x86_64', managed_run=manifest['managed_run'], cases=rows,
        maximum_prefix_allocation_words=w, combined_managed_and_static_word_budget=b,
        loaded_image_word_overcount=static_words, configured_text_files=len(texts),
        numeric_conditions={k: dict(upper=v[0], limit=v[1]) for k, v in checks.items()},
        guarded_semantic_operations=sum(a['hits'] for r in rows for a in r['arithmetic'].values()),
        maximum_semantic_result=max_count, tail_shape=tail,
        complete_prefix_capacity_established=True,
        prefix_and_fixed_tail_configuration_joined=True,
        source_argument_machine_checked=False, whole_pipeline_capacity_established=False,
        solver_output_bytes_bounded=False, production_configuration_adopted=False,
        new_native_prefix_executions=6, completed_prefix_executions=5,
        failed_configuration_attempts=1, solver_executions=0,
        managed_success_seconds=events[-1]['duration_seconds'],
        debugger_seconds=sum(r['debugger_seconds'] for r in rows))
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + '\n')
    else:
        assert result == json.loads((HERE / 'result.json').read_bytes())
    print(json.dumps({k: result[k] for k in ('scope', 'maximum_prefix_allocation_words',
        'combined_managed_and_static_word_budget', 'guarded_semantic_operations',
        'prefix_and_fixed_tail_configuration_joined', 'whole_pipeline_capacity_established')}, indent=2))


if __name__ == '__main__':
    main()
