#!/usr/bin/env python3
"""Finish the two authorized, sequential scratch profiles; stop on any failure."""
import datetime
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import time

base = Path(__file__).resolve().parent
snap = base / "profile"
workspace = snap / ".silver/linux-x86_64/proof"


def event(text):
    row = {"at": datetime.datetime.now(datetime.timezone.utc).isoformat(), "event": text}
    with (base / "sequence.jsonl").open("a") as f:
        f.write(json.dumps(row) + "\n")
    print(json.dumps(row), flush=True)


def collect(case, module, filename):
    out = base / case
    while not (out / "lean-focused-evidence.json").exists() or not (out / "artifacts-after.json").exists():
        if (out / "result.json").exists() and json.loads((out / "result.json").read_text())["exit_code"]:
            raise RuntimeError(f"{case} failed; retained evidence in {out}")
        time.sleep(2)
    result = json.loads((out / "result.json").read_text())
    assert result["exit_code"] == 0 and result["cutoff_reason"] is None, result
    raw = base / filename
    ranked = out / "ranked.json"
    subprocess.run(["python3", str(base / "analyze_profile.py"), str(workspace / f"Silver/{module}.lean"),
                    "--profile", str(raw), "--rss", str(out / "rss.jsonl"),
                    "--rss-command", f"{module}.lean", "--out", str(ranked)], check=True)
    profile = json.loads(ranked.read_text())
    total = sum(profile["thread_weight_ms"].values())
    coverage = profile["coverage"]
    assert coverage.get("negative_weight_samples", 0) == 0
    assert abs(total - coverage.get("assigned_ms", 0) - coverage.get("unassigned_ms", 0)) < 0.01
    assert abs(sum(x.get("owned_ms", 0) for x in profile["ranked_declarations"]) - coverage["assigned_ms"]) < 0.01
    assert abs(sum(profile["sample_phase_ms"].values()) - total) < 0.01
    archive = raw.with_suffix(raw.suffix + ".gz")
    with raw.open("rb") as source, archive.open("wb") as target:
        with gzip.GzipFile(filename="", fileobj=target, mode="wb", mtime=0) as zipped:
            while block := source.read(1024 * 1024):
                zipped.write(block)
    declarations = profile["ranked_declarations"]
    summary = {k: profile[k] for k in ["thread_weight_ms", "sample_phase_ms", "coverage", "categories",
                                      "observed_process_peak_rss_bytes", "rss_sample_count", "rss_pids", "notes"]}
    summary.update({"module": "Silver." + module, "declaration_count": len(declarations),
                    "timing_baseline": False, "launcher_result": result,
                    "managed_evidence": json.loads((out / "lean-focused-evidence.json").read_text()),
                    "raw_profile_sha256": hashlib.sha256(raw.read_bytes()).hexdigest(),
                    "raw_archive_sha256": hashlib.sha256(archive.read_bytes()).hexdigest(),
                    "raw_profile_bytes": raw.stat().st_size, "raw_archive_bytes": archive.stat().st_size,
                    "top_declarations": declarations[:25],
                    "slowest_lines": [x for x in declarations if x["category"] == "line_certificate"][:20],
                    "slowest_joins": [x for x in declarations if x["category"] == "reconstruction_join"][:20],
                    "final_tail": [x for x in declarations if x["category"] not in
                                   {"line_certificate", "reconstruction_single", "reconstruction_join", "other"}]})
    (out / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    event(f"{case} complete; run {summary['managed_evidence']['run_id']}; analysis and bounded summary retained")


event("Waiting for existing OutputBodyCertificate managed profile")
collect("profile-output", "OutputBodyCertificate", "output-body-profile.json")
removed = []
for folder in ["lib/lean", "ir"]:
    for p in (workspace / ".lake/build" / folder / "Silver").glob("PredicateSourceCandidate.*"):
        assert p.is_file() and not p.is_symlink()
        removed.append(str(p.relative_to(workspace)))
        p.unlink()
(base / "profile-predicate-invalidation.json").write_text(json.dumps({
    "root": "Silver.PredicateSourceCandidate", "removed_artifacts": removed}, indent=2) + "\n")
event("Starting PredicateSourceCandidate sequential profile; 1 worker/2 threads/16384 MiB")
subprocess.run(["python3", str(base / "measure.py"), "profile-predicate", "--snapshot", str(snap),
                "--target", "Silver.PredicateSourceCandidate", "--workers", "1"], check=True)
collect("profile-predicate", "PredicateSourceCandidate", "predicate-profile.json")
event("Both profiles complete; report summaries to lead before unprofiled BEFORE or focused correctness work")
