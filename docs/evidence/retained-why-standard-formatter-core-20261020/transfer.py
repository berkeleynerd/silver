"""Conditional aggregate core envelope for the two standard Format roots.

The argument is in the research note. This interface checks arithmetic and
explicit premise joins; it is not an executable proof of the source argument.
"""

MAX_INT = (1 << 62) - 1
P = 1000000010
ROOTS = 2
PREMISES = (
    "selected_source_native_runtime_relation",
    "initial_default_system_states_for_both_roots",
    "fixed_selected_callbacks_and_tokens",
    "whole_interval_prospective_B_E",
    "no_return_to_stale_same_formatter_core_frame",
)


def bounds(text_bytes, events, premises=None):
    if any(type(x) is not int or x < 0 for x in (text_bytes, events)):
        raise ValueError("B and E must be nonnegative mathematical integers")
    premises = {} if premises is None else premises
    if not isinstance(premises, dict) or set(premises) - set(PREMISES):
        raise ValueError("unknown premise")
    if any(type(x) is not bool for x in premises.values()):
        raise ValueError("premises require explicit booleans")
    b, e = text_bytes, events
    length = b + e
    insertions = 3 * e + ROOTS
    total = P + length + 1
    size = (3 * e + 1) * total
    counters = 4 * insertions + 2
    guards = {
        "flush_sentinel": length + 79 <= P,
        "size_and_intermediate_arithmetic": size + length + 79 <= MAX_INT,
        "container_counters_and_depth": counters <= MAX_INT,
    }
    candidate = {
        "aggregate_roots": ROOTS,
        "L": length,
        "I": insertions,
        "T": total,
        "S": size,
        "right_total_interval": [1, P + length],
        "left_total_interval": [1, 1 + length],
        "pending_count_interval": [-length, P + length - 1],
        "scan_size_interval": [-total, size],
        "space_left_interval": [-length, 78],
        "box_width_interval": [-length - 1, 78],
        "unclamped_indentation_interval": [0, length + 79],
        "indent_interval": [0, 68],
        "depth_interval": [0, e + 1],
        "each_container_counter_absolute_upper": counters,
        "each_linked_container_length_upper": insertions + 1,
        "queue_insertion_attempts_including_entry_tokens_upper": insertions,
        "set_size_calls_upper": 3 * e,
        "sentinel_initialization_attempts_including_entry_upper": 4 * e + ROOTS,
        "core_new_requested_ocaml_bytes_upper": 640 * insertions,
        "offered_standard_channel_bytes_upper": b + 70 * (e + ROOTS),
        "core_output_field_invocations_upper": 4 * (e + ROOTS),
        "channel_output_or_flush_invocations_upper": 6 * (e + ROOTS),
    }
    joined = all(premises.get(p) is True for p in PREMISES)
    return {
        "guards": guards,
        "candidate": candidate,
        "all_premises_supplied": joined,
        "joined_core_bounds": candidate if joined and all(guards.values()) else None,
        "initial_storage_A_pre": None,
        "runtime_service_R": None,
        "physical_sufficiency_established": False,
        "complete_formatter_capacity_established": False,
        "complete_save_or_exit_capacity_established": False,
        "whole_pipeline_capacity_established": False,
    }
