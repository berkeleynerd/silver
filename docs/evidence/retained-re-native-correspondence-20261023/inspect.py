#!/usr/bin/env python3
"""Named-function static ELF extraction. Never executes the inspected program."""
import json
import pathlib
import subprocess
import sys
import time

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT / "docs/evidence/retained-why-library-probe-paths-20261023"))
from elf_reader import Elf, identity

BINARY = pathlib.Path("/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3")
OBJDUMP = pathlib.Path("/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/bin/objdump")
EXPECTED = {"bytes": 24561432, "sha256": "7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368"}


def main():
    binary = BINARY.read_bytes()
    assert identity(binary) == EXPECTED
    elf = Elf(binary)
    record_path = HERE / "native.json"
    record = json.loads(record_path.read_text()) if record_path.exists() else {
        "target_identity": EXPECTED, "target": str(BINARY), "target_executions": 0,
        "disassembler": str(OBJDUMP), "disassembler_identity": identity(OBJDUMP.read_bytes()),
        "functions": {}, "inspections": []}
    assert record["target_identity"] == EXPECTED
    assert record["disassembler_identity"] == identity(OBJDUMP.read_bytes())
    for name in sys.argv[1:]:
        code = elf.function(name)
        if name in record["functions"]:
            assert record["functions"][name]["identity"] == identity(code)
            continue
        argv = [str(OBJDUMP), "-d", "--disassemble=" + name, str(BINARY)]
        started = time.monotonic()
        proc = subprocess.run(argv, capture_output=True, text=True, check=True)
        elapsed = time.monotonic() - started
        path = HERE / (name + ".txt")
        path.write_text(proc.stdout)
        record["functions"][name] = {**elf.symbols[name], "identity": identity(code),
            "hex": code.hex(), "disassembly": path.name,
            "disassembly_identity": identity(proc.stdout.encode())}
        record["inspections"].append({"argv": argv, "elapsed_seconds": elapsed,
            "exit_code": proc.returncode, "stderr": proc.stderr})
        record_path.write_text(json.dumps(record, indent=2, sort_keys=True) + "\n")
    record_path.write_text(json.dumps(record, indent=2, sort_keys=True) + "\n")
    print(json.dumps({"functions_retained": len(record["functions"]),
        "inspections": len(record["inspections"]), "target_executions": 0,
        "elapsed_seconds_recorded": sum(r.get("elapsed_seconds") or 0 for r in record["inspections"]),
        "elapsed_measurements_missing": sum(r.get("elapsed_seconds") is None for r in record["inspections"])}))


if __name__ == "__main__":
    main()
