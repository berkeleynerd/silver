"""Focused offline identity/source-input/arithmetic check; no predecessor replay."""
import argparse
from collections import Counter
import json
from pathlib import Path
import time

from build_packet import HERE, ROOT, identity, source_projection
from transfer import STATUS_LABELS, compose, table_transfer


def read(path):
    return json.loads(path.read_text())


def applications():
    index = read(ROOT / "docs/evidence/retained-why-save-entry-inputs-20261020/entry-inputs.json")
    scheduler = read(ROOT / "docs/evidence/retained-producer-driver-envelope-20261018/result.json")
    sched = {x["name"]: x for x in scheduler["cases"]}
    result = []
    for row in index["cases"]:
        x = read(ROOT / "docs/evidence/retained-why-save-entry-inputs-20261020" / row["path"])
        s = sched[row["case"]]
        assert x["configuration"]["input_identity"]["sha256"] == s["input_sha256"]
        assert x["pid"] == row["pid"]
        assert x["configuration"]["selected_provers"] == ["cvc5", "z3", "altergo"]
        occurrences = x["forest"]["source_order_entries"]
        visits = Counter(v["value"] for v in occurrences if v["kind"] == "goal")
        counts = x["forest"]["visit_counts"]
        kinds = Counter(v["kind"] for v in occurrences)
        assert all(kinds[k] == counts[k] for k in ("goal", "theory", "file", "transformation"))
        assert sum(visits.values()) == row["G"] == counts["goal"]
        assert set(visits) == set(map(int, x["goals"]))
        assert len({v["attempts_table"] for v in x["goals"].values()}) == len(x["goals"])
        ax = sum(visits[int(k)] * len(g["attempt_memberships"]) for k, g in x["goals"].items())
        a = len(x["attempts"]["stats_bindings"])
        ids = {pa["id"] for pa in x["attempts"]["stats_bindings"]}
        assert all(m["attempt_id"] in ids for g in x["goals"].values() for m in g["attempt_memberships"])
        assert ax == row["A_xml"] and a == row["A_stats"]
        assert all(pa["proof_script_word"] == 1 and pa["proof_script"] is None
                   for pa in x["attempts"]["stats_bindings"])
        # Preserve every traversal occurrence. This also checks this fixed
        # packet's sharper multiplicity=1 fact, without hardcoding it in compose.
        trans = [v["value"] for v in occurrences if v["kind"] == "transformation"]
        args = sum(len(x["transformations"][str(t)]["args"]) for t in trans)
        selected = len(x["configuration"]["selected_provers"])
        assert s["distinct_task_driver_pair_upper"] == selected * s["registered_task_upper"]
        inputs = {
            "A_stats0": a, "A_xml0": ax,
            "pair_entries": s["distinct_task_driver_pair_upper"],
            "selected_provers": selected,
            "prover_domain0_upper": x["attempts"]["P_stats_upper"],
            "max_goal_multiplicity": max(visits.values(), default=0),
            "next_attempt_id0": x["session_next_ids"]["proof_attempt"],
            "G": counts["goal"], "T": len(trans), "Th": counts["theory"],
            "F": counts["file"], "Args": args, "all_scripts_none": True,
        }
        output = compose(inputs, signal_contract=True)
        assert output["next_attempt_id_upper"] is None
        result.append({
            "case": x["case"], "pid": x["pid"], "phase": x["phase"],
            "application_kind": "conditional arithmetic: the continued signal condition is assumed, not discharged by this checker",
            "input_sha256": s["input_sha256"], "inputs": inputs,
            "conditional_transfer": output,
            "initial_goal_attempt_binding_counts": {
                k: len(v["attempt_memberships"]) for k, v in x["goals"].items()},
        })
    assert sum(c["inputs"]["pair_entries"] for c in result) == 459
    assert all(c["inputs"]["max_goal_multiplicity"] == 1 for c in result)
    assert all(c["inputs"]["T"] == 1 and c["inputs"]["Args"] == 0 for c in result)
    return result


