"""Conditional String.concat construction extents, including failed prefixes."""
MAX_STRING_BYTES = (1 << 57) - 9
MAX_INT = (1 << 62) - 1
PREMISES = (
    'selected_source_native_behavior',
    'finite_immutable_input_path_with_joined_length_bound',
    'faithful_pending_callbacks_and_private_frame',
    'identifier_occurrence_and_global_save_budget',
)


def construction_bounds(payload_bound, occurrences, save_entries=3, premises=None):
    for v in (payload_bound, occurrences, save_entries):
        if type(v) is not int or v < 0:
            raise ValueError('bounds must be nonnegative mathematical integers')
    premises = {} if premises is None else premises
    if not isinstance(premises, dict) or set(premises) - set(PREMISES):
        raise ValueError('unknown premise')
    if any(type(v) is not bool for v in premises.values()):
        raise ValueError('premises must be explicit booleans')
    calls = occurrences * save_entries
    components = payload_bound + 1
    block = 8 * (1 + (payload_bound + 8) // 8)
    candidate = {
        'component_count_per_nonempty_path_upper': components,
        'component_visits_per_concat_upper': 2 * components,
        'direct_loop_polls_per_concat_upper': 2 * components,
        'memmove_calls_per_concat_upper': 2 * components - 1,
        'bytes_copied_per_concat_upper': payload_bound,
        'byte_allocations_requested_per_concat_upper': 1,
        'requested_string_block_bytes_per_concat_upper': block,
        'concat_attempts_across_all_saves_upper': calls,
        'aggregate_requested_string_block_bytes_upper': calls * block,
        'aggregate_component_visits_upper': calls * 2 * components,
        'aggregate_memmove_calls_upper': calls * (2 * components - 1),
        'aggregate_bytes_copied_upper': calls * payload_bound,
        'direct_concat_loop_stack_growth_per_component_bytes': 0,
    }
    guard = payload_bound <= MAX_STRING_BYTES and components <= MAX_INT
    joined = all(premises.get(p) is True for p in PREMISES)
    return {
        'representation_guards_pass': guard,
        'candidate': candidate,
        'construction_bounds': candidate if guard and joined else None,
        'all_construction_premises_supplied': joined,
        'complete_restore_table_lookup_capacity_established': False,
        'complete_allocator_or_pending_callback_capacity_established': False,
        'complete_save_capacity_established': False,
        'whole_pipeline_capacity_established': False,
    }
