#!/usr/bin/env python3
"""Reproduce retained evidence and independently check selected local transfers.

No compiler, prover, generated program or toolchain build is invoked.
"""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import tempfile


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


class Node:
    def __init__(self, *children):
        self.children = children


def size(node):
    return 1 + sum(size(child) for child in node.children)


def graph_checks():
    # Shapes reconstructed from xtree_sinfo and the selected source calls.
    # Uniform symbol-size allowances intentionally include smaller overloads.
    builtin = Node(Node())
    abstract = Node(Node(Node()))
    local_scalar = Node(Node(), builtin)
    arithmetic_symbol = Node(Node(Node()), builtin)
    local_get = Node(Node(), abstract)
    function_symbol = Node(Node(Node()), abstract)
    true_term = Node(builtin)
    true_pred, effects = Node(), Node()
    call = lambda op, args, typ=builtin: Node(op, *args, typ)
    binary = lambda left, right: call(arithmetic_symbol, (left, right))
    sub = binary(local_scalar, local_scalar)
    shifted = binary(sub, local_scalar)
    range_pred = Node(binary(local_scalar, local_scalar),
                      binary(local_scalar, local_scalar))
    length_eq = Node(binary(local_scalar, local_scalar),
                     Node(binary(local_scalar, local_scalar), binary(sub, sub)),
                     binary(local_scalar, local_scalar), builtin)
    read_a = call(local_get, (local_scalar, local_scalar), abstract)
    read_b = call(local_get, (local_scalar, shifted), abstract)
    convert = lambda value: call(arithmetic_symbol, (value,))
    equality = binary(convert(read_a), convert(read_b))
    binder = Node(local_scalar, builtin)
    guarded = Node(range_pred, equality, builtin)  # absent else child
    quantified = Node(binder, guarded)
    definition = Node(length_eq, quantified)
    function = Node(function_symbol, *([binder] * 6), effects,
                    true_pred, true_pred, builtin, definition)
    reverse_call = call(function_symbol, [local_scalar] * 6)
    reverse_comparison = binary(reverse_call, true_term)
    axiom = Node(Node(*([binder] * 6), Node(reverse_comparison, definition)),
                 Node(function_symbol))
    observed = [size(n) for n in (shifted, range_pred, length_eq, read_a,
                                 read_b, equality, quantified, definition,
                                 function, reverse_comparison, axiom)]
    assert observed == [28, 33, 92, 17, 41, 82, 126, 219, 273, 44, 315]
    # Repeated shared definition is serialized twice, not hash-consed once.
    assert size(function) + size(axiom) == 588

    branch = Node(Node(Node()), builtin)
    condition = Node()
    assignment_label = Node(Node(branch, condition, builtin))
    branch_label = Node(branch, builtin)
    access = Node(branch_label, Node(Node()), builtin)
    observation = Node(assignment_label, access)
    assert size(observation) - size(condition) == 23
    return {"array_equality_intermediate_occurrences": observed,
            "array_equality_function_and_reverse_axiom": 588,
            "branch_observation_overhead": 23}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--spark", type=Path, required=True)
    parser.add_argument("--gcc", type=Path, required=True)
    parser.add_argument("--gpr", type=Path, required=True)
    parser.add_argument("--installation", type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    evidence = root / "docs/evidence"
    archive = evidence / "unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz"
    source_files = set()
    reproduced = []
    with tempfile.TemporaryDirectory(prefix="review-0cd5b74cc7-") as temp:
        scratch = Path(temp)
        capacity = evidence / "retained-producer-capacity-20261017"
        copied = scratch / "capacity"
        shutil.copytree(capacity, copied)
        subprocess.run([sys.executable, str(copied / "capture.py"),
                        "--source-root", str(args.spark),
                        "--source-archive", str(archive)],
                       check=True, stdout=subprocess.DEVNULL)
        for name in ("source-manifest.json", "source-excerpts.md",
                     "source-archive-check.json", "checks.json"):
            assert (copied / name).read_bytes() == (capacity / name).read_bytes()
            reproduced.append({"path": str((capacity / name).relative_to(root)),
                               "sha256": sha(copied / name)})
        source_files.update(x["path"] for x in json.loads(
            (capacity / "source-manifest.json").read_text())["files"])
        for component in ("control-20261017", "objects-20261017", "calls-20261018"):
            directory = evidence / ("retained-producer-" + component)
            result = scratch / (component + ".json")
            subprocess.run([sys.executable, str(directory / "derive.py"),
                            "--source-root", str(args.spark), "--output", str(result)],
                           check=True, stdout=subprocess.DEVNULL)
            assert result.read_bytes() == (directory / "components.json").read_bytes()
            reproduced.append({"path": str((directory / "components.json").relative_to(root)),
                               "sha256": sha(result)})
            source_files.update(x["path"] for x in json.loads(result.read_text())["sources"])
        fixed_dir = evidence / "unbounded-programs/retained-source-closure-20261017"
        fixed_bytes = subprocess.check_output([
            sys.executable, str(fixed_dir / "close-fixed-support.py"),
            "--installation", str(args.installation), "--gcc", str(args.gcc),
            "--gpr-source", str(args.gpr)])
        assert fixed_bytes == (fixed_dir / "fixed-support-closure.json").read_bytes()
        reproduced.append({"path": str((fixed_dir / "fixed-support-closure.json").relative_to(root)),
                           "sha256": hashlib.sha256(fixed_bytes).hexdigest()})
        fixed = json.loads(fixed_bytes)

    # Independently reconcile complete source identities, including name code
    # outside the fixed-support collector's inventory.
    with tarfile.open(archive) as retained:
        for name in sorted(source_files):
            assert (args.spark / name).read_bytes() == retained.extractfile("spark-source/" + name).read()
    baseline_path = evidence / "unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json"
    baseline = {x["path"]: x for x in json.loads(baseline_path.read_text())["files"]}
    gcc_names = set(fixed["gcc_source_inputs"]) | {"exp_dbug.adb", "namet.adb", "namet.ads", "tbuild.adb", "lib.adb", "types.ads", "scng.adb"}
    for name in gcc_names:
        key = name if name in baseline else "gcc/ada/" + name
        assert sha(args.gcc / name) == baseline[key]["sha256"], name

    aligned = lambda length: 4096 * (length // 4096 + 1)
    spec_charge = sum(aligned(item["bytes"]) for item in fixed["selected_specifications"].values())
    assert spec_charge == 409600
    assert len(fixed["binder_ali_closure"]) == 98
    assert fixed["binder_unit_count"] == 169
    units, path, directories, links = 169, 4096, 3, 1
    binder_raw = 1001 * (349 + 19 * units) + 1009 * links + (path + 9) * units + (path + 11) * directories
    assert binder_raw == 4270635
    assert binder_raw + 8192 + 20496384 + 4096 == 24779307
    assert 7 * aligned(1554) + aligned(3367) == 32768
    assert 7 * aligned(1554) + aligned(3367) + aligned(4898) == 40960
    # Exercise grouping and all-one omission without treating omitted suffixes
    # as unallocated temporary characters.
    homonym_cases = 0
    for count in range(5):
        for values in itertools.product((1, 2, 10, 999, 2147483647), repeat=count):
            joined = "_".join(map(str, values))
            charge = sum(len(str(v)) for v in values) + max(count - 1, 0)
            assert len(joined) == charge
            assert not count or charge <= 11 * count - 1
            emitted = "" if all(v == 1 for v in values) else "__" + joined
            assert len(emitted) <= (2 + charge if count else 0)
            homonym_cases += 1
    result = {
        "target": "0cd5b74cc77326df06284d57066dd16db145f43b",
        "reproduced_outputs": reproduced,
        "complete_spark_files_equal_to_retained_archive": len(source_files),
        "complete_gcc_files_equal_to_retained_manifest": len(gcc_names),
        "source_hash_scope": "Identity checks are broader than the directly inspected source paths; they do not establish installed binary correspondence.",
        "independent_arithmetic": {**graph_checks(), "binder_raw_bytes": binder_raw,
                                  "binder_source_charge": 24779307,
                                  "support_specification_charge": spec_charge,
                                  "homonym_transfer_cases": homonym_cases},
        "validation": "Source, retained-evidence and local arithmetic checks only. No compiler/prover execution; no whole-predicate verdict.",
    }
    destination = Path(__file__).with_name("results.json")
    destination.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"outputs_reproduced": len(reproduced), "spark_files": len(source_files),
                      "gcc_files": len(gcc_names), "checks": "passed"}))


if __name__ == "__main__":
    main()
