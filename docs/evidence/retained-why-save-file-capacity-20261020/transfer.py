"""Selected save path/channel representation transfer, excluding global exit I/O."""
MAX_STRING = (1 << 57) - 9
MAX_INT = (1 << 62) - 1
MAX_OFFSET = (1 << 63) - 1
IO_BUFFER = 65536
CHANNEL_STRUCT = 65616
PREMISES = (
    'selected_source_native_and_valid_value_relation',
    'actual_immutable_directory_and_selected_fresh_regular_files',
    'upstream_xml_shape_and_global_save_bounds',
    'private_channel_clients_and_classified_pending_hooks',
    'faithful_selected_posix_io_and_memory_services',
    'positive_count_write_returns_positive_or_interrupts_or_raises',
)


def file_bounds(directory_bytes, xml_bytes, shape_bytes, max_argument_string,
                save_entries=3, premises=None):
    for value in (directory_bytes, xml_bytes, shape_bytes, max_argument_string, save_entries):
        if type(value) is not int or value < 0:
            raise ValueError('bounds must be nonnegative mathematical integers')
    premises = {} if premises is None else premises
    if not isinstance(premises, dict) or set(premises) - set(PREMISES):
        raise ValueError('unknown premise')
    if any(type(value) is not bool for value in premises.values()):
        raise ValueError('premises must be explicit booleans')
    # Three filename joins, at most two binary concatenations each; three backups.
    path = directory_bytes + 20
    block = 8 * (1 + (path + 8) // 8)
    guards = {
        'path_and_binary_concatenation': path <= MAX_STRING,
        'linux_relative_path_argument_with_nul': path + 1 <= 4096,
        'linux_path_components': max(directory_bytes, 19) <= 255,
        'argument_string_length_and_offset': max_argument_string <= MAX_STRING,
        'xml_file_offset': xml_bytes <= MAX_OFFSET,
        'shape_file_offset': shape_bytes <= MAX_OFFSET,
    }
    candidate = {
        'filename_including_backup_bytes_upper': path,
        'c_path_copy_bytes_including_nul_upper': path + 1,
        'path_string_blocks_across_saves_upper': 9 * save_entries,
        'path_string_block_bytes_across_saves_upper': 9 * save_entries * block,
        'c_path_copy_requests_across_saves_upper': 19 * save_entries,
        'c_path_copy_bytes_across_saves_upper': 19 * save_entries * (path + 1),
        'new_descriptor_and_channel_attempts_upper': 2 * save_entries,
        'new_native_channel_record_bytes_upper': 2 * save_entries * CHANNEL_STRUCT,
        'file_exists_calls_upper': 6 * save_entries,
        'remove_calls_upper': 3 * save_entries,
        'rename_calls_upper': 3 * save_entries,
        'xml_offset_plus_pending_bytes_per_descriptor_upper': xml_bytes,
        'shape_offset_plus_pending_bytes_per_descriptor_upper': shape_bytes,
        'offered_bytes_all_new_descriptors_upper': save_entries * (xml_bytes + shape_bytes),
        'open_channel_pending_bytes_upper': IO_BUFFER,
        'syscall_write_request_bytes_upper': IO_BUFFER,
        'native_output_argument_bytes_upper': max_argument_string,
        'successful_write_calls_upper': save_entries * (xml_bytes + shape_bytes),
        'direct_native_output_loop_stack_growth_per_iteration_bytes': 0,
    }
    joined = all(premises.get(name) is True for name in PREMISES)
    return {
        'guards': guards, 'candidate': candidate,
        'selected_file_bounds': candidate if joined and all(guards.values()) else None,
        'all_premises_supplied': joined,
        'service_success_observed': False,
        'total_syscall_or_poll_attempt_count_bounded': False,
        'global_open_channel_list_and_refcount_capacity_established': False,
        'complete_allocator_gc_or_error_capacity_established': False,
        'complete_save_capacity_established': False,
        'whole_pipeline_capacity_established': False,
    }
