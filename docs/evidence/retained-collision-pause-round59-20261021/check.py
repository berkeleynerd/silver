#!/usr/bin/env python3
"""Reconcile accepted comparator and R58 attachment, without component replay."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def ident(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def read(path):
    return json.loads((ROOT / path).read_text())


def check():
    manifest = json.loads((HERE / "inputs.json").read_text())
    frozen, inherited = {}, {}
    for component in manifest["components"].values():
        for name in component["paths"]:
            old = subprocess.check_output(["git", "-C", str(ROOT), "show", component["freeze"]+":"+name])
            assert (ROOT / name).read_bytes() == old, name
            frozen[name] = ident(old)
    author = read("docs/evidence/retained-why-collision-comparison-20261020/inputs.json")
    reviewer = read("docs/evidence/retained-printer-entry-collision-review-20261020/inputs.json")
    for rows in [author["files"], reviewer["inherited_files"], reviewer["author_files"]]:
        for name, expected in rows.items():
            actual = ident((ROOT / name).read_bytes())
            assert actual == expected, name
            inherited[name] = actual
    assert reviewer["author_freeze"] == manifest["components"]["author"]["freeze"]
    result = read("docs/evidence/retained-why-collision-comparison-20261020/result.json")
    checked = read("docs/evidence/retained-printer-entry-collision-review-20261020/collision-comparison-check.json")
    assert checked["author_freeze"] == reviewer["author_freeze"]
    assert checked["returncode"] == 0 and checked["result"]["ok"]
    assert checked["author_packet_unchanged"] and checked["all_author_files_exactly_equal_frozen_git_objects"]
    assert result["candidate_operand"] == "right"
    assert all(n == 0 for n in result["attributable_effect"].values())
    assert all(result["closed"].values())
    assert not result["uniform_old_work_bound_needed_for_this_counter_or_request_interface"]
    assert not result["whole_quiet_capacity"] and not result["fresh_escape_allowance"]
    local = result["context_strict_term_interface"]
    assert local["bnd_upper"] == local["private_bound_map_entries_upper"] == 8
    assert local["paired_term_entries_upper"] == local["active_frames_each_side_upper"] == 99
    assert local["private_height_arithmetic_upper"] == 10
    assert local["private_bound_insertions_both_sides_upper"] == 16
    assert local["descend_frame_probes_both_sides_upper"] == 2*99**2
    assert local["descend_lookup_calls_both_sides_upper"] == 4*99**2
    assert local["private_map_node_constructions_upper"] == 8*8*9
    post = read("docs/evidence/retained-why-postinline-preparation-20261020/result.json")
    assert post["complete_for_named_source_operation_categories"]
    assert post["R56_and_R57_preceding_charges_remain_required"]
    assert post["combined_totals"]["direct_Ident_registrations"] == 753327
    assert post["remaining"]["later_selected_transformations_and_printers"]
    native = read("docs/evidence/retained-printer-entry-collision-review-20261020/native-byte-join.json")
    assert native["retained_body_equals_installed_body"]
    assert ident(Path(native["installed_binary"]).read_bytes()) == native["installed_identity"]
    assert native["symbol_size"] == 266
    original = read("docs/evidence/retained-literal-native-completion-20261019/inputs.json")
    for row in original["repository"]:
        assert ident((ROOT / row["path"]).read_bytes()) == {k: row[k] for k in ["bytes", "sha256"]}
    parsed, links = [], 0
    for name in frozen:
        path = ROOT / name
        if path.suffix == ".py":
            ast.parse(path.read_text(), filename=name); parsed.append(name)
        if path.suffix == ".md":
            for url in re.findall(r"\]\(([^)]+)\)", path.read_text()):
                if "://" in url or url.startswith("#"):
                    continue
                assert (path.parent / url.split("#")[0]).exists(), (name, url)
                links += 1
    return {"frozen_files": frozen, "inherited_inputs": inherited,
            "native_source_pins_unchanged": len(original["repository"]),
            "installed_why_unchanged": True, "native_symbol_bytes": 266,
            "python_parses": parsed, "frozen_packet_local_links": links,
            "first_reviewer_check_seconds": checked["elapsed_seconds"],
            "comparator_attributable_effect": result["attributable_effect"],
            "original_context_local_arithmetic": local,
            "R58_original_context_attachment_independently_reviewed": True,
            "R58_registration_bound_unchanged": 753327,
            "generated_candidate_families_closed": False,
            "caller_table_and_counter_headroom_closed": False,
            "whole_capacity_rule_complete": False,
            "component_checker_replays": 0, "native_target_solver_proof_capture_runs": 0}


if __name__ == "__main__":
    start = time.perf_counter()
    result = check()
    result.update(status="pass", elapsed_seconds=time.perf_counter()-start)
    print(json.dumps(result, indent=2, sort_keys=True))
