#!/usr/bin/env python3
"""Reconcile this finite prefix packet; no target or predecessor execution."""
import hashlib
import json
import struct
import tarfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def read(name):
    return json.loads((HERE / name).read_text())


def endpoint_projection():
    cuts = json.loads((ROOT / "docs/evidence/retained-parallel-logging-prefix-20261020/cut-projection.json").read_text())
    roles = json.loads((ROOT / "docs/evidence/retained-parallel-logging-prefix-20261020/input-role-projection.json").read_text())
    result = []
    for domain in ["put_line", "put", "first_or_default", "is_message", "input_is_valid"]:
        cut = cuts[domain]
        parallel = roles[domain]["captures"][1]
        argv = cut["prospective_argv"]
        assert cut["captured_argv"] == parallel["argv"]
        assert argv == parallel["argv"][:1] + ["--logging"] + parallel["argv"][1:]
        assert argv[2:4] == ["-j", "12"]
        assert argv.count("--socket") == 1
        socket = argv[argv.index("--socket") + 1]
        basename = socket.rsplit("/", 1)[1]
        assert basename == "server.sock" and len(basename.encode()) == 11
        assert "--standalone" not in argv and "--stand-alone" not in argv
        result.append({"domain": domain, "socket": socket,
                       "socket_bytes": len(socket.encode()),
                       "basename": basename, "basename_bytes": 11,
                       "prospective_argv": argv,
                       "private_root": parallel["private_root"],
                       "environment_roles": parallel["normalized_environment"],
                       "capture_archive": parallel["archive"]})
    assert len({x["socket"] for x in result}) == 5
    return result


def elf_bytes(raw, address, size):
    assert raw[:6] == b"\x7fELF\x02\x01"
    phoff = struct.unpack_from("<Q", raw, 32)[0]
    phsize, phnum = struct.unpack_from("<HH", raw, 54)
    for i in range(phnum):
        kind, flags, offset, vaddr, paddr, filesz, memsz, align = struct.unpack_from("<IIQQQQQQ", raw, phoff + i * phsize)
        if kind == 1 and vaddr <= address and address + size <= vaddr + filesz:
            start = offset + address - vaddr
            return raw[start:start + size]
    raise AssertionError("native range is outside file-backed PT_LOAD")


def main():
    start = time.monotonic()
    inputs = read("inputs.json")
    for path, expected in inputs["repository_inputs"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    native = Path(inputs["why_binary"]["path"]).read_bytes()
    assert identity(native) == inputs["why_binary"]["identity"]
    archives = {}
    for name in {x["archive"] for x in read("source-witnesses.json")}:
        with tarfile.open(ROOT / name) as archive:
            archives[name] = {m.name: archive.extractfile(m).read()
                              for m in archive if m.isfile()}
    for witness in read("source-witnesses.json"):
        raw = archives[witness["archive"]][witness["member"]]
        assert identity(raw) == witness["member_identity"]
        lines = raw.decode().splitlines(keepends=True)
        assert "".join(lines[witness["first_line"] - 1:witness["last_line"]]) == witness["text"]
    sources = archives[inputs["why_source_archive"]]
    census = []
    for name, raw in sorted(sources.items()):
        if name.startswith("why3/") and name.endswith(".ml"):
            for line, text in enumerate(raw.decode().splitlines(), 1):
                if "set_session_max_tasks" in text or "set_max_running_provers" in text:
                    census.append({"member": name, "line": line, "text": text})
    assert census == read("setter-census.json")
    endpoints = endpoint_projection()
    assert endpoints == read("endpoints.json")
    native_witnesses = read("native-witnesses.json")
    for witness in native_witnesses:
        expected = bytes.fromhex(witness["hex"])
        assert elf_bytes(native, witness["address"], len(expected)) == expected
        rows = {}
        for line in witness["disassembly"].splitlines():
            parts = line.split("\t")
            if len(parts) < 2 or not parts[0].strip().endswith(":"):
                continue
            address = int(parts[0].strip()[:-1], 16)
            for i, byte in enumerate(bytes.fromhex(parts[1])):
                assert address + i not in rows
                rows[address + i] = byte
        assert sorted(rows) == list(range(witness["address"], witness["address"] + len(expected)))
        assert bytes(rows[k] for k in sorted(rows)) == expected
    print(json.dumps({"scope": "exact successful fixed-prefix peer substitution",
                      "repository_inputs": len(inputs["repository_inputs"]),
                      "source_slices": len(read("source-witnesses.json")),
                      "native_functions": len(native_witnesses),
                      "native_instruction_bytes": sum(len(bytes.fromhex(x["hex"])) for x in native_witnesses),
                      "domains": len(endpoints),
                      "endpoint_bytes": [x["socket_bytes"] for x in endpoints],
                      "claimed_why_prefix_allocation_delta": 0,
                      "semantic_argument": "research note; independent review required",
                      "native_target_solver_proof_capture_runs": 0,
                      "predecessor_checker_replays": 0,
                      "candidate_executed": False,
                      "production_adopted": False,
                      "full_capacity_rule": False,
                      "elapsed_seconds": time.monotonic() - start}, indent=2))


if __name__ == "__main__":
    main()
