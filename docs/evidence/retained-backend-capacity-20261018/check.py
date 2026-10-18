#!/usr/bin/env python3
"""Reproduce source identities and local backend arithmetic, without compiling.

The handwritten report supplies reachability and composition reasoning. This
script checks inputs, excerpts and its stated arithmetic; it is not a proof of
the complete compiler or a compiler-success membership test.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile


RANGES = {
    "gcc/tree-cfg.cc": [(72, 79), (145, 214), (488, 555), (631, 666),
                        (810, 1024), (1085, 1220), (1325, 1405),
                        (1507, 1698), (1710, 1852), (2633, 2666)],
    "gcc/cfg.cc": [(65, 83), (214, 231), (278, 342)],
    "gcc/cfg.h": [(38, 70)],
    "gcc/input.cc": [(1045, 1059)],
    "gcc/passes.def": [(25, 47)],
    "gcc/gimple-low.cc": [(122, 214), (1178, 1223)],
    "gcc/gimplify.cc": [(944, 1050), (1096, 1126), (1270, 1282), (1699, 1830)],
    "gcc/tree-eh.cc": [(618, 655), (710, 877), (940, 1095),
                       (1107, 1283), (1289, 1800), (2333, 2356), (3318, 3349)],
    "gcc/gimple.cc": [(251, 263), (1563, 1577), (1901, 1931), (2045, 2095), (2297, 2333)],
    "gcc/tree-inline.cc": [(5735, 5795), (5861, 6060), (6667, 6720)],
    "gcc/langhooks-def.h": [(145, 158)],
    "gcc/ada/back_end.adb": [(123, 130), (155, 175)],
    "gcc/ada/gcc-interface/trans.cc": [(87, 91), (346, 363), (6705, 6732),
                                       (1201, 1289), (1330, 1369), (4911, 5015),
                                       (5688, 5691), (6779, 6881), (7086, 7116),
                                       (7291, 7342), (7415, 7470), (7605, 7616),
                                       (7756, 7821), (7944, 7974), (8603, 8622),
                                       (8968, 8996), (9298, 9305), (3301, 3306),
                                       (9889, 10025), (11006, 11030)],
    "gcc/ada/gcc-interface/decl.cc": [(400, 445), (697, 718), (754, 766), (1278, 1291),
                                      (2664, 2712), (3142, 3177)],
    "gcc/ada/gcc-interface/misc.cc": [(376, 377), (1475, 1476)],
    "gcc/ada/gcc-interface/utils.cc": [(259, 280), (430, 450), (770, 783),
                                      (4095, 4390)],
    "gcc/toplev.cc": [(761, 767), (1141, 1150)],
    "gcc/ggc-page.cc": [(1250, 1290), (1292, 1327), (1883, 1922)],
    "gcc/ggc.h": [(230, 258)],
    "gcc/tree.cc": [(142, 156), (770, 785), (1089, 1143), (1368, 1383),
                     (1468, 1547), (1581, 1616), (1696, 1729),
                     (1776, 1953), (2008, 2013), (2482, 2488), (2616, 2636),
                     (2926, 2960), (3834, 3872), (4132, 4170),
                     (4257, 4377), (4756, 4932),
                     (5840, 5965), (6433, 6492), (7198, 7385),
                     (7460, 7511), (7576, 7668), (8025, 8088),
                     (11024, 11113), (11637, 12013), (15095, 15129)],
    "gcc/tree.h": [(5460, 5467), (5500, 5517), (5921, 5929)],
    "gcc/tree-core.h": [(1138, 1253), (1565, 1595), (1631, 1648),
                         (1696, 1700), (1801, 1871)],
    "gcc/stor-layout.cc": [(67, 87), (296, 339), (603, 633), (909, 929),
                            (1962, 2067), (2402, 2427), (2437, 2469), (2558, 2576),
                            (2651, 2773), (2810, 2821), (2838, 2860), (2991, 3040)],
    "gcc/target.def": [(2324, 2330), (3710, 3763)],
    "gcc/coretypes.h": [(362, 368)],
    "gcc/hooks.cc": [(152, 155), (293, 298), (584, 587)],
    "gcc/params.opt": [(248, 250)],
    "gcc/fold-const.cc": [(646, 669), (844, 853), (1087, 1225), (1325, 1342),
                           (1477, 1498), (1920, 2011), (2092, 2137), (2192, 2203),
                           (2484, 2504), (2626, 2666), (6994, 7007),
                           (9205, 9254), (10986, 11056), (13886, 14015),
                           (15842, 15938), (15945, 16110), (16378, 16435)],
    "gcc/genmatch.cc": [(3259, 3268), (3331, 3348), (3445, 3485)],
    "gcc/match.pd": [(1, 41)],
    "gcc/varasm.cc": [(870, 920), (2304, 2335), (2665, 2667), (3953, 3965),
                       (5627, 5635), (8518, 8527), (76, 85), (2069, 2086),
                       (2976, 2987), (3537, 3553), (3720, 3753), (3804, 3893),
                       (4001, 4038), (4150, 4168), (4184, 4253), (4476, 4523)],
    "gcc/function.h": [(34, 70), (162, 169)],
    "gcc/function.cc": [(203, 218), (5133, 5144)],
    "gcc/vec.h": [(220, 260), (302, 325), (393, 425), (599, 660),
                  (731, 740), (863, 868), (999, 1016), (1394, 1415)],
    "gcc/vec.cc": [(150, 169)],
    "gcc/expr.cc": [(1096, 1176), (1506, 1590), (2024, 2169),
                     (2237, 2329), (2540, 2579)],
    "gcc/expr.h": [(85, 105)],
    "gcc/targhooks.cc": [(2156, 2220)],
    "gcc/defaults.h": [(977, 995)],
    "gcc/config/i386/i386.h": [(1916, 1966)],
    "gcc/config/i386/i386.cc": [(4434, 4441), (11580, 11596), (18489, 18497),
                                 (28520, 28521), (28726, 28727)],
    "gcc/config/i386/i386-expand.cc": [(9135, 9294), (9510, 9586),
                                      (10010, 10715)],
    "gcc/config/i386/x86-tune-costs.h": [(4139, 4157), (4208, 4220)],
    "gcc/emit-rtl.cc": [(80, 85), (1184, 1232), (1239, 1262), (5980, 6005)],
    "gcc/rtl.h": [(4091, 4146)],
    "gcc/bb-reorder.cc": [(2616, 2641), (2665, 2672), (2977, 3011)],
    "gcc/config/i386/i386.md": [(500, 515), (25924, 25962)],
    "gcc/read-rtl-function.cc": [(1435, 1450)],
    "gcc/genmodes.cc": [(828, 845), (1012, 1023)],
    "gcc/config/elfos.h": [(114, 132)],
    "gcc/hash-table.h": [(295, 355), (599, 617), (656, 679), (755, 778),
                         (788, 821), (833, 895), (1026, 1093)],
    "gcc/hash-table.cc": [(44, 78), (87, 110)],
    "include/hashtab.h": [(32, 46), (94, 137)],
    "libiberty/hashtab.c": [(134, 195), (282, 324), (464, 510), (517, 575),
                            (633, 705), (780, 792)],
    "gcc/opts.cc": [(470, 560), (596, 605), (819, 825)],
    "gcc/common.opt": [(2080, 2094), (2411, 2420)],
    "gcc/config/i386/i386-options.cc": [(2275, 2286)],
    "gcc/common/config/i386/i386-common.cc": [(2033, 2059)],
    "libcpp/include/line-map.h": [(48, 55), (295, 324), (425, 471), (747, 805)],
    "libcpp/line-map.cc": [(63, 125), (175, 261), (437, 443), (469, 543),
                           (570, 608), (662, 680), (890, 999), (1009, 1077)],
}

# Complete selected target headers are retained for negative override checks;
# the source excerpts above carry the positive hook/layout sites.
for _header in (
    "vxworks-dummy.h", "i386/biarch64.h", "i386/unix.h", "i386/att.h",
    "gnu-user.h", "glibc-stdint.h", "i386/x86-64.h",
    "i386/gnu-user-common.h", "i386/gnu-user64.h", "linux.h",
    "linux-android.h", "i386/linux-common.h", "i386/linux64.h",
    "initfini-array.h",
):
    RANGES["gcc/config/" + _header] = []


def read_tar(archive, name):
    with tarfile.open(archive) as src:
        with src.extractfile(name) as member:
            return member.read()


def check_expression_copy_transfers(all_bytes):
    gimplify = all_bytes["gcc/gimplify.cc"].decode()
    start = gimplify.index("\nmostly_copy_tree_r (")
    callback = gimplify[start:gimplify.index("\n}\n", start)]
    assert "code == SAVE_EXPR || code == TARGET_EXPR || code == BIND_EXPR" in callback
    assert "TREE_CODE_CLASS (code) == tcc_constant" in callback
    assert "copy_tree_r (tp, walk_subtrees, NULL);" in callback
    assert "walk_tree (&expr, mostly_copy_tree_r, NULL, NULL);" in gimplify
    assert "walk_tree_1 (a, b, c, d, NULL)" in all_bytes["gcc/tree.h"].decode()
    copying = all_bytes["gcc/tree-inline.cc"].decode()
    assert "CONSTRUCTOR_ELTS (new_tree) = vec_safe_copy (CONSTRUCTOR_ELTS (*tp));" in copying
    vector = all_bytes["gcc/vec.h"].decode()
    assert "vec_alloc (new_vec, len PASS_MEM_STAT);" in vector
    assert "new_vec->embedded_init (len, len);" in vector
    tree = all_bytes["gcc/tree.cc"].decode()
    start = tree.index("\nsubstitute_placeholder_in_expr (")
    substitution = tree[start:tree.index("\n}\n", start)]
    primitive_counts = {
        name: len(re.findall(r"\b" + name + r"\s*\(", substitution))
        for name in ("tree_cons", "fold_build1", "fold_build2", "fold_build3",
                     "build4", "fold", "copy_node")}
    assert primitive_counts == dict(tree_cons=1, fold_build1=2, fold_build2=1,
                                   fold_build3=1, build4=1, fold=2, copy_node=1)
    assert "maybe_inline_call_in_expr" not in substitution

    def cost(t):
        kind, children = t
        if kind in ("constant", "declaration", "type", "save", "target", "bind"):
            return 0
        return (kind != "statement_list") + sum(map(cost, children))

    shared = ("declaration", ())
    rows = []
    for depth in range(1, 9):
        shared = ("expr", (shared, shared))
        assert cost(shared) == 2**depth-1
        assert cost(("expr", (("save", (shared,)), ("save", (shared,))))) == 1
        rows.append(dict(distinct_binary_nodes=depth, expanded_copy_nodes=cost(shared)))
    return dict(
        scope="ordinary unshare_expr occurrences; source-to-input and whole-body metadata roots separate",
        tree_copies_per_eligible_occurrence=1,
        String_payload_copies=0,
        constructor_element_bytes_lp64=16,
        nonempty_constructor_copy_initial_slots="max(4,k), then GC rounding",
        constructor_copy_new_scalar_or_type_nodes=0,
        occurrence_examples=rows,
        placeholder_substitution_primitive_sites=primitive_counts,
        no_placeholder_substitution_tree_or_fold_requests=0,
        native_execution=False,
    )


def check_size_extrema_transfers(all_bytes):
    utils = all_bytes["gcc/ada/gcc-interface/utils.cc"].decode()
    value_start = utils.index("\nmax_value (tree exp, bool max_p)")
    size_start = utils.index("\nmax_size (tree exp, bool max_p)")
    value = utils[value_start:utils.index("\n}\n", value_start)]
    size = utils[size_start:utils.index("\n}\n", size_start)]
    inlining = all_bytes["gcc/tree-inline.cc"].decode()
    inline_start = inlining.index("\nmaybe_inline_call_in_expr (tree exp)")
    inline = inlining[inline_start:inlining.index("\n}\n", inline_start)]
    assert "if (fn && TREE_READONLY (fn) && DECL_SAVED_TREE (fn))" in inline
    assert inline.index("if (fn &&") < inline.index("hash_map<tree, tree> decl_map;")
    primitive_sites = {}
    for name, body in (("max_value", value), ("max_size", size)):
        primitive_sites[name] = {
            primitive: len(re.findall(r"\b" + primitive + r"\s*\(", body))
            for primitive in ("fold_convert", "build_int_cst", "fold_build1",
                              "fold_build2", "build2", "size_binop", "build_call_array")}
    assert primitive_sites["max_value"] == dict(fold_convert=2, build_int_cst=1,
        fold_build1=0, fold_build2=3, build2=0, size_binop=0, build_call_array=0)
    assert primitive_sites["max_size"] == dict(fold_convert=4, build_int_cst=1,
        fold_build1=4, fold_build2=4, build2=1, size_binop=1, build_call_array=1)
    tree = all_bytes["gcc/tree.cc"].decode()
    assert "int length = (len - 1) * sizeof (tree) + sizeof (struct tree_exp);" in tree
    assert "t = build_vl_exp (CALL_EXPR, nargs + 3);" in tree
    assert "t->exp.operands[0] = build_int_cst (sizetype, len);" in tree
    maximum_arity = ((2**31-1)-48)//8
    assert maximum_arity == 268435449
    assert 48+8*maximum_arity <= 2**31-1 < 48+8*(maximum_arity+1)
    return dict(
        scope="scalar size expressions; no reached placeholder-reference or inlineable body",
        max_value_primitive_sites=primitive_sites["max_value"],
        max_size_primitive_sites=primitive_sites["max_size"],
        max_size_visit_bound="N+2B; original occurrence forest and binary count",
        max_size_requests=dict(build2="B", fold_build1="U+3B", size_binop="2B",
            fold_build2="X", endpoint_constants="Q", calls="C", call_length_constants="C"),
        call_constructor=dict(tree_exp_bytes=32, request_bytes="48+8a",
            maximum_arity_from_signed_byte_length=maximum_arity, scratch_bytes="8a"),
        symbolic_folder_internals_closed=False,
        native_execution=False)


def check_type_transfers(all_bytes, bundle):
    tree = all_bytes["gcc/tree.cc"].decode()
    layout = all_bytes["gcc/stor-layout.cc"].decode()
    core = all_bytes["gcc/tree-core.h"].decode()
    target = all_bytes["gcc/target.def"].decode()
    assert "unsigned next_type_uid = 1;" in tree
    assert tree.count("TYPE_UID (t) = next_type_uid++;") == 2
    assert "#define TYPE_HASH_INITIAL_SIZE 1000" in tree
    assert "nonstandard_integer_type_cache[2 * MAX_INT_CACHED_PREC + 2]" in tree
    assert "return sizeof (tree_type_non_common);" in tree
    assert "TYPE_SIZE (type) = round_up (TYPE_SIZE (type), TYPE_ALIGN (type));" in layout
    assert "TYPE_SIZE_UNIT (type) = size_int (GET_MODE_SIZE (mode));" in layout
    hook = target.split("(set_default_type_attributes,", 1)[1].split(
        "DEFHOOK", 1)[0]
    assert "hook_void_tree)" in hook
    assert re.search(r"hook_void_tree \(tree\)\s*\{\s*\}",
                     all_bytes["gcc/hooks.cc"].decode())
    config = json.loads((bundle / "configuration-inventory.json").read_text())
    headers = ["gcc/" + p for p in re.findall(
        r'# include "(config/[^\"]+)"', config["plugin_headers"]["tm_h"])]
    for name in [*headers, "gcc/config/i386/i386.cc"]:
        assert b"TARGET_SET_DEFAULT_TYPE_ATTRIBUTES" not in all_bytes[name]
        assert not re.search(rb"^\s*#\s*define\s+ROUND_TYPE_ALIGN\b",
                             all_bytes[name], re.M)
        assert not re.search(rb"^\s*#\s*define\s+TARGET_ARRAY_MODE(?:_SUPPORTED_P)?\b",
                             all_bytes[name], re.M)

    common = core.split("struct GTY(()) tree_type_common {", 1)[1].split(
        "struct GTY(()) tree_type_with_lang_specific", 1)[0]
    # Source-derived conservative bound: one four-byte unit per bitfield.
    bitfields = re.findall(r"\b(?:[a-z_0-9]+)\s*:\s*(?:[0-9]+|MACHINE_MODE_BITSIZE)\s*;",
                           common)
    assert len(bitfields) == 23
    assert b"typedef int alias_set_type;" in all_bytes["gcc/coretypes.h"]
    prefix = 24 + 3*8 + 4 + len(bitfields)*4 + 4
    prefix_aligned = (prefix+7)//8*8
    bound = prefix_aligned + 8*8 + 8 + 4*8
    assert bound == 256
    array_start = tree.index("\nbuild_array_type_1 (")
    array_body = tree[array_start:tree.index("\n}\n", array_start)]
    assert array_body.count("make_node (ARRAY_TYPE)") == 1
    assert array_body.count("build_array_type_1 (") == 2  # declaration and recursion
    assert "TYPE_CANONICAL (elt_type)" in array_body
    assert "TYPE_CANONICAL (index_type)" in array_body
    assert "false, false, true" in tree.split("\nbuild_nonshared_array_type (", 1)[1].split("\n}", 1)[0]
    # Closed constant-layout path: normalization, unit literal, four size
    # operations, two conversions, two rounds, and the empty-array hook.
    static_array_constants = 2 + 1 + 4 + 2 + 2 + 2
    assert static_array_constants == 13
    array_sizes = []
    for length in (0, 1, 2**30, 2**31-1):
        bits = 8*length
        assert bits < 2**64 and bits % 8 == 0
        array_sizes.append(dict(length=length, byte_size=length, bit_size=bits))
    return dict(
        selected_target_headers=len(headers),
        nonstandard_integer_cache_slots=2*64+2,
        canonical_pointer_or_reference_type_nodes_per_request=2,
        qualified_type_copies_per_request=2,
        simple_type_copies_per_request=1,
        scalar_layout_constant_requests=4,
        scalar_construction_with_fixup_constant_requests=6,
        unnamed_integer_pair_type_nodes_per_request=2,
        type_hash_record_bytes=16,
        type_hash_initial_request=1000,
        unsigned_type_uid_initial_value=1,
        sufficient_all_phase_type_allocations=2**32-2,
        type_bitfield_storage_units_bound=len(bitfields),
        type_node_bytes_conservative_lp64=bound,
        type_node_ggc_rounding_upper_bound=256,
        nonshared_array_type_nodes_per_request=2,
        completed_constant_character_array_layout_constant_requests=static_array_constants,
        constant_character_array_size_examples=array_sizes,
        dynamic_character_array_layout_interface=dict(
            direct_scalar_constants=6, size_binop_requests=6,
            fold_convert_requests=2, empty_hook_fold_build2_requests=1,
            multiple_of_p_requests=1, save_expr_requests=2,
            transitive_symbolic_allocations_included=False),
        scope="scalar/pointer/type-copy and ordinary Character-array transfers; symbolic folding, other aggregate layout and source request join separate",
    )


def check_cleanup_transfers(all_bytes):
    """Arithmetic on the report's manually established cleanup frontier.

    Counts are constructor calls, not final live instructions. Source checks
    corroborate the branch selection; they do not establish reachability.
    """
    passes = all_bytes["gcc/passes.def"].decode()
    assert passes.index("NEXT_PASS (pass_lower_cf)") < passes.index(
        "NEXT_PASS (pass_lower_eh)")
    assert re.search(r"#define\s+LANG_HOOKS_EH_PROTECT_CLEANUP_ACTIONS\s+NULL\b",
                     all_bytes["gcc/langhooks-def.h"].decode())
    assert "LANG_HOOKS_EH_PROTECT_CLEANUP_ACTIONS" not in all_bytes[
        "gcc/ada/gcc-interface/misc.cc"].decode()
    eh = all_bytes["gcc/tree-eh.cc"].decode()
    start = eh.index("\ndecide_copy_try_finally (")
    body = eh[start:eh.index("\n}\n", start)]
    gate = body[body.index("if (!optimize)"):body.index(
        "/* Finally estimate N times")]
    for expression in ("is_gimple_debug (stmt)", "gimple_clobber_p (stmt)",
                       "gimple_call_builtin_p (stmt, BUILT_IN_STACK_RESTORE)"):
        assert expression in gate
    low = all_bytes["gcc/gimple-low.cc"].decode()
    start = low.index("\nlower_gimple_return (")
    body = low[start:low.index("\n}\n", start)]
    assert body.count("gimple_build_goto (") == 1
    assert body.count("create_artificial_label (") == 1
    assert "gimple_build_return (" not in body
    gimplify = all_bytes["gcc/gimplify.cc"].decode()
    start = gimplify.index("\nmostly_copy_tree_r (")
    copier = gimplify[start:gimplify.index("\n}\n", start)]
    for token in ("tcc_type", "tcc_declaration", "tcc_constant",
                  "SAVE_EXPR", "TARGET_EXPR", "BIND_EXPR"):
        assert token in copier
    assert "walk_tree (&expr, mostly_copy_tree_r, NULL, NULL);" in gimplify
    assert "tree clobber = build_constructor (type, NULL);" in all_bytes[
        "gcc/tree.cc"].decode()
    assert "return src ? src->copy (ALONE_PASS_MEM_STAT) : NULL;" in all_bytes[
        "gcc/vec.h"].decode()
    assert "gimple_set_op (copy, i, unshare_expr (gimple_op (stmt, i)));" in all_bytes[
        "gcc/gimple.cc"].decode()

    # Each tuple names independently inspected source allocations. Enumerate
    # flags and Q/D pairs only to check the symbolic sums and stated maxima.
    copy_rows = {
        "fallthrough_branch_and_end_label": 2,
        "exception_landing_label_and_resx": 2,
        "queued_goto_continuation_and_redirection": 2,
        "distinct_destination_label": 1,
    }
    switch_rows = {
        "common_finally_label_and_switch": 2,
        "fallthrough_assignment_case_branch_end_label": 4,
        "exception_landing_assignment_branch_case_resx": 5,
        "queued_goto_assignment_continuation_redirection": 3,
        "distinct_destination_label": 1,
    }
    cases = []
    for q, d in ((0, 0), (1, 1), (2, 1), (2, 2), (7, 1), (7, 7)):
        for f in (0, 1):
            for e in (0, 1):
                copy_controls = 2*f+2*e+2*q+d
                switch_controls = 2+4*f+5*e+3*q+d
                assert copy_controls <= 2*q+d+4
                assert switch_controls <= 11+3*q+d
                assert d+f+e <= d+2
                assert 1+2*f+2*e+d <= 5+d
                assert 2*f+2*e+q+d <= 4+q+d
                cases.append(dict(queued_gotos=q, destinations=d,
                                  fallthrough=f, exception=e,
                                  cleanup_copies=d+f+e,
                                  copy_control_statements=copy_controls,
                                  switch_control_statements=switch_controls))
    main_cases = [c for c in cases if c["queued_gotos"] <= 1]
    assert max(c["cleanup_copies"] for c in main_cases) == 3
    assert max(c["copy_control_statements"] for c in main_cases) == 7
    assert max(c["switch_control_statements"] for c in main_cases) == 15
    return {
        "scope": "O0 cleanup GIMPLE and selected simple operand copies; helper/container closure and later passes separate",
        "cf_precedes_eh": True,
        "implicit_return_cf_new_gimple": 2,
        "implicit_return_cf_new_label_declarations": 1,
        "simple_cleanup_copy_control_rows": copy_rows,
        "switch_cleanup_control_rows": switch_rows,
        "copy_bounds": {"cloned_statements": "(D+2)*C",
                        "ordinary_operand_tree_nodes": "(D+2)*C",
                        "operand_tree_slots": "(D+2)*C",
                        "other_statements": "2*Q+D+4",
                        "artificial_labels": "D+2"},
        "switch_bounds": {"new_statements": "11+3*Q+D",
                          "temporary_requests": 1,
                          "artificial_labels": "5+D",
                          "case_labels_and_entries": "2+D",
                          "integer_constant_requests": "4+Q+D",
                          "continuation_map_entries": "D"},
        "Main_Q_D_at_most_one": {
            "copy_statements": "3*C+7", "copy_labels": 3,
            "inner_copy_statements": "2*C+4", "inner_copy_labels": 2,
            "switch_statements": 15, "switch_temporaries": 1,
            "switch_labels": 6, "switch_cases": 3,
            "switch_integer_requests": 6, "goto_queue_capacity": 32},
        "simple_operand_copy": {
            "selected_shapes": ["VAR_DECL := CONSTRUCTOR(empty)",
                                "stack_restore(pointer_VAR_DECL)"],
            "ordinary_tree_nodes_per_copy": 1,
            "ordinary_tree_operand_slots_per_copy": 1,
            "String_payload_bytes": 0, "types": 0, "declarations": 0,
            "constructor_elements": 0,
            "maximum_cleanup_tuple_operands": 4,
            "excludes": "full-body unsharing, debug-value expressions, remapping/traversal container costs"},
        "enumerated_arithmetic_cases": cases,
        "source_frontier_requires_manual_argument": True,
    }


def check_initial_cfg(all_bytes):
    source = all_bytes["gcc/tree-cfg.cc"].decode()
    assert "static const int initial_cfg_capacity = 20;" in source
    start = source.index("\ncall_can_make_abnormal_goto (")
    body = source[start:source.index("\n}\n", start)]
    assert re.search(r"if \(!cfun->has_nonlocal_label\s*&& !cfun->calls_setjmp\)"
                     r"\s*return false;", body)
    rows = []
    # Direct per-terminal edge requests. Ordinary selected switches come only
    # from cleanup lowering, with at most three destinations.
    terminal_requests = dict(cond=2, call=2, throwing_assign=2, ordinary=1,
                             direct_goto=1, resx=1, return_stmt=1, switch=3)
    assert max(terminal_requests.values()) == 3
    for s in (0, 1, 20, 100, 1000000):
        b = max(1, s)
        for switches in (0, min(1, s), s):
            k = 3*switches
            edges = min(1+2*b+k, 1+3*b)
            assert edges <= 1+3*b
            rows.append(dict(statements=s, switch_labels=k, blocks=b+2,
                             edges=edges, pointer_vector_demand=max(20,b+2,s,edges),
                             discriminator_requests=s+edges,
                             discriminator_block_ids=s+2*b+edges))
    return dict(scope="build_gimple_cfg before CFG cleanup and loop discovery",
                blocks="max(1,S)+2", edge_requests="min(1+2*max(1,S)+K,1+3*max(1,S))",
                label_map_entries="S", vector_initial_demand=20,
                pointer_vector_demand_bound=1431655765,
                discriminator_requests="S+E_graph",
                discriminator_block_ids="S+2*max(1,S)+E_graph",
                new_adhoc_location_requests="S+E_graph",
                terminal_edge_requests=terminal_requests, cases=rows,
                excludes="CFG cleanup/loop discovery, ad-hoc-location allocator, SSA, RTL")


def check_integer_constant_transfers(all_bytes):
    source = all_bytes["gcc/tree.cc"].decode()
    assert "return cst.get_precision () / HOST_BITS_PER_WIDE_INT + 1;" in source
    assert "int_cst_node = make_int_cst (1, 1);" in source
    assert "TYPE_CACHED_VALUES (type) = make_tree_vec (max_slots);" in source
    assert "limit = param_integer_share_limit + 1;" in source
    assert "Init(251) IntegerRange(2, 65536)" in all_bytes["gcc/params.opt"].decode()
    folder = all_bytes["gcc/fold-const.cc"].decode()
    for arity, function in ((1, "unary"), (2, "binary"), (3, "ternary")):
        start = folder.index(f"\nfold_build{arity}_loc (")
        body = folder[start:folder.index("\n}\n", start)]
        assert body.index(f"fold_{function}_loc (") < body.index(
            f"tem = build{arity}_loc (")
    generator = all_bytes["gcc/genmatch.cc"].decode()
    assert '"_r%d = fold_build%d_loc (loc, %s, %s"' in generator
    rows = []
    for precision in (1, 8, 16, 32, 64, 128):
        limbs = precision//64+1
        requested = 16+8*limbs
        assert limbs <= 3 < 2**16
        assert requested <= 40 < 2**31
        rows.append(dict(precision_bound=precision, extended_limbs=limbs,
                         requested_bytes_lp64=requested))
    return dict(scalar_constant_nodes_per_request=1,
                initial_spare_constant_nodes=1,
                per_type_cache_vector_slots=252,
                per_type_cache_vector_bytes_lp64=24+8*252,
                cache_vector_count="min(R,T)",
                selected_constant_only_fold_requests=2,
                precision_cases=rows,
                scope="ordinary integer constants and enumerated successful scalar constant folds",
                excludes="symbolic/complex/view-conversion folding, arithmetic scratch, generic types and complete request counts")


def check_block_transfers(all_bytes, bundle):
    source = all_bytes["gcc/config/i386/i386-expand.cc"].decode()
    primitives = ("gen_reg_rtx", "emit_move_insn", "gen_label_rtx", "emit_label",
                  "emit_cmp_and_jump_insns", "emit_jump_insn", "emit_barrier",
                  "expand_simple_binop", "change_address", "offset_address",
                  "ix86_copy_addr_to_reg")
    expected = {
        "ix86_expand_movmem": (3, 11, 8, 8, 8, 6, 6, 8, 4, 2, 2),
        "ix86_expand_less_move_movmem": (1, 2, 6, 6, 6, 11, 11, 0, 2, 0, 0),
    }
    bodies, direct = {}, {}
    for name, counts in expected.items():
        start = re.search(r"\n" + name + r"\s*\(", source).start()
        end = source.index("\n}\n", start)
        bodies[name] = source[start:end]
        observed = tuple(len(re.findall(r"\b" + p + r"\s*\(", bodies[name]))
                         for p in primitives)
        assert observed == counts
        direct[name] = dict(zip(primitives, counts))
    # The report derives bounded loop multiplicities in these helpers.
    # Rows are (fresh explicit pseudos, move requests, address changes, offsets,
    #           adjust_address requests). Callee expansions remain separate.
    helpers = {
        "unroll_at_most_8_plus_tail": (9, 18, 2, 20, 2),
        "three_outer_overlap_helpers_moves_2_8_4": (14, 28, 6, 28, 0),
        "five_small_overlap_helpers_moves_2": (10, 20, 10, 20, 0),
        "two_load_helpers_moves_4": (8, 8, 2, 8, 0),
        "two_store_helpers_moves_4": (0, 8, 2, 8, 0),
        "two_move_helpers_moves_4": (8, 16, 0, 12, 0),
    }
    aggregate = {p: sum(row[p] for row in direct.values()) for p in primitives}
    aggregate["adjust_address"] = 0
    helper_fields = ("gen_reg_rtx", "emit_move_insn", "change_address",
                     "offset_address", "adjust_address")
    for row in helpers.values():
        for p, value in zip(helper_fields, row):
            aggregate[p] += value
    assert tuple(aggregate[p] for p in helper_fields) == (53, 111, 28, 98, 2)
    for name in ("ix86_expand_movmem", "ix86_expand_set_or_cpymem"):
        start = re.search(r"\n" + name + r"\s*\(", source).start()
        end = source.index("\n}\n", start)
        body = source[start:end]
        guard = "if (count > (HOST_WIDE_INT_1U << 30))\n    return false;"
        assert body.index(guard) < body.index("decide_alg (")
        assert body.index(guard) < body.index("ix86_copy_addr_to_reg (")
    query = json.loads((bundle / "target-options-query.json").read_text())
    for pattern in (r"-mtune=\s+generic", r"-march=\s+x86-64",
                    r"-minline-all-stringops\s+\[disabled\]",
                    r"-minline-stringops-dynamically\s+\[disabled\]"):
        assert re.search(pattern, query["stdout"])
    return {
        "scope": "local primitive requests, not transitive RTL or machine instructions",
        "ordinary_piecewise_move_ratio_upper_bound": 17,
        "ordinary_piecewise_estimated_pieces_maximum": 16,
        "universal_x86_piece_bytes_upper_bound": 64,
        "ordinary_piecewise_input_bytes_upper_bound": 16*64,
        "constant_pattern_early_return_above": 2**30,
        "large_constant_normal_copy_libcall_requests": 1,
        "libcall_arguments": 3,
        "pattern_mode_attempts_upper_bound": 2,
        "direct_lexical_primitive_inventory": direct,
        "manually_derived_helper_bounds": dict(zip(helpers, (
            dict(zip(helper_fields, row)) for row in helpers.values()))),
        "movmem_transitive_over_named_helpers_only": aggregate,
    }


def check_configuration_inventory(bundle, gcc_root, plugin):
    record = json.loads((bundle / "configuration-inventory.json").read_text())
    if gcc_root:
        seen = []
        found = {k: [] for k in record["results"]}
        patterns = {
            "assemble_static_space": r"\bassemble_static_space\s*\(",
            "partition_writers": r"\bhas_bb_partition\s*=",
            "register_writers": r"\breg_rtx_no\s*(?:\+\+|--|[-+*/]?=)",
        }
        for path in sorted((gcc_root / "gcc").rglob("*")):
            if path.suffix not in (".cc", ".c", ".h") or "testsuite" in path.parts:
                continue
            data = path.read_bytes()
            name = str(path.relative_to(gcc_root))
            seen.append((name, hashlib.sha256(data).hexdigest()))
            source = data.decode(errors="replace")
            for kind, pattern in patterns.items():
                for match in re.finditer(pattern, source):
                    found[kind].append(dict(path=name, line=source.count(
                        "\n", 0, match.start())+1, text=match.group()))
        assert len(seen) == record["source_file_count"]
        assert hashlib.sha256(json.dumps(seen, separators=(",", ":")).encode()
                              ).hexdigest() == record["source_file_list_sha256"]
        assert found == record["results"]
    if plugin:
        headers, hits = [], []
        for path in sorted(plugin.rglob("*.h")):
            data = path.read_bytes()
            name = str(path.relative_to(plugin))
            headers.append((name, hashlib.sha256(data).hexdigest()))
            if b"PCC_STATIC_STRUCT_RETURN" in data:
                hits.append(name)
        expected = record["plugin_headers"]
        assert len(headers) == expected["files"]
        assert hashlib.sha256(json.dumps(headers, separators=(",", ":")).encode()
                              ).hexdigest() == expected["list_sha256"]
        assert hits == expected["pcc_static_struct_return_hits"] == []
        assert (plugin / "tm.h").read_text() == expected["tm_h"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ada", required=True, type=Path,
                        help="Pinned gcc/ada directory")
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--gcc-root", type=Path,
                        help="Optional complete pinned GCC source for caller inventory")
    parser.add_argument("--plugin-include", type=Path,
                        help="Optional selected compiler headers for configuration inventory")
    args = parser.parse_args()
    bundle = Path(__file__).resolve().parent
    check_configuration_inventory(bundle, args.gcc_root, args.plugin_include)
    evidence = bundle.parent
    manifest = json.loads((bundle / "source-manifest.json").read_text())
    assert manifest["commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
    prior = evidence / "unbounded-programs/frontend-deferred-20261017"
    prior_files = {row["path"]: row for row in json.loads(
        (prior / "gcc-emission-source-manifest.json").read_text())["files"]}
    ada_record = evidence / ("unbounded-programs/continuation-20261017/"
                             "frontend-lifetimes/complete-source-manifest.json")
    ada_files = {"gcc/ada/" + row["path"]: row for row in
                 json.loads(ada_record.read_text())["files"]}
    excerpts = ["# Pinned native backend source excerpts\n",
                "LF line numbering; complete file identities checked.\n"]
    verified = []
    all_bytes = {}
    for row in manifest["files"]:
        name = row["path"]
        if name.startswith("gcc/ada/"):
            data = (args.ada / name.removeprefix("gcc/ada/")).read_bytes()
            assert hashlib.sha256(data).hexdigest() == ada_files[name]["sha256"]
        elif name in prior_files:
            data = read_tar(prior / "gcc-emission-sources.tar.gz",
                            prior_files[name]["file"])
            assert hashlib.sha256(data).hexdigest() == prior_files[name]["sha256"]
        else:
            data = read_tar(bundle / row.get("archive", "new-sources.tar.gz"), name)
        assert len(data) == row["bytes"], name
        assert hashlib.sha256(data).hexdigest() == row["sha256"], name
        blob = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data)
        assert blob.hexdigest() == row["git_blob_sha1"], name
        all_bytes[name] = data
        verified.append({"path": name, "sha256": row["sha256"]})
        lines = data.decode().split("\n")
        for first, last in RANGES[name]:
            excerpts.extend([f"\n## {name}:{first}–{last}\n", "```text\n"])
            excerpts.extend(f"{i}: {lines[i-1]}".rstrip() + "\n"
                            for i in range(first, last + 1))
            excerpts.append("```\n")

    # Negative source searches corroborate the inspected override scope.
    assert b"flag_merge_constants" not in all_bytes["gcc/ada/gcc-interface/misc.cc"]
    assert b"OPT_fmerge_constants" not in all_bytes[
        "gcc/common/config/i386/i386-common.cc"]

    line_bits, column_bits = 32, 8
    maximum_lines = 1 << (line_bits - column_bits)
    assert maximum_lines - 1 < 1 << (line_bits - column_bits)
    assert not maximum_lines < 1 << (line_bits - column_bits)
    location_charge = 256 * (maximum_lines - 1) + 252
    int_max = (1 << 31) - 1
    map_cases = []
    for demand in sorted({0, 1, 255, 256, 257, int_max} |
                         {2**k+delta for k in range(9,31) for delta in (-1,0,1)}):
        capacity = 0 if demand == 0 else max(256,1 << (demand-1).bit_length())
        assert demand <= capacity <= 2**31
        assert capacity*32 <= 2**36
        if capacity:
            assert capacity*32 == 1 << (capacity.bit_length()-1+5)
        map_cases.append(dict(demand=demand, capacity=capacity, bytes=32*capacity))
    header_offset = 20
    constructor_bytes = int_max + header_offset + 1
    assert constructor_bytes <= (1 << 32) - 1

    # The constant-label counter is file-local: inventory every increment and
    # reset in its complete source, not just a selected emitter excerpt.
    varasm = all_bytes["gcc/varasm.cc"].decode().split("\n")
    label_increments = [i for i, line in enumerate(varasm, 1)
                        if re.search(r"const_labelno\s*\+\+|\+\+\s*const_labelno", line)]
    label_resets = [i for i, line in enumerate(varasm, 1)
                    if re.search(r"\bconst_labelno\s*=\s*0", line)]
    assert label_increments == [2085, 2984, 3733, 4252]
    assert label_resets == [9077]
    deferred_updates = [i for i, line in enumerate(varasm, 1)
                        if re.search(r"n_deferred_constants\s*(?:\+\+|--)", line)]
    assert deferred_updates == [3888, 4519]

    prime_source = all_bytes["gcc/hash-table.cc"].decode()
    prime_text = prime_source.split("prime_tab[] = {", 1)[1].split("};", 1)[0]
    primes = [int(x, 0) for x in re.findall(r"\{\s*(0x[0-9a-f]+|[0-9]+),", prime_text)]
    assert len(primes) == 30 and primes[-2:] == [int_max, 2**32-5]
    c_hash_source = all_bytes["libiberty/hashtab.c"].decode()
    c_prime_text = c_hash_source.split("prime_tab[] = {", 1)[1].split("};", 1)[0]
    c_primes = [int(x, 0) for x in re.findall(
        r"\{\s*(0x[0-9a-f]+|[0-9]+),", c_prime_text)]
    assert c_primes == primes
    assert "size_t nsize, osize, elts;" in c_hash_source
    assert "size * 3 <= htab->n_elements * 4" in c_hash_source
    line_map = all_bytes["libcpp/line-map.cc"].decode()
    assert "m_location_adhoc_data_map.allocated = 128;" in line_map
    assert "m_location_adhoc_data_map.allocated *= 2;" in line_map
    live_limit = int_max // 2
    adhoc_cases = []
    for demand in (0, 1, 127, 128, 129, 255, 256, 257, live_limit):
        capacity = 0 if demand == 0 else 1 << (max(128,demand)-1).bit_length()
        requested_bytes = 40*capacity
        rounded_bytes = (0 if capacity == 0 else
                         1 << (requested_bytes-1).bit_length())
        assert demand <= capacity <= 2**30
        assert requested_bytes <= 40*2**30
        assert rounded_bytes <= 2**36
        assert capacity*40 <= 2**63-1
        adhoc_cases.append(dict(entries=demand, requested_capacity=capacity,
                                requested_bytes=requested_bytes,
                                rounded_bytes_upper_bound=rounded_bytes))
    hash_cases = []
    for demand in sorted({0, 1, 23, 24, 765, 766, live_limit} |
                         {p//2+delta for p in primes[:-1] for delta in (0,1)
                          if 0 <= p//2+delta <= live_limit}):
        request = max(1009, 2*demand)
        capacity = next(p for p in primes if p >= request)
        assert capacity <= int_max
        assert 2*capacity-3 <= 2**32-1  # index + secondary step
        assert 8*capacity <= 8*int_max < 2**34
        hash_cases.append(dict(live=demand, request=request, capacity=capacity))
    # Search the exact selected macro lengths; the shortest caller array is LF.
    label_lengths = {prefix: 2+len(prefix)+len(str(int_max-1))+1
                     for prefix in ("LF", "LC", "LHOTB", "LCOLDB", "LHOTE", "LCOLDE")}
    assert label_lengths["LF"] <= 17
    assert max(label_lengths.values()) <= 100

    # Heap capacity remains valid even when its unsigned growth heuristic wraps.
    heap_cases = []
    for old in (0, 4, 8, 15, 16, int_max//2, (2**32-1)//3,
                (2**32-1)//3+1, int_max-1):
        desired = old+1
        raw = 4 if not old else (old*2 if old < 16 else
                                ((old*3) & (2**32-1))//2)
        capacity = max(raw, desired)
        assert desired <= capacity <= int_max
        heap_cases.append(dict(old=old, desired=desired, capacity=capacity))
    gc_vectors = []
    for element_size in (1, 2, 4, 8, 16, 24, 32, 40, 64, 128):
        bound_bytes = 8+element_size*int_max
        rounding_ceiling = 1 << (bound_bytes.bit_length()-1)
        capacity = (rounding_ceiling-8)//element_size
        demand = 2*capacity//3+1
        assert demand <= capacity <= int_max
        assert 3*(demand-1)//2 <= capacity
        assert 8+element_size*capacity <= rounding_ceiling <= 2**63
        assert (rounding_ceiling-8)//element_size <= int_max
        gc_vectors.append(dict(element_bytes=element_size,
                               rounding_ceiling_bytes=rounding_ceiling,
                               recovered_capacity_bound=capacity,
                               sufficient_requested_total=demand))
    request = 8+4*int_max
    rounded = 1 << (request-1).bit_length()
    recovered = (rounded-8)//4
    assert request == 2**33+4 and rounded == 2**34
    assert recovered == 2**32-2 and (recovered & int_max) < int_max
    reg_capacities = [198]
    while 2*reg_capacities[-1] <= int_max:
        reg_capacities.append(2*reg_capacities[-1])
    assert reg_capacities[-1] == 1660944384
    assert reg_capacities[-1]-98 == 1660944286
    # The alignment mask is unsigned int before conversion to HOST_WIDE_INT.
    # genmodes emits BITS_PER_UNIT as a plain decimal int literal.
    mode_generator = all_bytes["gcc/genmodes.cc"].decode()
    assert '#define BITS_PER_UNIT (%d)' in mode_generator
    varasm_text = all_bytes["gcc/varasm.cc"].decode()
    assert varasm_text.count("pool->offset &= ~ ((align / BITS_PER_UNIT) - 1);") == 2
    uint_max = 2**32-1
    byte_alignment = 8
    before = 2**32
    unsigned_mask = (~(byte_alignment-1)) & uint_max
    narrowed = (before+byte_alignment-1) & unsigned_mask
    mathematical = (before+byte_alignment-1) & ~(byte_alignment-1)
    assert narrowed == 0 and mathematical == 2**32
    assert before+byte_alignment-1+8 <= 2**63-1
    # Below the 32-bit mask ceiling, zero-extension changes no significant bit.
    mask_cases = []
    for alignment in (1, 2, 4, 8, 16, 32, 64):
        mask = (~(alignment-1)) & uint_max
        for unaligned in sorted({0, alignment-1, alignment, uint_max-1, uint_max}):
            actual = unaligned & mask
            expected = unaligned & ~(alignment-1)
            assert actual == expected and 0 <= actual <= unaligned
            mask_cases.append({"alignment_bytes": alignment,
                               "pre_mask_offset": unaligned, "aligned_offset": actual})
    results = {
        "scope": "local source-derived arithmetic; no native compiler/prover run",
        "verified_sources": verified,
        "block_operations": check_block_transfers(all_bytes, bundle),
        "cleanup_lowering": check_cleanup_transfers(all_bytes),
        "initial_cfg": check_initial_cfg(all_bytes),
        "integer_constants": check_integer_constant_transfers(all_bytes),
        "scalar_pointer_types": check_type_transfers(all_bytes, bundle),
        "expression_unsharing": check_expression_copy_transfers(all_bytes),
        "size_extrema_helpers": check_size_extrema_transfers(all_bytes),
        "ordinary_vectors": {
            "heap_maximum_requested_total": int_max,
            "heap_modular_growth_examples": heap_cases,
            "gc_header_bytes": 8,
            "gc_sufficient_regions": gc_vectors,
            "gc_counterexample": dict(element_bytes=4, requested_total=int_max,
                                      requested_bytes=request, rounded_bytes=rounded,
                                      recovered_capacity=recovered,
                                      stored_capacity=recovered & int_max),
            "scope": "ordinary reserve preconditions; element alignment at most eight bytes",
        },
        "pseudo_register_backbones": {
            "initial_next_number": 98, "capacity_sequence": reg_capacities,
            "maximum_fresh_register_events": reg_capacities[-1]-98,
            "maximum_byte_array_request": reg_capacities[-1],
            "maximum_pointer_array_request": 8*reg_capacities[-1],
            "scope": "ordinary non-RTL-reader Ada path; source-to-event bound separate",
        },
        "line_map": {
            "location_bits": 64, "line_bits": line_bits,
            "column_bits": column_bits, "range_bits": 0,
            "maximum_lines_without_extra_map": maximum_lines,
            "first_line_count_requiring_extra_map": maximum_lines + 1,
            "preallocation_charge_at_maximum": location_charge,
            "later_column_headroom": 4,
            "normal_region_exclusive_limit": 0x50000000 << 31,
            "ordinary_map_bytes_lp64": 32,
            "growth_transitions": map_cases,
            "maximum_map_vector_bytes_from_nat_file_count": 2**36,
        },
        "adhoc_location_map": {
            "sufficient_fresh_entry_bound": live_limit,
            "initial_backing_capacity": 128,
            "entry_bytes_lp64_premise": 40,
            "maximum_backing_capacity": 2**30,
            "maximum_requested_bytes": 40*2**30,
            "maximum_rounded_bytes": 2**36,
            "C_hash_prime_table_matches_CPP_table": True,
            "C_hash_initial_request": 100,
            "C_hash_initial_capacity": 127,
            "C_hash_maximum_capacity": int_max,
            "C_hash_maximum_requested_bytes": 8*int_max,
            "growth_cases": adhoc_cases,
            "scope": "local sufficient region; source and all-phase request total still required",
            "loss": "generic twice-live growth envelope, without insertion-only schedule refinement",
        },
        "gnat_node_associations": {
            "array_count": 2,
            "maximum_count_from_int_interface": int_max,
            "maximum_requested_bytes_per_array": 8*int_max,
            "maximum_rounded_bytes_per_array": 2**34,
            "scope": "backbone arithmetic; pointed-to GCC trees are separate",
        },
        "constant_pools": {
            "label_increment_lines": label_increments,
            "label_reset_lines": label_resets,
            "maximum_total_label_events": int_max,
            "selected_O0_exclusions": {"C_space": 0, "C_part": 0},
            "label_buffers_including_nul": label_lengths,
            "deferred_update_lines": deferred_updates,
            "deferred_counter_bits": 32,
            "maximum_deferred_increments_per_function": 2**32-1,
            "decrement_bound_required_separately": True,
            "hash_prime_table": primes,
            "maximum_live_hash_entries_for_bounded_probe_arithmetic": live_limit,
            "maximum_hash_capacity": int_max,
            "maximum_pointer_backbone_bytes": 8*int_max,
            "hash_capacity_cases": hash_cases,
            "RTL_pool_offsets": {
                "offset_bits": 64, "offset_signed": True,
                "align_and_mask_bits": 32, "mask_unsigned": True,
                "sufficient_per_pool_charge": "sum(a_i-1+s_i) <= 2^32-1",
                "maximum_charge": uint_max,
                "witness_above_mask_width": {
                    "incoming_offset": before, "alignment_bytes": byte_alignment,
                    "unsigned_mask": unsigned_mask,
                    "actual_aligned_offset": narrowed,
                    "mathematical_aligned_offset": mathematical,
                    "fits_old_signed64_sum_bound": True,
                },
                "mask_boundary_cases": mask_cases,
                "scope": "local arithmetic; actual source-to-descriptor/mode counts remain open",
            },
            "scope": "local event-to-representation transfers; source event counts remain required",
        },
        "string": {
            "lp64_header_offset_premise": header_offset,
            "maximum_signed_length": int_max,
            "constructor_request_at_endpoint": constructor_bytes,
            "coexisting_temporary_plus_node_at_endpoint": int_max + constructor_bytes,
            "largest_stack_temporary": 999,
            "maximum_chunk_callbacks_at_endpoint": (int_max + 1999) // 2000,
            "normal_chunk_size": 2000, "base64_chunk_size": 16384,
            "emission_extra_nul_under_o0_no_override": False,
            "ordinary_Main_gigi_lowering": {
                "maximum_visits_per_expanded_literal_identity": 2,
                "events": "2*N_lit <= 2*A_Main",
                "payload_bytes": "2*W_lit <= 2*A_Main*L_max",
                "constructor_bytes": "2*W_lit+42*N_lit",
                "premises": "current normalized Main grammar; cached entity/lazy initialization; scalar literal subtype bounds; selected no-inlining native invocation",
                "excluded": "later GCC copies and constant-pool requests; named objects; diagnostic/filename/fixed dependency Strings",
            },
        },
    }
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "checks.json").write_text(json.dumps(results, indent=2) + "\n")
    (args.output / "source-excerpts.md").write_text("".join(excerpts))
    print(f"Verified {len(verified)} source files and local arithmetic")


if __name__ == "__main__":
    main()
