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

    goals = shared.read("docs/evidence/retained-why-goal-revalidation-20261020/result.json")
    inline = shared.read("docs/evidence/retained-why-fresh-inline-attachment-20261020/result.json")
    maxima = [236, 190, 181, 28, 15]
    sums = [8353, 6127, 1968, 32, 15]
    cases = goals["cases"]
    assert [r["selected_leaf_max"] for r in cases] == maxima
    assert [r["selected_leaf_sum"] for r in cases] == sums
    assert goals["normal_full_five_process_charge"] == 3*sum(sums) == 49485
    assert goals["normal_post_five_cut_charge"] == 49470
    assert all(r["normal_three_driver_charge"] == 3*r["selected_leaf_sum"] for r in cases)
    interrupted = [3*s + 2*m for s,m in zip(sums,maxima)]
    assert sum(interrupted) == 50785
    assert sum(interrupted)-15 == 50770
    composed = goals["under_named_existing_episode_premises"]
    assert composed["full_five_process_goal_charge_upper"] == sum(interrupted)
    assert composed["post_five_cut_goal_charge_upper"] == sum(interrupted)-15
    assert not composed["callback_Ident_work_included"]
    assert not goals["local_shape_count_requires_Ident_freshness"]
    for row, bound in zip(cases, interrupted):
        actual = row["under_named_existing_episode_premises"]
        assert actual["global_escaping_signal_save_exceptions_upper"] == 2
        assert actual["full_episode_goal_charge_upper"] == bound
    charge = inline["source_registration_charge"]
    assert charge["total"] == sum(charge[k] for k in (
        "kernel", "logic_formals_outside_kernel", "logic_termination_body", "task_check_match_body")) == 1145
    assert inline["logical_roots"] == 244
    assert inline["exact_prepared_input_isomorphism"]["blocks"] == 14477
    assert inline["fresh_complete_Hsdecl"]["old_objects"] == 6704
    assert inline["fresh_projection_summary"]["mapped_keys_unique"] == 143
    counter = inline["fresh_counter_plus_source_charge"]
    assert counter["initial"] == 60496
    assert counter["counter_after_call_upper"] == 60496+1145 == 61641
    assert counter["no_overflow_during_bounded_call"]
    assert not inline["pending_save_report_registration_charge_included"]
    assert not inline["other_tasks_drivers_transforms_bound_by_1145"]
    assert inline["whole_continuation_registration_bound"] is None
    assert inline["global_suffix_budget"] == dict(e_upper=2, save_attempts=3, save_entering_callbacks=2)
    assert not goals["complete_Ident_no_wrap"]
    assert not goals["complete_preparation_capacity"]

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
        goal_leaf_maxima=maxima, goal_leaf_sums=sums,
        normal_goal_charge_all_processes=49485, normal_goal_charge_post_cuts=49470,
        interrupted_goal_charge_all_processes=50785, interrupted_goal_charge_post_cuts=50770,
        local_inline_charge=1145, local_inline_final_counter_upper=61641,
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
