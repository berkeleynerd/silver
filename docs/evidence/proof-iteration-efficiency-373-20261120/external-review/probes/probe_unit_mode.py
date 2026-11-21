"""Reviewer probe: run the focused unit-mode report check over every real compiler unit.

The retained final complete (-U) reports stand in for per-unit `-u` output, so this
exercises FocusedProof.check_report's owned-coverage, trusted-import and vendor-instance
branches on producer data.  The SARIF command line is taken from the archive, so the
invocation-identity comparison is not what is being tested here.

Usage: python3 -B probes/probe_unit_mode.py <worktree> <scratch>
"""
from __future__ import annotations

import json
from pathlib import Path
import sys

worktree, scratch = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve()
sys.path.insert(0, str(worktree))

from scripts import check_evidence  # noqa: E402
from scripts.focused_proof import FocusedProof  # noqa: E402

reports = scratch / "final-native/reports"
source_dir = scratch / "final-src/src"
generated = scratch / "final-src/.silver/linux-x86_64/generated"
command = json.loads((reports / "gnatprove.sarif").read_text())["runs"][0]["invocations"][0]["commandLine"].split(" ")

sources = sorted(p for p in source_dir.iterdir() if p.suffix in (".ads", ".adb"))
sources += sorted(p for p in generated.iterdir() if p.suffix in (".ads", ".adb"))
units = sorted({p.stem for p in sources})
totals = {"entity_count": 0, "flow_checks": 0, "proof_checks": 0}
rejected, differing = {}, []
kinds = {"trusted import": 0, "vendor instance": 0, "ordinary": 0}
options_seen = {}
for unit in units:
    results = {}
    for source in [p for p in sources if p.stem == unit]:
        focus = FocusedProof.select(source.name, None)
        options = focus.options(source)
        options_seen[source.name] = options[options.index("-u") + 1]
        try:
            results[source.name] = focus.check_report(source, reports, command)
        except Exception as error:  # noqa: BLE001
            results[source.name] = f"{type(error).__name__}: {error}"
    values = list(results.values())
    if any(isinstance(value, str) for value in values):
        rejected[unit] = results
        continue
    if any(value != values[0] for value in values):
        differing.append((unit, results))
    for key in totals:
        totals[key] += values[0][key]
    if unit + ".ads" in check_evidence.TRUSTED_IMPORT_SPECS:
        kinds["trusted import"] += 1
    elif unit in check_evidence.SEQUENCE_INSTANCES:
        kinds["vendor instance"] += 1
    else:
        kinds["ordinary"] += 1

print("units:", len(units), "| accepted:", len(units) - len(rejected), "| rejected:", rejected)
print("accepted kinds:", kinds)
print("spec and body spellings disagree for:", differing)
print("sum over units:", totals, "(complete audit: 1252 entities, 1751 flow, 17975 proof)")
selected = {name: target for name, target in options_seen.items() if name != target}
print("spec selections redirected to their body:", len(selected), "| e.g.", dict(list(selected.items())[:3]))
print("spec-only units analysed by spec:", sorted(name for name, target in options_seen.items()
                                                 if name.endswith(".ads") and target == name))

# Scope labels recorded for the two spellings of one unit (see finding on recurrence families).
for name in ("silver_numbers.ads", "silver_numbers.adb"):
    print("scope for", name, "->", FocusedProof.select(name, None).scope(),
          "| effective -u", options_seen[name])
