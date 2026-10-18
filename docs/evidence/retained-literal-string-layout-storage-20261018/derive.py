#!/usr/bin/env python3
"""Source-specialized request arithmetic; no compiler execution or fitted multiplier."""
import json

# A row is (name, request count, caller-byte upper bound per request).
FIXED_ROWS = [
    ('type nodes: 3 records, 2 pointers, unconstrained, array, Positive, 2 ranges', 10, 256),
    ('TYPE_DECL stubs/names (stub reuse included)', 7, 256),
    ('FIELD_DECL: P_ARRAY, P_BOUNDS, LB0, UB0, BOUNDS, ARRAY', 6, 256),
    ('lang_type: XUP, XUB, index, XUT', 4, 16),
    ('RM TREE_VEC(3): Positive and Ada range', 2, 48),
    ('DECL_EXPR temporaries', 5, 32),
    ('template INDIRECT_REF', 1, 32),
    ('bound widenings', 2, 32),
    ('array extent widening', 1, 32),
    ('object extent widening', 1, 32),
    ('placeholder', 1, 24),
    ('template and bound COMPONENT_REFs', 3, 48),
    ('initial bound comparison', 1, 40),
    ('initial high-bound conditional', 1, 48),
    ('array arithmetic plus possible conditional inversions', 8, 40),
    ('array extent conditionals', 4, 48),
    ('object arithmetic, masks and two discarded merge_sizes results', 8, 40),
]
CONSTANT_ROWS = [
    ('Character component validation: UI_To_gnu and modulo', 2),
    ('Positive signed extrema', 2),
    ('Positive mode bit/byte size', 2),
    ('Positive low bound direct Uint', 1),
    ('Positive high bound: base, first, 2*(digit,multiply,add)', 8),
    ('Positive Esize validation/modulo and RM size', 3),
    ('two pointer layouts: bit/byte size', 4),
    ('update_n_elem: 2 conversions, subtract, add, multiply', 5),
    ('maximum array byte size multiplication', 1),
    ('array length literal one', 1),
    ('array bit-size round_up divisor', 1),
    ('five fixed-size field advances', 5),
    ('two record offset normalizations: 7 scalar factory sites each', 14),
    ('three final record bit/byte positions: 6 scalar factory sites each', 18),
    ('four fixed-record mode field positions: 3 scalar factory sites each', 12),
    ('six finish_record_type field positions: 3 scalar factory sites each', 18),
    ('twelve finish_record_type merge_sizes scalar sites', 12),
    ('variable field: ceil-divide, conversion, add, multiple divisor', 4),
    ('XUT bit rounding: divisor, ratio, addend, mask, AND probe, second divisor', 6),
    ('XUT byte rounding: divisor, addend, mask, constant association, AND probe, second divisor', 6),
    ('array folds: negate one, false-arm sum, zero widening, zero product', 4),
]
NAMES = ['string', 'positive', 'string___XUB', 'string___UB0', 'string___XUA',
         'P_ARRAY', 'P_BOUNDS', 'LB0', 'UB0', 'BOUNDS', 'ARRAY']

def rho(n):
    assert isinstance(n, int) and n > 0
    return 1 << (n - 1).bit_length()

def evaluate():
    constants = sum(n for _, n in CONSTANT_ROWS)
    rows = FIXED_ROWS + [('scalar INTEGER_CST factory envelope', constants, 40),
                         ('identifier nodes', len(NAMES), 40)]
    rows += [('identifier bytes: ' + s, 1, len(s) + 1) for s in NAMES]
    return {
        'GGC_events': sum(n for _, n, _ in rows),
        'GGC_caller_bytes': sum(n * size for _, n, size in rows),
        'GGC_separately_rounded_bytes': sum(n * rho(size) for _, n, size in rows),
        'scalar_constant_factory_envelope': constants,
        'ordinary_requests': 3,
        'ordinary_caller_bytes': 3 * 64,
        'type_UID_increments': 10,
        'decl_UID_increments': 13,
        'identifier_lookups': len(NAMES),
        'identifier_new_entries': len(NAMES),
        'identifier_character_bytes': sum(len(s) + 1 for s in NAMES),
        'global_decls_pushes': 5,
        'alias_sets_pushes_envelope': 2,
        'alias_ID_increments_envelope': 1,
        'large_integer_insertion_capable_lookups_envelope': constants,
        'large_integer_new_entries_envelope': constants,
        'small_integer_cache_writes_envelope': constants,
        'new_integer_cache_vectors': 0,
        'type_hash_insertion_capable_lookups': 0,
        'tree_pool_insertion_capable_lookups': 0,
        'tree_pool_entries': 0,
        'tree_pool_replacement_objects': 0,
        'make_decl_rtl_calls': 0,
        'constructor_address_materializations': 0,
        'finalizers': 0,
        'cgraph_registrations': 0,
        'function_definition_numbers': 0,
        'RTL_labels': 0,
        'RTL_pseudos': 0,
        'symbol_order_increments': 0,
        'helper_94_included': False,
        'synthetic_173_included': False,
        'Main_null_helper_11_included': False,
        'original_Main_and_elaboration_included': False,
        'per_literal_subtype_and_constructor_included': False,
        'shared_table_backing_included': False,
        'direct_request_interval': 'first complete Standard.String conversion through final association/deferred processing, with both complete self_referential_size constructor invocations excised',
        'shared_demand_cutpoint': 'only residual operations in that interval; add helper94 demands once; consume shared backing in its existing aggregate component',
        'complete_cold_String_direct_constructor_transfer': True,
        'complete_imported_frontend': False,
        'complete_global_containers': False,
        'complete_collector': False,
        'complete_whole_pipeline': False,
    }

if __name__ == '__main__':
    print(json.dumps(evaluate(), indent=2))
