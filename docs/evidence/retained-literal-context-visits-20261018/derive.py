#!/usr/bin/env python3
"""Conditional fixed context input for the frozen original Main transfer."""
import hashlib
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
MAIN = "docs/evidence/retained-literal-original-main-storage-20261018/derive.py"
RUNTIME_UNITS = 36
SEMANTIC_UNITS = 39
IMPLICIT_WITH_VISITS = RUNTIME_UNITS + 2*SEMANTIC_UNITS


def evaluate():
    return {
        "runtime_implicit_with_visits": RUNTIME_UNITS,
        "new_elaboration_implicit_with_visits": SEMANTIC_UNITS,
        "old_elaboration_implicit_with_visits": SEMANTIC_UNITS,
        "I_upper_bound": IMPLICIT_WITH_VISITS,
        "additional_statement_list_GGC_requests": IMPLICIT_WITH_VISITS,
        "additional_caller_bytes": 32*IMPLICIT_WITH_VISITS,
        "additional_rounded_slot_bytes": 32*IMPLICIT_WITH_VISITS,
        "additional_stmt_list_cache_pushes": IMPLICIT_WITH_VISITS,
        "pool_demands": {"insertions": 0, "lookups": 0, "replacements": 0},
        "fixed_context_input_closed_under_selected_premises": True,
        "premises": ["accepted literal source family and successful native behavior",
                     "existing selected 36-runtime/39-semantic-unit source closure",
                     "no Main generic/child/subunit/separate-spec context copy",
                     "frozen source/installed-behavior correspondence"],
        "complete_frontend_storage_closed": False,
        "complete_original_gigi_storage_closed": False,
        "whole_toolchain_capacity_established": False,
        "production_admission_changed": False,
        "independent_review_pending": True,
    }


def load_main():
    manifest = json.loads((HERE / "inputs.json").read_text())
    row = next(x for x in manifest["repository_inputs"] if x["path"] == MAIN)
    raw = (REPO / MAIN).read_bytes()
    if hashlib.sha256(raw).hexdigest() != row["sha256"]:
        raise ValueError("frozen original Main callable changed")
    spec = importlib.util.spec_from_file_location("frozen_original_main", REPO / MAIN)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def attach_main(lengths, N=0, D=1):
    result = load_main().evaluate(lengths, N, D,
                                  implicit_with_visits=IMPLICIT_WITH_VISITS)
    return {"context_input": evaluate(), "original_Main": result}


if __name__ == "__main__":
    print(json.dumps(attach_main([13]), indent=2, sort_keys=True))
