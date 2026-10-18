#!/usr/bin/env python3
"""Inventory the pinned temporary-name counter; never executes a toolchain."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile


ROOT = Path(__file__).resolve().parent
EXPECTED_STRING_CALLS = {
    "src/why/gnat2why-expr-aggregates.adb": [2565],
    "src/why/gnat2why-expr.adb": [7371, 15981, 30276],
    "src/why/why-gen-names.adb": [865, 880],
}


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def clean_code(source):
    return re.sub(r'"(?:[^"\n]|"")*"|--[^\n]*',
                  lambda m: " " * len(m.group()), source)


def inventory(source_root, archive):
    expected_archive = json.loads((ROOT / "source-archive-check.json").read_text())
    assert digest(archive.read_bytes()) == expected_archive["archive_sha256"]
    sources = {str(p.relative_to(source_root)): p.read_bytes()
               for p in sorted((source_root / "src").rglob("*"))
               if p.suffix in (".adb", ".ads")}
    with tarfile.open(archive) as retained:
        archived = {m.name.removeprefix("spark-source/"): m for m in retained
                    if m.isfile() and m.name.startswith("spark-source/src/")
                    and m.name.endswith((".adb", ".ads"))}
        assert sources.keys() == archived.keys()
        for name, raw in sources.items():
            assert raw == retained.extractfile(archived[name]).read(), name

    calls = {}
    string_calls = {}
    declarations = 0
    identifiers = 0
    for name, raw in sorted(sources.items()):
        source = raw.decode()
        clean = clean_code(source)
        for match in re.finditer(r"\bNew_Temp_Identifier\b", clean):
            prefix = clean[clean.rfind("\n", 0, match.start()) + 1:match.start()]
            if re.search(r"\b(?:function|end)\s*$", prefix):
                declarations += 1
                continue
            start = match.end()
            while clean[start].isspace():
                start += 1
            assert clean[start] == "(", (name, start)
            depth, end = 1, start + 1
            while depth:
                depth += (clean[end] == "(") - (clean[end] == ")")
                end += 1
            args = clean[start + 1:end - 1]
            line = source[:match.start()].count("\n") + 1
            calls.setdefault(name, []).append(line)
            # Named type/node or multiple positional actuals select the
            # identifier overload. The remaining six sites are reviewed below.
            if re.search(r"\b(?:Typ|Ada_Node)\b", args) or "," in args:
                identifiers += 1
            else:
                string_calls.setdefault(name, []).append(line)
    assert string_calls == EXPECTED_STRING_CALLS
    assert declarations == 6  # two spec declarations, two bodies, two ends
    scanned = [{"path": name, "sha256": digest(raw)}
               for name, raw in sorted(sources.items())]
    return {
        "archive_sha256": expected_archive["archive_sha256"],
        "verified_complete_ada_files": len(sources),
        "scan_manifest_sha256": digest(json.dumps(
            scanned, sort_keys=True, separators=(",", ":")).encode()),
        "call_lines_by_file": calls,
        "identifier_overload_call_sites": identifiers,
        "string_overload_call_lines": string_calls,
        "manual_charges": {
            "names:865,880": "fresh identifier returned by each wrapper",
            "expr:7371": "enclosing New_Identifier",
            "expr:30276": "literal identifier at 30278, also fresh module at 30282",
            "aggregates:2565": "fresh module via 3687/3713 or 4300/4329 and 2576",
            "expr:15981": "fresh module via 15989 and 16051",
        },
        "conclusion": "Every increment can be charged to a distinct pre-import node; "
                      "temporary counter <= B_N for the complete bounded producer",
        "scope": "Lexical completeness and source identity are checked; "
                 "the allocation charging argument is manual",
        "toolchain_or_proof_processes_run": False,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--source-archive", type=Path, required=True)
    args = parser.parse_args()
    result = inventory(args.source_root, args.source_archive)
    (ROOT / "producer-counter-inventory.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps({"verified_complete_ada_files": result["verified_complete_ada_files"],
                      "identifier_call_sites": result["identifier_overload_call_sites"],
                      "string_call_sites": 6, "toolchain_run": False}))
