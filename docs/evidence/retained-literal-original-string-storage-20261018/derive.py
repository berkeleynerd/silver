#!/usr/bin/env python3
"""Arithmetic projection of the two source-specialized helper constructors.

The linked source note establishes control-flow and folding closure. This
module is not a compiler simulator and does not price shared backing.
"""
import json


# Family, request ceiling, individual caller-byte ceiling (excluding P).
FIXED_GGC_ROWS = [
    ('private_unary', 5, 32), ('private_binary', 7, 40),
    ('private_ternary', 2, 48),
    ('substitution_unary', 10, 32), ('substitution_binary', 22, 40),
    ('substitution_ternary', 4, 48),
    ('PARM_DECL', 4, 256), ('RESULT_DECL', 2, 256),
    ('FUNCTION_DECL', 2, 512), ('TREE_LIST', 6, 40),
    ('FUNCTION_TYPE_candidate', 2, 256), ('POINTER_TYPE', 2, 256),
    ('type_hash_record', 2, 16), ('BLOCK', 2, 96),
    ('MODIFY_EXPR', 2, 40), ('RETURN_EXPR', 2, 32),
    ('args_vector', 2, 64), ('size_functions_vector', 1, 64),
    ('ADDR_EXPR', 2, 32), ('CALL_EXPR', 2, 64),
    ('identifier_node', 4, 40), ('parameter_characters', 2, 3),
    ('small_INTEGER_CST_miss', 3, 32),
]
NAME_ROW = ('helper_characters', 2, 33)


def rho(n):
    assert n >= 1
    return 1 << (n - 1).bit_length()


def evaluate_at(P):
    assert 0 <= P <= (1 << 31) - 1 - 33
    return {
        'P': P,
        'GGC_events': sum(n for _, n, _ in FIXED_GGC_ROWS) + NAME_ROW[1],
        'GGC_caller_bytes_sum_ceiling':
            sum(n*b for _, n, b in FIXED_GGC_ROWS) + 2*(P+33),
        'GGC_rounded_slots_sum_ceiling':
            sum(n*rho(b) for _, n, b in FIXED_GGC_ROWS) + 2*rho(P+33),
    }


def evaluate():
    return {
        'scope': 'two complete self_referential_size constructor invocations',
        'cold_Standard_String_conversions': 1,
        'helper_constructors': 2,
        'parameters_per_helper': 2,
        'top_level_substitute_in_expr_calls': 4,
        'input_shapes': {
            'byte': {'unary': 2, 'binary': 3, 'ternary': 1},
            'bit': {'unary': 3, 'binary': 4, 'ternary': 1},
        },
        'substitution_envelope': {
            'all_ancestors_both_passes': {'unary': 10, 'binary': 14, 'ternary': 4},
            'extra_outer_association_binary': 4,
            'extra_conditional_inversion_binary': 4,
            'GGC_events': 36,
            'caller_bytes_sum_ceiling': 1392,
            'fold_created_constants': 0,
            'fold_created_types': 0,
            'fold_created_calls': 0,
            'ordinary_allocations': 0,
            'discarded_candidates_included': True,
        },
        'GGC_groups': [
            dict(family=k, requests=n, caller_bytes_ceiling=b,
                 rounded_slot_bytes_ceiling=rho(b))
            for k, n, b in FIXED_GGC_ROWS
        ] + [dict(family=NAME_ROW[0], requests=2,
                  caller_bytes_ceiling='P+33', rounded_slot_bytes_ceiling='rho(P+33)')],
        'GGC_events': 94,
        'GGC_caller_bytes_sum_ceiling': {'constant': 6832, 'P_coefficient': 2},
        'GGC_rounded_slots_sum_ceiling': {'constant': 7912, 'rho(P+33)_coefficient': 2},
        'ordinary_groups': [dict(family='self_refs_vector', requests=2,
                                caller_bytes_ceiling=40, explicit_release=True)],
        'ordinary_requests': 2,
        'ordinary_caller_bytes_sum_ceiling': 80,
        'identity_demands': {
            'fresh_DECL_UIDs': 8, 'fresh_type_UIDs_ceiling': 4,
            'helper_name_fnno_increments': 2,
            'function_definition_numbers': 0, 'SSA_names': 0,
            'RTL_pseudos': 0, 'RTL_labels': 0, 'symbol_registrations': 0,
        },
        'shared_container_demands': {
            'identifier_insertion_capable_lookups': 6,
            'identifier_new_entries_ceiling': 4,
            'type_hash_insertion_capable_lookups': 2,
            'type_hash_new_records_ceiling': 2,
            'scalar_constant_lookups_ceiling': 10,
            'existing_small_constant_cache_new_entries_ceiling': 3,
            'new_small_constant_cache_vectors': 0,
            'int_constant_hash_insertions': 0,
            'finalizer_registrations': 0,
            'constant_pool_entries': 0,
        },
        'finite_arithmetic_guards': {
            'P_min': 0, 'P_max': (1 << 31)-1-33,
            'incoming_fnno_max': (1 << 64)-1-2,
            'incoming_next_decl_uid_max': (1 << 31)-1-8,
            'incoming_next_type_uid_max': (1 << 32)-1-4,
        },
        'reference_P_values': [evaluate_at(p) for p in (0, 31, 32, 255, 4096, (1 << 31)-34)],
        'broader_Standard_String_conversion_included': False,
        'original_empty_elaboration_construction_included': False,
        'original_Main_gigi_included': False,
        'synthetic_gimplification_and_struct_function_included': False,
        'cgraph_nodes_and_symbol_registration_included': False,
        'shared_table_backing_included': False,
        'collector_pages_and_allocator_metadata_included': False,
        'stack_and_system_library_internals_included': False,
        'whole_literal_pipeline_closed': False,
        'independent_review': 'pending',
        'native_runs': 0,
    }


if __name__ == '__main__':
    print(json.dumps(evaluate(), indent=2))
