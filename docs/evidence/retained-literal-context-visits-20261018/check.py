#!/usr/bin/env python3
"""Offline source census and fixed-context composition checks."""
import argparse
import hashlib
import json
import re
import time
from pathlib import Path

from derive import HERE, REPO, attach_main, evaluate, load_main

MANIFEST = "docs/evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json"
FIXED = "docs/evidence/unbounded-programs/retained-native-expansion-20261017/native-fixed-inputs.json"
SETTERS = {
    "rtsfind.adb": [1317], "sem_ch10.adb": [3046, 3683, 3908, 4477],
    "sem_ch12.adb": [11344], "sem_ch8.adb": [4396, 10182],
    "sem_elab.adb": [8484, 16404],
}
BUILDERS = {
    "rtsfind.adb": [1309], "sem_ch10.adb": [3675, 3903, 4464, 4469],
    "sem_ch8.adb": [4377, 10170], "lib-load.adb": [480],
    "par-ch10.adb": [920], "sem_elab.adb": [8482, 16400],
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ada-root", type=Path, required=True)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    started = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for row in inputs["repository_inputs"]:
        raw = (REPO / row["path"]).read_bytes()
        assert len(raw) == row["bytes"], row["path"]
        assert hashlib.sha256(raw).hexdigest() == row["sha256"], row["path"]
    manifest = json.loads((REPO / MANIFEST).read_text())
    assert manifest["commit"] == inputs["gcc_commit"]
    selected = [x for x in manifest["files"] if x["path"].endswith((".adb", ".ads"))]
    selected += [next(x for x in manifest["files"] if x["path"] == "gcc-interface/trans.cc")]
    setters, builders = {}, {}
    for row in selected:
        raw = (args.ada_root / row["path"]).read_bytes()
        assert len(raw) == row["bytes"], row["path"]
        assert hashlib.sha256(raw).hexdigest() == row["sha256"], row["path"]
        if not row["path"].endswith((".adb", ".ads")):
            continue
        for number, line in enumerate(raw.decode("latin1").splitlines(), 1):
            line = line.split("--", 1)[0]
            if re.search(r"\bSet_Is_Implicit_With\b", line, re.I):
                setters.setdefault(row["path"], []).append(number)
            if re.search(r"\bMake_With_Clause\b|\bNew_Node\s*\(\s*N_With_Clause\b", line, re.I):
                builders.setdefault(row["path"], []).append(number)
    assert setters == SETTERS, setters
    assert builders == BUILDERS, builders
    fixed = json.loads((REPO / FIXED).read_text())
    assert fixed["selected_runtime_specifications"] == 36
    assert fixed["semantic_compilation_units_including_Main"] == 39
    bound = evaluate()
    assert bound["I_upper_bound"] == 36+39+39 == 114
    assert bound["additional_caller_bytes"] == 3648
    original = load_main()
    cases = 0
    for C in range(1, 9):
        for N in range(5):
            for D in range(1, min(C, 2)+1):
                for length in (0, 999, 1000, (1 << 31)-1):
                    base = original.evaluate([length]*C, N, D)
                    joined = attach_main([length]*C, N, D)["original_Main"]
                    assert joined["inputs"]["I"] == 114
                    actual = joined["conditional_direct_totals"]
                    symbolic = base["symbolic_direct_totals"]
                    assert actual["GGC_events"] == symbolic["GGC_events"]["constant"]+114
                    for key in ("caller_bytes", "rounded_slot_bytes"):
                        assert actual[key] == symbolic[key]["constant"]+3648
                    assert joined["derived"]["H_constant"]+114 == 2*joined["derived"]["V"]+5*C+4*N+119
                    assert joined["shared_demands"] == base["shared_demands"]
                    assert joined["exclusions"] == base["exclusions"]
                    assert not joined["complete_original_gigi_storage_closed"]
                    assert not joined["whole_toolchain_capacity_established"]
                    cases += 1
    report = {"status": "passed", "Ada_files_checked": len(selected)-1,
              "bridge_files_checked": 1, "setter_sites": setters,
              "with_constructor_sites": builders, "arithmetic_cases": cases,
              "I_upper_bound": 114, "elapsed_seconds": time.monotonic()-started,
              "native_execution": False, "independent_review": "pending",
              "model_selected": "GPT-6 Astra", "effort_selected": "Extra High",
              "runtime_confirmation": None, "tokens": None, "cost": None}
    raw = json.dumps(report, indent=2, sort_keys=True)+"\n"
    if args.output:
        args.output.write_text(raw)
    print(raw, end="")


if __name__ == "__main__":
    main()
