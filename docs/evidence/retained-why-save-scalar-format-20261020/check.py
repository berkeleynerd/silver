#!/usr/bin/env python3
"""Check the scalar source/native witnesses and conditional arithmetic interface."""

import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from transfer import PREMISES, scalar_bounds

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
INSN = re.compile(r"^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)")


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def main():
    start = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for path, expected in inputs["files"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    for path, expected in inputs["local_files"].items():
        assert identity((HERE / path).read_bytes()) == expected, path
    archives = {}
    witnesses = json.loads((HERE / "source-witnesses.json").read_text())
    try:
        for w in witnesses:
            if w["archive"] not in archives:
                archives[w["archive"]] = tarfile.open(ROOT / w["archive"])
            raw = archives[w["archive"]].extractfile(w["member"]).read()
            assert identity(raw) == w["member_identity"]
            lines = raw.decode().splitlines(keepends=True)
            assert "".join(lines[w["first_line"] - 1:w["last_line"]]) == w["text"]
    finally:
        for archive in archives.values():
            archive.close()

    native = json.loads((HERE / "native-witnesses.json").read_text())
    executable = Path(native["executable"]["path"]).read_bytes()
    assert identity(executable) == native["executable"]["identity"]
    assert executable[:6] == b"\x7fELF\x02\x01"
    phoff = struct.unpack_from("<Q", executable, 32)[0]
    phentsize, phnum = struct.unpack_from("<HH", executable, 54)
    loads = []
    for i in range(phnum):
        kind, flags, offset, addr, _, size, _, _ = struct.unpack_from(
            "<IIQQQQQQ", executable, phoff + i * phentsize)
        if kind == 1:
            loads.append((addr, addr + size, offset, flags))

    def at(address, size, code=False):
        for low, high, offset, flags in loads:
            if low <= address and address + size <= high and (not code or flags & 1):
                return executable[offset + address - low:offset + address - low + size]
        raise AssertionError((address, size))

    bodies = json.loads((HERE / "native-bodies.json").read_text())
    checked = 0
    for symbol, body in bodies.items():
        assert re.search(r"^[0-9a-f]+ <" + re.escape(symbol) + r">:", body)
        for line in body.splitlines():
            m = INSN.match(line)
            if m:
                raw = bytes.fromhex(m[2])
                assert at(int(m[1], 16), len(raw), code=True) == raw, (symbol, line)
                checked += len(raw)
    assert checked == native["instruction_bytes"]
    for w in native["constant_data"]:
        raw = bytes.fromhex(w["hex"])
        assert at(int(w["address"], 16), len(raw)) == raw, w

    # Exact integer inequalities support the derivation, not floating samples.
    assert 10**18 <= 2**62 < 10**19
    assert 2**1024 < 10**309
    assert 2**1074 < 10**324
    assert 1 + 1 + 1 + 5 + 1 + 1 + 3 == 13  # signed exponential form
    assert 1 + 2 + 3 + 6 == 12  # signed fixed form, exponent -4
    assert max(20, 13, 5) == 20 < 128
    assert len(b"%.6g") == 4 < 16
    assert (20 + 8) // 8 == 3  # largest scalar result's payload words
    complete = {key: True for key in PREMISES}
    assert scalar_bounds(complete)["scalar_bytes_upper"] == 20
    for key in PREMISES:
        partial = complete.copy()
        partial.pop(key)
        assert scalar_bounds(partial)["scalar_bytes_upper"] is None
        assert scalar_bounds({**complete, key: False})["scalar_bytes_upper"] is None
    for bad in (1, None, "true"):
        try:
            scalar_bounds({PREMISES[0]: bad})
        except ValueError:
            pass
        else:
            raise AssertionError(bad)
    result = json.loads((HERE / "result.json").read_text())
    assert result["interface"] == scalar_bounds(result["actual_joined_premises"])
    assert not result["interface"]["normal_scalar_conversion_contract_joined"]
    print(json.dumps({"status": "pass", "source_excerpts": len(witnesses),
                      "native_bodies": len(bodies), "native_instruction_bytes": checked,
                      "native_constant_data": len(native["constant_data"]),
                      "boundary_and_missing_premise_checks": "pass",
                      "native_target_runs": 0, "disassembler_runs": 0,
                      "old_checker_replays": 0,
                      "elapsed_seconds": time.monotonic() - start}, indent=2))


if __name__ == "__main__":
    main()
