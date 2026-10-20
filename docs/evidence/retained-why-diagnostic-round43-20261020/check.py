#!/usr/bin/env python3
"""Reconcile reviewed diagnostic interfaces; do not replay component checks."""
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


def collect(value, retained):
    if isinstance(value, list):
        for item in value:
            collect(item, retained)
        return
    if not isinstance(value, dict):
        return
    if isinstance(value.get("path"), str) and value["path"].startswith("docs/"):
        candidate = value.get("identity", value)
        if "bytes" in candidate and "sha256" in candidate:
            expected = {k: candidate[k] for k in ("bytes", "sha256")}
            name = value["path"]
            assert name not in retained or retained[name] == expected, name
            retained[name] = expected
    for key, item in value.items():
        if key.startswith("docs/") and isinstance(item, dict):
            candidate = item.get("identity", item)
            if "bytes" in candidate and "sha256" in candidate:
                expected = {k: candidate[k] for k in ("bytes", "sha256")}
                assert key not in retained or retained[key] == expected, key
                retained[key] = expected
        if key != "path":
            collect(item, retained)


def check():
    inputs = json.loads((HERE / "inputs.json").read_text())
    files, retained = [], {}
    for component, commit in inputs["freezes"].items():
        base = inputs.get("range_bases", {}).get(component)
        paths = (git("diff", "--name-only", base, commit) if base else
                 git("diff-tree", "--no-commit-id", "--name-only", "-r", commit))
        for name in paths.decode().splitlines():
            expected = identity(git("show", f"{commit}:{name}"))
            assert identity((ROOT / name).read_bytes()) == expected, name
            files.append({"component": component, "freeze": commit,
                          "path": name, **expected})
    for manifest in inputs["component_manifests"]:
        collect(read(manifest), retained)
    for name, expected in retained.items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    native = read("docs/evidence/retained-literal-native-completion-20261019/inputs.json")
    for row in native["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            k: row[k] for k in ("bytes", "sha256")}, row["path"]

    occurrences = read("docs/evidence/retained-why-diagnostic-occurrences-20261020/result.json")
    backtrace = read("docs/evidence/retained-why-disabled-backtrace-20261020/result.json")
    attachment = read("docs/evidence/retained-why-disabled-backtrace-20261020/input-attachment.json")
    joined = []
    for row, state in zip(occurrences["cases"], attachment, strict=True):
        assert (row["case"], row["pid"]) == (state["case"], state["pid"])
        c = row["under_named_existing_relation"]
        a = c["scheduling_owners_upper"]
        assert c["outer_exn_printer_calls_upper"] == 2*a+2
        assert c["outer_printexc_to_string_calls_upper"] == 2
        assert c["normal_json_invocations_upper"] == 1
        assert c["abort_json_invocations_upper"] == 2
        n, m, d = (c[k] for k in ("n_raw_string_invocations_upper",
                   "m_raw_print_invocations_upper", "d_simultaneous_covered_raw_invocations_upper"))
        assert (n, m, d) == (1, 4, 1)
        requests = n*backtrace["raw_string_direct_object_request_bytes_upper"] + m*backtrace["raw_print_direct_object_request_bytes_upper"]
        offered = m*backtrace["print_direct_requested_bytes_upper"]
        stack = d*backtrace["per_active_diagnostic_native_projection_with_bridge_bytes"]
        assert requests == c["backtrace_direct_object_requests_bytes_upper"] == 1432
        assert offered == c["backtrace_direct_channel_bytes_upper"] == 236
        assert stack == c["backtrace_active_native_projection_bytes_upper"] == 5016
        joined.append({"case": row["case"], "pid": row["pid"],
                       "direct_backtrace_requests_bytes": requests,
                       "offered_backtrace_channel_bytes": offered,
                       "active_backtrace_projection_bytes": stack,
                       "normal_json_calls_upper": 1, "abort_json_calls_upper": 2})
    for key in ("recursive_wrapper_depth", "recursive_registry_delegation_factors",
                "all_inner_exception_printer_invocations", "actual_standard_core_B_E",
                "all_diagnostic_payload_bytes"):
        assert occurrences[key] is None, key
    for key in ("complete_diagnostic_capacity_established", "complete_process_stack_established",
                "complete_save_or_exit_capacity_established", "physical_sufficiency_established"):
        assert occurrences[key] is False, key

    schema = read("docs/evidence/retained-why-standard-json-inputs-20261020/result.json")
    transfer = read("docs/evidence/retained-why-standard-json-inputs-20261020/transfer.json")
    expansion = read("docs/evidence/retained-why-diagnostic-expansion-20261020/result.json")
    imported = ROOT / "docs/evidence/retained-why-diagnostic-expansion-20261020/outer-occurrences-import.json"
    assert imported.read_bytes() == (ROOT / "docs/evidence/retained-why-diagnostic-occurrences-20261020/result.json").read_bytes()
    assert schema["normal_JSON_calls_upper"] == 1
    assert schema["abort_JSON_calls_upper"] == 2
    for key in ("actual_whole_JSON_B", "actual_whole_JSON_E", "actual_whole_standard_B",
                "actual_whole_standard_E", "actual_noncore_total"):
        assert schema[key] is None, key
    for key in ("complete_R", "complete_U", "complete_native_caller_stack",
                "physical_sufficiency", "whole_pipeline_capacity"):
        assert schema[key] is False, key
    assert expansion["wrapper_depth_upper_under_named_relation"] == 3+2+1+1 == 7
    per = expansion["per_outer_diagnostic_under_named_relation"]
    assert per["same_exception_dispatch_packages_upper"] == 2**8-1 == 255
    assert per["why_registry_passes_upper"] == 2*255 == 510
    assert per["why_callback_attempts_upper"] == 55*510
    assert per["printexc_callback_attempts_upper"] == 5*255
    assert expansion["actual_private_diagnostic_B_E"] is None
    assert expansion["actual_standard_core_B_E"] is None
    assert expansion["complete_save_or_exit_capacity_established"] is False
    assert expansion["whole_pipeline_capacity_established"] is False
    report_join = []
    for outer, j, x in zip(occurrences["cases"], transfer["cases"], expansion["cases"], strict=True):
        assert outer["pid"] == j["pid"] == x["pid"]
        assert outer["case"].lower() == j["case"] == x["case"]
        c = outer["under_named_existing_relation"]
        assert x["outer_calls_upper"] == c["combined_outer_report_calls_upper"]
        for key, factor in per.items():
            if key in x["conditional_dispatch_products"]:
                assert x["conditional_dispatch_products"][key] == factor*x["outer_calls_upper"]
        z = j["conditional_inputs"]
        assert z["N"] == c["scheduling_owners_upper"] == 3*z["G"]+2
        b = 14864+3732*z["R"]+189*z["G"]+873*z["A"]+3075*z["N"]+3*z["D"]+6*z["H"]+2*42
        e = 2313+753*z["R"]+73*z["G"]+194*z["A"]+1027*z["N"]+3*z["D"]+2*z["H"]+2*53
        assert j["all_JSON_attempts_coefficients"]["B"] == dict(constant=b,O=3111,W_o=3,L_o=6,X=6)
        assert j["all_JSON_attempts_coefficients"]["E"] == dict(constant=e,O=1039,W_o=3,L_o=2,X=2)
        assert j["actual_B"] is None and j["actual_E"] is None
        assert j["whole_standard_core_guards_established"] is False
        assert x["private_shell_count_standard_formula_probe_only"]["actual_standard_input_or_joined_result"] is False
        report_join.append({"case": j["case"], "pid": j["pid"],
                            "conditional_JSON_B_E": j["all_JSON_attempts_coefficients"],
                            "private_dispatch_products": x["conditional_dispatch_products"],
                            "private_dispatch_events_added_to_standard_E": False,
                            "actual_standard_B_E": None})

    channel = read("docs/evidence/retained-why-standard-channel-capacity-20261020/result.json")
    interface = read("docs/evidence/retained-why-standard-channel-capacity-20261020/interface.json")
    assert interface["X_format"] == "B + 70*(E+2)"
    assert interface["X_direct_stderr"] == "H_original + H_secondary + 371"
    assert interface["total_offered"] == "B + 70*(E+2) + H_original + H_secondary + 371"
    assert interface["direct_literal_and_newline_bytes"] == [24, 54, 57]
    assert interface["direct_raw_print_bytes_upper"] == 236
    assert sum(interface["direct_literal_and_newline_bytes"]) + 236 == interface["direct_stderr_constant_bytes_upper"] == 371
    assert interface["channel_buffer_bytes"] == interface["individual_syscall_requested_bytes_upper"] == 65536
    assert interface["signed_offset_interval"] == [-2**63, 2**63-1]
    assert interface["per_channel_guard"] == "represented O0; 0 <= P0 <= 65536; O0 + P0 + X <= 2^63-1"
    assert interface["prefix_invariant"] == ["0 <= P <= 65536", "0 <= F",
        "F + P <= P0 + A <= P0 + X", "O = O0 + F"]
    for key in ("actual_initial_channel_state_attached", "private_file_premise_extended",
                "positive_write_interface_attached_to_actual_standard_descriptors",
                "cached_offset_equals_kernel_position", "distinct_open_file_descriptions_required"):
        assert interface[key] is False, key
    assert interface["distinct_channel_records"] is True
    for key in ("all_syscall_attempts_upper", "all_syscall_requested_bytes_upper"):
        assert interface[key] is None, key
    for key in ("actual_standard_channel_state_attached", "actual_inherited_descriptor_positive_success_interface_attached",
                "complete_R_or_stack", "complete_channel_capacity", "complete_exit_or_save_capacity",
                "global_budgets_reset", "physical_sufficiency", "successful_delivery_established", "termination_established"):
        assert channel[key] is False, key
    assert channel["global_e_upper"] == channel["global_postcut_save_entering_callbacks_upper"] == 2
    assert channel["global_postcut_saves_upper"] == 3
    channel_join = []
    for report, row in zip(report_join, channel["cases"], strict=True):
        assert (report["case"], report["pid"]) == (row["case"], row["pid"])
        assert row["initial_standard_core_state"] is True
        assert row["flush_all_entries_upper_under_named_relation"] == 6
        for key in ("actual_B_E", "actual_H_original_H_secondary", "actual_offered_bytes",
                    "actual_offset_guards", "usable_standard_channel_bounds"):
            assert row[key] is None, key
        assert set(row["standard_channel_entry"]) == {"stdout", "stderr"}
        for state in row["standard_channel_entry"].values():
            assert state == dict(O0=None, P0=None, actual_buffer_alias_attachment=None,
                                 actual_descriptor_contract=None)
        channel_join.append({"case": row["case"], "pid": row["pid"],
            "conditional_offered_bytes": interface["total_offered"],
            "per_channel_guard": interface["per_channel_guard"],
            "actual_entry_and_payload_attachment": False,
            "usable_standard_channel_bounds": None})

    parsed, links = [], []
    names = {r["path"] for r in files} | {str(Path(__file__).resolve().relative_to(ROOT))}
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
            "backtrace_occurrence_join": joined,
            "report_and_dispatch_join": report_join,
            "conditional_channel_join": channel_join,
            "python_sources_parsed": parsed, "local_document_links": links,
            "target_runs": 0, "predecessor_checker_replays": 0,
            "actual_whole_interval_B_E": None,
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
