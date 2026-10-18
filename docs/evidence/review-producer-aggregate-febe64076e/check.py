#!/usr/bin/env python3
"""Reproduce frozen aggregate evidence in scratch and check its arithmetic."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

p = argparse.ArgumentParser()
p.add_argument("source_root", type=Path)
p.add_argument("output", type=Path)
a = p.parse_args()
repo = Path(__file__).resolve().parents[3]
base = repo / "docs/evidence/retained-producer-capacity-20261017"
scratch = Path(tempfile.mkdtemp(prefix="review-producer-aggregate-febe64076e-"))
copy = scratch / "evidence"
shutil.copytree(base, copy)
archive = repo / "docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz"
subprocess.run(["python3", str(copy / "capture.py"), "--source-root", str(a.source_root),
                "--source-archive", str(archive)], check=True)
rows = []
for name in ["source-manifest.json", "source-excerpts.md", "source-archive-check.json", "checks.json"]:
    data = (copy / name).read_bytes()
    assert data == (base / name).read_bytes(), name
    rows.append({"path": name, "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()})

# Independent composition of the already reviewed vectors. These checks do
# not establish the source-to-visit or child-occurrence arguments.
def add(*vectors):
    return [sum(v[i] for v in vectors) for i in range(4)]
expr = add([60, 32, 49, 484], [3, 0, 0, 0], [47, 22, 31, 459])
assert expr == [110, 54, 80, 943]
x = json.loads((base / "checks.json").read_text())
assert x["ordinary_expression_uniform_transfer"]["per_visit"] == expr
for row in x["ordinary_expression_uniform_transfer"]["local_cases_with_boundary_allowances"].values():
    assert all(r <= b for r, b in zip(row, expr))
list_affine = add([2, 0, 2, 6], [2, 2, 2, 10])
assert list_affine == [4, 2, 4, 16]
assert x["main_list_node_transfer"]["affine_node_coefficients"] == list_affine
assert x["main_list_node_transfer"]["constant_vector"] == [2, 2, 2, 10]
result = {
    "target": "febe64076e",
    "technical_commit": "1eeeb5a581",
    "byte_identical_outputs": rows,
    "uniform_expression_vector": expr,
    "list_A_Main_coefficient": list_affine,
    "list_constant": [2, 2, 2, 10],
    "limitation": "Component arithmetic/source evidence; no frontend A_Main derivation, complete producer closure, compiler/prover run or installed source identity",
}
a.output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({"verified_outputs": len(rows), "scratch_preserved": str(scratch)}))
