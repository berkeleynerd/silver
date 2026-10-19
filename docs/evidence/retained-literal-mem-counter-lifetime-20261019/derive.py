#!/usr/bin/env python3
"""Focused source-bound MEM/counter chronology and ordinary pool transfer.

No aggregate evaluator or predecessor Context is instantiated. The retained
pipeline and shared-query results are input interfaces, not replayed suites.
"""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO/'docs/evidence'
NATIVE = E/'unbounded-programs/retained-native-expansion-20261017'
I32, U32, I64 = 2**31-1, 2**32-1, 2**63-1


def require(condition, message):
    if not condition:
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
                    'changed MEM/counter input '+row['path'])
        self.source_files = sum(row['root'] == 'gcc' for row in pins['files'])
        self.repository_files = sum(row['root'] == 'repository' for row in pins['files'])
        self.recognize = runpy.run_path(str(NATIVE/'derive-literal-output.py'))['source_counts']
        self.backing = runpy.run_path(str(NATIVE/'derive-literal-rtl-backing.py'))['backing']
        self.pipeline = read(E/'retained-literal-pipeline-20261018/result.json')
        self.query = read(E/'retained-literal-shared-query-lifetime-20261019/result.json')
        self.setup = read(NATIVE/'native-rtl-setup.json')
        self.frame = read(NATIVE/'native-rtl-constructors.json')


