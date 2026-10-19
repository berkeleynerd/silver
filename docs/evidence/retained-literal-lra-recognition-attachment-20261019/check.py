#!/usr/bin/env python3
"""Focused actual-source recognition joins, retained owners and false/null paths."""
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

    def preserved(result, prior):
        changed = {'scope', 'evaluated_predicates_pass', 'conditional_arithmetic_pass', 'failed_predicates',
            'failed_conditional_predicates', 'unresolved_predicates', 'validation', 'accounting', 'open_joins'}
        return all(result[key] == value for key, value in prior.items() if key not in changed) and all(
            result['open_joins'][key] == value for key, value in prior['open_joins'].items() if key != 'native_remaining_lifetime_and_collector')

    check('18 complete accepted current/Git records and recognition source inventory',
        ctx.validation['accepted_current_and_historical_records'] == 18 and
        ctx.validation['recognition'] == dict(GCC_files=17, repository_files=26, literal_LF_excerpts=72,
            mutation_API_occurrences=65, owner_writer_occurrences=26, retained_headers=3))

    def forbidden_fixture(*args, **kwargs):
        raise AssertionError('fixed Hello fixture entered')

    ctx.recognition['fixture'] = forbidden_fixture
    ctx.prior_context.helper['retained_interface_check'] = forbidden_fixture
    original_prior, captured = ctx.prior['evaluate'], []

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
    (m['REPO'] / 'tmp').mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='recognition-attachment-', dir=m['REPO'] / 'tmp') as scratch:
        source_path = Path(scratch) / 'main.adb'
        for name, source in sources:
            source_path.write_bytes(source)
            result = m['evaluate'](m['PIPELINE'] / 'selected-route.json', ctx, None if name == 'Hello' else source_path)
            prior = captured[-1]
            leaf, attachment = result[m['FIELD']], result[m['ATTACHMENT']]
            ar, d, owners = leaf['arithmetic'], leaf['arithmetic']['derived'], leaf['retained_owners']
            c, n = result['source_counts']['output_calls'], result['source_counts']['null_statements']
            length = 7*c+5*n+20
            check(name+' exact367 maps unchanged and every prior owner retained',
                len(result['conditions']) == len(result['conditional_conditions']) == 367 and preserved(result, prior) and
                result['conditions'] == prior['conditions'] and result['conditional_conditions'] == prior['conditional_conditions'])
            check(name+' complete physical source counts path launch configuration',
                all(leaf[key] == result[key] for key in ('source', 'source_counts', 'source_path', 'launch', 'actual_shared_inputs', 'complete_path_bound')) and
                ar['C'] == c and ar['N'] == n and ar['K'] == 99+5*c and ar['M'] == length and ar['U'] == length+2)
            check(name+' rounded819 and2730 retained slots fit existing owner blocks',
                d['recognition_pool'] == dict(live_upper=length, slots_per_block=819, retained_blocks_upper=(length+818)//819,
                    retained_slots_upper=819*((length+818)//819)) and
                d['instruction_register_pool'] == dict(live_upper=10*c, slots_per_block=2730, retained_blocks_upper=(10*c+2729)//2730,
                    retained_slots_upper=2730*((10*c+2729)//2730)))
            check(name+' stored pseudo keys nrefs2 freq2000 argument alternatives and separate LRA10000',
                d['per_pseudo_nrefs_upper'] == 2 and d['per_pseudo_frequency_upper'] == 2000 and
                d['argument_stack_entries_used'] == 3 and d['maximum_shift'] == 34 and d['alternative_entries_upper'] == 70 and
                leaf['stored_pseudo_keys_preserved_through_final_renumber_until_deletion_or_draining'] and
                owners['separate_LRA10000_guard'] is prior['conditions'][ctx.prior['LRA_GUARD']])
            check(name+' complete existing recognition helper pool GGC audit owners',
                owners['recognition'] == prior['core_result']['selected_native_backing'][m['OWNER']] and
                owners['helper'] == prior[ctx.prior['HELPER_FIELD']] and
                owners['shared_bitmap_and_live_pools'] == prior['selected_native_shared_bitmap_pool_lifetime'] and
                owners['actual_GGC'] == prior['selected_native_GGC_ledger'] and
                owners['actual_GGC_events_upper'] == prior['selected_positive_GGC_events_upper'])
            check(name+' no new guards owners charges or broader capacity',
                attachment['new_guards'] == attachment['new_allocation_owners'] == attachment['new_GGC_events'] ==
                attachment['new_finalizer_registrations'] == attachment['new_pool_or_bitmap_charge'] == 0 and
                result[m['SUMMARY']] and result['evaluated_predicates_pass'] and result['conditional_arithmetic_pass'] and
                all(result[key] is False for key in ('complete_native_capacity', 'whole_literal_pipeline_capacity_established', 'aggregate_RAM_gate')) and
                ar['actual_source_adapter'] is ar['independently_reviewed'] is False and leaf['actual_source_recognition_adapter_attached'] and
                not attachment['fixed_Hello_reconciliation_used_as_actual_source_rule'] and not attachment['existing_recognition_owners_recharged'])
            if name == 'Hello':
                baseline, incoming = result, prior
                check('Hello pure arithmetic equals accepted source fixture without calling it', ar == ctx.recognition_reference)
            if name == 'same_counts_other_bytes':
                check('same numerical counts distinct actual source identity', result['source'] != baseline['source'] and
                    {k: v for k, v in result['source_counts'].items() if k != 'source_sha256'} ==
                    {k: v for k, v in baseline['source_counts'].items() if k != 'source_sha256'})
            if name == 'C10_N10':
                check('actual nonHello69927 GGC events retained', result['selected_positive_GGC_events_upper'] == 69927)
            variants.append(dict(name=name, source=result['source'], counts=result['source_counts'], guards=len(result['conditions']),
                recognition_pool=d['recognition_pool'], instruction_register_pool=d['instruction_register_pool'],
                GGC_events=result['selected_positive_GGC_events_upper'], passed=result[m['SUMMARY']]))
    ctx.prior['evaluate'] = original_prior
    original_arithmetic = ctx.recognition['arithmetic']

    def forbidden(*args, **kwargs):
        raise AssertionError('recognition arithmetic entered on failed/uncomputed prerequisites')

    ctx.recognition['arithmetic'] = forbidden
    keys = [next(k for k in incoming['conditions'] if k.startswith(prefix))
        for prefix in ('native_IRA_LRA_helper_', 'native_IRA_numeric_', 'native_ordinary_IRA_')]
    for field in ('conditions', 'conditional_conditions'):
        for key in keys:
            for value in (False, None):
                prior = mutate(incoming, [field, key], value)
                result = m['attach'](raw, prior, ctx)
                check(field+' preserves failed/uncomputed '+key+'='+str(value),
                    preserved(result, prior) and result[m['FIELD']] is None and not result[m['SUMMARY']] and
                    result['conditions'] == prior['conditions'] and result['conditional_conditions'] == prior['conditional_conditions'] and
                    result['failed_predicates'] == [k for k, v in prior['conditions'].items() if v is False] and
                    result['unresolved_predicates'] == [k for k, v in prior['conditions'].items() if v is None] and
                    any(reason.endswith('=uncomputed' if value is None else '=false') for reason in result[m['ATTACHMENT']]['not_computed_reasons']))
    helper_ctx = ctx.prior_context
    numeric_ctx, ordinary_ctx = helper_ctx.prior_context, helper_ctx.prior_context.prior_context
    ggc_ctx = ordinary_ctx.prior_context
    for key in (next(iter(incoming['conditions'])), next(k for k in incoming['conditions'] if k.startswith('native_pool_finalizer_'))):
        old = ctx.project(incoming, ggc_ctx.reference['conditions'].keys())
        old['conditions'][key] = old['conditional_conditions'][key] = False
        failed236 = ordinary_ctx.prior['attach'](raw, old, ggc_ctx)
        failed305 = numeric_ctx.prior['attach'](raw, failed236, ordinary_ctx)
        failed335 = helper_ctx.prior['attach'](raw, failed305, numeric_ctx)
        real_failed = ctx.prior['attach'](raw, failed335, helper_ctx)
        result = m['attach'](raw, real_failed, ctx)
        check('real failed219 retains148 nulls without adding predicates '+key,
            preserved(result, real_failed) and len(result['unresolved_predicates']) == 148 and
            result['failed_predicates'] == [key] and result[m['FIELD']] is None and not result[m['SUMMARY']])
    for key in ('native_GGC_active_page_signed_index', ctx.prior['LRA_GUARD']):
        old = ctx.project(incoming, ordinary_ctx.reference['conditions'].keys())
        old['conditions'][key] = old['conditional_conditions'][key] = False
        failed305 = numeric_ctx.prior['attach'](raw, old, ordinary_ctx)
        failed335 = helper_ctx.prior['attach'](raw, failed305, numeric_ctx)
        failed367 = ctx.prior['attach'](raw, failed335, helper_ctx)
        result = m['attach'](raw, failed367, ctx)
        check('real distinct GGC/LRA10000 failure retains131 nulls '+key,
            preserved(result, failed367) and result[m['FIELD']] is None and not result[m['SUMMARY']] and
            result['failed_predicates'] == [key] and len(result['unresolved_predicates']) == 131)
    paths = [('evaluated_predicates_pass',), ('conditional_arithmetic_pass',), ('selected_named_ordinary_capacity_established',),
        ('ordinary_attachment', 'selected_named_ordinary_capacity_established'), ('selected_named_IRA_numeric_arithmetic_established',),
        ('IRA_numeric_attachment', 'selected_named_IRA_numeric_arithmetic_established'), ('core_result', 'conditional_arithmetic_pass'),
        (ctx.prior['SUMMARY'],), (ctx.prior['ATTACHMENT'], 'selected_named_helper_storage_established')]
    for path in paths:
        result = m['attach'](raw, mutate(incoming, path, False), ctx)
        check('false summary skips recognition '+'.'.join(path), result[m['FIELD']] is None and not result[m['SUMMARY']])
    failures = [
        (['actual_shared_inputs', 'configuration', 'sha256'], '0'*64, 'configuration/System join'),
        (['selected_native_invocation', 'processes', 0, 'environment', 'EXTRA'], '1', 'selected invocation'),
        (['core_result', 'selected_native_backing', m['OWNER'], 'recognition_pool_blocks_upper'], 2, 'accepted RTL backing'),
        (['core_result', 'selected_native_backing', m['OWNER'], 'instruction_register_pool_blocks_upper'], 2, 'accepted RTL backing'),
        (['core_result', 'selected_native_backing', m['OWNER'], 'referenced_pseudo_nrefs_upper'], 3, 'accepted RTL backing'),
        ([ctx.prior['ATTACHMENT'], 'new_GGC_events'], 1, 'helper attachment metadata'),
        (['complete_native_capacity'], True, 'scope remains open')]
    for obj, label in ((incoming, 'passing'), (real_failed, 'real false/null')):
        for path, value, fragment in failures:
            reject(label+' rejects owner corruption before skip '+'.'.join(map(str, path)),
                lambda obj=obj, path=path, value=value: m['attach'](raw, mutate(obj, path, value), ctx), fragment)
        reject(label+' rejects equal-count wrong physical source', lambda obj=obj: m['attach'](sources[1][1], obj, ctx), 'actual source identity')
    for obj, label in ((incoming, 'passing'), (mutate(incoming, ['conditions', keys[0]], False), 'false helper')):
        for path, value, fragment in [
            ([ctx.prior['HELPER_FIELD'], 'arithmetic', 'counters', 'LRA_live_ranges_per_pseudo_upper'], 10, 'helper arithmetic owners'),
            ([ctx.prior['HELPER_FIELD'], 'retained_owners', 'actual_GGC_events_upper'], 1, 'helper source configuration and retained owners'),
            ([ctx.prior['HELPER_FIELD'], 'launch', 'native_options'], [], 'helper source configuration and retained owners')]:
            reject(label+' rejects complete helper corruption '+'.'.join(path),
                lambda obj=obj, path=path, value=value: m['attach'](raw, mutate(obj, path, value), ctx), fragment)
    ctx.recognition['arithmetic'] = original_arithmetic
    pure = original_arithmetic(1, 0)

    def patched(value):
        ctx.recognition['arithmetic'] = lambda *args: copy.deepcopy(value)
        try:
            return m['attach'](raw, incoming, ctx)
        finally:
            ctx.recognition['arithmetic'] = original_arithmetic

    mutations = [(['C'], 2), (['N'], 1), (['K'], 0), (['M'], 0), (['U'], 0), (['computed'], 1),
        (['derived'], None), (['actual_source_adapter'], True), (['complete_native_capacity'], True),
        (['whole_pipeline_capacity'], True), (['all_LRA_capacity'], True), (['aggregate_RAM_gate'], True),
        (['new_GGC_events'], 1), (['new_finalizer_registrations'], 1), (['new_pool_or_bitmap_charge'], 1),
        (['derived', 'per_pseudo_nrefs_upper'], 3), (['derived', 'per_pseudo_frequency_upper'], 2001),
        (['derived', 'argument_stack_entries_used'], 4), (['derived', 'maximum_shift'], 64),
        (['derived', 'recognition_pool', 'retained_slots_upper'], 27),
        (['derived', 'instruction_register_pool', 'retained_slots_upper'], 10)]
    mutations += [(['inherited_arithmetic_premises', key], False) for key in pure['inherited_arithmetic_premises']]
    for path, value in mutations:
        reject('returned recognition implication corruption '+'.'.join(path),
            lambda path=path, value=value: patched(mutate(pure, path, value)), 'complete recognition implication')
    pure_cases = []
    for c, n in ((1, 0), (1, 158), (1, 159), (273, 0), (274, 0), (143165556, 0), (143165557, 0),
                 (1, 286331147), (1, 286331148)):
        ar = original_arithmetic(c, n)
        d = ar['derived']
        check('pure implication preserves existing consumed premises '+str((c, n)),
            ar['computed'] is all(ar['inherited_arithmetic_premises'].values()) and
            (d is None or (d['recognition_pool']['retained_slots_upper'] == 819*((ar['M']+818)//819) and
                d['instruction_register_pool']['retained_slots_upper'] == 2730*((10*c+2729)//2730))))
        pure_cases.append(dict(C=c, N=n, computed=ar['computed'], derived=d,
            inherited_arithmetic_premises=ar['inherited_arithmetic_premises']))
    copied = m['attach'](raw, incoming, ctx)
    copied[m['FIELD']]['retained_owners']['recognition']['referenced_pseudo_nrefs_upper'] = 0
    check('new recognition audit owner does not alias inherited input or result',
        incoming['core_result']['selected_native_backing'][m['OWNER']]['referenced_pseudo_nrefs_upper'] == 2 and
        copied['core_result']['selected_native_backing'][m['OWNER']]['referenced_pseudo_nrefs_upper'] == 2)
    record = dict(status='passed', check_count=len(checks), checks=checks, actual_sources=variants, pure_count_cases=pure_cases,
        new_successor_contexts=1, inherited_guards=367, new_guards=0, real_failed_unresolved_predicates=148,
        affected_scope='New recognition attachment, complete helper/backing/source joins and representative inherited false/null paths; accepted source and predecessor evidence reused.',
        started_utc=start, completed_utc=datetime.now(timezone.utc).isoformat(), elapsed_seconds=time.perf_counter()-timer,
        platform=platform.platform(), validation=ctx.validation, native_tool_executions=0, build_prover_solver_capture_runs=0,
        predecessor_suites_rerun=False, aggregate_or_corpus_executions=0, recognition_fixed_Hello_fixture_called=False)
    args.output.write_text(json.dumps(record, indent=2)+'\n')
    baseline['offline_run'] = dict(started_utc=start, completed_utc=record['completed_utc'], elapsed_seconds=record['elapsed_seconds'],
        run_kind='Hello retained from same focused recognition checker; accepted predecessor/source suites reused')
    (HERE / 'result.json').write_text(json.dumps(baseline, indent=2)+'\n')
    print(json.dumps({key: record[key] for key in ('status', 'check_count', 'elapsed_seconds')}))


if __name__ == '__main__':
    main()
