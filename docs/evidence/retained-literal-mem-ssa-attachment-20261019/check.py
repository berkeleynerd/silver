#!/usr/bin/env python3
"""New focused interface/arithmetic checks; one Context, no old-suite replay."""
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
    start = datetime.now(timezone.utc).isoformat()
    timer = time.perf_counter()
    m = runpy.run_path(str(HERE/'compose.py'))
    parser = argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(m['PIPELINE']/'compose.py'))['arguments'](parser)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    ctx = m['Context'](args.gcc_root, args.ada_root, args.plugin_include, args.gcc_match)
    rows, variants = [], []
    def check(name, value):
        if not value:
            raise AssertionError(name)
        rows.append(name)
    def reject(name, fn, fragment):
        try:
            fn()
        except ValueError as exc:
            check(name, fragment in str(exc))
        else:
            raise AssertionError(name+' accepted')
    def mutate(obj, path, value):
        obj = copy.deepcopy(obj)
        target = obj
        for part in path[:-1]:
            target = target[part]
        target[path[-1]] = value
        return obj
    check('MEM historical prose view restored and actual executable paths retained',
        ctx.mem['Context'].__init__.__globals__['REPO'] == m['REPO'] and
        ctx.mem['E'] == m['E'] and ctx.mem_context.source_files == 56 and
        ctx.validation['SSA'] == dict(compiler=24, repository=8, excerpts=26))
    capture = []
    original_evaluate = ctx.prior['evaluate']
    def captured(*a, **kw):
        result = original_evaluate(*a, **kw)
        capture.append(result)
        return result
    ctx.prior['evaluate'] = captured
    hello = (m['REPO']/'samples/hello_world.adb').read_bytes()
    shell = b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    source_cases = [('Hello', hello),
        ('same_counts_other_bytes', hello.replace(b'Hello, world!', b'Other, world!')),
        ('mixed_empty_literals_and_nulls', shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("xy"); null;\nend Main;\n'),
        ('later_register_growth_C20', shell+b'Silver_IO.Put_Line ("x");\n'*20+b'end Main;\n'),
        ('pre_split_owner_grows_C34', shell+b'Silver_IO.Put ("x");\n'*34+b'end Main;\n')]
    with tempfile.TemporaryDirectory(prefix='mem-ssa-attachment-', dir=m['REPO']/'tmp') as temp:
        source_path = Path(temp)/'main.adb'
        for name, raw in source_cases:
            source_path.write_bytes(raw)
            result = m['evaluate'](m['PIPELINE']/'selected-route.json', ctx,
                None if name == 'Hello' else source_path)
            prior = capture[-1]
            mem = result['selected_native_MEM_counter_lifetime']
            ssa = result['selected_native_SSA_lifetime_extension']
            attachment = result['mem_ssa_attachment']
            owners = attachment['owners']
            c = result['source_counts']['output_calls']
            check(name+' actual source and full counts in both new leaves',
                result['source'] == m['identity'](raw) and all(leaf['source'] == result['source'] and
                    leaf['source_counts'] == result['source_counts'] for leaf in (mem, ssa)))
            check(name+' inherited149 guard values and conjunctive178 maps retained',
                len(prior['conditions']) == 149 and len(result['conditions']) == 178 and
                all(result['conditions'][k] == v for k,v in prior['conditions'].items()) and
                all(result['conditional_conditions'][k] == v for k,v in prior['conditional_conditions'].items()) and
                result['conditions'] == result['conditional_conditions'] and
                result['evaluated_predicates_pass'] and result['conditional_arithmetic_pass'] and
                not result['failed_predicates'] and not result['unresolved_predicates'])
            check(name+' inherited core query lifetimes and event owners preserved',
                result['core_result'] == prior['core_result'] and
                result['lifetime_attachment'] == prior['lifetime_attachment'] and
                result['selected_native_shared_query_lifetime'] == prior['selected_native_shared_query_lifetime'] and
                attachment['predecessor_event_owners'] == prior['lifetime_attachment']['event_owners'])
            check(name+' existing5C MEM owner extended with zero new records',
                owners['mem_attrs']['existing_variable_records'] == 5*c and
                owners['mem_attrs']['new_later_records'] == 0 and
                owners['mem_attrs']['existing_fixed_setup_envelope'] == 437 and
                not owners['mem_attrs']['fixed_setup_added_again'])
            check(name+' register delta disjoint from operation and initial owners',
                owners['later_register_arrays']['existing_pre_split_growths']+
                owners['later_register_arrays']['new_GGC_pointer_backings'] ==
                owners['later_register_arrays']['complete_growths'] and
                owners['later_register_arrays']['new_GGC_pointer_backings'] ==
                owners['later_register_arrays']['new_ordinary_alignment_requests'] ==
                mem['new_GGC_backing_events_upper'] and
                not owners['later_register_arrays']['initial_dummy_and_Main_owners_added_again'])
            check(name+' SSA initial allowance extended without duplicate events',
                owners['SSA']['retained_initial_GGC_events'] == 6*c+10+ssa['operand_slabs_upper'] and
                all(owners['SSA'][k] == 0 for k in ('new_later_GGC_events', 'helper_events_added_again',
                    'scalar_registration_added_again')) and ssa['source_lifetime_closed'] and
                ssa['retained_initial_guards'] == prior['core_result']['native_initial_SSA_lifetime']['local_representation_checks'])
            df = owners['DF']
            check(name+' DF per-generation and lifetime requests kept distinct',
                df['generations'] == 2 and df['old_generation_released_before_next'] and
                df['new_ordinary_lifetime_block_requests'] == 2*df['new_ordinary_blocks_per_generation'] and
                df['GGC_events'] == 0 and not df['existing_register_pool_added_again'])
            check(name+' frozen old pending and SSA-open fields remain historical',
                mem['independent_review_status'] == 'pending' and
                mem['SSA']['later_SSA_allocation_events_upper'] is None and
                not mem['SSA']['all_phase_SSA_allocation_lifetime_closed'] and
                attachment['frozen_MEM_and_predecessor_pending_flags_preserved_as_history'] and
                all(attachment['accepted_current_scopes'].values()))
            check(name+' no global capacity or total promotion',
                result['complete_imported_allocation_events'] is None and
                result['complete_imported_allocation_bytes'] is None and
                attachment['total_GGC_events'] is mem['total_GGC_events'] is ssa['total_GGC_events'] is None and
                all(result[k] is False for k in ('whole_literal_pipeline_capacity_established',
                    'complete_native_capacity', 'complete_proof_pipeline_capacity', 'complete_parent_storage_closed',
                    'production_launcher_adopted', 'production_admission_changed', 'aggregate_RAM_gate')) and
                not mem['complete_collector_lifetime_closed'] and not mem['complete_global_counter_lifetime_closed'] and
                'shared bitmap/ET' in result['open_joins']['native_remaining_lifetime_and_collector'])
            if name == 'Hello':
                baseline, incoming = result, prior
                check('Hello exact accepted MEM result reused at actual input', mem == m['read'](m['MEM']/'result.json'))
                frozen_ssa = m['read'](m['SSA']/'result.json')
                check('Hello same17 SSA events and all accepted retained owner fields',
                    owners['SSA']['retained_initial_GGC_events'] == 17 and all(ssa[k] == frozen_ssa[k]
                        for k in ('retained_initial_SSA_owned_GGC_events_upper',
                            'retained_initial_individual_GGC_request_groups', 'retained_initial_guards',
                            'conditional_selected_SSA_lifetime_fits', 'additional_GGC_events_charged',
                            'additional_scalar_registrations_charged', 'helper_SSA_owners_added_again')))
                check('Hello DF60 per generation120 lifetime and old768231213 owners unchanged',
                    df['new_ordinary_blocks_per_generation'] == 60 and df['new_ordinary_lifetime_block_requests'] == 120 and
                    result['core_result']['native_original_shared_storage']['interface']['additional_shared_GGC_backing_request_events_upper'] == 768 and
                    result['core_result']['native_original_shared_storage']['partial_ledger']['known_selected_GGC_event_subtotal'] == 2312 and
                    result['selected_native_location_lifetime']['additional_location_and_later_warning_GGC_events_upper'] == 13)
            elif name == 'later_register_growth_C20':
                check('C20 actual-source register delta adds one pointer and one alignment backing',
                    owners['later_register_arrays']['existing_pre_split_growths'] == 0 and
                    owners['later_register_arrays']['new_GGC_pointer_backings'] == 1 and
                    owners['later_register_arrays']['individual_pointer_request_bytes_upper'] == 3168)
            elif name == 'pre_split_owner_grows_C34':
                check('C34 actual-source pre-split owner accounts for sole growth',
                    owners['later_register_arrays']['existing_pre_split_growths'] == 1 and
                    owners['later_register_arrays']['new_GGC_pointer_backings'] == 0)
            if name != 'Hello':
                check(name+' cannot reuse Hello identity', result['source'] != baseline['source'])
            variants.append(dict(name=name, source=result['source'], counts=result['source_counts'],
                guards=len(result['conditions']), passed=result['evaluated_predicates_pass'], owners=owners))
        # Descriptor mismatch is rejected before evaluating any source/native path.
        descriptor = m['read'](m['PIPELINE']/'selected-route.json')
        descriptor['core_descriptor'] = str(m['PIPELINE']/'selected-core-fixture.json')
        descriptor['host_page_bytes'] = 8192
        changed_descriptor = Path(temp)/'changed-route.json'
        changed_descriptor.write_text(json.dumps(descriptor))
        reject('reject changed actual selected configuration',
            lambda: m['evaluate'](changed_descriptor, ctx), 'fixed path/page class')
    ctx.prior['evaluate'] = original_evaluate
    for key in incoming['conditions']:
        changed = copy.deepcopy(incoming)
        changed['conditions'][key] = changed['conditional_conditions'][key] = False
        result = m['attach'](hello, changed, ctx)
        check('inherited failed predicate retained '+key, result['failed_predicates'] == [key] and
            result['failed_conditional_predicates'] == [key] and not result['evaluated_predicates_pass'] and
            not result['conditional_arithmetic_pass'])
    # Fault-inject only new returned arithmetic values, after the source/owner
    # joins, to show that no new bool is silently asserted true or ignored.
    leaves = dict(MEM=baseline['selected_native_MEM_counter_lifetime'],
                  SSA=baseline['selected_native_SSA_lifetime_extension'])
    paths = [('MEM', ['local_representation_checks', k]) for k in leaves['MEM']['local_representation_checks']]
    paths += [('MEM', ['emission_guards', k]) for k in leaves['MEM']['emission_guards']]
    paths += [('MEM', ['conditional_selected_chronology_and_pool_capacity_established'])]
    paths += [('SSA', ['retained_initial_guards', k]) for k in leaves['SSA']['retained_initial_guards']]
    paths += [('SSA', ['conditional_selected_SSA_lifetime_fits'])]
    def patched_attach(label, leaf):
        if label == 'MEM':
            globals_ = ctx.mem
            name = 'evaluate_source'
        else:
            globals_ = m['attach'].__globals__
            name = 'ssa_extension'
        original = globals_[name]
        globals_[name] = lambda *a, **kw: copy.deepcopy(leaf)
        try:
            return m['attach'](hello, incoming, ctx)
        finally:
            globals_[name] = original
    for label, path in paths:
        result = patched_attach(label, mutate(leaves[label], path, False))
        check('new false raw predicate retained '+label+'.'+'.'.join(path),
            len(result['failed_predicates']) == 1 and result['failed_predicates'] == result['failed_conditional_predicates'] and
            result['failed_predicates'][0] in result['mem_ssa_attachment']['guards'] and
            not result['evaluated_predicates_pass'] and not result['conditional_arithmetic_pass'])
    reject('reject nonboolean new arithmetic flag',
        lambda: patched_attach('SSA', mutate(leaves['SSA'], ['retained_initial_guards', paths[-2][1][-1]], 1)),
        'boolean attached arithmetic')
    for path, value, fragment in [
        (['source', 'sha256'], '0'*64, 'selected actual source'),
        (['source_counts', 'maximum_literal_length'], 0, 'selected actual source'),
        (['core_result', 'source', 'sha256'], '0'*64, 'actual source'),
        (['selected_native_shared_query_lifetime', 'source_counts', 'decoded_literal_bytes'], 0, 'actual source'),
        (['selected_native_shared_query_lifetime', 'counter_endpoints', 'next_DECL_UID_upper'], 0, 'counter endpoints'),
        (['core_result', 'native_initial_SSA_lifetime', 'additional_GGC_request_events_upper'], 0, 'initial SSA owner'),
        (['core_result', 'native_initial_SSA_lifetime', 'additional_singleton_finalizer_registrations_upper'], 0, 'initial SSA owner'),
        (['core_result', 'native_initial_SSA_lifetime', 'individual_GGC_request_groups', 0, 'requests_upper'], 0, 'initial SSA owner'),
        (['core_result', 'native_initial_SSA_lifetime', 'ordinary_requests', 'ET_node_pool_blocks_upper'], 0, 'initial SSA owner')]:
        reject('reject changed actual input '+'.'.join(map(str, path)),
            lambda path=path, value=value: m['attach'](hello, mutate(incoming, path, value), ctx), fragment)
    for label in ('MEM', 'SSA'):
        for path, value in [(['source', 'sha256'], '0'*64), (['source_counts', 'maximum_literal_length'], 0)]:
            reject('reject changed leaf full identity/counts '+label+'.'+'.'.join(path),
                lambda label=label, path=path, value=value: patched_attach(label, mutate(leaves[label], path, value)),
                'attached actual source and complete counts')
    for label, path, value, fragment in [
        ('MEM', ['mem_attrs', 'variable_records_already_owned'], 0, 'MEM existing5C'),
        ('MEM', ['mem_attrs', 'fixed_setup_recharged'], True, 'MEM existing5C'),
        ('MEM', ['new_GGC_backing_events_upper'], 1, 'disjoint later register'),
        ('MEM', ['DF', 'newly_priced_lifetime_block_requests_upper'], 60, 'DF per-generation'),
        ('MEM', ['DF', 'ordinary_pools', 4, 'blocks_already_priced'], False, 'DF per-generation'),
        ('SSA', ['additional_GGC_events_charged'], 17, 'without second charge'),
        ('MEM', ['complete_collector_lifetime_closed'], True, 'scope remains incomplete')]:
        reject('reject changed new owner/scope '+label+'.'+'.'.join(map(str, path)),
            lambda label=label, path=path, value=value: patched_attach(label, mutate(leaves[label], path, value)), fragment)
    pins = m['read'](HERE/'inputs.json')
    pins['files'][0]['sha256'] = '0'*64
    reject('reject changed accepted pinned record without second Context',
        lambda: ctx.prior['check_pins'](pins), 'changed attachment input')
    reject('equal counts cannot reuse Hello source interface',
        lambda: m['attach'](hello.replace(b'Hello, world!', b'Other, world!'), incoming, ctx),
        'selected actual source')
    arithmetic = []
    initial_fn = ctx.prior_context.selected_context.core['native_initial_ssa_lifetime']
    core_ctx = ctx.prior_context.selected_context.core_context
    df_good = (2**31-1-19076)//17690
    register_good = (198*(1 << 23)-99)//5
    cases = [(1,0), (20,0), (34,0), (df_good,0), (df_good+1,0),
             (register_good,0), (register_good+1,0), (2**31,0), (1,2**32)]
    for c, n in cases:
        mem = ctx.mem['endpoints'](c, n, ctx.mem_context)
        emission = core_ctx.emission['evaluate'](c, n, c, 1)
        mem['emission_guards'] = emission['counter_and_emission_guards']
        mem['conditional_selected_chronology_and_pool_capacity_established'] &= all(mem['emission_guards'].values())
        initial = initial_fn(c, n, core_ctx)
        ssa = dict(retained_initial_guards=initial['local_representation_checks'],
            conditional_selected_SSA_lifetime_fits=initial['conditional_initial_SSA_lifetime_closed'])
        guards = m['arithmetic_guards'](mem, ssa)
        check('count-only arithmetic guard conjunction '+str((c,n)), len(guards) == 29 and
            all(guards.values()) == (c <= df_good and n == 0))
        arithmetic.append(dict(C=c, N=n, passed=all(guards.values()),
            failed=[k for k,v in guards.items() if not v],
            later_pointer_backings=mem['new_GGC_backing_events_upper']))
    check('DF exact signed comparator boundary fails without dropped predicate',
        'native_mem_ssa_MEM_inherited_RTL_DF_LRA_checks' in arithmetic[4]['failed'] and
        not arithmetic[3]['failed'])
    check('register signed doubling exact boundary retained',
        'native_mem_ssa_MEM_Main_register_array_signed_doubling' not in arithmetic[5]['failed'] and
        'native_mem_ssa_MEM_Main_register_array_signed_doubling' in arithmetic[6]['failed'])
    check('large SSA arithmetic failures retained without constructing huge source',
        any(k.startswith('native_mem_ssa_SSA_') for k in arithmetic[7]['failed']) and
        any(k.startswith('native_mem_ssa_SSA_') for k in arithmetic[8]['failed']))
    completed = datetime.now(timezone.utc).isoformat()
    baseline['offline_run'] = dict(started_utc=start, completed_utc=completed,
        scope='Hello generated once in new focused attachment run; no native execution')
    (HERE/'result.json').write_text(json.dumps(baseline, indent=2)+'\n')
    result = dict(started_utc=start, completed_utc=completed, elapsed_seconds=time.perf_counter()-timer,
        passed=True, checks=len(rows), check_names=rows, actual_source_variants=variants,
        count_only_arithmetic_cases=arithmetic, inherited_guard_count=149, new_guard_count=29,
        total_guards=178, new_contexts=1, validation=ctx.validation,
        selected_model='GPT-6.1 Sol', selected_effort='Extra High', runtime_confirmed_model_effort=None,
        token_cost_measurements=None, host=platform.system()+' '+platform.release()+' '+platform.machine(),
        native_tool_executions=0, predecessor_suites_rerun=False, large_corpus_rerun=False,
        build_prover_solver_capture_runs=0, runtime_census_reinventoried=False,
        implementation_inputs={name:m['identity']((HERE/name).read_bytes()) for name in ('compose.py', 'check.py', 'inputs.json')},
        reused_evidence='Accepted lifetime204; MEM49/27 count cases/48 register boundaries/42 pool boundaries; SSA66; predecessor successes and exact acceptance reports. None replayed.',
        source_proof_scope='Finite interface/arithmetic corroboration only; accepted handwritten selected-branch arguments supply source lifetime claims.')
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('passed', 'checks', 'total_guards', 'elapsed_seconds')}))


if __name__ == '__main__':
    main()
