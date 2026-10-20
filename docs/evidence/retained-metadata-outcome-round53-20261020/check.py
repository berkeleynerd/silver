#!/usr/bin/env python3
"""Reconcile frozen R53 evidence without replaying component checks."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads((ROOT / path).read_text())


def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])


def check():
    manifest = json.loads((HERE / "inputs.json").read_text())
    assert not manifest["review_freeze_pending"]
    assert "review" in manifest["components"]
    frozen, retained = [], {}
    for component, row in manifest["components"].items():
        for name in row["paths"]:
            expected = identity(git("show", f"{row['freeze']}:{name}"))
            assert identity((ROOT / name).read_bytes()) == expected, name
            frozen.append(dict(component=component, path=name, **expected))

    def collect(value):
        if isinstance(value, list):
            for item in value:
                collect(item)
        elif isinstance(value, dict):
            for name, item in value.items():
                if (name.startswith("docs/") and ":" not in name
                        and isinstance(item, str) and re.fullmatch(r"[0-9a-f]{64}", item)):
                    expected = identity((ROOT / name).read_bytes())
                    assert expected["sha256"] == item, name
                    assert name not in retained or retained[name] == expected, name
                    retained[name] = expected
                if (name.startswith("docs/") and ":" not in name
                        and isinstance(item, dict)
                        and "bytes" in item and "sha256" in item):
                    expected = {k: item[k] for k in ("bytes", "sha256")}
                    assert name not in retained or retained[name] == expected, name
                    retained[name] = expected
                collect(item)
            name = value.get("path", "")
            item = value.get("identity", value)
            if (name.startswith("docs/") and ":" not in name
                    and "bytes" in item and "sha256" in item):
                expected = {k: item[k] for k in ("bytes", "sha256")}
                assert name not in retained or retained[name] == expected, name
                retained[name] = expected

    for name in manifest["component_manifests"]:
        contents = read(name)
        collect(contents)
        for relative, expected in contents.get("local_files", {}).items():
            path = Path(name).parent / relative
            assert identity((ROOT / path).read_bytes()) == expected, str(path)
    for name, expected in retained.items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    native = read("docs/evidence/retained-literal-native-completion-20261019/inputs.json")
    for row in native["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            k: row[k] for k in ("bytes", "sha256")}, row["path"]

    packet = "docs/evidence/retained-why-parallel-residual-transfer-20261020/"
    domains = [
        ("first-domain-replay.json", "first-domain-correspondence-result.json", 33),
        ("input-is-valid-replay.json", "input-is-valid-correspondence.json", 5),
        ("put-line-replay.json", "put-line-correspondence.json", 65),
        ("put-replay.json", "put-correspondence.json", 54),
        ("is-message-replay.json", "is-message-correspondence.json", 4),
    ]
    rows = []
    for replay_name, join_name, tasks in domains:
        replay, join = read(packet + replay_name), read(packet + join_name)
        assert replay["status"] == "pass" and replay["native_J"] == 12
        assert replay["exact_output_files"] == 9
        assert replay["solver_launches"] == replay["preparation_entries"] == 0
        assert not replay["full_Hsdecl_captured"]
        assert join["exact_tags_and_immediates_equal"] and join["sharing_bijection"]
        assert join["raw_tasks"] == tasks
        rows.append(dict(case=join["case"], raw_tasks=tasks,
            declaration_pairs=join["declaration_pairs"], read_rows=replay["read_rows"],
            exact_output_files=replay["exact_output_files"]))
    assert sum(row["raw_tasks"] for row in rows) == 161
    outcome = read("docs/evidence/retained-adapter-outcome-interface-20261020/result.json")
    assert outcome["status"] == "pass" and outcome["source_slices"] == 42
    assert (outcome["frame_bytes"], outcome["receiver_bytes"],
            outcome["maximum_canonical_bytes"], outcome["canonical_rows"]) == (64,65,76,31)
    for condition in ["late_duplicate_blocks_final_confirmation", "queued_duplicate_blocks_seal",
            "native_fact_gate_required", "schema_is_not_ABI_validation", "mixed_H_needs_join"]:
        assert outcome["checks"][condition] > 0
    launch = read("docs/evidence/retained-adapter-launch-output-20261020/result.json")
    assert launch["errno_lookup"]["count"] == len(launch["errno_strings"]) == 134
    assert launch["error_string_max"] == 49 and launch["unknown_error_max"] == 25
    assert launch["group_diagnostic_fixed_bytes"] + 49 == 87
    assert launch["exec_diagnostic_fixed_bytes"] + 49 == 72
    assert not launch["complete_adapter_startup_bound"] and launch["complete_q"] is None
    assert not launch["production_adopted"]
    native_launch = read("docs/evidence/retained-adapter-launch-output-20261020/inputs.json")
    for row in native_launch["native_inputs"]:
        assert identity(Path(row["path"]).read_bytes()) == {k:row[k] for k in ("bytes","sha256")}
    parsed, links = [], []
    for name in sorted({row["path"] for row in frozen} | {str(Path(__file__).relative_to(ROOT))}):
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
        native_pins_unchanged=len(native["repository"]),
        launch_native_inputs_unchanged=len(native_launch["native_inputs"]),
        metadata_domains=rows, metadata_projection_files=sum(r["exact_output_files"] for r in rows),
        raw_graph_visits=161, scheduler_registered_tasks=153,
        native_observation_client_server_jobs=12, stored_parallel_family_closed=False,
        remaining_parallel_keys=13, complete_parallel_mutable_state_attachment=False,
        publication_protocol_scope="conditional source argument with final audit seal and separate native refinement",
        request_to_report_leaf_map_established=False, adapter_startup_bound_established=False,
        complete_q=None, whole_capacity_rule_delivered=False,
        global_save_callbacks_per_process=2, global_saves_per_process=3,
        global_signal_escape_budget_per_process=2, added_signal_allowance=0,
        component_checker_replays=0, integration_native_solver_compiler_proof_capture_runs=0,
        production_configuration_changed=False, production_adapter_adopted=False,
        python_parses=parsed, local_links=links)


if __name__ == "__main__":
    start=time.monotonic();result=check();output=HERE/"integration-result.json"
    if output.exists():
        assert result == json.loads(output.read_text())
    else:
        output.write_text(json.dumps(result,indent=2)+"\n")
    print(json.dumps(dict(status="pass", frozen_files=len(result["frozen_files"]),
        retained_inputs=len(result["retained_inputs"]), native_pins_unchanged=result["native_pins_unchanged"],
        metadata_domains=len(result["metadata_domains"]), metadata_projection_files=result["metadata_projection_files"],
        python_parses=len(result["python_parses"]),local_links=len(result["local_links"]),
        seconds=time.monotonic()-start)))
