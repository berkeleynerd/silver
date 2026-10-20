"""Scoped selected typed-format/accumulator transfer, not whole allocation."""

PREMISES = (
    'selected_source_native_and_valid_value_relation',
    'normal_numerical_and_allocation_services',
    'faithful_pending_callbacks_and_private_frames',
    'retained_occurrence_continuation_and_global_save_budget',
)
PARTS = ('F', 'Th', 'G', 'T', 'Axml', 'A', 'Args', 'Paths')
MAX_TEMPLATE_NODES = 27  # Includes the one-node annotation subformat.
MAIN_CHAIN_LIMIT = 32  # Dominates the census maximum 26.


def bounds(parts, saves=3, premises=None):
    if set(parts) != set(PARTS):
        raise ValueError('exact occurrence fields required')
    if any(type(v) is not int or v < 0 for v in parts.values()):
        raise ValueError('nonnegative integer occurrences required')
    if type(saves) is not int or not 1 <= saves <= 3:
        raise ValueError('the accepted global interval permits one to three saves')
    premises = {} if premises is None else premises
    if not set(premises) <= set(PREMISES) or any(type(v) is not bool for v in premises.values()):
        raise ValueError('explicit named Boolean premises required')
    p = parts
    q = 1 + sum(p.values())
    calls = (6 + 4*p['F'] + 4*p['Th'] + 6*p['G'] + 3*p['T']
             + 8*p['Axml'] + 3*p['A'] + 2*p['Args'] + p['Paths'])
    boxes = 1 + 2*(p['F'] + p['Th'] + p['G'] + p['T']) + p['Axml'] + p['A'] + p['Paths']
    assert calls <= 8*q and boxes <= 2*q
    nodes = MAX_TEMPLATE_NODES*calls
    candidate = {
        'Q': q,
        'formatted_calls_per_save_upper': calls,
        'formatted_calls_uniform_Q_upper': 8*q,
        'acc_nodes_including_annotation_per_save_upper': nodes,
        'make_printf_dispatches_per_save_upper': nodes + 3*calls,
        'output_acc_entries_per_save_upper': nodes + 3*calls,
        'alpha_callback_executions_per_save_upper': 4*calls,
        'box_annotation_helpers_per_save_upper': boxes,
        'annotation_source_scan_entries_per_save_upper': 30*boxes,
        'annotation_int_parser_calls_per_save_upper': boxes,
        'asprintf_buffer_formatter_pairs_per_save_upper': p['G'] + 1,
        'annotation_buffer_formatter_pairs_per_save_upper': boxes,
        'accumulator_and_format_continuation_requested_bytes_per_save_upper': 128*calls + 192*nodes,
        'annotation_parser_and_description_requested_bytes_per_save_upper': 208*boxes,
        'accumulator_and_format_continuation_requested_bytes_interval_upper': saves*(128*calls + 192*nodes),
        'annotation_parser_and_description_requested_bytes_interval_upper': saves*208*boxes,
        'formatted_calls_interval_upper': saves*calls,
        'acc_nodes_interval_upper': saves*nodes,
        'output_acc_direct_frames_across_nested_saves_upper': saves*(2*(MAIN_CHAIN_LIMIT+1)+2),
        'output_acc_direct_stack_bytes_across_nested_saves_upper': saves*32*(2*(MAIN_CHAIN_LIMIT+1)+2),
        'make_printf_direct_loop_stack_growth_per_node_bytes': 0,
        'annotation_scan_direct_loop_stack_growth_per_character_bytes': 0,
        'dynamic_typed_format_ast_nodes_allocated_in_selected_stream': 0,
    }
    ready = all(premises.get(p, False) for p in PREMISES)
    return {
        'candidate': candidate,
        'accumulator_bounds_under_supplied_named_relation': candidate if ready else None,
        'all_named_premises_supplied': ready,
        'source_semantics_machine_proved': False,
        'native_whole_stack_bound': None,
        'whole_formatter_allocated_bytes': None,
        'failed_service_capacity_established': False,
        'complete_formatter_capacity_established': False,
        'complete_save_capacity_established': False,
        'whole_pipeline_capacity_established': False,
    }
