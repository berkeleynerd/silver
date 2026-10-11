#!/usr/bin/env python3
"""Check pinned Lean proofs incrementally in an isolated native-host workspace.

Shared proof and compiler source files are read-only inputs. Candidate source
certificates, Lake objects/manifests, and evidence stay below .silver/<host>.
The workspace's sibling src link names the actual authoritative source tree;
source correspondence never switches to a divergent copied Ada source.
"""

from __future__ import annotations

import argparse
import codecs
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time
from typing import TextIO

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
    Path("Silver/OutputLexicalSpecCertificate.lean"): "silver_output_lexical.ads",
    Path("Silver/OutputLexicalBodyCertificate.lean"): "silver_output_lexical.adb",
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


def capture_shared_inputs() -> tuple[dict[str, Path], dict[Path, bytes]]:
    """Enumerate the whole selected input set, including additions and removals."""
    sources = project_sources(PROOF)
    paths = [*(path for path in sources.values() if path.relative_to(PROOF) not in CANDIDATES),
             PROOF / "lakefile.lean", PROOF / "lean-toolchain",
             PROOF / "generate_source_certificate.py",
             *sorted((ROOT / "src").glob("*.ads")), *sorted((ROOT / "src").glob("*.adb")),
             *sorted((ROOT / "scripts").glob("*.py"))]
    return sources, {path: path.read_bytes() for path in sorted(paths)}


def capture_workspace_inputs(host: HostLayout) -> tuple[dict[str, Path], dict[str, str]]:
    sources = project_sources(host.proof)
    paths = [*sources.values(), host.proof / "lakefile.lean", host.proof / "lean-toolchain"]
    return sources, {str(path.relative_to(host.proof)):
                     hashlib.sha256(path.read_bytes()).hexdigest() for path in sorted(paths)}


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


def nonnegative_integer(value: str) -> int:
    number = int(value)
    if number < 0:
        raise argparse.ArgumentTypeError("must be nonnegative (0 uses available CPUs)")
    return number


def available_cpus() -> int:
    """Respect process affinity and Python's CPU override, with a portable fallback.

    CPU-time quotas and competing workloads can require an explicit lower worker
    setting; an affinity mask does not describe those limits.
    """
    counts = []
    for probe in (getattr(os, "process_cpu_count", None), os.cpu_count):
        if probe is not None:
            try:
                count = probe()
            except OSError:
                continue
            if count is not None and count > 0:
                counts.append(count)
    try:
        affinity = len(os.sched_getaffinity(0))
        if affinity > 0:
            counts.append(affinity)
    except (AttributeError, OSError):
        pass
    return min(counts, default=1)


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


def verify_run_inputs(host: HostLayout, inputs: dict[Path, bytes],
                      source_modules: set[str], workspace_hashes: dict[str, str],
                      tool_hashes: dict[str, str]) -> dict[str, Path]:
    """Fail before the next expensive phase if this run has already gone stale."""
    current_sources, current_inputs = capture_shared_inputs()
    if set(current_sources) != source_modules or current_inputs != inputs:
        raise RuntimeError("proof inputs changed during verification (shared inventory or bytes)")
    verify_workspace_inputs(host, inputs)
    workspace_sources, current_workspace = capture_workspace_inputs(host)
    if set(workspace_sources) != source_modules or current_workspace != workspace_hashes:
        raise RuntimeError("proof inputs changed during verification (workspace inventory or bytes)")
    current_tools = {relative: hashlib.sha256((ROOT / relative).read_bytes()).hexdigest()
                     for relative in tool_hashes}
    if current_tools != tool_hashes:
        raise RuntimeError("Lean verification tools changed during replay")
    if (host.artifacts / "src").resolve() != (ROOT / "src").resolve():
        raise RuntimeError("authoritative source link changed during replay")
    return workspace_sources


def run_logged(command: list[str], *, cwd: Path, env: dict[str, str],
               destination: TextIO) -> subprocess.CompletedProcess[str]:
    """Tee available output, including partial lines, while retaining audit text."""
    output: list[str] = []
    decoder = codecs.getincrementaldecoder("utf-8")()

    def publish(text: str) -> None:
        if text:
            output.append(text)
            destination.write(text)
            destination.flush()
            print(text, end="", flush=True)

    with subprocess.Popen(command, cwd=cwd, env=env, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT) as process:
        assert process.stdout is not None
        try:
            while chunk := process.stdout.read1(65536):
                publish(decoder.decode(chunk))
            publish(decoder.decode(b"", final=True))
            returncode = process.wait()
        except BaseException:
            process.kill()
            process.wait()
            raise
    return subprocess.CompletedProcess(command, returncode, "".join(output))


