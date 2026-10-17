#!/usr/bin/env python3
"""Retain source excerpts and inspect existing JSON; never invokes the toolchain."""

import argparse
import hashlib
import json
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
    "src/why/xgen/xtree_sinfo.adb": [[30, 145], [170, 245], [280, 350], [380, 440], [580, 615], [705, 738]],
    "src/why/gnat2why-driver.adb": [[274, 310], [507, 610], [1195, 1225], [1318, 1355], [1415, 1457], [1462, 1590]],
    "src/why/gnat2why-util.adb": [[503, 540], [1126, 1201], [1347, 1454], [1609, 1615]],
    "src/why/gnat2why-util.ads": [[570, 582]],
    "src/why/why-inter.adb": [[354, 379], [387, 437], [550, 746], [836, 872], [943, 1017], [1160, 1224], [1260, 1285], [1547, 1577]],
    "src/why/why-atree-modules.adb": [[297, 324], [465, 504], [918, 1047]],
    "src/why/why-atree-modules.ads": [[819, 857]],
    "src/why/why-gen-names.adb": [[162, 352], [786, 832]],
    "src/why/why-gen-expr.adb": [[311, 348], [2399, 2445], [2476, 2522], [2642, 2692], [2740, 2910], [2916, 3050], [3533, 3569], [4289, 4355], [4488, 4535], [4883, 4922], [4962, 5010]],
    "src/why/why-gen-binders.adb": [[1260, 1310], [1392, 1415], [1626, 1640]],
    "src/why/why-gen-arrays.adb": [[981, 1068], [1075, 1161], [1529, 1623], [1772, 1906], [2990, 3036], [3042, 3078], [3835, 3848]],
    "src/why/gnat2why-expr.adb": [[1384, 1460], [1621, 1809], [2669, 2805], [2864, 2894], [14857, 14920], [19042, 19142], [21817, 21972], [21976, 22351], [22591, 22638], [23201, 23215], [23688, 23712], [24714, 24731], [29733, 29862], [30221, 30666], [31162, 31211]],
    "src/why/gnat2why-expr-loops.adb": [[500, 575], [787, 816], [1292, 1343], [1398, 1415], [1458, 1505], [1800, 1825], [1882, 1978], [2080, 2115], [2194, 2334]],
    "src/why/gnat2why-expr-loops-inv.adb": [[175, 198], [775, 815], [1079, 1398], [1704, 1745], [1940, 1976], [2291, 2350], [2398, 2408]],
    "src/why/why-gen-progs.adb": [[275, 280], [329, 364]],
    "src/why/gnat2why-decls.adb": [[66, 382], [451, 490], [496, 812]],
    "src/why/gnat2why-types.adb": [[895, 1101], [1108, 1155], [1623, 1739]],
    "src/why/gnat2why-subprograms.adb": [[4455, 4483], [5840, 5872], [6220, 6260]],
    "src/spark/spark_definition.ads": [[215, 232]],
    "src/spark/spark_definition.adb": [[248, 263], [11836, 11895], [12186, 12248], [14999, 15035]],
    "src/spark/spark_util-types.adb": [[3050, 3064]],
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
