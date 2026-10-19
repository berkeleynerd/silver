#!/usr/bin/env python3
"""Check focused source/byte witnesses, not native-effect or alias closure.

--write --disassembly PATH creates the projections and scans existing retained
read records. Default checks frozen projections; --rescan-reads also repeats
the narrow coverage check. No executable under study or old checker is run.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EVIDENCE = ROOT / "docs/evidence"
OCAML = "8eb41f72ded84df884c3671734c947f612091f84"
SOURCE_ARCHIVE = EVIDENCE / "retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
CAPTURE = EVIDENCE / "retained-why-session-save-state-20261019/capture.tar.gz"
BINDING = EVIDENCE / "retained-why-native-collection-hooks-20261019/capture-binding.json"
OLD_PROJECTION = EVIDENCE / "retained-why-native-collection-hooks-20261019/code-projection.json"
LOAD_BIAS = 0x55A661B32000
FUNCTIONS = {
    "init_sweep_phase", "mark_slice", "clean_slice",
    "caml_major_collection_slice", "caml_empty_minor_heap",
    "caml_oldify_local_roots", "caml_do_roots", "caml_darken_all_roots_start",
    "caml_thread_scan_roots", "caml_thread_initialize", "ml_z_format",
}
CELLS = {
    "caml_major_slice_begin_hook": 0xFAAF48,
    "caml_major_slice_end_hook": 0xFAAF40,
    "caml_minor_gc_begin_hook": 0xFAAF38,
    "caml_minor_gc_end_hook": 0xFAAF30,
    "caml_major_gc_hook": 0xFAAF60,
    "caml_scan_roots_hook": 0xFAAC98,
    "prev_scan_roots_hook": 0xFAAA48,
}
SELECTIONS = {
    "runtime/major_gc.c": [(125, 134), (395, 431), (820, 843), (851, 882), (1106, 1125)],
    "runtime/roots_nat.c": [(30, 37), (330, 360), (405, 452)],
    "runtime/minor_gc.c": [(356, 373), (486, 505)],
    "otherlibs/systhreads/st_stubs.c": [(132, 162), (429, 475)],
    "runtime/caml/freelist.h": [(26, 44)],
    "runtime/freelist.c": [(1755, 1765), (1780, 1840)],
    "runtime/signals.c": [(54, 58), (145, 177), (201, 227)],
    "runtime/io.c": [(54, 63)],
}


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def read_json(path):
    return json.loads(path.read_text())


def write_json(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2) + "\n")


class Elf:
    """Only ELF64 little-endian section and symbol fields needed here."""

    def __init__(self, data):
        self.data = data
        assert data[:6] == b"\x7fELF\x02\x01"
        offset = struct.unpack_from("<Q", data, 40)[0]
        size, count, _ = struct.unpack_from("<HHH", data, 58)
        assert size == 64
        self.sections = [struct.unpack_from("<IIQQQQIIQQ", data, offset + i * size)
                         for i in range(count)]
        self.symbols = {}
        for sec in self.sections:
            if sec[1] not in (2, 11):
                continue
            strs = self.sections[sec[6]]
            names = data[strs[4]:strs[4] + strs[5]]
            for i in range(sec[4], sec[4] + sec[5], sec[9]):
                name, info, other, index, address, length = struct.unpack_from("<IBBHQQ", data, i)
                name = names[name:names.index(0, name)].decode()
                if index and name in FUNCTIONS | set(CELLS):
                    entry = {"address": address, "size": length,
                             "type": info & 15, "section_index": index}
                    if name in self.symbols:
                        assert entry == self.symbols[name]
                    self.symbols[name] = entry

    def at(self, address, size):
        matches = [s for s in self.sections if s[1] != 8 and s[2] & 2
                   and s[3] <= address and address + size <= s[3] + s[5]]
        assert len(matches) == 1, (hex(address), size)
        sec = matches[0]
        offset = sec[4] + address - sec[3]
        return self.data[offset:offset + size]


def source_projection():
    result = {"archive": str(SOURCE_ARCHIVE.relative_to(ROOT)),
              "archive_identity": identity(SOURCE_ARCHIVE.read_bytes()),
              "revision": OCAML, "files": {}}
    with tarfile.open(SOURCE_ARCHIVE) as archive:
        for name, ranges in SELECTIONS.items():
            member = f"ocaml-{OCAML}/{name}"
            data = archive.extractfile(member).read()
            lines = data.decode().splitlines(keepends=True)
            result["files"][name] = {
                "member": member, "identity": identity(data),
                "excerpts": [{"first": first, "last": last,
                              "text": "".join(lines[first - 1:last])}
                             for first, last in ranges],
            }
    return result


def select_bodies(path):
    expected = read_json(OLD_PROJECTION)["origin_identity"]
    data = path.read_bytes()
    assert identity(data) == expected
    selected, current = {}, None
    for line in data.decode().splitlines(keepends=True):
        match = re.match(r"^[0-9a-f]+ <([^>]+)>:\n$", line)
        if match:
            current = match[1] if match[1] in FUNCTIONS else None
            if current:
                assert current not in selected
                selected[current] = []
        if current:
            selected[current].append(line)
    assert set(selected) == FUNCTIONS
    return "".join("".join(selected[name]) for name in sorted(selected))


def native_projection(text, elf):
    result, current = {}, None
    for line in text.splitlines():
        match = re.match(r"^([0-9a-f]+) <([^>]+)>:$", line)
        if match:
            current = match[2]
            assert current in FUNCTIONS and current not in result
            result[current] = {"address": int(match[1], 16), "records": []}
        elif line.strip():
            fields = line.split("\t")
            assert len(fields) in (2, 3), line
            address = int(fields[0].strip().removesuffix(":"), 16)
            data = bytes.fromhex(fields[1])
            assert data == elf.at(address, len(data)), line
            result[current]["records"].append({"address": address,
                "bytes": data.hex(), "operation": fields[2].strip() if len(fields) == 3 else ""})
    assert set(result) == FUNCTIONS
    for name, body in result.items():
        cursor = body["address"]
        assert cursor == elf.symbols[name]["address"]
        payload = bytearray()
        for record in body["records"]:
            assert record["address"] == cursor
            data = bytes.fromhex(record["bytes"])
            payload += data
            cursor += len(data)
        assert cursor >= body["address"] + elf.symbols[name]["size"]
        body["symbol_size"] = elf.symbols[name]["size"]
        body["byte_identity_including_trailing_padding"] = identity(payload)
    cells = {}
    for name, address in CELLS.items():
        symbol = elf.symbols[name]
        assert symbol["address"] == address and symbol["size"] == 8 and symbol["type"] == 1
        cells[name] = symbol
    return {"image_identity": identity(elf.data), "functions": result, "cells": cells,
            "scope": "Selected bodies only; no global client, effective-address, or effect-closure claim."}


def read_coverage():
    earlier = read_json(HERE / "hook-read-coverage.json")
    result = {"pid": 97103, "load_bias": LOAD_BIAS, "targets": {}, "streams": []}
    for name, address in CELLS.items():
        result["targets"][name] = {"elf_address": address, "process_address": LOAD_BIAS + address,
                                   "bytes": 8, "overlaps": []}
    with tarfile.open(CAPTURE) as archive:
        for stream in earlier["streams"]:
            member = stream["member"]
            digest, size, records = hashlib.sha256(), 0, 0
            for line in archive.extractfile(member):
                digest.update(line)
                size += len(line)
                row = json.loads(line)
                records += 1
                start, length = row["address"], row["bytes"]
                assert len(bytes.fromhex(row["hex"])) == length
                for cell in result["targets"].values():
                    if start < cell["process_address"] + 8 and cell["process_address"] < start + length:
                        cell["overlaps"].append({"member": member, "record": records, **row})
            observed = {"member": member, "identity": {"bytes": size, "sha256": digest.hexdigest()},
                        "records": records}
            assert observed == stream
            result["streams"].append(observed)
    result["any_target_read_observed"] = any(c["overlaps"] for c in result["targets"].values())
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--disassembly", type=Path)
    parser.add_argument("--image", type=Path)
    parser.add_argument("--rescan-reads", action="store_true")
    args = parser.parse_args()
    start = time.monotonic()
    for name, expected in read_json(HERE / "inputs.json").items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    binding = read_json(BINDING)
    image_name = next(name for name in binding["mapped_files"] if name.endswith("/gnatwhy3"))
    data = (args.image or Path(image_name)).read_bytes()
    assert identity(data) == binding["mapped_files"][image_name]
    elf = Elf(data)
    bodies = (select_bodies(args.disassembly) if args.disassembly
              else (HERE / "native-bodies.txt").read_text())
    sources, native = source_projection(), native_projection(bodies, elf)
    if args.write:
        assert args.disassembly
        (HERE / "native-bodies.txt").write_text(bodies)
        write_json("source-witnesses.json", sources)
        write_json("native-witnesses.json", native)
        write_json("expanded-read-coverage.json", read_coverage())
    else:
        assert sources == read_json(HERE / "source-witnesses.json")
        assert native == read_json(HERE / "native-witnesses.json")
        if args.rescan_reads:
            assert read_coverage() == read_json(HERE / "expanded-read-coverage.json")
    coverage = read_json(HERE / "expanded-read-coverage.json")
    assert coverage["pid"] == 97103 and coverage["load_bias"] == LOAD_BIAS
    assert coverage["streams"] == read_json(HERE / "hook-read-coverage.json")["streams"]
    assert set(coverage["targets"]) == set(CELLS)
    for name, cell in coverage["targets"].items():
        assert cell == {"elf_address": CELLS[name], "process_address": LOAD_BIAS + CELLS[name],
                        "bytes": 8, "overlaps": []}
    assert coverage["any_target_read_observed"] is False
    for record in read_json(HERE / "zarith-retrieval.json")["files"]:
        data = (HERE / record["url"].rsplit("/", 1)[1]).read_bytes()
        assert identity(data) == {k: record[k] for k in ("bytes", "sha256")}
    debug_path = b"/home/runner/work/why3/why3/_opam/.opam-switch/build/zarith.1.14"
    assert elf.data[19697721:19697721 + len(debug_path)] == debug_path
    result = {"selected_function_bodies": len(native["functions"]),
              "matched_bytes_including_padding": sum(b["byte_identity_including_trailing_padding"]["bytes"]
                                                       for b in native["functions"].values()),
              "selected_source_files": len(sources["files"]),
              "selected_native_cells": len(native["cells"]),
              "read_coverage_recomputed": args.write or args.rescan_reads,
              "complete_reachable_native_effect_set": False,
              "null_preservation_established": False,
              "R": None, "exceptional_identifier_charge": None,
              "elapsed_seconds": time.monotonic() - start}
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
