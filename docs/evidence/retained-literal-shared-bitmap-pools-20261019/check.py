#!/usr/bin/env python3
"""New arithmetic/interface checks only; handwritten reachability is separate."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import platform
import time
from derive import (Context,HERE,REPO,I32,U32,bitmap_domain,endpoints,
                    evaluate_default,evaluate_source,pool,read)


def main():
    start = time.monotonic()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,
        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--output',type=Path,default=HERE/'check-results.json')
    args = parser.parse_args()
    context,checks = Context(args.gcc_root),[]

    def check(name,value):
        if not value:
            raise AssertionError(name)
        checks.append(name)

    def reject(name,callback):
        try:
            callback()
        except (ValueError,TypeError):
            checks.append(name)
        else:
            raise AssertionError('accepted '+name)

    row = evaluate_default(context)
    check('retained actual-source result',row == read(HERE/'result.json'))
    check('actual-source accepted owner join',row['same_source_accepted_owners_verified'])
    check('Hello extents',row['extents'] == dict(K=104,U=29,Uf=53,B=10,G=4,M=27,P=64))
    alloc = row['bitmap_allocator']
    check('fixed ordinary chunk request',alloc['individual_initial_chunk_bytes'] ==
        alloc['individual_later_chunk_bytes'] == 65536 and
        alloc['largest_newchunk_formula_bytes'] == 147)
    check('lifetime history is not a bitmap count field',
        not alloc['cumulative_chunk_or_element_count_field'] and
        alloc['lifetime_chunk_requests_upper'] is None and
        not alloc['lifetime_chunk_count_required_for_representation'])
    check('positive default depth counts nesting',alloc['default_depth_upper'] == 9 and
        alloc['default_depth_counts_nesting_not_lifetime_initializations'])
    cache = row['shared_block_cache']
    check('returned shared block cache has no cumulative count',
        not cache['stored_block_count_field'] and cache['default_trim_retained_blocks'] == 16 and
        cache['returned_blocks_can_outlive_their_original_typed_pool_or_obstack'])
    df = row['DF_bitmap_families']
    check('scan generations have separate private lifetimes',df['scan_generations'] == 2 and
        not df['generations_coexist'] and df['scan_register_live_elements_upper'] == 5 and
        df['scan_instruction_live_elements_upper'] == 3)
    check('LR four embedded sets per block',df['LR_embedded_heads_upper'] == 40 and
        df['LR_live_elements_upper'] == 40 and not df['LR_verification_copies_selected'])
    pp = row['program_points']
    check('point-frequency initial reserve need not cover ceiling',
        pp['initial_point_frequency_reserve_upper'] == 58 < pp['point_frequency_length_upper'] == 64 and
        pp['point_frequency_capacity_upper'] == 128 and pp['point_frequency_request_bytes_upper'] == 520)
    check('assignment arrays are distinct ordinary requests',
        pp['assignment_header_arrays'] == 2 and pp['each_assignment_header_array_bytes_upper'] == 2048 and
        pp['reload_inheritance_assignment_bitmap_elements'] == 0)
    lra = row['LRA_additional_pools']
    check('live ranges have actual selected layout and retained slots',
        lra['live_ranges']['live_objects_upper'] == 10 and
        lra['live_ranges']['object_bytes'] == 32 and
        lra['live_ranges']['retained_slots_upper'] == 2047)
    check('copy invariant pools empty while controls retained',
        lra['copy_pool_objects'] == lra['invariant_pool_objects'] == lra['live_range_copies'] == 0 and
        lra['invariant_vector_initial_slots_already_owned'] == 100 and
        lra['invariant_hash_initial_slots_already_owned'] == 127)
    dom = row['dominance']
    check('ET two directions coexist safely',dom['live_nodes_combined_upper'] == 20 and
        dom['live_occurrences_combined_upper'] == 40 and
        dom['signed_relative_depth_intermediate_magnitude_upper'] == 80)
    check('ET actual selected pool sizes cover stored free slots',
        [p['object_bytes'] for p in dom['ordinary_pools']] == [64,48] and
        [p['retained_slots_upper'] for p in dom['ordinary_pools']] == [1023,1365])
    check('existing owner rows are preserved',
        row['retained_bitmap_owner_rows']['no_predecessor_event_owner_recharged'] and
        not dom['initial_CF_SSA_and_RTL_cold_block_owners_recharged'])
    check('callback effect and scalar owner preserved',row['collector_callback_GGC_events'] == 0 and
        row['collector_marker_individual_ordinary_request_bytes'] == 104 and
        row['collector_call_count'] is None and row['retained_scalar_finalizer_history_upper'] == 39275)
    check('local closure without whole native promotion',
        row['conditional_selected_shared_bitmap_and_pool_capacity_established'] and
        row['total_GGC_events'] is None and not any(row[key] for key in (
        'aggregate_RAM_gate','production_admission_changed','whole_literal_pipeline_capacity_established',
        'complete_all_ordinary_helper_lifetimes_closed','complete_array_finalizer_lifetime_closed',
        'complete_collector_lifetime_closed')))
    check('no added GGC events or finalizers',all(row[key] == 0 for key in
        ('new_GGC_events','new_scalar_registrations','new_array_registrations')))
    check('no prohibited execution',all(row[key] == 0 for key in
        ('native_tool_executions','accepted_component_suites_rerun','aggregate_executions','corpus_checkers_rerun')))

    raw = (REPO/'samples/hello_world.adb').read_bytes()
    def invoke(source=raw,**changed):
        return evaluate_source(source,*(changed.get(name,getattr(context,name))
            for name in ('pipeline','query','mem')),context)
    reject('same counts changed source bytes',lambda:invoke(source=raw+b'\n'))
    for name in ('pipeline','query','mem'):
        changed = copy.deepcopy(getattr(context,name))
        changed['source']['sha256'] = '0'*64
        reject('changed '+name+' source identity',lambda name=name,changed=changed:invoke(**{name:changed}))
    mutations = [
        ('query',('counter_endpoints','next_DECL_UID_upper'),1),
        ('query',('scalar_finalizers','historical_registrations_upper'),0),
        ('mem',('RTL','final_first_unused_pseudo_upper'),101),
        ('mem',('RTL','final_first_unused_UID_upper'),29),
        ('mem',('DF','scan_generations'),1),
        ('mem',('DF','scan_rebuild_releases_old_pools_before_allocating_new'),False),
        ('mem',('LRA','last_reg_value_upper'),1),
        ('pipeline',('RTL_shape','IRA_entry_chain'),0),
        ('pipeline',('native_initial_SSA_lifetime','ordinary_requests','shared_kills_bitmap_live_elements_upper'),0),
        ('pipeline',('native_initial_CF_CFG_lifetime','ordinary_requests','shared_altered_bitmap_live_elements_upper'),0),
        ('pipeline',('native_SSA_helper_backing','ranger_per_instance','bitmap_obstack_initial_chunks_upper'),0),
        ('pipeline',('native_SSA_helper_backing','out_of_SSA','shared_default_bitmap_headers_upper'),0),
        ('pipeline',('native_collector_callbacks','collector_callback_additional_GGC_events'),1),
    ]
    for name,path,value in mutations:
        changed = copy.deepcopy(getattr(context,name))
        target = changed
        for part in path[:-1]:
            target = target[part]
        target[path[-1]] = value
        reject('altered owner '+name+'.'+'.'.join(path),
            lambda name=name,changed=changed:invoke(**{name:changed}))
    for args_bad in ((0,0,1),(1,-1,1),(True,0,1),(1,False,1),(1,0,0)):
        reject('invalid counts '+str(args_bad),lambda args_bad=args_bad:endpoints(*args_bad,context))

    cases = 0
    for c in (1,2,19,20,100,1000,10000):
        for n in (0,1,100):
            r = endpoints(c,n,5875+5*c+n,context)
            assert r['extents']['P'] == 14*c+12*n+50
            assert r['conditional_selected_shared_bitmap_and_pool_capacity_established']
            assert r['LRA_additional_pools']['live_ranges']['live_objects_upper'] == 10*c
            cases += 1
    check('count transfer matrix',cases == 21)
    bitmap_cases = 0
    for x in (0,1,127,128,129,255,256,I32,U32-127,U32-126,U32):
        r = bitmap_domain(x)
        assert r['live_elements_per_header_upper']*128 >= x
        assert r['fits'] == (x <= U32-127)
        bitmap_cases += 1
    check('sparse bitmap arithmetic endpoints',bitmap_cases == 11)
    pool_cases = 0
    for size in (32,48,64):
        slots = 65528//size
        for objects,blocks in ((0,0),(1,1),(slots,1),(slots+1,2),(2*slots,2),(2*slots+1,3)):
            p = pool('boundary',objects,size)
            assert p['retained_blocks_upper'] == blocks
            assert p['allocated_and_free_count_upper'] == slots*blocks >= objects
            pool_cases += 1
    check('pool retained free-slot boundaries',pool_cases == 18)
    # Independent model of repeated return/reuse, with far more allocations than live objects.
    slots,allocated,free,blocks,history = 2047,0,0,0,0
    for _ in range(10000):
        if free == 0:
            allocated += slots; free += slots; blocks += 1
        free -= 1; history += 1
        free += 1
    check('allocation history does not grow retained pool count',
        history == 10000 and blocks == 1 and allocated == free == 2047)
    depth,peak,initializations = 0,0,0
    for _ in range(1000):
        for _ in range(9):
            depth += 1; peak = max(peak,depth); initializations += 1
        for _ in range(9):
            depth -= 1
            assert depth >= 0
    check('balanced default scopes retain bounded nesting',
        depth == 0 and peak == 9 and initializations == 9000)
    check('finished header and element chunks stay fixed',all(
        max(65536,length+7+100) == 65536 for length in (32,40)))
    for key,threshold in (
        ('program_point_finish_plus_one_signed',(I32-1-64)//12),
        ('point_frequency_capacity_31_bits',(I32//2-64)//12),
        ('ET_DFS_and_relative_depth_signed',(I32//8-10)//2)):
        good = endpoints(1,threshold,5877+threshold,context)['local_representation_checks']
        bad = endpoints(1,threshold+1,5878+threshold,context)['local_representation_checks']
        check('exact guard boundary '+key,good[key] and not bad[key])
    check('large native inputs fail without enumeration',not endpoints(I32,U32,I32,context)[
        'conditional_selected_shared_bitmap_and_pool_capacity_established'])
    result = dict(passed=True,checks=checks,check_count=len(checks),
        arithmetic_cases=cases,bitmap_boundary_cases=bitmap_cases,pool_boundary_cases=pool_cases,
        source_files_verified=context.source_files,repository_inputs_verified=context.repository_files,
        elapsed_seconds=time.monotonic()-start,completed_utc=datetime.now(timezone.utc).isoformat(),
        host=platform.platform(),python=platform.python_version(),
        native_tool_executions=0,accepted_component_suites_rerun=0,
        aggregate_executions=0,corpus_checkers_rerun=0,
        handwritten_source_argument_validated_by_these_checks=False)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({key:result[key] for key in ('passed','check_count','arithmetic_cases',
        'bitmap_boundary_cases','pool_boundary_cases','elapsed_seconds')}))


if __name__ == '__main__':
    main()
