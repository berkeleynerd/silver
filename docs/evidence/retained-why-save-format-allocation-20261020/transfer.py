"""Direct save formatter request accounting, not physical allocator sufficiency."""

MAX_INT = (1 << 62) - 1
MAX_STRING = (1 << 57) - 9
MAX_WOSIZE = (1 << 54) - 1
PREMISES = (
    'selected_source_native_valid_values_and_fixed_formats',
    'accepted_occurrence_inputs_and_global_three_save_budget',
    'accepted_restored_paths_scalar_and_shape_string_transfers',
    'fresh_private_formatter_buffer_and_channel_frames',
    'normal_conversion_allocation_and_locking_service_semantics',
)


def string_block(length):
    return 8 * (1 + (length + 8) // 8)


def buffer_requests(length, initial=512):
    """Charge every possible capacity, including skipped and abandoned backings."""
    capacity = initial
    capacities = [capacity]
    while capacity < length:
        capacity *= 2
        capacities.append(capacity)
    return {
        'capacity_upper': capacity,
        'resize_calls_upper': len(capacities) - 1,
        'all_backing_blocks_bytes_upper': sum(map(string_block, capacities)),
        'record_bytes': 40,
        'contents_block_bytes_upper': string_block(length),
        'requested_bytes_upper': 40 + sum(map(string_block, capacities)) + string_block(length),
    }


def bounds(parts, B, E, W, directory_bytes, concat_interval, premises=None):
    values = list(parts.values()) + [B, E, W, directory_bytes, concat_interval]
    if any(type(v) is not int or v < 0 for v in values):
        raise ValueError('expected nonnegative mathematical integers')
    if set(parts) != {'F', 'Th', 'G', 'T', 'A', 'Axml', 'Args', 'Paths'}:
        raise ValueError('occurrence domain')
    if W > MAX_STRING:
        raise ValueError('not an admitted per-string extent')
    premises = {} if premises is None else premises
    if not isinstance(premises, dict) or set(premises) - set(PREMISES):
        raise ValueError('unknown premise')
    if any(type(v) is not bool for v in premises.values()):
        raise ValueError('premises must be explicit booleans')
    r = 3  # interval-wide, including nested/abandoned saves; never reset at entry
    F, Th, G, T, A, Ax, Args, Paths = (parts[k] for k in ('F','Th','G','T','A','Axml','Args','Paths'))
    Q = 1 + sum(parts.values())
    C = 6 + 4*F + 4*Th + 6*G + 3*T + 8*Ax + 3*A + 2*Args + Paths
    O = 1 + 2*(F+Th+G+T) + Ax + A + Paths
    K = 2 + G + O  # XML; G shape asprintf plus header; annotations
    events = E + G*(W+1) + 65 + 2*O
    insertions = 3*events + K
    shape_buffer = buffer_requests(W)
    header_buffer = buffer_requests(64)
    # Fixed local blocks in caller bodies; list/map/sort result constructors excluded.
    caller = (184 + 72*A + 72*Ax + 32*(F+Ax) + 224*Ax +
              288*G + 224*T + 112*Th + 160*F + 104*G)
    ocaml = {
        'accepted_accumulators_and_Format_continuations': r*(128*C + 192*27*C),
        'accepted_annotation_parser_and_description': r*208*O,
        'formatter_fixed_records_containers_and_output_closures': r*640*K,
        'core_dynamic_queue_scan_format_options_and_reset_blocks': r*640*insertions,
        'normal_scalar_conversion_and_single_character_temporaries': r*192*events,
        'annotation_Buffer_records_and_backings': r*72*O,
        'shape_asprintf_Buffer_records_all_backings_and_contents': r*G*shape_buffer['requested_bytes_upper'],
        'header_asprintf_Buffer_records_backings_and_contents': r*header_buffer['requested_bytes_upper'],
        'caller_local_closures_options_refs_and_contexts': r*caller,
        'accepted_identifier_concat_destination_blocks': concat_interval,
        'accepted_file_path_string_blocks': r*9*string_block(directory_bytes+20),
        'new_channel_custom_wrappers': r*2*24,
    }
    native = {
        'accepted_path_copies_including_channel_names': r*19*(directory_bytes+21),
        'accepted_channel_records_including_IO_buffers': r*2*65616,
        'lazy_channel_mutex_objects': r*2*40,
    }
    largest_string = max(116162, W, shape_buffer['capacity_upper'], 512, directory_bytes+20)
    guards = {
        'xml_core_sentinel': B+E+79 <= 1000000010,
        'shape_core_sentinel': W+(W+1)+79 <= 1000000010,
        'header_and_annotation_core_sentinels': 64+65+79 <= 1000000010,
        'each_core_container_length': 4*(max(E,W+1,65,2)+1)+2 <= MAX_INT,
        'per_string_bytes_and_backing_capacity': largest_string <= MAX_STRING,
        'Buffer_position_addition_and_doubling': max(2*shape_buffer['capacity_upper'],1024) <= MAX_INT,
        'string_native_size_rounding': largest_string+8 <= (1 << 64)-1,
        'string_header_payload_words': (largest_string+8)//8 <= MAX_WOSIZE,
        'fixed_native_block_sizes': 65616 <= (1 << 64)-1,
        'cumulative_request_totals_fit_unsigned_64_for_reporting': sum(ocaml.values())+sum(native.values()) < (1 << 64),
    }
    candidate = {
        'global_save_entries_upper': r, 'Q': Q, 'C': C, 'O': O,
        'formatter_instances_per_save_upper': K,
        'all_stream_core_events_per_save_upper': events,
        'all_stream_queue_insertions_per_save_upper': insertions,
        'shape_text_bytes_per_string_upper': W,
        'shape_Buffer_per_invocation': shape_buffer,
        'header_Buffer_per_invocation': header_buffer,
        'largest_string_or_backing_bytes_upper': largest_string,
        'caller_local_bytes_per_save_upper': caller,
        'ocaml_requested_block_bytes_by_disjoint_owner': ocaml,
        'c_requested_object_bytes_by_disjoint_owner': native,
        'ocaml_requested_block_bytes_interval_upper': sum(ocaml.values()),
        'c_requested_object_bytes_interval_upper': sum(native.values()),
        'direct_requested_bytes_interval_upper': sum(ocaml.values())+sum(native.values()),
    }
    joined = all(premises.get(p) is True for p in PREMISES) and all(guards.values())
    return {
        'candidate': candidate, 'guards': guards,
        'direct_request_accounting_under_supplied_premises': candidate if joined else None,
        'complete_direct_formatter_request_accounting_under_supplied_premises': joined,
        'peak_physical_memory_bytes': None,
        'allocator_GC_or_pthread_internal_capacity_established': False,
        'native_whole_stack_capacity_established': False,
        'failed_service_capacity_established': False,
        'complete_formatter_capacity_established': False,
        'complete_save_capacity_established': False,
        'whole_pipeline_capacity_established': False,
    }
