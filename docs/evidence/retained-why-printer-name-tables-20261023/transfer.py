"""Source-attached arithmetic for fresh SMTv2 name tables; no OCaml replay.

Dimensions and premises are an interface, not claims proved by this program.
L bounds *all* raw identifier strings at printer entry. None preserves the
unclosed raw-name-origin obligation instead of borrowing saved-atom maxima.
"""
MAX_INT = (1 << 62) - 1
MAX_ARRAY = (1 << 54) - 1
MAX_STRING = (1 << 57) - 9
BLACKLIST_CALLS = 343
BLACKLIST_MAX_BYTES = 22
PREMISES = (
    'accepted_R61_fields_and_R62_selected_printer_cut',
    'accepted_syntax_type_affinity_ground_signatures_and_2S_term_visits',
    'accepted_debug_false_counterexample_meta_and_single_goal_control',
    'selected_source_native_scalar_runtime_and_guarded_insertion_behavior',
    'single_worker_nonreturning_save_callback_and_private_owner_nonaliasing',
    'first_global_identifier_violation_prefix_and_immutable_keys',
)


def table(writes, removes):
    cap = 2048
    while writes > 2 * cap:
        cap *= 2
    return {
        'insertion_opportunities_upper': writes,
        'remove_opportunities_upper': removes,
        'client_entry_bucket_occurrences_upper': writes,
        'abandoned_resize_published_bucket_occurrences_upper': 2 * writes,
        'scalar_size_lower': -removes,
        'scalar_size_upper': writes,
        'capacity_upper': cap,
        'largest_bucket_or_tail_array_words': cap,
        'largest_bucket_or_tail_array_block_bytes': 8 * (cap + 1),
        'each_lookup_or_remove_cell_visits_upper': writes,
        'each_resize_cell_visits_upper': writes,
        'each_resize_outer_array_iterations_upper': 2 * cap,
    }


def bounds(dimensions, premises=None, L=None):
    if set(dimensions) != {'S', 'P', 'H', 'A', 'T', 'E'}:
        raise ValueError('exact S/P/H/A/T/E input keys required')
    if any(type(v) is not int or v < 1 for v in dimensions.values()):
        raise ValueError('positive integer dimensions required')
    if L is not None and (type(L) is not int or L < 0):
        raise ValueError('L must be None or a nonnegative integer')
    p = {} if premises is None else premises
    if (not isinstance(p, dict) or set(p) - set(PREMISES)
            or any(type(v) is not bool for v in p.values())):
        raise ValueError('known Boolean premises required')
    s, slots, h, a, t, episodes = (dimensions[k] for k in ('S', 'P', 'H', 'A', 'T', 'E'))
    body_names = (2 * s + slots) * (t + 1)
    header_names = 2 * (a + 1) * (t + 2) + 8
    calls = h * (body_names + header_names)
    forgets = h * (2 * slots + 3 * a + 2)
    n = BLACKLIST_CALLS + calls
    indices, values = table(n, forgets), table(calls, forgets)
    candidate = {
        'body_name_calls_per_declaration_upper': body_names,
        'header_name_calls_per_declaration_upper': header_names,
        'id_unique_calls_per_fresh_printer_upper': calls,
        'forget_id_calls_per_fresh_printer_upper': forgets,
        'find_unique_calls_including_blacklist_per_fresh_printer_upper': n,
        'historical_ghost_strings_per_fresh_printer_upper': n,
        'all_cached_suffixes_and_reached_suffix_operands_upper': n,
        'Hstr_replace_calls_upper': 2 * n,
        'Hstr_find_calls_upper': n,
        'Hstr_mem_calls_upper': n * (n + 1),
        'specname_calls_upper': n * (n + 2),
        'Hid_replace_calls_upper': calls,
        'Hid_find_calls_upper': calls + forgets,
        'indices': indices, 'values': values,
        'process_find_unique_calls_upper': episodes * n,
        'process_id_unique_calls_upper': episodes * calls,
        'process_Hstr_replace_calls_upper': episodes * 2 * n,
        'fresh_printer_instances_upper': episodes,
        'new_callback_allowance': 0,
        'raw_name_entry_bytes_upper': L,
        'sanitized_or_blacklist_base_bytes_upper': None,
        'candidate_name_bytes_upper': None,
    }
    guards = {
        'suffix_and_successor_operands_represented': n <= MAX_INT,
        'indices_size_increment_decrement_represented': max(n, forgets) <= MAX_INT,
        'values_size_increment_decrement_represented': max(calls, forgets) <= MAX_INT,
        'table_thresholds_doubling_and_array_indices_represented':
            2 * max(indices['capacity_upper'], values['capacity_upper']) <= MAX_INT,
        'individual_bucket_and_tail_arrays_represented':
            max(indices['capacity_upper'], values['capacity_upper']) <= MAX_ARRAY,
    }
    string_guard = None
    if L is not None:
        # Only new raw spelling in this printer is constructor_name ^ "_proj".
        base = max(BLACKLIST_MAX_BYTES, 5, 2 * (L + 5))
        name = base + len(str(n))
        candidate['sanitized_or_blacklist_base_bytes_upper'] = base
        candidate['candidate_name_bytes_upper'] = name
        string_guard = L + 5 <= MAX_STRING and name <= MAX_STRING
    joined = all(p.get(k) is True for k in PREMISES) and all(guards.values())
    return {
        'candidate': candidate,
        'integer_and_table_guards': guards,
        'name_string_operand_guard': string_guard,
        'conditional_integer_and_table_interface': candidate if joined else None,
        'conditional_name_string_operand_interface':
            candidate if joined and string_guard is True else None,
        'raw_name_origin_attachment_established': False,
        'source_argument_machine_checked': False,
        'name_uniqueness_semantics_established': False,
        'complete_printer_capacity_established': False,
        'whole_process_capacity_established': False,
        'aggregate_RAM_gate': False,
    }
