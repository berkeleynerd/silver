"""Private-printer structural traversal bounds after source control discharge."""

PREMISES = (
    'fixed_source_native_runtime_live_value_relation',
    'selected_fresh_fixed_task_SV6_and_immutable_name_inputs',
    'accepted_pending_and_exit_owner_configuration_preserved',
    'global_three_save_two_exception_protocol_and_no_discarded_frame_resume',
    'ordinary_primitive_outcomes_and_no_unclassified_native_OCaml_entry',
    'accepted_per_task_occurrence_and_string_guards',
)
MAX_INT = (1 << 62) - 1


def bounds(G, P, premises=None):
    if type(G) is not int or type(P) is not int or G < 0 or P < 0:
        raise ValueError('nonnegative counts required')
    p = {} if premises is None else premises
    if not isinstance(p,dict) or set(p)-set(PREMISES) or any(type(v) is not bool for v in p.values()):
        raise ValueError('explicit named Boolean premises required')
    Q = P * (P + 1)
    spec = P * (Q + 2 * P + 4)
    cap = 2048
    resizes = 0
    while P > 2 * cap:
        cap *= 2
        resizes += 1
    # Old candidate bound is preserved. The new table theorem tightens the
    # cardinality, but does not rewrite any frozen shape/allocation packet.
    per_printer = {
        'find_unique_entries_upper':P,
        'each_table_binding_and_scalar_size_upper':P,
        'indices_replace_calls_upper':2 * P,
        'indices_first_replace_insertions_or_resizes':0,
        'indices_possible_insertion_sites_upper':P,
        'values_replace_calls_upper':P,
        'each_table_capacity_upper':cap,
        'each_table_completed_or_final_abandoned_resize_calls_upper':resizes,
        'bucket_nodes_per_find_mem_or_replace_scan_upper':P,
        'bucket_cells_per_resize_prefix_upper':P,
        'suffix_index_upper_unchanged':Q,
        'specname_calls_upper_unchanged':spec,
        'table_client_entries_upper':5 * P + spec,
        'all_client_and_redistribution_bucket_visits_upper':P * (8 * P + spec),
    }
    guards={'suffix_successor':Q + 1 <= MAX_INT,
        'table_size_and_capacity_doubling':max(P,2 * cap) <= MAX_INT}
    joined=all(p.get(k) is True for k in PREMISES) and all(guards.values())
    return {
        'global_save_entries_upper':3,
        'global_escaping_signal_save_exceptions_upper':2,
        'simultaneous_signal_save_children_of_ordinary_save_upper':1,
        'printer_instances_interval_upper':3 * G,
        'candidate':per_printer,
        'guards':guards,
        'printer_structure_and_finite_tool_traversals_under_supplied_premises':per_printer if joined else None,
        'first_replace_no_resize_and_reused_printer_valid_under_supplied_premises':joined,
        'application_service_progress_established':False,
        'physical_resources_established':False,
        'complete_save_capacity_established':False,
        'whole_pipeline_capacity_established':False,
    }


def consume_signal_exception(remaining):
    """Ledger operation for a consumed callback-origin exception, not a miss."""
    if type(remaining) is not int or remaining < 1 or remaining > 2:
        raise ValueError('no unspent global escaping signal exception')
    return remaining - 1
