#!/usr/bin/env python3
"""Reproduce reviewed-by-source local concat envelopes, not tool admission.

The rows are a manual control-flow derivation, not automatic call-graph closure.
The script checks pinned inputs, emits a lexical inspection aid, and sums rows.
It neither executes GNAT nor establishes costs of the named open helper routes.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser()
parser.add_argument("ada_source", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
repository = Path(__file__).resolve().parents[4]
manifest = json.loads((repository / "docs/evidence/unbounded-programs/"
    "continuation-20261017/frontend-lifetimes/complete-source-manifest.json").read_text())
pin = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
assert manifest["commit"] == pin
expected = {entry["path"]: entry for entry in manifest["files"]}
files = ["exp_ch4.adb", "exp_util.adb", "sem_util.adb", "sem_res.adb",
         "sem_eval.adb", "tbuild.adb", "namet.adb", "lib.adb", "validsw.ads",
         "atree.adb", "types.ads", "uintp.ads", "uintp.adb", "gen_il-gen.adb",
         "exp_imgv.adb", "exp_put_image.adb", "exp_ch2.adb", "exp_ch3.adb",
         "exp_ch8.adb", "sem_ch4.adb", "sem_dim.adb", "rtsfind.ads",
         "elists.adb", "libgnat/g-htable.ads", "libgnat/s-htable.adb",
         "sem_ch3.adb", "sem.adb", "sem_ch2.adb", "sem_ch8.adb", "checks.adb",
         "freeze.adb", "layout.adb", "lib-xref.adb", "sem_warn.adb",
         "sem_elim.adb", "sem_cat.adb", "einfo-utils.adb", "sem_ch13.adb",
         "exp_ch13.adb", "nlists.adb", "itypes.adb", "expander.adb",
         "sem_aux.adb", "ghost.adb", "sem_type.adb", "restrict.adb",
         "local_restrict.adb", "accessibility.adb", "opt.ads",
         "sem_attr.adb", "exp_attr.adb"]
sources = {}
hashes = {}
for name in files:
    raw = (args.ada_source / name).read_bytes()
    hashes[name] = hashlib.sha256(raw).hexdigest()
    blob = hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest()
    assert hashes[name] == expected[name]["sha256"], name
    assert blob == expected[name]["git_blob_sha1"], name
    sources[name] = raw.decode()

# Each pair denotes n_coefficient * n + constant, where n >= 2.
ordinary_rows = [
    ("initial aggregate zero", "2829", 0, 1),
    ("operand bounds/length, excluding last-bound capture", "2870-3045", 4, 0),
    ("last-bound capture, including two Convert_To calls", "2879-3007", 0, 8),
    ("aggregate lengths", "3054-3099", 5, 0),
    ("lower-bound conditional spine and capture", "3176-3228", 4, 3),
    ("high-bound expression", "3237-3253", 0, 3),
    ("null-result selection", "3273-3290", 0, 6),
    ("static maximum and optional slice range", "3306-3315", 0, 2),
    ("result subtype syntax", "3326-3342", 0, 4),
    ("result storage, maximum of secondary/plain paths", "3374-3433", 0, 12),
    ("runtime concatenation call", "3512-3538", 0, 3),
    ("slice assignment with optional guard", "3554-3617", 12, 0),
    ("result reference and optional slice", "3629-3632", 0, 2),
    ("saved old node in terminal Rewrite", "3453,3637", 0, 1),
]
entity_rows = [
    ("dynamic operand length", "3015", 1, 0),
    ("aggregate length beyond first retained operand", "3078", 1, -1),
    ("captured lower bound", "3219", 0, 1),
    ("result object", "3344", 0, 1),
    ("secondary-stack subtype/access/object", "3367,3368,3404", 0, 3),
]
list_rows = [
    ("dispatch operand list", "8046", 0, 1),
    ("action collection", "2658", 0, 1),
    ("lower-bound conditionals", "3197", 1, 0),
    ("null-result selectors", "3276,3285", 0, 2),
    ("result index constraint", "3342", 0, 1),
    ("result-storage Insert_Action wrappers", "3374-3430", 0, 4),
    ("runtime actuals and Insert_Action wrapper", "3513,3535", 0, 2),
    ("assignment guard and Insert_Action wrapper", "3617,3620", 2, 0),
]
copy_rows = [
    ("operand lower bound", "2905,2976", 1, 0),
    ("last literal lower/high bounds", "2881,2886", 0, 2),
    ("aggregate length capture", "3096", 1, -1),
    ("lower-bound recursion", "3179,3205", 1, 0),
    ("high-bound expression", "3249,3252", 0, 2),
    ("null-result selectors", "3278,3287", 0, 2),
    ("error-path bound rewrite", "3453", 0, 1),
    ("slice assignment endpoints", "3556,3561", 2, 0),
]

def table(rows):
    return {"rows": [{"reason": reason, "exp_ch4_lines": lines,
                       "n_coefficient": n, "constant": c}
                      for reason, lines, n, c in rows],
            "n_coefficient": sum(row[2] for row in rows),
            "constant": sum(row[3] for row in rows)}

# This aids coverage inspection; it does not decide whether a site is reachable.
calls = []
for line_number, line in enumerate(sources["exp_ch4.adb"].splitlines(), 1):
    if 2829 <= line_number <= 3638 or 8046 <= line_number <= 8092:
        code = line.split("--", 1)[0]
        for call in re.findall(r"\b(?:Make_\w+|New_\w+|Insert_Actions?|"
                               r"Duplicate_Subexpr|Convert_To|Rewrite|"
                               r"Analyze_And_Resolve|Freeze_Itype|RTE(?:_Available)?)\b", code):
            calls.append({"line": line_number, "name": call})

def uint_digits(magnitude):
    assert magnitude >= 0
    digits = 1
    while magnitude >= 32768:
        digits += 1
        magnitude //= 32768
    return digits

examples = []
for n, input_bound in [(2, 4096), (9, 4096), (10, 4096), (64, 4096),
                       (2**31 - 2, 2**31 - 1)]:
    magnitude = n * max(2 * input_bound + 1, 256) + input_bound + 1
    digits = uint_digits(magnitude)
    examples.append({"operands": n, "input_magnitude_bound": input_bound,
                     "intermediate_magnitude_bound": magnitude, "base_32768_digits": digits,
                     "direct_uint_entries": 7 * n + 6,
                     "including_index_helper_arithmetic_uint_entries": 13 * n + 6,
                     "including_index_helper_arithmetic_digit_words": digits * (13 * n + 6)})

result = {
    "source_commit": pin,
    "source_files_verified": len(files),
    "source_sha256": hashes,
    "scope": "native String concat direct emitter and specified primitive helpers; not transitive closure",
    "ordinary_allocations_excluding_New_Copy_Tree_and_open_helpers": table(ordinary_rows),
    "fresh_temporary_entities_and_internal_names": table(entity_rows),
    "list_headers_including_direct_Insert_Action_wrappers": table(list_rows),
    "direct_New_Copy_Tree_invocations": table(copy_rows),
    "simple_aggregate_leaf_copies": {"n_coefficient": 1, "constant": 2},
    "remaining_direct_New_Copy_Tree_invocations": {"n_coefficient": 4, "constant": 4},
    "Duplicate_Subexpr_invocations": {"n_coefficient": 2, "constant": 2},
    "ordinary_allocations_including_simple_aggregate_leaf_copies": {"n_coefficient": 26, "constant": 47},
    "direct_growing_slot_events": 1,
    "direct_Name_Enter_characters_per_temporary_including_NUL": 13,
    "direct_uint_additions": {"n_coefficient": 3, "constant": 2},
    "direct_uint_subtractions": {"n_coefficient": 2, "constant": 2},
    "Get_First_Index_Bounds_invocations": {"n_coefficient": 2, "constant": 0},
    "uint_arithmetic_examples_not_admission_thresholds": examples,
    "decorated_copy_transfer": {
        "premises": "no owned normal entities/actions/blocks/dimensions/packed/discriminated types; owned itypes only one-dimensional String array subtypes, signed scalar index subtypes and String-literal subtypes; default empty entity map",
        "ordinary_nodes": "t + a + sum(r_j)",
        "entities_and_names": "e",
        "syntax_list_headers": "l + a + sum(s_j)",
        "pending_itype_elist_headers": "q",
        "pending_itype_elist_elements": "e",
        "new_entity_hash_entries": "e",
        "pending_itype_hash_entries": "q",
        "growing_slot_events": 0,
        "String_Uint_value_allocations": 0,
        "hash_lifetime": "wrappers freed at next public copy reset; Elist headers/elements retained",
        "examples": [
            {"shape": "scalar leaf", "t": 1, "l": 0, "a": 0, "sum_r": 0,
             "sum_s": 0, "e": 0, "q": 0, "ordinary_nodes": 1, "syntax_lists": 0},
            {"shape": "Image slice with simple bounds", "t": 5, "l": 0, "a": 1,
             "sum_r": 3, "sum_s": 0, "e": 2, "q": 1,
             "ordinary_nodes": 9, "syntax_lists": 1},
            {"shape": "First attribute of the same Image slice", "t": 6, "l": 0, "a": 1,
             "sum_r": 3, "sum_s": 0, "e": 2, "q": 1,
             "ordinary_nodes": 10, "syntax_lists": 1},
        ],
    },
    "native_Image_shape": "Integer Image uses Image_Integer procedure plus Snn(1..Pnn), not Put_Image/unconstrained function call",
    "mutable_renaming_pointer_capture": {
        "premises": "already-analyzed ordinary pointer name; existing named access to String; relevant types frozen; known nonnull; no renaming/current value/actual subtype/OK_To_Rename on old pointer; fresh local internal constant; no aspects/delayed freeze/static allocation/foreign convention; ordinary non-Ghost procedure/block; empty Related_Id",
        "analysis_of_generated_declaration_and_final_dereference_extra_allocations": 0,
        "Duplicate_Subexpr_total_including_direct_capture_and_final_tree_copy": {
            "ordinary_nodes": 8, "entities_and_internal_names": 1,
            "syntax_list_wrappers": 1, "growing_slot_events": 0,
            "pending_itype_elist_headers_and_elements": 0,
            "String_Uint_value_allocations": 0,
            "internal_name_characters_including_NUL": 13,
        },
        "not_included": "Insert_Actions placement/context handling; derivation of source-to-shape premises; prior access-type creation/freezing; backend",
    },
    "concat_allocator_expansion": {
        "runtime_entity": "RE_SS_Allocate",
        "runtime_unit": "System.Secondary_Stack",
        "ordinary_node_entity_list_allocations_in_Expand_N_Allocator": 0,
        "premises": "generated named access to constrained uncontrolled String; expression subtype identifier; No_Initialization; not special return/coextension; Linux 64-bit address; no restrictive config diagnostic",
        "not_included": "allocator semantic analysis, access-type declaration/freezing, RTE lookup/dependency loading, backend emission",
    },
    "concat_named_access_declaration_and_freeze": {
        "premises": "fresh generated named access to existing frozen constrained String subtype in current ordinary procedure/block scope; no aspects/storage-size/default-pool/private/derived/remote/controlled/task cases",
        "declaration_extra_elist_headers": 1,
        "first_freeze_extra_ordinary_nodes": 1,
        "first_freeze_extra_syntax_list_headers": 1,
        "extra_entity_name_String_Uint_allocations": 0,
        "repeated_freeze_extra_allocations": 0,
        "new_runtime_seeds": [],
        "not_included": "direct declaration syntax, incoming subtype construction/freezing, Insert_Actions context/scope handling, backend",
    },
    "concat_allocator_analysis_and_resolution": {
        "premises": "new ConstrT subtype identifier; exact designated subtype of existing frozen named access type; No_Initialization; no subpool/qualified expression/controlled/task/tagged/coextension cases",
        "extra_entities_and_internal_names": 1,
        "extra_node_list_elist_String_Uint_allocations": 0,
        "name_characters_including_NUL": 13,
        "retention": "E_Allocator_Type remains retained after expression type replaced with named access type",
        "not_included": "direct allocator syntax, enclosing object/renaming declaration, runtime lookup/loading, later whole-scope/backend processing",
    },
    "scalar_variable_bound_capture": {
        "premises": "already-analyzed nonvolatile ordinary local Integer-family variable identifier; no renaming/current value/actual subtype/OK_To_Rename/pending Do_Range_Check; relevant types frozen; fresh internal non-Ghost constant with no aspects/delayed freeze; empty Related_Id",
        "ordinary_nodes": 5, "entities_and_internal_names": 1,
        "syntax_list_wrappers": 1, "name_characters_including_NUL": 13,
        "growing_slot_events": 0,
        "extra_analysis_node_entity_list_name_String_Uint_allocations": 0,
        "repeated_Force_Evaluation_of_result_allocations": 0,
        "not_included": "Insert_Actions context/transient handling, source-to-shape derivation, backend",
    },
    "ordinary_String_Set_Slice_Subtype": {
        "premises": "resolved nonpacked one-dimensional String slice; N_Range with t scalar-tree ordinary nodes, no lists/owned entities/itypes/actions; separately charged bounds already side-effect-free under Variable_Ref; no dimension/type attributes; compile-time-known bounds reduce to literals or finite constant-name chains",
        "ordinary_nodes": "t + 2",
        "entities_and_internal_names": 2, "name_characters_including_NUL": 26,
        "syntax_list_headers": 2,
        "growing_slot_events_elist_hash_String_allocations": 0,
        "retained_Uint_entries": 4,
        "retained_Uint_magnitude": "8*(2*H+1), H bounds both input magnitudes",
        "Uint_entries_when_a_bound_value_unknown": 0,
        "UI_Mul_transient_digit_words_for_multiplication_by_8": "2*(k+1), k digits in other operand",
        "Itype_Reference_semantic_and_expander_allocations": 0,
        "Itype_Reference_invokes_Freeze_Itype": False,
        "leaf_range_example": {"t": 3, "ordinary_nodes": 5},
        "not_included": "input syntax/resolution/range checks, bound capture/analysis, Insert_Actions context/transient handling, later freezing/backend",
    },
    "ordinary_String_slice_pair_freezing": {
        "premises": "unaltered Set_Slice_Subtype output; artificial local String/index itypes in current scope; standard/ancestor types frozen; index size 32 bits, array Esize unknown, earlier compile-time size check complete; no aspects/predicates/representation/remote/controlled/task flags",
        "Freeze_Entity_without_delayed_freeze_extra_allocations": 0,
        "per_unfrozen_member_with_delayed_freeze_max_ordinary_nodes": 1,
        "per_unfrozen_member_with_delayed_freeze_max_list_headers": 1,
        "explicit_Freeze_Itype_of_fresh_array_max_ordinary_nodes": 1,
        "explicit_Freeze_Itype_of_fresh_array_max_list_headers": 1,
        "freeze_node_analysis_expansion_extra_allocations": 0,
        "repeated_freeze_extra_allocations": 0,
        "not_included": "Insert_Actions context/transient handling, out-of-scope freeze analysis, later backend, explicit object-derived subtype construction",
    },
    "signed_Integer_index_layout": {
        "premises": "unpredicated signed Integer subtype, no biased representation; finite ancestor chain to frozen Standard Integer; selected compile-time-known bounds are literal/constant chains in -2**31 .. 2**31-1",
        "max_signed_loop_tests": 32,
        "max_power_cache_multiplications": 31,
        "max_Uint_negations": 64,
        "retained_Uint_entries": 95,
        "retained_Uint_digit_words": 285,
        "UI_Ints_cache_insertions": 95,
        "maximum_local_transient_Uint_digit_words": 8,
        "node_entity_list_name_String_allocations": 0,
        "not_included": "incoming range resolution/capture/checks, derived itype name, ancestor/constant-chain stack, cache wrapper bytes, backend",
    },
    "dynamic_range_check_tree_construction": {
        "premises": "no discriminant/access/fixed-lower-bound/static-error route; post-analysis side-effect-free bounds with b ordinary nodes and l syntax-list headers total, no owned itypes/entities/actions",
        "ordinary_nodes": "2*b + 28",
        "syntax_list_headers": "2*l",
        "bound_copy_nodes": "2*b",
        "Convert_To_calls": 6,
        "Convert_To_max_nodes_per_call": 3,
        "bound_attribute_nodes": 4,
        "other_constructor_nodes": 6,
        "entity_name_growing_slot_String_Uint_allocations_in_builder": 0,
        "suppression_prevents_construction": False,
        "not_included": "Compile_Time_Compare/Determine_Range numeric analysis, incoming resolution/capture, static-error handler, enabled-check analysis and placement",
    },
    "scalar_Determine_Range_and_Compile_Time_Compare": {
        "premises": "finite acyclic signed Integer expression/initializer/index-bound graph; +,-,* and unary signs, discrete conversions, scalar conditionals, ordinary String First/Last/Length; no modular/real/generic/discriminant/representation/Interfaces-array/expression-actions; known values are literal/constant chains",
        "A": "maximum fully unfolded rooted tree nodes including captured initializers and queried/substituted index bounds",
        "Determine_Range_Uint_appends": "6*A",
        "Determine_Range_local_Uint_weights": {
            "unary_plus_conversion_constant_forwarding": 0,
            "unary_minus": 2, "addition": 2, "subtraction": 4,
            "multiplication_including_Release_And_Save": 6,
            "String_Length": 6, "unrefined_leaf": 0,
        },
        "Compile_Time_Compare_max_invocations_including_recursive": 5,
        "Determine_Range_max_queries": 10,
        "Is_Same_Value_max_pair_walks": 10,
        "Compile_Time_Compare_ordinary_nodes": "20*A",
        "Compile_Time_Compare_Uint_appends": "80*A + 60",
        "Compile_Time_Compare_Uint_digits": "k*(80*A + 60)",
        "Compile_Time_Compare_other_table_allocations": 0,
        "maximum_local_transient_Uint_digit_words": "5*k+3",
        "no_static_error_Get_Range_Checks_ordinary_nodes": "2*b + 28 + 20*A",
        "no_static_error_Get_Range_Checks_syntax_lists": "2*l",
        "not_included": "source derivation of unfolded shape/acyclicity/magnitude/count, recursive walk stack bytes, numeric cache wrapper bytes, enabled check insertion/analysis",
    },
    "suppressed_explicit_String_subtype_resolved_pure_bounds": {
        "premises": "fresh artificial local ordinary subtype; existing defining entity/input syntax charged; one N_Range with already-analyzed nonoverloaded pure scalar bounds; combined finite analysis graph and 32-bit layout premises; all checks suppressed; standard and referenced scalar types frozen; no aspects/predicates/representation/generic/spec-expression/error/transient wrap",
        "ordinary_nodes": "2*b + 32 + 20*A",
        "extra_entities": 1, "extra_name_entries": 1,
        "name_characters_including_NUL": "L+4, L subtype identifier length",
        "Uint_appends": "80*A + 155", "growing_slot_events": 2,
        "syntax_list_headers": "2*l",
        "elist_String_allocations": 0,
        "dynamic_slot_envelope": "9*(2*b+34+20*A)+61",
        "secondary_concat_index_max_name_characters_including_NUL": 16,
        "plain_object_Find_Type_Of_Object_before_subtype_analysis": {
            "ordinary_nodes": 2, "entities": 1, "syntax_list_wrappers": 1,
            "name_characters_including_NUL": "O+3, O object name length",
            "subtype_plus_index_max_name_characters_for_O_at_most_12": 33,
        },
        "not_included": "initial analysis of generated scalar arithmetic/conditionals, capture, enabled-check analysis, insertion placement/transient contexts, freezing/backend",
    },
    "ordinary_for_range_capture_placement": {
        "premises": "ordinary scalar for-range parent chain; no spec expression or transient scope",
        "placement": "containing statement list immediately before loop",
        "Expression_With_Actions_created_by_this_route": False,
        "source_routes": ["exp_util.adb:12765-12824", "exp_util.adb:8289-8314", "exp_util.adb:8318-8462"],
        "not_included": "proof-domain replay multiplicity and proof-mode exclusion of transient scopes/Itype_Reference replay",
    },
    "generated_Integer_add_subtract_semantic_transfer": {
        "premises": "generated Standard Make_Op_Add/Subtract, already analyzed/resolved nonoverloaded operands of frozen Standard Integer base; all checks suppressed; no pending overflow flag/error/dimension/unset diagnostic/transient wrap; constant-folded intermediates fit Integer",
        "extra_ordinary_nodes": 2,
        "extra_growing_slot_events": 1,
        "extra_Uint_appends": 2,
        "entity_overload_list_name_String_allocations": 0,
        "direct_concat_operator_nodes": "4*n+2",
        "one_initial_analysis_if_all_premises_hold": {
            "ordinary_nodes": "8*n+4", "growing_slot_events": "4*n+2",
            "Uint_appends": "8*n+4",
        },
        "not_included": "child/attribute/conditional analysis, enabled-check plain-storage route, copies/reanalysis/source-to-event multiplicity, backend",
    },
    "generated_Integer_conditional_semantic_transfer": {
        "premises": "artificial complete if expression; already analyzed/resolved Standard Boolean condition and same frozen Standard Integer base/context branches; no actions/delayed expansion/diagnostics/dimensions/checks/conversion-return-aggregate-transient-spec context; strict overflow; validity-test and coverage overrides disabled; no allocating rewrite callbacks; known values are existing literal/constant chains",
        "extra_ordinary_nodes": 2,
        "extra_growing_slot_events": 1,
        "Uint_String_entity_name_overload_list_allocations": 0,
        "direct_concat_conditional_nodes": "n+2",
        "one_initial_analysis_if_all_premises_hold": {
            "ordinary_nodes": "2*n+4", "growing_slot_events": "n+2",
        },
        "not_included": "child comparison/arithmetic/attribute transfers, input Expressions lists, enabled-check route, copies/reanalysis/source-to-event multiplicity, backend",
    },
    "generated_Integer_equality_semantic_transfer": {
        "premises": "artificial Standard Make_Op_Eq/Ne and artificial Original_Node; already analyzed/resolved nonoverloaded same frozen Integer base operands and Boolean context; strict overflow, suppressed checks, no diagnostics/dimensions/transient/callback additions; no root entity Length attribute through conversions; finite initializer graph per comparison transfer",
        "extra_ordinary_nodes": "40*A+5",
        "extra_growing_slot_events": 2,
        "extra_Uint_appends": "160*A+120",
        "extra_syntax_lists_eq": 1,
        "extra_syntax_lists_ne": 0,
        "entity_name_elist_String_overload_allocations": 0,
        "Compile_Time_Compare_calls": 2,
        "direct_concat_comparisons": "2*n+2",
        "one_initial_analysis_if_all_premises_hold": {
            "ordinary_nodes": "(2*n+2)*(40*A+5)",
            "growing_slot_events": "4*n+4",
            "Uint_appends": "(2*n+2)*(160*A+120)",
            "syntax_lists": 2,
        },
        "not_included": "first child analysis, generated range-check comparisons, copies/reanalysis/source-to-event multiplicity, backend",
    },
    "generated_String_bound_attribute_semantic_transfer": {
        "premises": "artificial First/Last/Length without dimension; analyzed/resolved nonoverloaded ordinary String object/view/subtype prefix with frozen referenced entities, frozen ordinary nonpacked/nonprivate/nongeneric/nonpredicated non-literal String nominal/actual subtype and Integer indices; no access-typed prefix/BIP/concurrent/union/error/dimension/pending check/transient/spec/callback additions; Integer base context and folded results fit; checks suppressed, strict overflow; existing known bound values",
        "First_Last": {"ordinary_nodes": 2, "growing_slot_events": 1, "Uint_appends": 0},
        "Length": {"ordinary_nodes": "20*A+4", "growing_slot_events": 2, "Uint_appends": "80*A+64"},
        "extra_Length_arithmetic_magnitude": "2*H+1, combined with comparison magnitude envelope",
        "entity_name_list_elist_String_overload_allocations": 0,
        "direct_concat_First_Last_nodes": "n+2",
        "direct_concat_Length_nodes": "n",
        "one_initial_analysis_if_all_premises_hold": {
            "ordinary_nodes": "20*n*A+6*n+4",
            "growing_slot_events": "3*n+2",
            "Uint_appends": "n*(80*A+64)",
        },
        "not_included": "first prefix analysis, outer conversions, nonfrozen copied slice itypes, insertion contexts, copies/reanalysis/source-to-event multiplicity, backend",
    },
    "lexical_call_sites_not_a_reachable_call_graph": calls,
    "limitations": ["no native compiler/prover/build execution", "no complete source-to-event bound",
                    "no semantic/generated-action/recursive-copy closure", "no safe language threshold",
                    "no backend or dependency cost included", "no independent review yet"],
}
assert (result["ordinary_allocations_excluding_New_Copy_Tree_and_open_helpers"]["n_coefficient"],
        result["ordinary_allocations_excluding_New_Copy_Tree_and_open_helpers"]["constant"]) == (25, 45)
assert (result["fresh_temporary_entities_and_internal_names"]["n_coefficient"],
        result["fresh_temporary_entities_and_internal_names"]["constant"]) == (2, 4)
assert (result["list_headers_including_direct_Insert_Action_wrappers"]["n_coefficient"],
        result["list_headers_including_direct_Insert_Action_wrappers"]["constant"]) == (3, 11)
assert (result["direct_New_Copy_Tree_invocations"]["n_coefficient"],
        result["direct_New_Copy_Tree_invocations"]["constant"]) == (5, 6)
for case in result["decorated_copy_transfer"]["examples"]:
    assert case["ordinary_nodes"] == case["t"] + case["a"] + case["sum_r"]
    assert case["syntax_lists"] == case["l"] + case["a"] + case["sum_s"]
args.output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({"verified_sources": len(files), "lexical_call_sites": len(calls),
                  "ordinary_direct": "25*n+45", "whole_construct_closed": False}))
