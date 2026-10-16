#!/usr/bin/env python3
"""Run native development tools in the current host's isolated workspace.

Silver source admission, compilation, and execution belong to the SPARK binary;
this helper builds and verifies that compiler and runs its development tests.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass, field
import json
import os
import shutil
from pathlib import Path
import subprocess
import sys
import uuid

if __package__:
    from .check_evidence import PROOF_OPTIONS, audit_sources
    from .proof_provenance import (MANIFEST, begin_proof, complete_proof, invalidate_proof,
                                   selected_proof_cache, validate_project, preflight, input_hashes, digest, tool_identities, validate_tool_identities)
    from .run_history import ManagedRun, status, diagnose, checkpoint
    from .platforms import HostLayout, alire_command, native_layout, require_native, tool_environment
else:
    from check_evidence import PROOF_OPTIONS, audit_sources
    from proof_provenance import (MANIFEST, begin_proof, complete_proof, invalidate_proof,
                                  selected_proof_cache, validate_project, preflight, input_hashes, digest, tool_identities, validate_tool_identities)
    from run_history import ManagedRun, status, diagnose, checkpoint
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


def invoke(host: HostLayout, command: list[str], *, cwd: Path | None = None,
           pass_fds: tuple[int, ...] = (), log: Path | None = None) -> None:
    require_native(host)
    options = dict(cwd=host.root if cwd is None else cwd,
                   env=tool_environment(host) if cwd == host.context else None,
                   pass_fds=pass_fds)
    if log is None:
        subprocess.run(command, check=True, **options)
        return
    with log.open("a", encoding="utf-8") as stream:
        with subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                              text=True, errors="replace", **options) as process:
            assert process.stdout is not None
            for line in process.stdout:
                stream.write(line)
                stream.flush()
                print(line, end="", flush=True)
            result = process.wait()
            if result:
                raise subprocess.CalledProcessError(result, command)


def project_reports(host: HostLayout, arguments: list[str]) -> Path:
    """Validate optional native build flags before a tool can write anything."""
    reports = host.compiler / "obj/gnatprove"
    redirects = ("-P", "--project", "--relocate-build-tree", "--root-dir",
                 "--object-dir", "--exec-dir", "--src-subdirs", "--config",
                 "--autoconf", "--db", "--target", "-o", "-cargs", "-bargs", "-largs")
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
        raise ValueError("jobs must be a nonnegative integer (0 allocates available workers)")
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



def hash_paths(paths: list[Path]) -> dict[str, str]:
    """Capture declared input bytes, including dirty and untracked source files."""
    result = {}
    for path in paths:
        if not path.exists():
            raise RuntimeError(f"missing declared run input: {path}")
        files = sorted(item for item in path.rglob("*") if item.is_file()) if path.is_dir() else [path]
        for item in files:
            if "__pycache__" not in item.parts:
                result[str(item)] = digest(item)
    return result


def scheduled_arguments(arguments: list[str], requested: int) -> tuple[list[str], int]:
    """Resolve one worker declaration instead of letting a forwarded -j override it."""
    result = []
    index = 0
    while index < len(arguments):
        argument = arguments[index]
        if argument in ("-j", "--jobs"):
            index += 1
            if index == len(arguments):
                raise RuntimeError("jobs requires a nonnegative integer")
            requested = worker_count(arguments[index])
        elif argument.startswith("--jobs="):
            requested = worker_count(argument.split("=", 1)[1])
        elif argument.startswith("-j"):
            requested = worker_count(argument[2:])
        else:
            result.append(argument)
        index += 1
    return result, requested


def tool_resources(host: HostLayout, command: list[str], workspaces: list[str],
                   declared_inputs: list[str]) -> tuple[list[Path], Path | None, bool]:
    """Infer only the reviewed project. Arbitrary GPRs need declared outputs/inputs."""
    if command[1:] in (["--version"], ["--help"], ["-h"]):
        return [host.context], None, False
    projects = []
    redirect = False
    for index, argument in enumerate(command[1:], 1):
        if argument in ("-P", "--project"):
            if index + 1 >= len(command):
                raise RuntimeError("project requires a path")
            projects.append(command[index + 1])
        elif argument.startswith("-P"):
            projects.append(argument[2:])
        elif argument.startswith("--project="):
            projects.append(argument.split("=", 1)[1])
        if argument.startswith(("--relocate-build-tree", "--root-dir", "--object-dir", "--exec-dir",
                                "--src-subdirs", "--config", "--autoconf", "--db", "--target",
                                "-o", "-cargs", "-bargs", "-largs")):
            redirect = True
        if argument.startswith("-X") and argument != f"-XSILVER_HOST={host.key}":
            redirect = True
    standard = (command[0] in ("gnatprove", "gprbuild") and len(projects) == 1
                and (host.context / projects[0]).resolve() == host.root / "silver.gpr"
                and f"-XSILVER_HOST={host.key}" in command and not redirect)
    resources = [host.context, *(Path(path).resolve() for path in workspaces)]
    reports = None
    if standard:
        subdirs = []
        for index, argument in enumerate(command):
            if argument == "--subdirs":
                subdirs.extend([argument, command[index + 1]])
            elif argument.startswith("--subdirs="):
                subdirs.append(argument)
        reports = project_reports(host, subdirs)
        relative = reports.parent.relative_to(host.compiler / "obj")
        resources.extend([reports.parent, host.compiler / "bin" / relative,
                          host.artifacts / "proof-containers/obj" / relative])
    elif not workspaces or not declared_inputs:
        raise RuntimeError("custom tool runs require --workspace and --input declarations; "
                           "list actual writable roots and source/configuration inputs")
    # A custom local solver cache is writable even outside the object tree.
    for index, argument in enumerate(command):
        if argument == "--memcached-server" and index + 1 < len(command):
            value = command[index + 1]
        elif argument.startswith("--memcached-server="):
            value = argument.split("=", 1)[1]
        else:
            continue
        if value.startswith("file:"):
            resources.append((host.context / value[5:]).resolve())
    return resources, reports, standard


def proof_scope(command: list[str]) -> list[str]:
    targets = []
    mode = "all"
    for index, argument in enumerate(command[1:], 1):
        if argument in ("-P", "--project") and index + 1 < len(command):
            targets.append("project:" + command[index + 1])
        elif argument.startswith("-P"):
            targets.append("project:" + argument[2:])
        elif argument.startswith("--project="):
            targets.append("project:" + argument.split("=", 1)[1])
        elif argument == "--mode" and index + 1 < len(command):
            mode = command[index + 1]
        elif argument.startswith("--mode="):
            mode = argument.split("=", 1)[1]
        elif argument.startswith("--limit-"):
            targets.append(argument if "=" in argument else
                           argument + "=" + (command[index + 1] if index + 1 < len(command) else ""))
        elif argument.endswith((".adb", ".ads")):
            targets.append(argument)
    return ["mode:" + mode, *(targets or ["compiler"])]


def main(arguments: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="action", required=True)
    for action in ("prove", "build", "test", "tool"):
        child = commands.add_parser(action)
        child.add_argument("--task", default=os.environ.get("SILVER_TASK", ""))
        child.add_argument("--reason", default="")
        child.add_argument("--jobs", "-j", type=worker_count, default=0,
                           help="reserved workers; 0 allocates available workers (default)")
        if action == "prove":
            child.add_argument("--full", "-f", action="store_true",
                               help="force all units and audit complete proof evidence")
            child.add_argument("--cold", action="store_true",
                               help="full audit with fresh isolated objects, sessions and solver cache")
        if action == "tool":
            child.add_argument("--workspace", action="append", default=[],
                               help="actual writable root of a custom tool run (repeatable)")
            child.add_argument("--input", action="append", default=[],
                               help="custom source/configuration input file or directory (repeatable)")
        child.add_argument("arguments", nargs=argparse.REMAINDER)
    path_parser = commands.add_parser("paths")
    path_parser.add_argument("--field", help="print one path instead of JSON")
    runs = commands.add_parser("runs").add_subparsers(dest="operation", required=True)
    runs.add_parser("status").add_argument("--task", default="")
    diagnostic = runs.add_parser("diagnose")
    diagnostic.add_argument("run_id")
    diagnostic.add_argument("--summary", required=True)
    diagnostic.add_argument("--next-step", required=True)
    note = runs.add_parser("checkpoint")
    note.add_argument("--task", default=os.environ.get("SILVER_TASK", ""))
    note.add_argument("--summary", required=True)
    note.add_argument("--next-check", required=True)
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
    if args.action == "runs":
        if args.operation == "status":
            result = status(host, args.task)
            # Keep detailed event streams/input hashes in each durable record;
            # this is the concise readout used at resume.
            result["runs"] = [{key: value for key, value in run.items()
                               if key not in ("events", "inputs")}
                              for run in result["runs"]]
        elif args.operation == "diagnose":
            result = diagnose(host, args.run_id, args.summary, args.next_step)
        else:
            result = checkpoint(host, args.task, args.summary, args.next_check)
        print(json.dumps(result, indent=2))
        return
    extra = args.arguments[1:] if args.arguments[:1] == ["--"] else args.arguments
    proof_run = None
    reports = None
    cache = None
    standard = False
    jobs = args.jobs
    kind = args.action
    scope = ["compiler"]
    if args.action == "test":
        command = [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v", *extra]
        resources = [host.artifacts]
        scope = extra or ["all-tests"]
    elif args.action in ("prove", "build"):
        reports = project_reports(host, extra)
        if args.action == "prove":
            proof_run = proof_arguments(extra, full=args.full, cold=args.cold, jobs=jobs)
            extra, jobs = proof_run.arguments, proof_run.jobs
            if proof_run.cold:
                workspace = host.compiler / "obj" / ("cold-" + uuid.uuid4().hex[:16])
                reports = workspace / "gnatprove"
                # Do not create directories until the run owns its workspace.
            # Reserve the namespace before reading its lock-derived cache key.
            # Missing setup is then a recorded preflight failure under the lease.
            cache = (reports.parent / "cache" if proof_run.cold
                     else host.artifacts / "proof-cache/gnatprove")
        else:
            extra, jobs = scheduled_arguments(extra, jobs)
        relative = reports.parent.relative_to(host.compiler / "obj")
        resources = [host.context, reports.parent, host.compiler / "bin" / relative,
                     host.artifacts / "proof-containers/obj" / relative]
        if cache is not None:
            resources.append(cache)
        command = ["gnatprove" if proof_run else "gprbuild", *extra]
        standard = True
    else:
        if not extra:
            parser.error("tool requires a command; for example: tool -- gnatls --version")
        command = extra
        exploratory_tool(host, command)
        resources, reports, standard = tool_resources(host, command, args.workspace, args.input)
        kind = "tool-" + Path(command[0]).name
        scope = proof_scope(command)
        if Path(command[0]).name in ("gnatprove", "gprbuild") and command[1:] not in (["--help"], ["--version"], ["-h"]):
            tail, jobs = scheduled_arguments(command[1:], jobs)
            command = [command[0], *tail]
    query = args.action == "tool" and command[1:] in (["--help"], ["--version"], ["-h"])
    initial = {"scope": scope, "arguments": extra,
               "mode": "cold" if proof_run and proof_run.cold else "full" if proof_run and proof_run.full else args.action}
    with ManagedRun(host, kind, command, initial, resources,
                    workers=0 if query else jobs or None, task=args.task, reason=args.reason,
                    evidence=[reports] if reports else [], failure_reports=[reports] if reports else
                    [Path(path).resolve() for path in args.workspace] if args.action == "tool" else []) as run:
        print(f"Managed run: {run.run_id} ({run.directory})", flush=True)
        if args.action != "test" and (not host.alr.is_file() or not (host.context / "alire.toml").is_file()):
            raise RuntimeError("native toolchain is not set up; run python3 scripts/bootstrap.py")
        log = run.directory / "native.log"
        run.evidence.append(log)
        run.event("phase-start", phase="preflight")
        prepared = preflight(host, pass_fds=run.pass_fds) if standard else None
        if prepared is not None:
            inputs = dict(initial, **prepared)
        else:
            selected = [host.root / "scripts", Path(sys.executable).resolve()]
            if args.action == "test":
                selected += [host.root / item for item in ("tests", "src", "proof", "samples", "catalogue")
                             if (host.root / item).exists()]
                selected += [path for path in (host.compiler / "bin/silver", host.root / "silver.gpr",
                                               host.root / "alire.toml", host.generated, host.context)
                             if path.exists()]
            else:
                selected += [Path(path).resolve() for path in args.input]
                selected += [host.alr, host.context / "alire.toml"]
            inputs = dict(initial, inputs_sha256=hash_paths(selected))
        if args.action == "tool" and args.input and prepared is not None:
            inputs["declared_inputs_sha256"] = hash_paths([Path(path).resolve() for path in args.input])
        if args.action == "tool" and prepared is None and not query:
            identities = tool_identities(host, pass_fds=run.pass_fds)
            validate_tool_identities(host, identities)
            inputs["tools"] = identities
            # Arbitrary tool executables are not identified by their basename.
            resolver = ("import pathlib,shutil,sys; "
                        "p=shutil.which(sys.argv[1]); "
                        "print('SILVER_EXECUTABLE=' + str(pathlib.Path(p).resolve()) if p else 'SILVER_EXECUTABLE=')")
            resolved = subprocess.run(alire_command(host, "exec", "--", sys.executable,
                                      "-c", resolver, command[0]), cwd=host.context,
                                      env=tool_environment(host), check=True, capture_output=True,
                                      text=True, pass_fds=run.pass_fds)
            paths_found = [line.split("=", 1)[1] for line in resolved.stdout.splitlines()
                           if line.startswith("SILVER_EXECUTABLE=")]
            if len(paths_found) != 1 or not paths_found[0]:
                raise RuntimeError("cannot identify custom tool executable")
            executable = Path(paths_found[0])
            inputs["executable"] = {"path": str(executable), "sha256": digest(executable)}
        run.prepare(inputs, expensive=bool(proof_run and proof_run.full))
        run.event("phase-end", phase="preflight")
        snapshot = None
        if args.action in ("prove", "build"):
            if proof_run:
                cache = selected_proof_cache(host, reports, cold=proof_run.cold)
                cache.mkdir(parents=True, exist_ok=True)
                options = [*PROOF_OPTIONS, "-j", str(run.workers), f"--memcached-server=file:{cache}"]
                if proof_run.full:
                    options.append("-f")
                if proof_run.cold:
                    extra = [f"--subdirs={reports.parent.name}"]
            else:
                options = ["-p", "-j", str(run.workers)]
            command = ["gnatprove" if proof_run else "gprbuild", "-P", "../../../silver.gpr",
                       *options, *extra, f"-XSILVER_HOST={host.key}"]
        elif args.action == "tool" and Path(command[0]).name in ("gnatprove", "gprbuild") and not query:
            command += ["-j", str(run.workers)]
        actual = command if args.action == "test" else alire_command(host, "exec", "--", *command)
        run.event("command", command=actual, cwd=str(host.root if args.action == "test" else host.context))
        if proof_run:
            # Preserve outputs of an interrupted or earlier run before summaries
            # or its completed manifest can be replaced by this invocation.
            prior = [*reports.glob("*.spark"), reports / "gnatprove.sarif",
                     reports / "gnatprove.out", reports / MANIFEST, reports / "proof-inputs.json"]
            for source in prior:
                if source.is_file():
                    destination = run.directory / "previous-reports" / source.name
                    destination.parent.mkdir(exist_ok=True)
                    shutil.copy2(source, destination)
            if (run.directory / "previous-reports").exists():
                run.evidence.append(run.directory / "previous-reports")
            if proof_run.full:
                snapshot = begin_proof(host, command, reports, cold=proof_run.cold, prepared=prepared)
                print(f"Full GNATprove evidence: {reports / MANIFEST}", flush=True)
                run.evidence.append(reports / MANIFEST)
            else:
                invalidate_proof(reports)
        run.event("phase-start", phase="test" if args.action == "test" else "native-tool")
        invoke(host, actual, cwd=None if args.action == "test" else host.context, pass_fds=run.pass_fds, log=log)
        run.event("phase-end", phase="test" if args.action == "test" else "native-tool")
        if proof_run and proof_run.full:
            run.event("phase-start", phase="audit")
            audit_sources(host.root / "src", reports, host.generated, effective_command=command)
            complete_proof(host, reports, snapshot, pass_fds=run.pass_fds)
            invoke(host, [sys.executable, str(host.root / "scripts/check_evidence.py"),
                          "--source-dir", str(host.root / "src"), "--generated-dir", str(host.generated),
                          "--report-dir", str(reports)], pass_fds=run.pass_fds, log=log)
            retained = run.directory / "proof-evidence"
            retained.mkdir()
            for source in [*reports.glob("*.spark"), reports / "gnatprove.sarif",
                           reports / "gnatprove.out", reports / MANIFEST, reports / "proof-inputs.json"]:
                if source.is_file():
                    shutil.copy2(source, retained / source.name)
            run.evidence.append(retained)
            run.event("phase-end", phase="audit")
        elif prepared is not None:
            if input_hashes(host) != prepared["inputs_sha256"]:
                raise RuntimeError("run inputs changed during execution; retain outputs and rerun the affected check")
        else:
            if hash_paths(selected) != inputs["inputs_sha256"]:
                raise RuntimeError("declared run inputs changed during execution")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"development command: {error}") from error
