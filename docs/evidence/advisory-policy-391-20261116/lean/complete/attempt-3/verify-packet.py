"""Inspect the completed run without launching Lean or changing proof inputs."""

import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess


root = Path(__file__).resolve().parents[6]
packet = Path(__file__).resolve().parent
expected_commit = "d60bd8a899fcc66e5ef40112423b7f94b2e4becc"
run_id = "20261116T233445-6dce1a7dbb80"
manifest_path = root / ".silver/linux-aarch64/lean-evidence.json"
manifest = json.loads(manifest_path.read_text())
assert manifest["run_id"] == run_id
assert manifest["scope"] == "complete" and manifest["axiom_audit"] == "passed"
assert not manifest["clean_build"] and manifest["kernel_recheck"] is None
workspace = root / manifest["workspace"]


def digest(path):
    return hashlib.file_digest(path.open("rb"), "sha256").hexdigest()


counts = {}
for key, base in [("inputs_sha256", root), ("workspace_inputs_sha256", workspace),
                  ("tools_sha256", root), ("artifacts_sha256", workspace)]:
    for relative, expected in manifest[key].items():
        assert digest(base / relative) == expected, (key, relative)
    counts[key] = len(manifest[key])
assert digest(root / manifest["log"]) == manifest["log_sha256"]
assert hashlib.sha256(json.dumps(manifest["inputs_sha256"], sort_keys=True).encode()).hexdigest() == manifest["inputs_digest_sha256"]

# Check the exact frozen Git blobs in a single read-only batch.
paths = list(manifest["inputs_sha256"])
batch = subprocess.run(["git", "cat-file", "--batch"], cwd=root, check=True,
                       input="".join(f"{expected_commit}:{p}\n" for p in paths).encode(),
                       capture_output=True).stdout
offset = 0
for relative in paths:
    end = batch.index(b"\n", offset)
    header = batch[offset:end].split()
    assert header[1] == b"blob", relative
    size = int(header[2])
    contents = batch[end + 1:end + 1 + size]
    assert hashlib.sha256(contents).hexdigest() == manifest["inputs_sha256"][relative], relative
    offset = end + size + 2
assert offset == len(batch)

project_modules = {".".join(p.relative_to(root / "proof").with_suffix("").parts)
                   for p in (root / "proof").rglob("*.lean")
                   if ".lake" not in p.parts and p.name != "lakefile.lean"}
workspace_modules = {".".join(p.relative_to(workspace).with_suffix("").parts)
                     for p in workspace.rglob("*.lean")
                     if ".lake" not in p.parts and p.name != "lakefile.lean"}
log = (root / manifest["log"]).read_text()
audit_log = log.split("Lean phase audit started at ", 1)[1]
actual_modules = set(re.findall(r"^SILVER_MODULE ([A-Za-z0-9_.]+)$", audit_log, re.M))
assert set(manifest["modules"]) == project_modules == workspace_modules == actual_modules
assert len(actual_modules) == 1009
audit = re.search(r"^Silver axiom audit passed: (\d+) declarations; foundations: (.+)$", audit_log, re.M)
assert audit and audit.group(2) == "[propext, Classical.choice, Quot.sound]"
assert int(audit.group(1)) == 162274
diagnostics = re.findall(r"^.*(?:warning:|error:).*$", log, re.M)
assert not diagnostics, diagnostics

# Enumerate the declared generated witnesses and independently bound sources.
runner = (root / "scripts/check_lean.py").read_text()
roots_text = runner.split("CERTIFICATE_ROOTS = {", 1)[1].split("OUTPUT_BODY_LINES =", 1)[0]
certificate_pairs = re.findall(r'Path\("([^"]+)"\): "([^"]+)"', roots_text)
candidates = {p for p, _ in certificate_pairs} | {f"Silver/OutputBodyLines{i}.lean" for i in range(8)}
embedded = sorted({source for _, source in certificate_pairs})
assert len(candidates) == 40 and len(embedded) == 32
for relative in candidates:
    assert relative in manifest["workspace_inputs_sha256"]
    assert ".".join(Path(relative).with_suffix("").parts) in actual_modules
source_bindings = []
for relative in manifest["workspace_inputs_sha256"]:
    if not relative.endswith(".lean"):
        continue
    for source in re.findall(r'include_str "../../src/([^"]+)"', (workspace / relative).read_text()):
        if source in embedded:
            source_bindings.append({"module": relative, "source": source,
                                    "sha256": digest(root / "src" / source)})
