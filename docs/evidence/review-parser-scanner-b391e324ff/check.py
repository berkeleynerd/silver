#!/usr/bin/env python3
"""Retain an independent parser/scanner review inventory; no tool execution."""
import argparse
import hashlib
import json
from pathlib import Path
import re

p = argparse.ArgumentParser()
p.add_argument("ada_source", type=Path)
p.add_argument("output", type=Path)
a = p.parse_args()
repo = Path(__file__).resolve().parents[3]
manifest = json.loads((repo / "docs/evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json").read_text())
assert manifest["commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
expected = {x["path"]: x for x in manifest["files"]}
paths = sorted(a.ada_source.glob("par*.ad[bs]"))
paths += [a.ada_source / n for n in ["scn.adb", "scans.adb", "scans.ads",
          "elists.adb", "types.ads", "restrict.adb", "local_restrict.adb",
          "warnsw.ads", "libgnat/s-rident.ads"]]
hashes = {}
code = {}
for path in paths:
    name = path.relative_to(a.ada_source).as_posix()
    raw = path.read_bytes()
    digest = hashlib.sha256(raw).hexdigest()
    assert digest == expected[name]["sha256"], name
    assert hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest() == expected[name]["git_blob_sha1"], name
    hashes[name] = digest
    # This inventory only searches identifiers/call syntax; do not interpret
    # string contents or its lexical hits as a resolved Ada call graph.
    code[name] = "\n".join(line.split("--", 1)[0] for line in raw.decode().split("\n"))

def sites(expr, only_parser=False):
    found = []
    for name, source in code.items():
        if only_parser and not name.startswith("par"):
            continue
        for m in re.finditer(expr, source, re.I):
            found.append({"file": name, "line_lf": source.count("\n", 0, m.start()) + 1})
    return found

suspicious = sites(r"\bSuspicious_Labels\s*\.\s*Append\s*\(", True)
assert suspicious == [{"file": "par-ch5.adb", "line_lf": 546}]
resets = sites(r"\bSuspicious_Labels\s*\.\s*(?:Init|Set_Last)\b", True)
assert not resets
loop_counter = sites(r"\bLoop_Block_Count\s*:=", True)
assert loop_counter == [{"file": "par-ch5.adb", "line_lf": 2349}]
assert "Token_Node := Saved_State.Save_Token_Node" in code["scans.adb"]
assert re.search(r"Check_Restriction\s*\(No_Obsolescent_Features,\s*New_Node\s*\(N_Empty,\s*S\)\)", code["scn.adb"])
result = {
    "target": "b391e324ff",
    "upstream_commit": manifest["commit"],
    "source_sha256": hashes,
    "suspicious_label_append_sites": suspicious,
    "suspicious_label_parser_reset_sites": resets,
    "loop_counter_assignment_sites": loop_counter,
    "loop_name_lexical_calls_and_headers": sites(r"\bSet_Loop_Block_Name\s*\(", True),
    "reviewed_parser_scope_entries": "2+d",
    "reviewed_parser_loop_auxiliaries": {"ordinary_nodes": "2*F", "entities": "F", "element_headers": 3, "elements": "2*F"},
    "reviewed_scanner_ordinary_nodes": "2*(W+S+N+N_colon)",
    "limitation": "Hashes/lexical anchors corroborate the manual path review; no whole-source/tool capacity proof or compiler/prover execution",
}
a.output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({"sources_verified": len(hashes), "suspicious_append_sites": len(suspicious), "parser_resets": len(resets)}))
