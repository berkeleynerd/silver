#!/usr/bin/env python3
"""Reconcile accepted R57 freezes and compose direct storage; no component replay."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CACHE = {}


def identity(path):
    if path not in CACHE:
        raw = path.read_bytes()
        CACHE[path] = {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}
    return CACHE[path]


def read(name):
    return json.loads((ROOT / name).read_text())


def check():
    manifest = json.loads((HERE / "inputs.json").read_text())
    assert not manifest["review_freeze_pending"]
    assert set(manifest["components"]) == {"server_owned_storage", "shared_prefix", "returned_storage", "review"}
    frozen, retained = [], {}
    for component, row in manifest["components"].items():
        for name in row["paths"]:
            raw = subprocess.check_output(["git", "-C", str(ROOT), "show", row["freeze"] + ":" + name])
            expected = {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}
            assert identity(ROOT / name) == expected, name
            frozen.append(dict(component=component, path=name, **expected))

    def record(name, expected, folder):
        if ":" in name or name.startswith("/"):
            return
        path = ROOT / name if name.startswith("docs/") else folder / name
        if not path.is_file():
            assert not name.startswith("docs/"), "missing repository input: " + name
            return  # Archive members/symbols are not repository-path identities.
        actual = identity(path)
        if isinstance(expected, str):
            assert actual["sha256"] == expected, str(path)
        else:
            assert actual == {k: expected[k] for k in ["bytes", "sha256"]}, str(path)
        retained[str(path.relative_to(ROOT))] = actual

    def collect(value, folder):
        if isinstance(value, list):
            for child in value:
                collect(child, folder)
        elif isinstance(value, dict):
            for key, child in value.items():
                if isinstance(child, str) and re.fullmatch("[0-9a-f]{64}", child):
                    record(key, child, folder)
                if isinstance(child, dict):
                    expected = child.get("identity", child)
                    if "bytes" in expected and "sha256" in expected:
                        record(key, expected, folder)
                collect(child, folder)
            name = value.get("path", "")
            expected = value.get("identity", value)
            if name and "bytes" in expected and "sha256" in expected:
                record(name, expected, folder)

    for name in manifest["component_manifests"]:
        collect(read(name), (ROOT / name).parent)
    native = read("docs/evidence/retained-literal-native-completion-20261019/inputs.json")
    for row in native["repository"]:
        assert identity(ROOT / row["path"]) == {k: row[k] for k in ["bytes", "sha256"]}
    prefix_inputs = read("docs/evidence/retained-shared-server-prefix-20261020/inputs.json")
    assert identity(Path(prefix_inputs["why_binary"]["path"])) == prefix_inputs["why_binary"]["identity"]
    server_native = read("docs/evidence/retained-server-owned-storage-20261020/native-inputs.json")["inputs"]
    for row in server_native:
        assert identity(Path(row["path"])) == {k: row[k] for k in ["bytes", "sha256"]}
    review = read("docs/evidence/retained-returned-server-storage-review-20261020/round.json")
    checks = review["first_focused_checks"]
    for key in ["server_owned_storage", "shared_prefix", "returned_storage"]:
        component = manifest["components"][key]
        assert checks[key]["author_freeze"] == component.get("first_focused_check_freeze", component["freeze"])
        assert review["accepted_author_freezes"][key] == component["freeze"]
        record_name = "docs/evidence/retained-returned-server-storage-review-20261020/" + checks[key]["record"]
        check_record = read(record_name)
        assert check_record["exit_code"] == 0 and check_record["author_packet_unchanged"]
        assert check_record["author_freeze"] == checks[key]["author_freeze"]
        assert check_record["result"] == checks[key]["result"]
        if "status" in check_record["result"]:
            assert check_record["result"]["status"].lower() == "pass"
    assert review["successful_focused_checker_replays"] == review["predecessor_checker_replays"] == 0

    server = read("docs/evidence/retained-server-owned-storage-20261020/projection.json")
    operands = read("docs/evidence/retained-solver-request-bytes-20261020/projection.json")
    endpoint = read("docs/evidence/retained-shared-server-prefix-20261020/endpoints.json")
    assert len(endpoint) == 5 and len({x["socket"] for x in endpoint}) == 5
    assert server["total_run_entries"] == 459
    assert server["selected_parallel_control_lines"] == 0
    assert server["no_new_request_ID_copy"] and server["no_new_send_buffer_copy"]
    assert server["complete_q"] is None and not server["production_adopted"]
    assert server["remaining_library_allocation_summands"] and server["remaining_distinct_owners"]
    assert server["backend_response_allocated_C_constant"] == 23628
    assert server["backend_response_allocated_C_coefficient"] == 459
    n = sum(v["N"] for v in operands["domains"].values())
    quiet = sum(v["N"] * v["profiles"]["quiet"]["L_d"]["constant"] for v in operands["domains"].values())
    assert all(v["profiles"]["quiet"]["m_d"] == 14 for v in operands["domains"].values())
    assert n == 459 and quiet == 125823
    # Direct C requested-object terms only: parser, parent argv, ring,
    # response, fixed records/list/poll and process/path owners, each once.
    constant = n*8*14 + 57714 + 8*n*16 + 41536 + 23628 + 1016 + n*36
    assert constant == 250578 and constant + quiet == 376401
    c_coefficient = n + server["backend_response_allocated_C_coefficient"]
    assert c_coefficient == 918

    returned = read("docs/evidence/retained-why-returned-storage-20261020/result.json")
    assert returned["original_context_keys"] == 1238
    assert returned["complete_returned_storage_under_named_source_and_mutation_premises"]
    assert returned["conservative_validator_traversals_per_context_declaration"] == 32
    assert sum(returned["source_productive_sweeps_per_episode"].values()) == 16
    assert sum(row["registered_roots"] for row in returned["domains"]) == 118
    assert sum(row["original_context_keys"] for row in returned["domains"]) == 1238
    for row in returned["domains"]:
        e = row["shared_process_escape_upper"]
        assert e == 2
        k = 6 + 16 * (3 * row["registered_roots"] + e) * 64
        assert k == row["returned_map_entries_upper"]
        assert 99 * (1 + k) == row["returned_stored_occurrences_upper"]
    assert max(row["returned_stored_occurrences_upper"] for row in returned["domains"]) == 15713973
    assert returned["episodes"]["escape_is_process_global"]
    assert not returned["episodes"]["fresh_stage_escape_allowance"]
    assert all(value < 2**62 for value in returned["all_five_processes"].values())
    assert returned["remaining"]["whole_quiet_capacity"]
    assert returned["remaining"]["later_stage_and_printer_total_work"]

    parsed, links = [], []
    for name in sorted({x["path"] for x in frozen} | {str(Path(__file__).relative_to(ROOT))}):
        path = ROOT / name
        if path.suffix == ".py":
            ast.parse(path.read_text(), filename=name)
            parsed.append(name)
        elif path.suffix == ".md":
            for url in re.findall(r"\]\(([^)]+)\)", path.read_text()):
                if "://" in url or url.startswith("#"):
                    continue
                target = url.split("#")[0]
                assert (path.parent / target).exists(), (name, target)
                links.append({"file": name, "target": target})
    return {"frozen_files": frozen, "retained_repository_inputs": retained,
            "native_source_pins_unchanged": len(native["repository"]),
            "installed_why_binary_unchanged": True,
            "unchanged_server_native_inputs": len(server_native),
            "review_first_check_subprocess_seconds": sum(row["elapsed_seconds"] for row in checks.values()),
            "python_parses": parsed, "local_links": links,
            "quiet_direct_server_requested_objects": {
                "formula": "459*A + sum_d N_d*tau_d + sum_d 2*R(M_d) + 918*C + 376401",
                "adapter_path_coefficient": n, "server_cwd_coefficient": c_coefficient,
                "constant_bytes": constant + quiet,
                "includes_direct_process_records": True,
                "includes_library_allocator_kernel_child_proxy_why_raw_output": False},
            "shared_prefix_scope": "exact client-facing paths/cwd/inputs; successful peer substitution",
            "returned_context_keys": 1238,
            "returned_context_stored_occurrences_max": 15713973,
            "validator_support_scope": "first inline only; 32 units per context key per invocation",
            "physical_allocator_kernel_internals_proof_required": False,
            "actual_launcher_attached": False, "complete_q": None,
            "whole_capacity_rule_delivered": False, "component_checker_replays": 0,
            "native_target_solver_proof_capture_runs": 0}


if __name__ == "__main__":
    start = time.perf_counter()
    result = check()
    result.update(status="pass", elapsed_seconds=time.perf_counter() - start)
    print(json.dumps(result, indent=2, sort_keys=True))
