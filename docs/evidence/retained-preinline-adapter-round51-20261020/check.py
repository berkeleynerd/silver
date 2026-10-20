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

    prefix = shared.read("docs/evidence/retained-why-preinline-prefix-20261020/result.json")
    reducer = shared.read("docs/evidence/retained-solver-response-adapter-20261020/checks.json")
    byte_design = shared.read("docs/evidence/retained-solver-response-adapter-20261020/byte-construction-checks.json")
    cases = prefix["cases"]
    assert prefix["retained_serial_seed_closure_under_named_premises"] is True
    assert prefix["intended_parallel_seed_closure"] is False
    assert prefix["intended_parallel_episode_composition_claimed"] is False
    assert prefix["episode_composition_scope"] == "Retained serial R34 continuation only"
    assert all(r["retained_serial_seed_closure_under_named_premises"] is True
               and r["intended_parallel_seed_closure"] is False for r in cases)
    assert [r["selected_goals"] for r in cases] == [64, 53, 32, 3, 1]
    assert [r["selected_ce_direct_Ident_max"] for r in cases] == [1269, 1214, 775, 436, 472]
    assert [r["selected_altergo_prefix_Ident_max"] for r in cases] == [1335, 1271, 847, 440, 477]
    assert [r["common_task_prefix_nodes"] for r in cases] == [1043, 1043, 535, 367, 433]
    assert [r["table"]["distinct_objects"] for r in cases] == [6917, 6917, 6763, 6672, 6704]
    assert all(r["table"]["complete_slot_and_graph_closure"] for r in cases)
    assert all(r["raw_goal_type_variables"] == r["ce_goal_type_variables"] == r["mono_new_type_symbols"] == 0 for r in cases)
    assert [r["compatible_old_objects"] for r in cases] == [241, 241, 69, 51, 61]
    assert sum(r["verified_binding_free_maps"] for r in cases) == 17707
    full = [150196, 122533, 39927, 3378, 1903]
    for row, bound in zip(cases, full):
        charge = row["under_named_episode_and_seed_premises"]
        assert charge["global_escape_budget"] == 2
        assert charge["full_prefix_Ident_upper"] == bound
        assert charge["post_cut_prefix_Ident_upper"] == bound - charge["already_completed_cvc5_prefix_allowance"]
    assert cases[-1]["under_named_episode_and_seed_premises"]["already_completed_cvc5_prefix_allowance"] == 472
    total = prefix["under_named_source_cache_episode_and_seed_premises"]
    assert total["full_five_process_prefix_Ident_upper"] == sum(full) == 317937
    assert total["post_five_cut_prefix_Ident_upper"] == sum(full) - 472 == 317465
    for field in ("complete_Ident_no_wrap", "complete_inline_capacity", "includes_R50_update_charge",
                  "includes_pending_callback_charge", "includes_transform_lookup_initialization",
                  "source_theorem_machine_checked"):
        assert prefix[field] is False, field
    assert prefix["native_runs"] == prefix["predecessor_replays"] == 0
    assert reducer["reachable_reducer_states"] == 106 <= reducer["reducer_state_upper_bound"] == 110
    assert reducer["canonical_rows"] == 31
    assert reducer["canonical_max_bytes"] == 76
    assert reducer["compared_eager_and_streaming_cases"] == 354312
    assert reducer["hf_with_warning_reachable"] is False
    storage = byte_design["storage"]
    assert storage["reducer_gap_states"] == 3*110 == 330
    assert storage["transform_bytes"] == 2048*330*2 == 1351680
    assert storage["total_reserved_bytes"] == 1351680 + 65536 == 1417216 < storage["limit_bytes"] == 2**21
    assert byte_design["endpoint_matrix"]["cvc5"]["finite_endpoint_cases"] == 1555
    assert byte_design["endpoint_matrix"]["z3"]["finite_endpoint_cases"] == 11111
    assert all(r["all_accounted_for"] for r in byte_design["source_shape_coverage"].values())

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
        prefix_full_charge_by_process=full, prefix_full_charge_all_processes=317937,
        prefix_post_cut_charge_all_processes=317465,
        prefix_episode_scope="Retained serial R34 continuation only",
        retained_serial_seed_closure_under_named_premises=True,
        intended_parallel_seed_closure=False,
        intended_parallel_episode_composition_claimed=False,
        canonical_response_max_bytes=76, proposed_adapter_storage_bytes=1417216,
        implemented_adapter=False, production_adapter_adopted=False,
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
