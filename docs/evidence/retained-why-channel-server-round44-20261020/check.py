#!/usr/bin/env python3
"""Reconcile frozen channel/server attachments without replaying their checkers."""
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
spec.loader.exec_module(shared)  # Definitions only; neither check() nor main runs.


def check():
    inputs = json.loads((HERE / "inputs.json").read_text())
    frozen, retained = [], {}
    assert shared.identity(HELPER.read_bytes()) == inputs["helper_identity"]
    for component, commit in inputs["freezes"].items():
        names = shared.git("diff-tree", "--no-commit-id", "--name-only", "-r", commit)
        for name in names.decode().splitlines():
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

    channel = shared.read("docs/evidence/retained-why-standard-channel-attachment-20261020/result.json")
    old_channel = shared.read("docs/evidence/retained-why-standard-channel-capacity-20261020/result.json")
    server = shared.read("docs/evidence/retained-why-server-record-capacity-20261020/result.json")
    attachment = shared.read("docs/evidence/retained-why-server-record-capacity-20261020/attachment.json")
    schema = shared.read("docs/evidence/retained-why-standard-json-inputs-20261020/transfer.json")
    occurrences = shared.read("docs/evidence/retained-why-diagnostic-occurrences-20261020/result.json")
    expansion = shared.read("docs/evidence/retained-why-diagnostic-expansion-20261020/result.json")
    assert channel["selected_controlled_prefix_X_pre"] == 0
    assert channel["prospective_pipe_constructor_q"] == -1
    assert channel["prospective_guard"] == "X_pre + X_suffix <= 2^63 for each channel"
    for key in ("actual_inherited_descriptor_service_attached", "universal_pre_admission_prefix_attached",
                "post_execution_certificate_is_pre_admission_rule", "production_launcher_implemented",
                "physical_capacity", "native_stack_capacity", "complete_exit_capacity",
                "issue_119_complete", "issue_153_complete", "global_budget_reset"):
        assert channel[key] is False, key
    assert (channel["maximum_suffix_save_callbacks"], channel["maximum_suffix_saves"],
            channel["maximum_suffix_escaping_save_exceptions"]) == (2, 3, 2)
    assert server["prefix_safe_line_formula_excluding_LF"] == "C+60+8N"
    assert server["generic_offered_request_Q_line_formula_excluding_LF"] == "Q+C+40"
    assert server["actual_O"] is None and server["whole_JSON_B_E"] is None
    for key in ("complete_R", "complete_U", "complete_server_capacity",
                "protocol_liveness_established", "server_receive_preservation_attached",
                "issue_119_or_153_complete"):
        assert server[key] is False, key
    joined = []
    rows = zip(channel["cases"], old_channel["cases"], attachment["cases"],
               schema["cases"], occurrences["cases"], expansion["cases"], strict=True)
    for entry, old, protocol, js, outer, dispatch in rows:
        ids = {(r["case"].lower(), r["pid"]) for r in (entry, old, protocol, js, outer, dispatch)}
        assert len(ids) == 1
        for name, state in entry["channels"].items():
            assert name in ("stdout", "stderr")
            assert state["source_derived_P0"] == state["X_pre_source_at_this_controlled_cut"] == 0
            assert state["source_derived_O0"] == "constructor lseek result q"
            assert state["conditional_root_and_buffer_ownership"] is True
            for key in ("observed_P0", "observed_O0", "actual_constructor_q", "actual_fd_kind",
                        "actual_fd_live", "actual_offset_guard", "usable_standard_channel_bound"):
                assert state[key] is None, key
            assert state["positive_write_service_attached"] is False
            assert old["standard_channel_entry"][name]["P0"] is None
        z = js["conditional_inputs"]
        for key in ("R", "G", "A", "N"):
            assert protocol[key] == z[key], key
        assert protocol["N"] == outer["under_named_existing_relation"]["scheduling_owners_upper"]
        assert protocol["source_protocol_message_attempts_upper"] == protocol["N"]
        c, n = protocol["C_launch"], protocol["N"]
        assert len(protocol["server_launch"]["cwd"].encode()) == c
        assert protocol["raw_ID_upper_with_abandoned_request_prefixes"] == 20+8*n
        m = c+60+8*n
        assert protocol["prefix_safe_line_upper_if_C_is_launch_length"] == m
        assert protocol["prefix_safe_recv_concatenation_upper_if_C_is_launch_length"] == m+1024
        assert protocol["prefix_safe_InvalidAnswer_direct_text_upper_if_C_is_launch_length"] == m+23
        assert protocol["all_InvalidAnswer_branch_direct_text_upper_conditional"] == (m+23)*256*dispatch["outer_calls_upper"]
        for key in ("actual_O", "actual_solver_file_upper"):
            assert protocol[key] is None, key
        for key in ("current_dir_value_observed", "pinned_solver_executable_resolution_attached",
                    "server_receive_preservation_attached"):
            assert protocol[key] is False, key
        joined.append(dict(case=entry["case"], pid=entry["pid"], controlled_source_P0=0,
            controlled_source_O0="q", conditional_server_line=m,
            actual_descriptor_and_solver_output_attached=False))

    copy = shared.read("docs/evidence/retained-why-server-buffer-copy-20261020/result.json")
    assert copy["server"]["symbol"] == "memcpy@GLIBC_2.14"
    assert copy["server"]["identity"] == dict(bytes=96904,
        sha256="143e182d167d3e290c974770d0b84b5f59cf70bf331de5208a36bd650b386a80")
    assert copy["libc"]["normalized_identical"] is True
    assert copy["libc"]["resolver_bytes_each"] == 257
    assert len(copy["libc"]["returned_targets"]) == 13
    for key in ("selected_runtime_target", "historical_server_loaded_libc", "historical_server_GOT"):
        assert copy["libc"][key] is None, key
    for key in ("generic_C_memcpy_overlap_valid", "actual_overlap_observed", "actual_corruption_observed",
                "source_undefined_behavior_removed", "selected_server_runtime_binding_observed",
                "universal_binary_refinement", "server_stream_preservation_unconditional",
                "complete_server_capacity"):
        assert copy[key] is False, key

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
        native_pins_unchanged=len(native["repository"]), case_joins=joined,
        conditional_native_copy_bridge=copy["native_bridge"],
        actual_server_stream_preservation_attached=False,
        python_parses=parsed, local_links=links, component_checker_replays=0,
        new_target_runs=0, complete_save_exit=False, whole_pipeline_capacity=False)


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
