"""Bind reviewed R71 inputs without replaying component or review programs."""
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
    inputs = read(HERE / "inputs.json")
    frozen = {}
    for component in inputs["components"].values():
        for path in component["paths"]:
            data = (ROOT / path).read_bytes()
            assert data == subprocess.check_output(
                ["git", "show", component["freeze"] + ":" + path], cwd=ROOT), path
            frozen[path] = identity(data)
    review = EV / "retained-filetags-canonical-parser-review-20261023"
    audit = read(review / "audit-result.json")
    assert audit["status"] in ("pass", "passed")
    assert identity((review / "audit.py").read_bytes()) == audit["audit_code_identity"]
    assert set(audit["author_freezes"].values()) == {
        inputs["components"][name]["freeze"] for name in ("filetags", "parser", "protocol")}
    for group in ("exact_inputs", "providers"):
        for path, expected in audit[group].items():
            assert identity((ROOT / path).read_bytes()) == expected, path
    tags = read(EV / "retained-why-filetags-capacity-20261023/projection.json")
    assert tags["global_e_upper"] == tags["save_entering_callbacks_upper"] == 2
    assert tags["saves_upper"] == 3 and not tags["renewed_failure_budget"]
    assert not tags["arbitrary_resumed_resource_failure_closure"]
    assert tags["all_FileTags_filename_upper"] == 180
    assert tags["alias_robust_warning_entry_upper"] == 436
    assert len(tags["domains"]) == 5
    for row in tags["domains"].values():
        assert row["actual_N0"] is row["actual_B0"] is None
        assert row["counter_upper"] == row["size_upper_per_table"] == row["physical_cells_allocated_upper_per_table"] == 1890430
        assert row["backing_and_tail_extent_upper"] == 2097152
        assert row["threshold_and_attempted_doubling_upper"] == 4194304
        assert row["suffix_forward_add_attempts_upper"] == 945216
        assert row["representation_guards_pass"]
    parser = read(EV / "retained-why-canonical-parser-capacity-20261023/result.json")
    guard = parser["guard_inputs"]
    assert guard["input_bytes"] == 76
    assert guard["reader_buffer"] == guard["reader_scratch"] == 1024
    assert guard["union_buffer"] == 512
    assert len(parser["domains"]) == 5
    protocol = read(EV / "retained-current-protocol-join-20261023/result.json")
    assert protocol["status"] == "pass"
    assert protocol["retained_protocol_bounds_unchanged"]
    assert protocol["current_wire_entries_upper"] == 354
    assert protocol["retained_protocol_entries_upper"] == 459
    assert protocol["raw_backend_file_bytes_upper"] is None
    assert not protocol["shared_server_connection_refinement_established"]
    pins = read(EV / "retained-literal-native-completion-20261019/inputs.json")
    for row in pins["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            key: row[key] for key in ("bytes", "sha256")}, row["path"]
    binary = read(EV / "retained-printer-entry-collision-review-20261020/native-byte-join.json")
    assert identity(Path(binary["installed_binary"]).read_bytes()) == binary["installed_identity"]
    return {"status": "pass", "frozen_files": frozen,
            "reviewed_author_freezes": audit["author_freezes"],
            "FileTags_representation_guards_attached": True,
            "FileTags_counter_upper": 1890430,
            "FileTags_backing_extent_upper": 2097152,
            "canonical_reader_and_direct_callers_attached": True,
            "reference_Re_numeric_bounds_attached": True,
            "installed_Re_numeric_correspondence_established": False,
            "retained_protocol_entries_upper": 459,
            "source_ownership_and_physical_resource_premises_retained": True,
            "arbitrary_resumed_resource_failure_closure": False,
            "raw_backend_file_bytes_upper": None,
            "whole_process_capacity": False, "whole_capacity_rule_complete": False,
            "production_implemented": False, "aggregate_RAM_or_stack_gate": False,
            "native_source_pins_unchanged": len(pins["repository"]),
            "installed_why_unchanged": True,
            "component_checker_replays": 0, "native_runs": 0}


if __name__ == "__main__":
    start = time.perf_counter()
    result = check()
    result["elapsed_seconds"] = time.perf_counter() - start
    (HERE / "integration-result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({k: v for k, v in result.items() if k != "frozen_files"}))
