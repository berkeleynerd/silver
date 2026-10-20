#!/usr/bin/env python3
"""Join frozen solver components without replaying their source censuses."""
import ast
import importlib.util
import json
from pathlib import Path
import re
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
HELPER = ROOT / "docs/evidence/retained-why-diagnostic-round43-20261020/check.py"
spec = importlib.util.spec_from_file_location("round43_helpers", HELPER)
shared = importlib.util.module_from_spec(spec)
spec.loader.exec_module(shared)  # Definitions only; no component check runs.


def read_packet(packet, name):
    return shared.read(f"docs/evidence/{packet}-20261020/{name}.json")


def check():
    inputs = json.loads((HERE / "inputs.json").read_text())
    assert shared.identity(HELPER.read_bytes()) == inputs["helper_identity"]
    frozen, retained = [], {}
    for component, commit in inputs["freezes"].items():
        base = inputs.get("range_bases", {}).get(component)
        paths = (shared.git("diff", "--name-only", base, commit) if base else
            shared.git("diff-tree", "--no-commit-id", "--name-only", "-r", commit))
        for name in paths.decode().splitlines():
            expected = shared.identity(shared.git("show", f"{commit}:{name}"))
            assert shared.identity((ROOT / name).read_bytes()) == expected, name
            frozen.append(dict(component=component, freeze=commit, path=name, **expected))
    for manifest in inputs["component_manifests"]:
        shared.collect(shared.read(manifest), retained)
    for name, expected in retained.items():
        assert shared.identity((ROOT / name).read_bytes()) == expected, name
    native = shared.read("docs/evidence/retained-literal-native-completion-20261019/inputs.json")
    for row in native["repository"]:
        assert shared.identity((ROOT / row["path"]).read_bytes()) == {
            k: row[k] for k in ("bytes", "sha256")}, row["path"]

    inventory = read_packet("retained-solver-identity", "inventory")
    launch = read_packet("retained-solver-identity", "launch")
    drivers = read_packet("retained-solver-identity", "drivers")
    cvc = read_packet("retained-cvc5-output-capacity", "result")
    z3 = read_packet("retained-z3-output-capacity", "result")
    ae = read_packet("retained-altergo-output-capacity", "result")
    identities = {
        "cvc5": read_packet("retained-cvc5-output-capacity", "identity")["revision"],
        "z3": read_packet("retained-z3-output-capacity", "identity")["revision"],
        "alt-ergo": read_packet("retained-altergo-output-capacity", "inputs")["download"]["revision"]}
    for name, revision in identities.items():
        candidate = inventory["source_candidates"][name]
        assert candidate["revision"] == revision
        assert candidate["binary_source_correspondence_attached"] is False
        assert candidate["installed_build_recipe_attached"] is False
        assert candidate["binary_embedded_exact_revision_match"] == (name == "cvc5")
    commands = {key: " ".join([row["executable"], *row["args"]])
        for key, row in inventory["selected_provers"].items()}
    assert commands == {
        "cvc5": "cvc5 --prenex-quant=none --stats-internal %f",
        "z3": "z3 -smt2 -st smt.arith.solver=6 %f",
        "altergo": "alt-ergo --max-split 5 --disable-weaks %f"}
    assert cvc["selected_command"] == commands["cvc5"]
    assert drivers["deleted_step_directives"] == 6
    assert drivers["corrected_selected_step_directives"] == 0
    assert drivers["production_adopted"] is False
    assert launch["packaged_executable_resolution_attached"] is False
    confirmation = launch["proposed_confirmation"]
    assert confirmation["jobs"] == "max(3, available CPUs)"
    assert confirmation["losing_attempts_may_be_interrupted"] is True
    assert confirmation["fixed_PATH_adopted"] is False
    assert confirmation["absolute_command_extra_config_supported"] is False

    server = read_packet("retained-why-server-record-capacity", "attachment")
    js = read_packet("retained-why-standard-json-inputs", "transfer")
    cases = []
    for a, b, c in zip(launch["retained_cases"], server["cases"], js["cases"], strict=True):
        assert a["case"].lower() == b["case"].lower() == c["case"].lower()
        assert a["process"]["pid"] == b["pid"] == c["pid"]
        argv = a["server"]["actual_argv"]
        assert argv[argv.index("-j") + 1] == "1"
        assert a["server"]["actual_environment"]["PATH"] == "/usr/bin:/bin"
        assert "-j" not in a["process"]["argv"]
        terms = c["conditional_inputs"]
        assert b["A"] == terms["A"] and b["N"] == terms["N"]
        cases.append(dict(case=a["case"], pid=b["pid"],
            conditional_uniform_q_weight=max(terms["A"], terms["N"]), actual_O=None))
    assert [row["conditional_uniform_q_weight"] for row in cases] == [208, 173, 108, 12, 9]
    assert cvc["normal_response_pair_bound"] == 84
    assert cvc["q_cvc5"] is None and cvc["weighted_O"] is None
    assert z3["statistics_render_bound_bytes"] == 3+1034*(38+313+4) == 367073
    assert z3["complete_output_file_q"] is None and z3["weighted_output_O"] is None
    assert z3["installed_source_correspondence_proved"] is False
    assert ae["status_data_payload_formula"] == "F + G + 4D + T + 80"
    assert ae["conditional_status_payload_formula"] == "F + T + 182"
    assert ae["complete_solver_file_q"] is None and ae["actual_O"] is None
    assert ae["includes_formatter_or_other_output"] is False
    assert ae["native_source_correspondence_established"] is False
    assert ae["global_budget_reset"] is False

    parsed, links = [], []
    names = {row["path"] for row in frozen} | {str(Path(__file__).resolve().relative_to(ROOT))}
    for name in sorted(names):
        p = ROOT / name
        if p.suffix == ".py":
            ast.parse(p.read_text(), filename=name)
            parsed.append(name)
        if p.suffix == ".md":
            for url in re.findall(r"\]\(([^)]+)\)", p.read_text()):
                if "://" in url or url.startswith("#"):
                    continue
                target = url.split("#")[0]
                assert (p.parent / target).exists(), (name, target)
                links.append(dict(file=name, target=target))
    return dict(frozen_files=frozen, retained_inputs=retained,
        native_pins_unchanged=len(native["repository"]),
        candidate_revisions=identities, selected_commands=commands, case_joins=cases,
        cvc5_conditional_normal_response_pair=84,
        z3_conditional_statistics_render=367073,
        altergo_conditional_status_data_payload="F + T + 182",
        complete_solver_output_q=None, weighted_O=None,
        selected_executable_source_correspondence=False,
        intended_concurrent_configuration_attached=False,
        global_budget_reset=False, python_parses=parsed, local_links=links,
        component_checker_replays=0, new_solver_runs=0, whole_pipeline_capacity=False)


if __name__ == "__main__":
    start = time.monotonic()
    result = check()
    output = HERE / "integration-result.json"
    if output.exists():
        assert result == json.loads(output.read_text())
    else:
        output.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(dict(status="pass", frozen_files=len(result["frozen_files"]),
        retained_inputs=len(result["retained_inputs"]), native_pins_unchanged=result["native_pins_unchanged"],
        python_parses=len(result["python_parses"]), local_links=len(result["local_links"]),
        seconds=time.monotonic()-start)))
