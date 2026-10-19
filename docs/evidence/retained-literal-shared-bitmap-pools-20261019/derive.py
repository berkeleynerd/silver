#!/usr/bin/env python3
"""Focused shared ordinary bitmap and pool join; no predecessor suite replay."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EVIDENCE = REPO/'docs/evidence'
NATIVE = EVIDENCE/'unbounded-programs/retained-native-expansion-20261017'
I32, U32, I64, U64 = 2**31-1, 2**32-1, 2**63-1, 2**64-1


def require(value, message):
    if not value:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


class Context:
    def __init__(self, gcc_root):
        pins = read(HERE/'inputs.json')
        roots = dict(gcc=Path(gcc_root), repository=REPO)
        for row in pins['files']:
            require(identity((roots[row['root']]/row['path']).read_bytes()) ==
                    {k: row[k] for k in ('bytes', 'sha256')},
                    'changed shared-bitmap/pool input '+row['path'])
        self.source_files = sum(r['root'] == 'gcc' for r in pins['files'])
        self.repository_files = sum(r['root'] == 'repository' for r in pins['files'])
        self.recognize = runpy.run_path(str(NATIVE/'derive-literal-output.py'))['source_counts']
        self.backing = runpy.run_path(str(NATIVE/'derive-literal-rtl-backing.py'))['backing']
        self.pipeline = read(EVIDENCE/'retained-literal-pipeline-20261018/result.json')
        self.query = read(EVIDENCE/'retained-literal-shared-query-lifetime-20261019/result.json')
        self.mem = read(EVIDENCE/'retained-literal-mem-counter-lifetime-20261019/result.json')
        self.framework = read(NATIVE/'native-pass-framework.json')


def bitmap_domain(extent):
    require(type(extent) is int and extent >= 0, 'bitmap extent')
    return dict(exclusive_bit_bound=extent, live_elements_per_header_upper=(extent+127)//128,
        range_end_upper=extent, iterator_next_and_rounding_upper=extent+127,
        count_bits_return_type='unsigned long', fits=extent+127 <= U32)


def pool(name, objects, size):
    require(type(objects) is int and objects >= 0 and size in (32,48,64), 'typed pool domain')
    slots = 65528//size
    blocks = (objects+slots-1)//slots
    return dict(family=name, live_objects_upper=objects, object_bytes=size,
        objects_per_block=slots, retained_blocks_upper=blocks,
        retained_slots_upper=slots*blocks, allocated_and_free_count_upper=slots*blocks,
        block_count_upper=blocks, individual_block_request_bytes=65536,
        retained_count_type='size_t', lifetime_block_requests_upper=None,
        lifetime_block_count_required_for_counter_proof=False,
        fits=slots*blocks <= U64 and blocks <= U64,
        new_GGC_events=0, new_scalar_registrations=0, new_array_registrations=0)


def endpoints(c, n, decl_uid, context):
    """Count arithmetic only. Accepted actual-source owners are separate inputs."""
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0 and
            type(decl_uid) is int and decl_uid >= 1, 'literal bitmap/pool domain')
    k, u, uf, b, g, m = 99+5*c, 7*c+5*n+22, 7*c+7*n+46, 2*n+10, n+4, 7*c+5*n+20
    p = 2*m+b
    point_capacity = max(2*u,2*p)
    domains = {key:bitmap_domain(value) for key,value in dict(
        hard_register=92, register=k, final_instruction_UID=uf,
        basic_block=b, initial_GIMPLE_block=g, program_point=p,
        declaration_UID=decl_uid, initial_SSA_version=3*c+2).items()}
    et_pools = [pool('shared dominance ET nodes',2*b,64),
                pool('shared dominance ET occurrences',4*b,48)]
    live_pool = pool('LRA live ranges',10*c,32)
    inherited = context.backing(c,n)
    result = dict(source_input=dict(output_calls=c,null_statements=n,
            next_DECL_UID_upper=decl_uid),
        extents=dict(K=k,U=u,Uf=uf,B=b,G=g,M=m,P=p), bit_domains=domains,
        bitmap_allocator=dict(header_bytes=32,element_bytes=40,element_bits=128,
            alignment_bytes=8, individual_initial_chunk_bytes=65536,
            partial_object_bytes_at_newchunk=0, largest_newchunk_formula_bytes=147,
            individual_later_chunk_bytes=65536,
            cumulative_chunk_or_element_count_field=False,
            allocation_statistics_enabled=False,
            default_depth_upper=9,default_depth_type='int',
            default_depth_counts_nesting_not_lifetime_initializations=True,
            selected_shared_obstacks=['default','reg_obstack','df_bitmap_obstack'],
            selected_private_obstacks=['initial SSA','ranger','DF scan registers',
                'DF scan instructions','DF LR','LRA assignment hard-register pseudos',
                'LRA assignment reload/inheritance pseudos'],
            lifetime_chunk_requests_upper=None,
            lifetime_chunk_count_required_for_representation=False,
            combined_live_header_or_element_count_required_for_representation=False,
            GGC_events=0,scalar_registrations=0,array_registrations=0),
        shared_block_cache=dict(individual_block_bytes=65536,
            stored_block_count_field=False,default_trim_retained_blocks=16,
            trim_local_counter_counts_requested_prefix_only=True,
            returned_blocks_can_outlive_their_original_typed_pool_or_obstack=True,
            aggregate_retained_block_count_required_for_representation=False),
        retained_bitmap_owner_rows=dict(
            initial_CF_CFG=dict(shared_headers=3,altered_live_elements=(g+127)//128,other_elements=0),
            initial_SSA=dict(shared_headers=3,kills_live_elements=1,
                kills_fresh_element_requests_upper=g,prune_live_elements=(g+127)//128),
            out_of_SSA=dict(shared_headers=5,elements=0),
            ranger=dict(sequential_instances=2,private_obstacks_each=5,
                headers_each_upper=2*(n+5)+8,elements=0),
            no_predecessor_event_owner_recharged=True),
        DF_bitmap_families=dict(scan_generations=2,generations_coexist=False,
            returned_block_cache_is_separate=True,
            scan_register_heads=5,scan_allocated_register_heads=2,
            scan_register_live_elements_upper=5,
            scan_instruction_embedded_heads=3,
            scan_instruction_live_elements_upper=3*((uf+127)//128),
            LR_embedded_heads_upper=4*b,LR_live_elements_upper=4*b*((k+127)//128),
            LR_verification_copies_selected=False,
            shared_scratch_domain_upper=max(k,uf,b),
            shared_scratch_domains=['register','final_instruction_UID','basic_block'],
            initial_chunks_retain_existing_owners=True),
        reg_bitmap_families=dict(initializations=1,
            domains=['hard_register','register','final_instruction_UID','basic_block','program_point'],
            LRA_per_register_instruction_heads_upper=3*k//2+1,
            LRA_per_register_instruction_live_elements_upper=10*c,
            IRA_dead_point_heads_upper=34,IRA_dead_point_element_domain_upper=p,
            optimizer_and_failure_routes_selected=False),
        program_points=dict(IRA_and_LRA_upper=p,LRA_builds=1,
            per_instruction_increments_upper=2,per_block_increments_upper=1,
            initial_point_frequency_reserve_upper=2*u,
            point_frequency_length_upper=p,
            point_frequency_capacity_upper=point_capacity,
            point_frequency_request_bytes_upper=8+4*point_capacity,
            each_assignment_header_array_bytes_upper=32*p,
            assignment_header_arrays=2,assignment_private_initial_chunks=2,
            assignment_bitmap_register_domain_upper=k,
            reload_inheritance_assignment_bitmap_elements=0,
            each_dense_point_bitmap_bytes_upper=8+8*((p+63)//64),
            dense_point_bitmaps_per_compression=3,compression_map_bytes_upper=4*p,
            each_register_sparseset_bytes_upper=32+8*k,
            compression_only_decreases_point_count=True),
        LRA_additional_pools=dict(live_ranges=live_pool,live_range_builds=1,
            live_range_copies=0,copy_pool_objects=0,invariant_pool_objects=0,
            invariant_vector_initial_slots_already_owned=100,
            invariant_hash_initial_slots_already_owned=127,
            live_range_pool_released_at_finish=True,
            copy_and_invariant_controls_retain_existing_owners=True),
        dominance=dict(functions_with_CFG=1,directions_upper=2,
            live_nodes_combined_upper=2*b,live_occurrences_combined_upper=4*b,
            live_nodes_per_tree_upper=b,fast_DFS_endpoint_per_direction_upper=2*b,
            signed_relative_depth_intermediate_magnitude_upper=8*b,
            old_parent_occurrence_released_before_reparent=True,
            empty_pools_released_and_counts_reset=True,
            ordinary_pools=et_pools,
            initial_CF_SSA_and_RTL_cold_block_owners_recharged=False,
            shared_incoming_and_retained_pool_state_closed=True),
        new_GGC_events=0,new_scalar_registrations=0,new_array_registrations=0,
        total_GGC_events=None,aggregate_RAM_gate=False,production_admission_changed=False,
        whole_literal_pipeline_capacity_established=False,
        complete_all_ordinary_helper_lifetimes_closed=False,
        complete_array_finalizer_lifetime_closed=False,complete_collector_lifetime_closed=False,
        source_reachability_argument_is_handwritten=True,independent_review_status='pending',
        native_tool_executions=0,accepted_component_suites_rerun=0,
        aggregate_executions=0,corpus_checkers_rerun=0)
    checks = dict(inherited_RTL_DF_LRA_representation=all(inherited['local_representation_checks'].values()),
        sparse_bitmap_indices_range_ends_and_rounding=all(x['fits'] for x in domains.values()),
        declaration_UID_signed=decl_uid <= I32,
        bitmap_default_nesting_signed=9 <= I32,
        bitmap_chunk_local_arithmetic=147 <= 65536 <= I64,
        program_point_finish_plus_one_signed=p+1 <= I32,
        point_frequency_initial_unsigned_product=2*u <= U32,
        point_frequency_growth_unsigned_product=3*p <= U32,
        point_frequency_capacity_31_bits=point_capacity <= I32,
        local_array_and_vector_pointer_spans=max(32*p,8+4*point_capacity,4*k) <= I64,
        dense_bitmap_rounding_and_stored_size=p+63 <= U32 and 8+8*((p+63)//64) <= U32,
        sparse_set_unsigned_request=32+8*k <= U32,
        ET_DFS_and_relative_depth_signed=8*b <= I32,
        typed_pool_retained_counters=all(row['fits'] for row in et_pools+[live_pool]))
    result['local_representation_checks'] = checks
    result['conditional_selected_shared_bitmap_and_pool_capacity_established'] = all(checks.values())
    return result


def evaluate_source(raw, pipeline, query, mem, context):
    counts, source = context.recognize(raw), identity(raw)
    require(all(row['source'] == source and row['source_counts'] == counts
                for row in (pipeline,query,mem)), 'same actual source and counts')
    c,n = counts['output_calls'],counts['null_statements']
    d = int(counts['Put'] > 0)+int(counts['Put_Line'] > 0)
    decl = 5869+5*c+n+3*d
    require(query['complete_DECL_UID_lifetime_closed'] and
            query['counter_endpoints']['next_DECL_UID_upper'] == decl and
            mem['inherited_shared_query_counter_endpoints'] == query['counter_endpoints'],
            'accepted shared declaration UID owner')
    require(query['complete_scalar_finalizer_lifetime_closed'] and
            query['scalar_finalizers']['historical_registrations_upper'] == 39257+18,
            'retained scalar finalizer owner')
    result = endpoints(c,n,decl,context)
    ex = result['extents']
    require(mem['same_source_predecessor_owners_verified'] and
            mem['RTL']['final_first_unused_pseudo_upper'] == ex['K'] and
            mem['RTL']['final_first_unused_UID_upper'] == ex['Uf'] and
            mem['DF']['scan_generations'] == 2 and
            mem['DF']['scan_rebuild_releases_old_pools_before_allocating_new'] and
            mem['LRA']['last_reg_value_upper'] == 3*ex['K']//2+1,
            'accepted chronological register UID scan and LRA owners')
    require(pipeline['selected_native_backing'] == context.backing(c,n), 'accepted RTL backing')
    shape = pipeline['RTL_shape']
    require(all(shape[key] == value for key,value in dict(
        first_unused_pseudo_number_upper=ex['K'],first_unused_UID_upper=ex['Uf'],
        IRA_entry_chain=ex['M'],block_slots_upper=ex['B']).items()), 'selected RTL shape')
    initial = pipeline['native_initial_SSA_lifetime']
    cf = pipeline['native_initial_CF_CFG_lifetime']
    helpers = pipeline['native_SSA_helper_backing']
    ssa,cfb = initial['ordinary_requests'],cf['ordinary_requests']
    require(initial['source_input']['initial_CFG_block_slots_upper'] == ex['G'] and
            initial['real_SSA_names'] == initial['PHIs'] == 0 and
            ssa['shared_default_bitmap_headers_upper'] == 3 and
            ssa['shared_kills_bitmap_live_elements_upper'] == 1 and
            ssa['shared_kills_bitmap_element_requests_upper'] == ex['G'] and
            ssa['shared_PHI_prune_bitmap_elements_upper'] == (ex['G']+127)//128,
            'initial SSA bitmap owner')
    require(cfb['shared_default_bitmap_headers_upper'] == 3 and
            cfb['shared_altered_bitmap_live_elements_upper'] == (ex['G']+127)//128 and
            cfb['shared_other_bitmap_elements'] == 0, 'initial CF CFG bitmap owner')
    ranger,out = helpers['ranger_per_instance'],helpers['out_of_SSA']
    require(helpers['sequential_ranger_instances_upper'] == 2 and
            ranger['bitmap_obstack_initial_chunks_upper'] == 5 and
            ranger['bitmap_headers_upper'] == 2*(n+5)+8 and ranger['bitmap_elements'] == 0 and
            out['shared_default_bitmap_headers_upper'] == 5 and
            out['shared_default_bitmap_elements'] == out['real_partitions'] == 0,
            'ranger and out of SSA bitmap owners')
    callback = pipeline['native_collector_callbacks']
    require(callback['source'] == source and callback['source_counts'] == counts and
            callback['selected_literal_collector_callback_effects_closed'] and
            callback['collector_callback_additional_GGC_events'] == 0 and
            callback['value_expression_marker']['each_ordinary_hash_backing_bytes'] == 104,
            'collector callback effect owner')
    require(context.framework['default_bitmap_initialization_depth_upper'] == 9 and
            not context.framework['bitmap_retained_object_or_chunk_number_field'],
            'pass framework bitmap depth and counter fields')
    inherited_guards = dict(mem=mem['conditional_selected_chronology_and_pool_capacity_established'],
        initial_SSA=initial['conditional_initial_SSA_lifetime_closed'],
        initial_CFG=cf['conditional_initial_CF_CFG_lifetime_closed'],
        SSA_helpers=helpers['conditional_SSA_helper_backing_closed'])
    result.update(source=source,source_counts=counts,same_source_accepted_owners_verified=True,
        inherited_owner_guards=inherited_guards,
        collector_callback_GGC_events=0,collector_marker_individual_ordinary_request_bytes=104,
        collector_call_count=None,
        retained_scalar_finalizer_history_upper=query['scalar_finalizers']['historical_registrations_upper'],
        source_argument='docs/research/retained-literal-shared-bitmap-pools.md',
        complete_source_files_verified=context.source_files,
        repository_inputs_verified=context.repository_files)
    result['conditional_selected_shared_bitmap_and_pool_capacity_established'] &= all(inherited_guards.values())
    return result


def evaluate_default(context):
    return evaluate_source((REPO/'samples/hello_world.adb').read_bytes(),
        context.pipeline,context.query,context.mem,context)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,
        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--output',type=Path,default=HERE/'result.json')
    args = parser.parse_args()
    args.output.write_text(json.dumps(evaluate_default(Context(args.gcc_root)),indent=2)+'\n')
