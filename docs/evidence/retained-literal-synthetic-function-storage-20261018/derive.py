#!/usr/bin/env python3
"""Direct synthetic-function requests; shared backing is exported, not priced.

The source argument is in the linked research note. This is an arithmetic
projection of that argument, not a compiler simulator or a native experiment.
"""
import json


# (object family, lifetime request ceiling, individual caller-byte ceiling).
# GGC vector rows already cover vec's pre-call ggc_round_alloc_size.
GGC_ROWS = [
    ('function', 3, 208),
    ('eh_status', 3, 48),
    ('machine_function', 3, 320),
    ('EH_pointer_vectors', 6, 64),
    ('gimple_df', 2, 256),
    ('default_def_hash_control', 2, 128),
    ('default_def_hash_backing', 2, 248),
    ('SSA_name_vector', 2, 512),
    ('whole_body_unshare_unary', 21, 32),
    ('whole_body_unshare_binary', 27, 40),
    ('whole_body_unshare_ternary', 6, 48),
    ('materialization_INIT', 10, 40),
    ('materialization_shallow_unshare', 10, 40),
    ('conditional_arm_assignment_trees', 4, 40),
    ('return_VAR_DECL', 2, 312),
    ('scalar_SSA_NAME', 10, 88),
    ('LABEL_DECL', 6, 256),
    ('GIMPLE_ASSIGN', 14, 96),
    ('GIMPLE_COND', 2, 88),
    ('GIMPLE_LABEL', 6, 64),
    ('GIMPLE_GOTO', 2, 64),
    ('GIMPLE_RETURN', 2, 80),
    ('GIMPLE_BIND', 2, 72),
    ('temporary_identifier', 10, 40),
    ('temporary_identifier_characters', 10, 16),
]

ORDINARY_ROWS = [
    ('unshare_hash_control', 2, 64),
    ('unshare_hash_backing', 2, 104),
    ('gimplifier_context_pool_extension', 1, 128),
    ('parameter_pointer_vector', 2, 40),
    ('cfun_stack_first_capacity', 1, 40),
]


def rounded(n):
    return 1 << (n - 1).bit_length()


def groups(rows, ggc=False):
    return [dict(family=k, requests=n, caller_bytes=b,
                 **({'rounded_slot_bytes_ceiling': rounded(b)} if ggc else {}))
            for k, n, b in rows]


def evaluate():
    return {
        'scope': 'three struct-function allocations and two initial gimplifications',
        'function_structure_calls': 3,
        'initial_helper_gimplifications': 2,
        'empty_elaboration_gimplifications': 0,
        'ordinary_lowered_nonMain_functions': 0,
        'emitted_nonMain_functions': 0,
        'input_dimensions': {
            'byte': {'unary': 3, 'binary': 4, 'ternary': 1,
                     'W': 8, 'scalar_materializations': 4},
            'bit': {'unary': 4, 'binary': 5, 'ternary': 1,
                    'W': 10, 'scalar_materializations': 6},
        },
        'GGC_groups': groups(GGC_ROWS, True),
        'GGC_events': sum(n for _, n, _ in GGC_ROWS),
        'GGC_caller_bytes_sum_ceiling': sum(n*b for _, n, b in GGC_ROWS),
        'GGC_rounded_slots_sum_ceiling': sum(n*rounded(b) for _, n, b in GGC_ROWS),
        'ordinary_groups': groups(ORDINARY_ROWS),
        'ordinary_requests': sum(n for _, n, _ in ORDINARY_ROWS),
        'ordinary_caller_bytes_sum_ceiling': sum(n*b for _, n, b in ORDINARY_ROWS),
        'identity_demands': {
            'function_definition_numbers': 3,
            'fresh_DECL_UIDs': 8,
            'fresh_type_UIDs': 0,
            'SSA_names_total': 10,
            'SSA_name_vector_length_per_helper': [5, 7],
            'tmp_var_id_num_increment_ceiling': 10,
            'tmp_var_id_num_incoming_max': (1 << 32) - 1 - 10,
            'condition_UID_next_value_per_helper': 2,
            'CFG_label_UID_assignments': 0,
            'RTL_label_numbers': 0,
        },
        'shared_container_demands': {
            'identifier_insertion_capable_lookups': 10,
            'identifier_new_entries_ceiling': 10,
            'singleton_finalizer_registrations': 2,
            'vector_finalizer_registrations': 0,
            'cfun_stack_pushes': 2,
            'cfun_stack_pops': 2,
            'cfun_stack_peak_length': 1,
            'gimplifier_context_peak_active': 1,
            'gimplifier_context_returns_to_pool': 2,
            'default_def_hashes': 2,
            'default_def_hash_live_entries': 0,
            'default_def_hash_capacity_each': 31,
            'unshare_hash_capacity_each': 13,
            'unshare_hash_live_entries': 0,
            'EH_vector_live_entries_each': 1,
            'parameter_vector_live_entries_each': 2,
        },
        'original_gigi_predecessor_construction_included': False,
        'cgraph_nodes_and_symbol_map_backing_included': False,
        'shared_identifier_backing_included': False,
        'collector_page_and_finalizer_backing_included': False,
        'independent_review': 'pending',
        'whole_literal_pipeline_closed': False,
        'native_runs': 0,
    }


if __name__ == '__main__':
    print(json.dumps(evaluate(), indent=2))
