#!/usr/bin/env python3
"""Retain source excerpts and inspect existing JSON; never invokes the toolchain."""

import argparse
import hashlib
import json
import tarfile
from pathlib import Path


ROOT = Path(__file__).resolve().parent
SOURCE_REVISION = "42554fc241fcd1fdf08d3a2feccb3f86912acbc0"
RANGES = {
    "src/why/why-types.ads": [[30, 60]],
    "src/why/xgen/why-atree.ads-tmpl": [[95, 130]],
    "src/why/why-atree.adb": [[60, 95]],
    "src/why/xgen/xtree_builders.adb": [[200, 255]],
    "src/why/xgen/xtree_why_ast.adb": [[160, 245]],
    "src/why/xgen/why-atree-to_json.adb-tmpl": [[100, 160]],
    "src/why/xgen/xtree_sinfo.adb": [[30, 145], [170, 245], [254, 368], [371, 440], [470, 486], [528, 558], [580, 635], [682, 738]],
    "src/why/gnat2why-driver.adb": [[274, 310], [507, 610], [1195, 1225], [1318, 1355], [1415, 1457], [1462, 1590]],
    "src/why/gnat2why-util.adb": [[503, 540], [1126, 1201], [1347, 1454], [1609, 1615], [1875, 1909]],
    "src/why/gnat2why-util.ads": [[570, 582]],
    "src/why/why-inter.adb": [[354, 379], [387, 437], [550, 746], [756, 799], [836, 872], [943, 1017], [1149, 1242], [1260, 1285], [1547, 1632]],
    "src/why/why-atree-modules.adb": [[297, 324], [465, 504], [703, 781], [870, 893], [918, 1047], [1132, 1150], [2699, 2747], [2765, 2775], [3297, 3323], [3693, 3722], [3962, 4006]],
    "src/why/why-atree-modules.ads": [[819, 857]],
    "src/why/why-gen-names.adb": [[68, 160], [162, 392], [560, 570], [734, 910], [911, 921], [1136, 1246]],
    "src/why/why-gen-expr.adb": [[147, 157], [311, 381], [982, 1512], [1518, 1648], [1956, 1996], [2349, 2391], [2399, 2910], [2916, 3050], [3219, 3277], [3405, 3997], [4289, 4385], [4488, 4535], [4816, 4837], [4883, 4956], [4962, 5010], [5282, 5323], [5436, 5541]],
    "src/why/why-gen-expr.ads": [[65, 78], [96, 105], [305, 311]],
    "src/why/why-gen-binders.adb": [[192, 211], [268, 280], [448, 481], [745, 786], [888, 947], [1082, 1150], [1222, 1338], [1346, 1415], [1457, 1524], [1626, 1640]],
    "src/why/why-gen-arrays.adb": [[223, 448], [473, 580], [614, 630], [981, 1068], [1075, 1161], [1529, 1623], [1772, 2222], [2813, 2892], [2990, 3036], [3042, 3104], [3261, 3281], [3305, 3363], [3396, 3599], [3835, 3969]],
    "src/why/gnat2why-expr.adb": [[1384, 1460], [1621, 1831], [2329, 2360], [2669, 2805], [6396, 6824], [7080, 7230], [7503, 7600], [8782, 8999], [11736, 11778], [11961, 12034], [2864, 2894], [12039, 12056], [12286, 12368], [12402, 12440], [14857, 14920], [18547, 18735], [19042, 19146], [19238, 19345], [19903, 20101], [20256, 20300], [21817, 21972], [21976, 22351], [22591, 22638], [23187, 23215], [23600, 23647], [23688, 23712], [24012, 24205], [24547, 24570], [24630, 24731], [25500, 25573], [25635, 25724], [26847, 27088], [29520, 29561], [29733, 29862], [30221, 30666], [30936, 31120], [31162, 31211]],
    "src/why/gnat2why-expr-loops.adb": [[500, 575], [787, 816], [1292, 1343], [1398, 1415], [1458, 1505], [1800, 1825], [1882, 1978], [2080, 2115], [2194, 2334]],
    "src/why/gnat2why-expr-loops-inv.adb": [[175, 198], [775, 815], [1079, 1398], [1704, 1745], [1940, 1976], [2291, 2350], [2398, 2408]],
    "src/why/why-gen-progs.adb": [[38, 58], [168, 180], [199, 215], [243, 257], [275, 280], [329, 364]],
    "src/why/why-gen-records.adb": [[5048, 5125]],
    "src/why/why-gen-decl.adb": [[90, 295]],
    "src/why/why-gen-scalars.adb": [[410, 927], [1117, 1470], [1546, 1575]],
    "src/why/why-gen-init.adb": [[502, 554]],
    "src/why/gnat2why-decls.adb": [[66, 382], [451, 490], [496, 812]],
    "src/why/gnat2why-types.adb": [[201, 575], [895, 1101], [1108, 1155], [1416, 1423], [1538, 1739]],
    "src/why/gnat2why-subprograms.adb": [[4455, 4483], [5840, 5872], [6220, 6260]],
    "src/spark/spark_definition.ads": [[215, 232]],
    "src/spark/spark_definition.adb": [[248, 263], [11836, 11895], [12186, 12248], [14999, 15035]],
    "src/spark/spark_util-types.adb": [[1521, 1620], [3050, 3064]],
    "src/spark/spark_util-types.ads": [[128, 146]],
    "src/flow/flow_utility.adb": [[966, 1000], [2035, 2062], [2519, 2681], [6352, 6359]],
    "src/flow/flow_generated_globals-phase_2.adb": [[4793, 4875]],
}

