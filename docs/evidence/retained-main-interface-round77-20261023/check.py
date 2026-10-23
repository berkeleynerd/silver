"""Bind the accepted Main interface and reviews without replaying providers."""
from pathlib import Path
import hashlib
import json
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent
START = time.perf_counter()


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


components = read(HERE / "inputs.json")["components"]
frozen = {}
for component in components.values():
    for path in component["paths"]:
        data = (ROOT / path).read_bytes()
        assert data == subprocess.check_output(
            ["git", "show", component["freeze"] + ":" + path], cwd=ROOT
        ), path
        frozen[path] = identity(data)

author_dir = EV / "retained-main-callers-profile-20261023"
review_dir = EV / "retained-main-callers-final-review-20261023"
author = read(author_dir / "result.json")
review = read(review_dir / "repair-result.json")
round_record = read(review_dir / "round.json")
assert author["status"] == review["status"] == "pass"
assert author["checks"] == 29358 and author["diagrams"] == 60
assert review["checks"] == 6513
assert review["code_diagram_commit"] == components["code"]["freeze"]
assert review["receipt_commit"] == components["receipts"]["freeze"]
assert all(f["status"] == "fixed and independently reviewed"
           for f in round_record["findings"])
assert round_record["native_runs"] == round_record["predecessor_checker_replays"] == 0
for path, digest in review["inputs"].items():
    assert identity((ROOT / path).read_bytes())["sha256"] == digest, path

providers = read(author_dir / "identity.json")["providers"]
for provider in providers:
    assert identity((ROOT / provider["path"]).read_bytes())["sha256"] == provider["sha256"], provider["path"]

# The two amended author runs are retained separately from the initial result.
for receipt in ("result-initial.json", "result-three-repairs.json"):
    assert read(author_dir / receipt)["status"] == "pass"
assert (author_dir / "result-initial.json").read_bytes() == subprocess.check_output(
    ["git", "show", "4a4d15cd02:docs/evidence/retained-main-callers-profile-20261023/result.json"], cwd=ROOT
)

pins = read(EV / "retained-literal-native-completion-20261019/inputs.json")
for pin in pins["repository"]:
    assert identity((ROOT / pin["path"]).read_bytes()) == {
        key: pin[key] for key in ("bytes", "sha256")
    }, pin["path"]
native = read(EV / "retained-fixed-ptree-mlw-output-20261023/native-witnesses.json")
assert identity(Path(native["executable"]).read_bytes()) == native["identity"]

out = dict(
    status="pass", frozen_files=frozen, unchanged_providers=len(providers),
    ordinary_Main_source_typed_U_H_interface_accepted=True,
    downstream_source_to_terminal_goal_composition_complete=False,
    whole_tool_capacity_rule_complete=False,
    native_module_signature_attachment_claimed=False,
    fixed_failure_composition_complete=False,
    native_source_pins_unchanged=len(pins["repository"]), installed_Why_unchanged=True,
    component_checker_replays=0, integration_native_runs=0,
    global_exception_allowance_renewed=False,
    elapsed_seconds=time.perf_counter() - START,
)
(HERE / "integration-result.json").write_text(json.dumps(out, indent=2) + "\n")
print(json.dumps({key: value for key, value in out.items() if key != "frozen_files"}, indent=2))
