"""Bind accepted backend-output design evidence without replaying its checks."""
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
    review = EV / "retained-backend-output-route-review-20261023"
    audit = read(review / "audit-result.json")
    assert audit["status"] == "pass"
    assert audit["author_freezes"]["backend_output_route"] == inputs["components"]["author"]["freeze"]
    assert identity((review / "audit.py").read_bytes()) == audit["audit_code_identity"]
    for group in ("exact_inputs", "providers"):
        for path, expected in audit[group].items():
            assert identity((ROOT / path).read_bytes()) == expected, path
    author = EV / "retained-backend-output-route-20261023"
    projection = read(author / "projection.json")
    assert read(author / "result.json")["status"] == "passed"
    assert projection["q_backend_formula"] == "max(2*A+72,A+E+1296)"
    assert projection["sufficient_guard"] == "A>=1 and E>=1 and q_backend(A,E)<=2147483647"
    assert projection["actual_A"] is projection["actual_E"] is projection["actual_numeric_q_backend"] is None
    assert projection["canonical_file_upper"] == 76
    assert projection["control_decision_upper"] == 64
    assert projection["inherited_parent_stdio_payload"] == 0
    assert projection["selected_solver_pipe_contribution_to_backend_file"] == 0
    assert projection["global_e_upper"] == projection["save_entering_callbacks_upper"] == 2
    assert projection["saves_upper"] == 3
    for field in ("budget_renewed", "new_trusted_capacity_premise", "production_refinement_established",
                  "old_stock_solver_file_q_closed", "optional_raw_logging_selected",
                  "whole_process_capacity_established"):
        assert not projection[field], field
    protocol = read(EV / "retained-current-protocol-join-20261023/result.json")
    assert projection["current_launch_entries_upper"] == protocol["current_wire_entries_upper"] == 354
    assert projection["retained_protocol_entries_upper"] == protocol["retained_protocol_entries_upper"] == 459
    assert projection["production_refinement_certificate"] == "Adapter_Backend_Emission"
    assert audit["terminal_components"]["combined_constant"] == 1296
    pins = read(EV / "retained-literal-native-completion-20261019/inputs.json")
    for row in pins["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            key: row[key] for key in ("bytes", "sha256")}, row["path"]
    binary = read(EV / "retained-printer-entry-collision-review-20261020/native-byte-join.json")
    assert identity(Path(binary["installed_binary"]).read_bytes()) == binary["installed_identity"]
    return {
        "status": "pass", "frozen_files": frozen,
        "author_freeze": inputs["components"]["author"]["freeze"],
        "review_freeze": inputs["components"]["review"]["freeze"],
        "backend_output_design_interface_attached": True,
        "q_backend_formula": projection["q_backend_formula"],
        "sufficient_configuration_guard": projection["sufficient_guard"],
        "actual_numeric_q_backend": None,
        "configuration_operands_unset_are_not_a_missing_design_theorem": True,
        "future_implementation_refinement": projection["production_refinement_certificate"],
        "current_launch_entries_upper": 354, "retained_protocol_entries_upper": 459,
        "pre_redirect_stream_separate": True,
        "canonical_reader_input_unchanged": True,
        "global_exception_allowance_renewed": False,
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
