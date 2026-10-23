"""Bind the reviewed R72 packet; do not replay its component or audit programs."""
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
    review = EV / "retained-re-native-correspondence-review-20261023"
    audit = read(review / "audit-result.json")
    assert audit["status"] == "pass"
    assert audit["author_freezes"]["installed_Re"] == inputs["components"]["author"]["freeze"]
    assert identity((review / "audit.py").read_bytes()) == audit["audit_code_identity"]
    for group in ("exact_inputs", "providers"):
        for path, expected in audit[group].items():
            assert identity((ROOT / path).read_bytes()) == expected, path
    author = EV / "retained-re-native-correspondence-20261023"
    result = read(author / "result.json")
    assert result["status"] == "pass"
    assert identity((author / "check.py").read_bytes()) == result["checker_identity"]
    for name, expected in result["packet_input_identities"].items():
        assert identity((author / name).read_bytes()) == expected, name
    bounds = result["bounds"]
    for field, audit_field in (
        ("compiler_ids", "compile_ID_upper"),
        ("hash_set_key_count", "packed_key_domain"),
        ("historical_size", "Hash_set_historical_count_upper"),
        ("hash_set_slots", "Hash_set_capacity_upper"),
        ("hash_set_bytes", "Hash_set_payload_bytes_upper"),
    ):
        assert bounds[field] == audit[audit_field], field
    assert bounds["hash_set_bytes"] < bounds["max_string_length"]
    assert not audit["finite_models_are_universal_proof"]
    assert result["native_functions"] == audit["retained_functions"] == 109
    assert result["native_data_records"] == audit["retained_data_intervals"] == 8
    assert result["target_executions"] == audit["target_executions"] == 0
    pins = read(EV / "retained-literal-native-completion-20261019/inputs.json")
    for row in pins["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            key: row[key] for key in ("bytes", "sha256")}, row["path"]
    binary = read(EV / "retained-printer-entry-collision-review-20261020/native-byte-join.json")
    assert identity(Path(binary["installed_binary"]).read_bytes()) == binary["installed_identity"]
    assert binary["installed_identity"] == result["target_identity"] == audit["native_target_identity"]
    return {
        "status": "pass", "frozen_files": frozen,
        "author_freeze": inputs["components"]["author"]["freeze"],
        "review_freeze": inputs["components"]["review"]["freeze"],
        "installed_Re_selected_numerical_correspondence_established": True,
        "bounds": bounds,
        "matching_semantics_and_physical_resource_premises_retained": True,
        "global_exception_allowance_renewed": False,
        "raw_backend_file_bytes_upper": None,
        "whole_process_capacity": False, "whole_capacity_rule_complete": False,
        "production_implemented": False, "aggregate_RAM_or_stack_gate": False,
        "native_source_pins_unchanged": len(pins["repository"]),
        "installed_why_unchanged": True,
        "component_checker_replays": 0, "native_runs": 0,
    }


if __name__ == "__main__":
    start = time.perf_counter()
    result = check()
    result["elapsed_seconds"] = time.perf_counter() - start
    (HERE / "integration-result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({k: v for k, v in result.items() if k != "frozen_files"}))
