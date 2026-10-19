#!/usr/bin/env python3
"""Focused helper attachment joins, predicates and false/null paths."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import platform
import runpy
import tempfile
import time

HERE = Path(__file__).resolve().parent


def main():
    start, timer = datetime.now(timezone.utc).isoformat(), time.perf_counter()
    m = runpy.run_path(str(HERE / 'compose.py'))
    parser = argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(m['PIPELINE'] / 'compose.py'))['arguments'](parser)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    ctx = m['Context'](args.gcc_root, args.ada_root, args.plugin_include, args.gcc_match)
    checks, variants = [], []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checks.append(name)

    def reject(name, fn, fragment):
        try:
            fn()
        except ValueError as exc:
            if fragment not in str(exc):
                raise AssertionError(name+': expected '+fragment+'; got '+str(exc)) from exc
            check(name, True)
        else:
            raise AssertionError(name+' accepted')

    def mutate(obj, path, value):
        result = copy.deepcopy(obj)
        target = result
        for key in path[:-1]:
            target = target[key]
        target[path[-1]] = value
        return result

    preserve = ['core_result', 'selected_native_invocation', 'selected_native_MEM_counter_lifetime',
        'selected_native_SSA_lifetime_extension', 'selected_native_shared_query_lifetime',
        'selected_native_shared_bitmap_pool_lifetime', 'selected_native_finalizer_lifetime',
        'selected_native_GGC_ledger', 'selected_positive_GGC_events_upper', 'selected_active_pages_upper',
        'selected_GGC_event_partition_closed', 'selected_collector_indexed_storage_capacity_established',
        'lifetime_attachment', 'mem_ssa_attachment', 'pool_finalizer_attachment', 'ggc_attachment',
        'selected_native_CFI_CFG_ordinary_lifetime', m['IRA_FIELD'], 'ordinary_attachment',
        'selected_named_ordinary_capacity_established', m['NUMERIC_FIELD'], 'IRA_numeric_attachment',
        'selected_named_IRA_numeric_arithmetic_established']
    broad = ['whole_literal_pipeline_capacity_established', 'complete_native_capacity',
        'complete_proof_pipeline_capacity', 'complete_parent_storage_closed',
        'production_launcher_adopted', 'production_admission_changed', 'aggregate_RAM_gate']
    residual = ['aggregate_RAM_gate', 'all_outer_IRA_interfaces_closed', 'all_LRA_ordinary_helpers_closed',
        'all_LRA_numeric_arithmetic_closed', 'complete_all_ordinary_native_capacity',
        'complete_native_capacity', 'whole_literal_pipeline_capacity_established', 'production_admission_changed']
    check('18 complete current/Git inputs and72 helper LF operative excerpts',
        ctx.validation['accepted_current_and_historical_records'] == 18 and
        ctx.validation['helper'] == dict(GCC_files=36, repository_files=25,
            literal_LF_operative_excerpts=72, retained_generated_headers=1,
            selected_target_files_without_initial_value_override=9) and
        not ctx.validation['helper_fixed_Hello_reconciliation_called'])
    original_reconciliation = ctx.helper['retained_interface_check']

    def forbidden_reconciliation(*args, **kwargs):
        raise AssertionError('fixed-Hello helper reconciliation entered')

    ctx.helper['retained_interface_check'] = forbidden_reconciliation
    captured = []
    original_prior = ctx.prior['evaluate']

    def capture(*args, **kwargs):
        result = original_prior(*args, **kwargs)
        captured.append(result)
        return result

    ctx.prior['evaluate'] = capture
    raw = (m['REPO'] / 'samples/hello_world.adb').read_bytes()
    shell = b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    sources = [('Hello', raw), ('same_counts_other_bytes', raw.replace(b'Hello, world!', b'Other, world!')),
        ('C2_N2', shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("xy"); null;\nend Main;\n'),
        ('C10_N10', shell+b'Silver_IO.Put ("x"); null;\n'*10+b'end Main;\n')]
    with tempfile.TemporaryDirectory(prefix='helper-attachment-', dir=m['REPO'] / 'tmp') as scratch:
        source_path = Path(scratch) / 'main.adb'
        for name, source in sources:
            source_path.write_bytes(source)
            r = m['evaluate'](m['PIPELINE'] / 'selected-route.json', ctx, None if name == 'Hello' else source_path)
            prior = captured[-1]
            leaf, attachment = r[m['HELPER_FIELD']], r[m['ATTACHMENT']]
            ar, owners = leaf['arithmetic'], leaf['retained_owners']
            c, n = r['source_counts']['output_calls'], r['source_counts']['null_statements']
            k, b, length = 99+5*c, 2*n+10, 7*c+5*n+20
            x = dict(A=4*c, K=k, B=b, M=length, U=length+2, P=2*length+b, R=3*k//2+1)
            check(name+' actual complete source/path/launch/configuration367 guards',
                len(r['conditions']) == len(r['conditional_conditions']) == 367 and len(attachment['guards']) == 32 and
                leaf['source'] == r['source'] and leaf['source_counts'] == r['source_counts'] and
                leaf['source_path'] == r['source_path'] and leaf['launch'] == r['launch'] and
                leaf['actual_shared_inputs'] == r['actual_shared_inputs'] and leaf['complete_path_bound'] == r['complete_path_bound'] and
                r['evaluated_predicates_pass'] and r['conditional_arithmetic_pass'] and r[m['SUMMARY']])
            check(name+' all335 inherited maps and23 full owner/attachment fields preserved',
                all(r[f][key] is value for f in ('conditions', 'conditional_conditions') for key, value in prior[f].items()) and
                all(r[key] == prior[key] for key in preserve))
            check(name+' actual complete A K B M U P R helper transfer', ar['counts'] == dict(C=c, N=n) and ar['extents'] == x)
            check(name+' accepted DF600C and reference-creation owner retained',
                ar['counters']['regstat_deaths_each_upper'] == 600*c and
                ar['counters']['accepted_DF_reference_creations_upper'] == 17690*c+368*n+19076 ==
                owners['native_backing']['DF_selected_reference_and_solver_transfer']['ref_order_final_upper'])
            check(name+' optional inheritance size branch included',
                ar['counters']['inheritance_passes_upper'] == 1 and ar['counters']['inheritance_EBB_epochs_upper'] == b and
                next(row for row in ar['individual_requests'] if row['name'] == 'optional LRA inheritance usage array')['each_request_bytes_upper'] == 24*k and
                owners['selected_LRA_schedule'] == dict(constraints=2, live_range_construction=1, assignment=1, inheritance_upper=1, undo_upper=1))
            check(name+' per-pseudo2(P+1) separate from global10C live pool',
                ar['counters']['LRA_live_ranges_per_pseudo_upper'] == 2 and
                ar['counters']['assignment_live_length_sum_upper'] == 2*(x['P']+1) and
                owners['shared_bitmap_and_live_pools']['LRA_additional_pools']['live_ranges']['live_objects_upper'] == 10*c)
            check(name+' separate IRA1000 and LRA10000 numeric ownership',
                prior[m['NUMERIC_FIELD']]['arithmetic']['constants']['IRA_frequency_upper'] == 1000 and
                prior[m['NUMERIC_FIELD']]['arithmetic']['constants']['LRA_frequency_unit_separate'] == 10000 and
                owners['separate_LRA10000_guard'] is prior['conditions'][m['LRA_GUARD']])
            check(name+' actual GGC rows and event count retained without fixed-Hello rule',
                owners['actual_GGC'] == prior['selected_native_GGC_ledger'] and
                owners['actual_GGC_events_upper'] == prior['selected_positive_GGC_events_upper'] and
                not attachment['fixed_Hello_reconciliation_used_as_actual_source_rule'])
            check(name+' zero GGC finalizer bitmap ET register/constraint recharge and named scope',
                all(ar[key] == 0 for key in ('new_GGC_events', 'new_scalar_registrations', 'new_array_registrations', 'shared_bitmap_or_ET_blocks_recharged')) and
                ar['retained_LRA_register_and_constraint_owners_recharged'] is False and
                all(ar[key] is False for key in residual) and all(r[key] is False for key in broad) and
                ar['aggregate_ordinary_bytes'] is ar['lifetime_ordinary_request_total'] is
                r['complete_imported_allocation_events'] is r['complete_imported_allocation_bytes'] is None)
            check(name+' earlier component scope flags remain frozen',
                r[m['IRA_FIELD']]['numeric_cost_arithmetic_closed'] is False and
                r['ordinary_attachment']['numeric_cost_pressure_priority_and_outer_IRA_LRA_capacity_established'] is False and
                attachment['earlier_helper_open_flags_are_component_history'] and
                ar['actual_source_adapter_created'] is ar['numeric_packet_consumed'] is False and
                leaf['actual_source_helper_adapter_attached'])
            if name == 'Hello':
                baseline, incoming = r, prior
                check('Hello helper pure fields match frozen accepted source result',
                    ar == ctx.helper['arithmetic'](1, 0) and all(ar[key] == ctx.helper_reference[key] for key in ar))
            if name == 'same_counts_other_bytes':
                check('equal counts with distinct physical bytes bind distinct source',
                    r['source'] != baseline['source'] and
                    {k: v for k, v in r['source_counts'].items() if k != 'source_sha256'} ==
                    {k: v for k, v in baseline['source_counts'].items() if k != 'source_sha256'})
            if name == 'C10_N10':
                check('C10N10 actual69927 GGC events retained', r['selected_positive_GGC_events_upper'] == 69927)
            variants.append(dict(name=name, source=r['source'], counts=r['source_counts'], extents=ar['extents'],
                guards=len(r['conditions']), GGC_events=r['selected_positive_GGC_events_upper'], passed=r['evaluated_predicates_pass']))
    ctx.prior['evaluate'] = original_prior
    original_helper = ctx.helper['arithmetic']

    def forbidden(*args, **kwargs):
        raise AssertionError('new helper arithmetic entered on false/null prerequisites')

    ctx.helper['arithmetic'] = forbidden
    numeric_key = next(key for key in incoming['conditions'] if key.startswith('native_IRA_numeric_'))
    ordinary_key = next(key for key in incoming['conditions'] if key.startswith('native_ordinary_IRA_'))
    for field in ('conditions', 'conditional_conditions'):
        for key in (numeric_key, ordinary_key):
            for value in (False, None):
                changed = mutate(incoming, [field, key], value)
                r = m['attach'](raw, changed, ctx)
                check(field+' preserves and skips helper for '+key+'='+str(value),
                    r[m['HELPER_FIELD']] is None and all(v is None for v in r[m['ATTACHMENT']]['guards'].values()) and
                    not r[m['SUMMARY']] and not r['conditional_arithmetic_pass'] and
                    any(reason.endswith('=uncomputed' if value is None else '=false') for reason in r[m['ATTACHMENT']]['not_computed_reasons']) and
                    all(r[f][k] is v for f in ('conditions', 'conditional_conditions') for k, v in changed[f].items()) and
                    all(r[k] == changed[k] for k in preserve))
    ordinary_ctx = ctx.prior_context.prior_context
    ggc_ctx, ggc_api = ordinary_ctx.prior_context, ordinary_ctx.prior
    first = next(iter(incoming['conditions']))
    pool_key = next(key for key in incoming['conditions'] if key.startswith('native_pool_finalizer_'))
    for key in (first, pool_key):
        old = ctx.project(incoming, ggc_ctx.reference['conditions'].keys())
        old['conditions'][key] = old['conditional_conditions'][key] = False
        failed236 = ggc_api['attach'](raw, old, ggc_ctx)
        failed305 = ctx.prior_context.prior['attach'](raw, failed236, ordinary_ctx)
        failed335 = ctx.prior['attach'](raw, failed305, ctx.prior_context)
        r = m['attach'](raw, failed335, ctx)
        check('real failed219 retains116 old nulls plus32 new='+str(148)+' '+key,
            len(r['unresolved_predicates']) == 148 and r['failed_predicates'] == [key] and
            r[m['HELPER_FIELD']] is None and not r[m['SUMMARY']] and
            all(r[f][k] is v for f in ('conditions', 'conditional_conditions') for k, v in failed335[f].items()) and
            all(r[k] == failed335[k] for k in preserve))
        real_failed = failed335
    for key in ('native_GGC_active_page_signed_index', m['LRA_GUARD']):
        old = ctx.project(incoming, ordinary_ctx.reference['conditions'].keys())
        old['conditions'][key] = old['conditional_conditions'][key] = False
        failed305 = ctx.prior_context.prior['attach'](raw, old, ordinary_ctx)
        failed335 = ctx.prior['attach'](raw, failed305, ctx.prior_context)
        r = m['attach'](raw, failed335, ctx)
        check('distinct GGC or LRA10000 prerequisite '+key+' skips helper',
            r[m['HELPER_FIELD']] is None and r['conditions'][key] is False and
            len(r['unresolved_predicates']) == 131 and not r[m['SUMMARY']])
    summary_paths = [('evaluated_predicates_pass',), ('conditional_arithmetic_pass',),
        ('selected_named_ordinary_capacity_established',), ('ordinary_attachment', 'selected_named_ordinary_capacity_established'),
        ('selected_named_IRA_numeric_arithmetic_established',), ('IRA_numeric_attachment', 'selected_named_IRA_numeric_arithmetic_established'),
        ('core_result', 'conditional_arithmetic_pass')]
    for path in summary_paths:
        r = m['attach'](raw, mutate(incoming, path, False), ctx)
        check('false summary skips helper '+'.'.join(path), r[m['HELPER_FIELD']] is None and not r[m['SUMMARY']])
    # Owner corruption must fail before the short-circuit, with helper forbidden.
    failures = [
        (['actual_shared_inputs', 'configuration', 'sha256'], '0'*64, 'configuration/System join'),
        (['selected_native_invocation', 'processes', 0, 'environment', 'EXTRA'], '1', 'selected invocation'),
        (['core_result', 'selected_native_backing', 'LRA_register_and_recognition_backing', 'referenced_pseudo_nrefs_upper'], 3, 'accepted RTL backing'),
        (['core_result', 'selected_native_backing', 'LRA_register_and_recognition_backing', 'constraint_stack_request_bytes_upper'], 0, 'accepted RTL backing'),
        (['core_result', 'selected_native_backing', 'DF_selected_reference_and_solver_transfer', 'ref_order_final_upper'], 0, 'accepted RTL backing'),
        (['core_result', 'selected_native_backing', 'LRA_register_and_recognition_backing', 'each_register_record_bytes'], 1, 'accepted RTL backing'),
        (['IRA_numeric_attachment', 'new_GGC_events'], 1, 'numeric attachment metadata')]
    for obj, label in [(incoming, 'passing'), (real_failed, 'real false/null')]:
        for path, value, fragment in failures:
            reject(label+' owner corruption before branch '+'.'.join(map(str, path)),
                lambda obj=obj, path=path, value=value: m['attach'](raw, mutate(obj, path, value), ctx), fragment)
        reject(label+' equal-count wrong physical source rejected', lambda obj=obj: m['attach'](sources[1][1], obj, ctx), 'actual source identity')
    for obj, label in [(incoming, 'passing'), (mutate(incoming, ['conditions', numeric_key], False), 'false numeric')]:
        for path, value, fragment in [
            ([m['NUMERIC_FIELD'], 'arithmetic', 'cost_bounds', 'equivalence_gains'], 1, 'numeric arithmetic owners'),
            ([m['NUMERIC_FIELD'], 'retained_owners', 'actual_GGC_events_upper'], 1, 'numeric source configuration and retained owners'),
            ([m['NUMERIC_FIELD'], 'retained_owners', 'ordinary_IRA', 'extents', 'A'], 1, 'numeric source configuration and retained owners'),
            ([m['NUMERIC_FIELD'], 'launch', 'native_options'], [], 'numeric source configuration and retained owners'),
            ([m['IRA_FIELD'], 'ordinary_requests', 0, 'each_request_bytes_upper'], 0, 'complete actual ordinary')]:
            reject(label+' inherited complete numeric/ordinary owner '+'.'.join(map(str, path)),
                lambda obj=obj, path=path, value=value: m['attach'](raw, mutate(obj, path, value), ctx), fragment)
    ctx.helper['arithmetic'] = original_helper
    pure = original_helper(1, 0)

    def patch_helper(value):
        ctx.helper['arithmetic'] = lambda *args, **kwargs: copy.deepcopy(value)
        try:
            return m['attach'](raw, incoming, ctx)
        finally:
            ctx.helper['arithmetic'] = original_helper

    for key in pure['local_representation_checks']:
        r = patch_helper(mutate(pure, ['local_representation_checks', key], False))
        check('new false predicate stays computed '+key,
            r['failed_predicates'] == r['failed_conditional_predicates'] == [m['PREFIX']+key] and
            r[m['HELPER_FIELD']] is not None and r[m['ATTACHMENT']]['status'] == 'computed' and
            not r[m['SUMMARY']] and not r['unresolved_predicates'] and all(r[k] == incoming[k] for k in preserve))
    r = patch_helper(mutate(pure, ['conditional_named_helper_storage_capacity'], False))
    check('new false conjunction stays computed', r['failed_predicates'] == [m['CONJUNCTION']] and r[m['ATTACHMENT']]['status'] == 'computed')
    reject('nonboolean helper local rejected',
        lambda: patch_helper(mutate(pure, ['local_representation_checks', 'register_indices_signed'], 1)), 'boolean computed helper')
    reject('nonboolean helper conjunction rejected',
        lambda: patch_helper(mutate(pure, ['conditional_named_helper_storage_capacity'], 1)), 'boolean helper conjunction')
    for path, value, fragment in [
        (['counts', 'N'], 1, 'count and extent'), (['extents', 'R'], 0, 'count and extent'),
        (['counters', 'LRA_live_ranges_per_pseudo_upper'], 10, 'per-pseudo length'),
        (['counters', 'assignment_live_length_sum_upper'], 10*65, 'per-pseudo length'),
        (['counters', 'inheritance_passes_upper'], 0, 'inheritance'),
        (['retained_LRA_register_and_constraint_owners_recharged'], True, 'recharge')]+[
        ([k], 1, 'recharge') for k in ('new_GGC_events', 'new_scalar_registrations', 'new_array_registrations', 'shared_bitmap_or_ET_blocks_recharged')]+[
        ([k], True, 'scope remains named') for k in residual]:
        reject('returned helper scope/owner corruption '+'.'.join(path),
            lambda path=path, value=value: patch_helper(mutate(pure, path, value)), fragment)
    # Count-only boundary and export checks: no source or inherited success claim.
    pure_cases = []
    last_n = (ctx.helper['I32']//2 - 65)//12
    for name, c, n in [('C5000_N0', 5000, 0), ('live_length_last', 1, last_n), ('live_length_first', 1, last_n+1)]:
        ar = original_helper(c, n)
        exported = m['helper_guards'](ar, ctx)
        guard = ar['local_representation_checks']['assignment_live_length_sum_signed']
        check('pure count length/export '+name,
            ar['counters']['assignment_live_length_sum_upper'] == 2*(ar['extents']['P']+1) and
            exported[m['PREFIX']+'assignment_live_length_sum_signed'] is guard and guard is (not name.endswith('first')))
        if name == 'C5000_N0':
            check('pure5000 all31 helpers pass with140102 length', all(v is True for v in exported.values()) and
                ar['counters']['assignment_live_length_sum_upper'] == 140102)
        pure_cases.append(dict(name=name, C=c, N=n, per_pseudo_live_length_upper=ar['counters']['assignment_live_length_sum_upper'],
            exported_live_length_guard=guard, all_local_guards_pass=ar['conditional_named_helper_storage_capacity'], failed_predicates=ar['failed_predicates']))
    copied = m['attach'](raw, incoming, ctx)
    copied[m['HELPER_FIELD']]['retained_owners']['native_backing']['LRA_register_and_recognition_backing']['referenced_pseudo_nrefs_upper'] = 0
    check('deep copied helper audit owners do not alias inherited owners',
        incoming['core_result']['selected_native_backing']['LRA_register_and_recognition_backing']['referenced_pseudo_nrefs_upper'] == 2 and
        copied['core_result']['selected_native_backing']['LRA_register_and_recognition_backing']['referenced_pseudo_nrefs_upper'] == 2)
    ctx.helper['retained_interface_check'] = original_reconciliation
    result = dict(status='passed', check_count=len(checks), checks=checks, actual_sources=variants,
        pure_count_cases=pure_cases, new_successor_contexts=1, new_helper_false_checks=32,
        real_failed_unresolved_predicates=148,
        affected_scope='New helper attachment, complete prior numeric/backing joins and representative inherited false/null routes; accepted predecessor/source success reused.',
        started_utc=start, completed_utc=datetime.now(timezone.utc).isoformat(), elapsed_seconds=time.perf_counter()-timer,
        platform=platform.platform(), validation=ctx.validation, native_tool_executions=0,
        build_prover_solver_capture_runs=0, predecessor_suites_rerun=False, aggregate_or_corpus_executions=0,
        helper_fixed_Hello_reconciliation_called=False)
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    baseline['offline_run'] = dict(started_utc=start, completed_utc=result['completed_utc'], elapsed_seconds=result['elapsed_seconds'],
        run_kind='Hello retained from same focused helper checker; accepted predecessor/source suites reused')
    (HERE / 'result.json').write_text(json.dumps(baseline, indent=2)+'\n')
    print(json.dumps({k: result[k] for k in ('status', 'check_count', 'elapsed_seconds')}))


if __name__ == '__main__':
    main()
