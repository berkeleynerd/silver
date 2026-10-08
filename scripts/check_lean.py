#!/usr/bin/env python3
"""Replay pinned Lean proofs in an isolated native-host workspace.

Shared proof and compiler source files are read-only inputs. Candidate source
certificates, Lake objects/manifests, and evidence stay below .silver/<host>.
The workspace's sibling src link names the actual authoritative source tree;
source correspondence never switches to a divergent copied Ada source.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time

if __package__:
    from .bootstrap_lean import lean_environment
    from .platforms import ROOT, HostLayout, native_layout
else:
    from bootstrap_lean import lean_environment
    from platforms import ROOT, HostLayout, native_layout

PROOF = ROOT / "proof"
CANDIDATE = Path("Silver/SourceCertificates.lean")


def project_sources(proof: Path) -> dict[str, Path]:
    return {".".join(path.relative_to(proof).with_suffix("").parts): path
            for path in proof.rglob("*.lean")
            if ".lake" not in path.parts and path.name != "lakefile.lean"}


def prepare_workspace(host: HostLayout, inputs: dict[Path, bytes]) -> None:
    """Replace only this host's disposable proof workspace with captured inputs."""
    if host.artifacts.is_symlink() or host.proof.is_symlink():
        raise RuntimeError("host proof/artifact directory must not be a symbolic link")
    host.artifacts.mkdir(parents=True, exist_ok=True)
    source_link = host.artifacts / "src"
    authoritative = (host.root / "src").resolve()
    if source_link.exists() or source_link.is_symlink():
        if not source_link.is_symlink():
            raise RuntimeError(f"{source_link} must link to authoritative {authoritative}")
        if source_link.resolve() != authoritative:
            source_link.unlink()
            source_link.symlink_to(Path("../../src"), target_is_directory=True)
    else:
        source_link.symlink_to(Path("../../src"), target_is_directory=True)
    if host.proof.exists():
        shutil.rmtree(host.proof)
    host.proof.mkdir()
    shared_proof = host.root / "proof"
    for path, contents in inputs.items():
        if path.is_relative_to(shared_proof) and (
                path.suffix == ".lean" or path.name == "lean-toolchain"):
            destination = host.proof / path.relative_to(shared_proof)
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(contents)


def verify_workspace_inputs(host: HostLayout, inputs: dict[Path, bytes]) -> None:
    """Only the candidate certificate may differ from captured shared inputs.

    Run this before establishing the workspace hash baseline: a generator must
    not redefine the handwritten source binding or bridge and then have those
    changes mistaken for the inputs we intended to check.
    """
    shared_proof = host.root / "proof"
    for source, expected in inputs.items():
        if not source.is_relative_to(shared_proof):
            continue
        relative = source.relative_to(shared_proof)
        if relative == CANDIDATE or not (source.suffix == ".lean" or source.name == "lean-toolchain"):
            continue
        destination = host.proof / relative
        for depth in range(len(relative.parts) + 1):
            if host.proof.joinpath(*relative.parts[:depth]).is_symlink():
                raise RuntimeError(f"handwritten proof input is a symbolic link: {destination}")
        if not destination.is_file() or destination.read_bytes() != expected:
            raise RuntimeError(f"candidate generation changed handwritten proof input: {relative}")
    candidate = host.proof / CANDIDATE
    for depth in range(len(CANDIDATE.parts) + 1):
        if host.proof.joinpath(*CANDIDATE.parts[:depth]).is_symlink():
            raise RuntimeError("candidate certificate must not be a symbolic link")
    if not candidate.is_file():
        raise RuntimeError("candidate generator did not produce a regular certificate file")


def audit_import_closure(sources: dict[str, Path], output: str) -> set[str]:
    # Emitted by the actual imported Lean environment. Text inside a comment,
    # unused conditional syntax, or an unbuilt module cannot count as an import.
    visited = set(re.findall(r"(?:^|: )SILVER_MODULE ([A-Za-z0-9_.]+)\s*$", output, re.MULTILINE))
    if sources.keys() != visited:
        raise RuntimeError("actual Lean audit imports differ from project modules: missing=" +
                           ", ".join(sorted(sources.keys() - visited)) + "; unexpected=" +
                           ", ".join(sorted(visited - sources.keys())))
    return visited


