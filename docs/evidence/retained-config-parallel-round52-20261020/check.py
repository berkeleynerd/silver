#!/usr/bin/env python3
"""Reconcile frozen R52 evidence without replaying component checks."""
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

    warning = read("docs/evidence/retained-why-warning-exclusion-20261020/verification.json")
    timing = read("docs/evidence/retained-response-timing-config-20261020/result.json")
    parallel = read("docs/evidence/retained-why-parallel-first-fill-20261020/result.json")
    combined = read("docs/evidence/retained-adapter-config-composition-20261020/result.json")
    assert warning["passed"] and warning["warning_attempts_upper"] == 0
    assert warning["distinct_GP_Check_attributes_by_case"] == [18, 14, 9, 1, 1]
    assert timing["configured_limits"] == timing["queued_limits"] == [0, 0, 0]
    assert timing["server_limits"] == [0, 0]
    assert timing["time_measurement_rules_after"] == timing["steps_measurement_rules_after"] == 0
    assert not timing["parallel_transfer_claimed"] and not timing["production_adopted"]
    assert parallel["raw_keys"] == 675
    assert parallel["physically_identical_raw_candidates"] == 659
    assert parallel["live_raw_protected_keys"] == 660
    assert parallel["true_shape_protected_keys"] == 2
    assert parallel["unresolved_keys"] == 675 - 660 - 2 == 13
    assert len(parallel["unresolved_formula_families"]) == 4
    assert not parallel["intended_parallel_stored_family_closed"]
    assert not parallel["intended_parallel_fixed_raw_input_and_initial_state_attachment_established"]
    assert not parallel["complete_Ident_no_wrap"] and not parallel["complete_pipeline_capacity"]
    assert parallel["global_save_callbacks_per_process"] == 2
    assert parallel["global_saves_per_process"] == 3
    assert parallel["global_signal_escape_budget_per_process"] == 2
    assert parallel["added_signal_escape_allowance"] == 0
    assert parallel["prospective_direct_component_under_same_three_driver_raw_input_attachment"] == 309197
    assert not parallel["prospective_component_is_retained_postcut_charge"]
    credits = combined["credits"]
    assert credits["minor_words"] == timing["minor_credit_words"] + 4096 == 7582192
    assert credits["major_words"] == timing["major_credit_words"] == 7578096
    assert credits["remembered_entries"] == timing["reference_credit_entries"] + 4096 == 18924760
    assert credits["identifier_registrations_added"] == credits["driver_registrations_added"] == 0
    assert credits["FileTags_distinct_names_added_upper"] == 1
    assert not combined["parallel_transfer_claimed"] and not combined["depends_on_proxy_design"]
    assert combined["complete_q"] is timing["complete_q"] is None
    for base, row in zip(timing["rows"], combined["rows"], strict=True):
        assert base["case"] == row["case"] and base["cut"] == row["cut"]
        assert row["identical_raw_start_and_cut"]
        assert row["candidate_minor_upper"] == base["candidate_minor_upper"] + 4096
        assert row["candidate_major_upper"] == base["candidate_major_upper"]
        assert row["candidate_arena_upper"] == base["candidate_arena_allocation_upper"]
        assert row["candidate_reference_upper"] == base["candidate_reference_upper"] + 4096

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
        warning_attempts_upper=0, raw_keys=675, live_raw_protected_keys=660,
        true_shape_protected_keys=2, unresolved_parallel_keys=13,
        unresolved_parallel_families=4, intended_parallel_stored_family_closed=False,
        composed_configuration_scope=combined["source_claim"],
        composed_configuration_credits=credits,
        complete_q=None, weighted_O=None, whole_capacity_rule_delivered=False,
        production_configuration_changed=False, production_adapter_adopted=False,
        component_checker_replays=0, native_solver_compiler_proof_capture_runs=0,
        python_parses=parsed, local_links=links)


if __name__ == "__main__":
    start = time.monotonic()
    result = check()
    output = HERE / "integration-result.json"
    if output.exists():
        assert result == json.loads(output.read_text())
    else:
        output.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(dict(status="pass", frozen_files=len(result["frozen_files"]),
        retained_inputs=len(result["retained_inputs"]),
        native_pins_unchanged=result["native_pins_unchanged"],
        python_parses=len(result["python_parses"]), local_links=len(result["local_links"]),
        seconds=time.monotonic()-start)))
