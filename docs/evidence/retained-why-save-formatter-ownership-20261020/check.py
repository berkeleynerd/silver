#!/usr/bin/env python3
"""Check retained source/native witnesses and external-premise separation."""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from attachment import EXTERNAL_PREMISES, attach

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
INSN = re.compile(r"^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)")


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def main():
    start = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for kind, root in (("files", ROOT), ("local_files", HERE)):
        for path, expected in inputs[kind].items():
            assert identity((root/path).read_bytes()) == expected, path
    sources = json.loads((HERE/"source-witnesses.json").read_text())
    archives = {}
    try:
        for s in sources:
            if s["archive"] not in archives:
                archives[s["archive"]] = tarfile.open(ROOT/s["archive"])
            raw = archives[s["archive"]].extractfile(s["member"]).read()
            assert identity(raw) == s["member_identity"]
            lines = raw.decode().splitlines(keepends=True)
            assert "".join(lines[s["first_line"]-1:s["last_line"]]) == s["text"]
    finally:
        for a in archives.values():
            a.close()
    native = json.loads((HERE/"native-witnesses.json").read_text())
    raw = Path(native["executable"]["path"]).read_bytes()
    assert identity(raw) == native["executable"]["identity"]
    assert raw[:6] == b"\x7fELF\x02\x01"
    phoff = struct.unpack_from("<Q", raw, 32)[0]
    entsize, count = struct.unpack_from("<HH", raw, 54)
    loads = []
    for i in range(count):
        kind, flags, off, addr, _, size, _, _ = struct.unpack_from("<IIQQQQQQ", raw, phoff+i*entsize)
        if kind == 1 and flags & 1:
            loads.append((addr, addr+size, off))
    bodies = json.loads((HERE/"native-bodies.json").read_text())
    checked = 0
    for name, text in bodies.items():
        assert re.search(r"^[0-9a-f]+ <"+re.escape(name)+r">:", text)
        for line in text.splitlines():
            m = INSN.match(line)
            if not m:
                continue
            addr, data = int(m[1], 16), bytes.fromhex(m[2])
            for lo, hi, off in loads:
                if lo <= addr and addr+len(data) <= hi:
                    assert raw[off+addr-lo:off+addr-lo+len(data)] == data
                    break
            else:
                raise AssertionError((name,line))
            checked += len(data)
    assert checked == native["instruction_bytes"]
    # The already-reviewed conversion is selected before application callbacks,
    # and shutdown/exit ordering is inspected in these retained bodies.
    assert bodies["caml_startup_common"].index("<caml_init_locale>") < bodies["caml_startup_common"].index("<caml_start_program>")
    assert bodies["caml_shutdown"].index("<caml_finalise_heap>") < bodies["caml_shutdown"].index("<caml_free_locale>")
    assert "<caml_do_exit>" in bodies["main"]
    assert "<caml_shutdown>" in bodies["caml_do_exit"]
    assert "<caml_terminate_signals>" in bodies["caml_do_exit"]
    # Presence/order checks corroborate the source argument; they are not a
    # decoded indirect-call completeness or control-flow refinement proof.
    complete = {p: True for p in EXTERNAL_PREMISES}
    assert attach()["normal_scalar_bytes_upper_under_supplied_external_premises"] is None
    assert attach(complete)["normal_scalar_bytes_upper_under_supplied_external_premises"] == 20
    for p in EXTERNAL_PREMISES:
        missing = complete.copy(); missing.pop(p)
        assert attach(missing)["normal_scalar_bytes_upper_under_supplied_external_premises"] is None
        assert attach({**complete,p:False})["normal_scalar_bytes_upper_under_supplied_external_premises"] is None
    assert attach({EXTERNAL_PREMISES[0]:True})["fresh_default_and_private_frame_under_supplied_external_premises"] is True
    assert attach({EXTERNAL_PREMISES[0]:False})["fresh_default_and_private_frame_under_supplied_external_premises"] is None
    for bad in ({"unknown":True}, {EXTERNAL_PREMISES[0]:1}, {EXTERNAL_PREMISES[1]:"true"}):
        try:
            attach(bad)
        except ValueError:
            pass
        else:
            raise AssertionError(bad)
    result = json.loads((HERE/"result.json").read_text())
    assert result["no_external_assertion"] == attach()
    assert result["under_named_existing_external_premises"] == attach(complete)
    assert not attach(complete)["runtime_service_success_observed"]
    assert not attach(complete)["complete_formatter_capacity_established"]
    print(json.dumps({"status":"pass","source_excerpts":len(sources),
                      "native_bodies":len(bodies),"instruction_bytes":checked,
                      "premise_separation_checks":"pass","native_runs":0,
                      "disassembler_runs":0,"elapsed_seconds":time.monotonic()-start},indent=2))


if __name__ == "__main__":
    main()
