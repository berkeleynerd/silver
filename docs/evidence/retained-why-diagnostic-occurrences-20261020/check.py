#!/usr/bin/env python3
"""Focused comparison only; no target, disassembly, fetch or earlier checker.

The source argument is in the research note. Arithmetic and source attachment
checks do not establish reachability or the remaining wrapper-depth theorem.
"""
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
OCAML = "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
LIBRARY = "docs/evidence/retained-producer-prefix-gc-20261018/dimensions-sources.tar.gz"
OCAML_PREFIX = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"
EXCERPTS = [
    (WHY, "why3/src/gnat/gnat_main.ml", 95, 116),
    (WHY, "why3/src/gnat/gnat_main.ml", 270, 309),
    (WHY, "why3/src/gnat/gnat_main.ml", 331, 360),
    (WHY, "why3/src/gnat/gnat_util.ml", 1, 24),
    (WHY, "why3/src/gnat/gnat_report.ml", 34, 46),
    (WHY, "why3/src/gnat/gnat_report.ml", 224, 234),
    (WHY, "why3/src/gnat/gnat_scheduler.ml", 1, 28),
    (WHY, "why3/src/session/controller_itp.ml", 412, 440),
    (WHY, "why3/src/session/controller_itp.ml", 448, 491),
    (WHY, "why3/src/session/controller_itp.ml", 517, 536),
    (WHY, "why3/src/session/controller_itp.ml", 592, 652),
    (WHY, "why3/src/session/session_itp.ml", 298, 308),
    (WHY, "why3/src/session/session_itp.ml", 354, 363),
    (WHY, "why3/src/session/session_itp.ml", 813, 878),
    (WHY, "why3/src/session/session_itp.ml", 1588, 1637),
    (WHY, "why3/src/session/session_itp.ml", 1670, 1684),
    (WHY, "why3/src/session/session_itp.ml", 1770, 1791),
    (WHY, "why3/src/driver/call_provers.ml", 478, 499),
    (WHY, "why3/src/driver/call_provers.ml", 534, 565),
    (WHY, "why3/src/driver/driver.ml", 391, 408),
    (WHY, "why3/src/driver/driver.ml", 456, 494),
    (WHY, "why3/src/core/printer.ml", 196, 234),
    (WHY, "why3/src/core/printer.ml", 299, 407),
    (WHY, "why3/src/printer/smtv2.ml", 260, 279),
    (WHY, "why3/src/printer/smtv2.ml", 382, 417),
    (WHY, "why3/src/printer/smtv2.ml", 736, 765),
    (WHY, "why3/src/printer/smtv2.ml", 855, 904),
    (WHY, "why3/src/printer/smtv2.ml", 1061, 1082),
    (WHY, "why3/src/parser/lexer.mll", 55, 71),
    (WHY, "why3/src/util/lexlib.mll", 159, 168),
    (WHY, "why3/src/util/exn_printer.ml", 11, 52),
    (WHY, "why3/src/util/loc.ml", 298, 360),
    (WHY, "why3/src/mlw/pmodule.ml", 412, 478),
    (WHY, "why3/src/mlw/pmodule.ml", 1382, 1396),
    (WHY, "why3/src/core/pretty.ml", 1011, 1022),
    (WHY, "why3/src/core/trans.ml", 367, 393),
    (WHY, "why3/src/core/trans.ml", 561, 566),
    (OCAML, OCAML_PREFIX + "stdlib/printexc.ml", 307, 367),
    (OCAML, OCAML_PREFIX + "runtime/printexc.c", 138, 162),
    (OCAML, OCAML_PREFIX + "stdlib/fun.ml", 21, 38),
]


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def encoded(value):
    return (json.dumps(value, indent=2, sort_keys=True) + "\n").encode()


def read(relative):
    return json.loads((ROOT / relative).read_text())


def witnesses():
    rows = []
    for archive in (WHY, OCAML):
        with tarfile.open(ROOT / archive) as tar:
            for selected_archive, member, first, last in EXCERPTS:
                if selected_archive != archive:
                    continue
                raw = tar.extractfile(member).read()
                lines = raw.decode().splitlines(keepends=True)
                assert 1 <= first <= last <= len(lines), member
                text = "".join(lines[first-1:last])
                rows.append(dict(archive=archive, member=member,
                                 member_identity=identity(raw), first=first,
                                 last=last, text=text,
                                 excerpt_identity=identity(text.encode())))
    return rows


def library_directives():
    inventory = read("docs/evidence/retained-why-path-input-inventory-20261020/library-inventory.json")
    rows = []
    with tarfile.open(ROOT / LIBRARY) as tar:
        for f in inventory["files"]:
            raw = tar.extractfile(f["member"]).read()
            assert identity(raw) == f["identity"]
            count = raw.count(b"[#")
            assert count == 0
            rows.append(dict(member=f["member"], identity=identity(raw),
                             position_directive_prefix_occurrences=count))
    assert len(rows) == 4
    return rows


