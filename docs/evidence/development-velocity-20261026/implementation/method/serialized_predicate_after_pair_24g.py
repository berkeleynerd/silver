#!/usr/bin/env python3
"""One serialized predicate diagnostic, strictly after successful timed cases."""
import datetime
import fcntl
import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import time

base = Path(__file__).resolve().parent
root = base.parent.parent
commit = "e94c8b4343f429c434900cc2a23e29e870f577bf"
snapshot = base / "serialized-predicate-worktree"
case = base / "profile-predicate-serialized"
raw = base / "predicate-serialized-profile.json"
lock = (base / "serialized-24g-continuation.lock").open("a+b")
fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def event(stage, **details):
    row = {"at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
           "stage": stage, "pid": os.getpid(), **details}
    with (base / "serialized-24g-continuation.jsonl").open("a") as stream:
        stream.write(json.dumps(row) + "\n")
    print(json.dumps(row), flush=True)


try:
    event("waiting-for-revised-24g-matched-pair-success", order="AFTER then BEFORE",
          commit=commit, diagnostic="Elab.async=false on PredicateSourceCandidate only")
    while True:
        journal_path = base / "pair-24g.jsonl"
        journal = [json.loads(line) for line in journal_path.read_text().splitlines()] if journal_path.exists() else []
        if any(row["stage"] == "stopped-on-failure" for row in journal):
            raise RuntimeError("Revised matched pair failed; diagnostic remains unlaunched")
        if journal and journal[-1]["stage"] == "matched-pair-complete":
            break
        time.sleep(5)
    for label in ["after-24g", "before-24g"]:
        result = json.loads((base / label / "result.json").read_text())
        evidence = json.loads((base / label / "lean-evidence.json").read_text())
        assert result["exit_code"] == 0 and result["cutoff_reason"] is None
        assert evidence["scope"] == "complete" and evidence["axiom_audit"] == "passed"
        assert evidence["memory_mb_per_process"] == 24576
    assert not snapshot.exists() and not case.exists() and not raw.exists()
    event("preparing-independent-serialized-diagnostic", worktree=str(snapshot))
    with (base / "setup-serialized-predicate.log").open("w") as log:
        subprocess.run(["git", "worktree", "add", "--detach", str(snapshot), commit], cwd=root,
                       stdout=log, stderr=subprocess.STDOUT, check=True)
    shutil.copytree(base / "warm-proof", snapshot / ".silver/linux-x86_64/proof",
                    symlinks=True, copy_function=shutil.copy2)
    shutil.copytree(base / "profile/.tools/linux-x86_64/lean", snapshot / ".tools/linux-x86_64/lean",
                    symlinks=True, copy_function=shutil.copy2)
    original_inputs = json.loads((base / "baseline-inputs.json").read_text())
    for relative, identity in original_inputs.items():
        assert sha(snapshot / relative) == identity["sha256"], relative
    normal = json.loads((base / "profile-predicate/lean-focused-evidence.json").read_text())
    for relative, expected in normal["tools_sha256"].items():
        assert sha(snapshot / relative) == expected, relative
    flags = ["--profile", "-Dprofiler.threshold=100", "-Dtrace.profiler=true",
             "-Dtrace.profiler.threshold=1000000000", "-Dtrace.Kernel=true",
             "-Dtrace.Elab.definition.header=true", "-Dtrace.Elab.definition.value=true",
             "-Dtrace.Elab.async=true", "-Dtrace.profiler.output.pp=true",
             f"-Dtrace.profiler.output={raw}", "-DElab.async=false"]
    snippet = ("\nlean_lib ProfiledSerializedPredicateSourceCandidate where\n"
               "  roots := #[]\n  globs := #[.one `Silver.PredicateSourceCandidate]\n"
               "  weakLeanArgs := #[" + ", ".join(json.dumps(flag) for flag in flags) + "]\n")
    with (snapshot / "proof/lakefile.lean").open("a") as stream:
        stream.write(snippet)
    (base / "serialized-instrumentation-lakefile.txt").write_text(snippet)
    workspace = snapshot / ".silver/linux-x86_64/proof"
    removed = []
    for folder in ["lib/lean", "ir"]:
        for artifact in (workspace / ".lake/build" / folder / "Silver").glob("PredicateSourceCandidate.*"):
            assert artifact.is_file() and not artifact.is_symlink()
            removed.append({"path": str(artifact.relative_to(workspace)), "sha256": sha(artifact)})
            artifact.unlink()
    inputs = {"commit": commit, "matched_baseline_input_files": len(original_inputs),
              "predicate_source_sha256": sha(snapshot / "proof/Silver/PredicateSourceCandidate.lean"),
              "tools_sha256": normal["tools_sha256"], "baseline_input_record_sha256": sha(base / "baseline-inputs.json"),
              "normal_async_run_id": normal["run_id"], "normal_async_raw_sha256": sha(base / "predicate-profile.json"),
              "preserved_invalid_async_summary_sha256": sha(base / "profile-predicate/invalid-attribution.json"),
              "normal_async_attribution_diagnosis_sha256": sha(base / "profile-predicate/attribution-diagnosis.json"),
              "instrumented_lakefile_sha256": sha(snapshot / "proof/lakefile.lean"),
              "exact_module_additional_args": flags, "removed_artifacts": removed,
              "purpose": "Serialized diagnostic ranking only; no normal-async service-cost or performance claim"}
    (base / "serialized-inputs.json").write_text(json.dumps(inputs, indent=2) + "\n")
    command = ["python3", str(base / "measure.py"), case.name, "--snapshot", str(snapshot),
               "--target", "Silver.PredicateSourceCandidate", "--workers", "1"]
    event("serialized-profile-started", command=command, worktree=str(snapshot), output=str(case / "output.log"))
    with (base / "launcher-predicate-serialized.log").open("w") as log:
        subprocess.run(command, cwd=root, stdout=log, stderr=subprocess.STDOUT, check=True)
    result = json.loads((case / "result.json").read_text())
    evidence = json.loads((case / "lean-focused-evidence.json").read_text())
    assert result["exit_code"] == 0 and result["cutoff_reason"] is None
    assert evidence["scope"] == "focused" and evidence["axiom_audit"] == "passed"
    ranked = case / "ranked.json"
    subprocess.run(["python3", str(base / "analyze_profile.py"), str(workspace / "Silver/PredicateSourceCandidate.lean"),
                    "--profile", str(raw), "--rss", str(case / "rss.jsonl"), "--rss-command", "PredicateSourceCandidate.lean",
                    "--out", str(ranked)], check=True)
    validation = case / "interval-validation.json"
    subprocess.run(["python3", str(base / "verify_serialized_profile.py"), str(raw),
                    "--ranked", str(ranked), "--out", str(validation)], check=True)
    processes = {}
    with (case / "rss.jsonl").open() as samples:
        for line in samples:
            row = json.loads(line)
            for process in row["processes"]:
                command = process["cmd"]
                words = command.split()
                if not words or Path(words[0]).name != "lean" or "PredicateSourceCandidate.lean" not in command:
                    continue
                assert "-DElab.async=false" in command
                cpu = process["user_seconds"] + process["system_seconds"]
                item = processes.setdefault(str(process["pid"]), {"command": command, "first_cpu_seconds": cpu,
                                            "first_monotonic_ns": row["monotonic_ns"], "sample_count": 0,
                                            "peak_sampled_rss_kib": 0, "peak_sampled_hwm_kib": 0})
                item.update({"last_cpu_seconds": cpu, "last_monotonic_ns": row["monotonic_ns"],
                             "sample_count": item["sample_count"] + 1,
                             "peak_sampled_rss_kib": max(item["peak_sampled_rss_kib"], process["rss_kib"]),
                             "peak_sampled_hwm_kib": max(item["peak_sampled_hwm_kib"], process["hwm_kib"])})
    assert len(processes) == 1
    for item in processes.values():
        item["sampled_cpu_seconds_increase"] = item["last_cpu_seconds"] - item["first_cpu_seconds"]
        item["sample_window_seconds"] = (item["last_monotonic_ns"] - item["first_monotonic_ns"]) / 1e9
    archive = raw.with_suffix(".json.gz")
    with raw.open("rb") as source, archive.open("wb") as target:
        with gzip.GzipFile(filename="", fileobj=target, mode="wb", mtime=0) as zipped:
            shutil.copyfileobj(source, zipped)
    analysis = json.loads(ranked.read_text())
    summary = {key: analysis[key] for key in ["thread_weight_ms", "sample_phase_ms", "coverage", "categories",
                                              "observed_process_peak_rss_bytes", "rss_sample_count", "rss_pids"]}
    summary.update({"status": "validated serialized diagnostic; normal-async per-declaration costs remain inconclusive",
                    "timing_baseline": False, "production_setting_adopted": False, "commit": commit,
                    "run_id": evidence["run_id"], "managed_evidence": evidence, "launcher_result": result,
                    "interval_validation": json.loads(validation.read_text()), "sampled_module_processes": processes,
                    "declaration_count": len(analysis["ranked_declarations"]),
                    "top_declarations": analysis["ranked_declarations"][:25],
                    "raw_profile_sha256": sha(raw), "raw_archive_sha256": sha(archive),
                    "raw_profile_bytes": raw.stat().st_size, "raw_archive_bytes": archive.stat().st_size,
                    "notes": ["Exclusive traced elapsed costs apply only to this serialized diagnostic.",
                              "OS scheduling and GC remain inside elapsed scopes; these are not OS CPU costs.",
                              "Sampled process CPU/RSS can miss endpoints; focused auditing is separate from complete final auditing.",
                              "Normal-async module observations remain in profile-predicate/summary.json; its old ranking is invalid history."]})
    (case / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    event("serialized-diagnostic-complete", run_id=evidence["run_id"], summary=str(case / "summary.json"))
except BaseException as error:
    event("stopped-on-failure", error=repr(error), next_step="Lead diagnosis; retain evidence; no automatic retry")
    raise
