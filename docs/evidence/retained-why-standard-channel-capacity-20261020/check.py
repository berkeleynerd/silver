#!/usr/bin/env python3
"""Focused source/identity/arithmetic comparison, never target or service work."""
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = "c947f496ad682abfbbc024523c55d2c11735f411"
OCAML = "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
PREFIX = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"
K = 65536
MIN_OFFSET = -(1 << 63)
MAX_OFFSET = (1 << 63) - 1
EXCERPTS = [
    (OCAML, PREFIX + "stdlib/stdlib.ml", 310, 316),
    (OCAML, PREFIX + "stdlib/stdlib.ml", 341, 379),
    (OCAML, PREFIX + "stdlib/stdlib.ml", 486, 504),
    (OCAML, PREFIX + "stdlib/format.ml", 1000, 1023),
    (OCAML, PREFIX + "stdlib/printf.ml", 15, 32),
    (OCAML, PREFIX + "stdlib/camlinternalFormat.ml", 1894, 1913),
    (OCAML, PREFIX + "stdlib/printexc.ml", 14, 20),
    (OCAML, PREFIX + "stdlib/printexc.ml", 307, 367),
    (OCAML, PREFIX + "runtime/io.c", 70, 124),
    (OCAML, PREFIX + "runtime/io.c", 180, 253),
    (OCAML, PREFIX + "runtime/io.c", 505, 527),
    (OCAML, PREFIX + "runtime/io.c", 571, 595),
    (OCAML, PREFIX + "runtime/io.c", 653, 700),
    (OCAML, PREFIX + "runtime/io.c", 713, 740),
    (OCAML, PREFIX + "runtime/caml/io.h", 24, 65),
    (OCAML, PREFIX + "runtime/caml/io.h", 103, 124),
    (OCAML, PREFIX + "runtime/unix.c", 88, 109),
    (OCAML, PREFIX + "runtime/signals.c", 165, 195),
    (WHY, "why3/src/server/server-unix.c", 335, 400),
]
FIRST_HEADER = "Fatal error: exception %s\n"
SECOND_HEADER = "Fatal error in uncaught exception handler: exception %s\n"
OOM = "Fatal error: out of memory in uncaught exception handler"


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def encoded(value):
    return (json.dumps(value, indent=2, sort_keys=True) + "\n").encode()


def read(path):
    return json.loads((ROOT / path).read_text())


def witnesses():
    rows = []
    for archive in (OCAML, WHY):
        with tarfile.open(ROOT / archive) as tar:
            for selected, member, first, last in EXCERPTS:
                if selected != archive:
                    continue
                raw = tar.extractfile(member).read()
                lines = raw.decode().splitlines(keepends=True)
                assert 1 <= first <= last <= len(lines)
                excerpt = "".join(lines[first-1:last])
                rows.append(dict(archive=archive, member=member, first=first,
                                 last=last, member_identity=identity(raw),
                                 excerpt_identity=identity(excerpt.encode()),
                                 text=excerpt))
    printexc = next(r["text"] for r in rows
                    if r["member"].endswith("stdlib/printexc.ml") and r["first"] == 307)
    for header in (FIRST_HEADER, SECOND_HEADER):
        assert header.replace("\n", "\\n") in printexc
        assert header.count("%s") == 1
    assert OOM in printexc
    return rows


