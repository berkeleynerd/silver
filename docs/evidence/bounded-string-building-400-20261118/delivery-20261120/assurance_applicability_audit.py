#!/usr/bin/env python3
"""Read-only PR403 packet/applicability audit; writes only adjacent scratch.

This deliberately does not manufacture a native proof-provenance manifest or
claim that parsing a retained Lean log freshly imports/kernel-checks objects.
"""
import collections
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys
import tarfile

sys.dont_write_bytecode = True
OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[1]
TARGET = ROOT / "tmp/pr403-delivery"
HEAD = "001c50dce1bcf3ad2d174b4426f684fe78cb2e64"
PACKET = TARGET / "docs/evidence/named-scalar-arguments-392-20261117"
sys.path.insert(0, str(TARGET / "scripts"))
import bootstrap
import check_evidence
import check_lean
import platforms
import proof_provenance


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read_json(path):
    return json.loads(path.read_bytes())


def read_archive(path, expected):
    with tarfile.open(path) as archive:
        members = archive.getmembers()
        assert len(members) == len(expected)
        assert {m.name for m in members} == set(expected)
        assert all(m.isfile() and not Path(m.name).is_absolute()
                   and ".." not in Path(m.name).parts for m in members)
        data = {m.name: archive.extractfile(m).read() for m in members}
    assert {k: sha(v) for k, v in data.items()} == expected
    return data


def compare_git(inputs):
    names = sorted(inputs)
    proc = subprocess.run(["git", "cat-file", "--batch"], cwd=TARGET,
                          input="".join(f"{HEAD}:{name}\n" for name in names).encode(),
                          capture_output=True, check=True)
    payload = proc.stdout
    offset = 0
    for name in names:
        end = payload.index(b"\n", offset)
        header = payload[offset:end].split()
        assert len(header) == 3 and header[1] == b"blob", (name, header)
        size = int(header[2])
        data = payload[end + 1:end + 1 + size]
        assert sha(data) == inputs[name], name
        assert sha((TARGET / name).read_bytes()) == inputs[name], name
        offset = end + 1 + size + 1
    assert offset == len(payload)
    return len(names)


native_dir = PACKET / "complete-native"
lean_dir = PACKET / "complete-lean"
native = read_json(native_dir / "proof-provenance.json")
lean = read_json(lean_dir / "final-run/evidence.json")
manifest_hashes = read_json(native_dir / "SHA256SUMS.json")
if "files_sha256" in manifest_hashes:
    manifest_hashes = manifest_hashes["files_sha256"]
assert {str(p.relative_to(native_dir)) for p in native_dir.rglob("*")
        if p.is_file()} - {"SHA256SUMS.json"} == set(manifest_hashes)
for name, expected in manifest_hashes.items():
    assert sha((native_dir / name).read_bytes()) == expected, name
lean_hashes = read_json(lean_dir / "packet-manifest.json")["files_sha256"]
assert {str(p.relative_to(lean_dir)) for p in lean_dir.rglob("*")
        if p.is_file()} - {"packet-manifest.json"} == set(lean_hashes)
for name, expected in lean_hashes.items():
    assert sha((lean_dir / name).read_bytes()) == expected, name

shared_modules, shared_inputs = check_lean.capture_shared_inputs()
current_lean_inputs = {str(p.relative_to(TARGET)): sha(data)
                       for p, data in shared_inputs.items()}
assert current_lean_inputs == lean["inputs_sha256"]
assert sha(json.dumps(current_lean_inputs, sort_keys=True).encode()) == lean["inputs_digest_sha256"]
repo_native_paths = {TARGET / p for p in ("silver.gpr", "proof/silver_proof_containers.gpr", "alire.toml")}
for directory, suffixes in ((TARGET / "src", {".ads", ".adb"}), (TARGET / "scripts", {".py"})):
    repo_native_paths.update(p for p in directory.rglob("*") if p.is_file() and p.suffix in suffixes)
current_native_inputs = {str(p.relative_to(TARGET)): sha(p.read_bytes()) for p in repo_native_paths}
retained_native_repo = {k: v for k, v in native["inputs_sha256"].items() if not k.startswith(".")}
assert current_native_inputs == retained_native_repo
all_repo_inputs = {**current_native_inputs, **current_lean_inputs}
git_inputs = compare_git(all_repo_inputs)

snapshot = read_json(native_dir / "proof-inputs.json")
assert all(native[k] == v for k, v in snapshot.items())
assert native["schema"] == 1 and native["complete"] is True and native["host"] == "linux-aarch64"
assert native["mode"] == "full"
command = native["command"]
assert command[:3] == ["gnatprove", "-P", "../../../silver.gpr"]
assert command[3:3 + len(check_evidence.PROOF_OPTIONS)] == check_evidence.PROOF_OPTIONS
assert command[-1] == "-XSILVER_HOST=linux-aarch64"
proof_provenance.validate_project(platforms.HostLayout(TARGET, "linux-aarch64"))

