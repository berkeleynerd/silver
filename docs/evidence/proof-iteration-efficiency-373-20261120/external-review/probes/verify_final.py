"""Reviewer probe: recheck the retained final native/Lean/build records against the review target.

Usage: python3 -I probes/verify_final.py <worktree> <scratch>
Reads committed evidence and the extracted scratch copies only.
"""
from __future__ import annotations

import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

worktree, scratch = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve()
final = worktree / "docs/evidence/proof-iteration-efficiency-373-20261120/final"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def events(name: str) -> list[dict]:
    return [json.loads(line) for line in gzip.decompress((final / name / "events.jsonl.gz").read_bytes()).decode().splitlines()]


def prepared(name: str) -> dict:
    return next(e for e in events(name) if e["event"] == "prepared")["inputs"]


tracked = set(subprocess.run(["git", "ls-files"], cwd=worktree, capture_output=True, text=True, check=True).stdout.split("\n"))

# ---- native
print("== native ==")
native, build = prepared("native"), prepared("build")
reports = scratch / "final-native/reports"
manifest = json.loads((reports / "proof-provenance.json").read_text())
snapshot = json.loads((reports / "proof-inputs.json").read_text())
print("manifest: complete", manifest.get("complete"), "| mode", manifest.get("mode"), "| host", manifest.get("host"),
      "| initial_state", manifest.get("initial_state"))
print("manifest inputs == managed prepared inputs:", manifest["inputs_sha256"] == native["inputs_sha256"], len(native["inputs_sha256"]))
print("manifest tools == managed prepared tools  :", manifest["tools"] == native["tools"], len(native["tools"]))
print("build prepared inputs/tools == native     :", build["inputs_sha256"] == native["inputs_sha256"], build["tools"] == native["tools"])
print("proof-inputs snapshot agrees with manifest:",
      all(snapshot[key] == manifest[key] for key in snapshot))
actual = {path.name: sha(path) for path in reports.iterdir()
          if path.suffix == ".spark" or path.name in ("gnatprove.sarif", "gnatprove.out")}
print("manifest reports_sha256 == archived reports:", manifest["reports_sha256"] == actual, len(actual))
sarif = json.loads((reports / "gnatprove.sarif").read_text())
invocation = sarif["runs"][0]["invocations"][0]
print("SARIF commandLine == ' '.join(manifest command):", invocation["commandLine"] == " ".join(manifest["command"]),
      "| exit", invocation.get("exitCode"), invocation.get("executionSuccessful"),
      "| driver", sarif["runs"][0]["tool"]["driver"].get("version"))
command_event = next(e for e in events("native") if e["event"] == "command")["command"]
print("managed command tail == manifest command:", command_event[-len(manifest["command"]):] == manifest["command"])
print("manifest command:", " ".join(manifest["command"]))

inputs = native["inputs_sha256"]
categories: dict[str, int] = {}
mismatch, untracked = [], []
for relative, digest in inputs.items():
    top = relative.split("/")[0] if not relative.startswith(".") else "/".join(relative.split("/")[:3])
    categories[top] = categories.get(top, 0) + 1
    if relative in tracked:
        if sha(worktree / relative) != digest:
            mismatch.append(relative)
    else:
        untracked.append(relative)
print("input categories:", categories)
print("tracked inputs:", len(inputs) - len(untracked), "mismatching target tree:", mismatch)
print("untracked (generated/tool) inputs:", len(untracked), "non-.tools examples:",
      [name for name in untracked if not name.startswith(".tools/")][:12])
print("tools:", {name: (identity.get("version") or "").strip().splitlines()[0][:60] if identity.get("version") else "(binary identity only)"
                 for name, identity in native["tools"].items()})