# Additional helper paths for ordinary Main type translation/completion.
RANGES["src/why/why-gen-arrays.adb"].append([2526, 2810])
RANGES["src/why/why-gen-expr.adb"].extend([[280, 305], [4337, 4418]])
RANGES["src/why/gnat2why-expr.adb"].extend([[5465, 5592], [5726, 6011], [6820, 7085]])
RANGES["src/why/gnat2why-expr.adb"].extend([[946, 954], [2707, 2894]])
RANGES["src/why/gnat2why-expr-loops.adb"].extend([[619, 651], [690, 787], [970, 1050], [1292, 1416], [1763, 1989]])
RANGES["src/why/gnat2why-expr-loops-inv.adb"].append([327, 343])
RANGES["src/why/gnat2why-expr-loops-inv.adb"].extend([[1404, 1460], [1641, 1689]])
RANGES["src/why/why-gen-expr.adb"].append([3485, 3572])
RANGES["src/why/why-gen-progs.adb"].extend([[52, 102], [126, 150], [329, 370]])
RANGES["src/why/xgen/xtree_sinfo.adb"].extend([[488, 511], [558, 576]])
RANGES["src/why/gnat2why-expr.adb"].extend([[3707, 3834], [3910, 3927], [15420, 15569], [22840, 23012], [23117, 23232], [30068, 30088]])
RANGES["src/why/gnat2why-driver.adb"].extend([[1381, 1445], [1593, 1638]])
RANGES["src/spark/spark_rewrite.adb"] = [[253, 276], [340, 544]]
RANGES["src/spark/spark_util.ads"] = [[69, 111]]
RANGES["src/why/gnat2why-expr.adb"].extend([[29496, 29517], [30190, 30215]])
RANGES["src/why/why-atree-modules.adb"].extend([
    [510, 912], [1091, 2985], [3006, 3387], [3584, 3757], [3959, 4084],
    [4394, 4510], [4578, 4588],
])
RANGES["src/why/why-atree-modules.ads"].extend([[609, 618]])
RANGES["src/why/why-inter.adb"].append([846, 880])
RANGES["src/why/why-gen-arrays.adb"].append([2951, 2955])
RANGES["src/why/gnat2why-driver.adb"].append([998, 1013])
RANGES["src/why/gnat2why-subprograms.adb"].extend([
    [548, 590], [1220, 1246], [1283, 1362], [1368, 1540], [1544, 1696],
    [1826, 1904], [2000, 2105], [3305, 3310], [4485, 4740], [4958, 5093],
    [5096, 5422], [5466, 5478], [5580, 5623], [5808, 5900], [6130, 6270],
    [6644, 6688], [7431, 7470], [7534, 7610], [7614, 7658], [7698, 7735], [8113, 8157],
    [8472, 8535], [9049, 9134],
])
RANGES["src/why/gnat2why-expr.adb"].extend([
    [2029, 2093], [2362, 2462], [2945, 2990], [3049, 3121], [9459, 9473],
    [9558, 9676], [14615, 14858], [26695, 26734], [26822, 26841],
])
RANGES["src/why/why-gen-binders.adb"].extend([
    [92, 129], [281, 364], [613, 690], [820, 886], [1222, 1258], [1629, 1640],
])
RANGES["src/why/gnat2why-util.adb"].extend([
    [644, 698], [840, 856], [1007, 1018], [1035, 1040], [1265, 1268],
])
RANGES["src/why/why-gen-terms.ads"] = [[31, 38]]
RANGES["src/why/why-gen-progs.ads"] = [[38, 42]]
RANGES["src/why/why-gen-expr.adb"].append([3149, 3165])
RANGES["src/spark/spark_util-subprograms.adb"] = [[786, 859], [1890, 1950]]
RANGES["src/spark/spark_util.adb"] = [[2450, 2540], [3092, 3153]]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def dump(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def is_node(value):
    return (isinstance(value, list) and bool(value)
            and isinstance(value[0], str) and value[0].startswith("W_"))


def nodes(value):
    if is_node(value):
        yield value
    if isinstance(value, list):
        for child in value:
            yield from nodes(child)
    elif isinstance(value, dict):
        for child in value.values():
            yield from nodes(child)


def occurrences(value):
    return sum(1 for _ in nodes(value))


def inspect_fixture(modules):
    result = []
    for module in modules:
        decls = module[3]
        axiom = next(d for d in decls if d[0] == "W_AXIOM"
                     and d[3].endswith("__def_axiom"))
        quantifier = axiom[4]
        predicate = quantifier[6]
        equalities = [n for n in nodes(predicate)
                      if n[0] == "W_CALL" and n[3][0] == "W_IDENTIFIER"
                      and n[3][3][3] == "="]
        length = len(equalities)
        char_predicate = 1 if length == 0 else 40 * length + int(length >= 2)
        imports = len(module[6])
        assert all(occurrences(n) == 40 for n in equalities)
        assert occurrences(predicate) == char_predicate
        assert occurrences(module) == 74 + char_predicate + 2 * imports
        ids = [n[1] for n in nodes(module)]
        assert ids == list(range(ids[0], ids[-1] + 1))
        result.append({
            "name": module[4], "decoded_length": length,
            "occurrences_per_character_equality": [occurrences(n) for n in equalities],
            "character_predicate_occurrences": char_predicate,
            "module_occurrences": occurrences(module), "import_count": imports,
            "nonimport_nonpredicate_occurrences": 74,
            "first_occurrence_id": ids[0], "last_occurrence_id": ids[-1],
        })
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path)
    parser.add_argument("--source-archive", type=Path)
    parser.add_argument("--retained-json", type=Path)
    parser.add_argument("--retained-source", type=Path)
    args = parser.parse_args()
    if args.source_root:
        entries = []
        excerpts = []
        for name, ranges in sorted(RANGES.items()):
            raw = (args.source_root / name).read_bytes()
            lines = raw.split(b"\n")
            if lines[-1] == b"":
                lines.pop()
            entries.append({"path": name, "sha256": sha(raw),
                            "bytes": len(raw), "lf_lines": len(lines),
                            "retained_line_ranges": ranges})
            for start, end in ranges:
                assert 1 <= start <= end <= len(lines), (name, start, end)
                excerpts.append(f"## {name}:{start}-{end}\n\n```ada\n")
                excerpts.extend(f"{i:6d}:" + (" " + lines[i-1].decode('utf-8') if lines[i-1] else "") + "\n"
                                for i in range(start, end + 1))
                excerpts.append("```\n\n")
        dump(ROOT / "source-manifest.json", {"revision": SOURCE_REVISION,
             "line_definition": "LF-separated byte lines; one trailing empty segment excluded",
             "files": entries})
        (ROOT / "source-excerpts.md").write_text("".join(excerpts).rstrip("\n") + "\n")
    if args.source_archive:
        manifest = json.loads((ROOT / "source-manifest.json").read_text())
        matched = []
        with tarfile.open(args.source_archive, "r:gz") as archive:
            for item in manifest["files"]:
                member = "spark-source/" + item["path"]
                raw = archive.extractfile(member).read()
                assert sha(raw) == item["sha256"], member
                matched.append({"path": item["path"], "sha256": sha(raw)})
        dump(ROOT / "source-archive-check.json", {
            "archive_sha256": sha(args.source_archive.read_bytes()),
            "archive_member_prefix": "spark-source/",
            "complete_files_matched": matched,
            "scope": "Source-file equality only, not external binary attestation",
        })
    if args.retained_json:
        assert args.retained_source
        raw = args.retained_json.read_bytes()
        value = json.loads(raw)
        modules = [n for n in nodes(value) if n[0] == "W_THEORY_DECLARATION"
                   and "String_Literal" in n[4]]
        assert len(modules) == 3
        dump(ROOT / "retained-literal-modules.json", modules)
        source = args.retained_source.read_bytes()
        (ROOT / "retained-main.adb").write_bytes(source)
        dump(ROOT / "retained-input.json", {
            "mode": "read existing artifacts; no new compiler or proof run",
            "json": {"path": str(args.retained_json), "bytes": len(raw), "sha256": sha(raw)},
            "source": {"path": str(args.retained_source), "bytes": len(source), "sha256": sha(source)},
            "scope": "Three literal modules extracted unchanged; this does not attest the whole prior run",
        })
    fixture = json.loads((ROOT / "retained-literal-modules.json").read_text())
    result = inspect_fixture(fixture)
    arithmetic = {
        "ordinary_main_wrapper": {
            "core_rows": {
                "registration_four_headers_and_vc_module": [7, 8, 0, 4],
                "completion_without_fixed_effects": [15, 4, 2, 16],
                "twelve_sequences_39_slots": [12, 12, 39, 12 + 4 * 39],
                "return_raise_and_try_handler": [3, 1, 1, 13],
                "two_eager_finalization_sequences": [2, 2, 3, 10],
                "four_comments": [4, 0, 0, 4],
                "two_ignored_empty_contracts": [10, 0, 0, 32],
                "other_empty_contract_literals": [3, 0, 0, 0],
                "vc_effects": [1, 3, 0, 0],
                "vc_function_with_unit_binder": [4, 1, 2, 12],
            },
            "core_total": [61, 31, 47, 259],
            "sequence_arities": [5, 3, 5, 2, 4, 3, 2, 2, 2, 6, 3, 2],
            "per_fixed_effect_rows": {
                "unused_logic_binder_and_effect_references": [11, 0, 2, 12],
                "input_assumption_and_output_dynamic_property": [68, 32, 48, 144],
                "three_discarded_type_invariant_traversals": [57, 30, 45, 0],
            },
            "per_fixed_effect_total": [136, 62, 95, 156],
            "fixed_effect_root_bound": 5,
            "unused_default_priority_read": [5, 0, 0, 0],
            "total_excluding_fixed_constant_assumptions": [746, 341, 522, 1039],
            "additional_closes": 4,
            "source_declaration_and_body_multiplicity": 1,
            "still_separate": "fixed external-constant assumptions and input closure, dependencies, imports, memoized modules",
        },
        "ordinary_entity_symbol_cache_nodes": {
            "signed_integer_type": 2 * (2 + 12 + 2) + 2 * 2,
            "rank_one_string_type": 2 * (10 + 9 + 2) + 2 * 3 + 2,
            "object": 3 * 2,
            "procedure_main": 2 * 2,
            "memoized_modules_per_entity": 27,
            "lists_elements_independent_occurrences": [0, 0, 0],
            "excludes": "richer fixed-library symbol shapes; initializer counted in initializer-inventory.json",
        },
        "representation_maxima": {"Why_Node_Id_Last": 2**30 - 1,
                                  "Why_Node_Counter_Last": 2**31 - 1},
        "array_representation_helper_allocations": {
            "each_cache_attempt_nodes": 1 + 2 + 2 + 6 * 2,
            "each_cache_attempt_lists": 0,
            "rank_one_helpers_on_miss_nodes": 2 + 5 * 2,
            "comparison_module_helpers_on_miss_nodes": 1 + 2,
            "excludes": "theory construction and all other translation work",
        },
        "ordinary_array_representation_miss": {
            "index_substitution_helper": {"nodes": 2 + 1 + 1 + 1 + 1 + 7 * 2,
                                          "lists": 1 + 3, "elements": 1, "occurrences_max": 9 + 7 * 5},
            "representation_before_equality": {"nodes": 1 + 20 + 3 + 5 + 1,
                                                "lists": 2 + 4 + 1 + 1, "elements": 1 + 1 + 9,
                                                "occurrences_max": 1 + 44 + 3 + 6 + 2},
            "equality": {"nodes": 16 + 2 + 3 + 8 + 16 + 4 + 8 + 12,
                         "lists": 2 + 3 + 8 + 5 + 3 + 4 + 4,
                         "elements": 4 + 4 + 12 + 8 + 1 + 7 + 15,
                         "shared_definition_occurrences_max": 219,
                         "function_occurrences_max": 273, "reverse_axiom_occurrences_max": 315},
            "comparison": {"nodes": 2 + 1 + 10 + 20 + 1, "lists": 2 + 4 + 1,
                           "elements": 1 + 12 + 1, "occurrences_max": 1 + 9 + 2 + 20 + 35},
            "total_per_miss": {"nodes": 30 + 69 + 34 + 15, "lists": 8 + 29 + 7,
                               "elements": 11 + 51 + 14, "occurrences_max": 56 + 588 + 67,
                               "theory_closes": 2, "direct_modules_beyond_each_attempt": 3},
            "excludes": "17 eager nodes per attempt, Close_Theory imports, cached Standard/Integer/Character symbol initialization",
        },
        "memoized_entity_module_kinds": 27,
        "main_entity_invocation_composition": {
            "ordinary_object_pass_per_entity": [11 + 22, 9, 6, 33],
            "loop_entity_pair": [6, 4, 2, 6],
            "literal_string_and_index_types": [112 + 97, 43 + 39, 45 + 33, 143 + 205],
            "literal_string_and_index_type_closes": 3 + 3,
            "object_entities": "D + F + G, with G <= 2F",
            "object_loop_closes": "2D + 4F + 2G <= 2D + 8F",
            "ordinary_array_attempts": "D_lit + D_alias + K_literal <= D_s + K_literal",
            "module_bound": "M <= all_nonimport_nodes",
            "main_itype_reference_translations": 0,
            "itype_reference_basis": "frontend-invocation-audit.json inventory plus manual exclusion table in research report",
        },
        "ordinary_expression_uniform_transfer": {
            "per_visit": [60 + 3 + 47, 32 + 22, 49 + 31, 484 + 459],
            "local_cases_with_boundary_allowances": {
                "integer_leaf": [2 + 3 + 4, 1, 1, 11 + 15],
                "integer_operator": [4 + 3 + 4, 2 + 1, 3 + 1, 20 + 15],
                "length_including_optional_overflow": [20 + 3 + 3 + 4, 6 + 1 + 1, 9 + 1 + 1, 92 + 12 + 15],
                "string_use": [9 + 3 + 47, 2 + 22, 3 + 31, 14 + 459],
                "string_read": [6 + 3 + 47, 3 + 22, 5 + 31, 48 + 459],
                "image": [5 + 3 + 47, 2 + 22, 3 + 31, 18 + 459],
                "concat": [60 + 3 + 47, 32 + 22, 49 + 31, 484 + 459],
                "first_or_default": [18 + 3 + 47, 9 + 22, 9 + 31, 74 + 459],
                "input_is_valid_with_predicate_wrappers": [18 + 3 + 3, 9 + 1, 9 + 2, 78 + 13],
                "string_comparison_with_predicate_wrappers": [25 + 3 + 3, 8 + 1, 14 + 2, 147 + 13],
                "scalar_comparison_with_predicate_wrappers": [1 + 3 + 3, 1 + 1, 2 + 2, 8 + 13],
                "boolean_connective_with_predicate_wrappers": [10 + 3 + 3, 2 + 1, 3 + 2, 28 + 13],
                "not_with_predicate_wrappers": [1 + 3 + 3, 1 + 1, 1 + 2, 8 + 13],
            },
            "visits": "2 * (X + U + 3P) + 2G, G <= 2F",
            "per_literal_definition": [23, 13, 10, 75],
            "per_aggregate_literal_character": [7, 3, 6, 40],
            "literal_identities": "K <= S + A + 3P + D_copy, D_copy <= D_s",
            "copied_literal_lengths": "H includes sum(length bound of each copied declaration initializer); charging every String declaration is conservative",
            "late_constant_propagation": "GCC sem_ch3:5436-5453 replaces a name leaf by a literal, sharing analyzed type and Strval; V and K_literal unchanged",
            "scope": "Ordinary Main executable/value-axiom expression forest; fixed setup, skeletons, type theories and imports separate",
        },
        "main_list_node_transfer": {
            "per_entry": [2, 0, 2, 6],
            "per_list": [1, 1, 1, 5],
            "list_count_bound": "2 + 2*A_Main",
            "affine_node_coefficients": [2 + 2, 2, 2 + 2, 6 + 2 * 5],
            "constant_vector": [2, 2, 2, 10],
            "required_input": "A source-derived frontend node-allocation bound A_Main, not an observed count",
            "includes": "ignored/null Void cores and two optional labels per entry; nonempty statement/declaration cores separate",
        },
        "ordinary_main_skeleton": {
            "integer_declaration": [13, 3, 9, 55],
            "string_declaration": [55, 24, 36, 188],
            "static_subtype_declaration": [1, 0, 0, 5],
            "integer_assignment": [6, 0, 0, 8],
            "string_assignment": [148, 61, 86, 1247],
            "put": [9, 6, 4, 9],
            "reject": [4, 6, 4, 13],
            "if_condition_point": [8, 2, 2, 26],
            "if_body_warning": [9, 1, 3, 27],
            "loop_fixed": [69, 23, 43, 267],
            "each_modified_root": [49, 19, 27, 126],
            "modified_root_bound": "F * (D + 4)",
            "excludes": "supplied expression children, list transfer, entity/type passes, symbol/module caches, enclosing Main and fixed dependency theories, imports",
        },
        "ordinary_range_loop": {
            "fixed_rows": {
                "index_binder_and_bound_temporaries": [5 + 4, 0, 0, 0],
                "empty_initial_statement_sequence": [1, 1, 1, 0],
                "eager_index_and_unused_iterator_dereferences": [2, 0, 0, 0],
                "index_invariant_excluding_endpoint_children": [1 + 3, 3, 4, 1 + 2 * (8 + 8)],
                "entry_condition": [3, 3, 6, 8 + 2 * 8 + 2 * 4 + 2 * 8],
                "index_update_and_location": [4, 1, 2, 1 + 1 + 5 + 2 + 1 + 5 + 2 + 8 + 1],
                "exit_condition": [1, 1, 2, 1 + 5 + 2 + 8 + 4],
                "combine_index_and_frame_invariants": [1, 1, 2, 8],
                "initialize_index_and_prepend": [2, 1, 2, 1 + 5 + 4 + 2 + 1],
                "bind_low_and_high_once": [2, 0, 0, 2 * (1 + 4 + 2)],
                "wrap_loop": [2 + 2 + 9 + 2 + 2 + 2 + 18 + 3, 1 + 3 + 2 + 1 + 1 + 2 + 2,
                              4 + 8 + 2 + 1 + 6 + 3, 15 + 17 + 2 + 2 + 8 + 58 + 3],
            },
            "fixed_total": [69, 23, 43, 267],
            "integer_frame_entire_object": [2 + 8 + 2 + 3 + 1, 4 + 1, 6, 38 + 18 + 1],
            "integer_frame_not_written": [2 + 2 + 1 + 3 + 1, 1 + 1, 2, 23 + 18 + 1],
            "string_frame_entire_object": [6 + 25 + 4 + 13 + 1, 3 + 12 + 3 + 1, 5 + 17 + 5, 69 + 56 + 1],
            "string_frame_not_written": [6 + 4 + 1 + 13 + 1, 3 + 1 + 3 + 1, 5 + 2 + 5, 61 + 56 + 1],
            "scope": "no unrolling, explicit range bounds, no source invariant/variant/filter/body declaration; supplied body and endpoint translations separate; selected library G4 uses opaque non-SPARK File_System expansion",
        },
        "generated_declaration_helpers": {
            "scalar_range_check_static_base_core": [3 + 2 + 2, 3 + 2, 6, 3 * 8 + 2 * 5 + 2 + 5],
            "optional_each_endpoint_program_check": [4 + 1, 1, 2, 13 + 1],
            "scalar_range_check_max": [7 + 2 * 5, 5 + 2, 6 + 4, 41 + 2 * 14],
            "term_endpoint_allocation_multiplicity": 1,
            "term_endpoint_occurrence_multiplicity": 2,
            "program_endpoint_multiplicity_max": 1,
            "static_subtype_decl_location_max": [1, 0, 0, 5],
            "itype_reference_ignore_wrapper_max": [4, 0, 0, 14],
            "regular_scalar_action_preparation_and_binding": [2 * 5 + 1, 0, 0, 8],
            "declaration_list": "(1,1,2d+1,5) beyond the supplied d ordinary declaration results",
            "mixed_statement_list": "(m+g+1,1,m+2g+1,m+g+5), m source statements and g ordinary generated declarations",
            "scope": "per-helper costs only; generated-node counts, initializer/endpoint/itype replay and action occurrence multiplicities must follow frontend shape",
        },
        "ordinary_type_translation_completion": {
            "convention": "componentwise conservative bounds; raw function builders are allowed the binder helper's empty effects/True pre/post even where absent",
            "static_string_declaration": [1 + 5 + 12 + 14 + 2 + 1, 1 + 8 + 1, 1 + 2 + 8, 6 + 22 + 27],
            "scalar_declaration_static": [3 + 2 + 10 + 16 + 12, 1 + 8 + 7 + 1, 1 + 2 + 6 + 5, 3 + 28 + 51 + 14],
            "scalar_declaration_modeled_base_itype": [3 + 2 + 2 + 18 + 12, 1 + 7 + 1, 1 + 8 + 6, 6 + 65 + 19],
            "ref_and_havoc": [19 + 10, 6 + 4, 6 + 3, 36 + 19],
            "scalar_representation": [8 + 1 + 10 + 1 + 2, 5 + 1, 1 + 3 + 4 + 2, 2 + 34 + 13 + 2],
            "static_integer_dynamic_invariant": [20 + 8, 4 + 4, 6 + 6, 44 + 31],
            "static_string_dynamic_invariant": [22 + 24, 4 + 12, 6 + 15, 46 + 13],
            "static_integer_default_init": [11, 4, 3, 24],
            "static_string_default_init": [13 + 15, 4 + 7, 3 + 10, 26],
            "type_and_completion_totals": {
                "static_integer_itype": [43 + 29 + 22 + 3, 17 + 10 + 6 + 6, 14 + 9 + 10, 96 + 55 + 51 + 3],
                "static_integer_non_itype": [97 + 28 + 11 + 1, 39 + 8 + 4 + 2, 33 + 12 + 3, 205 + 75 + 24 + 1],
                "dynamic_or_empty_integer_itype": [37 + 29 + 2, 9 + 10 + 4, 15 + 9, 90 + 55 + 2],
                "static_string_itype": [35 + 2, 10 + 4, 11, 55 + 2],
                "static_string_non_itype": [37 + 46 + 28 + 1, 14 + 16 + 11 + 2, 11 + 21 + 13, 57 + 59 + 26 + 1],
            },
            "excludes": "array representation attempts/misses, cached symbols/modules, Close_Theory imports, executable generated declaration checks, fixed predefined/dependency types",
        },
        "normalized_integer_core": {
            "binary_call_occurrence_overhead": 1 + 5 + 2,
            "unary_minus_call_occurrence_overhead": 1 + 4 + 2,
            "overflow_wrapper_occurrence_overhead_max": (1 + 5 + 2) + (1 + 2) + 1,
            "binary_with_overflow_occurrence_overhead_max": 20,
            "unary_minus_with_overflow_occurrence_overhead_max": 19,
            "excludes": "children, identifier leaves, surrounding subtype conversions, initial symbol setup",
        },
        "ordinary_integer_leaf_and_boundary": {
            "identifier_occurrences_max": 1 + 1 + 1 + 2,
            "dereference_overhead": 1 + 2,
            "type_label_overhead": 1 + 2,
            "normalized_identifier_occurrences_max": 11,
            "static_boundary_overhead_max": 12 + 3,
            "excludes": "initial symbol/binder creation, caller-created expected type",
        },
        "ordinary_integer_wrappers": {
            "declaration": {"nodes_max": 13, "lists_max": 3, "elements_max": 9, "occurrence_overhead_max": 55},
            "assignment": {"nodes_max": 6, "lists_max": 0, "elements_max": 0, "occurrence_overhead_max": 8},
            "eager_move_temporary_nodes": 2,
            "eager_assignment_target_temporary_nodes": 2,
            "excludes": "RHS/init translation and boundary, binder/symbol setup, outer theories, enclosing sequence",
        },
        "boolean_and_warning_wrappers": {
            "scalar_comparison": {"nodes": 1, "lists": 1, "elements": 2, "occurrence_overhead_max": 8},
            "warning": {"nodes_max": 9, "lists_max": 1, "elements_max": 3, "occurrence_overhead_max": 27},
            "short_circuit": {"nodes_max": 10, "lists_max": 2, "elements_max": 3, "occurrence_overhead_max": 28},
            "excludes": "children, symbol setup, frontend Actions",
        },
        "string_representation_primitives": {
            "split_binder_read": {"nodes_max": 6, "lists_max": 3, "elements_max": 5, "occurrences_max": 48},
            "to_base": {"nodes": 4, "lists": 1, "elements": 1, "occurrence_overhead_max": 10},
            "from_base_normalized_bounds": {"nodes_max": 4, "lists": 1, "elements": 3, "occurrence_overhead_max": 10},
            "eager_array_conversion_split_type_nodes_max": 6,
            "excludes": "supplied children except in complete read, binder/symbol/memoized-module setup, expected-type conversion",
        },
        "conditional_string_conversion": {
            "premise": "rank-one Character; static-constrained or unconstrained; no FLB/wrappers/predicates/qualification/element conversion",
            "length_equality_occurrences_max": 10 * 18 + 6 * 8 + 1 + 3,
            "dynamic_range_property_occurrences_max": 2 * 18 + 2 * 14 + 8,
            "nodes_max": 6 + 3 + 17 + 1 + 3 + 1 + 16,
            "lists_max": 8 + 1 + 13,
            "elements_max": 10 + 3 + 18,
            "occurrence_overhead_max": 9 + 148 + 4 + 9 + 51 + 238,
            "excludes": "input child, expected-type construction, symbol/memoized-module setup, invocation count",
        },
        "conditional_string_concatenation": {
            "premise": "ordinary static-constrained/unconstrained rank-one Strings, two String operands, Standard.String result/ancestor",
            "last_bound_occurrences_max": 4 * 18 + 2 * 8 + 3 * 8 + 18 + 1,
            "nodes_max": 2 + 1 + 1 + 21 + 16 + 13 + 6,
            "lists_max": 1 + 1 + 12 + 11 + 7,
            "elements_max": 1 + 1 + 20 + 18 + 9,
            "occurrence_overhead_max": 10 + 188 + 171 + 97 + 18,
            "excludes": "children, cached symbol/module setup, enclosing expected-type conversion, repeated translation",
        },
        "string_comparison_and_image": {
            "comparison": {"nodes_max": 25, "lists_max": 8, "elements_max": 14, "occurrence_overhead_max": 112 + 18 + 8 + 1 + 8},
            "image": {"nodes": 5, "lists": 2, "elements": 3, "occurrence_overhead_max": (1 + 6 + 3) + (1 + 3 + 3 + 1)},
            "excludes": "children, expected-type conversion, cached symbol/module setup, predicate pretty labels, adapter",
        },
        "string_initializer_assignment_core": {
            "nodes_max": 2 + 2 + 2 + 5 + 8 + 1 + 1,
            "lists_max": 1 + 6 + 1,
            "elements_max": 1 + 8 + 3,
            "occurrence_overhead_max": 25 + 2 * (14 + 18 + 8 + 1) + 1 + 8,
            "excludes": "initializer and expected-type conversion, binder/symbol setup, declaration dynamic-invariant suffix",
        },
        "string_declaration_invariant": {
            "discarded_array_traversal_static": {"nodes": 2 + 5 + 6, "lists": 5 + 2, "elements": 6 + 4},
            "discarded_array_traversal_nonstatic": {"nodes": 2 + 5 + 14, "lists": 5 + 4, "elements": 6 + 6},
            "named_predicate_path": {"nodes_max": 3 + 1 + 21, "lists_max": 1 + 9,
                                     "elements_max": 5 + 12, "occurrences_max": 48 + 4 * 3 + 6 + 2 + 1},
            "static_itype_path": {"nodes_max": 3 + 3 + 1 + 13 + 4, "lists_max": 2 + 1 + 7 + 2,
                                  "elements_max": 2 + 1 + 10 + 2, "occurrences_max": 48 + 8},
            "complete_suffix": {"nodes_max": 25 + 6 + 3, "lists_max": 12 + 3 + 1,
                                "elements_max": 17 + 5 + 2, "occurrences_max": 69 + 3},
            "complete_source_declaration_wrapper": {"nodes_max": 21 + 34, "lists_max": 8 + 16,
                                                    "elements_max": 12 + 24, "occurrences_max": 116 + 72},
            "excludes": "initializer and expected-type conversion, binder/symbol setup, subtype declarations, outer theories, enclosing statement list",
        },
        "conditional_string_assignment": {
            "nodes_max": 54 + 2 * 47,
            "lists_max": 17 + 2 * 22,
            "elements_max": 24 + 2 * 31,
            "occurrence_overhead_max": 329 + 2 * 459,
            "excludes": "RHS and initial expected-type conversion, symbol/module setup, enclosing sequence",
            "premise": "ordinary String-shape premise also covers binder Actual_Subtype",
        },
        "static_literal_fixed_component": {
            "each_invocation": {"nodes_max": 3 + 3 + 3, "lists_max": 1 + 1,
                                "elements_max": 1 + 2, "returned_occurrences": 1 + 6 + 4 + 3},
            "each_module_miss": {"nodes": 2 + 2 + 3 + 1 + 3 + 1 + 2 + 2 + 2 + 2 + 2,
                                 "lists": 2 + 4 + 1 + 2 + 1 + 2,
                                 "elements": 3 + 1 + 1 + 2 + 1 + 2,
                                 "fixed_occurrences": 1 + 19 + 30 + 24},
            "extra_string_valued_temporary_names_per_miss": 1,
            "excludes": "character predicate, Close_Theory imports, cached symbol setup, printing-plan repetition",
        },
        "literal_component_examples": [
            {"length": length,
             "new_nodes": 7 * length + int(length >= 2),
             "new_lists": 3 * length + int(length >= 2),
             "new_list_elements": 5 * length + max(length - 2, 0),
             "predicate_occurrences": 1 if length == 0 else 40 * length + int(length >= 2)}
            for length in [0, 1, 2, 3, 7, 4096, 2**31 - 1]],
        "retained_modules": result,
        "limitation": "Arithmetic and retained-fixture checks; not whole-producer bound or source correspondence proof",
    }
    loop = arithmetic["ordinary_range_loop"]
    wrapper = arithmetic["ordinary_main_wrapper"]
    assert wrapper["core_total"] == [
        sum(row[i] for row in wrapper["core_rows"].values()) for i in range(4)
    ]
    assert sum(wrapper["sequence_arities"]) == 39
    assert wrapper["per_fixed_effect_total"] == [
        sum(row[i] for row in wrapper["per_fixed_effect_rows"].values()) for i in range(4)
    ]
    assert wrapper["total_excluding_fixed_constant_assumptions"] == [
        wrapper["core_total"][i] + 5 * wrapper["per_fixed_effect_total"][i]
        + wrapper["unused_default_priority_read"][i] for i in range(4)
    ]
    assert loop["fixed_total"] == [
        sum(row[i] for row in loop["fixed_rows"].values()) for i in range(4)
    ]
    expression = arithmetic["ordinary_expression_uniform_transfer"]
    assert expression["per_visit"] == [110, 54, 80, 943]
    assert all(all(local[i] <= expression["per_visit"][i] for i in range(4))
               for local in expression["local_cases_with_boundary_allowances"].values())
    dump(ROOT / "checks.json", arithmetic)
    print(json.dumps({"retained_modules_checked": len(result),
                      "checks": str(ROOT / "checks.json")}))


if __name__ == "__main__":
    main()
