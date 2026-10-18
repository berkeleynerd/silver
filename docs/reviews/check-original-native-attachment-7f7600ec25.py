#!/usr/bin/env python3
"""Focused attachment review; does not construct the broad aggregate Context."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import runpy
import subprocess
import sys
import time
from types import SimpleNamespace

REPO = Path(__file__).resolve().parents[2]
EVIDENCE = REPO / "docs/evidence"
PACKET = EVIDENCE / "retained-literal-pipeline-20261018"
FREEZE = "7f7600ec25f992e392c6b3fe58db744630457ecf"


def read(path):
    return json.loads(path.read_text())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--gcc-root", type=Path, required=True)
    parser.add_argument("--ada-root", type=Path, required=True)
    parser.add_argument("--gcc-match", type=Path, required=True)
    args = parser.parse_args()
    sys.dont_write_bytecode = True
    started = time.monotonic()
    for name in ("compose.py", "inputs.json", "result.json", "check-results.json"):
        path = PACKET / name
        assert path.read_bytes() == subprocess.check_output(
            ["git", "show", f"{FREEZE}:{path.relative_to(REPO)}"], cwd=REPO)
    prior = json.loads(subprocess.check_output(
        ["git", "show", f"{FREEZE}^:{(PACKET / 'inputs.json').relative_to(REPO)}"], cwd=REPO))
    pins = read(PACKET / "inputs.json")
    assert pins[:len(prior)] == prior
    for row in pins[len(prior):]:
        raw = (REPO / row["path"]).read_bytes()
        assert len(raw) == row["bytes"]
        assert hashlib.sha256(raw).hexdigest() == row["sha256"]
    aggregate = runpy.run_path(str(PACKET / "compose.py"))
    context = SimpleNamespace()
    for label, directory, expected in (
        ("original_string", "retained-literal-string-layout-storage-20261018", "interface.json"),
        ("original_main", "retained-literal-original-main-storage-20261018", "result.json"),
        ("context_visits", "retained-literal-context-visits-20261018", "result.json")):
        setattr(context, label, runpy.run_path(str(EVIDENCE / directory / "derive.py")))
        setattr(context, label + "_expected", read(EVIDENCE / directory / expected))
    context.original_string_audit = read(EVIDENCE /
        "retained-literal-string-layout-storage-20261018/fold-audit.json")
    main_manifest = read(EVIDENCE / "retained-literal-original-main-storage-20261018/inputs.json")
    historical = next(row for row in main_manifest["files"]
                      if row["path"] == "docs/research/retained-literal-pipeline.md")
    history_bytes = aggregate["read_historical_repository_file"](
        main_manifest["repository_base"], historical["path"])
    assert len(history_bytes) == historical["bytes"] == 118976
    assert hashlib.sha256(history_bytes).hexdigest() == historical["sha256"]
    assert history_bytes != (REPO / historical["path"]).read_bytes()
    current = aggregate["verify_original_storage_sources"](
        main_manifest, "Main", args.gcc_root, args.ada_root, args.gcc_match)
    assert len(main_manifest["files"]) == 46 and len(current) == 45
    assert str(REPO / historical["path"]) not in current
    assert len({(row["root"], row["path"]) for row in main_manifest["files"]}) == 46

    rejected = []
    def reject(label, operation, expected):
        try:
            operation()
        except ValueError as error:
            assert str(error) == expected, (label, str(error))
            rejected.append(label)
        else:
            raise AssertionError("accepted " + label)

    verify = aggregate["verify_original_storage_sources"]
    saved = verify.__globals__["read_historical_repository_file"]
    verify.__globals__["read_historical_repository_file"] = lambda revision, path: b"wrong historical bytes"
    try:
        reject("historical_object_mismatch", lambda: verify(main_manifest, "Main",
               args.gcc_root, args.ada_root, args.gcc_match),
               "literal original Main complete source join: " + historical["path"])
    finally:
        verify.__globals__["read_historical_repository_file"] = saved

    recorded = read(PACKET / "result.json")
    helper = recorded["native_original_helper_storage"]
    helper_leaf = runpy.run_path(str(EVIDENCE /
        "retained-literal-original-string-storage-20261018/derive.py"))
    assert helper["interface"] == helper_leaf["evaluate"]()
    assert helper["evaluated_requests"] == helper_leaf["evaluate_at"](
        helper["name_input"]["local_cleaned_component_bound"])
    string = aggregate["native_original_string_storage"](context, helper)
    assert string == recorded["native_original_String_storage"]
    assert string["cold_String_including_helpers"]["GGC_events"] == 216 + 94 == 310
    assert string["synthetic173_additions"] == string["null_helper11_additions"] == 0
    synthetic = recorded["native_synthetic_function_storage"]
    assert synthetic["GGC_events"] == 173
    recognizer = runpy.run_path(str(EVIDENCE /
        "unbounded-programs/retained-native-expansion-20261017/derive-literal-output.py"))
    cases = [([("Put_Line", b'Put -- "Silver_IO.Put"')], 2),
             ([("Put", b"Put_Line"), ("Put", b"")], 3),
             ([("Put", b"same"), ("Put_Line", b"same")], 0),
             ([("Put_Line", b'"'), ("Put", b"x"*999), ("Put_Line", b"y"*1000)], 1)]
    for calls, nulls in cases:
        raw = b"WITH Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\r\n"
        for name, literal in calls:
            raw += b"Silver_IO." + name.encode() + b' ("' + literal.replace(b'"', b'""') + b'");\r\n'
        raw += b"null;\r\n"*nulls + b"-- Put_Line ignored\r\nend Main;"
        counts = recognizer["source_counts"](raw)
        c, d = len(calls), len({name for name, _ in calls})
        lengths = [len(literal) for _, literal in calls]
        assert counts["decoded_literal_lengths"] == lengths
        # Explicit accepted frontend interface fixture, not a full frontend replay.
        frontend = {"selected_source": counts,
                    "gigi_source_interface": {"Main_source_syntax_visit_bound": 73+81*c+4*nulls}}
        attached = aggregate["native_original_main_storage"](counts, frontend, context)
        leaf = attached["interface"]
        assert leaf == context.original_main["evaluate"](lengths, nulls, d, 114)
        assert leaf["conditional_direct_totals"]["GGC_events"] == 609*c+24*nulls+54*d+398
        assert attached["shared_container_demands"] == leaf["shared_demands"]
        assert attached["identity_demands"] == leaf["identities"]
        assert attached["evaluated_stmt_list_cache_pushes_upper"] == 265+167*c+12*nulls
        assert leaf["ordinary_literal_scratch"]["caller_bytes"] == sum(x for x in lengths if x >= 1000)
        bad_frontend = copy.deepcopy(frontend)
        bad_frontend["gigi_source_interface"]["Main_source_syntax_visit_bound"] += 1
        reject("frontend_V_mismatch", lambda: aggregate["native_original_main_storage"](
               counts, bad_frontend, context), "literal original Main storage interface join")
        for fits in (True, False):
            pools = copy.deepcopy(recorded["native_pool_lifetime"])
            pools["conditional_arithmetic_fits"] = fits
            aggregate["attach_original_tree_pool_frontier"](pools, string, attached, helper, synthetic)
            assert pools["named_consumer_closed"] is fits
            assert not pools["imported_constructor_frontier_established"]
            assert pools["source_input"]["pool_entries_upper"] == 2
            assert pools["tree_pool"]["replacement_requests_upper"] == 3
    forged = copy.deepcopy(attached)
    forged["interface"]["original_tree_constant_pool_demands"]["lookups"] = 1
    reject("nonzero_unowned_pool_lookup", lambda: aggregate["attach_original_tree_pool_frontier"](
        {}, string, forged, helper, synthetic), "literal original imported tree-pool zero-demand join")
    expected_unknown = ["Main_assembler_object_interface", "Main_GAS_BFD_storage",
                        "literal_output_linker_representation"]
    assert recorded["unresolved_predicates"] == expected_unknown
    assert all(recorded["conditions"][key] is None for key in expected_unknown)
    for key in ("complete_global_counter_lifetime_closed", "complete_collector_lifetime_closed"):
        assert recorded["native_unit_frontier"][key] is False
    assert recorded["native_unit_frontier"]["complete_imported_allocation_events"] is None
    assert not recorded["whole_literal_pipeline_capacity_established"]
    checks = read(PACKET / "check-results.json")
    assert checks["all_checks_pass"] and checks["case_count"] == len(checks["cases"]) == 253
    large = next(row for row in checks["cases"] if row.get("case") == "5000_calls")
    assert large["failed_conditional_predicates"] == ["literal_output_linker_representation"]
    assert large["unresolved_predicates"] == expected_unknown and not large["whole_pipeline_closed"]
    print(json.dumps({"status": "passed", "freeze": FREEZE,
        "new_repository_pins": len(pins)-len(prior), "earlier_pin_prefix_unchanged": True,
        "Main_inventory": 46, "Main_current_files": 45, "Main_historical_files": 1,
        "historical_revision": main_manifest["repository_base"],
        "source_adapter_cases": len(cases), "targeted_rejections": rejected,
        "retained_253_case_success_replayed": False, "native_execution": False,
        "elapsed_seconds": time.monotonic()-started}, indent=2))


if __name__ == "__main__":
    main()
