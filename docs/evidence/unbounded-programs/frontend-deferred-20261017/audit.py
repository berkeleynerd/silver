#!/usr/bin/env python3
"""Audit exact upstream sources; does not build a compiler or compile Ada.

Usage: python3 audit.py UPSTREAM_ROOT OUTPUT_DIRECTORY GCC_EMISSION_ROOT
UPSTREAM_ROOT contains gcc/ada/ and ada-tree.json from the prior full-tree audit.
GCC_EMISSION_ROOT contains the four flattened files in gcc-emission-sources.tar.gz.
The lexical inventory is a review aid, not an Ada name resolver or call graph.
"""

import hashlib
import json
from pathlib import Path
import re
import sys

PIN = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
SYMBOLS = """Start_String End_String Store_String_Char Store_String_Chars
Store_String_Int Unstore_String_Char String_Length Get_String_Char String_Equal
String_To_Name String_To_Name_Buffer String_From_Name_Buffer Strings_Address
String_Chars_Address Write_Char_Code Write_String_Table_Entry""".split()
CANONICAL = {s.lower(): s for s in SYMBOLS}
TOKEN = re.compile(r"\b(?:" + "|".join(SYMBOLS) + r")\b", re.I)


def blank(match):
    return "".join("\n" if c == "\n" else " " for c in match[0])


def code_only(text, ada):
    if ada:
        return re.sub(r'''--[^\n]*|'(?:[^'\n]|')'|"(?:""|[^"])*"''', blank, text)
    return re.sub(r'''//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*' ''',
                  blank, text, flags=re.X)


def save(out, name, value):
    (out / name).write_text(json.dumps(value, indent=2) + "\n")


def main():
    root, out, gcc_root = map(Path, sys.argv[1:])
    out.mkdir(parents=True, exist_ok=True)
    tree = json.loads((root / "ada-tree.json").read_text())
    files, errors, matches, references, overloads = [], [], [], [], []
    for entry in sorted(tree["tree"], key=lambda e: e["path"]):
        if entry["type"] != "blob":
            continue
        path = root / "gcc/ada" / entry["path"]
        data = path.read_bytes()
        blob = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
        files.append({"path": entry["path"], "bytes": len(data),
                      "git_blob_sha1": blob, "sha256": hashlib.sha256(data).hexdigest()})
        if blob != entry["sha"]:
            errors.append(entry["path"])
        if path.suffix.lower() not in (".adb", ".ads", ".cc", ".h", ".c"):
            continue
        raw = data.decode("utf-8", errors="replace")
        original = raw.splitlines()
        ada = path.suffix.lower() in (".adb", ".ads")
        code = code_only(raw, ada)
        imports = ada and bool(re.search(r"\bwith\s+Stringt\s*;", code, re.I))
        for number, line in enumerate(code.splitlines(), 1):
            hit = {"path": entry["path"], "line": number,
                   "source": original[number - 1].strip()}
            symbols = sorted({CANONICAL[s.lower()] for s in TOKEN.findall(line)})
            if symbols:
                matches.append({"path": hit["path"], "line": number,
                                "symbols": symbols, "source": hit["source"]})
            if re.search(r"\bStringt\b|\bStrings_Ptr\b|\bString_Chars_Ptr\b|"
                         r"\bStrings_Address\b|\bString_Chars_Address\b", line, re.I):
                references.append(hit)
            if ada and (imports or path.name in ("stringt.ads", "stringt.adb")):
                if re.search(r"\b(?:Append|To_String)\b", line, re.I):
                    overloads.append(hit)
    save(out, "consumer-inventory.json", {
        "method": "Complete pinned Ada subtree lexical API inventory; comments and literals filtered; manual resolution required",
        "upstream_commit": PIN, "matches": matches,
        "package_and_raw_pointer_references": references})
    save(out, "overloaded-consumer-candidates.json", {
        "method": "Overloaded name candidates in Ada files importing Stringt and Stringt itself; manual resolution required",
        "matches": overloads})
    verification = {
        "upstream_commit": PIN, "ada_tree": tree["sha"],
        "truncated": tree["truncated"], "files": len(files),
        "bytes": sum(f["bytes"] for f in files), "mismatches": errors,
        "lexical_matching_lines": len(matches),
        "lexical_matching_files": len({h["path"] for h in matches}),
        "overloaded_candidate_lines": len(overloads),
        "package_and_pointer_reference_lines": len(references)}
    save(out, "verified-tree-and-inventory.json", verification)
    save(out, "design-arithmetic.json", {
        "status": "Symbolic candidate representation, not an implemented benchmark",
        "Int_Last": 2**31 - 1, "final_chain_lengths": [2**30, 2**30],
        "current_final_character_slots_lower_bound": 2**31,
        "current_final_Char_Code_payload_bytes_lower_bound": 4 * 2**31,
        "candidate_chain_leaf_roots": 2, "candidate_chain_concat_roots": 60,
        "candidate_chain_descriptors": 62,
        "caveat": "Excludes lexical tokens, runtime/dependency values, metadata, other folds, arena spare capacity and backend/prover materialization"})
    bundle = Path(__file__).resolve().parent
    for item in json.loads((bundle / "gcc-emission-source-manifest.json").read_text())["files"]:
        data = (gcc_root / item["file"]).read_bytes()
        assert len(data) == item["bytes"]
        assert hashlib.sha256(data).hexdigest() == item["sha256"]
    selected = json.loads((bundle / "selected-source-ranges.json").read_text())
    excerpts, source_manifest = [], []
    for item in selected:
        path = ((root / "gcc/ada" / item["path"]) if item["area"] == "ada"
                else gcc_root / item["path"].replace("/", "__"))
        data = path.read_bytes()
        source_hash = hashlib.sha256(data).hexdigest()
        source_manifest.append({**item, "bytes": len(data), "sha256": source_hash})
        lines = data.decode("utf-8").splitlines()
        excerpts.append(f"SOURCE {item['area']}:{item['path']} @ {PIN}\nSHA256 {source_hash}\n")
        for start, end in item["ranges"]:
            assert 1 <= start <= end <= len(lines)
            excerpts.append(f"LINES {start}-{end}\n")
            excerpts.extend(f"{number:6}: {lines[number - 1]}".rstrip() + "\n"
                            for number in range(start, end + 1))
        excerpts.append("\n")
    (out / "selected-source-excerpts.txt").write_text("".join(excerpts).rstrip() + "\n")
    save(out, "selected-source-manifest.json", source_manifest)
    assert not tree["truncated"] and not errors
    print(json.dumps(verification))


if __name__ == "__main__":
    main()
