"""Direct application requests in the six pruned shape-builder families.

These are mathematical cumulative bounds, not machine counters or available RAM.
The source lemmas and callback ownership are stated in the accompanying note.
"""

MAX_INT = (1 << 62) - 1
MAX_STRING = (1 << 57) - 9
MAX_WOSIZE = (1 << 54) - 1
PREMISES = (
    'accepted_fixed_tasks_typed_atoms_and_fresh_entry_correspondence',
    'accepted_initial_identifier_domain_and_immutable_metadata',
    'frozen_variable_only_binder_transfer_and_valid_persistent_maps',
    'accepted_source_native_and_scalar_service_behavior',
    'one_global_three_save_two_exception_budget_and_discarded_frame_control',
    'accepted_private_printer_candidate_and_formatter_event_transfers',
)


def string_block(n):
    return 8 * (1 + (n + 8) // 8)


def map_request(n, m=0):
    """Own Extmap blocks, including simple option callbacks; not client bodies."""
    return 4096 * (n + m + 1) ** 3


def buffer_requests(n):
    cap = 512
    caps = [cap]
    while cap < n:
        cap *= 2
        caps.append(cap)
    return 40 + sum(string_block(c) for c in caps) + string_block(n), cap


def table_requests(writes):
    cap = 2048
    while writes > 2 * cap:
        cap *= 2
    # Charge two arrays and resize closures at EVERY replace site. This covers
    # repeated/abandoned attempts without a successful-rehash premise. The
    # private printer never sets ongoing_traversal: redistribution is inplace,
    # and therefore has no per-cell copied-bucket request.
    per_replace = 32 + 2 * 8 * (cap + 1) + 96
    return {
        'writes_upper': writes, 'capacity_upper': cap,
        'largest_array_block_bytes': 8 * (cap + 1),
        'requested_bytes_upper': 16384 + 40 + 8 * (2048 + 1) + writes * per_replace,
    }


def decoder_requests(M):
    output = 2 * M + 16
    events = 2 * M + 64  # includes empty text fragments and the final flush
    backing, cap = buffer_requests(output)
    return {
        'output_bytes_upper': output, 'core_events_upper': events,
        'backing_capacity_upper': cap,
        'requested_bytes_upper': (
            512 + 5 * string_block(M) + 2 * (128 + 192 * 27)
            + 640 + 640 * (3 * events + 1) + 192 * events + backing),
    }


def opening_requests(B, N, U, L):
    K = N + U + L + 1
    skeleton_visits = (1 + L * L) * B
    visits = skeleton_visits * (N + 1)
    own = 4096 * (1 + L * L)
    per_visit = own + (16 + 4 * N) * map_request(K, K)
    return {
        'base_skeleton_visits_per_opening_upper': skeleton_visits,
        'substitution_visits_per_opening_upper': visits,
        'map_operand_keys_upper': K,
        'map_operation_charges_per_substitution_visit': 16 + 4 * N,
        'requested_bytes_upper': own + L * (4096 + 2 * map_request(K, K))
            + visits * per_visit,
    }


def bounds(v, premises=None):
    required = {'G','J','P','A','M','Cbytes','Cchain','I','B','N','U','Ubytes','L','E'}
    if set(v) != required or any(type(x) is not int or x < 0 for x in v.values()):
        raise ValueError('nonnegative exact input domain required')
    p = {} if premises is None else premises
    if not isinstance(p, dict) or set(p) - set(PREMISES) or any(type(x) is not bool for x in p.values()):
        raise ValueError('explicit known Boolean premises required')
    G,J,P,A,M,Cb,C,I,B,N,U,Ub,L,E = (v[k] for k in
        ('G','J','P','A','M','Cbytes','Cchain','I','B','N','U','Ubytes','L','E'))
    r = 3  # one global interval allowance, never reset at a root/helper
    suffix = P * (P + 1)
    name = M + max(suffix, len(str(suffix)))
    spec = P * (suffix + 2 * P + 4)
    dec = decoder_requests(M)
    opener = opening_requests(B,N,U,L)
    indices, values = table_requests(2 * P), table_requests(P)
    local_calls = (1 << (C + 1)) - 1
    local = 256 * (C + 1) * (1 << (C + 1))
    per_collect = 512 + 2 * U * (64 + string_block(Ub))
    # Both term traversals start from immutable task input. P overbounds each
    # full goal-explanation walk and the sum of all selected proposition walks.
    shape_visits = r * G * P
    expl_visits = r * G * P
    opening_calls = shape_visits + expl_visits
    by_owner = {
        'used_theories_maps_and_callbacks': r * G * (map_request(I) + 256 * (I + 1)),
        'used_symbols_outer_inner_maps_unions_and_callbacks': r * G * (
            map_request(I) + I * (map_request(I) + map_request(I,I) + 1024) + 1024),
        'local_decls_task_list_catch_tree_choose_pairs_and_reversals': r * G * local,
        'printer_factory_private_tables_and_all_replace_attempts': r * G * (
            80 + indices['requested_bytes_upper'] + values['requested_bytes_upper']),
        'explanation_attribute_substrings_lists_concats_and_caller_blocks': r * G * (
            256 + (P + 1) * per_collect + 5 * string_block(E)),
        'term_opening_fresh_symbols_substitution_maps_records_and_lists':
            opening_calls * opener['requested_bytes_upper'],
        'shape_local_closures_alpha_strings_and_alpha_name_map': r * G * (
            512 * P + 64 * A + (P + A) * map_request(P + A, P + A)),
        'identifier_decode_internal_formats_and_candidate_strings': r * G * (
            136 * P + (P + spec) * dec['requested_bytes_upper']
            + spec * (2 * string_block(name) + 64)),
        'integer_constant_private_Format_and_OCaml_decimal_destinations':
            shape_visits * (1024 + 640 + 640 * 7 + 192 * 2 + string_block(Cb)),
    }
    native = {'integer_constant_Zarith_buffer_and_limb_copy': shape_visits * (133 + 16)}
    largest_string = max(name, E, Ub, dec['backing_capacity_upper'], Cb)
    largest = max(string_block(largest_string),indices['largest_array_block_bytes'],
        values['largest_array_block_bytes'],4096,133)
    guards = {
        'suffix_and_successor_represented': suffix + 1 <= MAX_INT,
        'alpha_counter_represented': A + 1 <= MAX_INT,
        'identifier_registration_increment_allowance_represented': I + L * opening_calls <= MAX_INT,
        'table_size_threshold_and_doubling_represented':
            max(2 * P, 2 * indices['capacity_upper'], 2 * values['capacity_upper']) <= MAX_INT,
        'map_heights_represented': 2 * max(I, P + A, opener['map_operand_keys_upper']) + 2 <= MAX_INT,
        'list_length_and_name_offsets_represented': max(C,2 * U,M + 16) <= MAX_INT,
        'all_string_lengths_and_backings_represented': largest_string <= MAX_STRING,
        'all_individual_OCaml_header_sizes_represented': largest // 8 - 1 <= MAX_WOSIZE,
        'internal_decoder_Format_sentinel': dec['output_bytes_upper'] + dec['core_events_upper'] + 79 <= 1000000010,
        'constant_Format_sentinel': Cb + 2 + 79 <= 1000000010,
        'numeric_limb_and_C_request_sizes': Cb <= 20 and 149 < (1 << 64),
        'accepted_explanation_prefix_two_bound': E >= max(11, 2 * (Ub + 2 * U) + 1),
    }
    candidate = {
        'global_save_entries_upper':r, 'global_escaping_signal_exceptions_upper':2,
        'first_five_roots_each_calls_upper':r * G,
        't_shape_root_calls_upper':r * (J - G),
        'shape_term_visits_upper':shape_visits, 'explanation_term_visits_upper':expl_visits,
        'opening_calls_upper':opening_calls, 'fresh_variable_calls_upper':L * opening_calls,
        'local_filter_activation_tree_per_call_upper':local_calls,
        'private_suffix_index_upper':suffix, 'candidate_specname_calls_per_printer_upper':spec,
        'private_indices_table':indices, 'private_values_table':values,
        'decoder_per_call':dec, 'opening_per_call':opener,
        'largest_new_individual_request_bytes_upper':largest,
        'ocaml_requested_bytes_by_disjoint_owner':by_owner,
        'c_requested_bytes_by_disjoint_owner':native,
        'ocaml_requested_bytes_upper':sum(by_owner.values()),
        'c_requested_bytes_upper':sum(native.values()),
        'direct_requested_bytes_interval_upper':sum(by_owner.values()) + sum(native.values()),
    }
    joined = all(p.get(k) is True for k in PREMISES) and all(guards.values())
    return {
        'candidate':candidate, 'guards':guards,
        'pruned_shape_builder_direct_requests_under_supplied_premises':candidate if joined else None,
        'complete_pruned_shape_builder_direct_request_accounting_under_supplied_premises':joined,
        'printer_rehash_preservation_or_termination_established':False,
        'multiplicity_scalar_semantics_established':False,
        'physical_memory_sufficiency_established':False,
        'failed_allocation_service_capacity_established':False,
        'complete_nonformatter_save_capacity_established':False,
        'complete_save_capacity_established':False,
        'whole_pipeline_capacity_established':False,
    }
