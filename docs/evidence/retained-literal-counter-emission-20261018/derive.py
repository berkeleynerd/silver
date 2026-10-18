#!/usr/bin/env python3
"""Selected source-derived counter interface, not a complete capacity verdict."""
import argparse
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
I32 = (1 << 31) - 1


def interface():
    return {
        'scope': 'Selected literal family, unchanged retained GCC/configuration premises',
        'selected_empty_elaboration_symbol_registration_closed': True,
        'empty_elaboration_symbol_registrations': 0,
        'empty_elaboration_function_definition_increment': 1,
        'size_helper_symbol_registrations': 2,
        'size_helper_function_definition_increment': 2,
        'size_helper_private_name_increment': 2,
        'target_hook_additional_function_definitions': 0,
        'target_hook_additional_symbol_registrations': 0,
        'function_definition_number_prefix': 0,
        'function_definition_numbers': {
            'empty_elaboration': 0, 'Main': 1,
            'String_bit_size_helper': 2, 'String_byte_size_helper': 3},
        'next_function_definition_number': 4,
        'nonnull_function_allocations': 4,
        'finalized_function_definitions': 3,
        'initial_function_gimplifications': 3,
        'ordinary_lowered_functions': 1,
        'emitted_functions': 1,
        'non_Main_function_definition_increment': 3,
        'additional_emitted_functions_from_non_Main_frontier': 0,
        'symbol_registration_formula': 'B+D+4',
        'next_symbol_UID_formula': 'B+D+5',
        'next_symbol_order_formula': 'B+D+4',
        'B_definition': 'distinct registered Main bounds-pool declarations, B<=C',
        'D_definition': 'distinct called output procedures, 1<=D<=min(2,C)',
        'main_function_boundary_labels': ['.LFB1', '.LFE1'],
        'main_function_boundary_label_bytes_excluding_NUL': 5,
        'non_Main_counter_effect_on_selected_emission_closed': True,
        'additional_emitted_lines_from_non_Main_frontier': 0,
        'inherited_local_label_bytes_excluding_NUL': 25,
        'inherited_symbol_name_bytes_including_NUL': 26,
        'inherited_instruction_line_bytes_excluding_LF': 64,
        'inherited_complete_line_bytes_excluding_LF': 512,
        'inherited_final_RTL_data_and_invocation_premises_required': True,
        'inherited_RTL_label_counter_condition_required': True,
        'inherited_constant_label_counter_condition_required': True,
        'complete_imported_allocation_events': None,
        'complete_imported_allocation_bytes': None,
        'complete_global_counter_lifetime_closed': False,
        'complete_collector_lifetime_closed': False,
        'whole_literal_pipeline_capacity_established': False,
        'independent_review': 'pending',
    }


def evaluate(calls, nulls):
    """Counts must come from the parent's accepted complete source recognizer.

    This exports source-derived upper bounds; it neither admits programs nor
    guesses B/D from C. In particular C=1 retains the conservative D<=2 ceiling.
    """
    if type(calls) is not int or calls < 1:
        raise ValueError('calls must be an integer >=1')
    if type(nulls) is not int or nulls < 0:
        raise ValueError('nulls must be an integer >=0')
    return {
        'calls': calls, 'null_statements': nulls,
        'interface': interface(),
        'symbol_registrations_upper': calls + 6,
        'next_symbol_UID_upper': calls + 7,
        'next_symbol_order_upper': calls + 6,
        'live_symbols_after_both_helper_removals_upper': calls + 4,
        'assigned_symbol_UID_upper': calls + 6,
        'assigned_symbol_order_upper': calls + 5,
        'symbol_next_values_fit_signed_32': calls + 7 <= I32,
        'function_definition_next_value_fits_signed_32': 4 <= I32,
        'synthetic_counter_changes_preserve_inherited_emission_envelopes': True,
        'whole_literal_pipeline_capacity_established': False,
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('calls', type=int)
    parser.add_argument('nulls', type=int)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    result = json.dumps(evaluate(args.calls, args.nulls), indent=2) + '\n'
    if args.output:
        args.output.write_text(result)
    else:
        print(result, end='')
