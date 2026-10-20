#!/usr/bin/env python3
"""Check this packet only. No target, disassembler, fetch or earlier checker."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from transfer import MAX_INT, P, PREMISES, bounds

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OCAML = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"
ARCHIVES = {
    "ocaml": "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz",
    "why3": "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz",
}
EXCERPTS = [
    ("ocaml", "stdlib/format.ml", 18, 50),
    ("ocaml", "stdlib/format.ml", 95, 132),
    ("ocaml", "stdlib/format.ml", 217, 302),
    ("ocaml", "stdlib/format.ml", 319, 411),
    ("ocaml", "stdlib/format.ml", 427, 535),
    ("ocaml", "stdlib/format.ml", 592, 637),
    ("ocaml", "stdlib/format.ml", 652, 718),
    ("ocaml", "stdlib/format.ml", 890, 917),
    ("ocaml", "stdlib/format.ml", 937, 1023),
    ("ocaml", "stdlib/format.ml", 1249, 1311),
    ("ocaml", "stdlib/format.ml", 1398, 1404),
    ("ocaml", "stdlib/queue.ml", 19, 80),
    ("ocaml", "stdlib/stack.ml", 15, 52),
    ("ocaml", "stdlib/camlinternalFormat.ml", 1968, 2008),
    ("ocaml", "stdlib/stdlib.ml", 550, 570),
    ("ocaml", "runtime/signals.c", 201, 227),
    ("ocaml", "runtime/signals.c", 260, 335),
    ("ocaml", "runtime/fail_nat.c", 63, 87),
    ("ocaml", "runtime/io.c", 73, 81),
    ("ocaml", "runtime/io.c", 185, 210),
    ("ocaml", "runtime/io.c", 660, 670),
    ("ocaml", "runtime/io.c", 714, 739),
    ("ocaml", "runtime/memory.c", 608, 663),
    ("why3", "src/gnat/gnat_main.ml", 298, 309),
    ("why3", "src/util/debug.ml", 65, 80),
    ("why3", "src/util/json_base.ml", 11, 107),
]
FORMAT_BODIES = """pp_enqueue pp_clear_queue format_pp_text format_string
break_new_line break_line break_same_line pp_force_break_line format_pp_token
advance_left enqueue_advance enqueue_string_as enqueue_string
initialize_scan_stack set_size scan_push pp_open_box_gen pp_open_sys_box
pp_close_box pp_rinit clear_tag_stack pp_flush_queue pp_print_as_size pp_print_as
pp_print_string pp_print_newline pp_print_flush pp_force_newline
pp_print_custom_break pp_print_break display_newline display_blanks
compute_tag output_formatting_lit output_acc flush_standard_formatters
fun_2430 fun_2433""".split()
NATIVE_PREFIXES = ["camlStdlib__Format__" + n + "_" for n in FORMAT_BODIES]
# Anonymous bodies already have their numeric suffix.
NATIVE_PREFIXES = [p[:-1] if re.search(r"fun_\d+_$", p) else p for p in NATIVE_PREFIXES]
NATIVE_PREFIXES += ["camlStdlib__Queue__" + n + "_" for n in ("clear", "add", "peek_opt", "take")]
NATIVE_PREFIXES += ["camlStdlib__Stack__" + n + "_" for n in ("clear", "push", "pop_opt", "top_opt")]
NATIVE_PREFIXES += ["camlCamlinternalFormat__open_box_of_string_",
                    "camlGnat_main__save_session_and_exit_", "camlWhy3__Debug__fun_2950"]
NATIVE_EXACT = {"caml_modify", "caml_execute_signal_exn", "caml_process_pending_actions",
                "caml_raise", "caml_ml_output", "caml_ml_output_bytes", "caml_ml_flush"}
INSN = re.compile(r"^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)")


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def encoded(value):
    return (json.dumps(value, indent=2, sort_keys=True) + "\n").encode()


def source_witnesses():
    out = []
    archives = {k: tarfile.open(ROOT / v) for k, v in ARCHIVES.items()}
    try:
        for owner, path, first, last in EXCERPTS:
            member = (OCAML if owner == "ocaml" else "why3/") + path
            raw = archives[owner].extractfile(member).read()
            text = "".join(raw.decode().splitlines(keepends=True)[first-1:last])
            out.append(dict(archive=ARCHIVES[owner], member=member,
                            member_identity=identity(raw), first_line=first,
                            last_line=last, text=text, excerpt_identity=identity(text.encode())))
    finally:
        for archive in archives.values():
            archive.close()
    return out


def native_witnesses(inputs):
    raw = Path(inputs["disassembly"]).read_text()
    matches = list(re.finditer(r"^[0-9a-f]+ <([^>]+)>:\n", raw, re.M))
    bodies = {}
    for i, match in enumerate(matches):
        name = match[1]
        if name in NATIVE_EXACT or any(
                re.fullmatch(re.escape(p) + (r"\d+" if p.endswith("_") else ""), name)
                for p in NATIVE_PREFIXES):
            bodies[name] = raw[match.start():matches[i+1].start() if i+1 < len(matches) else len(raw)]
    for prefix in NATIVE_PREFIXES:
        assert any(re.fullmatch(re.escape(prefix) + (r"\d+" if prefix.endswith("_") else ""), n)
                   for n in bodies), prefix
    assert NATIVE_EXACT <= set(bodies)
    executable = Path(inputs["executable"]).read_bytes()
    assert executable[:6] == b"\x7fELF\x02\x01"
    phoff = struct.unpack_from("<Q", executable, 32)[0]
    size, number = struct.unpack_from("<HH", executable, 54)
    loads = []
    for i in range(number):
        kind, flags, offset, address, _, length, _, _ = struct.unpack_from(
            "<IIQQQQQQ", executable, phoff + i * size)
        if kind == 1 and flags & 1:
            loads.append((address, address + length, offset))
    byte_count = 0
    control = {}
    for name, body in bodies.items():
        for line in body.splitlines():
            match = INSN.match(line)
            if not match:
                continue
            address, data = int(match[1], 16), bytes.fromhex(match[2])
            segment = next((x for x in loads if x[0] <= address and address + len(data) <= x[1]), None)
            assert segment is not None, (name, line)
            lo, _, off = segment
            assert executable[off+address-lo:off+address-lo+len(data)] == data, (name, line)
            byte_count += len(data)
        control[name] = {
            "body_identity": identity(body.encode()),
            "allocation_reservations": re.findall(r"sub\s+\$0x([0-9a-f]+),%r15", body),
            "gc_call_sites": re.findall(r"^\s*([0-9a-f]+):.*call.*<caml_call_gc>", body, re.M),
            "direct_call_or_tail_targets": sorted(set(re.findall(r"(?:call|jmp)\s+[0-9a-f]+ <([^>]+)>", body))),
        }
    # Specific retained frontiers used in the argument, beyond identity alone.
    expected = {
        "camlStdlib__Format__pp_enqueue_462": ["986e1d:", "986e2e:", "<camlStdlib__Queue__add_283>"],
        "camlStdlib__Stack__pop_opt_289": ["9641b4:", "9641c1:", "9641c5:"],
        "camlStdlib__Format__pp_close_box_718": ["987d5a:", "987d68:", "987d76:", "987d87:"],
        "camlStdlib__Format__pp_flush_queue_779": ["98823b:", "988242:", "98824a:", "988278:"],
    }
    for name, markers in expected.items():
        assert all(m in bodies[name] for m in markers), name
    return bodies, control, byte_count


def arithmetic_checks():
    joined = dict.fromkeys(PREMISES, True)
    assert bounds(7, 2, joined)["joined_core_bounds"] is not None
    assert bounds(P - 79, 0, joined)["joined_core_bounds"] is not None
    assert bounds(P - 78, 0, joined)["joined_core_bounds"] is None
    # At the largest sentinel-admitted E, the larger size guard really matters.
    assert bounds(0, P - 79, joined)["guards"]["flush_sentinel"]
    assert not bounds(0, P - 79, joined)["guards"]["size_and_intermediate_arithmetic"]
    for premise in PREMISES:
        for missing in (None, False):
            p = joined.copy()
            if missing is None:
                p.pop(premise)
            else:
                p[premise] = False
            assert bounds(7, 2, p)["joined_core_bounds"] is None
    for b, e, p in [(-1, 2, {}), (True, 2, {}), (1, 2.5, {}),
                     (1, 2, {PREMISES[0]: 1}), (1, 2, {"unknown": True})]:
        try:
            bounds(b, e, p)
        except ValueError:
            pass
        else:
            raise AssertionError((b, e, p))
    # Check ownership arithmetic over disjoint event partitions, not executions.
    partitions = 0
    for e in range(25):
        for opened in range(e+1):
            for direct_close in range(e-opened+1):
                for flush in range(e-opened-direct_close+1):
                    other = e-opened-direct_close-flush
                    c = opened+direct_close+flush
                    i = 3*e+2
                    assert c <= e
                    assert opened+other+c+flush+2 <= i
                    assert other+2*c <= 3*e
                    assert 4*e+2 <= 2*i
                    assert i+e <= 2*i
                    assert 69*(opened+other+flush+2)+flush <= 70*(e+2)
                    assert 3*(opened+other+flush+2)+3*flush <= 6*(e+2)
                    partitions += 1
    # Algebraic interface examples, explicitly not retained-case budgets.
    examples = [dict(B=b, E=e, interface=bounds(b, e))
                for b, e in [(0, 0), (1538, 516), (1000000, 100000)]]
    return dict(partitions=partitions, examples=examples,
                old_fresh_total_counterexample={
                    "abstract_events": ["flush: assign P, then abandon at peek allocation", "text of length 1"],
                    "B": 1, "E": 2, "old_right_upper": 4, "prefix_right_total": P+1,
                    "reproduced_execution": False})


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="write this packet's generated witnesses")
    args = parser.parse_args()
    start = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for path, expected in inputs["files"].items():
        p = Path(path) if path.startswith("/") else ROOT / path
        assert identity(p.read_bytes()) == expected, path
    sources = source_witnesses()
    bodies, control, byte_count = native_witnesses(inputs)
    arithmetic = arithmetic_checks()
    result = {
        "base": inputs["base"], "source_excerpts": len(sources),
        "native_bodies": len(bodies), "instruction_bytes": byte_count,
        "arithmetic": arithmetic,
        "initial_state_established_by_this_packet": False,
        "actual_retained_case_B_E": None, "actual_joined_core_bounds": None,
        "source_native_refinement_proved": False,
        "complete_formatter_capacity_established": False,
        "complete_save_or_exit_capacity_established": False,
        "runtime_service_R": None, "initial_storage_A_pre": None,
        "native_stack_join": None, "physical_sufficiency_established": False,
        "native_runs": 0, "disassembler_runs": 0, "predecessor_checker_runs": 0,
    }
    products = {"source-witnesses.json": sources, "native-bodies.json": bodies,
                "native-control.json": control, "result.json": result}
    for name, value in products.items():
        data = encoded(value)
        if args.write:
            (HERE / name).write_bytes(data)
        else:
            assert (HERE / name).read_bytes() == data, name
    print(json.dumps(dict(status="pass", mode="write" if args.write else "comparison",
                         source_excerpts=len(sources), native_bodies=len(bodies),
                         instruction_bytes=byte_count, arithmetic_partitions=arithmetic["partitions"],
                         elapsed_seconds=time.monotonic()-start), indent=2))


if __name__ == "__main__":
    main()
