"""Conditional fresh selected Format-core extents; not full save capacity."""

MAX_INT = (1 << 62) - 1
PP_INFINITY = 1000000010
PREMISES = (
    "selected_source_native_behavior",
    "fresh_default_typed_private_formatter",
    "input_and_continuation_bounds",
    "private_frame_callback_integrity",
)


def core_bounds(text_bytes, events, premises=None):
    for value in (text_bytes, events):
        if type(value) is not int or value < 0:
            raise ValueError("bounds must be nonnegative mathematical integers")
    premises = {} if premises is None else premises
    if not isinstance(premises, dict) or set(premises) - set(PREMISES):
        raise ValueError("unknown premises")
    if any(type(v) is not bool for v in premises.values()):
        raise ValueError("premises must be explicit booleans")
    length = text_bytes + events
    nodes = 4 * (events + 1)
    guards = {
        "sentinel_and_draining": length + 79 <= PP_INFINITY,
        "container_and_depth": nodes + 2 <= MAX_INT,
    }
    candidate = {
        "text_and_break_length": length,
        "normal_total_upper": 1 + length,
        "space_left_lower": -length,
        "space_left_upper": 78,
        "box_width_lower": -length - 1,
        "box_width_upper": 78,
        "unclamped_indentation_upper": length + 79,
        "depth_upper": events + 1,
        "queue_and_each_stack_length_upper": nodes,
        "queue_insertions_upper": 3 * events + 1,
        "offered_xml_bytes_upper": text_bytes + 70 * (events + 1),
        "core_output_flush_calls_upper": nodes,
        "box_annotation_helpers_upper": events,
        "annotation_raw_bytes_per_helper_upper": 7,
        "annotation_description_bytes_upper": 5,
    }
    joined = all(premises.get(p) is True for p in PREMISES)
    return {
        "guards": guards,
        "candidate": candidate,
        "core_bounds": candidate if joined and all(guards.values()) else None,
        "all_core_premises_supplied": joined,
        "complete_formatter_capacity_established": False,
        "complete_save_capacity_established": False,
        "whole_pipeline_capacity_established": False,
    }
