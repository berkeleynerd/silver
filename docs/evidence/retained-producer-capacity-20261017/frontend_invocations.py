#!/usr/bin/env python3
"""Retain pinned frontend constructor sites; never runs the toolchain.

The full Ada source scan checks identity and reproduces a lexical inventory.
The associated exclusion argument is manual, in the producer research report.
"""

import argparse
import hashlib
import json
import re
from pathlib import Path


PIN = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[2]
PRIOR = (REPO / "docs/evidence/unbounded-programs/continuation-20261017/"
         "frontend-lifetimes/complete-source-manifest.json")
RANGES = {
    "checks.adb": [(3509, 3561), (10308, 10337)],
    "exp_aggr.adb": [(4339, 4381)],
    "exp_ch3.adb": [(4851, 4862), (4890, 4899), (4918, 4951)],
    "exp_ch4.adb": [(2046, 2088), (10162, 10259), (10290, 10345)],
    "exp_ch5.adb": [(1014, 1029)],
    "exp_ch9.adb": [(14218, 14245)],
    "exp_pakd.adb": [(1583, 1610)],
    "exp_spark.adb": [(120, 213), (1008, 1023)],
    "exp_util.adb": [(5397, 5412), (8159, 8182), (8289, 8470),
                     (12761, 12824)],
    "expander.adb": [(105, 127)],
    "freeze.adb": [(4303, 4368), (5181, 5215), (7343, 7393),
                   (8293, 8322)],
    "sem_ch3.adb": [(852, 895), (968, 1017), (8617, 8642),
                    (11262, 11294), (14882, 14921), (16595, 16640),
                    (23073, 23113), (23168, 23204)],
    "sem_ch6.adb": [(2141, 2177), (9494, 9540)],
    "sem_ch7.adb": [(2097, 2137)],
    "sem_res.adb": [(13180, 13200)],
}
EXPECTED = {
    "checks.adb": [3551, 3554, 3557, 10330],
    "exp_aggr.adb": [4350, 4376],
    "exp_ch3.adb": [4934, 4938],
    "exp_ch4.adb": [2084, 2085, 10341],
    "exp_ch5.adb": [1024, 1025],
    "exp_ch9.adb": [14231],
    "exp_pakd.adb": [1605, 1606],
    "exp_util.adb": [5408],
    "freeze.adb": [4360, 5200, 7374, 8311],
    "sem_ch3.adb": [891, 980, 999, 1004, 1013, 8633, 11269,
                    14915, 16633, 23105, 23198],
    "sem_ch6.adb": [2164, 2169, 9532],
    "sem_ch7.adb": [2123],
    "sem_res.adb": [13197],
}
CALL = re.compile(r"\b(Make_Itype_Reference|Build_Itype_Reference|Ensure_Defined)\b")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--frontend-root", type=Path, required=True)
    args = parser.parse_args()
    manifest = json.loads(PRIOR.read_text())
    assert manifest["commit"] == PIN
    entries = {item["path"]: item for item in manifest["files"]
               if item["path"].endswith((".adb", ".ads"))}
    files = {}
    inventory = []
    node_kind_mentions = []
    scanned = []
    for name, expected in sorted(entries.items()):
        raw = (args.frontend_root / name).read_bytes()
        digest = hashlib.sha256(raw).hexdigest()
        assert len(raw) == expected["bytes"] and digest == expected["sha256"], name
        scanned.append({"path": name, "sha256": digest})
        lines = raw.decode().split("\n")
        files[name] = lines
        for number, line in enumerate(lines, 1):
            code = line.split("--", 1)[0]
            if "N_Itype_Reference" in code:
                node_kind_mentions.append({"path": name, "line": number,
                                           "text": code.strip()})
            if not name.endswith(".adb"):
                continue
            for match in CALL.finditer(code):
                if re.search(r"\b(?:procedure|function|end)\s+$", code[:match.start()]):
                    continue
                inventory.append({"path": name, "line": number,
                                  "callee": match.group(1)})
    actual = {}
    for item in inventory:
        actual.setdefault(item["path"], []).append(item["line"])
    assert actual == EXPECTED
    excerpts = [f"# Frontend invocation excerpts\n\nGCC `{PIN}`; full files "
                "hash-verified against the retained complete source manifest.\n"]
    retained = []
    for name, ranges in sorted(RANGES.items()):
        expected = entries[name]
        retained.append({"path": name, "sha256": expected["sha256"],
                         "bytes": expected["bytes"], "ranges": ranges})
        for first, last in ranges:
            excerpts.append(f"\n## {name}:{first}–{last}\n\n```ada\n")
            excerpts.extend(f"{i:6d} {files[name][i - 1]}".rstrip() + "\n"
                            for i in range(first, last + 1))
            excerpts.append("```\n")
    result = {
        "commit": PIN,
        "verified_against": str(PRIOR.relative_to(REPO)),
        "scan_file_count": len(scanned),
        "scan_path_digest_sha256": hashlib.sha256(
            json.dumps(scanned, sort_keys=True, separators=(",", ":")).encode()).hexdigest(),
        "call_site_count_including_two_helper_bodies": len(inventory),
        "call_sites": inventory,
        "raw_node_kind_mentions_for_manual_review": node_kind_mentions,
        "retained_files": retained,
        "scope": "Pinned-source identity and lexical inventory; manual reachability argument in research report",
        "toolchain_or_proof_processes_run": False,
    }
    (ROOT / "frontend-invocation-audit.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n")
    (ROOT / "frontend-invocation-excerpts.md").write_text("".join(excerpts))
    print(json.dumps({"verified_ada_source_files": len(scanned),
                      "itype_reference_sites": len(inventory)}))


if __name__ == "__main__":
    main()
