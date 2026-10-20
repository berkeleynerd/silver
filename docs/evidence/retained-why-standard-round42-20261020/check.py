#!/usr/bin/env python3
"""Reconcile reviewed component freezes and interfaces, without replay."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def read(name):
    return json.loads((ROOT / name).read_text())


def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])


def retained_inputs(value, retained):
    if not isinstance(value, dict):
        return
    for key, item in value.items():
        if key.startswith("docs/") and isinstance(item, dict):
            candidate = item.get("identity", item)
            if "bytes" in candidate and "sha256" in candidate:
                expected = {k: candidate[k] for k in ("bytes", "sha256")}
                assert key not in retained or retained[key] == expected, key
                retained[key] = expected
        retained_inputs(item, retained)


def check():
    inputs = read(str(HERE.relative_to(ROOT) / "inputs.json"))
    files = []
    for component, commit in inputs["freezes"].items():
        names = git("diff-tree", "--no-commit-id", "--name-only", "-r", commit)
        for name in names.decode().splitlines():
            expected = identity(git("show", f"{commit}:{name}"))
            actual = identity((ROOT / name).read_bytes())
            assert expected == actual, (component, name)
            files.append({"component": component, "freeze": commit,
                          "path": name, **actual})
    retained = {}
    for manifest in inputs["component_manifests"]:
        retained_inputs(read(manifest), retained)
    for name, expected in retained.items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    native = read("docs/evidence/retained-literal-native-completion-20261019/inputs.json")
    for row in native["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            key: row[key] for key in ("bytes", "sha256")}, row["path"]

    backtrace = read("docs/evidence/retained-why-disabled-backtrace-20261020/result.json")
    assert backtrace["inactive_at_cuts_and_selected_suffix_under_named_relation"] is True
    assert backtrace["asynchronous_Failure_fallback_included"] is True
    assert backtrace["returned_string_lengths"] == [0, 59]
    assert backtrace["raw_string_direct_object_request_bytes_upper"] == 16 + 1040 + 40 + 16 == 1112
    assert backtrace["raw_print_direct_object_request_bytes_upper"] == 16 + 40 + 24 == 80
    assert backtrace["per_active_diagnostic_native_projection_with_bridge_bytes"] == 912 + 4104 == 5016
    assert backtrace["global_postcut_saves_upper"] == 3
    assert backtrace["global_postcut_signals_upper"] == 2
    assert backtrace["whole_suffix_report_count"] is None
    for key in ("complete_exit_capacity", "complete_process_stack", "complete_save_capacity"):
        assert backtrace[key] is False, key

    initial = read("docs/evidence/retained-why-standard-initial-state-20261020/result.json")
    assert initial["source_composition"]["constructor_dynamic_state_preserved_at_all_five_cuts"] is True
    assert initial["source_composition"]["complete_selected_standard_mutator_partition"] is True
    state = initial["constructor_state_template"]
    assert (state["left_total"], state["right_total"], state["curr_depth"]) == (1, 1, 1)
    assert (state["space_left"], state["current_indent"], state["margin"], state["max_indent"]) == (78, 0, 78, 68)
    assert state["queue"]["length"] == state["queue"]["cell_count"] == 1
    assert state["queue"]["first_is_last"] is True
    assert state["queue"]["last_next"] == "Nil"
    assert state["queue"]["token"] == {
        "kind": "Pp_begin", "indent": 0, "box_type": "Pp_hovbox",
        "size": "Size.unknown", "length": 0}
    assert state["scan_stack"]["length"] == 2
    assert state["scan_stack"]["top_to_bottom"][0]["queue_elem"] == "same system token as queue cell content"
    assert state["scan_stack"]["top_to_bottom"][1]["sentinel_in_queue"] is False
    for key in ("format_stack", "tbox_stack", "tag_stack", "mark_stack"):
        assert state[key] == {"length": 0, "entries": []}, key
    assert initial["callbacks"]["stdout"]["newline_wrapper_depth"] == 0
    assert initial["callbacks"]["stderr"]["newline_wrapper_depth"] == 1
    assert [case["case"] for case in initial["cases"]] == backtrace["cases"]
    backtrace_cases = {case["case"]: case for case in read(
        "docs/evidence/retained-why-disabled-backtrace-20261020/input-attachment.json")}
    for case in initial["cases"]:
        for key in ("pid", "cut_symbol", "cut_elf_relative_pc"):
            assert case[key] == backtrace_cases[case["case"]][key], (case["case"], key)
        assert case["conditional_source_constructor_state"] is True
        assert case["source_states_distinct"] is True
        assert case["state_instances"] == ["stdout", "stderr"]
        assert case["standard_root_pointer_reads"] == {"stdout": 0, "stderr": 0}
    for key in ("observed_raw_standard_graphs", "suffix_constructor_freshness",
                "suffix_no_SIGINT", "uncontrolled_production_prefix_claim", "global_budget_reset",
                "complete_formatter_capacity", "complete_exit_capacity", "complete_save_capacity"):
        assert initial[key] is False, key

    core = read("docs/evidence/retained-why-standard-formatter-core-20261020/result.json")
    assert core["initial_state_established_by_this_packet"] is False
    assert core["actual_retained_case_B_E"] is None
    assert core["actual_joined_core_bounds"] is None
    for example in core["arithmetic"]["examples"]:
        b, e = example["B"], example["E"]
        interface = example["interface"]
        candidate = interface["candidate"]
        assert candidate["aggregate_roots"] == 2
        assert candidate["I"] == 3 * e + 2
        assert candidate["L"] == b + e
        assert candidate["T"] == 1000000010 + b + e + 1
        assert candidate["S"] == (3 * e + 1) * candidate["T"]
        assert candidate["core_new_requested_ocaml_bytes_upper"] == 640 * (3 * e + 2)
        assert candidate["offered_standard_channel_bytes_upper"] == b + 70 * (e + 2)
        assert candidate["channel_output_or_flush_invocations_upper"] == 6 * (e + 2)
        assert interface["joined_core_bounds"] is None
    entry_join = {
        "scope": "Two distinct default standard formatter states at the five retained controlled cuts, under the accepted named source/runtime relation.",
        "core_initial_state_premise_discharged_under_named_relation": True,
        "cases": initial["cases"],
        "prospective_whole_interval_B_E": None,
        "actual_joined_core_bounds": None,
        "native_stack_join": None,
        "remaining_obligations": ["whole-interval prospective event/text budgets and arithmetic guards",
                                  "caller/scalar/annotation/diagnostic owners",
                                  "global channel/offset, ambient and service resources",
                                  "complete stack and physical sufficiency"],
        "signal_save_budget_reset": False,
        "uncontrolled_production_prefix_claim": False}

    meta = read("docs/evidence/retained-why-model-meta-control-20261020/result.json")
    assert meta["accepted_source_argument_reused"] is True
    assert meta["model_diagnostic_excluded_by_task_meta_under_named_relation"] is True
    assert meta["selected_call_provers_model_parser_invocations_upper"] == 0
    assert meta["get_model_for_selected_saved_calls"] == "None"
    assert meta["new_native_meta_name_observation"] is False
    assert meta["other_diagnostics_excluded"] is False
    assert meta["whole_output_capacity"] is None
    meta_cases = read("docs/evidence/retained-why-model-meta-control-20261020/attachment.json")["cases"]
    assert {case["case"] for case in meta_cases} == set(backtrace_cases)
    for case in meta_cases:
        for key in ("pid", "cut_symbol"):
            assert case[key] == backtrace_cases[case["case"]][key], (case["case"], key)

    parsed, links = [], []
    names = {row["path"] for row in files} | {str(Path(__file__).resolve().relative_to(ROOT))}
    for name in sorted(names):
        path = ROOT / name
        if path.suffix == ".py":
            ast.parse(path.read_text(), filename=name)
            parsed.append(name)
        if path.suffix == ".md":
            for url in re.findall(r"\]\(([^)]+)\)", path.read_text()):
                if "://" in url or url.startswith("#"):
                    continue
                target = url.split("#")[0]
                assert (path.parent / target).exists(), (name, target)
                links.append({"file": name, "target": target})
    return {"frozen_files": files, "retained_repository_inputs": retained,
            "native_pins_unchanged": len(native["repository"]),
            "disabled_backtrace_interface": backtrace,
            "standard_entry_to_interrupted_core_join": entry_join,
            "conditional_core_examples": core["arithmetic"]["examples"],
            "reused_model_meta_interface": meta,
            "python_sources_parsed": parsed, "local_document_links": links,
            "target_runs": 0, "predecessor_checker_replays": 0,
            "complete_save_exit_capacity": False, "whole_pipeline_capacity": False}


if __name__ == "__main__":
    start = time.monotonic()
    result = check()
    output = HERE / "integration-result.json"
    if output.exists():
        assert result == json.loads(output.read_text())
    else:
        output.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"status": "pass", "frozen_files": len(result["frozen_files"]),
                      "retained_inputs": len(result["retained_repository_inputs"]),
                      "native_pins_unchanged": result["native_pins_unchanged"],
                      "python_parses": len(result["python_sources_parsed"]),
                      "local_links": len(result["local_document_links"]),
                      "seconds": time.monotonic() - start}))
