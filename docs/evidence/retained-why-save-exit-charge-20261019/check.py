#!/usr/bin/env python3
"""Check this packet's bindings/arithmetic; does not prove OCaml semantics."""
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def main():
    start = time.monotonic()
    inputs = read(HERE / "inputs.json")
    for path, expected in inputs["dependencies"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    for path, expected in inputs["local_inputs"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path

    sources = read(HERE / "source-excerpts.json")
    assert len({r["id"] for r in sources}) == len(sources)
    archives = {}
    reconstructed = []
    try:
        for row in sources:
            path = row["archive"]
            if path not in archives:
                archives[path] = tarfile.open(ROOT / path)
            data = archives[path].extractfile(row["member"]).read()
            assert identity(data) == row["member_identity"], row["id"]
            lines = data.decode().splitlines(keepends=True)
            first, last = row["first_line"], row["last_line"]
            assert 1 <= first <= last <= len(lines)
            excerpt = "".join(lines[first - 1:last])
            assert identity(excerpt.encode()) == row["excerpt_identity"]
            reconstructed.append(
                f"=== {row['id']}: {row['member']}:{first}-{last} ===\n"
                + excerpt + "\n")
    finally:
        for archive in archives.values():
            archive.close()
    assert (HERE / "source-excerpts.txt").read_bytes() == ("".join(reconstructed) + "=== END ===\n").encode()
    assert b"\r" not in (HERE / "source-excerpts.txt").read_bytes()

    ledger = read(HERE / "effect-ledger.json")
    source_ids = {r["id"] for r in sources}
    for row in ledger:
        assert row["source_refs"] and set(row["source_refs"]) <= source_ids
        assert row["entry"] and row["continuation"] and row["leaves"]
    by_id = {r["id"]: r for r in ledger}
    assert len(by_id) == len(ledger)
    reports = read(HERE / "report-sites.json")
    site_order = {r["id"]: i for i, r in enumerate(reports["sites"])}
    assert len(site_order) == len(reports["sites"]) == 6
    for row in reports["sites"]:
        assert set(row["source_refs"]) <= source_ids
        for target in row.get("forward_on_report_failure", []) + row.get("forward_on_success", []):
            assert site_order[target] > site_order[row["id"]]
    assert reports["within_report"]["maximum_why_wrapper_depth"] == 2
    assert reports["signal_attempts_upper"] == 2

    evidence = ROOT / "docs/evidence"
    counter = read(evidence / "retained-why-inline-identifier-state-20261018/result.json")
    rep = read(evidence / "retained-why-inline-representative-state-20261018/result.json")
    binder = read(evidence / "retained-why-session-save-state-20261019/binder-certificate.json")
    signals = read(evidence / "retained-why-callback-launch-20261018/result.json")
    atoms = read(evidence / "retained-why-session-save-outcomes-20261019/atom-certificate.json")
    initial = counter["registration_transfer"]["initial"]
    baseline = counter["registration_transfer"]["registrations_upper"]
    assert (initial, baseline) == (60496, 1145)
    assert baseline == 235 + 6 * 123 + 4 + 168
    assert rep["attached_local_demands"]["events"]["all_fresh_identifier_registrations_upper"] == baseline
    assert binder["B_binders"] == 966
    assert signals["conditional_save_entry_upper"] == 2
    assert atoms["term_constructor_counts"].get("Tcase", 0) == 0
    assert atoms["pattern_pointers"] == []
    assert len(atoms["formula_roots"]) == 66

    original_type_nodes = rep["representative_envelope"]["type_occurrence_nodes"]
    working_type_nodes = rep["attached_local_demands"]["structural"]["instantiated_type_occurrences_upper"]
    assert (original_type_nodes, working_type_nodes) == (3, 9)
    diagnostic_nodes = working_type_nodes * working_type_nodes
    diagnostic_pair_nodes = diagnostic_nodes + working_type_nodes
    # The prose proves that type instantiation preserves the applied symbols.
    type_arity = original_type_nodes - 1
    tuple_probes_per_node = 2
    identifiers_per_tuple_miss = type_arity + 1
    pretty_charge = diagnostic_pair_nodes * tuple_probes_per_node * identifiers_per_tuple_miss
    assert pretty_charge == by_id["diagnostic"]["identifier_charge"]["per_matching_pretty_attempt"] == 540

    # Explicit finite registry recurrence, including unsuccessful attempts.
    exn_attempts, printexc_attempts = [2], [1]
    for _ in range(2):
        printexc_attempts.append(exn_attempts[-1])
        exn_attempts.append(2 * exn_attempts[-1])
    assert exn_attempts == [2, 4, 8] and printexc_attempts == [1, 2, 4]
    root_calls = by_id["report_sites"]["identifier_charge"]["root_reports"]
    assert root_calls == 6
    assert by_id["registry"]["identifier_charge"]["pretty_attempts_per_report"] == exn_attempts[-1]
    diagnostic_charge = root_calls * exn_attempts[-1] * pretty_charge
    constant_component = initial + baseline + signals["conditional_save_entry_upper"] * binder["B_binders"] + diagnostic_charge
    assert (diagnostic_charge, constant_component) == (25920, 89493)

    result = {
        "status": "source_bindings_and_conditional_arithmetic_passed",
        "source_excerpts": len(sources), "effect_rows": len(ledger),
        "capture_run": inputs["capture"]["run"], "capture_pid": inputs["capture"]["pid"],
        "conditional_components": {
            "initial_counter": initial, "accounted_first_fold": baseline,
            "save_attempts_upper": 2, "save_binders_per_attempt": 966,
            "direct_ocaml_save_exit_nonbinder": 0,
            "first_fold_returning_continuation_excess": 0,
            "diagnostic_type_nodes": diagnostic_nodes,
            "diagnostic_type_pair_nodes": diagnostic_pair_nodes,
            "identifiers_per_pretty_attempt": pretty_charge,
            "pretty_attempts_per_outer_report": exn_attempts[-1],
            "outer_report_calls_upper": root_calls,
            "whole_interval_reporting_D": diagnostic_charge,
            "counter_interface": "counter_end <= 89493 + N_native",
            "native_charge_N_native": None,
        },
        "endpoint": {
            "normal": "first selected invocation return, before later driver printing/transform",
            "handled_failure": "return from its failure-report callback, before next scheduler invocation",
            "uncaught": "completion/termination of the one uncaught-handler wrapper",
            "scheduler_exit": "before transition into ordinary ending save",
            "ordinary_ending_forest_and_reentrant_save_covered": False,
            "later_scheduled_invocations_covered": False,
        },
        "native_effect_preservation_obligation": "OPEN",
        "exception_family_conditional_on_native_effect_closure": True,
        "source_argument_machine_checked": False,
        "complete_R": None, "unconditional_counter_endpoint": None,
        "counter_no_wrap_established": False,
        "native_runs": 0, "old_checker_replays": 0, "global_censuses": 0,
        "checker_seconds": time.monotonic() - start,
    }
    (HERE / "result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({k: result[k] for k in ("status", "source_excerpts", "effect_rows", "checker_seconds")}))


if __name__ == "__main__":
    main()
