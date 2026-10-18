#!/usr/bin/env python3
"""Reproduce the frozen component evidence and verify the later L1 repair."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[2]
EVIDENCE = REPO / "docs/evidence"
REPAIR = "b6061a8458"


def sha(data):
    return hashlib.sha256(data).hexdigest()


def run(*args):
    subprocess.run([sys.executable, *map(str, args)], cwd=REPO, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--frontend", type=Path, required=True)
    parser.add_argument("--spark", type=Path, required=True)
    parser.add_argument("--installation", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    producer = EVIDENCE / "retained-producer-capacity-20261017"
    names = ["checks.json", "source-manifest.json", "source-excerpts.md",
             "source-archive-check.json", "frontend-invocation-audit.json",
             "frontend-invocation-excerpts.md"]
    before = {name: (producer / name).read_bytes() for name in names}
    run(producer / "capture.py", "--source-root", args.spark,
        "--source-archive", EVIDENCE / ("unbounded-programs/"
        "frontend-representation-20261017/toolchain/raw-evidence.tar.gz"))
    run(producer / "frontend_invocations.py", "--frontend-root", args.frontend)
    for name, data in before.items():
        assert (producer / name).read_bytes() == data, name

    # Independent case/spacing-tolerant scans across the whole Ada source tree.
    paren = []
    itypes = []
    for path in sorted(args.frontend.rglob("*")):
        if path.suffix not in (".adb", ".ads"):
            continue
        code = "\n".join(line.split("--", 1)[0]
                         for line in path.read_text().split("\n"))
        for match in re.finditer(r"\bSet_Paren_Count\s*\(", code, re.I):
            paren.append({"file": str(path.relative_to(args.frontend)),
                          "line_lf": code.count("\n", 0, match.start()) + 1})
        if path.suffix == ".adb":
            for number, line in enumerate(code.split("\n"), 1):
                for match in re.finditer(
                    r"\b(Make_Itype_Reference|Build_Itype_Reference|Ensure_Defined)\b",
                    line, re.I
                ):
                    if not re.search(r"\b(?:procedure|function|end)\s+$",
                                     line[:match.start()], re.I):
                        itypes.append({"path": str(path.relative_to(args.frontend)),
                                       "line": number, "callee": match.group(1)})
    frontend = json.loads(before["frontend-invocation-audit.json"])
    assert itypes == frontend["call_sites"] and len(itypes) == 37
    assert len(paren) == 22
    assert {"file": "atree.adb", "line_lf": 2273} in paren

    table_rel = "docs/evidence/unbounded-programs/retained-table-capacity-20261017"
    table = REPO / table_rel
    frozen_out = args.output / "frozen-table.json"
    run(table / "derive.py", args.frontend, frozen_out)
    assert frozen_out.read_bytes() == (table / "arithmetic-and-inventory.json").read_bytes()
    frozen_sites = json.loads(frozen_out.read_text())["parenthesis_counts"]["lexical_setter_sites"]
    assert len(frozen_sites) == 21

    # Execute the exact repair script with its normal repository-relative
    # context, without modifying the frozen reviewed input files.
    repaired_source = subprocess.check_output(
        ["git", "show", f"{REPAIR}:{table_rel}/derive.py"], cwd=REPO)
    repaired_output = args.output / "repaired-table.json"
    saved_argv = sys.argv
    try:
        sys.argv = [str(table / "derive.py"), str(args.frontend), str(repaired_output)]
        exec(compile(repaired_source, str(table / "derive.py"), "exec"),
             {"__file__": str(table / "derive.py"), "__name__": "__main__"})
    finally:
        sys.argv = saved_argv
    repair_record = subprocess.check_output(
        ["git", "show", f"{REPAIR}:{table_rel}/arithmetic-and-inventory.json"], cwd=REPO)
    assert repaired_output.read_bytes() == repair_record
    repaired_sites = json.loads(repair_record)["parenthesis_counts"]["lexical_setter_sites"]
    assert [{"file": row["file"], "line_lf": row["line_lf"]}
            for row in repaired_sites] == paren

    # Independently reconstruct the fixed loop occurrence overhead from the
    # schema, treating its body/endpoint/frame subtrees as separate children.
    void, identifier, temporary, builtin_type, exception_name = 4, 5, 4, 2, 2
    deref = 1 + identifier + builtin_type
    comparison_overhead = 1 + identifier + builtin_type
    loop_occ = {
        "index_invariant": 1 + 2 * (comparison_overhead + deref),
        "entry_condition": 8 + 2 * comparison_overhead + 2 * deref + 2 * temporary,
        "update_and_location": 1 + (1 + identifier + builtin_type)
            + (1 + identifier + builtin_type) + deref + 1,
        "exit_condition": comparison_overhead + deref + temporary,
        "combined_invariants": 8,
        "initialize_and_prepend": 1 + (1 + identifier + temporary + builtin_type),
        "two_bound_bindings": 2 * (1 + temporary + builtin_type),
    }
    before_loop = 1 + (1 + void) + 1 + void + void
    catch_void = 1 + (1 + exception_name + void)
    after_loop = 1 + 3 + 1 + catch_void + (1 + 1 + exception_name)
    wrap = before_loop + after_loop + 2 + 2 + catch_void + (2 * 27 + void) + 3
    assert wrap == 105 and sum(loop_occ.values()) + wrap == 267

    identity = EVIDENCE / "retained-tool-source-identity-20261018"
    identity_result = (identity / "results.json").read_bytes()
    run(identity / "verify.py", "--installation", args.installation)
    assert (identity / "results.json").read_bytes() == identity_result
    for row in json.loads((identity / "MANIFEST.json").read_text()):
        data = (identity / row["path"]).read_bytes()
        assert len(data) == row["bytes"] and sha(data) == row["sha256"]
    assert json.loads(identity_result)["source_identity_established"] is False

    result = {
        "review_target": "5d4fd26cbb",
        "previous_review_target": "0cd5b74cc7",
        "producer_outputs_reproduced": [{"path": n, "sha256": sha(v)} for n, v in before.items()],
        "spark_source_files_verified": len(json.loads(before["source-manifest.json"])["files"]),
        "frontend_ada_files_verified": frontend["scan_file_count"],
        "itype_inventory_reproduced": len(itypes),
        "independent_parenthesis_sites": paren,
        "L1": {"severity": "low", "frozen_sites": len(frozen_sites),
               "correct_sites": len(paren), "repair_commit": REPAIR,
               "repair_byte_identical_reproduction": True,
               "repaired_inventory_sha256": sha(repair_record)},
        "fixed_loop_occurrences": loop_occ,
        "wrap_loop_occurrences": wrap,
        "fixed_loop_occurrences_total": sum(loop_occ.values()) + wrap,
        "source_identity_record_reproduced": True,
        "source_identity_established": False,
        "scope": "Source/evidence review, not complete capacity assurance or installed-tool acceptance",
    }
    (args.output / "review-results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"reproduced_producer_outputs": len(before),
                      "L1_repair_verified": True, "fixed_loop_occurrences": 267}))


if __name__ == "__main__":
    main()
