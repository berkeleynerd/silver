#!/usr/bin/env python3
"""Reconcile reviewed R58 inputs and additive storage; no component replay."""
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
    assert set(manifest["components"]) == {"server_libc_storage", "postinline_preparation", "review"}
    frozen, retained, context_successors = [], {}, {}
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
            return  # Not a repository file: archive member or symbol identity.
        actual = identity(path)
        if name in manifest.get("historical_context_successors", {}):
            successor = manifest["historical_context_successors"][name]
            raw = subprocess.check_output(["git", "-C", str(ROOT), "show", successor["freeze"] + ":" + name])
            historical = {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}
            assert historical == {k: expected[k] for k in ["bytes", "sha256"]}, name
            old = raw.decode()
            current = path.read_text()
            prefix = old.split(successor["old_summary_start"], 1)[0]
            assert prefix != old and current.startswith(prefix)
            anchor = successor["unchanged_suffix_start"]
            assert old.count(anchor) == current.count(anchor) == 1
            assert old.split(anchor, 1)[1] == current.split(anchor, 1)[1]
            context_successors[name] = {"reviewed_input": historical, "current": actual,
                                       "contract_after_progress_summary_unchanged": True,
                                       "reviewed_freeze": successor["freeze"]}
            return
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
    why = read("docs/evidence/retained-shared-server-prefix-20261020/inputs.json")["why_binary"]
    assert identity(Path(why["path"])) == why["identity"]
    server = read("docs/evidence/retained-server-owned-storage-20261020/native-inputs.json")["inputs"]
    for row in server:
        assert identity(Path(row["path"])) == {k: row[k] for k in ["bytes", "sha256"]}
    acquisition = read("docs/evidence/retained-server-libc-storage-20261020/acquisition.json")
    libc = acquisition["libc"]
    assert identity(Path(libc["path"])) == {k: libc[k] for k in ["bytes", "sha256"]}
    review_round = read("docs/evidence/retained-postinline-libc-capacity-review-20261020/round.json")
    assert review_round["successful_focused_checker_replays"] == 0
    assert review_round["predecessor_checker_replays"] == 0
    review_checks = []
    for key, name in manifest["review_checks"].items():
        row = read(name)
        assert row["author_freeze"] == manifest["components"][key]["first_focused_check_freeze"]
        review_key = manifest["components"][key]["review_key"]
        assert review_round["accepted_author_freezes"][review_key] == manifest["components"][key]["freeze"]
        assert row["returncode"] == 0 and row["author_packet_unchanged"]
        assert row["result"]["status"].lower() == "pass"
        assert row["result"] == review_round["first_focused_checks"][review_key]["result"]
        review_checks.append(row)

    # New composition consumes the accepted earlier result, without replay.
    prior = read("docs/evidence/retained-returned-server-round57-20261020/integration-result.json")
    assert prior["status"] == "pass"
    direct = prior["quiet_direct_server_requested_objects"]
    assert direct["adapter_path_coefficient"] == 459
    assert direct["server_cwd_coefficient"] == 918
    assert direct["constant_bytes"] == 376401
    assert direct["includes_library_allocator_kernel_child_proxy_why_raw_output"] is False
    lp = read("docs/evidence/retained-server-libc-storage-20261020/projection.json")
    assert lp["getcwd_calls_per_server"] == 1 and lp["strdup_calls_per_server"] == 2
    assert lp["initial_path_bound_without_page_observation"] == 2**31-1
    assert lp["DIR_request_max"] == 1048624
    assert lp["guards"]["C_max_from_R57"] == 2**31-1-45
    assert lp["guards"]["ancestor_component_max"] == 4095
    assert lp["formulas"]["R57_addition"] == "G_peak(C,P)+2*(S+1)"
    assert lp["formulas"]["G_peak(C,P)"] == "max(P+C+1,2*B(C)+1048624)"
    assert lp["formulas"]["B(C)"] == "max(4096,2*C)"
    assert lp["aggregate_RAM_gate_required"] is False
    examples = []
    for row in lp["examples"]:
        c, s = row["C"], row["S"]
        conservative = max(2**31-1+c+1, 2*max(4096, 2*c)+1048624)+2*(s+1)
        assert conservative >= row["three_calls_additive_peak"]
        if row["P"] == 2**31-1:
            assert conservative == row["three_calls_additive_peak"]
        examples.append({"C": c, "S": s, "P": row["P"], "conservative_added_bytes": conservative})

    post = read("docs/evidence/retained-why-postinline-preparation-20261020/result.json")
    assert post["complete_for_named_source_operation_categories"]
    assert post["R56_and_R57_preceding_charges_remain_required"]
    assert post["budgets"]["process_global_e_upper"] == 2
    assert not post["budgets"]["fresh_stage_escape_allowance"]
    assert post["budgets"]["per_stage_maxima_share_same_e"]
    assert post["budgets"]["ordinary_preparations"] == 354
    assert post["budgets"]["preparations_upper"] == 364
    totals = post["combined_totals"]
    assert totals["direct_Ident_registrations"] == 753327
    assert totals["Hsdecl_constructor_requests"] == 59781
    assert totals["tdecl_constructor_requests"] == 186092
    assert totals["type_application_requests"] == 7367
    assert all(0 <= n < 2**62 for n in totals.values())
    assert sum(d["registered_roots"] for d in post["domains"]) == 118
    for key, value in totals.items():
        assert value == sum(
            category[key]["with_shared_e_le_2"]
            for domain in post["domains"]
            for category in domain["composition"].values()
        ), key

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
    return {
        "frozen_files": frozen, "retained_repository_inputs": retained,
        "historical_context_successors": context_successors,
        "native_source_pins_unchanged": len(native["repository"]),
        "installed_why_binary_unchanged": True, "installed_libc_unchanged": True,
        "unchanged_server_native_inputs": len(server),
        "review_first_check_subprocess_seconds": sum(r["elapsed_seconds"] for r in review_checks),
        "review_elapsed_interval_seconds": review_round["elapsed_from_first_retained_clock_seconds"],
        "python_parses": parsed, "local_links": links,
        "server_with_libc_requested_objects": {
            "formula": "459*A + sum N_d*tau_d + sum 2*R(M_d) + 918*C + 376401 + max(INT_MAX+C+1, 2*max(4096,2*C)+1048624) + 2*(S+1)",
            "backend_server_count": 1, "INT_MAX": 2**31-1,
            "S_is_actual_backend_socketname_length": True,
            "S_is_not_assumed_frontend_basename_length": True,
            "retained_example_substitutions": examples,
            "historical_page_size_assumed": False,
            "inherited_caller_service_representation_guards_required": True},
        "additional_postinline_source_categories": totals,
        "first_inline_validator_allowance_reused": False,
        "fresh_stage_escape_allowance": False,
        "aggregate_RAM_gate_required": False,
        "complete_q": None, "whole_capacity_rule_delivered": False,
        "component_checker_replays": 0, "native_target_solver_proof_capture_runs": 0,
    }


if __name__ == "__main__":
    start = time.perf_counter()
    result = check()
    result.update(status="pass", elapsed_seconds=time.perf_counter() - start)
    print(json.dumps(result, indent=2, sort_keys=True))