def main() -> None:
    started = time.monotonic()
    host = native_layout()
    if host.artifacts.is_symlink():
        raise RuntimeError("host artifact directory must not be a symbolic link")
    host.artifacts.mkdir(parents=True, exist_ok=True)
    log = host.artifacts / "lean-proof.log"
    evidence = host.artifacts / "lean-evidence.json"
    # A failed setup or generation attempt must not retain this host's prior
    # success. Other host evidence and old flat-layout artifacts are untouched.
    evidence.unlink(missing_ok=True)

    sources = project_sources(PROOF)
    # The checked-in candidate is never edited or used as trusted generated
    # input. Every replay regenerates its host-local replacement from src.
    paths = [*(path for path in sources.values() if path != PROOF / CANDIDATE),
             PROOF / "lakefile.lean", PROOF / "lean-toolchain",
             PROOF / "generate_source_certificate.py",
             *sorted((ROOT / "src").glob("*.ads")), *sorted((ROOT / "src").glob("*.adb")),
             *sorted((ROOT / "scripts").glob("*.py"))]
    inputs = {path: path.read_bytes() for path in sorted(paths)}
    checked_inputs = {str(path.relative_to(ROOT)): hashlib.sha256(data).hexdigest()
                      for path, data in inputs.items()}

    pin = inputs[PROOF / "lean-toolchain"].decode().strip()
    prefix = "leanprover/lean4:v"
    if not pin.startswith(prefix):
        raise RuntimeError("proof/lean-toolchain must pin a concrete Lean version")
    lean = host.lean / "bin" / "lean"
    lake = lean.with_name("lake")
    checker = lean.with_name("leanchecker")
    tool_paths = [lean, lake, checker]
    tool_hashes = {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
                   for path in tool_paths}
    environment = lean_environment(host)
    version = subprocess.run([str(lean), "--short-version"], check=True,
                             text=True, capture_output=True, env=environment,
                             cwd=host.artifacts).stdout.strip()
    if version != pin.removeprefix(prefix):
        raise RuntimeError(f"Lean {version} does not match {pin}")

    prepare_workspace(host, inputs)
    candidate = host.proof / CANDIDATE
    # These are candidate certificates, not trusted results: Lean checks each
    # line and reconstruction of the exact authoritative source bytes.
    subprocess.run([sys.executable, str(PROOF / "generate_source_certificate.py"),
                    "--output", str(candidate)], cwd=ROOT, check=True)
    verify_workspace_inputs(host, inputs)
    workspace_sources = project_sources(host.proof)
    if workspace_sources.keys() != sources.keys():
        raise RuntimeError("host proof workspace does not contain exactly the shared project modules")
    workspace_inputs = [*workspace_sources.values(), host.proof / "lakefile.lean",
                        host.proof / "lean-toolchain"]
    workspace_hashes = {str(path.relative_to(host.proof)):
                        hashlib.sha256(path.read_bytes()).hexdigest()
                        for path in sorted(workspace_inputs)}

    compiled_hashes = None
    with log.open("w") as destination:
        for arguments in ([str(lake), "clean"], [str(lake), "build", "Silver.Audit"],
                          [str(lake), "env", str(checker), "--fresh", "Silver.Audit"]):
            if "--fresh" in arguments:
                compiled_hashes = {
                    str(path.relative_to(host.proof)): hashlib.sha256(path.read_bytes()).hexdigest()
                    for path in sorted((host.proof / ".lake/build").rglob("*.olean*")) if path.is_file()}
                if not compiled_hashes:
                    raise RuntimeError("Lean build produced no compiled artifacts to recheck")
            print("+ " + " ".join(arguments), flush=True)
            result = subprocess.run(arguments, cwd=host.proof, text=True,
                                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                    env=environment)
            destination.write(result.stdout)
            destination.flush()
            print(result.stdout, end="", flush=True)
            if result.returncode:
                raise RuntimeError(f"Lean check failed; see {log}")
    if "Silver axiom audit passed:" not in log.read_text():
        raise RuntimeError("Lean build completed without the required axiom audit")
    verify_workspace_inputs(host, inputs)
    visited = audit_import_closure(workspace_sources, log.read_text())
    current_artifacts = {
        str(path.relative_to(host.proof)): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in sorted((host.proof / ".lake/build").rglob("*.olean*")) if path.is_file()}
    if compiled_hashes != current_artifacts:
        raise RuntimeError("compiled Lean artifacts changed during the kernel recheck")
    current_inputs = {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
                      for path in inputs}
    current_workspace = {str(path.relative_to(host.proof)):
                         hashlib.sha256(path.read_bytes()).hexdigest()
                         for path in workspace_inputs}
    if current_inputs != checked_inputs or current_workspace != workspace_hashes:
        raise RuntimeError("proof inputs changed during the clean replay")
    if tool_hashes != {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
                       for path in tool_paths}:
        raise RuntimeError("Lean verification tools changed during replay")
    if (host.artifacts / "src").resolve() != (ROOT / "src").resolve():
        raise RuntimeError("authoritative source link changed during replay")
    evidence.write_text(json.dumps({"host": host.key, "lean_version": version,
                                    "clean_replay": True, "axiom_audit": "passed",
                                    "kernel_recheck": "leanchecker --fresh Silver.Audit",
                                    "tools_sha256": tool_hashes,
                                    "artifacts_sha256": current_artifacts,
                                    "modules": sorted(visited),
                                    "elapsed_seconds": round(time.monotonic() - started, 3),
                                    "inputs_sha256": checked_inputs,
                                    "workspace_inputs_sha256": workspace_hashes,
                                    "workspace": str(host.proof.relative_to(ROOT)),
                                    "authoritative_source": "src",
                                    "log": str(log.relative_to(ROOT)),
                                    "log_sha256": hashlib.sha256(log.read_bytes()).hexdigest()}, indent=2) + "\n")
    print(f"Lean proof replay and axiom audit passed for {host.key}: {log}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"check_lean: {error}") from error
