#!/usr/bin/env python3
"""Receiver-side read-only byte checks for PR403's recovered ARM evidence.

Streams the cache archive, resolves archive hardlinks without extracting them,
and never loads a Lean object or executes any recovered program/script.
"""
import collections
from compression import zstd
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import sys
import tarfile
import time

sys.dont_write_bytecode = True
OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[1]
TARGET = ROOT / "tmp/pr403-delivery"
RECOVERY = ROOT / "tmp/silver-pr403-recovery-20261120"
RECORDS = OUT / "recovered-records"
BASE = TARGET / "docs/evidence/named-scalar-arguments-392-20261117"
sys.path.insert(0, str(TARGET / "scripts"))
import check_lean


def sha(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def data_sha(data):
    return hashlib.sha256(data).hexdigest()


def read_json(path):
    return json.loads(path.read_bytes())


def write_json(name, value):
    (OUT / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


started = time.monotonic()
native = read_json(BASE / "complete-native/proof-provenance.json")
lean = read_json(BASE / "complete-lean/final-run/evidence.json")
previous = read_json(OUT / "assurance-applicability-results.json")
archive_hashes = {}
for line in (RECOVERY / "SHA256SUMS").read_text().splitlines():
    expected, name = line.split()
    assert Path(name).name == name
    actual = sha(RECOVERY / name)
    assert actual == expected, name
    archive_hashes[name] = {"sha256": actual, "bytes": (RECOVERY / name).stat().st_size}

path_map = read_json(RECORDS / "native-392/supporting-input-path-map.json")
support_root = RECORDS / "native-392/supporting-inputs"
expected_support = {k: v for k, v in native["inputs_sha256"].items() if k.startswith(".")}
assert path_map.keys() == expected_support.keys()
assert {str(p.relative_to(support_root)) for p in support_root.rglob("*") if p.is_file()} == expected_support.keys()
original_root = Path(read_json(BASE / "complete-native/audit-verification.json")["worktree"])
native_local = {}
for name, expected in native["inputs_sha256"].items():
    if name in path_map:
        mapping = path_map[name]
        assert mapping["recorded_path"] == str(original_root / name)
        assert mapping["export_path"] == "supporting-inputs/" + name
        selected = support_root / name
        if name.startswith(".silver/linux-aarch64/"):
            assert mapping["ext4_path"] == "/volumes/silver-recovery-370-20261115/_data/named-392-native-artifacts/" + name.removeprefix(".silver/linux-aarch64/")
    else:
        selected = TARGET / name
    actual = sha(selected)
    assert actual == expected, name
    native_local[name] = actual

comparison = read_json(RECORDS / "native-392/hash-comparison.json")
native_observations = comparison["inputs_with_readonly_bind_recovery"]
assert native_observations["counts"] == {"matching": 2622}
assert len(native_observations["entries"]) == len(native_local)
assert {e["path"]: e["actual"] for e in native_observations["entries"]} == native_local
assert all(e["status"] == "matching" and e["expected"] == e["actual"] for e in native_observations["entries"])
tools = {v["path"]: v["sha256"] for v in native["tools"].values()}
tool_observations = comparison["tools_with_readonly_image_recovery"]
assert tool_observations["counts"] == {"matching": 12}
observed_tools = {}
for entry in tool_observations["entries"]:
    path = entry.get("path", entry.get("recorded_path"))
    expected = entry.get("expected", entry.get("expected_sha256"))
    actual = entry.get("actual", entry.get("actual_sha256"))
    assert expected == actual == tools[path] and entry["status"] == "matching"
    observed_tools[path] = actual
assert observed_tools == tools
python_record = read_json(RECORDS / "arm-python.json")
python_file = RECORDS / python_record["export_path"]
assert sha(python_file) == native["tools"]["python"]["sha256"] == python_record["actual_sha256"]
elf = python_file.read_bytes()[:64]
assert elf[:4] == b"\x7fELF" and elf[5] == 1 and int.from_bytes(elf[18:20], "little") == 183
generated_dir = support_root / ".silver/linux-aarch64/generated"
generated_checks = {}
for name, expected in previous["original_generated_ada_reconstructed_and_rehashed"].items():
    actual = sha(generated_dir / name)
    assert actual == expected
    generated_checks[name] = actual
overlay = read_json(RECORDS / "native-392/image-overlay.json")
vendor = Path(native["tools"]["gnatprove"]["path"]).parent.parent
assert overlay["original"] == str(original_root / ".silver/linux-aarch64/image-tools")
layout = overlay["layout"]
directories = {"bin", "libexec", "libexec/spark", "libexec/spark/bin"}
assert {name for name, item in layout.items() if item["kind"] == "directory"} == directories
assert {name for name, item in layout.items() if item["kind"] == "file"} == {"bin/gnatprove"}
assert layout["bin/gnatprove"]["sha256"] == native["tools"]["gnatprove"]["sha256"]
assert overlay["compiler_copy_matches_vendor_gnatprove"] is True
assert overlay["adapter_target_sha256"] == read_json(BASE / "complete-native/audit-verification.json")["post_build_verification"]["binary_sha256"]["silver_image_adapter"]
for name, item in layout.items():
    if item["kind"] == "symlink":
        expected = str(original_root / ".silver/linux-aarch64/compiler/bin/silver_image_adapter") if name == "libexec/spark/bin/gnatwhy3" else str(vendor / name)
        assert item["target"] == expected, name
    else:
        assert item["kind"] in {"directory", "file"}
assert len(layout) == 80
vendor_observation = overlay["vendor_binding"]["entries"]
assert overlay["vendor_binding"]["counts"] == {"matching": 1} and len(vendor_observation) == 1
vendor_entry = vendor_observation[0]
assert vendor_entry["actual"] == vendor_entry["expected"] == native["tools"]["gnatwhy3"]["sha256"]
assert vendor_entry["path"] == native["tools"]["gnatwhy3"]["path"]
generated_literals = re.findall(r':= "([^"]+)";', (generated_dir / "silver_image_config.ads").read_text())
assert generated_literals == [vendor_entry["path"], vendor_entry["actual"]]

native_result = {
    "checked_utc": datetime.now(timezone.utc).isoformat(),
    "target": previous["target"], "archive_hashes": archive_hashes,
    "locally_rehashed_native_inputs": len(native_local),
    "locally_rehashed_recovered_support_inputs": len(path_map),
    "locally_rehashed_current_repository_inputs": len(native_local) - len(path_map),
    "generated_ada_matches_original_reconstruction": generated_checks,
    "native_tool_observations_checked_against_original_manifest": len(observed_tools),
    "locally_rehashed_tool_bytes": {"python": native["tools"]["python"]["sha256"]},
    "python_architecture": "ELF64 little-endian AArch64 (e_machine 183)",
    "image_overlay_record_entries_checked": len(layout),
    "image_overlay_record_kind_counts": dict(collections.Counter(item["kind"] for item in layout.values())),
    "image_vendor_and_adapter_observed_hashes_match_original": True,
    "limits": [
        "The other 11 native tool hashes and Image copied executable/adapter/layout are reviewed collector observations; their binary/topology bytes were not transferred.",
        "The recovered Image record does not record executable permission bits or independently enumerate the vendor tree; no receiver-local canonical validate_image_setup pass is claimed.",
        "The original native success and current report audit are reused; no new native proof/complete live provenance invocation occurred.",
    ],
}
write_json("recovery-native-assurance-results.json", native_result)
print("Native: all 2622 inputs locally rehashed; 12 tool observations consistent; original ARM Python locally rehashed.", flush=True)

members = {}
contents = {}
read_bytes = 0
last_notice = time.monotonic()
with zstd.open(RECOVERY / "lean-392-cache.tar.zst", "rb") as decompressed:
    with tarfile.open(fileobj=decompressed, mode="r|") as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert not path.is_absolute() and ".." not in path.parts
            name = str(path)
            assert name not in members, name
            item = {"size": member.size, "mode": member.mode, "mtime": member.mtime}
            if member.isfile():
                item["kind"] = "file"
                keep = (name.endswith(".trace") or name.endswith(".json") or
                        name in {"adjacent/lean-proof.log", "reference/final-run/evidence.json"})
                assert not keep or member.size < 20 * 1024 * 1024, (name, member.size)
                buffer = bytearray() if keep else None
                digest = hashlib.sha256()
                with archive.extractfile(member) as source:
                    while data := source.read(1024 * 1024):
                        digest.update(data)
                        read_bytes += len(data)
                        if buffer is not None:
                            buffer.extend(data)
                item["sha256"] = digest.hexdigest()
                if buffer is not None:
                    contents[name] = bytes(buffer)
            elif member.islnk():
                item["kind"] = "hardlink"
                target = PurePosixPath(member.linkname)
                assert not target.is_absolute() and ".." not in target.parts
                item["target"] = str(target)
            elif member.issym():
                item.update(kind="symlink", target=member.linkname)
            elif member.isdir():
                item["kind"] = "directory"
            else:
                item["kind"] = "other:" + repr(member.type)
            members[name] = item
            if time.monotonic() - last_notice > 15:
                print(f"Archive: {len(members)} members inspected; {read_bytes} regular-file bytes hashed.", flush=True)
                last_notice = time.monotonic()


def resolve(name):
    visited = set()
    while members[name]["kind"] == "hardlink":
        assert name not in visited, name
        visited.add(name)
        name = members[name]["target"]
    assert members[name]["kind"] == "file", name
    return name, members[name]


def content(name):
    return contents[resolve(name)[0]]


workspace_actual, artifacts_actual = {}, {}
for name, member in members.items():
    if not name.startswith("proof/"):
        continue
    relative = name.removeprefix("proof/")
    path = PurePosixPath(relative)
    assert member["kind"] in {"file", "hardlink", "directory"}, (name, member)
    if member["kind"] == "directory":
        continue
    actual = resolve(name)[1]["sha256"]
    if (path.suffix == ".lean" and ".lake" not in path.parts) or relative == "lean-toolchain":
        workspace_actual[relative] = actual
    if relative.startswith(".lake/build/") and ".olean" in path.name:
        artifacts_actual[relative] = actual
assert workspace_actual == lean["workspace_inputs_sha256"]
assert artifacts_actual == lean["artifacts_sha256"]
assert content("reference/final-run/evidence.json") == (BASE / "complete-lean/final-run/evidence.json").read_bytes()
assert data_sha(content("adjacent/lean-proof.log")) == lean["log_sha256"]
marker = json.loads(content("proof/.silver-cache-tools.json"))
assert marker == lean["tools_sha256"]
traces = {}
for name in members:
    if name.startswith("proof/.lake/build/") and name.endswith(".trace"):
        trace = content(name)
        check_lean.check_proof_policy(Path(name), trace)
        traces[name.removeprefix("proof/")] = data_sha(trace)
assert traces
source_link = members["adjacent/src"]
assert source_link["kind"] == "symlink" and source_link["target"] == "../../src"
paths = json.loads(content("paths.json"))
assert paths["cache_marker_sha256"] == data_sha(content("proof/.silver-cache-tools.json"))
assert paths["adjacent_src_target"] == source_link["target"] and paths["symlinks_in_merged_view"] == {}
assert paths["source_checkout_head"] == "c7388ab5d038ccbce9635ffaeec7df9189369366"
assert paths["original_worktree"] == "/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/tmp/named-source-392"
recorded_comparison = json.loads(content("hash-comparison.json"))
for group, expected in [("workspace_inputs", lean["workspace_inputs_sha256"]), ("artifacts", lean["artifacts_sha256"])]:
    observations = recorded_comparison["merged_snapshot_view"][group]
    assert observations["counts"] == {"matching": len(expected)}
    assert {e["path"]: e["actual"] for e in observations["entries"]} == expected
    assert all(e["actual"] == e["expected"] and e["status"] == "matching" for e in observations["entries"])
overlay_metadata = json.loads(content("overlay-metadata.json"))
proof_files = {name: resolve(name)[1] for name, value in members.items()
               if name.startswith("proof/") and value["kind"] in {"file", "hardlink"}}
lean_result = {
    "checked_utc": datetime.now(timezone.utc).isoformat(),
    "archive": archive_hashes["lean-392-cache.tar.zst"],
    "streamed_archive_members": len(members), "regular_file_bytes_hashed": read_bytes,
    "archive_member_kinds": dict(collections.Counter(v["kind"] for v in members.values())),
    "merged_proof_files": len(proof_files),
    "merged_proof_logical_file_bytes": sum(v["size"] for v in proof_files.values()),
    "exact_workspace_inventory_and_bytes_match": len(workspace_actual),
    "exact_compiled_artifact_inventory_and_bytes_match": len(artifacts_actual),
    "compiled_artifact_bytes": sum(resolve("proof/" + k)[1]["size"] for k in artifacts_actual),
    "source_binding_symlink": source_link, "source_checkout_observation": paths["source_checkout_head"],
    "tool_marker": marker, "tool_marker_matches_original_tools": True,
    "current_production_trace_policy_checked": len(traces),
    "trace_hashes": traces,
    "original_lean_log_rehashed": lean["log_sha256"],
    "collector_merged_comparison_matches_receiver_bytes": True,
    "overlay_whiteouts": overlay_metadata["whiteouts"],
    "overlay_special_entry_count": len(overlay_metadata["special_entries"]),
    "overlay_attribute_path_count": len(overlay_metadata["opaque_or_other_overlay_attributes"]),
    "elapsed_seconds": round(time.monotonic() - started, 3),
    "limits": [
        "All compared object bytes are the original ARM result; no Lean object was loaded or replayed.",
        "Source link spelling was preserved; original /Volumes target is absent locally, so no claim of a live resolved source mount is made.",
        "Original Lean/lake executable hashes are bound by the unchanged recovered marker and historical successful provenance; executable bytes were not transferred or newly hashed here.",
        "Trace/source/object hash checks do not establish independent kernel replay or a fresh actual-import/axiom invocation.",
        "Archive was streamed without extracting any object into a live cache or preserving execution/ownership semantics for a new run.",
    ],
}
write_json("recovery-lean-assurance-results.json", lean_result)
write_json("recovery-lean-archive-file-inventory.json", members)
print(json.dumps({k: v for k, v in lean_result.items() if k not in {"trace_hashes", "overlay_whiteouts"}}, indent=2), flush=True)
