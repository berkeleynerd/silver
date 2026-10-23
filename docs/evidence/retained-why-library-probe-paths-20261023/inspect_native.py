#!/usr/bin/env python3
"""One-time target-free extraction; check.py never invokes the disassembler."""
import json
import pathlib
import subprocess
import time

from elf_reader import Elf, identity

HERE = pathlib.Path(__file__).resolve().parent
BINARY = pathlib.Path("/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3")
OBJDUMP = pathlib.Path("/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/bin/objdump")
FUNCTIONS = ["camlWhy3__Config__entry", "camlStdlib__Filename__entry", "camlWhy3__Whyconf__entry", "camlWhy3__Sexp_parser__entry", "caml_program", "camlWhy3__Env__locate_library_1155", "camlWhy3__Env__check_qualifier_1159", "camlWhy3__Env__add_ext_1163", "camlWhy3__Env__add_dir_1167", "camlStdlib__Filename__fun_1129", "camlStdlib__Filename__generic_basename_433", "camlStdlib__List__find_all_679"]


def main():
    binary = BINARY.read_bytes()
    elf = Elf(binary)
    record = {"target": str(BINARY), "target_identity": identity(binary), "disassembler": str(OBJDUMP), "disassembler_identity": identity(OBJDUMP.read_bytes()), "target_executions": 0, "functions": {}, "literals": {}, "invocations": []}
    texts = []
    previous = HERE / "native-inspection.json"
    if previous.exists():
        old = json.loads(previous.read_text())
        assert old["target_identity"] == record["target_identity"]
        assert old["disassembler_identity"] == record["disassembler_identity"]
        record = old
        texts.append((HERE / "native-disassembly.txt").read_text())
    for name in FUNCTIONS:
        code = elf.function(name)
        if name in record["functions"]:
            assert record["functions"][name]["identity"] == identity(code)
            continue
        record["functions"][name] = {**elf.symbols[name], "identity": identity(code), "hex": code.hex()}
        cmd = [str(OBJDUMP), "-d", "--disassemble=" + name, str(BINARY)]
        start = time.monotonic()
        result = subprocess.run(cmd, capture_output=True, text=True)
        record["invocations"].append({"argv": cmd, "exit_code": result.returncode, "elapsed_seconds": round(time.monotonic() - start, 6), "stdout_identity": identity(result.stdout.encode()), "stderr": result.stderr})
        texts.append(result.stdout)
        assert result.returncode == 0
    for name in ["camlWhy3__Config__3", "camlWhy3__Config__4", "camlWhy3__Config__5"]:
        record["literals"][name] = elf.literal(name)
    (HERE / "native-inspection.json").write_text(json.dumps(record, indent=2, sort_keys=True) + "\n")
    (HERE / "native-disassembly.txt").write_text("\n".join(texts))
    print(json.dumps({"functions": len(FUNCTIONS), "literals": len(record["literals"]), "target_executions": 0, "elapsed_seconds": sum(r["elapsed_seconds"] for r in record["invocations"])}))


if __name__ == "__main__":
    main()
