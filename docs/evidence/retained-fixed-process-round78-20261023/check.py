"""Integrate fixed-process acceptance without executing accepted checkers."""
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
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def source_bytes(path):
    if path.startswith("git:"):
        return subprocess.check_output(["git", "show", path[4:]], cwd=ROOT)
    revision, separator, _ = path.partition(":")
    if separator and 7 <= len(revision) <= 40 and all(c in "0123456789abcdef" for c in revision):
        return subprocess.check_output(["git", "show", path], cwd=ROOT)
    return (ROOT / path).read_bytes()


components = read(HERE / "inputs.json")["components"]
frozen = {}
for component in components.values():
    for path in component["paths"]:
        data = (ROOT / path).read_bytes()
        assert data == subprocess.check_output(
            ["git", "show", component["freeze"] + ":" + path], cwd=ROOT
        ), path
        frozen[path] = identity(data)

author_dir = EV / "retained-fixed-failure-composition-20261023"
review_dir = EV / "review-fixed-failure-composition-20261023"
author = read(author_dir / "result.json")
review = read(review_dir / "result.json")
assert author["status"] == "pass" and review["passed"]
assert author["checks"] == 2589 and review["checks"] == 1368
assert review["target"] == components["author"]["freeze"]
assert author["normal_and_terminal_prefixes_are_alternatives"]
assert not author["allowance_renewed"]
assert (author["global_e_upper"], author["save_entering_callbacks_upper"],
        author["saves_upper"]) == (2, 2, 3)
assert not author["arbitrary_Main_covered"]
assert not author["GNATCOLL_spark_collector_covered"]
assert not author["production_refinement_established"]
assert author["predecessor_checker_replays"] == author["target_runs"] == 0
assert review["predecessor_checker_runs"] == review["native_target_runs"] == 0
assert author["sufficient_region"] == dict(PrecutP_upper=1927, client_cwd_bytes_upper=1917)

inherited = read(author_dir / "inputs.json")
for path, expected in inherited.items():
    assert identity(source_bytes(path)) == expected, path
for path, expected in review["inputs"].items():
    assert identity(source_bytes(path)) == expected, path
manifest = read(review_dir / "author-freeze.json")
assert manifest["commit"] == components["author"]["freeze"]
for entry in manifest["files"]:
    assert identity((ROOT / entry["path"]).read_bytes()) == {
        key: entry[key] for key in ("bytes", "sha256")
    }, entry["path"]

pins = read(EV / "retained-literal-native-completion-20261019/inputs.json")
for pin in pins["repository"]:
    assert identity((ROOT / pin["path"]).read_bytes()) == {
        key: pin[key] for key in ("bytes", "sha256")
    }, pin["path"]

out = dict(
    status="pass", frozen_files=frozen, inherited_inputs=len(inherited),
    reviewer_inputs=len(review["inputs"]),
    fixed_five_success_failure_capacity_interface_accepted=True,
    controlled_driver_resolution_repair_accepted=True,
    issue153_technical_scope_complete=True,
    production_refinement_established=False,
    whole_tool_capacity_rule_complete=False,
    native_source_pins_unchanged=len(pins["repository"]),
    component_checker_replays=0, integration_native_runs=0,
    global_exception_allowance_renewed=False,
    elapsed_seconds=time.perf_counter() - START,
)
(HERE / "integration-result.json").write_text(json.dumps(out, indent=2) + "\n")
print(json.dumps({key: value for key, value in out.items() if key != "frozen_files"}, indent=2))