units = sorted(path.stem for path in reports.glob("*.spark"))
totals = dict(flow=0, proof=0, all=0, spec=0, no=0, entities_owned=0)
incomplete = []
for unit in units:
    report = json.loads((reports / f"{unit}.spark").read_text())
    if report.get("progress") != "PROGRESS_PROOF" or report.get("stop_reason") != "STOP_REASON_NONE" \
            or any(report.get(key) != [] for key in ("skip_flow_proof", "skip_proof", "pragma_assume")):
        incomplete.append(unit)
    totals["flow"] += len(report["flow"])
    totals["proof"] += len(report["proof"])
    bad = [r for key in ("flow", "proof") for r in report[key]
           if r.get("severity") != "info" or r.get("how_proved") not in ("flow", "prover", "trivial")]
    if bad:
        incomplete.append(unit + ":unproved")
    for value in report["spark"].values():
        totals[value if value in ("all", "spec") else "no"] += 1
print("raw reports:", len(units), "units;", totals, "| incomplete:", incomplete)
out = (reports / "gnatprove.out").read_text()
print("gnatprove.out Total row:", re.findall(r"(?m)^Total\s+.*$", out))
print("analyzed units line:", re.findall(r"Analyzed \d+ units?", out))

# ---- lean
print("== lean ==")
evidence = json.loads(gzip.decompress((final / "lean/lean-evidence.json.gz").read_bytes()))
log = gzip.decompress((final / "lean/lean-proof.log.gz").read_bytes()).decode()
print({key: evidence.get(key) for key in ("host", "lean_version", "run_id", "scope", "targets", "mode", "clean_build",
                                            "axiom_audit", "kernel_recheck", "threads_per_process", "lake_workers",
                                            "available_cpus", "memory_mb_per_process", "elapsed_seconds",
                                            "inputs_digest_sha256", "workspace", "authoritative_source")})
print("phases:", evidence.get("phases"))
print("modules:", len(evidence["modules"]), "unique:", len(set(evidence["modules"])))
print("inventories: inputs", len(evidence.get("inputs_sha256", {})), "workspace", len(evidence.get("workspace_inputs_sha256", {})),
      "artifacts", len(evidence.get("artifacts_sha256") or {}))
print("log_sha256 matches retained log:", evidence.get("log_sha256") == hashlib.sha256(log.encode()).hexdigest())
audit_lines = [line for line in log.splitlines() if "axiom audit" in line.lower() or "declarations" in line.lower()]
print("audit lines:", audit_lines[:6])
lean_inputs = evidence.get("inputs_sha256", {})
lean_mismatch = [relative for relative, digest in lean_inputs.items()
                 if relative in tracked and sha(worktree / relative) != digest]
lean_untracked = [relative for relative in lean_inputs if relative not in tracked]
print("lean tracked inputs:", len(lean_inputs) - len(lean_untracked), "mismatching target tree:", lean_mismatch,
      "| untracked:", lean_untracked[:8])
digest = hashlib.sha256(json.dumps(lean_inputs, sort_keys=True).encode()).hexdigest()
print("inputs_digest recomputed from inventory:", digest == evidence.get("inputs_digest_sha256"))
build_section = log.split("Lean phase build started", 1)[1].split("Lean phase build finished", 1)[0]
print("build phase lines:", len(build_section.splitlines()), "| mentions of 'Built':", build_section.count("Built "),
      "| 'Replayed':", build_section.count("Replayed "), "| 'Building':", build_section.count("Building "))
print("build phase tail:", [line for line in build_section.strip().splitlines()[-3:]])
print("kernel phase present:", "Lean phase kernel" in log)
module_lines = set(re.findall(r"(?m)^Silver audit module: (\S+)$", log)) or set(re.findall(r"(?m)^\s*module (\S+)$", log))
print("module marker lines in log:", len(module_lines), "equal to evidence modules:", module_lines == set(evidence["modules"]))
commands = evidence.get("commands") or []
print("commands:", [" ".join(c)[-150:] for c in commands])

# ---- build
print("== build ==")
print(gzip.decompress((final / "build/native.log.gz").read_bytes()).decode().strip())
summary = json.loads((final / "final-summary.json").read_text())
print("final-summary keys:", sorted(summary.keys()))