def main(arguments: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--full", action="store_true",
                        help="also independently replay the complete kernel environment")
    parser.add_argument("--clean", action="store_true",
                        help="discard this host's proof workspace and perform a full check")
    parser.add_argument("--workers", type=nonnegative_integer, default=0,
                        help="Lake workers for independent modules (default 0: available CPUs; "
                             "reduce on quota-limited or shared hosts)")
    parser.add_argument("--threads", type=nonnegative_integer, default=0,
                        help="threads per Lean build/audit process (default 0: available CPUs; "
                             "separate from Lake workers)")
    parser.add_argument("--memory-mb", type=positive_integer,
                        help="optional resident-memory threshold per Lean process, in MiB")
    args = parser.parse_args(arguments)
    cpus = available_cpus()
    args.workers = args.workers or cpus
    args.threads = args.threads or cpus
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

    # The checked-in candidates are never edited or used as trusted generated
    # inputs. Every replay regenerates their host-local replacements from src.
    # SourceCertificates.lean is a protected handwritten import facade.
    sources, inputs = capture_shared_inputs()
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

    # Lake's compiled runtime uses this worker pool for independent build jobs.
    # lean_environment removed any inherited value; the explicit -j option
    # separately configures each Lean build/audit process. Neither setting
    # parallelizes leanchecker's fresh replay.
    environment["LEAN_NUM_THREADS"] = str(args.workers)
    print(f"Lean concurrency: {args.workers} Lake workers, "
          f"{args.threads} threads per Lean process ({cpus} available CPUs).", flush=True)

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
    workspace_sources, workspace_hashes = capture_workspace_inputs(host)
    if workspace_sources.keys() != sources.keys():
        raise RuntimeError("host proof workspace does not contain exactly the shared project modules")
    source_modules = set(sources)
    verify_run_inputs(host, inputs, source_modules, workspace_hashes, tool_hashes)

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
    visited: set[str] = set()
    phases = []
    with log.open("w") as destination:
        def record(message: str) -> None:
            destination.write(message + "\n")
            destination.flush()
            print(message, flush=True)

        for phase, command in zip(("build", "audit", "kernel"), commands):
            phase_started = time.monotonic()
            started_at = datetime.now(timezone.utc).isoformat()
            record(f"Lean phase {phase} started at {started_at}")
            record("+ " + " ".join(command))
            try:
                result = run_logged(command, cwd=host.proof, env=environment,
                                    destination=destination)
            except BaseException as error:
                record(f"\nLean phase {phase} interrupted after "
                       f"{time.monotonic() - phase_started:.3f}s: {type(error).__name__}")
                raise
            phases.append({"phase": phase, "started_at": started_at,
                           "finished_at": datetime.now(timezone.utc).isoformat(),
                           "elapsed_seconds": round(time.monotonic() - phase_started, 3),
                           "exit_code": result.returncode})
            record(f"\nLean phase {phase} finished at {phases[-1]['finished_at']}; "
                   f"elapsed {phases[-1]['elapsed_seconds']:.3f}s; exit {result.returncode}")
            if result.returncode:
                raise RuntimeError(f"Lean check failed; see {log}")
            workspace_sources = verify_run_inputs(
                host, inputs, source_modules, workspace_hashes, tool_hashes)
            if command == build_command:
                compiled_hashes = compiled_artifacts(host)
                if not compiled_hashes:
                    raise RuntimeError("Lean build produced no compiled artifacts to audit")
            else:
                if compiled_hashes != compiled_artifacts(host):
                    raise RuntimeError("compiled Lean artifacts changed during verification")
                if command == audit_command:
                    if "Silver axiom audit passed:" not in result.stdout:
                        raise RuntimeError("Lean check completed without a freshly executed axiom audit")
                    visited = audit_import_closure(workspace_sources, result.stdout)
    workspace_sources = verify_run_inputs(
        host, inputs, source_modules, workspace_hashes, tool_hashes)
    current_artifacts = compiled_artifacts(host)
    if compiled_hashes != current_artifacts:
        raise RuntimeError("compiled Lean artifacts changed during verification")
    evidence.write_text(json.dumps({"host": host.key, "lean_version": version,
                                    "mode": "clean" if args.clean else "full" if full else "incremental",
                                    "clean_replay": args.clean, "axiom_audit": "passed",
                                    "kernel_recheck": "leanchecker --fresh Silver.Audit" if full else None,
                                    "threads_per_process": args.threads,
                                    "lake_workers": args.workers,
                                    "available_cpus": cpus,
                                    "memory_mb_per_process": args.memory_mb,
                                    "commands": commands,
                                    "phases": phases,
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