def raw_clients():
    inventory = read("docs/evidence/retained-why-disabled-backtrace-20261020/source-client-inventory.json")
    classification = {
        ("why3/src/bddinfer/why3infer.ml", 1537): "unselected inference frontend",
        ("why3/src/bddinfer/why3infer.ml", 1547): "unselected inference frontend",
        ("why3/src/gnat/gnat_util.ml", 14): "raw_string at most one",
        ("why3/src/ide/gconfig.ml", 25): "unselected IDE",
        ("why3/src/ide/why3ide.ml", 125): "unselected IDE",
        ("why3/src/mlw/pinterp.ml", 43): "callstack inspection, not covered raw diagnostic input; RAC unselected",
        ("why3/src/session/session_itp.ml", 859): "raw_print at most global e",
        ("why3/src/session/session_itp.ml", 1598): "old-session merge excluded",
        ("why3/src/session/session_itp.ml", 1679): "comment",
        ("why3/src/session/session_itp.ml", 1784): "comment",
        ("why3/src/transform/reduction_engine.ml", 1576): "accepted selected normalization exclusion",
        ("why3/src/trywhy3/why3_worker.ml", 53): "unselected browser frontend",
    }
    rows = inventory["why"]["matches"]["diagnostic_and_callstack_clients"]
    assert {(r["member"], r["line"]) for r in rows} == set(classification)
    return [dict(r, disposition=classification[(r["member"], r["line"])]) for r in rows]


def result():
    writer = read("docs/evidence/retained-why-path-writer-capacity-20261020/result.json")
    channel = read("docs/evidence/retained-why-channel-exit-bound-20261020/result.json")
    backtrace = read("docs/evidence/retained-why-disabled-backtrace-20261020/result.json")
    assert backtrace["raw_string_direct_object_request_bytes_upper"] == 1112
    assert backtrace["raw_print_direct_object_request_bytes_upper"] == 80
    assert backtrace["print_direct_requested_bytes_upper"] == 59
    assert backtrace["per_active_diagnostic_native_projection_with_bridge_bytes"] == 5016
    assert backtrace["global_postcut_signals_upper"] == 2
    assert backtrace["global_postcut_saves_upper"] == 3
    cases = []
    for row, channels in zip(writer["cases"], channel["cases"], strict=True):
        a = row["under_named_existing_premises"]["dispatch_bounds"]["preparation_episodes_intersecting_suffix_upper"]
        assert a == 3 * row["registered_goals_upper"] + 2
        assert row["case"] == channels["case"]
        assert a == channels["preparation_episodes_upper"]
        counts = dict(
            scheduling_owners_upper=a,
            build_internal_failure_reports_upper=a,
            idle_internal_failure_reports_upper=a,
            main_exception_reports_upper=1,
            custom_uncaught_exception_reports_upper=1,
            outer_exn_printer_calls_upper=2*a+2,
            outer_printexc_to_string_calls_upper=2,
            combined_outer_report_calls_upper=2*a+4,
            normal_json_invocations_upper=1,
            abort_json_invocations_upper=2,
            printer_integer_failure_stderr_calls_upper=a,
            smtv2_model_parser_stderr_calls_upper=0,
            fallback_stderr_exception_header_calls_upper=2,
            fallback_out_of_memory_line_calls_upper=1,
            fallback_explicit_stderr_flush_calls_upper=1,
            session_missing_parent_raw_print_calls_upper=2,
            n_raw_string_invocations_upper=1,
            m_raw_print_invocations_upper=4,
            d_simultaneous_covered_raw_invocations_upper=1,
            backtrace_direct_object_requests_bytes_upper=1112+4*80,
            backtrace_direct_channel_calls_upper=4,
            backtrace_direct_channel_bytes_upper=4*59,
            backtrace_returned_string_length_upper=59,
            backtrace_active_native_projection_bytes_upper=5016,
        )
        cases.append(dict(case=row["case"], pid=row["pid"],
                          without_named_relation=None,
                          under_named_existing_relation=counts))
    assert [r["under_named_existing_relation"]["scheduling_owners_upper"] for r in cases] == [194,161,98,11,5]
    return dict(
        scope="Whole selected suffix outer diagnostic occurrences and covered raw-backtrace composition",
        base="01ad7f9053fc1d2d64e7a993ec8f2d8d2543e3a7",
        cases=cases,
        summed_separate_process_counts={
            k:sum(r["under_named_existing_relation"][k] for r in cases)
            for k in ("scheduling_owners_upper", "combined_outer_report_calls_upper",
                      "outer_exn_printer_calls_upper", "outer_printexc_to_string_calls_upper",
                      "printer_integer_failure_stderr_calls_upper",
                      "backtrace_direct_object_requests_bytes_upper")},
        recursive_wrapper_depth=None,
        recursive_registry_delegation_factors=None,
        all_inner_exception_printer_invocations=None,
        actual_standard_core_B_E=None,
        all_diagnostic_payload_bytes=None,
        complete_diagnostic_capacity_established=False,
        complete_process_stack_established=False,
        complete_save_or_exit_capacity_established=False,
        physical_sufficiency_established=False,
        semantic_theorem_proved_by_checker=False,
        native_runs=0, new_captures=0, new_disassembly=0,
        predecessor_checker_replays=0,
    )


def products():
    return {"source-witnesses.json": witnesses(),
            "library-directives.json": library_directives(),
            "raw-client-dispositions.json": raw_clients(),
            "result.json": result()}


def main():
    started = time.perf_counter()
    for path, expected in json.loads((HERE / "inputs.json").read_text()).items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    generated = products()
    for name, value in generated.items():
        assert (HERE / name).read_bytes() == encoded(value), name
    print(json.dumps(dict(status="pass", mode="comparison",
                          source_excerpts=len(EXCERPTS),
                          existing_raw_client_rows=len(generated["raw-client-dispositions.json"]),
                          library_files=len(generated["library-directives.json"]),
                          cases=len(generated["result.json"]["cases"]),
                          elapsed_seconds=time.perf_counter()-started), indent=2))


if __name__ == "__main__":
    main()
