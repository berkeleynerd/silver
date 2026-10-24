"""C->T individual representation operands; not a parser or admission test.

Both entrypoints are conditional on the accepted producer/source relation.
No free-form count, exponent or initial-state certificate is accepted.
No predecessor checker, extractor, compose or native target is executed.
"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
CONFIGURATION = 'r78_repaired_quiet_timeless_j12_logging'
BODY_LIMIT = (1 << 31) - 2
INT_MAX = (1 << 62) - 1
WOSIZE_MAX = (1 << 54) - 1
STRING_MAX = (1 << 57) - 9
PP_INFINITY = 1000000010
AUXILIARY = json.loads((HERE.parent / 'prefix-auxiliary/exports.json').read_text())['producer_maximum']


def string_request(length):
    """Payload words include the trailing length byte; total includes header."""
    words = (length + 8) // 8
    return {'length': length, 'payload_words': words, 'request_bytes': 8 * (words + 1)}


def _envelope(role, body, configuration):
    if configuration != CONFIGURATION or role not in AUXILIARY:
        raise ValueError('only the accepted configuration and launch roles')
    n = body + 1
    output = max(64 * body + 128, n + 256)
    lexcap = max(1024, 2 * n)
    tokcap = max(256, 2 * n)
    fmtcap = max(512, 2 * output)
    strings = {name: string_request(length) for name, length in {
        'input_auxiliary': 512, 'lexbuf': lexcap,
        'decoded_string_buffer': tokcap, 'decoded_or_lexeme_string': n,
        'parser_error': n + 256, 'format_buffer': fmtcap,
        'format_result': output,
    }.items()}
    numeric = {
        'serialized_signed_decimal_characters': 40,
        'parsed_magnitude_strict_upper': 10 ** 40,
        'parsed_bits_upper': 133,
        'parse_digit_malloc_bytes_upper': 41,
        'parse_custom_limbs_upper': 3,
        'ureal_numerator_upper': (1 << 64) - 1,
        'ureal_denominator_absolute_upper': 4080,
        'selected_ureal_bases': [2, 16],
        'constructor_exponent_absolute_upper': 16320,
        'normalization_factor_strict_upper': 1 << 128,
        'normalized_exponent_absolute_upper': 16384,
        'all_arithmetic_operand_limbs_upper': 3,
        'each_custom_request_limbs_upper': 6,
        'each_custom_payload_words_upper': 8,
        'each_custom_total_bytes_upper': 72,
        'radix_power_or_shift_calls_before_T': 0,
        'ordinary_Main_ureal_occurrences': 0,
        'real_literal_base_zero_path_selected': False,
        'later_five_atom_contract_used': False,
        'GMP_primitive_contract': 'Inherited faithful bounded-operand numeric/allocation contract; not a proof of GMP internals.',
    }
    parser = {
        'file_bytes_including_Close_LF': n,
        'lexbuf_capacity_upper': lexcap,
        'decoded_string_buffer_capacity_upper': tokcap,
        'lexbuf_or_buffer_addition_absolute_upper': 4 * n + 2048,
        'position_or_error_coordinate_absolute_upper': 4 * n + 8,
        'line_number_upper': n + 1,
        'unquoted_integer_magnitude_upper': (1 << 31) - 1,
        'error_result_string_upper': n + 256,
        'error_junk_buffer_bytes': 32,
        'JSON_list_cells_per_list_upper': body,
        'JSON_containers_are_fixed_arity_blocks_and_lists': True,
        'read_array_helper_selected': False,
        'float_or_intlit_branch_selected': False,
        'generated_lexer_tables_have_source_fixed_extents': True,
    }
    formatting = {
        'per_call_output_bytes_upper': output,
        'private_buffer_capacity_upper': fmtcap,
        'queue_length_upper': 4 * body + 64,
        'normal_left_right_total_upper': output + 1,
        'flush_right_total': PP_INFINITY,
        'arithmetic_absolute_upper': 2 * output + 2 * PP_INFINITY + 256,
        'maximum_box_depth': 1,
        'formatter_initial_buffer': 512,
        'Printf_initial_buffer': 64,
        'format_accumulators_have_source_fixed_arity': True,
        'dynamic_width_precision_or_user_format': False,
        'same_private_formatter_reused_across_conversion_calls': False,
        'outer_failure_report_and_post_T_printers_included': False,
    }
    guards = {
        'each_string_length': all(s['length'] <= STRING_MAX for s in strings.values()),
        'each_string_header': all(s['payload_words'] <= WOSIZE_MAX for s in strings.values()),
        'each_unsigned_byte_request': all(s['request_bytes'] < 1 << 64 for s in strings.values()),
        'parser_arithmetic': max(parser['lexbuf_or_buffer_addition_absolute_upper'], parser['position_or_error_coordinate_absolute_upper']) <= INT_MAX,
        'formatter_arithmetic': max(formatting['queue_length_upper'], formatting['arithmetic_absolute_upper'], 2 * fmtcap) <= INT_MAX,
        'numeric_header_and_request': numeric['each_custom_payload_words_upper'] <= WOSIZE_MAX and numeric['each_custom_total_bytes_upper'] < 1 << 64,
    }
    return {
        'role': role, 'configuration': configuration, 'producer_body_bytes_upper': body,
        'consumer_scope': 'Actual producer serialization to first Typing.type_mlw_file entry, before its body; failures stop with their existing outcome.',
        'source_provider_relation_required': True,
        'Yojson': parser, 'Number_BigInt': numeric, 'Format_Printf_Buffer': formatting,
        'individual_strings': strings, 'guards': guards,
        'consumer_representation_closed_under_inherited_premises': all(guards.values()),
        'accepted_auxiliary_owner_projection_reused': True,
        'complete_C_to_T_representation_when_joined_to_accepted_prefix_and_auxiliary': all(guards.values()),
        'T_to_builder_transport': False,
        'cumulative_physical_bytes_or_stack_bound_claimed': False,
        'process_global_exception_allowance': 2, 'save_entering_callbacks': 2, 'save_calls': 3,
    }


def producer_envelope(role, configuration=CONFIGURATION):
    return _envelope(role, BODY_LIMIT, configuration)


def from_serialized_json(role, data, configuration=CONFIGURATION):
    """Size actual producer bytes; does not validate JSON/schema/source origin."""
    if type(data) is not bytes or not data.endswith(b'\n'):
        raise ValueError('actual producer bytes including Outputs.Close LF required')
    body = len(data) - 1
    if not 0 < body <= BODY_LIMIT:
        raise ValueError('outside the existing producer body-byte interface')
    return _envelope(role, body, configuration)


def trunc_divmod(v, p):
    q = abs(v) // p
    if v < 0:
        q = -q
    return q, v - q * p


def normalize_trace(v, prime):
    """Exact Number.normalize source recursion, retaining all intermediates."""
    if v == 0 or prime not in (2, 5):
        raise ValueError('real_value handles zero before normalize')
    trace = []
    def visit(v, p, e, depth):
        d, m = trunc_divmod(v, p)
        trace.append({'v': v, 'p': p, 'e': e, 'd': d, 'm': m, 'depth': depth})
        if m:
            return v, 0
        e2 = e + e
        trace.append({'e2': e2, 'p_squared': p * p})
        w, f = visit(d, p * p, e2, depth + 1)
        d, m = trunc_divmod(w, p)
        trace.append({'v': w, 'p': p, 'e': e, 'd': d, 'm': m, 'f': f, 'depth': depth})
        return (d, f + e2) if m == 0 else (w, f + e)
    result = visit(v, prime, 1, 1)
    return {'value': result[0], 'valuation': result[1], 'trace': trace}
