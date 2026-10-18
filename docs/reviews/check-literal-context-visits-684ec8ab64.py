#!/usr/bin/env python3
"""Focused offline evidence for the independent context-visit source review.

The lexical inventory is multiline-aware; it is not an Ada control-flow proof.
Existing broad successful correspondence/composition checks are not replayed.
"""
import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
import time
from pathlib import Path

FREEZE = "684ec8ab64c0c97a4d5cb9f84c0e4ea7ba964a6c"
REPO = Path(__file__).resolve().parents[2]
PACKET = REPO / "docs/evidence/retained-literal-context-visits-20261018"
MANIFEST = REPO / "docs/evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json"
SETTERS = {"rtsfind.adb": [1317], "sem_ch10.adb": [3046, 3683, 3908, 4477],
           "sem_ch12.adb": [11344], "sem_ch8.adb": [4396, 10182],
           "sem_elab.adb": [8484, 16404]}
BUILDERS = {"lib-load.adb": [480], "par-ch10.adb": [920], "rtsfind.adb": [1309],
            "sem_ch10.adb": [3675, 3903, 4464, 4469],
            "sem_ch8.adb": [4377, 10170], "sem_elab.adb": [8482, 16400]}
FOCUSED = {"rtsfind.adb", "sem_elab.adb", "sem_ch10.adb", "sem_ch12.adb",
           "sem_ch8.adb", "lib-load.adb", "par-ch10.adb", "frontend.adb",
           "sem.adb", "ghost.adb", "lib.adb", "sem_ch6.adb", "sem_prag.adb",
           "nlists.adb", "gcc-interface/trans.cc"}


def ada_code(raw):
    # Hide string literals and comments, preserving offsets and line numbers.
    return re.sub(r'"(?:""|[^"\n])*"|--[^\n]*',
                  lambda m: " " * len(m[0]), raw)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ada-root", type=Path, required=True)
    args = parser.parse_args()
    start = time.monotonic()
    sys.dont_write_bytecode = True
    for path in [PACKET / x for x in ("derive.py", "inputs.json", "check.py")]:
        frozen = subprocess.check_output(
            ["git", "show", f"{FREEZE}:{path.relative_to(REPO)}"], cwd=REPO)
        assert path.read_bytes() == frozen, path
    inputs = json.loads((PACKET / "inputs.json").read_text())
    for row in inputs["repository_inputs"]:
        raw = (REPO / row["path"]).read_bytes()
        assert len(raw) == row["bytes"]
        assert hashlib.sha256(raw).hexdigest() == row["sha256"], row["path"]
    manifest = json.loads(MANIFEST.read_text())
    assert manifest["commit"] == inputs["gcc_commit"]
    by_path = {row["path"]: row for row in manifest["files"]}
    for path in FOCUSED:
        raw = (args.ada_root / path).read_bytes()
        assert len(raw) == by_path[path]["bytes"]
        assert hashlib.sha256(raw).hexdigest() == by_path[path]["sha256"], path
    sources = sorted(x for x in by_path if x.endswith((".adb", ".ads")))
    patterns = {
        "setters": r"\bSet_Is_Implicit_With\b",
        "builders": r"\bMake_With_Clause\b|\bNew_Node\s*\(\s*N_With_Clause\b",
        "kind_mutations": r"\b(?:Set_Nkind|Mutate_Nkind)\s*\([^;]*?\bN_With_Clause\b",
    }
    census = {key: {} for key in patterns}
    for path in sources:
        code = ada_code((args.ada_root / path).read_text(encoding="latin1"))
        for key, pattern in patterns.items():
            lines = [code.count("\n", 0, m.start()) + 1
                     for m in re.finditer(pattern, code, re.I)]
            if lines:
                census[key][path] = lines
    assert census["setters"] == SETTERS
    assert census["builders"] == BUILDERS
    assert census["kind_mutations"] == {}
    spec = importlib.util.spec_from_file_location("context_review_input", PACKET / "derive.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    bound = module.evaluate()
    assert bound["I_upper_bound"] == 36 + 39 + 39 == 114
    assert bound["pool_demands"] == {"insertions": 0, "lookups": 0, "replacements": 0}
    cases = [([0], 0, 1), ([999, 1000], 4, 2), ([(1 << 31)-1, 1, 0], 6, 2)]
    for lengths, n, d in cases:
        main_result = module.attach_main(lengths, n, d)["original_Main"]
        actual = main_result["conditional_direct_totals"]
        assert actual["GGC_events"] == 609*len(lengths) + 24*n + 54*d + 284 + 114
        for key in ("caller_bytes", "rounded_slot_bytes"):
            rows = sum(row["requests"]*row[key + "_each"] for row in main_result["rows"])
            assert actual[key] == rows + 114*32
        h = main_result["derived"]["H_constant"] + 114
        assert h == 2*main_result["derived"]["V"] + 5*len(lengths) + 4*n + 119
        assert not main_result["complete_original_gigi_storage_closed"]
        assert not main_result["whole_toolchain_capacity_established"]
    print(json.dumps({"status": "passed", "freeze": FREEZE,
        "repository_attachments": len(inputs["repository_inputs"]),
        "focused_source_identities": len(FOCUSED), "lexical_Ada_files": len(sources),
        "setter_sites": 10, "constructor_sites": 11, "kind_mutation_sites": 0,
        "mixed_arithmetic_cases": len(cases), "I_upper_bound": 114,
        "additional_bytes": 3648, "elapsed_seconds": time.monotonic()-start,
        "native_execution": False, "complete_capacity_claim": False}, indent=2))


if __name__ == "__main__":
    main()
