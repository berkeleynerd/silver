#!/usr/bin/env python3
"""Check pinned Lean proofs, or selected modules, in a native-host workspace.

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
    from .run_history import ManagedRun, allocation_report
else:
    from bootstrap_lean import lean_environment
    from platforms import ROOT, HostLayout, native_layout
    from run_history import ManagedRun, allocation_report

PROOF = ROOT / "proof"
CERTIFICATE_ROOTS = {
    Path("Silver/ProcedureBindingsSpecCertificate.lean"): "silver_procedure_bindings.ads",
    Path("Silver/ProcedureBindingsBodyCertificate.lean"): "silver_procedure_bindings.adb",
    Path("Silver/FunctionBindingsSpecCertificate.lean"): "silver_function_bindings.ads",
    Path("Silver/FunctionBindingsBodyCertificate.lean"): "silver_function_bindings.adb",
    Path("Silver/ArrayBindingsSpecCertificate.lean"): "silver_array_bindings.ads",
    Path("Silver/ArrayBindingsBodyCertificate.lean"): "silver_array_bindings.adb",
    Path("Silver/ImageModelSpecCertificate.lean"): "silver_image_model.ads",
    Path("Silver/ImageModelBodyCertificate.lean"): "silver_image_model.adb",
    Path("Silver/ImageModelTemplatesSpecCertificate.lean"): "silver_image_model_templates.ads",
    Path("Silver/ImageModelTemplatesBodyCertificate.lean"): "silver_image_model_templates.adb",

    Path("Silver/ScalarExpressionSpecCertificate.lean"): "silver_scalar_expressions.ads",
    Path("Silver/ScalarExpressionBodyCertificate.lean"): "silver_scalar_expressions.adb",
    Path("Silver/ScalarsSpecCertificate.lean"): "silver_scalars.ads",
    Path("Silver/ScalarLiteralSpecCertificate.lean"): "silver_scalar_literals.ads",
    Path("Silver/ScalarLiteralBodyCertificate.lean"): "silver_scalar_literals.adb",
    Path("Silver/NamesSpecCertificate.lean"): "silver_names.ads",
    Path("Silver/NamesBodyCertificate.lean"): "silver_names.adb",
    Path("Silver/PathFactsSpecCertificate.lean"): "silver_path_facts.ads",
    Path("Silver/IntegerLiteralSpecCertificate.lean"): "silver_integer_literals.ads",
    Path("Silver/IntegerLiteralBodyCertificate.lean"): "silver_integer_literals.adb",
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
OUTPUT_BODY_LINES = tuple(Path(f"Silver/OutputBodyLines{index}.lean") for index in range(8))
CANDIDATES = CERTIFICATE_ROOTS | {
    path: "silver_output_profile.adb" for path in OUTPUT_BODY_LINES}


def check_proof_policy(path: Path, contents: bytes) -> None:
    """Reject direct kernel bypasses, including in option strings and comments.

    The audit's exact read-only option guard is the sole permitted reference.
    This is a project source policy, not a sandbox for hostile metaprograms.
    """
    if path.parts[-2:] == ("Silver", "AxiomAudit.lean"):
        guard = "  if debug.skipKernelTC.get (← getOptions) then\n".encode()
        contents = contents.replace(guard, b"", 1)
    forbidden = re.search(rb"skipKernelTC|addDeclWithoutChecking|addDeclCore", contents)
    if forbidden:
        raise RuntimeError(f"kernel-check bypass {forbidden[0].decode()!r} is forbidden in {path}")


def check_cached_kernel_policy(host: HostLayout) -> None:
    """Reject retained objects built with unsafe weak arguments before reuse.

    Pinned Lake traces retain the original compiler command when weakLeanArgs
    changes are reverted. Missing/stale traces cause Lake's normal rebuild.
    Like the rest of the cache, these local traces are trusted, not authenticated.
    """
    for trace in sorted((host.proof / ".lake/build").rglob("*.trace")):
        check_proof_policy(trace, trace.read_bytes())


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


def generate_certificate(host: HostLayout, relative: Path, source_name: str,
                         *, pass_fds: tuple[int, ...] = ()) -> None:
    """Regenerate one source and publish all its generated candidate inputs.

    Stage the output-body aggregator and its eight line modules together. Read
    every expected output before publishing any, so a partial generation cannot
    silently retain a stale chunk. Unchanged bytes keep their useful timestamps.
    """
    outputs = (relative, *OUTPUT_BODY_LINES) if relative == Path(
        "Silver/OutputBodyCertificate.lean") else (relative,)
    pending = {host.proof / path: (host.proof / path).with_suffix(".lean.pending")
               for path in outputs}
    for candidate, generated in pending.items():
        require_regular_workspace_path(host, candidate)
        require_regular_workspace_path(host, generated)
        generated.unlink(missing_ok=True)
    try:
        subprocess.run([sys.executable, str(PROOF / "generate_source_certificate.py"),
                        "--source", source_name, "--output", str(pending[host.proof / relative])],
                       cwd=ROOT, check=True, pass_fds=pass_fds)
        contents = {}
        for candidate, generated in pending.items():
            require_regular_workspace_path(host, generated)
            if not generated.is_file():
                raise RuntimeError(f"candidate generator did not produce a regular certificate file: {generated}")
            contents[candidate] = generated.read_bytes()
        for candidate, data in contents.items():
            write_changed(candidate, data)
    finally:
        for generated in pending.values():
            generated.unlink(missing_ok=True)


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
    for path in host.proof.rglob("*.lean"):
        relative = path.relative_to(host.proof)
        if ".lake" not in relative.parts and relative not in CANDIDATES and relative not in expected:
            require_regular_workspace_path(host, path)
            path.unlink()
            # Pinned Lake checks source dependencies even for cached importers;
            # Lean also loads transitive imports from their own object files.
            # Remove this module's object/trace/IR family so neither can reuse
            # it, retaining unrelated (potentially expensive) certificates.
            for directory in ("lib/lean", "ir"):
                artifacts = host.proof / ".lake/build" / directory / relative.parent
                require_regular_workspace_path(host, artifacts)
                for artifact in artifacts.glob(relative.stem + ".*"):
                    require_regular_workspace_path(host, artifact)
                    artifact.unlink()
    for path, contents in inputs.items():
        if path.is_relative_to(shared_proof) and (
                path.suffix == ".lean" or path.name == "lean-toolchain"):
            destination = host.proof / path.relative_to(shared_proof)
            require_regular_workspace_path(host, destination)
            write_changed(destination, contents)


def prepare_tool_cache(host: HostLayout, tool_hashes: dict[str, str]) -> None:
    """Invalidate on compiler/build-tool changes, independent of optional replay."""
    marker = host.proof / ".silver-cache-tools.json"
    require_regular_workspace_path(host, marker)
    # Older markers included leanchecker. It neither builds these objects nor
    # affects their validity, so switching replay modes must preserve the cache.
    builders = {name: digest for name, digest in tool_hashes.items()
                if Path(name).name != "leanchecker"}
    try:
        previous = {name: digest for name, digest in json.loads(marker.read_bytes()).items()
                    if Path(name).name != "leanchecker"}
    except (OSError, ValueError, AttributeError):
        previous = None
    expected = json.dumps(builders, sort_keys=True).encode() + b"\n"
    cache = host.proof / ".lake"
    require_regular_workspace_path(host, cache)
    if previous != builders:
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


def lake_build_command(lake: Path, settings: list[str],
                       targets: list[str] | None = None) -> list[str]:
    # Lake caches get_config? values at configuration elaboration time. -K alone
    # does not replace that cached configuration. Re-elaboration applies this
    # run's thread/memory settings; weakLeanArgs preserve accepted module caches.
    return [str(lake), "--rehash", "--reconfigure", *settings, "build",
            *(["+" + target for target in targets] if targets is not None else ["Silver.Audit"])]


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
        if destination.suffix == ".lean":
            check_proof_policy(destination, expected)
    for relative in CANDIDATES:
        candidate = host.proof / relative
        for depth in range(len(relative.parts) + 1):
            if host.proof.joinpath(*relative.parts[:depth]).is_symlink():
                raise RuntimeError(f"candidate certificate must not be a symbolic link: {relative}")
        if not candidate.is_file():
            raise RuntimeError(f"candidate generator did not produce a regular certificate file: {relative}")
        check_proof_policy(candidate, candidate.read_bytes())


def audit_import_closure(sources: dict[str, Path], output: str,
                         targets: list[str] | None = None) -> set[str]:
    # Emitted by the actual imported Lean environment. Text inside a comment,
    # unused conditional syntax, or an unbuilt module cannot count as an import.
    visited = set(re.findall(r"(?:^|: )SILVER_MODULE ([A-Za-z0-9_.]+)\s*$", output, re.MULTILINE))
    required = set(sources) if targets is None else {*targets, "Silver.AxiomAudit"}
    if required - visited or visited - sources.keys():
        raise RuntimeError("actual Lean audit imports differ from project modules: missing=" +
                           ", ".join(sorted(required - visited)) + "; unexpected=" +
                           ", ".join(sorted(visited - sources.keys())))
    return visited


def verify_run_inputs(host: HostLayout, inputs: dict[Path, bytes],
                      source_modules: set[str], workspace_hashes: dict[str, str],
                      tool_hashes: dict[str, str],
                      audit_driver: tuple[Path, bytes] | None = None) -> dict[str, Path]:
    """Fail before the next expensive phase if this run has already gone stale."""
    current_sources, current_inputs = capture_shared_inputs()
    if set(current_sources) != source_modules or current_inputs != inputs:
        raise RuntimeError("proof inputs changed during verification (shared inventory or bytes)")
    verify_workspace_inputs(host, inputs)
    check_cached_kernel_policy(host)
    workspace_sources, current_workspace = capture_workspace_inputs(host)
    if set(workspace_sources) != source_modules or current_workspace != workspace_hashes:
        raise RuntimeError("proof inputs changed during verification (workspace inventory or bytes)")
    current_tools = {relative: hashlib.sha256((ROOT / relative).read_bytes()).hexdigest()
                     for relative in tool_hashes}
    if current_tools != tool_hashes:
        raise RuntimeError("Lean verification tools changed during replay")
    if (host.artifacts / "src").resolve() != (ROOT / "src").resolve():
        raise RuntimeError("authoritative source link changed during replay")
    if audit_driver is not None:
        path, expected = audit_driver
        require_regular_workspace_path(host, path)
        if not path.is_file() or path.read_bytes() != expected:
            raise RuntimeError("focused audit driver changed during verification")
    return workspace_sources


def run_logged(command: list[str], *, cwd: Path, env: dict[str, str],
               destination: TextIO, pass_fds: tuple[int, ...] = ()) -> subprocess.CompletedProcess[str]:
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
                          stderr=subprocess.STDOUT, pass_fds=pass_fds) as process:
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


def lean_failure_keys(output: str, phase: str, workspace: Path) -> list[str]:
    """Identify repeated source diagnostics, without inventing IDs for tool crashes.

    Lean does not publish GNATprove-style VC identifiers. Source location plus
    the first error line is a diagnostic key, not a theorem identity guarantee.
    Both direct Lean and Lake-prefixed error forms occur in retained output.
    """
    keys = set()
    for line in re.sub(r"\x1b\[[0-9;]*m", "", output).splitlines():
        match = re.fullmatch(r"(error: )?(.+?\.lean):(\d+):(\d+):\s*(error:\s*)?(.*)", line)
        if match is None or not (match[1] or match[5]):
            continue
        source = Path(match[2])
        absolute = (workspace / source).resolve()
        try:
            source = absolute.relative_to(workspace.resolve())
        except ValueError:
            source = absolute
        keys.add(f"lean:{phase}:{source}:{match[3]}:{match[4]}:{match[6]}")
    return sorted(keys)


def main(arguments: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--target", action="append", default=[], metavar="MODULE",
                        help="check one project module and its imports (repeatable; partial validation)")
    parser.add_argument("--replay", "--full", dest="replay", action="store_true",
                        help="also independently replay the complete kernel environment (optional audit)")
    parser.add_argument("--provenance", action="store_true",
                        help="record detailed input, workspace and compiled-object hash inventories")
    parser.add_argument("--clean", action="store_true",
                        help="discard this host's proof workspace before building (does not imply replay)")
    parser.add_argument("--workers", type=nonnegative_integer, default=0,
                        help="Lake workers for independent modules (default 0: coordinated available workers; "
                             "separate Lean process threads are not an OS thread cap; "
                             "a count below the available workers needs --resource-reason)")
    parser.add_argument("--threads", type=nonnegative_integer, default=0,
                        help="threads per Lean build/audit process (default 0: available CPUs; "
                             "separate from Lake workers; a count below the available CPUs needs --resource-reason)")
    parser.add_argument("--memory-mb", type=positive_integer,
                        help="optional resident-memory threshold per Lean process, in MiB")
    parser.add_argument("--task", default=os.environ.get("SILVER_TASK", ""), help="issue or task reference for durable run history")
    parser.add_argument("--reason", default="",
                        help="rationale for repeating a successful clean/replay check unchanged")
    parser.add_argument("--resource-reason", default="",
                        help="why this check deliberately uses fewer workers or threads than are available")
    args = parser.parse_args(arguments)
    sources, inputs = capture_shared_inputs()
    targets = list(dict.fromkeys(args.target))
    for target in targets:
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*", target) or target not in sources:
            parser.error(f"unknown project module: {target}")
    if targets and args.replay:
        parser.error("--replay/--full checks the complete project; omit --target")
    cpus = available_cpus()
    requested_threads = args.threads or None
    args.threads = args.threads or cpus
    detailed_integrity = args.provenance or args.replay
    started = time.monotonic()
    host = native_layout()
    log = host.artifacts / ("lean-focused.log" if targets else "lean-proof.log")
    evidence = host.artifacts / ("lean-focused-evidence.json" if targets else "lean-evidence.json")
    checked_inputs = {str(path.relative_to(ROOT)): hashlib.sha256(data).hexdigest()
                      for path, data in inputs.items()}
    inputs_digest = hashlib.sha256(json.dumps(checked_inputs, sort_keys=True).encode()).hexdigest()
    lean = host.lean / "bin" / "lean"
    lake = lean.with_name("lake")
    checker = lean.with_name("leanchecker")
    tool_paths = [lean, lake, *([checker] if args.replay else [])]
    # Missing tools still produce a recorded preflight failure before any cache
    # mutation. Successful checks retain the exact executable byte hashes.
    tool_hashes = {str(path.relative_to(ROOT)):
                   hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else "missing"
                   for path in tool_paths}
    run_inputs = {
        "host": host.key, "scope": sorted(targets) if targets else "complete",
        "sources": checked_inputs, "tools": tool_hashes,
        "workspace": str(host.proof.resolve()),
        "configuration": {"clean": args.clean, "replay": args.replay,
                          "provenance": args.provenance, "workers": args.workers,
                          "threads": args.threads, "memory_mb": args.memory_mb},
    }
    command = [sys.executable, str(Path(__file__).resolve()),
               *(sys.argv[1:] if arguments is None else arguments)]
    with ManagedRun(host=host, kind="lean", command=command, inputs=run_inputs,
                    resources=[host.proof, log, evidence], workers=args.workers or None,
                    task=args.task, reason=args.reason, expensive=args.clean or args.replay,
                    evidence=[log, evidence], failure_reports=[log], resource_reason=args.resource_reason,
                    allocation={"threads": {"requested": requested_threads, "automatic": cpus,
                                            "actual": args.threads},
                                "memory_mb": {"requested": args.memory_mb, "automatic": None,
                                              "actual": args.memory_mb}}) as run:
        args.workers = run.workers
        if host.artifacts.is_symlink():
            raise RuntimeError("host artifact directory must not be a symbolic link")
        host.artifacts.mkdir(parents=True, exist_ok=True)
        # Failed checks cannot leave the previous success looking current.
        # A rejected lease/rerun request has not started a check and preserves it.
        for old in (log, evidence):
            if old.is_file():
                previous = run.directory / "previous-evidence"
                previous.mkdir(exist_ok=True)
                shutil.copy2(old, previous / old.name)
                run.evidence.append(previous / old.name)
        evidence.unlink(missing_ok=True)
        log.unlink(missing_ok=True)
        for path, contents in inputs.items():
            if path.suffix == ".lean":
                check_proof_policy(path, contents)
        pin = inputs[PROOF / "lean-toolchain"].decode().strip()
        prefix = "leanprover/lean4:v"
        if not pin.startswith(prefix):
            raise RuntimeError("proof/lean-toolchain must pin a concrete Lean version")
        if "missing" in tool_hashes.values():
            raise RuntimeError("pinned Lean tools are missing; run scripts/bootstrap_lean.py")
        environment = lean_environment(host)
        version = subprocess.run([str(lean), "--short-version"], check=True,
                                 text=True, capture_output=True, env=environment,
                                 cwd=host.artifacts, pass_fds=run.pass_fds).stdout.strip()
        if version != pin.removeprefix(prefix):
            raise RuntimeError(f"Lean {version} does not match {pin}")
        run.event("preflight", outcome="success", tools_sha256=tool_hashes)

        # Lake's compiled runtime uses this worker pool for independent build jobs.
        # lean_environment removed any inherited value; the explicit -j option
        # separately configures each Lean build/audit process. Neither setting
        # parallelizes leanchecker's fresh replay.
        environment["LEAN_NUM_THREADS"] = str(args.workers)
        print(f"Lean concurrency: {args.workers} Lake workers, "
              f"{args.threads} threads per Lean process ({cpus} available CPUs).", flush=True)
        print(allocation_report(run.record), flush=True)

        prepare_workspace(host, inputs, clean=args.clean)
        prepare_tool_cache(host, tool_hashes)
        # These are candidate certificates, not trusted results: Lean checks each
        # line and reconstruction of the exact authoritative source bytes.
        # The generator writes beside the final module so its authoritative-source
        # path checks remain valid. Publish only changed bytes to preserve no-op runs.
        for relative, source_name in CERTIFICATE_ROOTS.items():
            generate_certificate(host, relative, source_name, pass_fds=run.pass_fds)
        verify_workspace_inputs(host, inputs)
        workspace_sources, workspace_hashes = capture_workspace_inputs(host)
        if workspace_sources.keys() != sources.keys():
            raise RuntimeError("host proof workspace does not contain exactly the shared project modules")
        source_modules = set(sources)
        lake_settings = ["-K", f"silverThreads={args.threads}"]
        lean_settings = ["-DwarningAsError=true", f"-j{args.threads}"]
        if args.memory_mb is not None:
            lake_settings.extend(["-K", f"silverMemoryMb={args.memory_mb}"])
            lean_settings.append(f"-M{args.memory_mb}")
        audit_driver = None
        build_targets = None
        audit_path = Path("Silver/Audit.lean")
        if targets:
            build_targets = list(dict.fromkeys([*targets, "Silver.AxiomAudit"]))
            audit_path = Path(".lake/silver-focused-audit.lean")
            contents = ("".join(f"import {target}\n" for target in build_targets) +
                        "\n#silver_audit\n").encode()
            driver_path = host.proof / audit_path
            require_regular_workspace_path(host, driver_path)
            write_changed(driver_path, contents)
            audit_driver = (driver_path, contents)
        verify_run_inputs(host, inputs, source_modules, workspace_hashes, tool_hashes, audit_driver)
        build_command = lake_build_command(lake, lake_settings, build_targets)
        audit_command = [str(lake), *lake_settings, "env", str(lean), *lean_settings,
                         str(audit_path)]
        commands = [build_command, audit_command]
        if args.replay:
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
                run.event("phase_started", phase=phase, command=command, started_at=started_at)
                record(f"Lean phase {phase} started at {started_at}")
                record("+ " + " ".join(command))
                try:
                    result = run_logged(command, cwd=host.proof, env=environment,
                                        destination=destination, pass_fds=run.pass_fds)
                except BaseException as error:
                    run.event("phase_interrupted", phase=phase, error=type(error).__name__,
                              elapsed_seconds=round(time.monotonic() - phase_started, 3))
                    record(f"\nLean phase {phase} interrupted after "
                           f"{time.monotonic() - phase_started:.3f}s: {type(error).__name__}")
                    raise
                phases.append({"phase": phase, "started_at": started_at,
                               "finished_at": datetime.now(timezone.utc).isoformat(),
                               "elapsed_seconds": round(time.monotonic() - phase_started, 3),
                               "exit_code": result.returncode})
                run.event("phase_finished", **phases[-1])
                record(f"\nLean phase {phase} finished at {phases[-1]['finished_at']}; "
                       f"elapsed {phases[-1]['elapsed_seconds']:.3f}s; exit {result.returncode}")
                if result.returncode:
                    run.finish(outcome="interrupted" if result.returncode < 0 else "failure",
                               returncode=result.returncode,
                               failure_keys=lean_failure_keys(result.stdout, phase, host.proof))
                    raise RuntimeError(f"Lean check failed; see {log}")
                workspace_sources = verify_run_inputs(
                    host, inputs, source_modules, workspace_hashes, tool_hashes, audit_driver)
                if command == build_command:
                    if detailed_integrity:
                        compiled_hashes = compiled_artifacts(host)
                        if not compiled_hashes:
                            raise RuntimeError("Lean build produced no compiled artifacts to audit")
                else:
                    if detailed_integrity and compiled_hashes != compiled_artifacts(host):
                        raise RuntimeError("compiled Lean artifacts changed during verification")
                    if command == audit_command:
                        if "Silver axiom audit passed:" not in result.stdout:
                            raise RuntimeError("Lean check completed without a freshly executed axiom audit")
                        visited = audit_import_closure(workspace_sources, result.stdout, targets or None)
        workspace_sources = verify_run_inputs(
            host, inputs, source_modules, workspace_hashes, tool_hashes, audit_driver)
        if detailed_integrity and compiled_hashes != compiled_artifacts(host):
            raise RuntimeError("compiled Lean artifacts changed during verification")
        result_record = {
            "host": host.key, "lean_version": version, "run_id": run.run_id,
            "scope": "focused" if targets else "complete",
            "targets": targets or ["Silver.Audit"],
            "mode": "clean" if args.clean else "replay" if args.replay else
                    "focused" if targets else "incremental",
            "clean_build": args.clean, "axiom_audit": "passed",
            "kernel_recheck": "leanchecker --fresh Silver.Audit" if args.replay else None,
            "threads_per_process": args.threads, "lake_workers": args.workers,
            "available_cpus": cpus, "memory_mb_per_process": args.memory_mb,
            "phases": phases, "tools_sha256": tool_hashes, "modules": sorted(visited),
            "elapsed_seconds": round(time.monotonic() - started, 3),
            "inputs_digest_sha256": inputs_digest,
            "workspace": str(host.proof.relative_to(ROOT)),
            "authoritative_source": "src", "log": str(log.relative_to(ROOT))}
        if args.provenance:
            result_record.update({"commands": commands, "inputs_sha256": checked_inputs,
                                  "workspace_inputs_sha256": workspace_hashes,
                                  "artifacts_sha256": compiled_hashes,
                                  "log_sha256": hashlib.sha256(log.read_bytes()).hexdigest()})
        evidence.write_text(json.dumps(result_record, indent=2) + "\n")
        # Canonical convenience paths can change on the next run. Keep this
        # successful run's log and evidence alongside its durable event record.
        retained_log = run.directory / log.name
        retained_evidence = run.directory / evidence.name
        shutil.copyfile(log, retained_log)
        shutil.copyfile(evidence, retained_evidence)
        run.evidence.extend([retained_log, retained_evidence])
        label = "focused check (partial validation)" if targets else "complete project check"
        print(f"Lean {label} and fresh axiom audit "
              f"passed for {host.key}: {log}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"check_lean: {error}") from error
