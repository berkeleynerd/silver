#!/usr/bin/env python3
"""Authorized #246 continuation: focused tests, warm correctness, matched pair."""
import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time

base = Path(__file__).resolve().parent
root = base.parent.parent
baseline = "e94c8b4343f429c434900cc2a23e29e870f577bf"
reviewed = "80d5ec3e0e5224fe36c705f6be15e429b7fa7468"
seed = base / "warm-proof"
sequence_pid = 873852
lock = (base / "continuation.lock").open("a+b")
fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)


def event(stage, **details):
    row = {"at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
           "stage": stage, "continuation_pid": os.getpid(), **details}
    with (base / "continuation.jsonl").open("a") as stream:
        stream.write(json.dumps(row) + "\n")
    print(json.dumps(row), flush=True)


def snapshot(name, commit):
    snap = base / name
    assert not snap.exists(), f"Refusing to overwrite existing {snap}"
    event("prepare-worktree", worktree=str(snap), commit=commit)
    with (base / f"setup-{name}.log").open("w") as log:
        subprocess.run(["git", "worktree", "add", "--detach", str(snap), commit],
                       cwd=root, stdout=log, stderr=subprocess.STDOUT, check=True)
    shutil.copytree(seed, snap / ".silver/linux-x86_64/proof", symlinks=True,
                    copy_function=shutil.copy2)
    shutil.copytree(base / "profile/.tools/linux-x86_64/lean",
                    snap / ".tools/linux-x86_64/lean", symlinks=True,
                    copy_function=shutil.copy2)
    assert subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=snap, text=True).strip() == commit
    return snap


def tests(snap, label, pattern):
    out = base / label
    out.mkdir()
    command = ["python3", "scripts/dev.py", "test", "--jobs", "2", "--task", "#246",
               "--", "-p", pattern]
    (out / "command.json").write_text(json.dumps({"command": command, "cwd": str(snap)}, indent=2) + "\n")
    event(label + "-started", command=command, worktree=str(snap), output=str(out / "output.log"))
    started = time.monotonic()
    with (out / "output.log").open("w") as log:
        result = subprocess.run(command, cwd=snap, stdout=log, stderr=subprocess.STDOUT)
    text = (out / "output.log").read_text()
    run_id = re.search(r"Managed run: (\S+)", text)
    skipped = bool(re.search(r"\.\.\.\s+skipped\b|\bOK\s*\(skipped=", text))
    summary = {"exit_code": result.returncode, "wall_seconds": time.monotonic() - started,
               "run_id": run_id[1] if run_id else None, "skipped": skipped,
               "test_totals": re.findall(r"Ran \d+ tests? in [^\n]+", text)}
    (out / "result.json").write_text(json.dumps(summary, indent=2) + "\n")
    event(label + "-finished", **summary)
    assert result.returncode == 0 and not skipped and run_id, f"{label} failed/skipped; retained {out}"


def closure(snap, after):
    imports = {str(p.relative_to(snap / "proof"))[:-5].replace("/", "."):
               set(re.findall(r"^(?:(?:public|meta)\s+)*import\s+(?:all\s+)?(\S+)",
                              p.read_text(), re.MULTILINE))
               for p in (snap / "proof").rglob("*.lean")
               if ".lake" not in p.parts and p.name != "lakefile.lean"}
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
    removed = {}
    workspace = snap / ".silver/linux-x86_64/proof"
    for name in sorted(modules):
        relative = Path(name.replace(".", "/"))
        for folder in ["lib/lean", "ir"]:
            for artifact in (workspace / ".lake/build" / folder / relative.parent).glob(relative.name + ".*"):
                assert artifact.is_file() and not artifact.is_symlink()
                removed[str(artifact.relative_to(workspace))] = {
                    "sha256": hashlib.sha256(artifact.read_bytes()).hexdigest(),
                    "bytes": artifact.stat().st_size, "mtime_ns": artifact.stat().st_mtime_ns}
                artifact.unlink()
    record = {"commit": reviewed if after else baseline, "roots": sorted(roots),
              "closure": sorted(modules), "removed_artifacts": removed,
              "seed": str(seed), "seed_complete_run": "20261026T131016-6b27137135dc"}
    (base / ("after-invalidation.json" if after else "before-invalidation.json")).write_text(json.dumps(record, indent=2) + "\n")
    return modules


