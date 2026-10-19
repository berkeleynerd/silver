#!/usr/bin/env python3
"""Only new focused source-interface and arithmetic checks; no native replay."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import time
from derive import (Context, HERE, REPO, I32, U32, collection_capacity,
                    endpoints, evaluate_default, evaluate_source, pool, read,
                    register_capacity)


def main():
    start = time.monotonic()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path,
        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--output', type=Path, default=HERE/'check-results.json')
    args = parser.parse_args()
    context = Context(args.gcc_root)
    checks = []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checks.append(name)

    def reject(name, callback):
        try:
            callback()
        except (ValueError, TypeError):
            checks.append(name)
        else:
            raise AssertionError('accepted '+name)

    result = evaluate_default(context)
    check('exact retained-source result', result == read(HERE/'result.json'))
    check('source and predecessor owners joined', result['same_source_predecessor_owners_verified'])
    mem = result['mem_attrs']
    check('five variable MEM records keep their original owner',
          mem['variable_records_already_owned'] == mem['pool_setter_records_upper']+
              mem['call_setter_records_upper'] == 5)
    check('raw frame copy and CFI add no MEM records', all(mem[k] == 0 for k in
          ('frame_records','copy_records','CFI_records','later_additional_records','hash_backing_requests')))
    check('fixed setup437 not recharged', mem['fixed_setup_events_already_owned'] == 437 and
          not mem['fixed_setup_recharged'])
    rtl = result['RTL']
    check('dummy Main initialize independently', rtl['dummy_then_Main_init_emit_calls'] == 2 and
          not rtl['dummy_pseudo_arrays_reused_by_Main'] and rtl['dummy_alignment_array_freed_before_Main'])
    check('final UID pseudo and capacity bound',
          (rtl['final_first_unused_UID_upper'],rtl['final_first_unused_pseudo_upper'],
           rtl['final_array_capacity_upper']) == (53,104,198))
    check('global labels are preserved', not rtl['global_labels_reset_at_Main_entry'] and
          result['emission_counter_endpoints']['ordinary_label_next_at_exit_upper'] == 39310)
    check('final register growth adds no Hello request', result['new_GGC_backing_events_upper'] == 0)
    cross = endpoints(20,0,context)
    check('split LRA growth crosses capacity before operation alone',
          cross['RTL']['pre_split_growths_already_owned'] == 0 and
          cross['RTL']['complete_Main_growths_upper'] == cross['new_GGC_backing_events_upper'] == 1 and
          cross['RTL']['final_array_capacity_upper'] == 396)
    check('alias vector starts cold and remains two owned requests',
          result['alias_vectors']['incoming_old_base_capacity'] == 0 and
          result['alias_vectors']['requests_already_owned'] == 2 and
          result['alias_vectors']['rounded_requests_upper'] == [128,1024] and
          result['alias_vectors']['new_requests_in_this_packet'] == 0)
    ssa = result['SSA']
    check('SSA versions are per function and statistics are not capacities',
          ssa['helper_name_vector_lengths_upper'] == [5,7] and
          ssa['Main_initial_name_vector_length_upper'] == 5 and
          ssa['known_helper_plus_initial_Main_creation_events_upper'] == 14 and
          not ssa['global_statistics_used_for_capacity'] and
          not ssa['global_creation_and_reuse_statistics_reset'])
    check('SSA allocation lifetime remains distinct and open',
          ssa['later_SSA_allocation_events_upper'] is None and not ssa['all_phase_SSA_allocation_lifetime_closed'])
    df = result['DF']
    check('DF lifetime spans scan reconstruction', df['instances'] == 1 and df['scan_generations'] == 2 and
          not df['scan_rebuild_resets_ref_order'] and df['ref_order_final_upper'] == 36766)
    check('DF LR solver is per analysis', df['LR_solver_visits_upper_per_analysis'] == 946)
    pools = df['ordinary_pools']
    check('DF pool class sizes and block counts',
          [p['blocks_per_generation_upper'] for p in pools] == [18,20,21,1,1,0] and
          [p['objects_per_block'] for p in pools] == [1023,910,910,1365,4095,2047])
    check('new DF pools exclude already-owned register pool',
          df['newly_priced_blocks_upper_per_generation'] == 60 and
          df['newly_priced_lifetime_block_requests_upper'] == 120)
    check('DF generations release before reconstruction', df['scan_rebuild_releases_old_pools_before_allocating_new'])
    check('ordinary pools register no GGC finalizers', all(p[k] == 0 for p in
          pools+result['LRA']['ordinary_pools'] for k in ('GGC_events','scalar_finalizers','array_finalizers')))
    vectors = df['collection_vectors']
    check('auto storage transition is not heap growth from32',
          vectors['use']['heap_capacities'] == [33,49,73,109] and
          vectors['use']['individual_heap_requests_bytes'] == [272,400,592,880])
    check('other collection vectors stay inline', all(vectors[k]['heap_requests_per_record_upper'] == 0
          for k in ('definition','note_use','multiword')))
    check('LRA value counter and pools reset per invocation', result['LRA']['last_reg_value_initial'] == 0 and
          result['LRA']['last_reg_value_upper'] == 157 and result['LRA']['pools_released_at_finish'] and
          result['LRA']['recognition_pointer_incoming_capacity'] == 0)
    check('cfun backing and cold sequence owners retained', result['stacks']['cfun_additional_backings'] == 0 and
          result['stacks']['cfun_backing_bytes_already_owned'] == 40 and
          result['stacks']['sequence_cache_deletable'] and
          result['stacks']['sequence_cache_peak_does_not_replace_lifetime_events'])
    check('selected arithmetic passes without whole-pipeline promotion',
          result['conditional_selected_chronology_and_pool_capacity_established'] and
          not any(result[k] for k in ('complete_global_counter_lifetime_closed',
            'complete_array_finalizer_lifetime_closed','complete_collector_lifetime_closed',
            'complete_all_ordinary_helper_lifetimes_closed','whole_literal_pipeline_capacity_established',
            'production_admission_changed','aggregate_RAM_gate')) and result['total_GGC_events'] is None)
    check('no prohibited replay', all(result[k] == 0 for k in ('native_tool_executions',
          'accepted_component_suites_rerun','aggregate_executions','corpus_checkers_rerun')))

    raw = (REPO/'samples/hello_world.adb').read_bytes()
    def invoke(pipeline=None, query=None, source=raw):
        return evaluate_source(source, context.pipeline if pipeline is None else pipeline,
            context.query if query is None else query, context)
    reject('same counts different source bytes', lambda: invoke(source=raw+b'\n'))
    for packet in ('pipeline','query'):
        p = copy.deepcopy(getattr(context,packet))
        p['source']['sha256'] = '0'*64
        reject('mismatched '+packet+' identity', lambda p=p,packet=packet:invoke(**{packet:p}))
    mutations = [
        (('RTL_shape','first_unused_pseudo_number_upper'),101),
        (('RTL_shape','register_array_capacity_upper'),0),
        (('selected_native_backing','DF_selected_reference_and_solver_transfer','ref_order_final_upper'),32),
        (('native_lowering_data','conditional_native_selected_constructor_requests','pool_and_call_mem_attrs_requests_upper'),0),
        (('native_lowering_data','conditional_native_selected_constructor_requests','register_pointer_array_GGC_growth_requests_upper'),1),
        (('native_initial_SSA_lifetime','additional_global_SSA_name_creation_events_upper'),0),
        (('native_complete_emission_interface','counter_bounds','ordinary_label_next_at_prefix_exit_upper'),1),
        (('native_complete_emission_interface','counter_bounds','constant_label_next_at_exit_upper'),2),
        (('native_complete_emission_interface','emission','emitted_function_bodies'),3),
    ]
    for path,value in mutations:
        p = copy.deepcopy(context.pipeline)
        target = p
        for part in path[:-1]:
            target = target[part]
        target[path[-1]] = value
        reject('erased inherited '+'.'.join(path),lambda p=p:invoke(pipeline=p))
    q = copy.deepcopy(context.query)
    q['counter_endpoints']['next_DECL_UID_upper'] = 1
    reject('reset inherited compilation UID',lambda:invoke(query=q))
    for c,n in ((0,0),(1,-1),(True,0),(1,False)):
        reject('invalid domain '+str((c,n)),lambda c=c,n=n:endpoints(c,n,context))

    cases = 0
    for c in (1,2,19,20,21,59,60,1000,10000):
        for n in (0,1,100):
            row = endpoints(c,n,context)
            assert row['mem_attrs']['variable_records_already_owned'] == 5*c
            assert row['DF']['ref_order_final_upper'] == 17690*c+368*n+19076
            assert row['RTL']['pre_split_growths_already_owned']+row['new_GGC_backing_events_upper'] == \
                row['RTL']['complete_Main_growths_upper']
            assert row['conditional_selected_chronology_and_pool_capacity_established']
            cases += 1
    check('source-count transfer matrix',cases == 27)
    boundary_cases = 0
    for q in range(24):
        cap = 198*(1 << q)
        assert register_capacity(cap) == (q,cap)
        assert register_capacity(cap+1) == (q+1,2*cap)
        boundary_cases += 2
    check('all signed register doubling boundaries',boundary_cases == 48)
    cgood = (198*(1 << 23)-99)//5
    check('register overflow boundary survives other guards',
          endpoints(cgood,0,context)['local_representation_checks']['Main_register_array_signed_doubling'] and
          not endpoints(cgood+1,0,context)['local_representation_checks']['Main_register_array_signed_doubling'])
    cgood = (I32-19076)//17690
    check('DF comparator exact signed boundary',
          endpoints(cgood,0,context)['local_representation_checks']['inherited_RTL_DF_LRA_checks'] and
          not endpoints(cgood+1,0,context)['local_representation_checks']['inherited_RTL_DF_LRA_checks'])
    check('large native inputs fail guards', not endpoints(I32,0,context)[
        'conditional_selected_chronology_and_pool_capacity_established'] and
        not endpoints(1,U32,context)['conditional_selected_chronology_and_pool_capacity_established'])
    pool_cases = 0
    for size in (16,24,32,48,64,72,80):
        slots = 65528//size
        for length,blocks in ((0,0),(1,1),(slots,1),(slots+1,2),(2*slots,2),(2*slots+1,3)):
            row = pool('boundary',length,size,2)
            assert row['blocks_per_generation_upper'] == blocks
            assert row['allocated_and_free_count_upper'] == slots*blocks
            assert row['lifetime_block_requests_upper'] == 2*blocks
            pool_cases += 1
    check('pool capacity block and generation transitions',pool_cases == 42)
    for length,history in ((32,[]),(33,[33]),(34,[33,49]),(49,[33,49]),
                           (50,[33,49,73]),(73,[33,49,73]),(74,[33,49,73,109])):
        assert collection_capacity(32,length)['heap_capacities'] == history
    check('inline collection growth boundaries',True)
    elapsed = time.monotonic()-start
    args.output.write_text(json.dumps(dict(passed=True, checks=len(checks), check_names=checks,
        arithmetic_cases=cases, register_boundary_cases=boundary_cases, pool_boundary_cases=pool_cases,
        completed_utc=datetime.now(timezone.utc).isoformat(), elapsed_seconds=elapsed,
        source_files_verified=context.source_files, repository_inputs_verified=context.repository_files,
        handwritten_source_argument_independently_reviewed=False, native_tool_executions=0,
        accepted_component_suites_rerun=0, aggregate_executions=0, corpus_checkers_rerun=0),indent=2)+'\n')
    print(json.dumps(dict(passed=True,checks=len(checks),elapsed_seconds=elapsed)))


if __name__ == '__main__':
    main()