original_native_root = Path(read_json(native_dir / "audit-verification.json")["worktree"])
original_native_host = platforms.HostLayout(original_native_root, "linux-aarch64")
configuration = bootstrap.build_source_configuration(bootstrap.build_configuration(original_native_host)).encode("ascii")
vendor = native["tools"]["gnatwhy3"]
# Reconstruct exactly the recorded file from the recorded path/hash. This is
# not validate_image_setup and does not claim to rehash the absent vendor tool.
image_configuration = (
    "-- Generated exact vendor binding; bootstrap and rebuild after tool changes.\n"
    "package Silver_Image_Config with SPARK_Mode => On is\n"
    f"   Native_Gnatwhy3 : constant String := {bootstrap.ada_string(vendor['path'])};\n"
    f'   Native_Gnatwhy3_SHA256 : constant String := "{vendor["sha256"]}";\n'
    "end Silver_Image_Config;\n").encode("ascii")
generated = {
    "silver_build.ads": configuration,
    "silver_image_config.ads": image_configuration,
    "silver_library_sources.ads": bootstrap.runtime_source_configuration(TARGET / "src"),
}
generated_dir = OUT / "assurance-generated-arm-record"
generated_dir.mkdir(exist_ok=True)
for name, data in generated.items():
    assert sha(data) == native["inputs_sha256"][f".silver/linux-aarch64/generated/{name}"]
    (generated_dir / name).write_bytes(data)

reports = read_archive(native_dir / "native-reports.tar.gz", native["reports_sha256"])
reports_dir = OUT / "assurance-retained-native-reports"
reports_dir.mkdir(exist_ok=True)
for name, data in reports.items():
    (reports_dir / name).write_bytes(data)
sources = sorted(TARGET.joinpath("src").glob("*.ads")) + sorted(TARGET.joinpath("src").glob("*.adb"))
sources += sorted(generated_dir.glob("*.ads"))
for source in sources:
    check_evidence.audit_source_policy(source)
    if source.name in check_evidence.TRUSTED_IMPORT_SPECS:
        check_evidence.audit_import_spec(source)
proof_instances = {unit: check_evidence.audit_sequence_instance(TARGET / "src" / (unit + ".ads"))
                   for unit in check_evidence.SEQUENCE_INSTANCES
                   if (TARGET / "src" / (unit + ".ads")).is_file()}
conversion = TARGET / "src" / (check_evidence.SIGNED_CONVERSION_UNIT + ".ads")
stats = check_evidence.audit_reports(
    reports_dir, {p.stem for p in sources},
    {p.stem for p in sources if p.name in check_evidence.TRUSTED_IMPORT_SPECS},
    effective_command=command, proof_instances=proof_instances,
    signed_conversion_instance=check_evidence.audit_signed_conversion_instance(conversion))
assert stats == read_json(native_dir / "audit-verification.json")["stats"]

archived_repo = read_archive(lean_dir / "final-run/inputs.tar.gz", lean["inputs_sha256"])
workspace = read_archive(lean_dir / "final-run/workspace-inputs.tar.gz", lean["workspace_inputs_sha256"])
for name, data in archived_repo.items():
    assert data == (TARGET / name).read_bytes()
for name, data in workspace.items():
    if Path(name) not in check_lean.CANDIDATES:
        assert data == (TARGET / "proof" / name).read_bytes()
    if name.endswith(".lean"):
        check_lean.check_proof_policy(Path(name), data)
assert {".".join(Path(n).with_suffix("").parts) for n in workspace
        if n.endswith(".lean") and n != "lakefile.lean"} == shared_modules.keys()
generator_spec = importlib.util.spec_from_file_location("pr403_generator", TARGET / "proof/generate_source_certificate.py")
generator = importlib.util.module_from_spec(generator_spec)
generator_spec.loader.exec_module(generator)
candidate_hashes = {}
for filename, binding, prefix in generator.SOURCE_BINDINGS:
    source_bytes = (TARGET / "src" / filename).read_bytes()
    generator.validate_source_bytes(source_bytes, filename)
    binding_module = binding[0].upper() + binding[1:] + "Source"
    line_modules = generator.OUTPUT_BODY_LINE_MODULES if filename == "silver_output_profile.adb" else ()
    if line_modules:
        chunks, reconstruction = generator.generate_output_body_parts(source_bytes.decode("ascii"), binding, prefix)
        declarations = []
    else:
        declarations, reconstruction = generator.generate_parts(source_bytes.decode("ascii"), binding, prefix)
        chunks = []
    root = next(k for k, v in check_lean.CERTIFICATE_ROOTS.items() if v == filename)
    output = generator.module_header(binding_module, line_modules)
    if not line_modules:
        output.extend(line for declaration in declarations for line in declaration)
    output.extend(reconstruction)
    candidates = {root: output}
    for module, chunk in zip(line_modules, chunks, strict=True):
        candidates[Path("Silver") / (module + ".lean")] = generator.module_header() + [line for declaration in chunk for line in declaration]
    for path, contents in candidates.items():
        data = ("\n".join([*contents, "end Silver.Source"]) + "\n").encode("utf-8")
        assert data == workspace[str(path)]
        assert data == (TARGET / "proof" / path).read_bytes()
        candidate_hashes[str(path)] = sha(data)
