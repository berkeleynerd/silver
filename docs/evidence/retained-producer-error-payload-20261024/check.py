#!/usr/bin/env python3
"""Offline identity/projection/arithmetic audit; source reasoning is separate."""

import argparse
import ast
import hashlib
import io
import json
from pathlib import Path
import re
import subprocess
import tarfile

from capacity import payload_bounds

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def ident(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def read_input(path):
    if path.startswith("git:"):
        return subprocess.check_output(["git", "show", path[4:]], cwd=ROOT)
    return (ROOT / path).read_bytes()


def strings(value):
    if isinstance(value, str):
        yield value
    elif isinstance(value, list):
        for item in value:
            yield from strings(item)
    elif isinstance(value, dict):
        for key, item in value.items():
            yield key
            yield from strings(item)


def audit():
    inputs = json.loads((HERE / "inputs.json").read_text())
    cache = {}
    for path, expected in inputs.items():
        data = read_input(path)
        assert ident(data) == expected, path
        cache[path] = data

    manifest = json.loads((HERE / "source-manifest.json").read_text())
    archives = {}
    sources = {}
    with tarfile.open(HERE / "sources.tar.gz") as packet:
        assert set(packet.getnames()) == set(manifest)
        for name, record in manifest.items():
            data = packet.extractfile(name).read()
            assert ident(data) == record["identity"], name
            origin = record["origin_archive"]
            if origin not in archives:
                archives[origin] = tarfile.open(fileobj=io.BytesIO(cache[origin]))
            original = archives[origin].extractfile(record["origin_member"]).read()
            assert data == original, name
            sources[name] = data.decode()
    for archive in archives.values():
        archive.close()

    witnesses = json.loads((HERE / "source-witnesses.json").read_text())
    for item in witnesses:
        lines = sources[item["member"]].splitlines(keepends=True)
        assert "".join(lines[item["start"] - 1:item["end"]]) == item["text"]
    recipe = cache["git:a09e2be03b:docs/evidence/retained-producer-report-capacity-20261024/comperr-recipe-applied.adb"].decode()
    original = sources["gcc/ada/comperr.adb"]
    for first, last in (("      procedure End_Line is", "      end End_Line;"),
                        ("         if X'Length + Column > 76 then", "         --  Output source location information")):
        start = original.index(first)
        end = original.index(last, start) + len(last)
        assert original[start:end] in recipe
    assert "type Column_Number is range 0 .. 32767;" in sources["gcc/ada/types.ads"]
    assert "Types.Column_Number'Pred (Types.Column_Number'Last)" in sources["gcc/ada/hostparm.ads"]
    assert "Buffer_Max : constant := Hostparm.Max_Line_Length;" in sources["gcc/ada/output.ads"]
    assert "Buffer : String (1 .. Buffer_Max + 1)" in sources["gcc/ada/output.adb"]

    # Every complete retained Why callback is available to review. This lexical
    # check verifies correspondence and the simple pre-match/rejector shape;
    # it is not a pattern-matching/reachability theorem for arbitrary OCaml.
    registry_path = "docs/evidence/retained-why-session-exception-prefix-20261019/why-printer-inventory.json"
    registry = json.loads(cache[registry_path])
    assert len(registry) == 55
    registry_projection = []
    for index, item in enumerate(registry):
        source = sources[item["file"]]
        snippet = item["source"].rstrip("\n")
        assert snippet in source, (index, item["file"])
        matched = re.search(r"\bmatch\s+(?:exn|e)\s+with\b|\bfunction\b", snippet)
        assert matched, (index, item["file"])
        prefix = snippet[:matched.start()]
        assert not re.search(r"\b(?:fprintf|printf|eprintf|pp_print\w*)\b", prefix)
        fallback = re.search(r"\|\s*(_|exn|e)\s*->\s*raise\s+(?:exn|e)\b", snippet)
        assert fallback, (index, item["file"])
        registry_projection.append({"index": index, "file": item["file"],
                                    "start": item["start"], "fallback": fallback.group(0)})

    native_projection = []
    capture_path = "docs/evidence/retained-fixed-ptree-capture-20261023/capture.tar.gz"
    capture_manifest = json.loads(cache["docs/evidence/retained-fixed-ptree-capture-20261023/archive-manifest.json"])
    with tarfile.open(fileobj=io.BytesIO(cache[capture_path])) as archive:
        for member in archive.getmembers():
            if not member.name.endswith(".gnat-json"):
                continue
            data = archive.extractfile(member).read()
            assert ident(data) == capture_manifest["capture.tar.gz"]["members"][member.name]
            payloads = list(strings(json.loads(data)))
            assert all(all(32 <= ord(c) <= 126 for c in s) for s in payloads)
            native_projection.append({"member": member.name, "identity": ident(data),
                                      "strings": len(payloads), "all_printable_ascii": True})
    assert len(native_projection) == 5
    paths = json.loads(cache["docs/evidence/retained-fixed-failure-composition-20261023/paths.json"])
    path_strings = list(strings(paths))
    assert all(all(32 <= ord(c) <= 126 for c in s) for s in path_strings)

    # Check the exact recurrence arithmetic independently of helper constants.
    def merged(text, aborts, diagnostics, direct):
        return text + 69 * (10 * aborts + diagnostics + 4) + diagnostics + 2 + direct

    examples = [payload_bounds(p) for p in (180, 416, 558, 559, 1927)]
    for row in examples:
        p, q, early, post, line = [row[k] for k in
            ("P", "primary", "early_primary", "post_primary", "canonical_response_line_ceiling")]
        leaf = max(4096, 4 * p + 3072)
        # Raw fallback may start at the registered quoted Dynlink callback,
        # independently of a direct Why Plugin match in the custom handler.
        # The source note supplies the printable/TAB/LF/CR alphabet premise.
        raw_dynlink = (2 * (2 * (p + 512) + 32) + 128,
                       2 * (467 + 2 * 467 + 3 * 68 + 32) + 128,
                       2 * (2 * (p + 467) + 96) + 128)
        assert raw_dynlink == (4 * p + 2240, 3402, 4 * p + 2188)
        assert max(raw_dynlink) <= leaf
        assert q == leaf + 2 * (p + 128) + 467 + 52 + 29 + p + 128 + 70 * 66
        assert row["inside_main_merged"] == merged(2 * (q + 3 * 512) + 4 * 42 + 64, 4, 1, 2 * 512 + 253)
        assert row["before_main_merged"] == merged(2 * (early + 3 * 512) + 4 * 42 + 64, 4, 1, early + 512 + 253)
        assert row["post_cut_merged"] == merged(2 * (post + 512) + 4 * (line + p) + 2 * 42, 2, 0, 2 * 512 + 253)
        assert row["inside_main_merged"] - row["post_cut_merged"] == 8414 - 4 * p
        assert row["active_normal_suffix_bytes"] == merged(2 * (2 * 512) + 2 * 42, 2, 0, 2 * 512 + 253)
    assert payload_bounds(416)["merged_bytes"] == 30761
    assert payload_bounds(558)["compiler_abort_tail_guard"]
    assert not payload_bounds(559)["compiler_abort_tail_guard"]

    # Small direct model of GCC Output's byte/explicit-EOL endpoints. This is
    # a boundary regression check; the cited Ada source owns the general claim.
    def endpoint(length, lf_at_end=False):
        col = 1
        def char(c):
            nonlocal col
            if col > 32767:
                col = 1
            if c == "\n":
                assert col <= 32767
                col = 1
            else:
                col += 1
        for c in "|    ":
            char(c)
        for _ in range(length):
            char("x")
        if lf_at_end:
            char("\n")
        while col < 76:
            char(" ")
        char("|")
        return col <= 32767
    assert endpoint(32760)
    assert not endpoint(32761)
    assert endpoint(33227168, lf_at_end=True)
    assert "if C = ASCII.LF then\n         Write_Eol;" in sources["gcc/ada/output.adb"]
    for file in HERE.glob("*.py"):
        ast.parse(file.read_text())
    return {
        "status": "pass", "scope": "offline identities, exact fixed-byte projections and conditional arithmetic; semantic control proof requires review",
        "input_files": len(inputs), "complete_source_files": len(sources), "source_witnesses": len(witnesses),
        "registry_callbacks": len(registry_projection), "registry_projection": registry_projection,
        "native_inputs": native_projection, "recorded_path_strings_checked": len(path_strings),
        "cwd_ascii_assumed": False, "post_cut_raw_path_ascii_assumed": False,
        "examples": examples, "sufficient_P_interval": [180, 558],
        "native_runs": 0, "historical_manifest_recovery": False,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="write the deterministic result.json")
    args = parser.parse_args()
    result = audit()
    if args.write:
        (HERE / "result.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    else:
        assert result == json.loads((HERE / "result.json").read_text())
    print(json.dumps({k: result[k] for k in ("status", "input_files", "complete_source_files", "source_witnesses", "sufficient_P_interval")}))
