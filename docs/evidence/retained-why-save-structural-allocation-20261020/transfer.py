"""Selected structural caller objects; the pruned shape-builder residual is explicit."""

MAX_INT = (1 << 62) - 1
MAX_STRING = (1 << 57) - 9
MAX_ARRAY = (1 << 54) - 1
PREMISES = (
    'accepted_five_process_state_occurrences_and_global_r_e_budget',
    'accepted_table_prefix_private_owner_and_counter_attachment',
    'accepted_shape_transfer_and_no_return_to_interrupted_append',
    'accepted_publication_and_restore_lookup_structure',
    'selected_source_native_valid_values_and_runtime_service_relation',
)


def string_block(n):
    return 8 * (1 + (n + 8) // 8)


def array_block(n):
    return 8 * (n + 1)


def frequency_table(A):
    """One fresh table; any abandoned resize prefix is charged in full."""
    cap = 16
    capacities = [cap]
    while A > 2 * cap:
        cap *= 2
        capacities.append(cap)
    return {
        'capacities': capacities,
        'capacity_upper': cap,
        'record_initial_and_all_resize_objects_bytes':
            40 + array_block(16) + sum(2 * array_block(c) + 96 + 32 * A
                                      for c in capacities[1:]),
    }


def shape_backings(extent, initial):
    if initial <= 0:
        raise ValueError('positive captured Buffer backing required')
    cap, new = initial, []
    while cap < extent:
        cap *= 2
        new.append(cap)
    return {'capacity_upper': cap, 'new_capacities': new,
            'all_new_backing_bytes_per_owner': sum(map(string_block, new))}


def bounds(inputs, premises=None):
    if any(type(v) is not int or v < 0 for v in inputs.values()):
        raise ValueError('nonnegative mathematical integer inputs required')
    if set(inputs) != {'F','Th','G','T','A','Axml','P','B','V','N','J','X','D',
                       'buffer_initial','theory_capacity','theory_visits','W'}:
        raise ValueError('unexpected input domain')
    premises = {} if premises is None else premises
    if not isinstance(premises, dict) or set(premises) - set(PREMISES):
        raise ValueError('unexpected premise')
    if any(type(v) is not bool for v in premises.values()):
        raise ValueError('explicit Boolean premises required')
    F,Th,G,T,A,Ax,P,B,V,N,J,X,D,initial,thcap,thvis,W = (
        inputs[k] for k in ('F','Th','G','T','A','Axml','P','B','V','N','J','X','D',
                            'buffer_initial','theory_capacity','theory_visits','W'))
    r, e = 3, 2  # one whole-process interval; never refreshed by a helper
    U = min(A, P + e + 1)  # completed distinct/exceptional entries + final abandoned constructor
    C, n = r*J, Ax+T
    freq = frequency_table(A)
    backing = shape_backings(X, initial)
    tables = 1 + 3*U + B  # stats, frequency tables, occurs, including partial creation
    # 16,384 also covers randomized create: seed array, state, 110 digest rounds,
    # lazy wrappers/exception memo closure; it is paid per create, not per success.
    charges = {
        'persistent_global_shape_map_nodes': 48*8*C*(D+1),
        'saved_shape_list_cells': 24*C,
        'shape_Buffer_contents_destinations': C*string_block(X),
        'shape_Buffer_new_backings_including_abandoned_requests':
            r*backing['all_new_backing_bytes_per_owner'],
        'bound_shape_task_own_refs_and_callback_closure': r*120*G,
        'preliminary_save_session_and_forest_traversal_objects':
            r*(208 + 104*F + 72*Th + 72*T + 152*G + 16*Ax),
        'private_stats_table_record_array_and_partial_binding_nodes': r*(176+32*U),
        'private_frequency_records_arrays_resize_closures_and_possible_copies':
            r*3*U*freq['record_initial_and_all_resize_objects_bytes'],
        'private_frequency_replace_binding_requests': r*32*3*A,
        'private_statistics_caller_closure_and_table_triples': r*(40+32*U),
        'private_occurs_table_records_arrays_and_binding_requests': r*B*(176+32*V),
        'all_private_create_random_seeding_direct_objects': r*tables*16384,
        'get_prover_to_save_own_closure_tuple_and_unused_assert_allowance': r*104*B,
        'frequency_fold_record_maximum_pairs': r*24*3*A*B,
        'persistent_prover_and_id_map_nodes': r*48*4*(B+P)*(P+1),
        'prover_id_map_payload_tuples': r*40*P,
        'serializer_table_iter_and_fold_helper_closures': r*(104+152*B+40*G),
        'shared_shape_prover_and_status_insertion_requests': r*32*(G+B+F+Th),
        'possible_theory_status_resize_arrays_closures_and_copy_nodes':
            r*Th*(2*array_block(thcap)+96+32*thvis) if thcap > 16 else 0,
        'goal_attempt_and_transformation_input_pair_cons_groups': r*48*n,
        'sort_merge_cons_cells': r*24*4*n*(n+1),
        'sort_recursive_result_pairs': r*24*2*n,
        'sort_local_recursive_closure_groups': r*168*2*G,
        'shape_getter_variant_blocks_and_dictionary_output_closure': r*(16*G+40),
        'restored_path_key_and_data_getter_options': r*N*32*min(1<<59,7+W),
    }
    guards = {
        'shape_extent_and_backing_string_guard': max(X,backing['capacity_upper']) <= MAX_STRING,
        'shape_Buffer_doubling_and_position_arithmetic': 2*backing['capacity_upper'] <= MAX_INT,
        'shape_map_height_arithmetic': D+2 <= MAX_INT,
        'frequency_and_candidate_successors': max(A,V)+1 <= MAX_INT,
        'private_and_shared_array_extents': max(freq['capacity_upper'],thcap,55,16) < MAX_ARRAY,
        'array_doubling_and_byte_conversion': 16*max(freq['capacity_upper'],thcap,55) <= MAX_INT,
        'sort_native_lengths': n <= MAX_INT,
        'restored_lookup_bucket_bound_represented': min(1<<59,7+W) <= 1<<59,
        'bounded_partial_statistics_construction': B <= U <= A and B <= P+e,
        'source_occurrence_domains': J >= G and N <= G+Th,
    }
    residual = {
        'Termcode.goal_expl_task': r*G,
        'Ident.create_ident_printer_empty_blacklist': r*G,
        'Task.used_theories': r*G,
        'Task.used_symbols': r*G,
        'Task.local_decls': r*G,
        'Shape.t_shape': r*(J-G),
    }
    candidate = {
        'global_save_entries_upper':r,'global_escaping_signal_exceptions_upper':e,
        'private_stats_binding_visits_per_save_upper':B,
        'private_stats_construction_attempts_per_save_upper':U,
        'private_table_create_attempts_per_save_upper':tables,
        'frequency_table':freq,'shape_Buffer_backings':backing,
        'sort_input_cells_per_save_upper':n,
        'pruned_shape_builder_residual_root_calls_interval_upper':residual,
        'direct_requested_OCaml_bytes_by_disjoint_owner':charges,
        'accounted_direct_requested_OCaml_bytes_interval_upper':sum(charges.values()),
    }
    joined = all(premises.get(p) is True for p in PREMISES) and all(guards.values())
    return {'candidate':candidate,'guards':guards,
        'accounted_structural_requests_under_supplied_premises':candidate if joined else None,
        'scoped_structural_request_accounting_established_under_supplied_premises':joined,
        'shape_builder_residual_requested_bytes':None,
        'complete_nonformatter_save_allocation_established':False,
        'peak_physical_memory_bytes':None,
        'physical_exhaustion_excluded':False,
        'collector_internal_proof_required_by_this_packet':False,
        'complete_save_capacity_established':False,'whole_pipeline_capacity_established':False}
