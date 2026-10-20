#!/usr/bin/env python3
"""New narrow source/counter-byte check plus attachment consistency only."""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from join import HERE, ROOT, derive

INSN = re.compile(r"^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)")


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def main():
    started = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for path, expected in inputs["files"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    witnesses = json.loads((HERE / "source-excerpts.json").read_text())
    archives = {}
    for witness in witnesses:
        name = witness["archive"]
        if name not in archives:
            archives[name] = tarfile.open(ROOT / name)
        data = archives[name].extractfile(witness["member"]).read()
        assert identity(data) == witness["member_identity"]
        lines = data.decode().splitlines(keepends=True)
        assert "".join(lines[witness["first_line"] - 1:witness["last_line"]]) == witness["text"]
    for archive in archives.values():
        archive.close()
    native = json.loads((HERE / "native-witnesses.json").read_text())
    raw = (HERE / "native-bodies.json").read_bytes()
    assert identity(raw) == native["bodies_identity"]
    bodies = json.loads(raw)
    assert set(bodies) == {
        "camlWhy3__Session_itp__gen_proofAttemptID_1705",
        "camlWhy3__Session_itp__add_proof_attempt_2099",
    }
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
    checked, instructions = 0, {}
    for symbol, body in bodies.items():
        assert re.search(r"^[0-9a-f]+ <" + re.escape(symbol) + r">:", body)
        for line in body.splitlines():
            match = INSN.match(line)
            if not match:
                continue
            address, data = int(match[1], 16), bytes.fromhex(match[2])
            segment = next(x for x in loads if x[0] <= address and address + len(data) <= x[1])
            offset = segment[2] + address - segment[0]
            assert executable[offset:offset + len(data)] == data, (symbol, line)
            assert address not in instructions
            instructions[address] = line
            checked += len(data)
    assert checked == native["instruction_bytes"]
    # Assert the exact reviewed commit sequence and its subsequent call order.
    for address, fragment in native["reviewed_instruction_fragments"].items():
        assert fragment in instructions[int(address, 16)], (address, fragment)
    assert "call" not in bodies["camlWhy3__Session_itp__gen_proofAttemptID_1705"]
    for address, line in instructions.items():
        if 0x7f285b <= address <= 0x7f286a:
            assert not any(x in line for x in ("call", "jmp", "jb", "jne"))
    result = derive()
    assert result == json.loads((HERE / "result.json").read_text())
    print(json.dumps({
        "status": "pass", "input_identities_checked": len(inputs["files"]),
        "source_excerpts_checked": len(witnesses), "new_native_bodies": len(bodies),
        "new_native_instruction_bytes_checked": checked,
        "shared_table_applications_attached": result["shared_table_applications_attached"],
        "no_resize_applications": result["no_resize_applications"],
        "selected_theory_resize_replacements": result["selected_theory_resize_replacements"],
        "counter_endpoints": [x["usable_under_external_premises"]["next_proofAttemptID_upper"]
                              for x in result["cases"]],
        "legacy_outputs_modified": False, "old_checker_replays": 0,
        "native_target_runs": 0, "disassembler_runs": 0, "capture_runs": 0,
        "source_fetches": 0, "solver_or_proof_runs": 0,
        "elapsed_seconds": time.monotonic() - started,
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
