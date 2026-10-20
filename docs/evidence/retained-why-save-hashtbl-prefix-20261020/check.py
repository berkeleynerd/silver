#!/usr/bin/env python3
"""Check retained source/native projections and no-resize guard boundaries."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from transfer import MAX_ARRAY, MAX_INT, PREMISES, bound_table

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
INSN = re.compile(r"^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)" )


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--disassembly", type=Path)
    args = parser.parse_args()
    started = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for path, expected in inputs["files"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    archives = {}
    witnesses = json.loads((HERE / "source-witnesses.json").read_text())
    for witness in witnesses:
        archive = witness["archive"]
        if archive not in archives:
            archives[archive] = tarfile.open(ROOT / archive)
        data = archives[archive].extractfile(witness["member"]).read()
        assert identity(data) == witness["member_identity"]
        lines = data.decode().splitlines(keepends=True)
        assert "".join(lines[witness["first_line"] - 1:witness["last_line"]]) == witness["text"]
    for archive in archives.values():
        archive.close()

    native = json.loads((HERE / "native-witnesses.json").read_text())
    raw = (HERE / "native-bodies.json").read_bytes()
    assert identity(raw) == native["bodies_identity"]
    bodies = json.loads(raw)
    executable = Path(native["executable"]["path"]).read_bytes()
    assert identity(executable) == {k: native["executable"][k] for k in ("bytes", "sha256")}
    assert executable[:6] == b"\x7fELF\x02\x01"
    phoff = struct.unpack_from("<Q", executable, 32)[0]
    phentsize, phnum = struct.unpack_from("<HH", executable, 54)
    loads = []
    for i in range(phnum):
        ptype, flags, offset, vaddr, _, filesz, _, _ = struct.unpack_from(
            "<IIQQQQQQ", executable, phoff + i * phentsize)
        if ptype == 1 and flags & 1:
            loads.append((vaddr, vaddr + filesz, offset))
    checked = 0
    for symbol, body in bodies.items():
        assert re.search(r"^[0-9a-f]+ <" + re.escape(symbol) + r">:", body)
        for line in body.splitlines():
            match = INSN.match(line)
            if not match:
                continue
            address = int(match[1], 16)
            data = bytes.fromhex(match[2])
            segment = next(x for x in loads if x[0] <= address and address + len(data) <= x[1])
            offset = segment[2] + address - segment[0]
            assert executable[offset:offset + len(data)] == data, (symbol, line)
            checked += len(data)
    assert checked == native["instruction_bytes"]
    if args.disassembly:
        data = args.disassembly.read_bytes()
        assert identity(data) == {k: native["existing_disassembly"][k] for k in ("bytes", "sha256")}
        projected, active = {}, None
        for line in data.decode().splitlines(keepends=True):
            match = re.match(r"^[0-9a-f]+ <([^>]+)>:", line)
            if match:
                active = match[1] if match[1] in bodies else None
                if active:
                    projected[active] = ""
            if active:
                projected[active] += line
        assert projected == bodies

    # These guard cases are deliberately not captures or a proof by sampling.
    row = dict(table="synthetic", mode="persistent", entry_size=0, entry_visits=19,
               bucket_capacity=16, insertion_opportunities=32,
               **{name: True for name in PREMISES})
    assert bound_table(row)["binding_visits_upper"] == 51
    assert bound_table(row)["scalar_size_upper"] == 32
    assert bound_table({**row, "insertion_opportunities": 33})["binding_visits_upper"] is None
    for name in (*PREMISES, "entry_size", "entry_visits", "bucket_capacity", "insertion_opportunities"):
        missing = dict(row)
        missing.pop(name)
        assert bound_table(missing)["prefix_traversal_contract_established"] is False, name
    assert bound_table({**row, "mode": "clear_before_add", "entry_size": MAX_INT})["scalar_size_upper"] == MAX_INT
    assert bound_table({**row, "entry_size": MAX_INT})["numeric_guards_pass"] is False
    assert bound_table({**row, "bucket_capacity": 0})["numeric_guards_pass"] is False
    assert bound_table({**row, "bucket_capacity": 17})["numeric_guards_pass"] is False
    assert bound_table({**row, "bucket_capacity": MAX_ARRAY + 1})["numeric_guards_pass"] is False
    for mode in ("readonly", "clear_only"):
        result = bound_table({**row, "mode": mode, "insertion_opportunities": 0})
        assert result["binding_visits_upper"] == 19
    for bad in (-1, True, 1.5):
        try:
            bound_table({**row, "entry_size": bad})
        except ValueError:
            pass
        else:
            raise AssertionError(bad)
    schema = json.loads((HERE / "table-interface.json").read_text())
    assert all(bound_table(row)["prefix_traversal_contract_established"] is False for row in schema["uninstantiated_tables"])
    result = json.loads((HERE / "result.json").read_text())
    assert result["guarded_source_native_prefix_contract"] is True
    for name in ("actual_entry_inputs_joined", "unrestricted_resize_prefix_proved",
                 "complete_save_capacity_established", "whole_pipeline_capacity_established"):
        assert result[name] is False
    print(json.dumps({"status": "pass", "source_excerpts": len(witnesses),
                      "native_bodies": len(bodies), "native_instruction_bytes_checked": checked,
                      "retained_disassembly_reprojected": args.disassembly is not None,
                      "guard_boundary_checks": "pass", "elapsed_seconds": time.monotonic() - started,
                      "native_target_runs": 0, "disassembler_runs": 0, "capture_runs": 0,
                      "predecessor_checker_replays": 0}))


if __name__ == "__main__":
    main()
