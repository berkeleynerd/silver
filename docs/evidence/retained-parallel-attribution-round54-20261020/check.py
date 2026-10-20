#!/usr/bin/env python3
"""Reconcile frozen R54 evidence without replaying component checks."""
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
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads((ROOT / path).read_text())


def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])


def check():
    manifest = json.loads((HERE / "inputs.json").read_text())
    assert not manifest["review_freeze_pending"]
    assert "review" in manifest["components"]
    frozen, retained = [], {}
    for component, row in manifest["components"].items():
        for name in row["paths"]:
            expected = identity(git("show", f"{row['freeze']}:{name}"))
            assert identity((ROOT / name).read_bytes()) == expected, name
            frozen.append(dict(component=component, path=name, **expected))

    def collect(value):
        if isinstance(value, list):
            for item in value:
                collect(item)
        elif isinstance(value, dict):
            for name, item in value.items():
                if (name.startswith("docs/") and ":" not in name
                        and isinstance(item, str) and re.fullmatch(r"[0-9a-f]{64}", item)):
                    expected = identity((ROOT / name).read_bytes())
                    assert expected["sha256"] == item, name
                    assert name not in retained or retained[name] == expected, name
                    retained[name] = expected
                if (name.startswith("docs/") and ":" not in name
                        and isinstance(item, dict)
                        and "bytes" in item and "sha256" in item):
                    expected = {k: item[k] for k in ("bytes", "sha256")}
                    assert name not in retained or retained[name] == expected, name
                    retained[name] = expected
                collect(item)
            name = value.get("path", "")
            item = value.get("identity", value)
            if (name.startswith("docs/") and ":" not in name
                    and "bytes" in item and "sha256" in item):
                expected = {k: item[k] for k in ("bytes", "sha256")}
                assert name not in retained or retained[name] == expected, name
                retained[name] = expected

    for name in manifest["component_manifests"]:
        contents = read(name)
        collect(contents)
        for relative, expected in contents.get("local_files", {}).items():
            path = Path(name).parent / relative
            assert identity((ROOT / path).read_bytes()) == expected, str(path)
    for name, expected in retained.items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    native = read("docs/evidence/retained-literal-native-completion-20261019/inputs.json")
    for row in native["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            k: row[k] for k in ("bytes", "sha256")}, row["path"]

    exclusion = read("docs/evidence/retained-why-parallel-symbol-exclusion-20261020/result.json")
    assert exclusion["residual_keys"] == exclusion["ordered_z3_stages"] == 13
    assert exclusion["source_argument_fixed_raw_residual_ce_family_closed"]
    assert not exclusion["arbitrary_intended_parallel_shared_state_attached"]
    assert not exclusion["source_theorem_machine_checked"]
    assert sum(row["residual_keys"] for row in exclusion["cases"]) == 13
    assert all(row["derived_monomorphic_only"] for row in exclusion["cases"])
    assert exclusion["global_allowance"] == dict(save_callbacks=2, saves=3,
        escaping_exceptions_upper=2, scope="one unchanged process-wide budget")
    attribution = read("docs/evidence/retained-fixed-goal-attribution-20261020/result.json")
    assert attribution["status"] == "PASS" and attribution["source_slices"] == 48
    assert attribution["counted_assertions"] == 378
    totals = {key: sum(row[key] for row in attribution["cases"].values())
        for key in ("registered", "nontrivial_registered", "checks", "raw_goals", "checked_bindings")}
    assert totals == dict(registered=118, nontrivial_registered=116, checks=47,
        raw_goals=161, checked_bindings=6747)
    assert attribution["formatter"] == dict(initial_Format_margin=78, minimum_Done_JSON_bytes=91)
    completion = read("docs/evidence/retained-server-completion-format-20261020/result.json")
    assert completion["kernel_source_files"] == 19
    assert completion["time_field_bytes_upper"] == 18
    assert completion["F_bytes_upper"] == "id_bytes+path_bytes+29"
    assert completion["F_with_19_digit_id_upper"] == "path_bytes+48"
    assert completion["stock_allocation_bytes"] == "id_bytes+path_bytes+31"
    assert completion["capacity_guard"] == "id_bytes+path_bytes+31 <= INT_MAX"
    assert not completion["kernel_source_binary_attestation"]
    assert completion["complete_q"] is None and not completion["production_adopted"]
    native_completion = read("docs/evidence/retained-server-completion-format-20261020/native-inputs.json")
    for row in native_completion["inputs"]:
        assert identity(Path(row["path"]).read_bytes()) == {k:row[k] for k in ("bytes", "sha256")}
    parsed, links = [], []
    for name in sorted({row["path"] for row in frozen} | {str(Path(__file__).relative_to(ROOT))}):
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
                links.append(dict(file=name, target=target))
    return dict(frozen_files=frozen, retained_inputs=retained,
        native_pins_unchanged=len(native["repository"]),
        completion_native_inputs_unchanged=len(native_completion["inputs"]),
        fixed_input_residual_producer_family_closed=True,
        residual_keys_excluded=13, complete_parallel_mutable_state_attachment=False,
        finite_attribution_totals=totals,
        completion_log_association_scope="conditional one-unacknowledged-F source protocol; actual parallel/logging prefix remains open",
        F_bytes_upper="id_bytes+path_bytes+29", F_with_19_digit_id_upper="path_bytes+48",
        stock_completion_allocation_guard="id_bytes+path_bytes+31 <= INT_MAX",
        kernel_source_binary_attestation=False,
        aggregate_server_proxy_storage_bound_established=False,
        adapter_startup_bound_established=False, complete_q=None,
        whole_capacity_rule_delivered=False,
        global_save_callbacks_per_process=2, global_saves_per_process=3,
        global_signal_escape_budget_per_process=2, added_signal_allowance=0,
        component_checker_replays=0, integration_native_solver_compiler_proof_capture_runs=0,
        production_configuration_changed=False, production_adapter_adopted=False,
        python_parses=parsed, local_links=links)


if __name__ == "__main__":
    start=time.monotonic();result=check();output=HERE/"integration-result.json"
    if output.exists():
        assert result == json.loads(output.read_text())
    else:
        output.write_text(json.dumps(result,indent=2)+"\n")
    print(json.dumps(dict(status="pass", frozen_files=len(result["frozen_files"]),
        retained_inputs=len(result["retained_inputs"]), native_pins_unchanged=result["native_pins_unchanged"],
        completion_native_inputs_unchanged=result["completion_native_inputs_unchanged"],
        python_parses=len(result["python_parses"]),local_links=len(result["local_links"]),
        seconds=time.monotonic()-start)))
