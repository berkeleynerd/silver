#!/usr/bin/env python3
"""Offline fixed placeholder source/native/count check; never runs a Re engine."""
import json
import pathlib
import sys
import time

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sys.path.insert(0, str(ROOT / "docs/evidence/retained-why-library-probe-paths-20261023"))
from elf_reader import Elf, identity


def main():
    started = time.monotonic()
    manifest = json.loads((HERE / "inputs.json").read_text())
    for name, expected in manifest["files"].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    local = json.loads((HERE / "native.json").read_text())
    binary = pathlib.Path(local["target"]).read_bytes()
    assert identity(binary) == local["target_identity"]
    elf = Elf(binary)
    bodies = 0
    for packet_name, names in manifest["native_selections"].items():
        path = ROOT / packet_name
        packet = json.loads(path.read_text())
        assert packet["target_identity"] == local["target_identity"]
        for name in names:
            f = packet["functions"][name]
            b = elf.function(name)
            assert b.hex() == f["hex"] and identity(b) == f["identity"]
            assert identity((path.parent / f["disassembly"]).read_bytes()) == f["disassembly_identity"]
            bodies += 1
    for w in manifest["witnesses"]:
        assert elf.at(w["address"], len(bytes.fromhex(w["hex"]))).hex() == w["hex"]
        assert w["line"] in (ROOT / w["file"]).read_text()

    # Compile-time finite sets and flatten arithmetic, not regex execution.
    csets = [[(0, 255)], [(37, 37)], [(0, 9), (11, 255)]]
    endpoints = {x for s in csets for a, b in s for x in (a, b + 1)}
    assert endpoints == {0, 10, 11, 37, 38, 256}
    color = 0
    colors = [0]
    reps = [0]
    for byte in range(1, 256):
        if byte in endpoints:
            color += 1
            reps.append(byte)
        colors.append(color)
        reps[color] = byte
    assert reps == [9, 10, 36, 37, 255]
    assert [colors[x] for x in bytes.fromhex("5c3d")] == [4, 4]
    translated = [[(colors[a], colors[b]) for a, b in s] for s in csets]
    assert translated == [[(0, 4)], [(3, 3)], [(0, 0), (2, 4)]]
    assert all(not (a <= 4 <= b) for a, b in translated[1])
    assert all(not (a <= -1 <= b) for a, b in translated[0])
    counts = {"Cst": 3, "Rep": 1, "Seq": 6, "Mark": 4}
    assert sum(counts.values()) == 14

    # The note derives S,S,empty. Check its one-ID-per-clear consequence.
    capacity = size = 0
    backing_requests = []
    for epoch_keys in ((2,), (2,), ()):
        size = 0
        slots = [None] * capacity
        for key in epoch_keys:
            assert key not in slots and size == 0
            if capacity == 0:
                capacity = 1
                backing_requests.append(8)
                slots = [None]
            assert slots == [None]
            slots[0] = key
            size += 1
            assert capacity == size == 1
    assert capacity == 1 and size == 0 and backing_requests == [8]
    parse = 52 + 18 + 3 + 2 + 15
    compilation_stages = [128, 256, 256, 3 * 128, 160]
    derivative_stages = [4, 6, 10, 9, 6, 3, 3, 8 * 10, 32, 32, 48, 6, 32]
    other = 7 + 2 * 17 + 6 + 9 + 3 * 2 + 12
    assert parse == 90 <= 128
    assert sum(compilation_stages) == 1184 <= 2048
    assert sum(derivative_stages) == 271 <= 512
    assert other == 74 <= 128
    total = 128 + 2048 + 3 * 512 + 128
    assert total == 3840 <= 4096
    result = {
        "placeholder_hex": "255c282e5c29", "input_hex": "5c3d",
        "native_bodies": bodies, "witnesses": len(manifest["witnesses"]),
        "fixed_inputs": len(manifest["files"]), "colors": 5,
        "expressions": counts, "total_expressions": 14,
        "delta_invocations": 3, "state_table_keys": 2, "state_table_buckets": 128,
        "packed_capacity_slots": 1, "packed_backing_bytes": 8,
        "packed_size_peak": 1, "packed_backing_requests": backing_requests,
        "working_bits": 1, "working_hint": 0, "positions_length": 1,
        "parse_credit_words": 128, "compilation_credit_words": 2048,
        "derivative_credit_words": 512, "other_search_credit_words": 128,
        "total_stage_credit_words": total, "exported_owned_credit_words": 4096,
        "nine_placeholder_credit_words": 36864,
        "target_executions": 0, "engine_executions": 0,
        "elapsed_seconds": time.monotonic() - started,
        "scope": "Fixed successful-startup placeholder construction/force/failed search; excludes caller substitution wrappers and common runtime owners."
    }
    (HERE / "result.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()
