#!/usr/bin/env python3
"""Check source identities and ordinary-object local arithmetic only."""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile

RANGES = {
    "src/why/gnat2why-decls.adb": [(66, 113), (207, 283), (451, 812)],
    "src/why/gnat2why-driver.adb": [(1381, 1442), (1462, 1590)],
    "src/why/why-gen-binders.adb": [(192, 208), (745, 1121), (1151, 1182),
                                    (1262, 1276), (1346, 1368), (1392, 1415)],
    "src/why/why-gen-names.adb": [(95, 128), (714, 833), (1136, 1169)],
    "src/why/why-gen-decl.adb": [(74, 88)],
    "src/why/why-inter.adb": [(550, 752), (836, 890), (1129, 1224),
                             (1268, 1284), (1397, 1513), (1547, 1632)],
    "src/why/why-atree-modules.adb": [(529, 550), (721, 727)],
    "src/why/xgen/xtree_tables.adb": [(110, 143), (535, 548)],
    "src/why/xgen/xtree_sinfo.adb": [(77, 96), (187, 194), (301, 324),
                                    (579, 611), (638, 659), (721, 735)],
}


class Node:
    def __init__(self, *children):
        self.children = children


def occurrences(node):
    return 1 + sum(map(occurrences, node.children))


def derive():
    # Three-node type and six-occurrence qualified identifier upper shapes.
    typ = Node(Node(Node()))
    name = Node(Node())
    ident = Node(name, typ)
    local = Node(Node(), typ)
    boolean = Node(Node())
    eq_id = Node(Node(), boolean)
    assert [occurrences(x) for x in (typ, ident, local, eq_id)] == [3, 6, 5, 4]
    declaration = Node(local, typ)
    definition = Node(declaration)
    split_definition = Node(declaration, declaration, declaration)
    assert occurrences(definition) == 10
    assert occurrences(split_definition) == 28
    initializer = Node()
    left = Node(ident)
    equality = Node(eq_id, left, initializer, boolean)
    dependency = Node(ident)
    axiom_theory = Node(Node(equality, dependency))
    assert occurrences(axiom_theory) - occurrences(initializer) == 23
    # Trigger and triggers are allocated but discarded for empty binders.
    allocated_axiom_nodes = [left, equality, Node(left), Node(Node(left)),
                             dependency, axiom_theory.children[0], axiom_theory]
    assert len(allocated_axiom_nodes) == 7
    loop_theory = Node(Node(Node()), Node(Node()))
    assert occurrences(loop_theory) == 5
    assert 3 + 2 + 2 + 4 == 11
    assert 11 + 1 + 3 * 3 == 21
    assert 2 + 1 + 1 + 1 + 1 == 6  # theory/call/equality/two-trigger lists
    assert 2 + 1 + 1 + 1 == 5      # equality/trigger/triggers/emit elements
    return {
        "regular_setup": [5, 0, 0, 0],
        "split_string_setup": [11, 0, 0, 0],
        "direct_modules_per_setup_at_most": 1,
        "constant_definition": [4, 3, 1, 10],
        "regular_mutable_definition_with_extra_setup": [9, 2, 1, 10],
        "split_mutable_definition_with_extra_setup": [21, 4, 3, 28],
        "constant_value_axiom_overhead": [7, 6, 5, 23],
        "empty_axiom": [1, 2, 0, 1],
        "ordinary_constant_theory_pair": [11, 9, 6, 33],
        "regular_mutable_theory_pair": [10, 4, 1, 11],
        "split_mutable_theory_pair": [22, 6, 3, 29],
        "loop_exception_theory": [5, 2, 2, 5],
        "loop_theory_pair": [6, 4, 2, 6],
        "closes_per_object_or_loop_visit": 2,
        "scope": "local schema arithmetic; source review establishes constructors",
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
        "arithmetic": derive(),
        "not_established": ["installed producer source identity", "caller multiplicities",
                            "whole-process capacity", "auxiliary-container bounds"],
        "validation": "source/archive identity and local mathematical checks only",
    }
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(f"Verified {len(sources)} source files; object-theory local checks passed")


if __name__ == "__main__":
    main()
