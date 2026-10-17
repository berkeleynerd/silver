#!/usr/bin/env python3
"""Check pinned input bytes and local wrapper arithmetic, without tool runs."""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile

RANGES = {
    "src/why/gnat2why-expr.adb": [(19903, 20101), (25668, 25724),
                                  (29733, 29862), (30068, 30088), (30195, 30215)],
    "src/why/why-gen-arrays.adb": [(537, 580), (2813, 2928)],
    "src/why/why-gen-expr.adb": [(311, 347), (712, 820), (1956, 1987), (3149, 3170),
                                 (4728, 4758), (4937, 5011)],
    "src/why/why-gen-progs.adb": [(57, 85), (329, 369)],
    "src/why/why-atree-modules.adb": [(529, 550), (715, 717), (2805, 2810)],
    "src/why/why-gen-names.ads": [(83, 89)],
    "src/why/why-gen-names.adb": [(786, 808)],
    "src/why/xgen/xtree_sinfo.adb": [(254, 290), (330, 368), (427, 435),
                                    (473, 483), (528, 534)],
}


class Node:
    def __init__(self, *children):
        self.children = children


def occurrences(node):
    return 1 + sum(map(occurrences, node.children))


def wrapper_arithmetic():
    # Existing symbols/types. This miniature serialization graph checks the
    # documented recurrence; source review establishes which constructors run.
    boolean = Node(Node())
    unit = Node(Node())
    branch = Node(Node(Node()), boolean)  # identifier/name/module/type
    void = Node(Node(), unit)
    condition = Node()
    allocated = []

    def fresh(*children):
        result = Node(*children)
        allocated.append(result)
        return result

    assignment = fresh(branch, condition, boolean)
    located_assignment = fresh(assignment)
    labeled_branch = fresh(branch, boolean)
    field_name = fresh()
    field = fresh(field_name)
    access = fresh(labeled_branch, field, boolean)
    sequence = fresh(located_assignment, access)
    observation = (len(allocated), 1, 2,
                   occurrences(sequence) - occurrences(condition))
    assert observation == (7, 1, 2, 23)
    assert occurrences(branch) == 5
    assert occurrences(void) == 4
    then_part = Node()
    else_part = Node()
    conditional = fresh(sequence, then_part, else_part, unit)
    conditional_overhead = (occurrences(conditional) - occurrences(sequence)
                            - occurrences(then_part) - occurrences(else_part))
    assert conditional_overhead == 3
    length_rows = ((14, 3, 5, 48), (2, 0, 0, 0), (3, 3, 4, 36), (1, 0, 0, 8))
    length_total = [sum(row[i] for row in length_rows) for i in range(4)]
    assert length_total == [20, 6, 9, 92]
    return {
        "object_length_core": length_total,
        "branch_observation": list(observation),
        "conditional_overhead": [1, 1, 0, conditional_overhead],
        "branch_skeleton": ["8*q+9*b", "2*q+b", "2*q+3*b", "26*q+27*b"],
        "located_source_statement_list": ["m+1", "1", "m+1", "m+5"],
        "scope": "local arithmetic/schema corroboration; no mechanical caller proof",
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, default=Path(__file__).parent / "components.json")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    archive = root / "docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz"
    existing = json.loads((root / "docs/evidence/retained-producer-capacity-20261017/source-manifest.json").read_text())
    assert existing["revision"] == "42554fc241fcd1fdf08d3a2feccb3f86912acbc0"
    expected = {entry["path"]: entry for entry in existing["files"]}
    sources = []
    with tarfile.open(archive) as retained:
        for name, ranges in RANGES.items():
            data = (args.source_root / name).read_bytes()
            assert data == retained.extractfile("spark-source/" + name).read(), name
            digest = hashlib.sha256(data).hexdigest()
            if name in expected:
                assert digest == expected[name]["sha256"], name
            lines = data.decode().split("\n")
            assert all(1 <= first <= last <= len(lines) for first, last in ranges)
            sources.append({"path": name, "bytes": len(data), "sha256": digest,
                            "reviewed_lf_ranges": ranges})
    result = {
        "revision": existing["revision"],
        "retained_archive_sha256": hashlib.sha256(archive.read_bytes()).hexdigest(),
        "source_files_verified": len(sources),
        "sources": sources,
        "arithmetic": wrapper_arithmetic(),
        "not_established": ["installed producer source identity", "whole-process capacity",
                            "source-to-all-helper invocation coverage"],
        "validation": "source/archive identity and local mathematical checks only",
    }
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(f"Verified {len(sources)} source files; local wrapper arithmetic passed")


if __name__ == "__main__":
    main()
