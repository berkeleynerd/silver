#!/usr/bin/env python3
"""Source-ledger arithmetic; not a compiler simulator or capacity decision."""
import json

INT_MAX = (1 << 31) - 1
SCALAR_PARTS = {
    "subtype_operands": 24,
    "two_ranges": 4,
    "two_arrays": 26,
    "validate_size": 13,
    "set_rm_size": 12,
    "two_size_annotations": 62,
    "data_pointer": 8,
    "template_endpoints": 2,
    "two_constructor_sorts": 12,
    "call_operand_count": 1,
}
EXCLUDED = [
    "cold_Standard_String_conversion", "self_referential_size_94",
    "synthetic_function_and_initial_helper_173", "Main_struct_function",
    "direct_Main_gimplifier_10C_2N_2", "Main_ingress_33C_9N_3",
    "materialization_helpers_8C", "pool_10C", "cgraph_symbols_dummy",
    "warning_map", "source_locations", "shared_backing", "collector",
]


def rho(n):
    assert n > 0
    return 1 << (n - 1).bit_length()


def evaluate(lengths, N=0, D=1, implicit_with_visits=None):
    """Lengths are decoded lengths; None leaves fixed context input I open."""
    lengths = tuple(lengths)
    C = len(lengths)
    assert C >= 1 and type(N) is int and N >= 0
    assert type(D) is int and 1 <= D <= min(2, C)
    assert all(type(x) is int and 0 <= x <= INT_MAX for x in lengths)
    assert implicit_with_visits is None or (
        type(implicit_with_visits) is int and implicit_with_visits >= 0)
    V = 73 + 81*C + 4*N
    G = V + C + N + 3
    A = 4*C + 3*N + 2
    H0 = V + G + A
    R = sum(SCALAR_PARTS.values())*C + 16*D + 8
    K = C + 4*D + 5
    type_nodes = 6*C + 5*D + 3
    decl_nodes = 2*C + N + 3*D + 5
    rows = [
        ("FUNCTION_DECL", D+2, 512),
        ("other_declarations", 2*C+N+2*D+3, 256),
        ("type_nodes_including_optional_profile_copies", type_nodes, 256),
        ("language_type_payloads", C+D+1, 16),
        ("literal_RM_values", C, 48),
        ("profile_argument_lists", 2*D, 40),
        ("type_hash_records", 2*(D+1), 16),
        ("ordinary_expressions", 11*C+3*N+D+6, 64),
        ("constructor_vectors_pre_rounded", 2*C, 128),
        ("scalar_constants", R, 40),
        ("small_constant_vectors", R, 2040),
        ("identifier_nodes", K, 40),
        ("identifier_characters", K, 32),
        ("binding_wrappers", C+3, 16),
        ("BLOCK", C+3, 96),
        ("statement_groups", G, 32),
        ("statement_list_headers_excluding_I", H0, 32),
        ("statement_list_links", A, 24),
        ("Main_language_function", 1, 32),
        ("elab_info", 1, 24),
        ("initial_procedure_return_stacks_pre_rounded", 2, 64),
        ("namespace_map_control", 1, 128),
        ("namespace_initial_table", 1, 208),
    ]
    # Keep payloads as individual allocations: rho(sum bytes) is not valid.
    rows += [(f"STRING_CST_{i}", 1, length+21)
             for i, length in enumerate(lengths)]
    base_events = sum(n for _, n, _ in rows)
    base_caller = sum(n*b for _, n, b in rows)
    base_rounded = sum(n*rho(b) for _, n, b in rows)
    symbolic = {
        "GGC_events": {"constant": base_events, "I_coefficient": 1},
        "caller_bytes": {"constant": base_caller, "I_coefficient": 32},
        "rounded_slot_bytes": {"constant": base_rounded, "I_coefficient": 32},
    }
    concrete = None if implicit_with_visits is None else {
        key: val["constant"] + val["I_coefficient"]*implicit_with_visits
        for key, val in symbolic.items()
    }
    return {
        "inputs": {"C": C, "N": N, "D": D, "lengths": list(lengths),
                   "I": implicit_with_visits},
        "derived": {"V": V, "G": G, "A": A, "H_constant": H0,
                    "H_I_coefficient": 1, "R": R, "K": K},
        "rows": [{"family": name, "requests": n, "caller_bytes_each": b,
                  "rounded_slot_bytes_each": rho(b)} for name, n, b in rows],
        "symbolic_direct_totals": symbolic,
        "conditional_direct_totals": concrete,
        "ordinary_literal_scratch": {
            "requests": sum(x >= 1000 for x in lengths),
            "caller_bytes": sum(x for x in lengths if x >= 1000),
            "largest_alloca_bytes": max((x for x in lengths if x < 1000),
                                        default=0),
        },
        "identities": {"DECL_UID": decl_nodes, "type_UID": type_nodes,
                       "alias_ID": 1, "function_definition_numbers": 0,
                       "helper_name_fnno": 0, "annotation_var_count": 0},
        "shared_demands": {
            "identifier_lookups": K, "type_hash_lookups": 2*(D+1),
            "integer_hash_lookups": R, "global_decls_pushes": D+3,
            "stmt_list_cache_pushes": {"constant": H0, "I_coefficient": 1},
            "alias_sets_pushes": 2,
            "scalar_finalizer_vector_pushes": 1,
            "Uint_entries": 2*C, "Udigits_words": 10*C,
            "UI_Ints_wrapper_calls": 2*C,
        },
        "zero_demands": ["tree_constant_pool", "Rep_Table", "annotation_cache",
                         "deferred_decl_context_entries"],
        "original_tree_constant_pool_demands": {
            "insertions": 0, "lookups": 0, "replacements": 0,
            "independent_of_unsupplied_I": True,
            "excludes_later_Main_gimplification_pool": True,
            "independent_review_pending": True,
        },
        "exclusions": EXCLUDED,
        "fixed_context_input_supplied": implicit_with_visits is not None,
        "complete_original_gigi_storage_closed": False,
        "whole_toolchain_capacity_established": False,
        "production_admission_changed": False,
    }


if __name__ == "__main__":
    print(json.dumps(evaluate([13]), indent=2, sort_keys=True))
