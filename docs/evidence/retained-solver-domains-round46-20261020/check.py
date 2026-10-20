#!/usr/bin/env python3
"""Reconcile frozen task, statistics and launch interfaces without replay."""
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
spec.loader.exec_module(shared)


def packet(name):
    return shared.read(f"docs/evidence/{name}-20261020/result.json")


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

    enum = packet("retained-cvc5-enum-output")
    registry = packet("retained-cvc5-registry-domain")
    tasks = packet("retained-solver-task-language")
    launch = packet("retained-solver-launch-profile")
    cvc_source = shared.read("docs/evidence/retained-cvc5-output-capacity-20261020/identity.json")
    assert registry["source_revision"] == cvc_source["revision"]
    enum_archive = ROOT / "docs/evidence/retained-cvc5-output-capacity-20261020/cvc5-source.tar.gz"
    assert shared.identity(enum_archive.read_bytes())["sha256"] == enum["archive_sha256"]
    commands = tasks["per_submitted_file_command_upper_bounds"]
    assert commands["check-sat"] == commands["get-info :reason-unknown"] == 1
    for name in ("set-option", "get-model", "get-value", "get-proof", "echo",
                 "get-info :all-statistics", "reset", "reset-assertions", "push", "pop",
                 "minimize", "find-synth", "find-synth-next"):
        assert commands[name] == 0
    assert tasks["set_info_filename"] == 0
    assert tasks["solver_automatic_option_changes_excluded"] is None
    assert tasks["solver_semantic_acceptance"] is None
    assert tasks["universal_current_silver_grammar_attachment"] is None
    assert tasks["global_suffix_budget"] == {
        "e_upper_bound":2, "save_attempts":3, "save_entering_callbacks":2}
    assert all(tasks[k] is None for k in ("q_cvc5", "q_z3", "q_altergo", "O"))
    assert registry["q_cvc5"] is None and registry["weighted_O"] is None
    counts = registry["stats_all_false_superset"]["both"]
    inactive = registry["stats_all_false_uint32_inactive_superset"]["both"]
    assert (counts["S"], counts["L_names"], counts["I"], counts["D"], counts["T"]) == (622,20096,420,5,125)
    domains = enum["domains"]
    # Use the union of all supported ordinary printer languages, without
    # assuming a sharper default-language or signal-safe bucket theorem.
    key_map = {"API_Kind":"API_Kind", "internal_Kind":"internal_Kind_any_supported_language",
               "TypeConstant":"TypeConstant", "ProofRule":"ProofRule",
               "ProofRewriteRule":"ProofRewriteRule"}
    enum_terms = {key: inactive["histograms"][key] * domains[value]["ordinary_histogram_allowance"]
                  for key, value in key_map.items()}
    enum_sum = sum(enum_terms.values())
    ordinary_constant = counts["base_plus_seven_accepted_finite_histogram_families"] + enum_sum
    inactive_constant = inactive["base_plus_seven_accepted_finite_histogram_families"] + enum_sum
    assert enum_sum == 220014
    assert (ordinary_constant, inactive_constant) == (1104005, 1103886)

    assert launch["complete_parallel_capacity"] is False
    assert launch["per_file_q"] is None and launch["weighted_O"] is None
    for row in launch["cases"]:
        assert row["run_offers_upper"] == row["interrupt_offers_upper"] == 3*row["G"]
        assert row["line_upper_if_C_is_launch_length"] == row["C_launch"]+60+51*row["G"]

    parsed, links = [], []
    names = {r["path"] for r in frozen} | {str(Path(__file__).resolve().relative_to(ROOT))}
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
        fixed_task_command_bounds=commands,
        ordinary_histogram_enum_terms=enum_terms,
        cvc5_one_dump_stats_all_false_R_zero="1104005 + F + 4*V_uint32",
        cvc5_one_dump_additional_inactive_uint32_premise="1103886 + F",
        full_solver_option_preservation=False, complete_solver_output_q=None,
        weighted_O=None, safe_statistics_bucket_bound=None,
        prospective_launch_cases=launch["cases"], historical_serial_counts_changed=False,
        intended_parallel_state_attachment=False, whole_pipeline_capacity=False,
        global_budget_reset=False, component_checker_replays=0, new_native_runs=0,
        python_parses=parsed, local_links=links)


if __name__ == "__main__":
    start = time.monotonic()
    result = check()
    output = HERE / "integration-result.json"
    if output.exists():
        assert result == json.loads(output.read_text())
    else:
        output.write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps(dict(status="pass", frozen_files=len(result["frozen_files"]),
        retained_inputs=len(result["retained_inputs"]), native_pins_unchanged=result["native_pins_unchanged"],
        python_parses=len(result["python_parses"]), local_links=len(result["local_links"]),
        seconds=time.monotonic()-start)))
