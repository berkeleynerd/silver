#!/usr/bin/env python3
"""Check pinned Lean proofs incrementally in an isolated native-host workspace.

Shared proof and compiler source files are read-only inputs. Candidate source
certificates, Lake objects/manifests, and evidence stay below .silver/<host>.
The workspace's sibling src link names the actual authoritative source tree;
source correspondence never switches to a divergent copied Ada source.
"""

from __future__ import annotations

import argparse
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
CANDIDATES = {
    Path("Silver/ProfileSpecCertificate.lean"): "silver_profile.ads",
    Path("Silver/ProfileBodyCertificate.lean"): "silver_profile.adb",
    Path("Silver/OutputSpecCertificate.lean"): "silver_output_profile.ads",
    Path("Silver/OutputBodyCertificate.lean"): "silver_output_profile.adb",
    Path("Silver/IOSpecCertificate.lean"): "silver_io.ads",
    Path("Silver/IOBodyCertificate.lean"): "silver_io.adb",
    Path("Silver/OutputLibcCertificate.lean"): "silver_output_libc.ads",
    Path("Silver/ArgumentsSpecCertificate.lean"): "silver_arguments.ads",
    Path("Silver/ArgumentsBodyCertificate.lean"): "silver_arguments.adb",
    Path("Silver/RuntimeSpecCertificate.lean"): "silver_runtime.ads",
}


def project_sources(proof: Path) -> dict[str, Path]:
    return {".".join(path.relative_to(proof).with_suffix("").parts): path
            for path in proof.rglob("*.lean")
            if ".lake" not in path.parts and path.name != "lakefile.lean"}


def write_changed(path: Path, contents: bytes) -> None:
    """Preserve unchanged source timestamps and Lake's useful local artifacts."""
    if not path.is_file() or path.read_bytes() != contents:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(contents)


def require_regular_workspace_path(host: HostLayout, path: Path) -> None:
    relative = path.relative_to(host.proof)
    for depth in range(len(relative.parts) + 1):
        if host.proof.joinpath(*relative.parts[:depth]).is_symlink():
            raise RuntimeError(f"proof workspace path must not be a symbolic link: {path}")


def prepare_workspace(host: HostLayout, inputs: dict[Path, bytes], *, clean: bool = False) -> None:
    """Synchronize captured inputs, retaining this host's incremental artifacts."""
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
    if clean and host.proof.exists():
        shutil.rmtree(host.proof)
    host.proof.mkdir(exist_ok=True)
    require_regular_workspace_path(host, host.proof / ".lake")
    shared_proof = host.root / "proof"
    expected = {path.relative_to(shared_proof) for path in inputs
                if path.is_relative_to(shared_proof) and (
                    path.suffix == ".lean" or path.name == "lean-toolchain")}
    removed = False
    for path in host.proof.rglob("*.lean"):
        relative = path.relative_to(host.proof)
        if ".lake" not in relative.parts and relative not in CANDIDATES and relative not in expected:
            require_regular_workspace_path(host, path)
            path.unlink()
            removed = True
    # A removed module must not remain importable from an old .olean. Removing
    # the local build directory is deliberately conservative and infrequent.
    if removed and (host.proof / ".lake/build").exists():
        require_regular_workspace_path(host, host.proof / ".lake/build")
        shutil.rmtree(host.proof / ".lake/build")
    for path, contents in inputs.items():
        if path.is_relative_to(shared_proof) and (
                path.suffix == ".lean" or path.name == "lean-toolchain"):
            destination = host.proof / path.relative_to(shared_proof)
            require_regular_workspace_path(host, destination)
            write_changed(destination, contents)


def prepare_tool_cache(host: HostLayout, tool_hashes: dict[str, str]) -> None:
    """Discard compiled configurations/artifacts if the local tools change."""
    marker = host.proof / ".silver-cache-tools.json"
    require_regular_workspace_path(host, marker)
    expected = json.dumps(tool_hashes, sort_keys=True).encode() + b"\n"
    cache = host.proof / ".lake"
    require_regular_workspace_path(host, cache)
    if not marker.is_file() or marker.read_bytes() != expected:
        if cache.exists():
            shutil.rmtree(cache)
        write_changed(marker, expected)


