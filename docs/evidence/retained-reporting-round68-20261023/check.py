"""Bind reviewed reporting freezes; no component program or target execution."""
import hashlib
import json
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def check():
    manifest = read(HERE / "inputs.json")
    frozen = {}
    for component in manifest["components"].values():
        for path in component["paths"]:
            data = (ROOT / path).read_bytes()
            assert data == subprocess.check_output(
                ["git", "show", component["freeze"]+":"+path], cwd=ROOT), path
            frozen[path] = identity(data)
    review_dir = EV / "retained-diagnostic-output-review-20261023"
    audit = read(review_dir / "audit-result.json")
    assert audit["status"] in ("pass", "passed")
    assert identity((review_dir / "audit.py").read_bytes()) == audit["audit_code_identity"]
    for name, freeze in audit["author_freezes"].items():
        assert manifest["components"][name]["freeze"] == freeze, name
    for group in ("exact_inputs", "providers"):
        for path, expected in audit[group].items():
            assert identity((ROOT / path).read_bytes()) == expected, path
    composition = read(EV / "retained-reporting-composition-20261023/result.json")
    assert composition["status"] == "pass"
    assert composition["actual_standard_core_guards"] is None
    assert not composition["actual_path_inputs_attached"]
    assert not composition["whole_process_capacity"]
    assert not composition["whole_capacity_rule_complete"]
    assert composition["stderr_fragment_copies_per_process"] == 1
    assert composition["exit_flush_events_total"] == 2
    assert composition["global_escape_budget"] == composition["save_entering_callbacks"] == 2
    assert composition["saves_upper"] == 3
    assert not composition["budget_renewed"]
    assert len(composition["cases"]) == 5
    for row in composition["cases"]:
        assert row["orientation_only"]["all_core_guards_fit"]
        assert row["orientation_only"]["zero_initial_offset_guard_fits"]
        assert row["actual_standard_core_guards"] is None
        assert row["actual_channel_offset_guards"] is None
    pins = read(EV / "retained-literal-native-completion-20261019/inputs.json")
    for row in pins["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            key: row[key] for key in ("bytes", "sha256")}, row["path"]
    binary = read(EV / "retained-printer-entry-collision-review-20261020/native-byte-join.json")
    assert identity(Path(binary["installed_binary"]).read_bytes()) == binary["installed_identity"]
    return {"status": "pass", "frozen_files": frozen,
            "reviewed_author_freezes": audit["author_freezes"],
            "reviewed_reporting_interfaces_attached": True,
            "orientation_guard_cases": len(composition["cases"]),
            "minimum_orientation_sentinel_margin": min(
                row["orientation_only"]["sentinel_margin"] for row in composition["cases"]),
            "native_source_pins_unchanged": len(pins["repository"]),
            "installed_why_unchanged": True,
            "actual_path_inputs_attached": False,
            "actual_standard_core_guards": None,
            "whole_process_capacity": False, "whole_capacity_rule_complete": False,
            "production_implemented": False, "aggregate_RAM_or_stack_gate": False,
            "component_checker_replays": 0, "native_runs": 0}


if __name__ == "__main__":
    start = time.perf_counter()
    result = check()
    result["elapsed_seconds"] = time.perf_counter()-start
    (HERE / "integration-result.json").write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps({k: v for k, v in result.items() if k != "frozen_files"}))