def focused_checks(cases):
    x = cases[0]["inputs"]
    missing = compose(x)
    assert missing["remaining_all_save_entries_upper"] is None
    assert missing["new_table_bindings_upper"]["session_prover_ids"] is None
    assert missing["usable_attempt_visit_bounds"] is None
    repeated = compose({**x, "max_goal_multiplicity": 3}, signal_contract=True)
    assert repeated["conditional_A_xml_upper"] == x["A_xml0"] + 3 * (x["pair_entries"] + 2)
    assert repeated["conditional_A_stats_upper"] == x["A_stats0"] + x["pair_entries"] + 2
    assert missing["conditional_A_stats_upper"] is None
    distinct = table_transfer({"binding_visits": 11, "size": 3, "capacity": 8}, 6)
    assert distinct["binding_visits_upper"] == 17 and distinct["size_upper"] == 9
    assert table_transfer({"binding_visits": 10, "size": 10, "capacity": 8}, 6)["no_resize_arithmetic"]
    assert not table_transfer({"binding_visits": 10, "size": 10, "capacity": 8}, 7)["no_resize_arithmetic"]
    assert not table_transfer({"binding_visits": 0, "size": 0, "capacity": 16}, 48)["no_resize_arithmetic"]
    assert table_transfer(None, 6)["binding_visits_upper"] is None
    # Check the finite charging abstraction: genuine misses add previously
    # absent keys; each exceptional/stale duplicate spends one global token.
    # This checks arithmetic and the necessity of the token term, not its
    # source refinement or the native interruption theorem.
    states = {(frozenset(), 0, 0)}
    for _ in range(8):
        successors = set(states)
        for keys, spent, additions in states:
            assert additions <= len(keys) + spent
            for key in range(3):
                if key not in keys:
                    successors.add((keys | {key}, spent, additions + 1))
                elif spent < 2:
                    successors.add((keys, spent + 1, additions + 1))
        states = successors
    assert max(a for _, _, a in states) == 5
    assert any(a > len(k) for k, _, a in states)
    assert max(map(len, STATUS_LABELS)) == 17
    return {"unknown_signal_budget_stays_unknown": True,
            "missing_table_state_stays_unknown": True,
            "forest_multiplicity_preserved": True,
            "visits_size_capacity_kept_separate": True,
            "no_resize_boundary_checked": True,
            "theory_status_capacity16_growth48_rejected": True,
            "monotone_key_charging_states": len(states),
            "naive_unique_key_bound_has_counterexample": True}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--write-applications", action="store_true")
    args = parser.parse_args()
    start = time.monotonic()
    manifest = read(HERE / "inputs.json")
    for name, wanted in manifest["files"].items():
        assert identity((ROOT / name).read_bytes()) == wanted, name
    excerpts, census = source_projection()
    assert excerpts == read(HERE / "source-excerpts.json")
    assert census == read(HERE / "source-census.json")
    previous = read(ROOT / "docs/evidence/retained-producer-driver-envelope-20261018/inputs.json")
    for name, entry in excerpts.items():
        relative = name.removeprefix("why3/")
        if relative in previous["source_identities"]:
            assert entry["full_member_identity"] == previous["source_identities"][relative]
    text = "\n".join(r["text"] for v in excerpts.values() for r in v["ranges"])
    assert all('"' + s + '"' in text for s in STATUS_LABELS)
    assert "if element = ProverStarted && blocking then" in text
    assert "let blocking = true" in text
    cases = applications()
    if args.write_applications:
        (HERE / "applications.json").write_text(json.dumps(cases, indent=2) + "\n")
    else:
        assert cases == read(HERE / "applications.json")
    checks = focused_checks(cases)
    result = {
        "success": True, "cases": len(cases), "checked_input_files": len(manifest["files"]),
        "source_members": len(excerpts), "checks": checks,
        "elapsed_seconds": time.monotonic() - start,
        "new_native_runs": 0, "predecessor_checker_replays": 0,
        "capture_replays": 0, "binder_recomputations": 0, "source_fetches": 0,
        "native_table_contract_discharged_here": False,
        "whole_save_capacity_closed": False,
    }
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