assert set(candidate_hashes) == {str(p) for p in check_lean.CANDIDATES}
log_bytes = (lean_dir / "final-run/lean-proof.log").read_bytes()
assert sha(log_bytes) == lean["log_sha256"]
log = log_bytes.decode()
imports = check_lean.audit_import_closure(shared_modules, log)
assert imports == set(lean["modules"])
audit_lines = re.findall(r"Silver axiom audit passed: .*", log)
assert audit_lines and all("166332 declarations" in line for line in audit_lines)
assert all(set(re.findall(r"propext|Classical\.choice|Quot\.sound", line)) == {"propext", "Classical.choice", "Quot.sound"} for line in audit_lines)
assert lean["scope"] == "complete" and lean["axiom_audit"] == "passed"
assert lean["kernel_recheck"] is None and all(p["exit_code"] == 0 for p in lean["phases"])

native_tools = {}
for name, identity in native["tools"].items():
    if "version" in identity:
        assert sha(identity["version"].encode()) == identity["version_sha256"]
    path = Path(identity["path"])
    native_tools[name] = {"path": str(path), "sha256": identity["sha256"], "original_path_available": path.is_file()}
    if path.is_file():
        native_tools[name]["original_path_hash_matches"] = sha(path.read_bytes()) == identity["sha256"]
assert set(native_tools) == {"gnatprove", "gnatls", "gcc", "gprbuild", "cvc5", "z3", "alt-ergo", "gnat2why", "gnatwhy3", "why3server", "python", "alr"}
native_other = {}
for name, expected in native["inputs_sha256"].items():
    if name in current_native_inputs:
        continue
    path = ROOT / name
    role = "generated_ada" if "/generated/" in name else "alire_context" if name.startswith(".silver/") else "alire_settings_and_index"
    native_other[name] = {"role": role, "sha256": expected, "local_historical_copy_available": path.is_file()}
    if path.is_file():
        native_other[name]["local_historical_copy_hash_matches"] = sha(path.read_bytes()) == expected

record = {
    "checked_utc": datetime.now(timezone.utc).isoformat(),
    "target": HEAD, "worktree": str(TARGET), "actual_host": platforms.host_key(),
    "native_packet_files_rehashed": len(manifest_hashes), "lean_packet_files_rehashed": len(lean_hashes),
    "repository_inputs_compared_with_worktree_and_git": git_inputs,
    "native_repository_inputs": len(current_native_inputs), "lean_repository_inputs": len(current_lean_inputs),
    "native_report_archive_files": len(reports), "native_report_archive_uncompressed_bytes": sum(map(len, reports.values())),
    "native_report_and_source_policy_audit": stats,
    "original_generated_ada_reconstructed_and_rehashed": {n: sha(d) for n, d in generated.items()},
    "current_root_x86_generated_ada_observation": {
        p.name: {"sha256": sha(p.read_bytes()), "equals_original_arm_file": p.read_bytes() == generated[p.name]}
        for p in (ROOT / ".silver/linux-x86_64/generated").glob("*.ads") if p.name in generated},
    "native_other_input_categories": dict(collections.Counter(v["role"] for v in native_other.values())),
    "native_other_inputs": native_other, "native_tools": native_tools,
    "lean_workspace_inputs_rehashed": len(workspace),
    "lean_generated_candidates_recomputed_against_pr_and_archive": candidate_hashes,
    "lean_actual_import_log_modules": len(imports), "lean_retained_audit_lines": audit_lines,
    "lean_recorded_artifact_files": len(lean["artifacts_sha256"]),
    "lean_recorded_tools": lean["tools_sha256"],
    "lean_repository_archive_bytes": sum(map(len, archived_repo.values())),
    "lean_workspace_archive_bytes": sum(map(len, workspace.values())),
    "limits": [
        "Fresh Python report/source-policy audit of retained linux-aarch64 reports; not a new GNATprove run.",
        "No native validate_provenance or validate_image_setup pass: original installation/tool bytes and overlay are unavailable.",
        "Reconstructed generated files match old recorded hashes; this does not revalidate the vendor executable or claim current x86 generated inputs match.",
        "Native audit_sources timestamp guard was not run on reconstructed copies; no timestamps were backdated.",
        "Lean packet, source/candidate parity and retained module/axiom log were rechecked; no new Lean import/axiom audit or kernel replay occurred.",
        "6202 compiled artifacts are hash-inventoried but absent from the committed packet; their contents were not rehashed.",
    ],
}
(OUT / "assurance-applicability-results.json").write_text(json.dumps(record, indent=2) + "\n")
print(json.dumps({k: v for k, v in record.items() if k not in {
    "native_other_inputs", "native_tools", "lean_generated_candidates_recomputed_against_pr_and_archive"}}, indent=2))
