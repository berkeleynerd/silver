#!/usr/bin/env python3
"""Optional complete GCC raw-argument inventory; source classification is manual."""
import argparse
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
NAMES = {
    "Error_Msg", "Error_Msg_N", "Error_Msg_NE", "Error_Msg_F", "Error_Msg_FE",
    "Error_Msg_NEL", "Error_Msg_NW", "Error_Msg_S", "Error_Msg_AP",
    "Error_Msg_BC", "Error_Msg_SC", "Error_Msg_SP",
}


def masked(raw):
    code = list(raw)
    literals = []
    i = 0
    while i < len(raw):
        if raw.startswith("--", i):
            end = raw.find("\n", i)
            end = len(raw) if end < 0 else end
            code[i:end] = " "*(end-i)
            i = end
        elif raw[i] == "'" and i+2 < len(raw) and raw[i+2] == "'":
            literals.append((i, i+3, raw[i+1]))
            code[i:i+3] = " "*3
            i += 3
        elif raw[i] == '"':
            start = i
            i += 1
            value = ""
            while i < len(raw):
                if raw[i] == '"':
                    if i+1 < len(raw) and raw[i+1] == '"':
                        value += '"'
                        i += 2
                        continue
                    i += 1
                    break
                value += raw[i]
                i += 1
            code[start:i] = " "*(i-start)
            literals.append((start, i, value))
        else:
            i += 1
    return "".join(code), literals


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--gcc-root", type=Path, required=True)
    args = parser.parse_args()
    manifest = json.loads((ROOT / (
        "docs/evidence/unbounded-programs/continuation-20261017/"
        "frontend-lifetimes/complete-source-manifest.json"
    )).read_text())
    expected = {r["path"]: r for r in manifest["files"]}
    rows = []
    sources = {}
    static_max = {"bytes": 0}
    calls = 0
    pattern = re.compile(r"\b("+"|".join(sorted(NAMES, key=len, reverse=True))+r")\s*\(")
    for name, entry in sorted(expected.items()):
        if "/" in name or not name.endswith(".adb"):
            continue
        data = (args.gcc_root / name).read_bytes()
        assert len(data) == entry["bytes"]
        assert hashlib.sha256(data).hexdigest() == entry["sha256"]
        sources[name] = entry
        raw = data.decode()
        code, literals = masked(raw)
        for match in pattern.finditer(code):
            before = code[max(0, match.start()-30):match.start()]
            if re.search(r"\bprocedure\s*$", before):
                continue
            start = match.end()
            end = start
            depth = 0
            while end < len(code):
                c = code[end]
                if c == "(":
                    depth += 1
                elif c == ")":
                    if depth == 0:
                        break
                    depth -= 1
                elif c == "," and depth == 0:
                    break
                end += 1
            calls += 1
            argument = " ".join(raw[start:end].split())
            stripped = re.sub(r"^\s*Msg\s*=>", "", code[start:end], flags=re.I)
            row = {"file": name, "line": raw.count("\n", 0, match.start())+1,
                   "callee": match.group(1), "argument": argument}
            if re.search(r"[A-Za-z_]", stripped):
                rows.append(row)
            else:
                size = sum(len(value.encode()) for lo, hi, value in literals
                           if start <= lo < hi <= end)
                if size > static_max["bytes"]:
                    static_max = {"bytes": size, **row}
    result = {
        "scope": "Lexical raw-argument inventory, not a reachability or caller-count proof",
        "gcc_revision": manifest["commit"], "entrypoint_names": sorted(NAMES),
        "call_occurrences": calls, "nonstatic_arguments": rows,
        "maximum_direct_literal_argument": static_max, "sources": sources,
    }
    (HERE / "raw-argument-inventory.json").write_text(json.dumps(result, indent=2, sort_keys=True)+"\n")
    print(json.dumps({"calls": calls, "nonstatic": len(rows), "static_max": static_max["bytes"]}, sort_keys=True))


if __name__ == "__main__":
    main()
