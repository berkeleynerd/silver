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
    review_dir = EV / "retained-report-path-construction-review-20261023"
    audit = read(review_dir / "audit-result.json")
    assert audit["status"] in ("pass", "passed")
    assert identity((review_dir / "audit.py").read_bytes()) == audit["audit_code_identity"]
    for name, freeze in audit["author_freezes"].items():
        assert manifest["components"][name]["freeze"] == freeze, name
    for group in ("exact_inputs", "providers"):
        for path, expected in audit[group].items():
            assert identity((ROOT / path).read_bytes()) == expected, path
    joined = read(EV / "retained-reporting-path-join-20261023/result.json")
    assert joined["status"] == "pass"
    assert joined["actual_R"] is joined["actual_runtime_guard_claim"] is None
    assert not joined["whole_process_capacity"] and not joined["whole_capacity_rule_complete"]
    assert not joined["raw_stat_path_storage_closed"]
    assert joined["global_escape_budget"] == joined["save_entering_callbacks"] == 2
    assert joined["saves_upper"] == 3 and not joined["budget_renewed"]
    assert joined["derived_envelope_is_not_an_adopted_admission_cap"]
    assert len(joined["cases"]) == 5
    for row in joined["cases"]:
        assert row["L_o"] == 436*row["W_o"]
        assert row["L_o_increase"] == 14*row["W_o"]
        assert row["noncore_representation_provider_attached"]
        for endpoint in ("lower_endpoint_arithmetic_only", "upper_endpoint_arithmetic_only"):
            assert row[endpoint]["all_guards"]
        assert row["next_R_sentinel_margin"] < 0
        assert row["actual_R"] is row["actual_runtime_guard_claim"] is None
    assert joined["common_sufficient_R_envelope"] == min(row["R_limit"] for row in joined["cases"])
    pins = read(EV / "retained-literal-native-completion-20261019/inputs.json")
    for row in pins["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            key: row[key] for key in ("bytes", "sha256")}, row["path"]
    binary = read(EV / "retained-printer-entry-collision-review-20261020/native-byte-join.json")
    assert identity(Path(binary["installed_binary"]).read_bytes()) == binary["installed_identity"]
    return {"status": "pass", "frozen_files": frozen,
            "reviewed_author_freezes": audit["author_freezes"],
            "reviewed_path_construction_and_guard_interfaces_attached": True,
            "conditional_guard_cases": len(joined["cases"]),
            "common_sufficient_R_envelope": joined["common_sufficient_R_envelope"],
            "minimum_illustrative_R64_sentinel_margin": joined["minimum_illustrative_R64_sentinel_margin"],
            "native_source_pins_unchanged": len(pins["repository"]),
            "installed_why_unchanged": True,
            "source_path_functions_attached": True,
            "actual_R": None, "actual_runtime_guard_claim": None,
            "raw_stat_path_storage_closed": False,
            "whole_process_capacity": False, "whole_capacity_rule_complete": False,
            "production_implemented": False, "aggregate_RAM_or_stack_gate": False,
            "component_checker_replays": 0, "native_runs": 0}


if __name__ == "__main__":
    start = time.perf_counter()
    result = check()
    result["elapsed_seconds"] = time.perf_counter()-start
    (HERE / "integration-result.json").write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps({k: v for k, v in result.items() if k != "frozen_files"}))