assert {binding["source"] for binding in source_bindings} == set(embedded)
assert (root / ".silver/linux-aarch64/src").resolve() == (root / "src").resolve()
preflight = json.loads((packet / "preflight.json").read_text())
assert sorted(preflight["embedded_sources"]) == embedded
assert preflight["all_embedded_source_bytes_unchanged_since_prior_complete"]

old = preflight["preexisting_primary_objects_sha256"]
missing = [p for p in old if not (root / p).is_file()]
changed = [p for p, expected in old.items() if (root / p).is_file() and digest(root / p) != expected]
primary = {str(p.relative_to(root)): digest(p) for p in (workspace / ".lake/build/lib/lean").rglob("*.olean")}
assert not missing
assert len(primary) == 1009
samples = [json.loads(line) for line in (packet / "resources.jsonl").read_text().splitlines()]
launcher = json.loads((packet / "launcher.json").read_text())
assert launcher["returncode"] == 0 and launcher["guard_trigger"] is None
try:
    os.killpg(launcher["runner_pgid"], 0)
except ProcessLookupError:
    process_group_released = True
else:
    raise AssertionError("Original runner process group is still present")
status = json.loads(subprocess.run(["python3", "scripts/dev.py", "runs", "status", "--task", "#391"],
                                   cwd=root, capture_output=True, text=True, check=True).stdout)
managed = next(run for run in status["runs"] if run["run_id"] == run_id)
assert managed["state"] == "success" and not managed["active"]
assert not any(run["active"] for run in status["runs"] if run["kind"] == "lean")
run_dir = Path(managed["directory"])
for source, destination in [(manifest_path, packet / "lean-evidence.json"),
                            (root / manifest["log"], packet / "lean-proof.log"),
                            (run_dir / "events.jsonl", packet / "events.jsonl")]:
    shutil.copyfile(source, destination)
(packet / "managed-summary.json").write_text(json.dumps(managed, indent=2) + "\n")
summary = {
    "verified_at_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "run_id": run_id, "implementation_commit": expected_commit,
    "all_captured_inputs_match_commit": True, "verified_manifest_counts": counts,
    "log_sha256": manifest["log_sha256"], "inputs_digest_sha256": manifest["inputs_digest_sha256"],
    "actual_project_manifest_workspace_module_count": len(actual_modules),
    "module_sets_equal": True, "declarations": int(audit.group(1)),
    "foundations": ["propext", "Classical.choice", "Quot.sound"],
    "generated_candidate_count": len(candidates), "generated_candidates": sorted(candidates),
    "embedded_source_count": len(embedded), "authoritative_source_bindings": source_bindings,
    "authoritative_source_link_correct": True, "diagnostics": diagnostics,
    "original_tool_session_id": 85539, "original_terminal_exit": 0,
    "original_terminal_collected": True, "process_group_released": process_group_released,
    "managed_state": managed["state"], "managed_active": managed["active"],
    "no_active_lean_run": True, "workers": manifest["lake_workers"],
    "threads_per_process": manifest["threads_per_process"],
    "memory_mb_per_process": manifest["memory_mb_per_process"],
    "guard_trigger": launcher["guard_trigger"], "resource_sample_count": len(samples),
    "peak_tree_rss_gib": max(s["tree_rss_kib"] for s in samples) / 1024**2,
    "minimum_host_available_gib": min(s["host_available_kib"] for s in samples) / 1024**2,
    "supervised_elapsed_seconds": launcher["elapsed_seconds"],
    "build_elapsed_seconds": manifest["phases"][0]["elapsed_seconds"],
    "audit_elapsed_seconds": manifest["phases"][1]["elapsed_seconds"],
    "successful_logged_silver_builds": len(re.findall(r"^.*Built Silver(?:[. ]|$).*$", log, re.M)),
    "preexisting_primary_object_count": len(old), "missing_preexisting_primary_objects": missing,
    "unchanged_preexisting_primary_object_count": len(old) - len(changed),
    "changed_preexisting_primary_objects": changed, "current_primary_object_count": len(primary),
    "new_primary_objects": sorted(set(primary) - set(old)),
}
(packet / "verification-summary.json").write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps({k: v for k, v in summary.items() if not isinstance(v, list)}, indent=2))
