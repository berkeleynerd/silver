#!/usr/bin/env python3
"""Verify frozen identities and exercise ledger arithmetic without GCC."""
import argparse
import hashlib
import json
import time
from pathlib import Path

from derive import EXCLUDED, INT_MAX, SCALAR_PARTS, evaluate

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--gcc-root", type=Path, required=True)
    parser.add_argument("--ada-root", type=Path, required=True)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    start = time.monotonic()
    manifest = json.loads((HERE / "inputs.json").read_text())
    for row in manifest["files"]:
        root = {"repository": REPO, "gcc": args.gcc_root,
                "ada": args.ada_root}[row["root"]]
        raw = (root / row["path"]).read_bytes()
        assert len(raw) == row["bytes"], row["path"]
        assert hashlib.sha256(raw).hexdigest() == row["sha256"], row["path"]
    assert sum(SCALAR_PARTS.values()) == 164
    cases = 0
    for C in (1, 2, 7, 64):
        for N in (0, 1, 11):
            for D in range(1, min(2, C)+1):
                for length in (0, 1, 999, 1000, INT_MAX):
                    lengths = [length]*C
                    open_result = evaluate(lengths, N, D)
                    assert open_result["conditional_direct_totals"] is None
                    for I in (0, 1, 31):
                        result = evaluate(lengths, N, D, I)
                        d = result["derived"]
                        assert d["R"] == 164*C+16*D+8
                        assert d["H_constant"] == 2*d["V"]+5*C+4*N+5
                        assert result["identities"]["DECL_UID"] == 2*C+N+3*D+5
                        assert result["identities"]["type_UID"] == 6*C+5*D+3
                        t = result["conditional_direct_totals"]
                        b = open_result["symbolic_direct_totals"]
                        assert t["GGC_events"] == b["GGC_events"]["constant"]+I
                        assert t["caller_bytes"] == b["caller_bytes"]["constant"]+32*I
                        assert t["rounded_slot_bytes"] >= t["caller_bytes"]
                        assert result["ordinary_literal_scratch"]["requests"] == C*(length >= 1000)
                        assert result["ordinary_literal_scratch"]["caller_bytes"] == C*length*(length >= 1000)
                        strings = [x for x in result["rows"] if x["family"].startswith("STRING_CST_")]
                        assert sum(x["caller_bytes_each"] for x in strings) == C*(length+21)
                        assert result["exclusions"] == EXCLUDED
                        assert result["shared_demands"]["scalar_finalizer_vector_pushes"] == 1
                        assert not result["complete_original_gigi_storage_closed"]
                        assert not result["whole_toolchain_capacity_established"]
                        assert not result["production_admission_changed"]
                        cases += 1
    mixed = evaluate([0, 999, 1000, INT_MAX], 3, 2, 7)
    assert mixed["ordinary_literal_scratch"]["requests"] == 2
    assert mixed["ordinary_literal_scratch"]["largest_alloca_bytes"] == 999
    # Distinct signatures, not repeated calls, control these fixed terms.
    one = evaluate([0]*5, D=1)
    two = evaluate([0]*5, D=2)
    assert two["derived"]["K"] - one["derived"]["K"] == 4
    assert two["derived"]["R"] - one["derived"]["R"] == 16
    invalid = [([], 0, 1, None), ([0], -1, 1, None), ([0], 0, 2, None),
               ([-1], 0, 1, None), ([INT_MAX+1], 0, 1, None),
               ([0], 0, 1, -1)]
    for lengths, n, d, i in invalid:
        try:
            evaluate(lengths, n, d, i)
        except AssertionError:
            pass
        else:
            raise AssertionError("invalid input accepted")
    report = {
        "status": "passed", "checked_file_identities": len(manifest["files"]),
        "arithmetic_cases": cases, "invalid_cases": len(invalid),
        "elapsed_seconds": time.monotonic()-start,
        "validation": "offline identity and arithmetic checks; no compiler or prover",
        "independent_source_review": "pending",
        "model_selected": "GPT-6 Astra", "effort_selected": "Extra High",
        "runtime_setting_confirmation": None, "tokens": None, "cost": None,
        "whole_toolchain_capacity_established": False,
    }
    raw = json.dumps(report, indent=2, sort_keys=True)+"\n"
    if args.output:
        args.output.write_text(raw)
    print(raw, end="")


if __name__ == "__main__":
    main()
