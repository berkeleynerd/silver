#!/usr/bin/env python3
"""Reconcile frozen sources/native bytes and the conditional core transfer."""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from transfer import MAX_INT, PP_INFINITY, PREMISES, core_bounds

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
INSN = re.compile(r"^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)")


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def applications():
    strings = json.loads((ROOT / "docs/evidence/retained-why-save-serializer-inputs-20261020/result.json").read_text())
    states = json.loads((ROOT / "docs/evidence/retained-why-save-state-join-20261020/result.json").read_text())
    by_case = {c["case"]: c for c in states["cases"]}
    rows = []
    for c in strings["cases"]:
        state = by_case[c["case"]]
        assert c["pid"] == state["new_pid"]
        assert state["logical_graph_correspondence_established"]
        growth = state["conditional_growth"]
        forest = growth["preserved_forest"]
        visits = c["inventory"]["visits"]
        assert (forest["F"], forest["Th"], forest["G"], forest["T"]) == (
            visits["files"], visits["theories_examined"], visits["goals"], visits["transformations"])
        paths = sum(f["path"]["component_count"] for f in c["inventory"]["files"])
        assert growth["proof_script_path_occurrences"] == 0
        parts = dict(forest)
        parts.update(A=growth["conditional_A_stats_upper"],
                     Axml=growth["conditional_A_xml_upper"], Paths=paths)
        assert set(parts) == {"F", "Th", "G", "T", "Args", "A", "Axml", "Paths"}
        q = 1 + sum(parts.values())
        u = c["candidate_raw_string_bytes_sum_per_save"]
        b, e = 1024*q + 6*u + 32*q*20, 128*q + u
        rows.append({"case": c["case"], "pid": c["pid"], "Q_parts": parts,
                     "Q": q, "candidate_U": u, "candidate_d": 20,
                     "candidate_B": b, "candidate_E": e,
                     "actual_joined_premises": {p: False for p in PREMISES},
                     "interface": core_bounds(b, e)})
    return rows


def main():
    start = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for kind, root in (("files", ROOT), ("local_files", HERE)):
        for path, expected in inputs[kind].items():
            assert identity((root / path).read_bytes()) == expected, path
    witnesses = json.loads((HERE / "source-witnesses.json").read_text())
    archives = {}
    try:
        for w in witnesses:
            if w["archive"] not in archives:
                archives[w["archive"]] = tarfile.open(ROOT / w["archive"])
            raw = archives[w["archive"]].extractfile(w["member"]).read()
            assert identity(raw) == w["member_identity"]
            lines = raw.decode().splitlines(keepends=True)
            assert "".join(lines[w["first_line"]-1:w["last_line"]]) == w["text"]
    finally:
        for a in archives.values():
            a.close()
    native = json.loads((HERE / "native-witnesses.json").read_text())
    executable = Path(native["executable"]["path"]).read_bytes()
    assert identity(executable) == native["executable"]["identity"]
    assert executable[:6] == b"\x7fELF\x02\x01"
    phoff = struct.unpack_from("<Q", executable, 32)[0]
    phentsize, phnum = struct.unpack_from("<HH", executable, 54)
    loads = []
    for i in range(phnum):
        kind, flags, offset, addr, _, size, _, _ = struct.unpack_from(
            "<IIQQQQQQ", executable, phoff+i*phentsize)
        if kind == 1 and flags & 1:
            loads.append((addr, addr+size, offset))
    bodies = json.loads((HERE / "native-bodies.json").read_text())
    count = 0
    for name, body in bodies.items():
        assert re.search(r"^[0-9a-f]+ <" + re.escape(name) + r">:", body)
        for line in body.splitlines():
            m = INSN.match(line)
            if not m:
                continue
            address, data = int(m[1], 16), bytes.fromhex(m[2])
            for low, high, offset in loads:
                if low <= address and address+len(data) <= high:
                    assert executable[offset+address-low:offset+address-low+len(data)] == data
                    break
            else:
                raise AssertionError((name, line))
            count += len(data)
    assert count == native["instruction_bytes"]

    complete = {p: True for p in PREMISES}
    # Exact guard boundary: one extra byte must reject this sufficient transfer.
    assert core_bounds(PP_INFINITY-79, 0, complete)["core_bounds"] is not None
    assert core_bounds(PP_INFINITY-78, 0, complete)["core_bounds"] is None
    assert core_bounds(7, 2, complete)["core_bounds"] is not None
    assert core_bounds(0, MAX_INT, complete)["core_bounds"] is None
    for p in PREMISES:
        missing = complete.copy(); missing.pop(p)
        assert core_bounds(7, 2, missing)["core_bounds"] is None
        assert core_bounds(7, 2, {**complete, p: False})["core_bounds"] is None
    for b, e, premises in [(-1, 1, {}), (True, 1, {}), (1, 1.5, {}),
                            (1, 1, {PREMISES[0]: 1}), (1, 1, {"unknown": True})]:
        try:
            core_bounds(b, e, premises)
        except ValueError:
            pass
        else:
            raise AssertionError((b, e, premises))
    result = json.loads((HERE / "result.json").read_text())
    assert result["cases"] == applications()
    for c in result["cases"]:
        assert all(c["interface"]["guards"].values())
        assert c["interface"]["core_bounds"] is None
    print(json.dumps({"status": "pass", "source_excerpts": len(witnesses),
                      "native_bodies": len(bodies), "instruction_bytes": count,
                      "applications": len(result["cases"]),
                      "guard_and_missing_premise_checks": "pass",
                      "native_runs": 0, "disassembler_runs": 0,
                      "elapsed_seconds": time.monotonic()-start}, indent=2))


if __name__ == "__main__":
    main()
