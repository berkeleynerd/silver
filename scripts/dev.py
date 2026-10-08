#!/usr/bin/env python3
"""Run native development tools in the current host's isolated workspace.

Silver source admission, compilation, and execution belong to the SPARK binary;
this helper builds and verifies that compiler and runs its development tests.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass, field
import json
from pathlib import Path
import subprocess
import sys
import tempfile

if __package__:
    from .check_evidence import PROOF_OPTIONS, audit_sources
    from .proof_provenance import (MANIFEST, begin_proof, complete_proof, invalidate_proof,
                                   selected_proof_cache, validate_project)
    from .platforms import HostLayout, alire_command, native_layout, require_native, tool_environment
else:
    from check_evidence import PROOF_OPTIONS, audit_sources
    from proof_provenance import (MANIFEST, begin_proof, complete_proof, invalidate_proof,
                                  selected_proof_cache, validate_project)
    from platforms import HostLayout, alire_command, native_layout, require_native, tool_environment


def paths(host: HostLayout) -> dict[str, str]:
    return {"host": host.key, "root": str(host.root), "tools": str(host.tools),
            "alr": str(host.alr), "settings": str(host.alire_settings),
            "cache": str(host.alire_cache), "toolchains": str(host.alire_toolchains),
            "artifacts": str(host.artifacts), "context": str(host.context),
            "generated": str(host.generated), "compiler": str(host.compiler),
            "executable": str(host.compiler / "bin/silver"),
            "reports": str(host.compiler / "obj/gnatprove"),
            "lean": str(host.lean), "proof": str(host.proof)}


def invoke(host: HostLayout, command: list[str], *, cwd: Path | None = None) -> None:
    require_native(host)
    subprocess.run(command, cwd=host.root if cwd is None else cwd,
                   env=tool_environment(host) if cwd == host.context else None,
                   check=True)


def project_reports(host: HostLayout, arguments: list[str]) -> Path:
    """Validate optional native build flags before a tool can write anything."""
    reports = host.compiler / "obj/gnatprove"
    redirects = ("-P", "--project", "--relocate-build-tree", "--root-dir",
                 "--object-dir", "--exec-dir", "--src-subdirs", "--config",
                 "--autoconf", "--db", "--target", "-cargs", "-bargs", "-largs")
    for index, argument in enumerate(arguments):
        if "SILVER_HOST" in argument or argument.startswith(redirects):
            raise RuntimeError("prove/build select the native project and output paths; "
                               "use tool for custom tool invocations")
        subdirectory = None
        if argument.startswith("--subdirs="):
            subdirectory = argument.split("=", 1)[1]
        elif argument == "--subdirs":
            if index + 1 == len(arguments):
                raise RuntimeError("--subdirs requires a relative directory")
            subdirectory = arguments[index + 1]
        if subdirectory is not None:
            path = Path(subdirectory)
            if not subdirectory or path.is_absolute() or ".." in path.parts:
                raise RuntimeError("build subdirectory must remain inside this host's workspace")
            reports = host.compiler / "obj" / path / "gnatprove"
    return reports


@dataclass
class ProofRun:
    full: bool = False
    cold: bool = False
    jobs: int = 0
    arguments: list[str] = field(default_factory=list)


def worker_count(value: str) -> int:
    if not value.isascii() or not value.isdecimal():
        raise ValueError("jobs must be a nonnegative integer (0 uses all cores)")
    return int(value)


def proof_arguments(arguments: list[str], *, full: bool = False, cold: bool = False,
                    jobs: int = 0) -> ProofRun:
    """Allow scheduling/output controls while preserving the proof regime."""
    result = ProofRun(full=full, cold=cold, jobs=jobs)
    index = 0
    while index < len(arguments):
        argument = arguments[index]
        if argument in ("--full", "-f"):
            result.full = True
        elif argument == "--cold":
            result.cold = True
        elif argument in ("--jobs", "-j"):
            if index + 1 == len(arguments):
                raise RuntimeError("--jobs requires a nonnegative integer")
            index += 1
            result.jobs = worker_count(arguments[index])
        elif argument.startswith("--jobs="):
            result.jobs = worker_count(argument.split("=", 1)[1])
        elif argument.startswith("-j"):
            result.jobs = worker_count(argument[2:])
        elif argument == "--subdirs":
            if index + 1 == len(arguments):
                raise RuntimeError("--subdirs requires a relative directory")
            index += 1
            value = arguments[index]
            result.arguments.extend([argument, value])
        elif argument.startswith("--subdirs="):
            value = argument.split("=", 1)[1]
            result.arguments.append(argument)
        else:
            raise RuntimeError(f"proof configuration cannot be overridden: {argument}; use tool for exploratory runs")
        if argument == "--subdirs" or argument.startswith("--subdirs="):
            path = Path(value)
            if path.parts and (path.parts[0] == "explore" or path.parts[0].startswith("cold-")):
                raise RuntimeError("explore and cold-* subdirectories are reserved; use tool or prove --cold")
        index += 1
    if result.cold:
        if result.arguments:
            raise RuntimeError("--cold selects its own fresh output subdirectory; omit --subdirs")
        result.full = True
    return result


def exploratory_tool(host: HostLayout, command: list[str]) -> None:
    """Prevent accidental sharing by direct GNATprove experiments, not wrappers."""
    if Path(command[0]).name != "gnatprove":
        return
    arguments = command[1:]
    if arguments in (["--help"], ["--version"], ["-h"]):
        return
    subdirectories = []
    for index, argument in enumerate(arguments):
        for option in ("--subdirs", "--memcached-server"):
            if argument == option:
                if index + 1 == len(arguments):
                    raise RuntimeError(f"{option} requires a value")
                value = arguments[index + 1]
            elif argument.startswith(option + "="):
                value = argument.split("=", 1)[1]
            else:
                continue
            if option == "--subdirs":
                subdirectories.append(value)
            elif value.startswith("file:"):
                cache = Path(value[5:])
                cache = (host.context / cache).resolve()
                managed = (host.artifacts / "proof-cache").resolve()
                objects = (host.compiler / "obj").resolve()
                cold_cache = False
                if cache.is_relative_to(objects):
                    parts = cache.relative_to(objects).parts
                    cold_cache = len(parts) >= 2 and parts[0].startswith("cold-") and parts[1] == "cache"
                if cache.is_relative_to(managed) or cold_cache:
                    raise RuntimeError("exploratory GNATprove must use its own cache, outside audited proof caches")
    if len(subdirectories) != 1:
        raise RuntimeError("exploratory GNATprove requires --subdirs=explore or --subdirs=explore/<name>")
    path = Path(subdirectories[0])
    if path.is_absolute() or not path.parts or path.parts[0] != "explore" or ".." in path.parts:
        raise RuntimeError("exploratory GNATprove requires --subdirs=explore or --subdirs=explore/<name>")


def main(arguments: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="action", required=True)
    for action in ("prove", "build", "test", "tool"):
        child = commands.add_parser(action)
        if action == "prove":
            child.add_argument("--full", "-f", action="store_true",
                               help="force all units and audit complete proof evidence")
            child.add_argument("--cold", action="store_true",
                               help="full audit with fresh isolated objects, sessions and solver cache")
            child.add_argument("--jobs", "-j", type=worker_count, default=0,
                               help="parallel workers; 0 uses all cores (default)")
        child.add_argument("arguments", nargs=argparse.REMAINDER)
    path_parser = commands.add_parser("paths")
    path_parser.add_argument("--field", help="print one path instead of JSON")
    args = parser.parse_args(arguments)
    host = native_layout()
    if args.action == "paths":
        values = paths(host)
        if args.field:
            if args.field not in values:
                parser.error(f"unknown path field: {args.field}")
            print(values[args.field])
        else:
            print(json.dumps(values, indent=2))
        return
    extra = args.arguments
    if extra[:1] == ["--"]:
        extra = extra[1:]
    if args.action == "test":
        invoke(host, [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v", *extra])
        return
    if not host.alr.is_file() or not (host.context / "alire.toml").is_file():
        raise RuntimeError("native toolchain is not set up; run python3 scripts/bootstrap.py")
    reports = host.compiler / "obj/gnatprove"
    proof_run = None
    if args.action in ("prove", "build"):
        reports = project_reports(host, extra)
        tool = "gnatprove" if args.action == "prove" else "gprbuild"
        if args.action == "prove":
            proof_run = proof_arguments(extra, full=args.full, cold=args.cold, jobs=args.jobs)
            extra = proof_run.arguments
            validate_project(host)
            if proof_run.cold:
                objects = host.compiler / "obj"
                objects.mkdir(parents=True, exist_ok=True)
                workspace = Path(tempfile.mkdtemp(prefix="cold-", dir=objects))
                extra = [f"--subdirs={workspace.name}"]
                reports = workspace / "gnatprove"
            cache = selected_proof_cache(host, reports, cold=proof_run.cold)
            cache.mkdir(parents=True, exist_ok=True)
            options = [*PROOF_OPTIONS, "-j", str(proof_run.jobs),
                       f"--memcached-server=file:{cache}"]
            if proof_run.full:
                options.append("-f")
        else:
            options = ["-p"]
        command = [tool, "-P", "../../../silver.gpr", *options, *extra,
                   f"-XSILVER_HOST={host.key}"]
    else:
        if not extra:
            parser.error("tool requires a command; for example: tool -- gnatls --version")
        command = extra
        exploratory_tool(host, command)
    snapshot = None
    if proof_run is not None:
        workers = "all cores" if proof_run.jobs == 0 else f"{proof_run.jobs} workers"
        if proof_run.full:
            mode = "Cold" if proof_run.cold else "Full"
            print(f"{mode} GNATprove validation ({workers}); native solver cache enabled.", flush=True)
            print(f"Proof evidence: {reports / MANIFEST}", flush=True)
            if proof_run.cold:
                snapshot = begin_proof(host, command, reports, cold=True)
            else:
                snapshot = begin_proof(host, command, reports)
        else:
            invalidate_proof(reports)
            print(f"Incremental GNATprove ({workers}); native solver cache enabled. "
                  "Use prove --full for complete validation.", flush=True)
    invoke(host, alire_command(host, "exec", "--", *command), cwd=host.context)
    if proof_run is not None and proof_run.full:
        audit_sources(host.root / "src", reports, host.generated,
                      effective_command=command)
        complete_proof(host, reports, snapshot)
        invoke(host, [sys.executable, str(host.root / "scripts/check_evidence.py"),
                      "--source-dir", str(host.root / "src"),
                      "--generated-dir", str(host.generated),
                      "--report-dir", str(reports)])
    elif proof_run is not None:
        print("Incremental GNATprove completed.", flush=True)


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"development command: {error}") from error
