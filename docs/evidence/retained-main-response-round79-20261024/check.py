"""Reconcile accepted Main/response freezes; do not replay their checkers."""
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


def source_bytes(path):
    spec = path.removeprefix("git:")
    revision, separator, _ = spec.partition(":")
    if separator and 7 <= len(revision) <= 40 and all(c in "0123456789abcdef" for c in revision):
        return subprocess.check_output(["git", "show", spec], cwd=ROOT)
    return (ROOT / path).read_bytes()


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


checked = {}


def check_pin(path, expected):
    actual = identity(source_bytes(path))
    if isinstance(expected, str):
        assert actual["sha256"] == expected, path
    else:
        for key in ("bytes", "sha256"):
            if key in expected:
                assert actual[key] == expected[key], (path, key)
    checked[path] = actual


components = read(HERE / "inputs.json")["components"]
frozen = {}
for component in components.values():
    for path in component["paths"]:
        data = (ROOT / path).read_bytes()
        assert data == source_bytes("git:" + component["freeze"] + ":" + path), path
        frozen[path] = identity(data)

main_dir = EV / "retained-main-vc-composition-20261023"
main = read(main_dir / "result.json")
main_review = read(EV / "review-main-vc-composition-20261023/result.json")
assert main_review["target_commit"] == components["main_author"]["freeze"]
assert main["checks"] == 32574 and main_review["checks"] == 1619
for path, sha in main["input_sha256"].items():
    check_pin(path, sha)
for path, sha in main_review["inputs"].items():
    check_pin(path, sha)
for field, name in (("checker_sha256", "check.py"), ("model_sha256", "model.py"), ("identity_sha256", "identity.json")):
    check_pin(str((main_dir / name).relative_to(ROOT)), main[field])
main_identity = read(main_dir / "identity.json")
for pin in main_identity["archives"] + main_identity["providers"] + [main_identity["spark_inventory"]]:
    check_pin(pin["path"], pin)
assert main["native_executions"] == main["predecessor_checker_executions"] == 0
assert main_review["native_executions"] == main_review["predecessor_checker_executions"] == 0

parser_dir = EV / "retained-response-parser-capacity-20261023"
parser = read(parser_dir / "result.json")
parser_review = read(EV / "review-response-parser-capacity-20261024/result.json")
assert parser["status"] == parser_review["status"] == "pass"
assert parser_review["reviewed_commit"] == components["parser_author"]["freeze"]
assert parser["checks"] == 1623 and parser_review["checks"] == 374
assert parser["stderr_merged_into_response_file"]
assert (parser["global_e"], parser["save_callbacks"], parser["saves"]) == (2, 2, 3)
assert not parser["allowance_renewed"] and not parser["whole_119_complete"]
assert not parser_review["actual_configuration_attached"]
assert not parser_review["whole_119_complete"]
assert parser["native_runs"] == parser["compiler_runs"] == parser["prover_runs"] == parser["predecessor_replays"] == 0
assert not parser_review["author_check_replayed"] and not parser_review["predecessor_checks_replayed"]
assert parser_review["native_runs"] == 0
manifest = read(EV / "review-response-parser-capacity-20261024/author-freeze.json")
assert manifest["commit"] == components["parser_author"]["freeze"]
for pin in manifest["files"] + read(parser_dir / "inputs.json")["providers"] + parser_review["additional_source_inputs"]:
    check_pin(pin["path"], pin)

pins = read(EV / "retained-literal-native-completion-20261019/inputs.json")
for pin in pins["repository"]:
    check_pin(pin["path"], pin)

out = dict(
    status="pass", frozen_files=frozen, reconciled_input_files=checked,
    native_source_pins_unchanged=len(pins["repository"]),
    issue185_technical_scope_complete=True,
    issue186_technical_scope_complete=True,
    issue187_whole_file_guard_accepted=True,
    issue188_merged_stderr_repair_accepted=True,
    whole_tool_capacity_rule_complete=False,
    actual_parser_configuration_and_native_relation_attached=False,
    component_checker_replays=0, integration_native_runs=0,
    global_exception_allowance_renewed=False,
    elapsed_seconds=time.perf_counter() - START,
)
(HERE / "integration-result.json").write_text(json.dumps(out, indent=2) + "\n")
print(json.dumps({k: v for k, v in out.items() if k not in ("frozen_files", "reconciled_input_files")}, indent=2))
