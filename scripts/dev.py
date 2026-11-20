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
    from .focused_proof import FocusedProof, focused_workspace, prepare_focused_workspace
    from .run_history import ManagedRun, allocation_report, status, diagnose, checkpoint
    from .platforms import HostLayout, alire_command, native_layout, require_native, tool_environment
else:
    from check_evidence import PROOF_OPTIONS, audit_sources
    from proof_provenance import (MANIFEST, begin_proof, complete_proof, invalidate_proof,
                                  selected_proof_cache, validate_project, preflight, input_hashes, digest, tool_identities, validate_tool_identities)
    from focused_proof import FocusedProof, focused_workspace, prepare_focused_workspace
    from run_history import ManagedRun, allocation_report, status, diagnose, checkpoint
    from platforms import HostLayout, alire_command, native_layout, require_native, tool_environment


def paths(host: HostLayout) -> dict[str, str]:
    return {"host": host.key, "root": str(host.root), "tools": str(host.tools),
            "alr": str(host.alr), "settings": str(host.alire_settings),
            "cache": str(host.alire_cache), "toolchains": str(host.alire_toolchains),
            "artifacts": str(host.artifacts), "context": str(host.context),
            "generated": str(host.generated), "compiler": str(host.compiler),
            "executable": str(host.compiler / "bin/silver"),
            "image_adapter": str(host.image_adapter), "image_tools": str(host.image_tools),
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
            if path.parts and (path.parts[0] in ("explore", "focused") or path.parts[0].startswith("cold-")):
                raise RuntimeError("explore, focused and cold-* subdirectories are reserved; use tool or prove --cold")
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
                if cache.is_relative_to(managed) or cache.is_relative_to(objects / "focused") or cold_cache:
                    raise RuntimeError("exploratory GNATprove must use its own cache, outside audited proof caches")
    if len(subdirectories) != 1:
        raise RuntimeError("exploratory GNATprove requires --subdirs=explore or --subdirs=explore/<name>")
    path = Path(subdirectories[0])
    if path.is_absolute() or not path.parts or path.parts[0] != "explore" or ".." in path.parts:
        raise RuntimeError("exploratory GNATprove requires --subdirs=explore or --subdirs=explore/<name>")
    objects = host.compiler / "obj"
    if (objects / path).resolve().is_relative_to((objects / "focused").resolve()):
        raise RuntimeError("exploratory GNATprove must not use focused proof sessions")


def hash_paths(paths: list[Path]) -> dict[str, str]:
    """Capture declared input bytes, including dirty and untracked source files."""
    result = {}
    for path in paths:
        if not path.exists():
            raise RuntimeError(f"missing declared run input: {path}")
        files = sorted(item for item in path.rglob("*") if item.is_file()) if path.is_dir() else [path]
        for item in files:
            if "__pycache__" not in item.parts:
                result[str(item.resolve())] = digest(item)
    return result


def custom_executable_identity(host: HostLayout, selector: str, *,
                               pass_fds: tuple[int, ...] = ()) -> dict[str, str]:
    """Resolve the original selector in the same Alire environment as execution."""
    resolver = ("import pathlib,shutil,sys; "
                "p=shutil.which(sys.argv[1]); "
                "print('SILVER_EXECUTABLE=' + str(pathlib.Path(p).resolve()) if p else 'SILVER_EXECUTABLE=')")
    resolved = subprocess.run(alire_command(host, "exec", "--", sys.executable,
                              "-c", resolver, selector), cwd=host.context,
                              env=tool_environment(host), check=True, capture_output=True,
                              text=True, pass_fds=pass_fds)
    paths_found = [line.split("=", 1)[1] for line in resolved.stdout.splitlines()
                   if line.startswith("SILVER_EXECUTABLE=")]
    if len(paths_found) != 1 or not paths_found[0]:
        raise RuntimeError("cannot identify custom tool executable")
    executable = Path(paths_found[0])
    return {"path": str(executable), "sha256": digest(executable)}


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


def retain_exploration(run: ManagedRun, destination: str) -> None:
    """Keep custom/standard exploratory outputs, including an interrupted predecessor."""
    retained = run.directory / destination
    for index, root in enumerate(run.failure_reports):
        root = Path(root)
        paths = root.rglob("*") if root.is_dir() else [root]
        for path in paths:
            if path.is_file() and (path.suffix == ".spark" or path.name in ("gnatprove.sarif", "gnatprove.out")):
                relative = path.relative_to(root) if root.is_dir() else Path(path.name)
                target = retained / str(index) / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(path, target)
    if retained.exists():
        run.evidence.append(retained)


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
                           help="reserved workers; 0 allocates available workers (default); "
                                "proof commands need --resource-reason for a count below the available allocation")
        child.add_argument("--resource-reason", default="",
                           help="why this run deliberately reserves fewer workers than are available")
        if action == "prove":
            focus = child.add_mutually_exclusive_group()
            focus.add_argument("--unit", metavar="FILE", help="verify one whole compiler unit")
            focus.add_argument("--subprogram", metavar="FILE:LINE",
                               help="verify the whole subprogram at its declaration")
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
    readout = runs.add_parser("status")
    readout.add_argument("--task", default="")
    readout.add_argument("--limit", type=int, default=20,
                         help="latest completed runs to show, plus all active runs; 0 shows all")
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
            if args.limit < 0:
                parser.error("--limit must be nonnegative")
            result["total_runs"] = len(result["runs"])
            active = [run for run in result["runs"] if run["active"]]
            completed = [run for run in result["runs"] if not run["active"]]
            selected = completed[-args.limit:] if args.limit else completed
            result["omitted_completed_runs"] = len(completed) - len(selected)
            result["runs"] = [*selected, *active]
            result["notes"] = result["notes"][-20:]
            # Keep detailed event streams/input hashes in each durable record;
            # this is the concise readout used at resume.
            summaries = []
            for run in result["runs"]:
                finish = run.get("finish") or {}
                summaries.append({
                    **{key: run[key] for key in ("run_id", "task", "kind", "scope", "state", "active",
                                                "workers", "directory", "fingerprint", "command", "reason")},
                    **({"focused_policy": ("final-policy" if run["inputs"]["focused_options"] == PROOF_OPTIONS
                                            else "different-policy")} if "focused_options" in run["inputs"] else
                       {"focused_policy": "experimental"} if run["inputs"].get("experimental_proof") else {}),
                    **({"focused_report": finish["focused_report"]} if "focused_report" in finish else {}),
                    "worktree": run["worktree"]["resolved"],
                    "resources": [item["resolved"] for item in run["resources"]],
                    "started_at": run["utc"], "finished_at": finish.get("utc"),
                    "duration_seconds": finish.get("duration_seconds"),
                    "returncode": finish.get("returncode"),
                    "error": finish.get("error"), "failure_keys": finish.get("failure_keys", []),
                    "evidence": [item["resolved"] for item in finish.get("evidence", run["evidence"])],
                    "retained_report_count": len(finish.get("retained_reports", [])),
                    **{key: run.get(key) for key in ("allocation", "resource_reductions", "resource_reason")},
                })
            result["runs"] = summaries
        elif args.operation == "diagnose":
            result = diagnose(host, args.run_id, args.summary, args.next_step)
        else:
            result = checkpoint(host, args.task, args.summary, args.next_check)
        print(json.dumps(result, indent=2))
        return
    extra = args.arguments[1:] if args.arguments[:1] == ["--"] else args.arguments
    proof_run = None
    focus = None
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
            focus = FocusedProof.select(args.unit, args.subprogram)
            if focus:
                if proof_run.full or extra:
                    raise RuntimeError("focused proof selects its own scope and output; omit --full, --cold and --subdirs")
                reports = focused_workspace(host.compiler / "obj") / "gnatprove"
                scope = focus.scope()
            if proof_run.cold:
                workspace = host.compiler / "obj" / ("cold-" + uuid.uuid4().hex[:16])
                reports = workspace / "gnatprove"
                # Do not create directories until the run owns its workspace.
            # Reserve the namespace before reading its lock-derived cache key.
            # Missing setup is then a recorded preflight failure under the lease.
            cache = (reports.parent / "cache" if proof_run.cold or focus
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
    declared_inputs = ([Path(path).absolute() for path in args.input]
                       if args.action == "tool" else [])
    executable_selector = None
    query = args.action == "tool" and command[1:] in (["--help"], ["--version"], ["-h"])
    initial = {"scope": scope, "arguments": extra,
               "mode": "cold" if proof_run and proof_run.cold else "full" if proof_run and proof_run.full else args.action}
    if kind == "tool-gnatprove" and not query:
        initial["experimental_proof"] = True
    with ManagedRun(host, kind, command, initial, resources,
                    workers=0 if query else jobs or None, task=args.task, reason=args.reason,
                    resource_reason=args.resource_reason,
                    evidence=[reports] if reports and args.action != "build" else [],
                    failure_reports=[reports] if reports and args.action != "build" else
                    [Path(path).resolve() for path in args.workspace] if args.action == "tool" else []) as run:
        print(f"Managed run: {run.run_id} ({run.directory})", flush=True)
        print(allocation_report(run.record), flush=True)
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
                selected += [host.root / "rosetta" / name
                             for name in ("refresh.py", "manifest.json", "coverage.json")
                             if (host.root / "rosetta" / name).exists()]
                selected += [path for path in (host.compiler / "bin/silver", host.root / "silver.gpr",
                                               host.root / "alire.toml", host.generated, host.context)
                             if path.exists()]
            else:
                # Keep selectors, not a preflight snapshot of symlink targets.
                # hash_paths resolves their files anew at each stability check.
                selected += declared_inputs
                selected += [host.alr, host.context / "alire.toml"]
            inputs = dict(initial, inputs_sha256=hash_paths(selected))
        if args.action == "tool" and args.input and prepared is not None:
            inputs["declared_inputs_sha256"] = hash_paths(declared_inputs)
        if args.action == "tool" and prepared is None and not query:
            identities = tool_identities(host, pass_fds=run.pass_fds)
            validate_tool_identities(host, identities)
            inputs["tools"] = identities
            executable_selector = command[0]
            inputs["executable"] = custom_executable_identity(
                host, executable_selector, pass_fds=run.pass_fds)
        if focus:
            source = host.root / "src" / focus.file
            if not source.is_file():
                source = host.generated / focus.file
            if str(source.relative_to(host.root)) not in prepared["inputs_sha256"]:
                raise RuntimeError(f"unknown compiler proof source: {focus.file}")
            prepare_focused_workspace(reports.parent)
            inputs["focused_options"] = PROOF_OPTIONS
            print(f"Focused final-policy proof: {scope[-1]}", flush=True)
        elif initial.get("experimental_proof"):
            print("Experimental GNATprove run", flush=True)
        run.prepare(inputs, expensive=bool(proof_run and proof_run.full))
        run.event("phase-end", phase="preflight")
        snapshot = None
        if args.action in ("prove", "build"):
            if proof_run:
                cache = selected_proof_cache(host, reports, cold=proof_run.cold)
                policy = PROOF_OPTIONS
                if focus:
                    cache = reports.parent / "cache" / cache.name
                    policy = focus.options(source)
                    extra = [f"--subdirs={reports.parent.relative_to(host.compiler / 'obj')}"]
                cache.mkdir(parents=True, exist_ok=True)
                options = [*policy, "-j", str(run.workers), f"--memcached-server=file:{cache}"]
                if proof_run.full or focus:
                    options.append("-f")
                if proof_run.cold:
                    extra = [f"--subdirs={reports.parent.name}"]
            else:
                options = ["-p", f"-j{run.workers}"]
            command = ["gnatprove" if proof_run else "gprbuild", "-P", "../../../silver.gpr",
                       *options, *extra, f"-XSILVER_HOST={host.key}"]
        elif args.action == "tool" and Path(command[0]).name in ("gnatprove", "gprbuild") and not query:
            command += [f"-j{run.workers}"]
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
                if focus:
                    # Preserve reusable solver sessions but require newly generated summaries.
                    for summary in prior:
                        summary.unlink(missing_ok=True)
        if kind == "tool-gnatprove":
            retain_exploration(run, "previous-reports")
        run.event("phase-start", phase="test" if args.action == "test" else "native-tool")
        invoke(host, actual, cwd=None if args.action == "test" else host.context, pass_fds=run.pass_fds, log=log)
        run.event("phase-end", phase="test" if args.action == "test" else "native-tool", returncode=0)
        if (focus or kind == "tool-gnatprove") and run.unresolved_obligations():
            run.finish("failure", returncode=0, error="GNATprove returned unresolved proof obligations")
            raise RuntimeError("GNATprove returned unresolved proof obligations; see retained run reports")
        if focus:
            focused_report = focus.check_report(reports, command)
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
        if "declared_inputs_sha256" in inputs and hash_paths(declared_inputs) != inputs["declared_inputs_sha256"]:
            raise RuntimeError("declared run inputs changed during execution")
        if kind == "tool-gnatprove":
            retain_exploration(run, "exploratory-evidence")
        if focus:
            retain_exploration(run, "focused-evidence")
            run.finish("success", returncode=0, focused_report=focused_report)
        if executable_selector is not None and custom_executable_identity(
                host, executable_selector, pass_fds=run.pass_fds) != inputs["executable"]:
            raise RuntimeError("custom tool executable changed during execution")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"development command: {error}") from error
