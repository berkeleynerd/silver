#!/usr/bin/env python3
"""Prepared #246 AFTER→BEFORE pair; invoke only after lead confirms probe result."""
import argparse
import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess

base = Path(__file__).resolve().parent
root = base.parent.parent
baseline = "e94c8b4343f429c434900cc2a23e29e870f577bf"
reviewed = "80d5ec3e0e5224fe36c705f6be15e429b7fa7468"
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--resource-probe-run", required=True)
args = parser.parse_args()
lock = (base / "pair-24g.lock").open("a+b")
fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)


def event(stage, **details):
    row = {"at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
           "stage": stage, "pid": os.getpid(), "order": "AFTER→BEFORE", **details}
    with (base / "pair-24g.jsonl").open("a") as stream:
        stream.write(json.dumps(row) + "\n")
    print(json.dumps(row), flush=True)


def snapshot(label, commit):
    snap = base / (label + "-worktree")
    assert not snap.exists(), f"Refusing to overwrite {snap}"
    event("preparing-" + label, worktree=str(snap), commit=commit)
    with (base / ("setup-" + label + ".log")).open("w") as log:
        subprocess.run(["git", "worktree", "add", "--detach", str(snap), commit], cwd=root,
                       stdout=log, stderr=subprocess.STDOUT, check=True)
    shutil.copytree(base / "warm-proof", snap / ".silver/linux-x86_64/proof",
                    symlinks=True, copy_function=shutil.copy2)
    shutil.copytree(base / "profile/.tools/linux-x86_64/lean", snap / ".tools/linux-x86_64/lean",
                    symlinks=True, copy_function=shutil.copy2)
    return snap


def invalidate(snap, label, after):
    imports = {str(p.relative_to(snap / "proof"))[:-5].replace("/", "."):
               set(re.findall(r"^(?:(?:public|meta)\s+)*import\s+(?:all\s+)?(\S+)", p.read_text(), re.MULTILINE))
               for p in (snap / "proof").rglob("*.lean") if ".lake" not in p.parts and p.name != "lakefile.lean"}
    roots = {"Silver.OutputBodyCertificate", "Silver.PredicateSourceCandidate", "Silver.ComposeSourceChecks"}
    if after:
        roots.add("Silver.ComposeSourceCandidate")
    modules = set(roots)
    while True:
        expanded = modules | {name for name, deps in imports.items() if deps & modules}
        if expanded == modules:
            break
        modules = expanded
    assert len(modules) == (20 if after else 19), sorted(modules)
    workspace = snap / ".silver/linux-x86_64/proof"
    removed = {}
    for name in sorted(modules):
        relative = Path(name.replace(".", "/"))
        for folder in ["lib/lean", "ir"]:
            for artifact in (workspace / ".lake/build" / folder / relative.parent).glob(relative.name + ".*"):
                assert artifact.is_file() and not artifact.is_symlink()
                removed[str(artifact.relative_to(workspace))] = {
                    "sha256": hashlib.sha256(artifact.read_bytes()).hexdigest(),
                    "bytes": artifact.stat().st_size, "mtime_ns": artifact.stat().st_mtime_ns}
                artifact.unlink()
    record = {"commit": reviewed if after else baseline, "roots": sorted(roots), "closure": sorted(modules),
              "removed_artifacts": removed, "seed": str(base / "warm-proof"),
              "seed_complete_run": "20261026T131016-6b27137135dc", "order": "AFTER→BEFORE"}
    (base / (label + "-invalidation.json")).write_text(json.dumps(record, indent=2) + "\n")
    return modules


def complete(snap, label, expected, commit):
    command = ["python3", str(base / "measure_pair_24g.py"), label, "--snapshot", str(snap), "--workers", "2"]
    event(label + "-started", command=command, worktree=str(snap), commit=commit)
    with (base / ("launcher-" + label + ".log")).open("w") as log:
        subprocess.run(command, cwd=root, stdout=log, stderr=subprocess.STDOUT, check=True)
    out = base / label
    evidence = json.loads((out / "lean-evidence.json").read_text())
    measured = json.loads((out / "result.json").read_text())
    assert evidence["scope"] == "complete" and evidence["axiom_audit"] == "passed"
    assert evidence["memory_mb_per_process"] == 24576
    assert evidence["lake_workers"] == 2 and evidence["threads_per_process"] == 2
    assert measured["exit_code"] == 0 and measured["cutoff_reason"] is None
    built = set(re.findall(r"\bBuilt (Silver(?:\.[A-Za-z_][A-Za-z0-9_]*)*)\b", (out / "lean-proof.log").read_text()))
    before = json.loads((out / "artifacts-before.json").read_text())
    after = json.loads((out / "artifacts-after.json").read_text())
    objects = {path[len(".lake/build/lib/lean/"):-len(".olean")].replace("/", ".")
               for path, item in after.items() if path.startswith(".lake/build/lib/lean/")
               and path.endswith(".olean") and (path not in before or before[path] != item)}
    summary = {"commit": commit, "order": "AFTER→BEFORE", "run_id": evidence["run_id"],
               "scope": evidence["scope"], "elapsed_seconds": evidence["elapsed_seconds"], "phases": evidence["phases"],
               "module_count": len(evidence["modules"]), "axiom_audit": evidence["axiom_audit"],
               "kernel_recheck": evidence["kernel_recheck"], "launcher_result": measured,
               "built_modules_from_log": sorted(built), "changed_or_created_olean_modules": sorted(objects),
               "expected_rebuild_closure": sorted(expected),
               "limits": "One fixed-order pair on one host; order/cache/host drift can affect timing; no general scaling claim"}
    (out / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    assert built == objects == expected, f"{label} rebuilt set mismatch; inspect summary"
    event(label + "-finished", run_id=evidence["run_id"], elapsed_seconds=evidence["elapsed_seconds"],
          rebuilt_count=len(built), summary=str(out / "summary.json"))


try:
    probe = json.loads((base / "resource-probe-run/lean-focused-evidence.json").read_text())
    result = json.loads((base / "resource-probe-run/result.json").read_text())
    assert probe["run_id"] == args.resource_probe_run and probe["axiom_audit"] == "passed"
    assert probe["scope"] == "focused" and probe["targets"] == ["Silver.ComposeRefinementResourceProbe"]
    assert probe["memory_mb_per_process"] == 24576
    assert result["exit_code"] == 0 and result["cutoff_reason"] is None
    event("revised-pair-started", resource_probe_run=probe["run_id"],
          reason="Retained16GiB correctness failure; exact two-fact24GiB resource probe passed; measured AFTER also provides complete C1 correctness")
    after = snapshot("after-24g", reviewed)
    after_modules = invalidate(after, "after-24g", True)
    complete(after, "after-24g", after_modules, reviewed)
    before = snapshot("before-24g", baseline)
    before_modules = invalidate(before, "before-24g", False)
    assert after_modules == before_modules | {"Silver.ComposeSourceCandidate"}
    complete(before, "before-24g", before_modules, baseline)
    event("matched-pair-complete", next_step="Lead integration and separately authorized serialized predicate diagnostic")
except BaseException as error:
    event("stopped-on-failure", error=repr(error), next_step="Lead diagnosis; retain evidence; no automatic retry")
    raise
