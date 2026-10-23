"""Conditional per-owner output and native operand interface.

This module does not establish the source/prefix premises. No target runs.
"""
MAX_INT = 2**62 - 1
MAX_STRING = 2**57 - 9
PP_INFINITY = 1000000010


def natural(n):
    if type(n) is not int or n < 0:
        raise ValueError('expected nonnegative integer, excluding bool')
    return n


def buffer_bounds(offered, initial):
    natural(offered); natural(initial)
    demand = max(offered, initial, 1)
    # The last *temporary* doubling precedes Buffer.resize's clamp.
    power = max(initial, 1)
    while power < demand:
        power *= 2
    return dict(position_and_addition_upper=offered,
                temporary_doubling_upper=power,
                allocated_capacity_upper=min(power, MAX_STRING),
                contents_or_output_length_upper=offered,
                guards=dict(string_extent=offered <= MAX_STRING,
                            resize_doubling=power <= MAX_INT,
                            initial_extent=1 <= initial <= MAX_STRING))


def fresh_core(text, events):
    natural(text); natural(events)
    length = text + events
    # Deliberately larger than every addition/subtraction in the selected
    # fresh core, including a flush's P-left_total after large output.
    arithmetic = 4 * (length + PP_INFINITY + 100)
    offered = text + 70 * (events + 1)
    return dict(text_bytes_upper=text, direct_core_events_upper=events,
                text_and_break_length_upper=length,
                scalar_absolute_upper=arithmetic,
                queue_and_each_stack_length_upper=4 * (events + 1),
                queue_insertions_upper=3 * events + 1,
                depth_upper=events + 1,
                offered_bytes_upper=offered,
                output_callback_calls_upper=4 * (events + 1),
                historical_small_stream_sufficient_guard=length + 79 <= PP_INFINITY,
                requires_new_fresh_scan_drain_lemma=True,
                requires_every_break_under_user_box_or_no_breaks=True,
                requires_no_returning_same_owner_callback=True,
                guards=dict(signed_arithmetic=arithmetic <= MAX_INT,
                            containers_and_depth=4 * (events + 1) + 2 <= MAX_INT))


def request(dimensions, driver_source_bytes, quoted_token_bytes,
            raw_name_bytes, raw_comment_name_bytes):
    for n in (driver_source_bytes, quoted_token_bytes, raw_name_bytes, raw_comment_name_bytes):
        natural(n)
    S, P, H, A, T, E = (dimensions[k] for k in ('S','P','H','A','T','E'))
    for n in (S, P, H, A, T, E): natural(n)
    C = H * ((2*S + P)*(T+1) + 2*(A+1)*(T+2) + 8)
    N = 343 + C
    printed = max(22, 5, 2*(raw_name_bytes+5)) + len(str(N))
    prelude = (H+1)*driver_source_bytes
    text = (quoted_token_bytes+256+printed)*C + 8*H*(raw_comment_name_bytes+1) + prelude + 512
    events = 128*C + 2*prelude + 128
    core = fresh_core(text, events)
    offered = core['offered_bytes_upper']
    return dict(dimensions=dimensions, name_calls_per_owner_upper=C,
                source_units_per_owner_upper=C,
                printed_name_bytes_upper=printed,
                raw_comment_name_bytes_upper=raw_comment_name_bytes,
                request_formatter=core,
                request_buffer=buffer_bounds(offered,1024),
                one_solver_input_file_bytes_upper=offered,
                files_upper=E,
                cumulative_file_bytes_mathematical_upper=E*offered,
                cumulative_total_is_native_operand=False,
                temporary_name_owners_upper=C,
                each_temporary_name_formatter=fresh_core(printed,2),
                each_temporary_name_exact_offered_bytes_upper=printed,
                each_temporary_name_buffer=buffer_bounds(printed,512),
                box_annotation_owners_upper=events,
                each_annotation_formatter=fresh_core(7,2),
                each_annotation_buffer=buffer_bounds(7,16),
                annotation_description_bytes_upper=5,
                annotation_decimal_argument_bytes_upper=1,
                syntax_integer_diagnostic=dict(
                    owner='shared stderr; add to existing whole-interval input budget',
                    attempts_per_request_upper=1, attempts_per_process_upper=E,
                    text_bytes_per_attempt_upper=64,
                    core_events_per_attempt_upper=8,
                    process_text_bytes_upper=64*E,
                    process_core_events_upper=8*E,
                    fresh_stderr_reset_assumed=False),
                optional_at_location_concat=dict(
                    evaluated_even_with_CE_off=True,
                    at_free_input_premise_required=True,
                    increment_count_under_at_free_input_premise=0,
                    generic_byte_formula='attribute_bytes + filename_bytes + 26',
                    generic_byte_input_closed=False),
                format_accumulator_stack_native_layout_closed=False,
                private_maps_and_tables_closed=False,
                source_native_correspondence_is_retained_premise=True,
                whole_printer_capacity=False,whole_process_capacity=False)
