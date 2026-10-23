"""Check the current-registration/protocol projection; do not replay providers."""
import hashlib
import json
from pathlib import Path
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def check():
    inputs = json.loads((HERE / "inputs.json").read_text())
    for path, expected in inputs["providers"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path

    def read(path):
        return json.loads((EV / path).read_text())

    cuts = read("retained-parallel-logging-prefix-20261020/cut-projection.json")
    combined = read("retained-combined-parallel-startup-20261020/projection.json")["domains"]
    six = read("retained-six-owner-round63-20261023/candidate-composition-result.json")
    demand = {r["case"].replace("-", "_"): r for r in six["cases"]}
    canonical = {r["case"]: r for r in read("retained-why-canonical-json-input-20261023/result.json")["cases"]}
    old = read("retained-adapter-protocol-storage-20261020/result.json")
    assert six["budgets"] == {"per_process_escape": 2, "save_entering_callbacks_upper": 2,
                              "saves_upper": 3, "allowance_renewed_at_stage_boundary": False}
    cases = []
    for row in old["cases"]:
        name = row["case"]
        cut, now, owner = cuts[name], combined[name], demand[name]
        g = len(cut["fixed_root_map"])
        goals = [r["goal"] for r in cut["fixed_root_map"]]
        assert len(goals) == len(set(goals))
        assert g == now["registered_root_count"] == owner["demand"]["registered_roots"]
        assert cut["captured_pid"] == now["original_pid"] == owner["attachment"]["retained_j12_pid"] == canonical[name]["j12_pid"]
        assert now["session_counters"] == cut["session_counters"]
        children = cut["session_counters"]["next_proofNodeID"] - 1
        assert children == canonical[name]["G"]
        q = owner["demand"]["preparation_episodes_upper"]
        assert q == 3*g + 2 == canonical[name]["N"]
        assert owner["demand"]["ordinary_pairs"] == 3*g
        assert 3*g <= row["run_entries"] == row["interrupt_entries"]
        assert len(str(3*g)) <= row["positive_ID_digits"]
        if name == "input_is_valid":
            assert children == 4 and goals == [3] and g == 1 and q == 5
        cases.append({"case": name, "j12_pid": cut["captured_pid"],
                      "raw_children": children, "registered_roots": g,
                      "parallel_wire_entries_upper": 3*g,
                      "broader_preparation_episodes_upper": q,
                      "retained_protocol_entries_upper": row["run_entries"],
                      "retained_ID_digits": row["positive_ID_digits"]})
    assert sum(r["parallel_wire_entries_upper"] for r in cases) == 354
    assert sum(r["retained_protocol_entries_upper"] for r in cases) == old["total_attempts_upper"] == 459
    assert old["response_records_upper"] == 918
    assert old["canonical_file_payload_bytes"] == 34884
    assert old["ring_old_new_backing_bytes_J12"] == 41536
    return {"status": "pass", "providers": inputs["providers"], "cases": cases,
            "current_wire_entries_upper": 354, "retained_protocol_entries_upper": 459,
            "retained_protocol_bounds_unchanged": True,
            "source_ownership_premises_retained": True,
            "raw_backend_file_bytes_upper": None,
            "shared_server_connection_refinement_established": False,
            "whole_capacity_rule_complete": False, "native_runs": 0,
            "provider_replays": 0, "global_budget_renewed": False}


if __name__ == "__main__":
    start = time.perf_counter()
    result = check()
    result["elapsed_seconds"] = time.perf_counter() - start
    (HERE / "result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({k: v for k, v in result.items() if k != "providers"}))