def register_capacity(extent):
    require(type(extent) is int and extent >= 98, 'register extent')
    q = max(0, ((extent+197)//198-1).bit_length())
    return q, 198*(1 << q)


def collection_capacity(inline, length):
    """Single pushes; the first heap reserve hides auto storage (vec.h:1977)."""
    require(type(inline) is int and inline >= 1 and type(length) is int and length >= 0,
            'auto vector domain')
    capacity, auto, history = inline, True, []
    for desired in range(1, length+1):
        if desired <= capacity:
            continue
        old = 0 if auto else capacity
        growth = 4 if old == 0 else old*2 if old < 16 else old*3//2
        capacity = max(desired, growth)
        history.append(capacity)
        auto = False
    return dict(logical_length_upper=length, inline_slots=inline,
                heap_capacities=history, retained_capacity_upper=capacity,
                individual_heap_requests_bytes=[8+8*x for x in history],
                heap_requests_per_record_upper=len(history))


def pool(name, objects, size, generations=1, already_priced=False):
    require(type(objects) is int and objects >= 0 and size in (16,24,32,48,64,72,80),
            'ordinary typed pool domain')
    slots = (65536-8)//size
    blocks = (objects+slots-1)//slots
    retained = blocks*slots
    return dict(family=name, object_bound_per_generation=objects,
        bytes_per_object=size, objects_per_block=slots,
        blocks_per_generation_upper=blocks, retained_slots_per_generation_upper=retained,
        retained_bytes_per_generation_upper=65536*blocks, generations_upper=generations,
        lifetime_block_requests_upper=generations*blocks, individual_block_bytes=65536,
        allocation_count_field='size_t', allocated_and_free_count_upper=retained,
        block_count_upper=blocks, blocks_already_priced=already_priced,
        fits=retained <= I64 and blocks <= I64 and size <= I32,
        GGC_events=0, scalar_finalizers=0, array_finalizers=0)


def endpoints(c, n, context):
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0, 'literal C N domain')
    inherited = context.backing(c, n)
    k0, k, u, uf, b = 98+3*c, 99+5*c, 7*c+5*n+22, 7*c+7*n+46, 2*n+10
    q0, cap0 = register_capacity(k0)
    q, cap = register_capacity(k)
    f, a, m = 17690*c+32, 368*n+19044, 7*c+5*n+20
    df_pools = [pool('DF base references', f, 64, 2),
        pool('DF regular references', f, 72, 2),
        pool('DF artificial references', a, 72, 2),
        pool('DF instruction records', uf, 48, 2),
        pool('DF register records', 3*k, 16, 2, True),
        pool('DF multiword descriptors', 0, 32, 2, True)]
    lra_pools = [pool('LRA recognition records', m, 80, already_priced=True),
                 pool('LRA instruction registers', 10*c, 24, already_priced=True)]
    alias = inherited['alias_direct_helpers']
    result = dict(
        source_input=dict(output_calls=c, null_statements=n),
        mem_attrs=dict(variable_records_already_owned=5*c,
            pool_setter_records_upper=4*c, call_setter_records_upper=c,
            record_raw_bytes=40, later_additional_records=0, frame_records=0,
            CFI_records=0, copy_records=0, hash_backing_requests=0,
            fixed_setup_events_already_owned=437, fixed_setup_recharged=False,
            complete_selected_setter_lifetime_closed=True),
        SSA=dict(per_function_version_zero_reserved=True, helper_fresh_names_upper=10,
            helper_name_vector_lengths_upper=[5,7], Main_initial_fresh_names_upper=3*c+1,
            Main_initial_name_vector_length_upper=3*c+2,
            known_helper_plus_initial_Main_creation_events_upper=3*c+11,
            global_creation_and_reuse_statistics_reset=False,
            global_statistics_type='unsigned int', global_statistics_used_for_capacity=False,
            global_statistics_unsigned_wrap_is_defined=True,
            global_statistics_capacity_relevance_closed=True,
            later_SSA_allocation_events_upper=None, all_phase_SSA_allocation_lifetime_closed=False),
        RTL=dict(dummy_then_Main_init_emit_calls=2, first_UID_each=1,
            first_pseudo_each=98, dummy_pseudo_arrays_reused_by_Main=False,
            dummy_alignment_array_freed_before_Main=True,
            initial_array_slots_each=198, initial_pointer_request_each=1584,
            initial_alignment_request_each=198, pre_split_first_unused_pseudo_upper=k0,
            final_first_unused_pseudo_upper=k, final_first_unused_UID_upper=uf,
            expansion_chain_upper=7*c+3*n+12, final_chain_upper=uf-1,
            pre_split_growths_already_owned=q0, complete_Main_growths_upper=q,
            later_additional_pointer_GGC_backings_upper=q-q0,
            later_additional_alignment_requests_upper=q-q0,
            final_array_capacity_upper=cap, pre_split_array_capacity_upper=cap0,
            each_final_pointer_request_bytes_upper=8*cap,
            each_final_alignment_request_bytes_upper=cap,
            global_labels_reset_at_Main_entry=False,
            complete_selected_UID_pseudo_and_array_chronology_closed=True),
        alias_vectors=dict(selected_calls=1, incoming_known_capacity=0,
            incoming_base_capacity=0, incoming_old_base_capacity=0,
            unique_id_at_each_iteration=1, unique_id_peak=1,
            requests_already_owned=2, new_requests_in_this_packet=0,
            raw_requests_upper=alias['GGC_pointer_vector_raw_requests_upper'],
            rounded_requests_upper=alias['GGC_pointer_vector_rounded_requests_upper'],
            normalized_capacities_upper=alias['new_GGC_pointer_vector_capacities_upper'],
            complete_selected_incoming_and_reuse_chronology_closed=True),
        DF=dict(instances=1, scan_generations=2, ref_order_initial=0,
            scan_rebuild_resets_ref_order=False, instruction_reference_creations_upper=f,
            artificial_reference_creations_upper=a, ref_order_final_upper=f+a,
            multiword_reference_order_increments=0,
            LR_solver_visits_upper_per_analysis=b+k*(2*n+9),
            LUID_reset_per_block=True, LUID_upper=uf,
            scan_rebuild_releases_old_pools_before_allocating_new=True,
            ordinary_pools=df_pools,
            newly_priced_blocks_upper_per_generation=sum(x['blocks_per_generation_upper']
                for x in df_pools if not x['blocks_already_priced']),
            newly_priced_lifetime_block_requests_upper=sum(x['lifetime_block_requests_upper']
                for x in df_pools if not x['blocks_already_priced']),
            collection_vectors=dict(definition=collection_capacity(128,92),
                use=collection_capacity(32,94), note_use=collection_capacity(32,0),
                multiword=collection_capacity(32,0), simultaneous_records_upper=1),
            complete_selected_reference_order_and_typed_pool_chronology_closed=True,
            combined_sparse_bitmap_obstacks_closed=False),
        LRA=dict(invocations=1, last_reg_value_initial=0,
            last_reg_value_upper=3*k//2+1, recognition_pointer_incoming_capacity=0,
            recognition_pointer_capacity_upper=max(3*(u-1)//2,u),
            ordinary_pools=lra_pools, pools_released_at_finish=True,
            capacity_fields_count_retained_slots_not_cumulative_allocate_calls=True,
            complete_selected_value_and_recognition_pool_chronology_closed=True),
        stacks=dict(cfun_conservative_peak=3, cfun_capacity_already_owned=4,
            cfun_backing_bytes_already_owned=40, cfun_additional_backings=0,
            nested_language_function_context_pushes=0,
            sequence_cache_deletable=True, fixed_sequence_events_already_owned=10,
            operation_sequence_events_already_owned=8*c, frame_sequence_events_already_owned=5,
            each_sequence_raw_bytes=24, sequence_cache_peak_does_not_replace_lifetime_events=True,
            call_argument_array_requests_already_owned=c, each_call_argument_array_bytes=184,
            temporary_slot_level_peak=1, temporary_slot_payload_objects=0,
            temporary_slot_vector_requests_already_owned=2,
            whole_native_stack_lifetime_closed=False),
        new_GGC_backing_events_upper=q-q0, new_mem_attrs_events=0,
        new_scalar_registrations=0, new_array_registrations=0,
        total_GGC_events=None, complete_global_counter_lifetime_closed=False,
        complete_array_finalizer_lifetime_closed=False, complete_collector_lifetime_closed=False,
        complete_all_ordinary_helper_lifetimes_closed=False,
        whole_literal_pipeline_capacity_established=False,
        production_admission_changed=False, aggregate_RAM_gate=False,
        source_reachability_argument_is_handwritten=True, independent_review_status='pending',
        native_tool_executions=0, accepted_component_suites_rerun=0,
        aggregate_executions=0, corpus_checkers_rerun=0)
    checks = dict(inherited_RTL_DF_LRA_checks=all(inherited['local_representation_checks'].values()),
        Main_register_array_signed_doubling=q <= 23,
        Main_register_array_pointer_span=8*cap <= I64,
        Main_register_array_alignment_span=cap <= I64,
        ordinary_pool_retained_count_widths=all(x['fits'] for x in df_pools+lra_pools),
        DF_collection_use_capacity_31_bits=109 <= I32,
        DF_collection_use_growth_unsigned=3*73 <= U32,
        DF_collection_use_request_span=880 <= I64,
        cfun_capacity_covers_peak=3 <= 4)
    result['local_representation_checks'] = checks
    result['conditional_selected_chronology_and_pool_capacity_established'] = all(checks.values())
    return result


def evaluate_source(raw, pipeline, query, context):
    counts = context.recognize(raw)
    source = identity(raw)
    c, n = counts['output_calls'], counts['null_statements']
    require(pipeline['source'] == query['source'] == source and
            pipeline['source_counts'] == query['source_counts'] == counts,
            'same actual source and recognized counts')
    result = endpoints(c,n,context)
    expected_backing = context.backing(c,n)
    require(pipeline['selected_native_backing'] == expected_backing, 'accepted RTL/DF/LRA backing')
    shape = pipeline['RTL_shape']
    expected_shape = dict(calls=c, nulls=n, pass_expand_chain=7*c+3*n+12,
        split_added_REG_requests=2*c, lifetime_dynamic_pseudo_requests_upper=5*c+1,
        first_unused_pseudo_number_upper=99+5*c,
        register_array_capacity_upper=result['RTL']['final_array_capacity_upper'],
        IRA_entry_chain=7*c+5*n+20, postreload_chain=7*c+5*n+21,
        postframe_chain=7*c+7*n+35, final_chain=7*c+7*n+45,
        first_unused_UID_upper=7*c+7*n+46, block_slots_upper=2*n+10, edges_upper=2*n+9)
    require(all(shape[k] == v for k,v in expected_shape.items()), 'accepted chronological RTL shapes')
    operation = pipeline['native_lowering_data']['conditional_native_selected_constructor_requests']
    require(operation['pool_and_call_mem_attrs_requests_upper'] == 5*c and
            operation['each_mem_attrs_raw_bytes'] == 40 and
            operation['call_and_move_sequence_stack_requests_upper'] == 8*c and
            operation['register_pointer_array_GGC_growth_requests_upper'] ==
                result['RTL']['pre_split_growths_already_owned'], 'operation owner not erased')
    require(context.frame['frame_MEM_attribute_objects'] == 0 and
            context.frame['frame_sequence_stacks']['cold_GGC_events_bound'] == 5 and
            context.frame['frame_sequence_stacks']['maximum_nesting'] == 3,
            'accepted raw frame MEM and sequence owners')
    require(context.setup['cold_sequence_stack_events_bound'] == 10 and
            context.setup['source_event_envelope']['GGC_events_bound'] == 437, 'fixed setup owner')
    ssa = pipeline['native_initial_SSA_lifetime']
    require(ssa['source_input']['SSA_slots_upper'] == 3*c+2 and
            ssa['additional_global_SSA_name_creation_events_upper'] == 3*c+1 and
            ssa['real_SSA_names'] == ssa['PHIs'] == 0, 'accepted initial SSA input')
    synthetic = pipeline['native_synthetic_function_storage']
    groups = {x['family']: x for x in synthetic['GGC_groups']}
    ordinary = {x['family']: x for x in synthetic['ordinary_groups']}
    require(groups['scalar_SSA_NAME']['requests'] == 10 and
            ordinary['cfun_stack_first_capacity'] == dict(family='cfun_stack_first_capacity',
                requests=1, caller_bytes=40), 'synthetic SSA and cfun stack owners')
    emission = pipeline['native_complete_emission_interface']
    require(emission['source_identity'] == source and emission['source_counts'] == counts,
            'same-source emission interface')
    chain = 7*c+7*n+45
    expected_counters = dict(fixed_prefix_positive_GGC_events_upper=39257,
        ordinary_label_initial_value=1, ordinary_label_next_at_prefix_exit_upper=39258,
        target_cost_setup_ordinary_label_increments=0,
        imported_and_non_Main_ordinary_label_increments=0,
        Main_ordinary_label_increments_upper=chain,
        ordinary_label_next_at_exit_upper=39258+chain, Main_label_alignment_span_upper=chain+1,
        constant_label_initial_value=0, constant_label_next_at_prefix_exit_upper=39257,
        target_cost_setup_constant_label_increments=0, additional_imported_constant_label_increments=0,
        Main_tree_constant_label_increments_upper=2*c,
        post_prefix_RTL_pool_static_space_partition_label_increments=0,
        constant_label_next_at_exit_upper=39257+2*c, final_scan_counter_initial_value=0,
        final_scan_counter_at_exit_upper=chain, CFI_label_counter_initial_value=0,
        CFI_label_counter_at_exit_upper=5, CFI_label_signed_temporary_maximum=4,
        Main_function_definition_number=1, next_function_definition_number=4)
    require(emission['counter_bounds'] == expected_counters and emission['final_chain'] == chain and
            emission['text_bytes_upper'] == 31*c+4*n+22 and
            emission['emission']['emitted_function_bodies'] == 1 and
            emission['emission']['additional_non_Main_emitted_lines'] == 0 and
            emission['emission']['Main_boundary_labels'] == ['.LFB1','.LFE1'],
            'accepted emission chronology not reset or enlarged')
    guards = dict(literal_length_signed_int=counts['maximum_literal_length'] <= I32,
        ordinary_label_next_signed_int=39258+chain <= I32,
        constant_label_next_signed_int=39257+2*c <= I32,
        Main_instruction_UID_and_label_span_signed_int=chain+1 <= I32,
        final_scan_counter_signed_int=chain <= I32,
        text_and_CFI_location_signed_int=31*c+4*n+22 <= I32,
        CFI_label_temporary_and_next_signed_int=True, function_definition_next_signed_int=True)
    require(emission['counter_and_emission_guards'] == guards and
            emission['counter_and_emission_guards_fit'] == all(guards.values()),
            'accepted emission guards')
    require(query['complete_DECL_UID_lifetime_closed'] and query['complete_type_lifetime_closed'] and
            query['complete_alias_lifetime_closed'] and not query['complete_collector_lifetime_closed'],
            'frozen shared-query scope')
    d = int(counts['Put'] > 0)+int(counts['Put_Line'] > 0)
    expected_query_counters = dict(next_DECL_UID_upper=5869+5*c+n+3*d,
        next_type_UID_upper=2295+6*c+5*d, alias_ID_upper=414860,
        temporary_name_serial_upper=40879+3*c+4*d,
        checks=dict(DECL_UID_signed=5869+5*c+n+3*d <= I32,
            type_UID_unsigned=2295+6*c+5*d <= U32, alias_ID_signed=True,
            temporary_name_serial_unsigned=40879+3*c+4*d <= U32))
    require(query['counter_endpoints'] == expected_query_counters,
            'frozen shared-query counter endpoints')
    result.update(source=source, source_counts=counts, same_source_predecessor_owners_verified=True,
        emission_counter_endpoints=expected_counters, emission_guards=guards,
        inherited_shared_query_counter_endpoints=query['counter_endpoints'])
    result['conditional_selected_chronology_and_pool_capacity_established'] &= all(guards.values())
    return result


def evaluate_default(context):
    return evaluate_source((REPO/'samples/hello_world.adb').read_bytes(),
        context.pipeline, context.query, context)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path,
        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--output', type=Path, default=HERE/'result.json')
    args = parser.parse_args()
    args.output.write_text(json.dumps(evaluate_default(Context(args.gcc_root)),indent=2)+'\n')
