#!/usr/bin/env python3
"""Reconcile reviewed stop inputs without replaying native/component work."""
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


def check():
    inputs = json.loads((HERE / "inputs.json").read_text())
    assert shared.identity(HELPER.read_bytes()) == inputs["helper_identity"]
    frozen, retained, historical = [], {}, []
    for component, row in inputs["components"].items():
        commit = row["freeze"]
        for name in row["paths"]:
            expected = shared.identity(shared.git("show", f"{commit}:{name}"))
            assert shared.identity((ROOT / name).read_bytes()) == expected, name
            frozen.append(dict(component=component, freeze=commit, path=name, **expected))
    for manifest in inputs["component_manifests"]:
        data = shared.read(manifest)
        # Review context remains tied to its actual historical inputs; the
        # current status/index and round ledger may legitimately advance.
        for row in data.pop("historical_inputs", []):
            expected = {key: row[key] for key in ("bytes", "sha256")}
            assert shared.identity(shared.git("show", f"{row['commit']}:{row['path']}")) == expected
            historical.append(row)
        shared.collect(data, retained)
        if isinstance(data.get("files"), dict):
            for name, expected in data["files"].items():
                assert shared.identity((ROOT / name).read_bytes()) == expected, name
    for name, expected in retained.items():
        assert shared.identity((ROOT / name).read_bytes()) == expected, name
    native = shared.read("docs/evidence/retained-literal-native-completion-20261019/inputs.json")
    for row in native["repository"]:
        assert shared.identity((ROOT / row["path"]).read_bytes()) == {
            k: row[k] for k in ("bytes", "sha256")}, row["path"]

    parser = shared.read("docs/evidence/retained-cvc5-parser-options-20261020/check-result.json")
    diagnostic = shared.read("docs/evidence/retained-cvc5-diagnostic-output-20261020/result.json")
    terminal = shared.read("docs/evidence/retained-cvc5-terminal-output-20261020/result.json")
    assert parser["ordinary_statistics_fixed_bytes"] == 1103886
    assert diagnostic["warning_fixed_bytes"] == 72
    assert diagnostic["nonintegral_smt2_rational_overhead_bound"] == 9
    assert diagnostic["arithmetic_warning_coefficient"] == 72+9
    assert all(diagnostic[k] is None for k in ("K_ar", "L_ar", "D_ar"))
    assert not diagnostic["zero_warning_invariant_established"]
    assert len(terminal["signal_kinds"]) + 1 == 6
    assert terminal["conditional_single_thread_CVC5_terminal_activations"] == 6
    assert terminal["conditional_direct_text_if_P0_is_4"] == 6*(1448+4*4)
    assert not terminal["single_thread_native_relation_established"]
    assert not terminal["all_signal_entry_registry_and_conversion_preconditions_established"]
    assert all(x["weighted_O"] is None for x in (parser, diagnostic, terminal))
    assert parser["q_cvc5"] is diagnostic["q_cvc5"] is terminal["complete_solver_q"] is None

    parsed, links = [], []
    names = {row["path"] for row in frozen} | {str(Path(__file__).relative_to(ROOT))}
    for name in sorted(names):
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
    return dict(frozen_files=frozen, retained_inputs=retained, historical_review_inputs=historical,
        native_pins_unchanged=len(native["repository"]),
        conditional_ordinary_statistics_fixed_bytes=parser["ordinary_statistics_fixed_bytes"],
        conditional_warning_bound=diagnostic["arithmetic_family_conditional_bound"],
        warning_recurrence_or_exclusion_proved=False,
        conditional_terminal_entries=6, conditional_terminal_direct_bytes_P0_4=8784,
        complete_solver_q=None, weighted_O=None, whole_capacity_rule_delivered=False,
        quiet_configuration_adopted=False, production_prerequisite_satisfied=False,
        component_checker_replays=0, native_solver_compiler_proof_runs=0,
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
        retained_inputs=len(result["retained_inputs"]),
        historical_review_inputs=len(result["historical_review_inputs"]),
        native_pins_unchanged=result["native_pins_unchanged"],
        python_parses=len(result["python_parses"]), local_links=len(result["local_links"]),
        seconds=time.monotonic()-start)))
