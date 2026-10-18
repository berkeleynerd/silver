#!/usr/bin/env python3
"""Check source identities and selected-call local arithmetic only."""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile

RANGES = {
    "src/why/gnat2why-expr.adb": [(4334,4919),(8654,8741),(10757,10788),
                                  (12090,12217),(21035,21399),(26365,26689),
                                  (26847,26909)],
    "src/why/gnat2why-subprograms.adb": [(2000,2012),(2050,2154)],
    "src/why/gnat2why-util.adb": [(1126,1221),(1843,1872)],
    "src/why/why-gen-binders.adb": [(448,455),(613,739),(745,1121)],
    "src/why/why-gen-expr.adb": [(311,379),(3485,3504),(4289,4331),
                                 (4962,5178)],
    "src/why/why-gen-names.adb": [(540,557),(714,806)],
    "src/why/why-gen-progs.adb": [(42,85),(275,371)],
    "src/why/why-inter.adb": [(1639,1655)],
    "src/why/why-atree-modules.adb": [(529,550),(3117,3125)],
    "src/why/xgen/xtree_sinfo.adb": [(110,122),(243,273),(301,324),
                                    (330,349),(528,534)],
    "src/spark/spark_util.adb": [(2450,2540),(3092,3153)],
    "src/spark/spark_util-subprograms.adb": [(95,144),(786,859),(2044,2107)],
    "src/spark/spark_util-types.adb": [(1521,1552)],
}


class Node:
    def __init__(self, *children):
        self.children = children


def occurrences(node):
    return 1 + sum(map(occurrences, node.children))


def derive():
    typ = Node(Node(Node()))
    boolean = Node(Node())
    unit = Node(Node())
    result = Node(Node(), typ)
    argument_tmp = Node(Node(), typ)
    function = Node(Node(Node()), typ)
    guard = Node(Node(Node()), unit)
    equality_id = Node(Node(), boolean)
    argument = Node()
    call = Node(function, argument_tmp, typ)
    guard_call = Node(guard, result, argument_tmp, boolean)
    equality = Node(equality_id, result, call, boolean)
    conjunction = Node(equality, guard_call)
    epsilon = Node(result, typ, conjunction)
    term_binding = Node(argument_tmp, argument, epsilon, typ)
    assert [occurrences(n) for n in (call, guard_call, equality,
            conjunction, epsilon)] == [15, 18, 27, 46, 55]
    assert occurrences(term_binding)-occurrences(argument) == 64
    assumption = Node(guard_call)
    sequence = Node(assumption, result)
    result_binding = Node(result, call, sequence, typ)
    pterm_binding = Node(argument_tmp, argument, result_binding, typ)
    assert occurrences(pterm_binding)-occurrences(argument) == 58
    void = Node(Node(), unit)
    procedure = Node(Node(Node()))
    procedure_call = Node(procedure, argument)
    store = Node(procedure_call, void)
    assert occurrences(store)-occurrences(argument) == 9
    assert occurrences(void) == 4
    assert 2+2+1+1+1+1+1+1 == 10
    assert 5+2+1+10 == 18
    assert 2+3+4 == 9
    assert 2+7 == 9
    return {
        "ordinary_guarded_function_body": [10,4,7,74],
        "first_or_default_wrapper": [18,9,9,74],
        "input_is_valid_wrapper": [18,9,9,78],
        "put_or_put_line_wrapper": [9,6,4,9],
        "reject_wrapper": [4,6,4,13],
        "source_argument_multiplicity": 1,
        "function_temporary_names_at_most": 2,
        "function_argument_temp_map_entries_at_most": 1,
        "per_call_theories_and_direct_modules": 0,
        "scope": "local schema arithmetic; fixed dependencies and caller coverage separate",
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--output", type=Path,
                        default=Path(__file__).parent / "components.json")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    archive = root / "docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz"
    sources = []
    with tarfile.open(archive) as retained:
        for name, ranges in RANGES.items():
            data = (args.source_root / name).read_bytes()
            assert data == retained.extractfile("spark-source/" + name).read(), name
            lines = data.decode().split("\n")
            assert all(1 <= first <= last <= len(lines) for first, last in ranges)
            sources.append({"path": name, "bytes": len(data),
                            "sha256": hashlib.sha256(data).hexdigest(),
                            "reviewed_lf_ranges": ranges})
    result = {
        "revision": "42554fc241fcd1fdf08d3a2feccb3f86912acbc0",
        "retained_archive_sha256": hashlib.sha256(archive.read_bytes()).hexdigest(),
        "source_files_verified": len(sources),
        "sources": sources,
        "selected_library_inputs": [{"path": name, "sha256": hashlib.sha256((root / name).read_bytes()).hexdigest()} for name in ["src/silver_io.ads", "src/silver_io.adb", "src/silver_arguments.ads", "src/silver_arguments.adb", "src/silver_runtime.ads"]],
        "arithmetic": derive(),
        "not_established": ["installed producer source identity", "caller multiplicities",
                            "whole-process capacity", "auxiliary-container bounds"],
        "validation": "source/archive identity and local mathematical checks only",
    }
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(f"Verified {len(sources)} source files; library-call local checks passed")


if __name__ == "__main__":
    main()