def interface():
    native = read("docs/evidence/retained-why-save-file-capacity-20261020/native-witnesses.json")
    backtrace = read("docs/evidence/retained-why-disabled-backtrace-20261020/result.json")
    assert backtrace["print_direct_requested_bytes_upper"] == 59
    assert native["buffer_bytes"] == K
    assert native["offset_bits"] == 64
    assert native["channel_struct_bytes"] == 65616
    assert native["positive_write_zero_return_guard_present"] is False
    literals = [len(FIRST_HEADER.replace("%s", "")),
                len(SECOND_HEADER.replace("%s", "")), len(OOM) + 1]
    assert literals == [24, 54, 57]
    return dict(
        scope="Conditional standard-channel request representation; actual attachment absent",
        channel_buffer_bytes=K, native_channel_record_bytes=65616,
        signed_offset_interval=[MIN_OFFSET, MAX_OFFSET],
        inherited_descriptor_numbers={"stdout": 1, "stderr": 2},
        distinct_channel_records=True, distinct_open_file_descriptions_required=False,
        direct_literal_and_newline_bytes=literals,
        direct_raw_print_bytes_upper=4*59,
        direct_stderr_constant_bytes_upper=sum(literals)+4*59,
        X_format="B + 70*(E+2)",
        X_direct_stderr="H_original + H_secondary + 371",
        total_offered="B + 70*(E+2) + H_original + H_secondary + 371",
        per_channel_guard="represented O0; 0 <= P0 <= 65536; O0 + P0 + X <= 2^63-1",
        prefix_invariant=["0 <= P <= 65536", "0 <= F",
                          "F + P <= P0 + A <= P0 + X", "O = O0 + F"],
        required_positive_success_interface="For valid readable 1..65536-byte requests: return 1<=w<=n committing that prefix, ordinary error/interruption/raise, or nonreturn",
        positive_write_interface_attached_to_actual_standard_descriptors=False,
        private_file_premise_extended=False,
        remaining_entry_fields=["actual rooted standard channel aliases and valid record/buffer ownership",
                                "readable initialized pending prefix and P0=curr-buff",
                                "cached O0 or environment/source-derived sufficient upper bound",
                                "actual descriptor binding/outcome contract, liveness and same-number aliases/close-rebinding owners",
                                "absence of unclassified native channel mutators"],
        remaining_input_fields=["actual B/E with accepted core guards", "Y_stdout/Y_stderr split or conservative aggregate", "H_original/H_secondary returned string bounds"],
        no_seek_read_close_or_buffering_change="conditional selected source/typed/native owner partition; not observed field values",
        callback_rule="Returning selected clients preserve roots; mutating save/exit callbacks terminate or unwind suspended caller",
        individual_syscall_requested_bytes_upper=K,
        successful_write_returns_upper="P0 + X",
        all_syscall_attempts_upper=None,
        all_syscall_requested_bytes_upper=None,
        cached_offset_equals_kernel_position=False,
        actual_initial_channel_state_attached=False,
    )


def guard(p0, o0, x):
    return (0 <= p0 <= K and MIN_OFFSET <= o0 <= MAX_OFFSET
            and x >= 0 and o0+p0+x <= MAX_OFFSET)


