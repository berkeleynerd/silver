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
    "src/why/xgen/xtree_sinfo.adb": [[30, 145], [170, 245], [254, 350], [371, 440], [470, 486], [528, 558], [580, 615], [705, 738]],
    "src/why/gnat2why-driver.adb": [[274, 310], [507, 610], [1195, 1225], [1318, 1355], [1415, 1457], [1462, 1590]],
    "src/why/gnat2why-util.adb": [[503, 540], [1126, 1201], [1347, 1454], [1609, 1615], [1875, 1909]],
    "src/why/gnat2why-util.ads": [[570, 582]],
    "src/why/why-inter.adb": [[354, 379], [387, 437], [550, 746], [756, 799], [836, 872], [943, 1017], [1160, 1224], [1260, 1285], [1547, 1632]],
    "src/why/why-atree-modules.adb": [[297, 324], [465, 504], [703, 781], [870, 893], [918, 1047], [1132, 1150], [2699, 2747], [2765, 2775], [3297, 3323], [3693, 3722], [3962, 4006]],
    "src/why/why-atree-modules.ads": [[819, 857]],
    "src/why/why-gen-names.adb": [[162, 352], [786, 870], [1182, 1220]],
    "src/why/why-gen-expr.adb": [[147, 157], [311, 381], [982, 1512], [1518, 1648], [1956, 1996], [2349, 2391], [2399, 2910], [2916, 3050], [3219, 3277], [3484, 3997], [4289, 4385], [4488, 4535], [4816, 4837], [4883, 4922], [4962, 5010], [5282, 5323], [5446, 5541]],
    "src/why/why-gen-expr.ads": [[96, 105], [305, 311]],
    "src/why/why-gen-binders.adb": [[192, 211], [448, 453], [745, 786], [888, 947], [1082, 1125], [1222, 1310], [1392, 1415], [1457, 1524], [1626, 1640]],
    "src/why/why-gen-arrays.adb": [[223, 448], [537, 580], [981, 1068], [1075, 1161], [1529, 1623], [1772, 1906], [2813, 2892], [2990, 3036], [3042, 3078], [3261, 3281], [3305, 3363], [3396, 3599], [3835, 3848]],
    "src/why/gnat2why-expr.adb": [[1384, 1460], [1621, 1831], [2329, 2360], [2669, 2805], [6396, 6524], [6730, 6824], [8782, 8916], [11736, 11778], [11961, 12034], [2864, 2894], [12039, 12056], [12286, 12368], [12402, 12440], [14857, 14920], [18547, 18735], [19042, 19146], [19238, 19345], [20256, 20300], [21817, 21972], [21976, 22351], [22591, 22638], [23187, 23215], [23600, 23647], [23688, 23712], [24012, 24205], [24547, 24570], [24630, 24731], [25500, 25573], [25635, 25724], [26847, 27088], [29520, 29561], [29733, 29862], [30221, 30666], [30936, 31120], [31162, 31211]],
    "src/why/gnat2why-expr-loops.adb": [[500, 575], [787, 816], [1292, 1343], [1398, 1415], [1458, 1505], [1800, 1825], [1882, 1978], [2080, 2115], [2194, 2334]],
    "src/why/gnat2why-expr-loops-inv.adb": [[175, 198], [775, 815], [1079, 1398], [1704, 1745], [1940, 1976], [2291, 2350], [2398, 2408]],
    "src/why/why-gen-progs.adb": [[38, 45], [168, 180], [199, 215], [243, 257], [275, 280], [329, 364]],
    "src/why/why-gen-records.adb": [[5048, 5125]],
    "src/why/why-gen-init.adb": [[502, 554]],
    "src/why/gnat2why-decls.adb": [[66, 382], [451, 490], [496, 812]],
    "src/why/gnat2why-types.adb": [[895, 1101], [1108, 1155], [1623, 1739]],
    "src/why/gnat2why-subprograms.adb": [[4455, 4483], [5840, 5872], [6220, 6260]],
    "src/spark/spark_definition.ads": [[215, 232]],
    "src/spark/spark_definition.adb": [[248, 263], [11836, 11895], [12186, 12248], [14999, 15035]],
    "src/spark/spark_util-types.adb": [[1521, 1620], [3050, 3064]],
}


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
        "representation_maxima": {"Why_Node_Id_Last": 2**30 - 1,
                                  "Why_Node_Counter_Last": 2**31 - 1},
        "array_representation_helper_allocations": {
            "each_cache_attempt_nodes": 1 + 2 + 2 + 6 * 2,
            "each_cache_attempt_lists": 0,
            "rank_one_helpers_on_miss_nodes": 2 + 5 * 2,
            "comparison_module_helpers_on_miss_nodes": 1 + 2,
            "excludes": "theory construction and all other translation work",
        },
        "memoized_entity_module_kinds": 27,
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
            "each_module_miss": {"nodes": 2 + 3 + 1 + 3 + 1 + 2 + 2 + 2 + 2 + 2,
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
    dump(ROOT / "checks.json", arithmetic)
    print(json.dumps({"retained_modules_checked": len(result),
                      "checks": str(ROOT / "checks.json")}))


if __name__ == "__main__":
    main()
