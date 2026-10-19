#!/usr/bin/env python3
"""Check exact source/excerpt and retained-owner consistency; no source proof."""
import argparse
import hashlib
import json
from pathlib import Path
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def check(gcc_root):
    manifest = json.loads((HERE / 'inputs.json').read_text())
    roots = dict(gcc=Path(gcc_root), repository=REPO)
    checks = []
    for row in manifest['files']:
        assert identity((roots[row['root']] / row['path']).read_bytes()) == {
            k: row[k] for k in ('bytes', 'sha256')}, row['path']
        checks.append('identity:' + row['root'] + ':' + row['path'])
    for row in manifest['source_excerpts']:
        lines = (roots['gcc'] / row['path']).read_text().split('\n')
        assert '\n'.join(lines[row['start'] - 1:row['end']]) == row['source'], row
        checks.append(f"excerpt:{row['path']}:{row['start']}:{row['end']}")
    pipeline = json.loads((REPO / 'docs/evidence/retained-literal-pipeline-20261018/selected-route-result.json').read_text())
    initial = pipeline['core_result']['native_initial_SSA_lifetime']
    counts = pipeline['source_counts']
    c, n = counts['output_calls'], counts['null_statements']
    u, z = 3*c+1, 3*c+2
    slabs = 1 + int(u > 25) + (max(0, u-127)+408)//409
    assert initial['source_input'] == dict(calls=c, nulls=n, SSA_slots_upper=z,
        memory_definitions_upper=3*c, memory_uses_upper=u, initial_CFG_block_slots_upper=n+4)
    assert initial['real_SSA_names'] == initial['PHIs'] == 0
    assert initial['default_memory_names'] == initial['default_definition_hash_entries'] == 1
    assert initial['nondefault_memory_names_upper'] == 3*c
    assert sum(r['requests_upper'] for r in initial['individual_GGC_request_groups']) == 6*c+10+slabs
    assert initial['additional_GGC_request_events_upper'] == 6*c+10+slabs
    assert initial['conditional_initial_SSA_lifetime_closed'] == all(initial['local_representation_checks'].values())
    assert initial['additional_singleton_finalizer_registrations_upper'] == 1
    assert not initial['whole_native_pipeline_capacity_established']
    checks.extend(['actual-source count binding', 'no real names or PHIs',
        'single default definition', 'nondefault definition ownership',
        'retained row sum and initial envelope', 'guard conjunction retained',
        'existing scalar registration', 'whole native capacity remains open'])
    result = dict(source=pipeline['source'], source_counts=counts,
        scope='Selected literal Main SSA families under the pinned source argument; independent review required',
        later_incremental_update_allocations=0, later_new_SSA_NAME_objects=0,
        later_SSA_name_vector_backings=0, later_free_name_queue_backings=0,
        later_free_name_vector_backings=0, later_default_hash_keys=0,
        operand_slabs_beyond_initial_envelope=0,
        retained_initial_SSA_owned_GGC_events_upper=initial['additional_GGC_request_events_upper'],
        retained_initial_individual_GGC_request_groups=initial['individual_GGC_request_groups'],
        retained_initial_guards=initial['local_representation_checks'],
        conditional_selected_SSA_lifetime_fits=all(initial['local_representation_checks'].values()),
        additional_GGC_events_charged=0, additional_scalar_registrations_charged=0,
        helper_SSA_owners_added_again=0,
        full_GGC_ledger_established=False, complete_native_capacity=False,
        production_admission_changed=False, source_argument_is_handwritten=True,
        independent_review_status='pending',
        checks=checks, gcc_files=sum(r['root']=='gcc' for r in manifest['files']),
        repository_files=sum(r['root']=='repository' for r in manifest['files']),
        source_excerpts=len(manifest['source_excerpts']), native_tool_executions=0,
        aggregate_executions=0, accepted_component_suites_rerun=0)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path,
        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    started = time.perf_counter()
    result = check(args.gcc_root)
    if args.write:
        (HERE/'result.json').write_text(json.dumps(result, indent=2)+'\n')
    else:
        assert result == json.loads((HERE/'result.json').read_text())
    print(json.dumps(dict(passed=True, checks=len(result['checks']),
        gcc_files=result['gcc_files'], repository_files=result['repository_files'],
        source_excerpts=result['source_excerpts'], seconds=time.perf_counter()-started)))
