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

    prefix = shared.read("docs/evidence/retained-quiet-prefix-transfer-20261020/result.json")
    lexer = shared.read("docs/evidence/retained-quiet-prefix-transfer-20261020/lexer-account.json")
    origin = shared.read("docs/evidence/retained-cvc5-task-acceptance-20261020/result.json")
    review = shared.read("docs/evidence/retained-quiet-task-prefix-review-20261020/result.json")
    assert prefix["allocation_delta_upper_words"] == prefix["remembered_entry_allowance"] == 4096
    assert review["allocation_upper_words"] == 2180 < 4096
    counts = [136844, 121505, 77806, 59035, 60496]
    assert [row["initial_registration_count_preserved"] for row in prefix["later_capture_cases"]] == counts
    for row in prefix["later_capture_cases"]:
        assert row["candidate_minor_upper"] == row["minor_words"] + 4096 < 2**28
        for key, value in row["table_used"].items():
            assert row["candidate_table_upper"][key] == value + 4096 < 2**25
    assert max(row["candidate_minor_upper"] for row in prefix["later_capture_cases"]) == 127943827
    older = prefix["older_fixed_tail_transfer"]
    assert older["W_upper"] == 128851857
    assert older["B_upper"] == 131047850
    assert older["byte_length_arithmetic_upper"] == 16*older["B_upper"] + 2 == 2096765602
    assert origin["reachable_module_count"] == 47
    assert origin["reachable_dependency_edges"] == 66
    assert origin["direct_driver_metadata_loop_identifier_registrations"] == 0
    assert origin["float80_template_origin_excluded_under_named_relation"]
    assert not origin["continuing_identifier_inequality_instantiated"]
    assert not origin["earlier_inline_charge_reattached_to_fresh_prepared_graph_here"]
    assert prefix["complete_q"] is prefix["weighted_O"] is origin["complete_q"] is None
    assert not prefix["source_simulation_machine_checked"]
    assert not prefix["exact_heap_identity_claimed"]
    assert not prefix["production_adopted"]
    assert not review["whole_capacity_goal_complete"]

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
        command_byte_delta=123, prefix_delta_words=4096, calculated_delta_words=2180,
        initial_registration_counts=counts, reachable_modules=47, dependency_edges=66,
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
