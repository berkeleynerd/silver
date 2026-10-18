#!/usr/bin/env python3
"""Independent arithmetic/source inventory for a conditional component review.

This checks finite source sites and sums, not reachability or whole-tool closure.
No compiler, prover or Lean command is executed.
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
repo = Path(__file__).resolve().parents[3]
manifest = json.loads((repo / "docs/evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json").read_text())
assert manifest["commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
expected = {x["path"]: x for x in manifest["files"]}
names = ["exp_ch4.adb", "checks.adb", "sem_eval.adb", "sem_ch3.adb",
         "sem_ch4.adb", "sem_res.adb", "sem_type.adb", "sem_warn.adb",
         "sem_ch13.adb", "uintp.adb", "tbuild.adb", "itypes.adb"]
hashes = {}
for name in names:
    raw = (args.ada_source / name).read_bytes()
    digest = hashlib.sha256(raw).hexdigest()
    assert digest == expected[name]["sha256"], name
    blob = hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest()
    assert blob == expected[name]["git_blob_sha1"], name
    hashes[name] = digest

# Reconstruct the operator sites independently of the submitted checker.
lines = (args.ada_source / "exp_ch4.adb").read_text().splitlines()
pattern = re.compile(r"\bMake_(?:Op_(?:Add|Subtract|Eq|Ne)|If_Expression)\b")
sites = [(i, m.group()) for i, line in enumerate(lines, 1)
         if 2829 <= i <= 3638
         for m in pattern.finditer(line.split("--", 1)[0])]
assert sites == [(2884, "Make_Op_Subtract"), (3095, "Make_Op_Add"),
                 (3196, "Make_If_Expression"), (3199, "Make_Op_Ne"),
                 (3248, "Make_Op_Add"), (3251, "Make_Op_Subtract"),
                 (3275, "Make_If_Expression"), (3277, "Make_Op_Eq"),
                 (3284, "Make_If_Expression"), (3286, "Make_Op_Eq"),
                 (3555, "Make_Op_Add"), (3560, "Make_Op_Add"),
                 (3563, "Make_Op_Subtract"), (3613, "Make_Op_Ne")]

# Each pair represents coefficient*n + constant. Multiplicities are the
# reviewer's source/control-flow deductions, not inferred by this script.
arithmetic = [(0, 1), (1, -1), (0, 2), (3, 0)]
conditionals = [(1, 0), (0, 2)]
comparisons = [(1, 0), (0, 2), (1, 0)]
def add_pairs(rows):
    return [sum(x[0] for x in rows), sum(x[1] for x in rows)]
assert add_pairs(arithmetic) == [4, 2]
assert add_pairs(conditionals) == [1, 2]
assert add_pairs(comparisons) == [2, 2]

index_appends = 31 + 2 * 32
range_tree_constant = 6 * 3 + 2 * 2 + 6
compare_uint_A = 5 * 2 * 6 + 5 * 2 * 2
compare_uint_constant = 5 * 12
compare_nodes_A = 5 * 2 * 2
assert (index_appends, index_appends * 3) == (95, 285)
assert range_tree_constant == 28
assert (compare_uint_A, compare_uint_constant, compare_nodes_A) == (80, 60, 20)
assert compare_uint_constant + index_appends == 155
assert range_tree_constant + 2 * 2 == 32
assert (2 * compare_nodes_A, 2 + 3) == (40, 5)
assert (2 * compare_uint_A, 2 * compare_uint_constant) == (160, 120)

result = {
    "target": "cbcd679320",
    "upstream_commit": manifest["commit"],
    "source_sha256": hashes,
    "operator_constructor_sites": [{"line": i, "constructor": name} for i, name in sites],
    "direct_arithmetic_coefficient_and_constant": add_pairs(arithmetic),
    "direct_conditional_coefficient_and_constant": add_pairs(conditionals),
    "direct_comparison_coefficient_and_constant": add_pairs(comparisons),
    "index_layout_Uint_appends": index_appends,
    "range_tree_constant_nodes": range_tree_constant,
    "Compile_Time_Compare_Uint_A_and_constant": [compare_uint_A, compare_uint_constant],
    "Compile_Time_Compare_ordinary_A": compare_nodes_A,
    "limitation": "Manual conditional transfers only; no source-to-shape, reanalysis-multiplicity, exact installed source identity or whole-program closure claim",
}
args.output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({"sources_verified": len(hashes), "constructor_sites": len(sites),
                  "direct_arithmetic": "4*n+2", "whole_construct_closed": False}))
