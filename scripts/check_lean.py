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
        if not source_link.is_symlink() or source_link.resolve() != authoritative:
            raise RuntimeError(f"{source_link} must link to authoritative {authoritative}")
    else:
        source_link.symlink_to(authoritative, target_is_directory=True)
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


def audit_import_closure(sources: dict[str, Path]) -> set[str]:
    pending = ["Silver.Audit"]
    visited: set[str] = set()
    while pending:
        module = pending.pop()
        if module in visited or module not in sources:
            continue
        visited.add(module)
        text = sources[module].read_text()
        pending.extend(re.findall(r"(?m)^\s*(?:public\s+)?import\s+([\w.]+)", text))
    missing = sources.keys() - visited
    if missing:
        raise RuntimeError("proof modules missing from audit imports: " + ", ".join(sorted(missing)))
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
             ROOT / "src" / "silver_profile.ads", ROOT / "src" / "silver_profile.adb"]
    inputs = {path: path.read_bytes() for path in sorted(paths)}
    checked_inputs = {str(path.relative_to(ROOT)): hashlib.sha256(data).hexdigest()
                      for path, data in inputs.items()}

    pin = inputs[PROOF / "lean-toolchain"].decode().strip()
    prefix = "leanprover/lean4:v"
    if not pin.startswith(prefix):
        raise RuntimeError("proof/lean-toolchain must pin a concrete Lean version")
    lean = host.lean / "bin" / "lean"
    lake = lean.with_name("lake")
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
    workspace_sources = project_sources(host.proof)
    if workspace_sources.keys() != sources.keys():
        raise RuntimeError("host proof workspace does not contain exactly the shared project modules")
    visited = audit_import_closure(workspace_sources)
    workspace_inputs = [*workspace_sources.values(), host.proof / "lakefile.lean",
                        host.proof / "lean-toolchain"]
    workspace_hashes = {str(path.relative_to(host.proof)):
                        hashlib.sha256(path.read_bytes()).hexdigest()
                        for path in sorted(workspace_inputs)}

    with log.open("w") as destination:
        for arguments in ([str(lake), "clean"], [str(lake), "build", "Silver.Audit"]):
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
    current_inputs = {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
                      for path in inputs}
    current_workspace = {str(path.relative_to(host.proof)):
                         hashlib.sha256(path.read_bytes()).hexdigest()
                         for path in workspace_inputs}
    if current_inputs != checked_inputs or current_workspace != workspace_hashes:
        raise RuntimeError("proof inputs changed during the clean replay")
    if (host.artifacts / "src").resolve() != (ROOT / "src").resolve():
        raise RuntimeError("authoritative source link changed during replay")
    evidence.write_text(json.dumps({"host": host.key, "lean_version": version,
                                    "clean_replay": True, "axiom_audit": "passed",
                                    "modules": sorted(visited),
                                    "elapsed_seconds": round(time.monotonic() - started, 3),
                                    "inputs_sha256": checked_inputs,
                                    "workspace_inputs_sha256": workspace_hashes,
                                    "workspace": str(host.proof.relative_to(ROOT)),
                                    "authoritative_source": "src",
                                    "log": str(log.relative_to(ROOT))}, indent=2) + "\n")
    print(f"Lean proof replay and axiom audit passed for {host.key}: {log}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"check_lean: {error}") from error
