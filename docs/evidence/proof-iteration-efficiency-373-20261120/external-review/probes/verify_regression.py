"""Reviewer probe: independently recompute the #373 regression census from raw logs and discovery.

Discovery imports the test modules but runs no test.  Usage:

    python3 -B probes/verify_regression.py <worktree>
"""
from __future__ import annotations

import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import unittest

worktree = Path(sys.argv[1]).resolve()
packet = worktree / "docs/evidence/proof-iteration-efficiency-373-20261120"
accounting = json.loads((packet / "regression-accounting.json").read_text())

HEADER = re.compile(r"\b(test\w+) \(((?:tests\.)?test_[\w.]+)\)")
RESULT = re.compile(r"\.\.\. (ok|FAIL|ERROR|skipped|expected failure|unexpected success)\b")
LINE_RESULT = re.compile(r"(?m)^(ok|FAIL|ERROR|skipped.*|expected failure|unexpected success)$")


def census(text: str) -> tuple[dict[str, str], str]:
    """Pair each unittest header with the first terminal result that follows it."""
    body, _, tail = text.rpartition("\n----------------------------------------------------------------------\nRan ")
    headers = list(HEADER.finditer(body))
    outcomes: dict[str, str] = {}
    duplicates = []
    for index, match in enumerate(headers):
        end = headers[index + 1].start() if index + 1 < len(headers) else len(body)
        identity = match[2]
        result = RESULT.search(body, match.end(), end)
        if identity in outcomes:
            duplicates.append(identity)
            continue
        if result is None and "... " in body[match.end():end]:
            # Output printed by the test separates the ellipsis from its terminal token.
            lines = LINE_RESULT.findall(body, match.end(), end)
            outcomes[identity] = lines[-1] if len(lines) == 1 else f"AMBIGUOUS {lines}"
            continue
        outcomes[identity] = result[1] if result else "NO RESULT"
    return outcomes, "Ran " + tail.strip().replace("\n", " | ")[:120] + (f" duplicates={duplicates}" if duplicates else "")


def read(path: Path) -> tuple[str, str]:
    data = gzip.decompress(path.read_bytes())
    return data.decode("utf-8", "replace"), hashlib.sha256(data).hexdigest()


fresh_text, fresh_hash = read(packet / "native.log.gz")
retained_path = worktree / accounting["retained"]["path"]
retained_text, retained_hash = read(retained_path)
fresh, fresh_tail = census(fresh_text)
retained, retained_tail = census(retained_text)
print("fresh log   :", len(fresh), "ids;", {v: list(fresh.values()).count(v) for v in set(fresh.values())}, "|", fresh_tail)
print("retained log:", len(retained), "ids;", {v: list(retained.values()).count(v) for v in set(retained.values())}, "|", retained_tail)
print("retained uncompressed sha256 matches record:", retained_hash == accounting["retained"]["uncompressed_sha256"])
print("retained compressed sha256 matches record  :",
      hashlib.sha256(retained_path.read_bytes()).hexdigest() == accounting["retained"]["compressed_sha256"])

# Current discovery at the review target (imports only).
sys.path.insert(0, str(worktree))
import os
os.chdir(worktree)


def ids(suite):
    for item in suite:
        if isinstance(item, unittest.TestSuite):
            yield from ids(item)
        else:
            yield item.id()


discovered = list(ids(unittest.defaultTestLoader.discover("tests")))
current = set(discovered)
print("discovered at target:", len(discovered), "entries,", len(current), "unique;",
      "load errors:", [name for name in current if "_FailedTest" in name or "unittest.loader" in name])

recorded = {item["id"]: item for item in accounting["all_ids"]}
fresh_ok = {name for name, result in fresh.items() if result == "ok"}
retained_ok = {name for name, result in retained.items() if result == "ok"}
print("recorded all_ids == discovery          :", set(recorded) == current, len(recorded))
print("recorded fresh ids == fresh log ok ids  :",
      {k for k, v in recorded.items() if v["evidence"] == "fresh"} == fresh_ok, len(fresh_ok))
retained_recorded = {k for k, v in recorded.items() if v["evidence"] == "retained"}
print("recorded retained ids ⊆ retained log ok :", retained_recorded <= retained_ok, len(retained_recorded))
print("fresh ∪ retained-recorded == discovery  :", fresh_ok | retained_recorded == current)
print("fresh ∩ retained-recorded               :", len(fresh_ok & retained_recorded))
print("new ids (current − retained log)        :", len(current - set(retained)),
      "recorded new:", len(accounting["new_ids"]), "equal:", current - set(retained) == set(accounting["new_ids"]))
print("new ids all fresh ok                    :", (current - set(retained)) <= fresh_ok)
print("retained-log ids no longer discovered   :", sorted(set(retained) - current))
print("retained log non-ok                     :", {k: v for k, v in retained.items() if v != "ok"})
print("fresh log non-ok                        :", {k: v for k, v in fresh.items() if v != "ok"})

# Which modules were rerun fresh, and which retained modules import changed tooling?
fresh_modules = sorted({name.split(".")[0] for name in fresh_ok})
print("fresh modules:", fresh_modules)
changed = subprocess.run(["git", "diff", "--name-only", "9cf913a3a4a69cb40fe99ea39f21d0e237647fe1", "HEAD", "--",
                          "scripts", "tests", "src", "proof", "samples", "catalogue", "rosetta", "silver.gpr",
                          "alire.toml"], cwd=worktree, capture_output=True, text=True, check=True).stdout.split()
print("inputs changed since retained commit 9cf913a3a4:", changed)
retained_modules = sorted({name.removeprefix("tests.").split(".")[0] for name in retained_recorded})
dependents = {}
for module in retained_modules:
    source = (worktree / "tests" / f"{module}.py").read_text()
    hits = sorted(set(re.findall(r"scripts(?:\.| import )[\w, ]*?\b(check_evidence|check_lean|dev|focused_proof|run_history|proof_provenance)\b", source)))
    if hits:
        dependents[module] = (hits, sum(1 for name in retained_recorded
                                         if name.removeprefix("tests.").split(".")[0] == module))
print(f"retained modules: {len(retained_modules)}; importing changed tooling (or its importer): {len(dependents)}")
for module, (hits, count) in dependents.items():
    print(f"   {module}: {hits} retained ids={count}")
print("retained ids in those modules:", sum(count for _, count in dependents.values()))

# Hashes of scripts/tests recorded in the accounting vs the target tree.
mismatch = [path for path, digest in accounting["captured_scripts_and_tests_hashes"].items()
            if not (worktree / path).is_file()
            or hashlib.sha256((worktree / path).read_bytes()).hexdigest() != digest]
print("captured scripts/tests hashes differing from target tree:", mismatch)
