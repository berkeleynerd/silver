#!/usr/bin/env python3
"""Scratch #246 Lake freshness controls; run only after measured AFTER succeeds."""
import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time


@contextmanager
def changed(path, contents, *, retain_timestamp=False):
    original, metadata = path.read_bytes(), path.stat()
    try:
        path.write_bytes(contents)
        if retain_timestamp:
            os.utime(path, ns=(metadata.st_atime_ns, metadata.st_mtime_ns))
        yield
    finally:
        path.write_bytes(original)
        os.utime(path, ns=(metadata.st_atime_ns, metadata.st_mtime_ns))
        assert path.read_bytes() == original
        assert path.stat().st_mtime_ns == metadata.st_mtime_ns


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    root = Path(__file__).resolve().parents[2]
    parser.add_argument("--measurement", type=Path, default=root / "tmp/velocity-246-measure")
    parser.add_argument("--out", required=True, type=Path, help="new scratch/evidence directory")
    args = parser.parse_args()
    measurement, out = args.measurement.resolve(), args.out.resolve()
    plan = json.loads((measurement / "continuation-plan.json").read_text())
    summary = json.loads((measurement / "after-24g/summary.json").read_text())
    assert summary["commit"] == plan["reviewed_commit"]
    assert summary["scope"] == "complete" and summary["axiom_audit"] == "passed"
    assert summary["launcher_result"]["exit_code"] == 0
    assert summary["launcher_result"]["cutoff_reason"] is None
    after = measurement / "after-24g-worktree"
    assert subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=after, text=True).strip() == plan["reviewed_commit"]
    # A normal-byte control starts from the committed Ada and reviewed pin,
    # never from a retained experiment mutation.
    for relative in ("src/silver_output_profile.adb", "proof/Silver/ReviewedOutputShape.lean"):
        expected = subprocess.check_output(["git", "show", f"{plan['reviewed_commit']}:{relative}"], cwd=after)
        assert (after / relative).read_bytes() == expected, relative
    assert not out.exists(), f"Refusing to reuse {out}"
    out.mkdir(parents=True)
    scratch = out / "snapshot"
    scratch.mkdir()
    sys.path.insert(0, str(after))
    from scripts.bootstrap_lean import lean_environment
    from scripts.check_lean import write_changed
    from scripts.platforms import HostLayout, host_key
    host = HostLayout(scratch, host_key())
    host.artifacts.mkdir(parents=True)
    # --reflink=auto never hardlinks regular files to the measured snapshot.
    for source, destination in ((after / "src", scratch / "src"),
                                (after / "proof", scratch / "proof"),
                                (after / ".silver" / host.key / "proof", host.proof)):
        subprocess.run(["cp", "-a", "--reflink=auto", str(source), str(destination)], check=True)
    (host.artifacts / "src").symlink_to("../../src", target_is_directory=True)
    assert (host.artifacts / "src").resolve() == scratch / "src"
    host.lean.parent.mkdir(parents=True)
    host.lean.symlink_to(after / ".tools" / host.key / "lean", target_is_directory=True)
    environment = {**lean_environment(host), "LEAN_NUM_THREADS": "2"}
    command = [str(host.lean / "bin/lake"), "--rehash", "--reconfigure", "--no-build",
               "-K", "silverThreads=2", "-K", "silverMemoryMb=24576", "build"]
    probes = []

    def probe(label, target, expected_code, frontier=None):
        invocation = command + ["+" + target]
        started = time.monotonic()
        completed = subprocess.run(invocation, cwd=host.proof, env=environment,
                                   text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                   timeout=60)
        (out / (label + ".log")).write_text(completed.stdout)
        probes.append({"label": label, "command": invocation, "cwd": str(host.proof),
                       "exit_code": completed.returncode, "expected_exit_code": expected_code,
                       "seconds": time.monotonic() - started, "expected_frontier": frontier})
        print(json.dumps(probes[-1]), flush=True)
        assert completed.returncode == expected_code, completed.stdout
        if frontier:
            assert frontier in completed.stdout and "out-of-date" in completed.stdout, completed.stdout

    modules = ("ComposeSourceCandidate", "ComposeSourceChecks", "ReviewedOutputShape",
               "OutputProfileBodySource", "OutputBodyCertificate")

    def objects():
        inventory = {}
        for module in modules:
            for suffix in (".olean", ".olean.server", ".olean.private"):
                path = host.proof / ".lake/build/lib/lean/Silver" / (module + suffix)
                inventory[str(path.relative_to(host.proof))] = {
                    "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                    "mtime_ns": path.stat().st_mtime_ns}
        return inventory

    before = objects()
    (out / "objects-before.json").write_text(json.dumps(before, indent=2) + "\n")
    result = {"scope": "Lake --no-build freshness controls; no proof build or audit",
              "after_commit": plan["reviewed_commit"], "after_run_id": summary["run_id"],
              "source_snapshot": str(after), "scratch": str(scratch), "probes": probes,
              "passed": False,
              "frontier_semantics": "Exit 3 identifies a stale dependency frontier, not all stale targets."}
    ada = scratch / "src/silver_output_profile.adb"
    shared_pin = scratch / "proof/Silver/ReviewedOutputShape.lean"
    workspace_pin = host.proof / "Silver/ReviewedOutputShape.lean"
    original_ada, original_pin = ada.read_bytes(), shared_pin.read_bytes()
    assert workspace_pin.read_bytes() == original_pin
    try:
        probe("normal-candidate", "Silver.ComposeSourceCandidate", 0)
        probe("normal-authoritative", "Silver.ComposeSourceChecks", 0)
        with changed(ada, original_ada + b"\n-- #246 comment-only no-build invalidation control\n", retain_timestamp=True):
            probe("comment-candidate", "Silver.ComposeSourceCandidate", 0)
            probe("comment-authoritative", "Silver.ComposeSourceChecks", 3, "Silver.OutputProfileBodySource")
        probe("restored-authoritative", "Silver.ComposeSourceChecks", 0)
        marker = b'def outputImplementation : List String :=\n  ["with", "silver_profile",'
        assert original_pin.count(marker) == 1
        edited_pin = original_pin.replace(marker, marker.replace(b'"silver_profile"', b'"silver_profile_control"'), 1)
        # Match the runner's shared-input -> private-proof synchronization.
        # The source link above already supplies authoritative Ada edits.
        with changed(shared_pin, edited_pin), changed(workspace_pin, original_pin):
            write_changed(workspace_pin, shared_pin.read_bytes())
            probe("reviewed-pin-candidate", "Silver.ComposeSourceCandidate", 3, "Silver.ReviewedOutputShape")
        probe("restored-candidate", "Silver.ComposeSourceCandidate", 0)
        probe("restored-final-authoritative", "Silver.ComposeSourceChecks", 0)
        result["passed"] = True
    except BaseException as error:
        result["error"] = repr(error)
        raise
    finally:
        after_objects = objects()
        result["objects_unchanged"] = before == after_objects
        result["normal_bytes_restored"] = (ada.read_bytes() == original_ada and
                                             shared_pin.read_bytes() == workspace_pin.read_bytes() == original_pin)
        result["passed"] = result["passed"] and result["objects_unchanged"] and result["normal_bytes_restored"]
        (out / "objects-after.json").write_text(json.dumps(after_objects, indent=2) + "\n")
        (out / "result.json").write_text(json.dumps(result, indent=2) + "\n")
        assert result["objects_unchanged"] and result["normal_bytes_restored"]


if __name__ == "__main__":
    main()
