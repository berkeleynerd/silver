"""Bind R70's independently reviewed interfaces without replaying providers."""
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
                ["git", "show", component["freeze"] + ":" + path], cwd=ROOT), path
            frozen[path] = identity(data)
    review = EV / "retained-library-probe-logging-review-20261023"
    audit = read(review / "audit-result.json")
    assert audit["status"] in ("pass", "passed")
    assert identity((review / "audit.py").read_bytes()) == audit["audit_code_identity"]
    for name, freeze in audit["author_freezes"].items():
        assert manifest["components"][name]["freeze"] == freeze
    for group in ("exact_inputs", "providers"):
        for path, expected in audit[group].items():
            assert identity((ROOT / path).read_bytes()) == expected, path
    paths = read(EV / "retained-why-library-probe-paths-20261023/projection.json")
    assert paths["P_stat"] == audit["P_stat"] == 167
    assert paths["candidate_count_upper"] == 20
    assert paths["managed_words_per_invocation_upper"] == audit["managed_words_per_locate_upper"] == 870
    assert paths["C_copy_single_request_upper"] == 168
    assert paths["C_copy_bytes_per_invocation_upper"] == audit["C_copy_bytes_per_locate_upper"] == 3188
    assert paths["global_locate_call_count"] is None
    assert not paths["FileTags_counter_or_table_capacity_established"]
    assert not paths["diagnostic_path_theorem_changed"]
    logs = read(EV / "retained-why-logging-capacity-20261023/bounds.json")
    assert logs["shared_e"] == logs["save_entering_callbacks"] == 2
    assert logs["saves"] == 3
    assert len(logs["cases"]) == 5
    for row in logs["cases"]:
        q = row["Q"]
        h = q*q + 4*q
        assert row["log_invocations_upper_H"] == h
        assert row["channel_offered_bytes_upper_X"] == 1281*h
        assert row["cached_offset_upper"] == 1281*h
        assert row["initial_debt_P0"] == row["initial_cached_offset_O0"] == 0
        assert row["log_channel_refcount_upper"] == 7
        assert row["numeric_guards_pass"]
        assert not row["complete_JSON_lines_or_delivery_established"]
        assert row["syscall_attempt_count_upper"] is None
    pins = read(EV / "retained-literal-native-completion-20261019/inputs.json")
    for row in pins["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            key: row[key] for key in ("bytes", "sha256")}, row["path"]
    binary = read(EV / "retained-printer-entry-collision-review-20261020/native-byte-join.json")
    assert identity(Path(binary["installed_binary"]).read_bytes()) == binary["installed_identity"]
    return {
        "status": "pass", "frozen_files": frozen,
        "reviewed_author_freezes": audit["author_freezes"],
        "reviewed_raw_path_and_logging_interfaces_attached": True,
        "P_stat": 167, "raw_candidates_per_locate": 20,
        "direct_managed_words_per_locate_upper": 870,
        "C_copy_single_request_upper": 168,
        "C_copy_bytes_per_locate_upper": 3188,
        "conditional_logging_cases": 5,
        "maximum_log_channel_offers": max(r["channel_offered_bytes_upper_X"] for r in logs["cases"]),
        "native_source_pins_unchanged": len(pins["repository"]),
        "installed_why_unchanged": True, "global_locate_call_count": None,
        "FileTags_representation_closed": False, "raw_solver_file_storage_closed": False,
        "whole_process_capacity": False, "whole_capacity_rule_complete": False,
        "production_implemented": False, "aggregate_RAM_or_stack_gate": False,
        "component_checker_replays": 0, "native_runs": 0,
    }


if __name__ == "__main__":
    start = time.perf_counter()
    result = check()
    result["elapsed_seconds"] = time.perf_counter() - start
    (HERE / "integration-result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({k: v for k, v in result.items() if k != "frozen_files"}))
