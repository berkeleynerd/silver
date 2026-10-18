#!/usr/bin/env python3
"""Check pinned inputs and structural arithmetic, without running a compiler.

The report supplies the manual branch/reachability argument. Site inventories
are coverage aids, not substitutes for that argument or transitive cost bounds.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re


PIN = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
RANGES = {
    "gcc/ada/checks.adb": [(7688, 7730)],
    "gcc/ada/exp_ch4.adb": [(3367, 3405), (4639, 4654)],
    "gcc/ada/exp_ch6.adb": [(6180, 6209), (6224, 6290), (6734, 6745)],
    "gcc/ada/exp_ch7.adb": [(4780, 4821)],
    "gcc/ada/sem_res.adb": [(13249, 13335)],
    "gcc/ada/libgnat/s-secsta.ads": [(70, 73), (110, 113), (300, 308), (335, 341)],
    "gcc/ada/libgnat/s-imgint.ads": [(37, 76)],
    "gcc/ada/libgnat/s-imagei.ads": [(37, 58)],
    "gcc/ada/libgnat/s-conca2.ads": [(32, 43)],
    "gcc/ada/libgnat/s-conca3.ads": [(32, 43)],
    "gcc/ada/libgnat/s-conca4.ads": [(32, 43)],
    "gcc/ada/libgnat/s-conca5.ads": [(32, 43)],
    "gcc/ada/libgnat/s-conca6.ads": [(32, 43)],
    "gcc/ada/libgnat/s-conca7.ads": [(32, 45)],
    "gcc/ada/libgnat/s-conca8.ads": [(32, 45)],
    "gcc/ada/libgnat/s-conca9.ads": [(32, 45)],
    "gcc/ada/gcc-interface/trans.cc": [
        (1047, 1059), (1189, 1380), (1741, 1752), (2141, 2319),
        (3026, 3306), (3313, 3400), (3843, 3941), (4028, 4126),
        (4228, 4249), (4582, 4613), (4680, 5758),
        (5990, 6003), (6031, 6065), (6076, 6095),
        (6118, 6144), (6150, 6318), (6765, 6774), (6826, 6917), (7086, 7097),
        (7291, 7655), (7656, 7725), (7944, 8003), (8118, 8146), (8603, 8638),
        (8968, 8996), (9104, 9185), (9217, 9278), (9298, 9325),
        (9378, 9406), (9492, 9582), (9757, 9795), (9846, 9856),
        (9889, 10025), (10014, 10494), (10708, 10752)],
    "gcc/ada/gcc-interface/utils.cc": [
        (521, 568), (682, 783), (894, 1062), (1522, 1613), (1691, 1935),
        (2861, 2894), (2918, 3133), (3137, 3162), (3830, 3875),
        (4401, 4460), (4794, 4905), (5009, 5635), (5764, 5851),
        (5911, 6250), (3700, 3755)],
    "gcc/ada/gcc-interface/decl.cc": [
        (352, 445), (697, 718), (754, 766), (1164, 1205), (1278, 1291),
        (1507, 1713), (1901, 2005), (2577, 3193), (3810, 4056),
        (4480, 4495), (4530, 5026), (5538, 5691), (7116, 7128), (7169, 7228), (7532, 7688)],
    "gcc/ada/gcc-interface/utils2.cc": [
        (216, 456), (984, 1520), (1530, 1984), (2018, 2130),
        (2166, 2435), (2564, 2761), (3009, 3380)],
    "gcc/ada/gcc-interface/gigi.h": [(1299, 1307)],
    "gcc/tree.cc": [
        (1212, 1230), (1468, 1479), (4080, 4106), (4132, 4223), (4257, 4283), (6982, 7023),
        (11020, 11077), (11194, 11224)],
    "gcc/passes.def": [(27, 42)],
    "gcc/gimple-low.cc": [(122, 214), (1178, 1223)],
    "gcc/gimplify.cc": [
        (83, 124), (387, 395), (460, 488), (619, 751), (944, 973), (1097, 1101),
        (1270, 1282), (1677, 1845),
        (1971, 2008), (2124, 2157), (2198, 2225), (3221, 3235),
        (3859, 3939), (4651, 4656), (4886, 5013),
        (5036, 5137), (5184, 5809), (6288, 6307), (7002, 7048),
        (7430, 7470), (7547, 7625), (7723, 7799),
        (19462, 19467), (20483, 20500),
        (21295, 21348), (21502, 21558), (21584, 21761)],
    "gcc/gimplify.h": [(53, 54)],
    "gcc/gimple.cc": [(251, 263), (328, 340), (385, 405)],
    "gcc/builtins.cc": [(11051, 11089)],
    "gcc/internal-fn.def": [(520, 522)],
    "gcc/calls.cc": [(590, 630), (807, 824)],
    "gcc/tree-cfg.cc": [(2185, 2200), (2628, 2652)],
    "gcc/tree-nested.cc": [(2656, 2719), (3668, 3690)],
    "gcc/tree-inline.cc": [(6667, 6720)],
}
INTERFACE = ("trans", "utils", "utils2", "decl")
MAIN_APIS = ("src/silver_arguments.ads", "src/silver_io.ads")


def collect(ada, gcc_root):
    sources, manifest, excerpts = {}, [], [
        "# Pinned gigi structural source excerpts\n",
        "Full-file SHA256 identities are in source-manifest.json; LF numbering.\n",
        "Excerpts expand tabs to eight columns and trim trailing whitespace.\n"]
    for name, ranges in RANGES.items():
        path = (ada / name.removeprefix("gcc/ada/")
                if name.startswith("gcc/ada/") else gcc_root / name)
        data = path.read_bytes()
        manifest.append({"path": name, "bytes": len(data),
                         "sha256": hashlib.sha256(data).hexdigest()})
        source = data.decode()
        sources[name] = source
        lines = source.splitlines()
        for low, high in ranges:
            assert 1 <= low <= high <= len(lines)
            excerpts.append(f"\n## {name}:{low}–{high}\n\n```text\n")
            excerpts.extend((f"{n}: " + lines[n-1].expandtabs(8)).rstrip()+"\n"
                            for n in range(low, high+1))
            excerpts.append("```\n")
    # These two identities belong to this Silver tree, not the upstream pin.
    repo = Path(__file__).resolve().parents[3]
    api_manifest = []
    for name in MAIN_APIS:
        data = (repo / name).read_bytes()
        sources[name] = data.decode()
        api_manifest.append({"path": name, "bytes": len(data),
                             "sha256": hashlib.sha256(data).hexdigest()})
        excerpts.append(f"\n## {name} (selected Silver API, complete)\n\n```text\n")
        excerpts.extend((f"{n}: " + line.expandtabs(8)).rstrip()+"\n"
                        for n, line in enumerate(sources[name].splitlines(), 1))
        excerpts.append("```\n")
    patterns = {
        "binding_push": r"\bgnat_pushlevel\s*\(",
        "cleanup_shapes": r"\b(?:TARGET_EXPR|CLEANUP_POINT_EXPR|WITH_CLEANUP_EXPR|TRY_FINALLY_EXPR|TRY_CATCH_EXPR|BIND_EXPR)\b",
        "var_declaration_routes": r"\b(?:create_var_decl|create_temporary|create_init_temporary|create_tmp_var|create_tmp_var_raw|build_decl)\s*\(",
    }
    inventory = {key: [] for key in patterns}
    for stem in INTERFACE:
        name = f"gcc/ada/gcc-interface/{stem}.cc"
        source = sources[name]
        for key, pattern in patterns.items():
            for match in re.finditer(pattern, source):
                line = source.count("\n", 0, match.start()) + 1
                inventory[key].append({"path": name, "line": line,
                                       "match": match.group()})
    return sources, {"commit": PIN, "files": manifest,
                     "silver_main_api_files": api_manifest}, "".join(excerpts), inventory


def check_sources(sources, inventory):
    trans = sources["gcc/ada/gcc-interface/trans.cc"]
    exp6 = sources["gcc/ada/exp_ch6.adb"]
    exp7 = sources["gcc/ada/exp_ch7.adb"]
    passes = sources["gcc/passes.def"]
    assert passes.index("NEXT_PASS (pass_lower_cf)") < passes.index(
        "NEXT_PASS (pass_lower_eh)")
    assert "Add_Return (Spec_Id, Statements (HSS));" in exp6
    assert "Append_To (Stmts, Stmt);\n            Set_Analyzed (Stmt);" in exp6
    assert "Set_At_End_Proc (N, New_Occurrence_Of (Fin_Id, Sloc (N)))" in exp7
    begin = trans.index("\nSubprogram_Body_to_gnu (")
    end = trans.index("\n}\n", begin)
    body = trans[begin:end]
    assert body.index("add_stmt (gnat_to_gnu (Handled_Statement_Sequence") < body.index(
        "At_End_Proc_to_gnu (gnat_node)")
    assert "vec_safe_push (gnu_return_label_stack, NULL_TREE);" in body
    begin = trans.index("\ngnat_gimplify_stmt (tree *stmt_p)")
    end = trans.index("    case EXIT_STMT:", begin)
    loop = trans[begin:end]
    assert loop.index("append_to_statement_list (LOOP_STMT_BODY") < loop.index(
        "tree t = build1 (GOTO_EXPR")
    assert loop.count("create_artificial_label (") == 1
    assert loop.count("build1 (LABEL_EXPR") == 2
    assert loop.count("build1 (GOTO_EXPR") == 2
    # Five optimization-annotation COND-adjacent build3 calls are excluded by
    # the selected flags; the executable condition is one explicit COND_EXPR.
    assert loop.count("build3 (COND_EXPR") == 1
    nested = sources["gcc/tree-nested.cc"]
    assert len(re.findall(r"\bget_nl_goto_field\s*\(", nested)) == 2
    assert not any(row["match"] in {"TARGET_EXPR", "CLEANUP_POINT_EXPR",
                                    "WITH_CLEANUP_EXPR"}
                   for row in inventory["cleanup_shapes"])
    assert "if (No (gnat_cond) || Nkind (gnat_cond) != N_Op_Not)" in trans
    assert "Nkind (gnat_rcond) == N_In" in trans
    assert "|| Nkind (gnat_rcond) == N_Op_Ge" in trans
    assert "|| Nkind (gnat_rcond) == N_Op_Le" in trans
    checks = sources["gcc/ada/checks.adb"]
    assert "Force_Evaluation (N, Mode => Strict);" in checks
    assert "if Source_Base_Type = Target_Base_Type then" in checks
    assert "Left_Opnd  => Duplicate_Subexpr (N)," in checks
    assert "if (!optimize && !Has_Pragma_Inline_Always (gnat_entity))" in trans
    assert "if (fn && TREE_READONLY (fn) && DECL_SAVED_TREE (fn))" in sources["gcc/tree-inline.cc"]
    specs = [name for name in sources if name.startswith("gcc/ada/libgnat/")]
    for name in specs + list(MAIN_APIS):
        assert "inline_always" not in sources[name].lower(), name
    decl = sources["gcc/ada/gcc-interface/decl.cc"]
    start = decl.index("\nelaborate_expression (Node_Id")
    end = decl.index("\n}\n", start)
    helper = decl[start:end]
    assert helper.index("if (present_gnu_tree (gnat_expr))") < helper.index("gnat_to_gnu (gnat_expr)")
    assert "if (!CONTAINS_PLACEHOLDER_P (gnu_expr))" in helper
    assert "save_gnu_tree (gnat_expr, gnu_expr, true);" in helper
    # Source-site/order checks support the separately argued Main dependency
    # frontier. They do not prove every source reference has an association.
    assert decl.index("&& present_gnu_tree (gnat_entity))") < decl.index(
        "gnu_expr = gnat_to_gnu_external (gnat_temp);")
    external_calls = re.findall(r"\bgnat_to_gnu_external\s*\(", decl)
    assert len(external_calls) == 2
    start = trans.index("    case N_Object_Declaration:\n", trans.index("\ngnat_to_gnu (Node_Id"))
    end = trans.index("    case N_Object_Renaming_Declaration:", start)
    object_case = trans[start:end]
    assert object_case.index("gnu_expr = gnat_to_gnu (Expression (gnat_node));") < object_case.index(
        "gnat_to_gnu_entity (gnat_temp, gnu_expr, true);")
    assert "save_gnu_tree (gnat_node, gnu_result, true);" in object_case
    start = trans.index("    case N_Expression_With_Actions:", trans.index("\ngnat_to_gnu (Node_Id"))
    end = trans.index("    case N_Freeze_Entity:", start)
    ewa = trans[start:end]
    assert ewa.index("add_stmt_list (Actions (gnat_node));") < ewa.index(
        "gnu_expr = gnat_to_gnu (Expression (gnat_node));") < ewa.index(
        "gnu_result_type = get_unpadded_type (Etype (gnat_node));")
    assert "? get_gnu_tree (gnat_decl) : NULL_TREE;" in trans
    assert "TREE_CONSTANT (t)" in trans[trans.index("\nconstant_decl_with_initializer_p ("):trans.index("\nconstant_decl_with_initializer_p (")+450]
    tree = sources["gcc/tree.cc"]
    assert "else if (tree_invariant_p (TREE_OPERAND (expr, 1)))" in tree
    assert "else if (tree_invariant_p (TREE_OPERAND (expr, 0)))" in tree
    gimplify = sources["gcc/gimplify.cc"]
    assert "push_gimplify_context (true);" in gimplify
    assert "if (!SAVE_EXPR_RESOLVED_P (*expr_p))" in gimplify
    assert "SAVE_EXPR_RESOLVED_P (*expr_p) = 1;" in gimplify
    assert "t = make_ssa_name (TYPE_MAIN_VARIANT (TREE_TYPE (val)));" in gimplify
    assert "mod = build2 (INIT_EXPR, TREE_TYPE (t), t, unshare_expr (val));" in gimplify
    assert "assign = gimple_build_assign (*to_p, *from_p);" in gimplify
    start = gimplify.index("\ngimplify_type_sizes (tree type,")
    end = gimplify.index("\n}\n", start)
    types = gimplify[start:end]
    assert types.index("TYPE_SIZES_GIMPLIFIED (type) = 1;") < types.index("switch (TREE_CODE (type))")
    assert types.count("gimplify_one_sizepos (") == 7
    start = trans.index("\ngnat_gimplify_expr (")
    end = trans.index("\n}\n", start)
    assert trans[start:end].count("gimplify_one_sizepos (") == 2
    assert "bool rhs_cond_ok = false" in sources["gcc/gimplify.h"]
    start = gimplify.index("\ngimplify_cond_expr (tree *expr_p,")
    end = gimplify.index("\n}\n", start)
    cond = gimplify[start:end]
    assert cond.count("gimple_build_cond (") == 1
    assert cond.count("gimple_build_label (") == 3
    assert cond.count("gimple_build_goto (") == 1
    assert cond.count("create_artificial_label (") == 3
    assert cond.count("maybe_fold_stmt (") == 1
    assert cond.count("build2 (INIT_EXPR,") == 2
    for name in ("tree_associate_condition_with_expr", "gimple_associate_condition_with_expr"):
        start = gimplify.index("\n" + name + " (")
        end = gimplify.index("\n}\n", start)
        helper = gimplify[start:end]
        assert helper.index("if (!condition_coverage_flag)") < helper.index("new hash_map")
    for name in ("ADD_OVERFLOW", "SUB_OVERFLOW", "MUL_OVERFLOW"):
        assert f"DEF_INTERNAL_FN ({name}, ECF_CONST | ECF_LEAF | ECF_NOTHROW, NULL)" in sources["gcc/internal-fn.def"]
    start = tree.index("\nprocess_call_operands (tree t)")
    end = tree.index("\n}\n", start)
    assert "TREE_READONLY (t) = read_only;" in tree[start:end]
    assert "if (tree_invariant_p_1 (inner))\n    return expr;" in tree
    start = gimplify.index("\ngimplify_call_expr (tree *expr_p,")
    end = gimplify.index("\n}\n", start)
    call = gimplify[start:end]
    assert call.index("if (want_value)\n\t    return GS_ALL_DONE;") < call.index("gimplify_arg (")
    assert "auto_vec<tree> vargs (nargs);" in gimplify
    assert sources["gcc/gimple.cc"].count("nargs + 3))") == 2
    assert "if (!saved)\n    save_gnu_tree (gnat_entity, gnu_decl, false);" in decl
    assert "case N_Itype_Reference:\n      if (!present_gnu_tree (Itype (gnat_node)))" in trans
    start = trans.index("\nprocess_type (Entity_Id")
    end = trans.index("\n}\n", start)
    process_type = trans[start:end]
    assert process_type.count("gnat_to_gnu_entity (") == 1
    assert "&& TYPE_IS_DUMMY_P (TREE_TYPE (gnu_old))" in process_type
    utils = sources["gcc/ada/gcc-interface/utils.cc"]
    start = utils.index("\nmake_dummy_type (Entity_Id")
    end = utils.index("\n}\n", start)
    dummy = utils[start:end]
    assert dummy.index("if (PRESENT_DUMMY_NODE") < dummy.index("make_node (")
    assert dummy.count("make_node (") == 2
    assert dummy.count("create_type_stub_decl (") == 1


def arithmetic():
    # Enumerate the call state machine: optional early R, optional late R,
    # and optional CICO P. A temporary only gets made if none already exists.
    call_result_max = 0
    for early in (0, 1):
        for late in (0, 1):
            for cico in (0, 1):
                retval = early
                result_temps = early
                if late and not retval:
                    retval = 1
                    result_temps += 1
                if cico and not retval:
                    result_temps += 1
                call_result_max = max(call_result_max, result_temps)
    assert call_result_max == 1
    # These coefficients arise from the listed sites, not fit measurements.
    push = {"U": 1, "F": 2, "B": 1, "L": 2, "C": 1, "X": 1}
    bind = {"U": 1, "F": 1, "B": 1, "L": 2, "C": 1, "X": 0}
    return {
        "binding_push_coefficients": push,
        "retained_bind_coefficients": bind,
        "main_fixed_framework_push_requests": push["U"] + 2*push["F"],
        "main_fixed_framework_bind_upper_bound": bind["U"] + 2*bind["F"],
        "result_temporary_requests_per_call_upper_bound": call_result_max,
        "loop_lowering_direct_executable_node_requests": 2+2+1,
        "loop_lowering_direct_executable_operand_slots": 2+2+3,
        "loop_lowering_additional_label_declarations": 1,
        "outer_cleanup_eh_Q_upper_bound": 1,
        "outer_cleanup_eh_D_upper_bound": 1,
        "outer_cleanup_eh_may_return": False,
        "inner_cleanup_eh_Q_and_D": 0,
        "clobber_upper_bound": "sum of local VAR_DECL entries in retained BINDs",
        "bind_cleanup_statement_upper_bound": "eligible locals + at most one stack_restore",
        "checked_add_sub_constant_binary_helper_requests": 1+2,
        "checked_multiply_constant_binary_helper_requests": 1+2+2+1,
        "checked_integral_conversion_requests": 1+2+2+2,
        "checked_integral_conversion_binary_helper_requests": 2+1,
        "protect_spine_new_wrapper_nodes": "h1+h3",
        "protect_spine_new_wrapper_operand_slots": "h1+3*h3",
        "protect_spine_terminal_save_expr_requests": 1,
        "call_expression_operand_slots": "n+3",
        "two_actual_overflow_call_operand_slots": 2+3,
        "raise_call_actual_counts": [2, 3, 6],
        "string_copy_requested_bytes_lp64": "stored payload length + 21",
        "call_input_adaptation_requests_per_actual": 1+1+1+1+4,
        "call_compound_helper_requests": "2*P+C",
        "call_assignment_helper_requests": "2*P+2*C",
        "call_component_reference_requests": "P+C",
        "call_unary_helper_requests": "P+2*C",
        "call_direct_statement_append_requests": "3*P+4*C",
        "call_actual_type_resolution_requests": "4*P",
        "ordinary_object_direct_variable_declaration_requests": 4,
        "local_type_backannotation_annotate_value_requests": 2,
        "local_type_backannotation_UI_From_Int_requests": 1,
        "one_dimensional_template_constructor_elements": 2,
        "stabilization_new_nodes": "n1+n2+n3+n4+s",
        "stabilization_new_operand_slots": "n1+2*n2+3*n3+4*n4+s",
        "string_equality_size_binary_requests": 2+2,
        "string_equality_conversion_requests": 3+4+1+2,
        "string_equality_scalar_binary_requests": 2+3+1+2,
        "string_equality_fold_build2_requests": 3+1,
        "ordinary_address_pointer_type_requests": "2*h",
        "ordinary_address_conversion_requests": "2*h",
        "ordinary_address_compound_nodes": "h-1",
        "ordinary_address_terminal_fold_requests": 1,
        "unchecked_scalar_conversion_requests_including_truncation": 1+3,
        "unchecked_integral_tail_binary_requests": 2,
        "secondary_stack_allocation_call_actuals": 2,
        "secondary_stack_allocation_call_operand_slots": 2+3,
        "secondary_stack_allocation_call_size_conversions": 2,
        "secondary_stack_allocator_result_pointer_conversions": 1,
        "diagnostic_preparation_scalar_visits": "3*(D_i+J_i)",
        "diagnostic_preparation_string_or_raise_visits": 0,
        "normalized_signed_type_endpoint_syntax_nodes": 16,
        "signed_type_bound_syntax_visits_per_variable_type": 2*16,
        "String_literal_low_bound_syntax_visits_per_type": 16,
        "Main_value_call_body_copy_requests_in_size_inliner": 0,
        "compiler_generated_size_wrapper_body_copy_requests": "separate layout obligation",
        "variable_Main_lazy_constant_or_renaming_initializers": 0,
        "variable_Main_source_syntax_visits": "O_Main+32*E_Main+3*(D_i+J_i)",
        "variable_Main_source_syntax_visits_cumulative_upper_bound": "A_Main+32*E_Main+3*(D_i+J_i)",
        "unchanged_protected_arithmetic_frontier": "branching arithmetic over recursively invariant leaves; not only a spine",
        "scalar_gimplification_materializations": "N+S+M",
        "scalar_gimplification_INIT_and_raw_assign_requests": "each <= N+S+M",
        "scalar_gimplification_ordinary_copy_nodes": "<= N+S+M",
        "scalar_gimplification_raw_assignment_operand_positions": "<= 3*(N+S+M)",
        "scalar_gimplification_SSA_and_VAR_identities": "each <= N+S+M, counted separately",
        "gimplification_size_position_root_requests": "2*T+2*Ts+3*F+2*Dv+2*Ds",
        "normal_conditional_raw_control_GIMPLE_requests": 1+3+1,
        "normal_conditional_fresh_label_requests": 3,
        "shortcut_context_input": "Cprime=C+V, V<=A",
        "shortcut_normal_control_test_requests": "<= 2*Cprime+A",
        "shortcut_new_COND_EXPR_requests": "<= V+2*A+2*Cprime",
        "shortcut_new_GOTO_EXPR_requests": "<= 5*A+2*Cprime",
        "shortcut_new_LABEL_EXPR_requests": "<= 3*A",
        "shortcut_direct_statement_append_requests": "<= 9*A",
        "conditional_raw_control_GIMPLE_requests": "<= 12*Cprime+13*A",
        "conditional_fresh_control_label_requests": "<= 8*Cprime+8*A",
        "conditional_extra_VAR_requests": "<= Cprime",
        "conditional_extra_assignment_wrappers_and_raw_assignments": "each <= 2*Cprime",
        "conditional_UID_and_context_push_requests": "<= 2*Cprime+2*A",
        "overflow_saved_boundary": "SAVE may be elided for readonly invariant IFN calls",
        "overflow_materialization_input": "I actual call occurrences, retained SAVE children once",
        "overflow_call_materializations_and_INIT_and_raw_GIMPLE": "each <= I",
        "overflow_raw_call_operand_positions": "<= 5*I",
        "overflow_materialization_ordinary_copy_nodes": "sum materialized-call ordinary cut-region weights; not unconditionally linear",
        "nonbuiltin_scalar_call_helper_visits": "<= 3*X",
        "nonbuiltin_scalar_call_actual_visits": "<= 3*P",
        "nonbuiltin_scalar_call_raw_operand_positions": "<= P+3*X",
        "nonbuiltin_scalar_call_unshare_nodes_and_slots": "<= 3*X nodes, P+5*X slots",
        "Main_constructor_bearing_full_entity_conversions": "O+Ts+Ta+Tl+Tp <= E_Main, each entity once",
        "Main_direct_ordinary_object_declaration_requests": "<= 4*O",
        "Main_deferred_dummy_type_and_decl_requests": "<= 2*T type/debug nodes and T TYPE_DECL, T=Ts+Ta+Tl+Tp",
        "scope": "source identities, local event counts and interface only; not transitive gigi allocation or compiler success",
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ada", type=Path, required=True)
    parser.add_argument("--gcc-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--record", action="store_true",
                        help="Write the pinned manifest/excerpts/inventory initially")
    args = parser.parse_args()
    bundle = Path(__file__).resolve().parent
    sources, manifest, excerpts, inventory = collect(args.ada, args.gcc_root)
    # Anchor Ada identities against the previously retained full source inventory.
    prior = bundle.parent / "unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json"
    known_ada = {"gcc/ada/"+x["path"]: x for x in json.loads(prior.read_text())["files"]}
    for row in manifest["files"]:
        if row["path"].startswith("gcc/ada/"):
            assert row["sha256"] == known_ada[row["path"]]["sha256"]
    gcc_manifest = json.loads((args.gcc_root / "manifest.json").read_text())
    assert gcc_manifest["commit"] == PIN
    known_gcc = {row["path"]: row for row in gcc_manifest["files"]}
    for row in manifest["files"]:
        if not row["path"].startswith("gcc/ada/"):
            assert row == known_gcc[row["path"]], row["path"]
    check_sources(sources, inventory)
    records = {"source-manifest.json": manifest, "site-inventory.json": inventory}
    if args.record:
        for name, value in records.items():
            (bundle / name).write_text(json.dumps(value, indent=2)+"\n")
        (bundle / "source-excerpts.md").write_text(excerpts)
    else:
        for name, value in records.items():
            assert json.loads((bundle / name).read_text()) == value, name
        assert (bundle / "source-excerpts.md").read_text() == excerpts
    result = {"commit": PIN, "source_files_checked": len(manifest["files"]),
              "silver_main_api_files_checked": len(manifest["silver_main_api_files"]),
              "arithmetic": arithmetic(), "compiler_runs": 0,
              "solver_runs": 0, "lean_builds": 0}
    args.output.write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
