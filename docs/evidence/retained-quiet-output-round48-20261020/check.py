#!/usr/bin/env python3
"""Reconcile exact reviewed inputs; do not rerun component or native work."""
import ast
import importlib.util
import json
from pathlib import Path
import re
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
HELPER = ROOT / "docs/evidence/retained-why-diagnostic-round43-20261020/check.py"
spec = importlib.util.spec_from_file_location("retained_helpers", HELPER)
shared = importlib.util.module_from_spec(spec)
spec.loader.exec_module(shared)


def check():
    inputs = json.loads((HERE / "inputs.json").read_text())
    assert shared.identity(HELPER.read_bytes()) == inputs["helper_identity"]
    frozen, retained, historical = [], {}, []
    for component, row in inputs["components"].items():
        for name in row["paths"]:
            expected = shared.identity(shared.git("show", f"{row['freeze']}:{name}"))
            assert shared.identity((ROOT / name).read_bytes()) == expected, name
            frozen.append(dict(component=component, path=name, **expected))
    for name in inputs["component_manifests"]:
        manifest = shared.read(name)
        for row in manifest.pop("historical_inputs", []):
            expected = {k: row[k] for k in ("bytes", "sha256")}
            assert shared.identity(shared.git("show", f"{row['commit']}:{row['path']}")) == expected
            historical.append(row)
        shared.collect(manifest, retained)
        for group in ("files", "inherited_files"):
            for path, expected in manifest.get(group, {}).items():
                assert shared.identity((ROOT / path).read_bytes()) == expected, path
    for path, expected in retained.items():
        assert shared.identity((ROOT / path).read_bytes()) == expected, path
    native = shared.read("docs/evidence/retained-literal-native-completion-20261019/inputs.json")
    for row in native["repository"]:
        assert shared.identity((ROOT / row["path"]).read_bytes()) == {
            k: row[k] for k in ("bytes", "sha256")}, row["path"]

    route = shared.read("docs/evidence/retained-cvc5-quiet-route-20261020/route.json")
    consumer = shared.read("docs/evidence/retained-solver-output-relevance-20261020/result.json")
    command = route["command"]
    assert len(command["new"].encode()) - len(command["old"].encode()) == command["delta_bytes"] == 123
    assert route["candidate"]["bytes"] - route["baseline"]["bytes"] == 123
    assert command["argv_count"] == len(command["argv_template"]) == 4
    assert sum(len(arg.encode()) for arg in command["argv_template"]) == command["new_argv_payload"] == 164
    assert consumer["clean_exact_pair"]["raw_bytes_upper"] == 84
    assert consumer["clean_exact_pair"]["formatted_answer_bytes_upper"] == 64
    assert consumer["clean_exact_pair"]["consecutive_answer_warnings"] == 0
    assert consumer["clean_exact_pair"]["ordinary_nonsignaled_termination"]
    assert consumer["clean_exact_pair"]["requires_selected_task_to_response_relation"]
    assert not consumer["observation_only_reclassification"]
    assert consumer["actual_clean_attempt_count"] is None
    assert route["complete_q"] is route["weighted_O"] is consumer["complete_q"] is consumer["complete_O"] is None
    assert consumer["global_suffix_budget"] == dict(e_upper=2, save_attempts=3, save_entering_callbacks=2)
    assert route["global_budget"] == dict(e_max=2, save_attempts=3, save_entering_callbacks=2)

    parsed, links = [], []
    for name in sorted({r["path"] for r in frozen} | {str(Path(__file__).relative_to(ROOT))}):
        path = ROOT / name
        if path.suffix == ".py":
            ast.parse(path.read_text(), filename=name)
            parsed.append(name)
        if path.suffix == ".md":
            for url in re.findall(r"\]\(([^)]+)\)", path.read_text()):
                if "://" in url or url.startswith("#"):
                    continue
                target = url.split("#")[0]
                assert (path.parent / target).exists(), (name, target)
                links.append(dict(file=name, target=target))
    return dict(frozen_files=frozen, retained_inputs=retained,
        historical_review_inputs=historical, native_pins_unchanged=len(native["repository"]),
        command_byte_delta=123, clean_pair_bytes=84, clean_formatted_answer_bytes=64,
        complete_q=None, weighted_O=None, whole_capacity_rule_delivered=False,
        production_configuration_changed=False, old_capture_identity_claimed=False,
        component_checker_replays=0, native_solver_compiler_proof_runs=0,
        python_parses=parsed, local_links=links)


if __name__ == "__main__":
    start = time.monotonic()
    result = check()
    output = HERE / "integration-result.json"
    if output.exists():
        assert result == json.loads(output.read_text())
    else:
        output.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(dict(status="pass", frozen_files=len(result["frozen_files"]),
        retained_inputs=len(result["retained_inputs"]),
        historical_inputs=len(result["historical_review_inputs"]),
        native_pins_unchanged=result["native_pins_unchanged"],
        python_parses=len(result["python_parses"]), local_links=len(result["local_links"]),
        seconds=time.monotonic()-start)))
