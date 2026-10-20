"""Conditional direct-lookup bounds; mathematical totals are not heap capacity."""
CELL_BYTES = 32
REPRESENTED_CHAIN_MAX = (1 << 64) // CELL_BYTES
MAX_ARRAY_LENGTH = (1 << 54) - 1
MAX_TABLE_CAPACITY = 1 << 53
PREMISES = (
    'selected_source_native_pending_frame_relation',
    'valid_64_bit_heap_and_gc_relocation_relation',
    'accepted_initial_state_and_private_writer_effect_closure',
    'accepted_occurrence_and_global_save_budget',
)


def natural(name, value):
    if type(value) is not int or value < 0:
        raise ValueError(name + ' must be a nonnegative integer')
    return value


def lookup_bounds(initial_cells, initial_bucket_max, occurrences, writes=None,
                  saves=3, premises=None):
    for name, value in (('initial_cells', initial_cells),
                        ('initial_bucket_max', initial_bucket_max),
                        ('occurrences', occurrences), ('saves', saves)):
        natural(name, value)
    if not initial_bucket_max <= initial_cells <= REPRESENTED_CHAIN_MAX:
        raise ValueError('invalid initial represented topology')
    if saves > 3:
        raise ValueError('global selected save budget is at most three')
    if writes is not None:
        natural('writes', writes)
    supplied = {} if premises is None else dict(premises)
    if set(supplied) - set(PREMISES) or any(type(v) is not bool for v in supplied.values()):
        raise ValueError('unknown or non-boolean premise')
    missing = [p for p in PREMISES if not supplied.get(p, False)]
    length = REPRESENTED_CHAIN_MAX if writes is None else min(
        REPRESENTED_CHAIN_MAX, initial_bucket_max + writes)
    attempts = saves * occurrences
    candidate = {
        'lookup_attempts_upper': attempts,
        'captured_chain_nodes_per_lookup_upper': length,
        'direct_chain_visits_upper': attempts * length,
        'direct_find_rec_poll_sites_upper': attempts * (length + 1),
        'direct_hash_wrapper_poll_sites_upper': 2 * attempts,
        'get_key_calls_upper': attempts * length,
        'get_data_calls_upper': attempts * length,
        'option_block_requests_upper': 2 * attempts * length,
        'option_block_requested_bytes_upper': 32 * attempts * length,
        'explicit_optionalize_pending_entries_upper': 2 * attempts * length,
        'identifier_tag_reads_upper': attempts * (1 + 2 * length),
        'find_rec_own_frame_bytes_excluding_return_and_callees': 40,
        'find_rec_additional_frame_bytes_per_node': 0,
        'table_capacity_lower': 4096,
        'table_capacity_upper': MAX_TABLE_CAPACITY,
        'current_cell_count_upper_if_writes_supplied': None if writes is None else min(
            REPRESENTED_CHAIN_MAX, initial_cells + writes),
    }
    return {
        'missing_premises': missing,
        'post_cut_replace_publications_upper': writes,
        'candidate': candidate,
        'direct_lookup_bounds': None if missing else candidate,
        'direct_lookup_structure_established_under_supplied_premises': not missing,
        'physical_memory_sufficiency_established': False,
        'writer_size_arithmetic_established': False,
        'aggregate_allocator_gc_pending_capacity_established': False,
        'whole_native_stack_capacity_established': False,
        'complete_restore_table_capacity_established': False,
        'complete_save_capacity_established': False,
        'whole_pipeline_capacity_established': False,
    }