def arithmetic():
    core = read("docs/evidence/retained-why-standard-formatter-core-20261020/result.json")
    core_examples = []
    for row in core["arithmetic"]["examples"]:
        b, e = row["B"], row["E"]
        amount = b+70*(e+2)
        assert amount == row["interface"]["candidate"]["offered_standard_channel_bytes_upper"]
        core_examples.append(dict(B=b, E=e, X_format=amount))
    guard_rows = []
    for p0 in (0, 1, K-1, K):
        for x in (0, 1, K, MAX_OFFSET):
            for o0 in sorted({MIN_OFFSET, -1, 0, MAX_OFFSET-p0-x, MAX_OFFSET-p0-x+1}):
                accepted = guard(p0, o0, x)
                if accepted:
                    for f in {0, p0+x, min(p0+x, K)}:
                        assert MIN_OFFSET <= o0+f <= MAX_OFFSET
                guard_rows.append(dict(P0=p0, O0=o0, X=x, accepted=accepted))
    flush_checks = 0
    for p in (1, 2, K-1, K):
        for w in {1, p, max(1, p//2)}:
            for o in (MIN_OFFSET, -1, 0, MAX_OFFSET-p):
                assert MIN_OFFSET <= o+w <= MAX_OFFSET
                assert 0 <= p-w < K
                assert w+(p-w) == p
                if p == K:
                    assert p-w <= K-1  # next Putch index is in bounds
                flush_checks += 1
    assert guard(0, MAX_OFFSET, 1) is False
    return dict(
        core_output_examples_reused=core_examples,
        offset_guard_boundaries=guard_rows,
        positive_flush_boundary_checks=flush_checks,
        zero_return_countermodel=dict(initial_P=K, returned_w=0,
                                      next_Putch_index=K, valid_max_index=K-1,
                                      actual_execution=False),
        unknown_offset_countermodel=dict(P0=0, O0=MAX_OFFSET, X=1,
                                         cached_offset_after_one_committed_byte=MAX_OFFSET+1,
                                         representable=False, actual_execution=False),
        repeated_EINTR_family=dict(P=K, retries="arbitrary N",
                                  syscall_requested_bytes="65536*N",
                                  state_growth_per_retry=0, actual_execution=False),
        aliased_description_example=dict(initial_kernel_position=100,
                                         two_channel_initial_cached_offsets=[100,100],
                                         committed_bytes_each=3,
                                         final_kernel_position=106,
                                         final_cached_offsets=[103,103],
                                         actual_execution=False),
        semantic_induction_proved_by_checker=False)


def result():
    occurrence = read("docs/evidence/retained-why-diagnostic-occurrences-20261020/result.json")
    initial = read("docs/evidence/retained-why-standard-initial-state-20261020/result.json")
    exits = read("docs/evidence/retained-why-channel-exit-bound-20261020/result.json")
    assert all(initial["callbacks"][s]["channel_buffer_state"] is None
               for s in ("stdout", "stderr"))
    rows = []
    for o, i, ex in zip(occurrence["cases"], initial["cases"], exits["cases"], strict=True):
        assert o["case"] == i["case"] == ex["case"]
        assert o["pid"] == i["pid"]
        counts = o["under_named_existing_relation"]
        assert counts["fallback_stderr_exception_header_calls_upper"] == 2
        assert counts["fallback_out_of_memory_line_calls_upper"] == 1
        assert counts["backtrace_direct_channel_bytes_upper"] == 236
        assert counts["m_raw_print_invocations_upper"] == 4
        assert ex["under_named_existing_relation"]["flush_all_entries_upper"] == 6
        rows.append(dict(case=o["case"], pid=o["pid"],
                         initial_standard_core_state=i["conditional_source_constructor_state"],
                         standard_channel_entry={s:dict(P0=None,O0=None,
                                                         actual_descriptor_contract=None,
                                                         actual_buffer_alias_attachment=None)
                                                 for s in ("stdout","stderr")},
                         actual_B_E=None, actual_H_original_H_secondary=None,
                         actual_offered_bytes=None, actual_offset_guards=None,
                         usable_standard_channel_bounds=None,
                         flush_all_entries_upper_under_named_relation=6))
    return dict(base=BASE, cases=rows,
                global_postcut_save_entering_callbacks_upper=2,
                global_postcut_saves_upper=3, global_e_upper=2,
                global_budgets_reset=False,
                parameterized_source_theorem=True,
                actual_standard_channel_state_attached=False,
                actual_inherited_descriptor_positive_success_interface_attached=False,
                complete_channel_capacity=False, complete_exit_or_save_capacity=False,
                complete_R_or_stack=False, physical_sufficiency=False,
                actual_kernel_position_bound=None, successful_delivery_established=False,
                termination_established=False, new_target_runs=0,
                new_captures=0, new_disassembly=0, new_service_tests=0,
                predecessor_checker_replays=0, new_fetches=0, new_proof_runs=0)


def products():
    return {"source-witnesses.json": witnesses(), "interface.json": interface(),
            "arithmetic.json": arithmetic(), "result.json": result()}


def main():
    started = time.perf_counter()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for path, expected in inputs.items():
        assert identity((ROOT/path).read_bytes()) == expected, path
    generated = products()
    for name, value in generated.items():
        assert (HERE/name).read_bytes() == encoded(value), name
    print(json.dumps(dict(status="pass", mode="comparison", inputs=len(inputs),
                          source_excerpts=len(EXCERPTS), cases=len(generated["result.json"]["cases"]),
                          offset_guard_boundaries=len(generated["arithmetic.json"]["offset_guard_boundaries"]),
                          positive_flush_boundary_checks=generated["arithmetic.json"]["positive_flush_boundary_checks"],
                          elapsed_seconds=time.perf_counter()-started), indent=2))


if __name__ == "__main__":
    main()
