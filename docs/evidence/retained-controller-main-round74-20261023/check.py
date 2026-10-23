"""Bind two accepted scoped interfaces; do not replay their component checks."""
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


def bind(items):
    for path, expected in items.items():
        assert identity((ROOT / path).read_bytes()) == expected, path


def check():
    inputs = read(HERE / "inputs.json")
    frozen = {}
    for component in inputs["components"].values():
        for path in component["paths"]:
            data = (ROOT / path).read_bytes()
            assert data == subprocess.check_output(
                ["git", "show", component["freeze"] + ":" + path], cwd=ROOT), path
            frozen[path] = identity(data)

    main_review = EV / "retained-main-typed-profile-review-20261023"
    main = read(main_review / "audit-result.json")
    assert main["status"] == "pass"
    assert main["author_freeze"] == inputs["components"]["main_author"]["freeze"]
    assert identity((main_review / "audit.py").read_bytes()) == main["audit_code_identity"]
    bind(main["exact_inputs"])
    bind(main["providers"])
    assert main["typed_contract_slice_accepted"]
    assert main["selected_contracts"] == 5
    assert not main["numeric_main_U_H_established"]
    assert not main["ordinary_Main_source_emitter_complete"]
    assert not main["issue_178_complete"] and not main["whole_rule_complete"]
    main_author = read(EV / "retained-main-typed-profile-20261023/result.json")
    assert main_author["fixed_external_state_keys"] == 7
    assert main_author["fixed_output_effect_keys"] == 11
    assert main_author["post_unit_costs"] == {
        "input_is_valid": 4, "first_or_default": 74, "reject": 1,
        "put": 116, "put_line": 127}
    for name, cost in main_author["post_unit_costs"].items():
        assert main["recovered_contract_profiles"][name]["post"]["at_unit_weights"] == cost

    controller_review = EV / "retained-controller-owner-review-20261023"
    controller = read(controller_review / "result.json")
    controller_inputs = read(controller_review / "inputs.json")
    assert controller["status"] == "pass"
    assert controller["reviewed_freeze"] == inputs["components"]["controller_author"]["freeze"]
    bind(controller_inputs["files"])
    assert identity((controller_review / "audit.py").read_bytes()) == controller_inputs["audit_script"]
    author = read(EV / "retained-controller-owner-join-20261023/result.json")
    assert author["status"] == "pass"
    assert author["controller_owner_join_under_existing_guard"]
    assert author["controller_SIGINT_save_entries_under_selected_mask"] == 0
    assert author["global_escape_budget"] == author["global_save_entering_callbacks_upper"] == 2
    assert author["global_saves_upper"] == 3
    for key in ("global_budget_renewed", "new_trusted_primitive_added",
                "arbitrary_resumed_resource_failure_preservation_claimed",
                "actual_launcher_mask_refinement_established", "whole_capacity_rule_complete"):
        assert not author[key], key
    assert [r["run_entries_upper"] for r in author["cases"]] == [153, 126, 66, 6, 3]
    assert [r["result_buffer"]["physical_cells_upper"] for r in author["cases"]] == [306, 252, 132, 12, 6]
    assert [r["attempt_counter_upper"] for r in author["cases"]] == [167, 138, 76, 7, 6]
    assert not controller["whole_capacity_rule_complete"]

    pins = read(EV / "retained-literal-native-completion-20261019/inputs.json")
    for row in pins["repository"]:
        bind({row["path"]: {k: row[k] for k in ("bytes", "sha256")}})
    binary = read(EV / "retained-printer-entry-collision-review-20261020/native-byte-join.json")
    assert identity(Path(binary["installed_binary"]).read_bytes()) == binary["installed_identity"]
    return {
        "status": "pass", "frozen_files": frozen,
        "controller_owner_join_attached": True,
        "selected_Main_contract_slice_attached": True,
        "numeric_arbitrary_Main_U_H_established": False,
        "ordinary_Main_source_emitter_complete": False,
        "whole_fixed_domain_composition_complete": False,
        "whole_capacity_rule_complete": False,
        "global_exception_allowance_renewed": False,
        "production_implemented": False, "aggregate_RAM_or_stack_gate": False,
        "native_source_pins_unchanged": len(pins["repository"]),
        "installed_why_unchanged": True,
        "component_checker_replays": 0, "native_runs": 0,
    }


if __name__ == "__main__":
    started = time.perf_counter()
    result = check()
    result["elapsed_seconds"] = time.perf_counter() - started
    (HERE / "integration-result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({k: v for k, v in result.items() if k != "frozen_files"}))