def complete(snap, label, expected=None):
    command = ["python3", str(base / "measure.py"), label, "--snapshot", str(snap), "--workers", "2"]
    event(label + "-started", command=command, worktree=str(snap))
    with (base / f"launcher-{label}.log").open("w") as log:
        result = subprocess.run(command, cwd=root, stdout=log, stderr=subprocess.STDOUT)
    out = base / label
    assert result.returncode == 0, f"{label} failed; retained {out}"
    evidence = json.loads((out / "lean-evidence.json").read_text())
    measured = json.loads((out / "result.json").read_text())
    assert evidence["scope"] == "complete" and evidence["axiom_audit"] == "passed"
    assert measured["exit_code"] == 0 and measured["cutoff_reason"] is None
    text = (out / "lean-proof.log").read_text()
    built = set(re.findall(r"\bBuilt (Silver(?:\.[A-Za-z_][A-Za-z0-9_]*)*)\b", text))
    before = json.loads((out / "artifacts-before.json").read_text())
    after = json.loads((out / "artifacts-after.json").read_text())
    objects = {path[len(".lake/build/lib/lean/"):-len(".olean")].replace("/", ".")
               for path, item in after.items() if path.startswith(".lake/build/lib/lean/")
               and path.endswith(".olean") and (path not in before or before[path] != item)}
    summary = {"commit": reviewed if label != "before" else baseline,
               "run_id": evidence["run_id"], "scope": evidence["scope"],
               "elapsed_seconds": evidence["elapsed_seconds"], "phases": evidence["phases"],
               "module_count": len(evidence["modules"]), "axiom_audit": evidence["axiom_audit"],
               "kernel_recheck": evidence["kernel_recheck"], "launcher_result": measured,
               "built_modules_from_log": sorted(built), "changed_or_created_olean_modules": sorted(objects),
               "expected_rebuild_closure": sorted(expected) if expected is not None else None}
    (out / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    if expected is not None:
        assert built == objects == expected, f"{label} rebuilt set mismatch; inspect {out}/summary.json"
    event(label + "-finished", run_id=evidence["run_id"], elapsed_seconds=evidence["elapsed_seconds"],
          rebuilt_count=len(built), summary=str(out / "summary.json"))


try:
    event("waiting-for-profiles", profile_sequence_pid=sequence_pid, reviewed_commit=reviewed,
          baseline_commit=baseline, original_seed=str(seed))
    while not all((base / case / "summary.json").exists() for case in ["profile-output", "profile-predicate"]):
        for case in ["profile-output", "profile-predicate"]:
            result = base / case / "result.json"
            if result.exists():
                assert json.loads(result.read_text())["exit_code"] == 0, f"{case} failed"
        os.kill(sequence_pid, 0)
        time.sleep(5)
    event("profiles-complete-begin-correctness")
    correctness = snapshot("correctness-worktree", reviewed)
    tests(correctness, "tests-lean", "test_lean*.py")
    tests(correctness, "tests-platforms", "test_platforms.py")
    complete(correctness, "correctness")
    before = snapshot("before-worktree", baseline)
    before_modules = closure(before, False)
    complete(before, "before", before_modules)
    after = snapshot("after-worktree", reviewed)
    after_modules = closure(after, True)
    assert after_modules == before_modules | {"Silver.ComposeSourceCandidate"}
    complete(after, "after", after_modules)
    event("all-authorized-cases-complete", remaining="Lead integration/review and no-build invalidation controls")
except BaseException as error:
    event("stopped-on-failure", error=repr(error), next_step="Lead diagnosis; preserve all evidence; no automatic retry")
    raise
