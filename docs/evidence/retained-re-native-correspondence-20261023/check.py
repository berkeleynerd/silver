#!/usr/bin/env python3
"""Focused static identity, operand and arithmetic check; no target execution.

This checks the evidence for the accompanying reviewed argument. It is not an
x86 verifier, an execution model of Re, or a replacement for that argument.
"""
import hashlib
import json
import pathlib
import re
import struct
import sys
import time

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT / "docs/evidence/retained-why-library-probe-paths-20261023"))
from elf_reader import Elf, identity


def read(name):
    return json.loads((HERE / name).read_text())


def main():
    started = time.monotonic()
    native = read("native.json")
    inputs = read("inputs.json")
    witnesses = read("witnesses.json")
    for item in inputs["inputs"]:
        assert identity((ROOT / item["path"]).read_bytes()) == item["identity"], item["path"]
    binary = pathlib.Path(native["target"]).read_bytes()
    assert identity(binary) == {
        "bytes": 24561432,
        "sha256": "7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368",
    } == native["target_identity"]
    assert native["target_executions"] == 0
    elf = Elf(binary)
    text_by_name = {}
    for name, item in native["functions"].items():
        assert {k: item[k] for k in elf.symbols[name]} == elf.symbols[name]
        code = elf.function(name)
        assert code.hex() == item["hex"] and identity(code) == item["identity"], name
        dis = (HERE / item["disassembly"]).read_bytes()
        assert identity(dis) == item["disassembly_identity"], name
        text_by_name[name] = dis.decode()
        assert f"<{name}>:" in text_by_name[name]
    assert len(native["functions"]) == 109
    assert len(native["inspections"]) == 109
    assert sum(i.get("elapsed_seconds") is None for i in native["inspections"]) == 5
    for name, item in native["data"].items():
        data = elf.at(item["address"], item["bytes"])
        assert data.hex() == item["hex"] and identity(data) == item["identity"], name
        if "targets" in item:
            actual = [item["address"] + x for x in struct.unpack("<" + "i" * (len(data)//4), data)]
            assert actual == item["targets"], name
        if "words" in item:
            assert list(struct.unpack("<" + "Q" * (len(data)//8), data)) == item["words"]
    owner_by_table = {
        "rename_dispatch": "camlRe__Automata__rename_1196",
        "delta_expr_dispatch": "camlRe__Automata__delta_expr_2010",
        "handle_case_dispatch": "camlRe__Ast__handle_case_1186",
        "translate_immediate_dispatch": "camlRe__Compile__translate_1981",
        "translate_block_dispatch": "camlRe__Compile__translate_1981",
    }
    for table, name in owner_by_table.items():
        body = native["functions"][name]
        assert all(body["address"] <= target < body["address"] + body["bytes"]
                   for target in native["data"][table]["targets"]), table
    assert native["data"]["rename_dispatch"]["targets"][0] == 0x9172c4
    assert native["data"]["translate_block_dispatch"]["targets"][:5] == [
        0x922a54, 0x922aa0, 0x922ba4, 0x922be4, 0x922d18]
    epsilon = native["data"]["epsilon_expr"]["words"]
    assert epsilon[0] >> 10 == 2 and epsilon[0] & 255 == 0 and epsilon[1:] == [1, 1]
    assert native["data"]["char_initializer_closure"]["words"][1] == elf.symbols["camlRe__Ast__fun_2317"]["address"]
    assert native["data"]["mark_max_fold_closure"]["words"][3] == elf.symbols["camlRe__Mark_infos__fun_486"]["address"]

    direct_edges = 0
    assert len(witnesses) == 84
    for item in witnesses:
        code = bytes.fromhex(item["hex"])
        body = native["functions"][item["symbol"]]
        assert body["address"] <= item["address"] < body["address"] + body["bytes"]
        assert elf.at(item["address"], len(code)) == code
        assert item["assembly"] in text_by_name[item["symbol"]]
        if code[0] in (0xe8, 0xe9):
            assert len(code) == 5
            target = item["address"] + 5 + struct.unpack("<i", code[1:])[0]
            shown = re.search(r"\b(?:call|jmp)\s+([0-9a-f]+)\s+<", item["assembly"])
            assert shown and int(shown[1], 16) == target
            direct_edges += 1

    # No local OCaml trap installation in the scratch/position mutation chain.
    no_trap = [
        "camlRe__Hash_set__" + n for n in ["init_508", "clear_526", "add_530", "resize_582", "add_590", "mem_599"]
    ] + [
        "camlRe__Automata__" + n for n in ["delta_2076", "loop_1628", "delta_desc_2058", "delta_e_2057", "delta_expr_2010", "delta_rep_2011", "delta_alt_2012", "delta_seq_2013", "free_index_1999"]
    ] + [
        "camlRe__Compile__" + n for n in ["resize_1199", "set_1203", "loop_1358", "validate_1261", "scan_str_1486", "final_boundary_check_1496", "make_match_str_1508", "match_str_no_bounds_1793", "match_str_1830"]
    ]
    for name in no_trap:
        assert not re.search(r"push\s+0x10\(%r14\)|mov\s+%rsp,0x10\(%r14\)", text_by_name[name]), name
    for name in ["camlRe__Hash_set__clear_526", "camlStdlib__Bytes__fill_357", "caml_fill_bytes"]:
        body = text_by_name[name]
        assert not any(x in body for x in ["caml_call_gc", "caml_process_pending", "caml_alloc", "caml_c_call"]), name
    for name in ["delta_desc_2058", "delta_e_2057", "delta_expr_2010", "delta_rep_2011", "delta_alt_2012", "delta_seq_2013"]:
        assert "camlRe__Hash_set" not in text_by_name["camlRe__Automata__" + name]

    n = 64 * (401 + 8)**2
    m = n + 1
    historical_count = m * (m + 1)
    capacity = 4 * historical_count
    packed_bytes = 8 * capacity
    max_int = 2**62 - 1
    max_string = 2**57 - 9
    max_array = 2**54 - 1
    assert n == 10705984 and m == 10705985
    assert packed_bytes < max_string
    assert historical_count + 1 < max_int and capacity * 2 < max_int
    # Conservatively covers tagged index sums and tagged eight-byte offsets.
    assert 32 * capacity < 2**63 - 1
    assert 2048 <= max_array and 257 <= max_array and 8 <= max_array
    for idx in range(402):
        tagged = 2 * idx + 1
        encoded = -8 - tagged
        assert encoded <= -9 < -5 < -3 < 1 <= tagged
        assert -8 - encoded == tagged
    assert 512 >= 402 and (512 + 7)//8 == 64
    assert max(512 + 1, 2 * (402 + 1)) < 2048

    result = {
        "status": "pass", "native_functions": len(native["functions"]),
        "native_data_records": len(native["data"]), "instruction_witnesses": len(witnesses),
        "direct_call_or_jump_witnesses": direct_edges, "no_local_trap_bodies": len(no_trap),
        "immutable_input_files": len(inputs["inputs"]), "target_identity": native["target_identity"],
        "bounds": {"compiler_ids": n, "hash_set_key_count": m,
                   "historical_size": historical_count, "hash_set_slots": capacity,
                   "hash_set_bytes": packed_bytes, "max_string_length": max_string,
                   "working_bits": 512, "working_bytes": 64, "positions_words": 2048,
                   "transition_words": 257, "mark_words": 8,
                   "union_table_buckets": 256, "individual_table_buckets": 128},
        "target_executions": 0, "predecessor_checker_replays": 0,
        "note": "Identity/operand/arithmetic evidence; structural proofs remain in the reviewed note.",
        "checker_identity": identity(pathlib.Path(__file__).read_bytes()),
        "packet_input_identities": {name: identity((HERE/name).read_bytes()) for name in ["native.json", "inputs.json", "witnesses.json"]},
        "elapsed_seconds": time.monotonic() - started,
    }
    (HERE / "result.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()