def compiled_artifacts(host: HostLayout) -> dict[str, str]:
    return {str(path.relative_to(host.proof)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in sorted((host.proof / ".lake/build").rglob("*.olean*")) if path.is_file()}


def positive_integer(value: str) -> int:
    number = int(value)
    if number < 1:
        raise argparse.ArgumentTypeError("must be a positive integer")
    return number


def lake_build_command(lake: Path, settings: list[str]) -> list[str]:
    # Lake caches get_config? values at configuration elaboration time. -K alone
    # does not replace that cached configuration. Re-elaboration applies this
    # run's thread/memory settings; weakLeanArgs preserve accepted module caches.
    return [str(lake), "--rehash", "--reconfigure", *settings, "build", "Silver.Audit"]


def verify_workspace_inputs(host: HostLayout, inputs: dict[Path, bytes]) -> None:
    """Only the selected generated certificates may differ from shared inputs.

    Run this before establishing the workspace hash baseline: a generator must
    not redefine the handwritten source binding or bridge and then have those
    changes mistaken for the inputs we intended to check.
    """
    shared_proof = host.root / "proof"
    for source, expected in inputs.items():
        if not source.is_relative_to(shared_proof):
            continue
        relative = source.relative_to(shared_proof)
        if relative in CANDIDATES or not (source.suffix == ".lean" or source.name == "lean-toolchain"):
            continue
        destination = host.proof / relative
        for depth in range(len(relative.parts) + 1):
            if host.proof.joinpath(*relative.parts[:depth]).is_symlink():
                raise RuntimeError(f"handwritten proof input is a symbolic link: {destination}")
        if not destination.is_file() or destination.read_bytes() != expected:
            raise RuntimeError(f"candidate generation changed handwritten proof input: {relative}")
    for relative in CANDIDATES:
        candidate = host.proof / relative
        for depth in range(len(relative.parts) + 1):
            if host.proof.joinpath(*relative.parts[:depth]).is_symlink():
                raise RuntimeError(f"candidate certificate must not be a symbolic link: {relative}")
        if not candidate.is_file():
            raise RuntimeError(f"candidate generator did not produce a regular certificate file: {relative}")


def audit_import_closure(sources: dict[str, Path], output: str) -> set[str]:
    # Emitted by the actual imported Lean environment. Text inside a comment,
    # unused conditional syntax, or an unbuilt module cannot count as an import.
    visited = set(re.findall(r"(?:^|: )SILVER_MODULE ([A-Za-z0-9_.]+)\s*$", output, re.MULTILINE))
    if sources.keys() != visited:
        raise RuntimeError("actual Lean audit imports differ from project modules: missing=" +
                           ", ".join(sorted(sources.keys() - visited)) + "; unexpected=" +
                           ", ".join(sorted(visited - sources.keys())))
    return visited


def main(arguments: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--full", action="store_true",
                        help="also independently replay the complete kernel environment")
    parser.add_argument("--clean", action="store_true",
                        help="discard this host's proof workspace and perform a full check")
    parser.add_argument("--threads", type=positive_integer, default=1,
                        help="threads per Lean process (default 1 for certificate memory use; "
                             "Lake also schedules independent modules)")
    parser.add_argument("--memory-mb", type=positive_integer,
                        help="optional memory limit per Lean process, in megabytes")
    args = parser.parse_args(arguments)
    full = args.full or args.clean
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
    # The checked-in candidates are never edited or used as trusted generated
    # inputs. Every replay regenerates their host-local replacements from src.
    # SourceCertificates.lean is a protected handwritten import facade.
    paths = [*(path for path in sources.values() if path.relative_to(PROOF) not in CANDIDATES),
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

    prepare_workspace(host, inputs, clean=args.clean)
    prepare_tool_cache(host, tool_hashes)
    # These are candidate certificates, not trusted results: Lean checks each
    # line and reconstruction of the exact authoritative source bytes.
    # The generator writes beside the final module so its authoritative-source
    # path checks remain valid. Publish only changed bytes to preserve no-op runs.
    for relative, source_name in CANDIDATES.items():
        candidate = host.proof / relative
        generated = candidate.with_suffix(".lean.pending")
        require_regular_workspace_path(host, generated)
        require_regular_workspace_path(host, candidate)
        generated.unlink(missing_ok=True)
        try:
            subprocess.run([sys.executable, str(PROOF / "generate_source_certificate.py"),
                            "--source", source_name, "--output", str(generated)], cwd=ROOT, check=True)
            require_regular_workspace_path(host, generated)
            write_changed(candidate, generated.read_bytes())
        finally:
            generated.unlink(missing_ok=True)
    verify_workspace_inputs(host, inputs)
    workspace_sources = project_sources(host.proof)
    if workspace_sources.keys() != sources.keys():
        raise RuntimeError("host proof workspace does not contain exactly the shared project modules")
    workspace_inputs = [*workspace_sources.values(), host.proof / "lakefile.lean",
                        host.proof / "lean-toolchain"]
    workspace_hashes = {str(path.relative_to(host.proof)):
                        hashlib.sha256(path.read_bytes()).hexdigest()
                        for path in sorted(workspace_inputs)}

    lake_settings = ["-K", f"silverThreads={args.threads}"]
    lean_settings = ["-DwarningAsError=true", f"-j{args.threads}"]
    if args.memory_mb is not None:
        lake_settings.extend(["-K", f"silverMemoryMb={args.memory_mb}"])
        lean_settings.append(f"-M{args.memory_mb}")
    build_command = lake_build_command(lake, lake_settings)
    audit_command = [str(lake), *lake_settings, "env", str(lean), *lean_settings,
                     "Silver/Audit.lean"]
    commands = [build_command, audit_command]
    if full:
        commands.append([str(lake), *lake_settings, "env", str(checker), "--fresh", "Silver.Audit"])
    compiled_hashes = None
    audit_output = ""
    with log.open("w") as destination:
        for command in commands:
            print("+ " + " ".join(command), flush=True)
            result = subprocess.run(command, cwd=host.proof, text=True,
                                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                    env=environment)
            destination.write(result.stdout)
            destination.flush()
            print(result.stdout, end="", flush=True)
            if result.returncode:
                raise RuntimeError(f"Lean check failed; see {log}")
            if command == build_command:
                compiled_hashes = compiled_artifacts(host)
                if not compiled_hashes:
                    raise RuntimeError("Lean build produced no compiled artifacts to audit")
            elif command == audit_command:
                audit_output = result.stdout
    if "Silver axiom audit passed:" not in audit_output:
        raise RuntimeError("Lean check completed without a freshly executed axiom audit")
    verify_workspace_inputs(host, inputs)
    visited = audit_import_closure(workspace_sources, audit_output)
    current_artifacts = compiled_artifacts(host)
    if compiled_hashes != current_artifacts:
        raise RuntimeError("compiled Lean artifacts changed during verification")
    current_inputs = {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
                      for path in inputs}
    current_workspace = {str(path.relative_to(host.proof)):
                         hashlib.sha256(path.read_bytes()).hexdigest()
                         for path in workspace_inputs}
    if current_inputs != checked_inputs or current_workspace != workspace_hashes:
        raise RuntimeError("proof inputs changed during verification")
    if tool_hashes != {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
                       for path in tool_paths}:
        raise RuntimeError("Lean verification tools changed during replay")
    if (host.artifacts / "src").resolve() != (ROOT / "src").resolve():
        raise RuntimeError("authoritative source link changed during replay")
    evidence.write_text(json.dumps({"host": host.key, "lean_version": version,
                                    "mode": "clean" if args.clean else "full" if full else "incremental",
                                    "clean_replay": args.clean, "axiom_audit": "passed",
                                    "kernel_recheck": "leanchecker --fresh Silver.Audit" if full else None,
                                    "threads_per_process": args.threads,
                                    "memory_mb_per_process": args.memory_mb,
                                    "commands": commands,
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
    print(f"Lean {'full verification' if full else 'incremental check'} and fresh axiom audit "
          f"passed for {host.key}: {log}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"check_lean: {error}") from error
