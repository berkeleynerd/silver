#!/usr/bin/env python3
"""Prepare an UNVALIDATED four-module line-certificate experiment for #8.

Preparation and --dry-run never execute Lean. --run-pair separately builds the
isolated common closure, then forces the same 512-line/four-chunk candidate and
root to rebuild with 1 and 4 Lake workers. Each Lean process uses one thread as
an intentional measurement control. This is not a complete assurance/audit run.
"""
from __future__ import annotations

import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import signal
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from platforms import native_layout  # noqa: E402
from run_history import ManagedRun, RunHistoryError, status  # noqa: E402

HOST = native_layout(ROOT)
SCRATCH = HOST.artifacts / "line-chunks"
DEFAULT_OUTPUT = SCRATCH / "pilot-ready"
CHUNKS = [f"Silver.OutputBodyLines{i}" for i in range(4)]
MICRO_ROOT = "Silver.OutputBodyLineMicro"
COMMON = ["Silver.SourceLexer", "Silver.CertificateWitness"]
DECLARATION = re.compile(
    rb"def outputBodyTokens_line_(\d+) : LineCertificate where\n"
    rb"  text := ([^\n]+)\n  tokens := ([^\n]+)\n"
    rb"  correct := by decide \+kernel\n  noNewline := by decide \+kernel\n\n")
IMPORT = re.compile(rb"(?m)^(?:public )?(?:meta )?import ([A-Za-z0-9_.]+)\s*$")
AUTHORITATIVE = b"public import Silver.OutputProfileBodySource\n"
PRESSURE_BYTES = 8 * 1024**3


class ExperimentPressureInterrupt(KeyboardInterrupt):
    """Yield experiment resources before production reaches its lower RAM guard."""


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def write_json(path: Path, value) -> None:
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def extract(original: bytes) -> tuple[bytes, list[bytes], bytes]:
    matches = list(DECLARATION.finditer(original))
    if len(matches) != 4915 or [int(m[1]) for m in matches] != list(range(4915)):
        raise ValueError("expected exactly the existing 4,915 ordered line declarations")
    if any(a.end() != b.start() for a, b in zip(matches, matches[1:])):
        raise ValueError("unexpected bytes between line declarations")
    header, suffix = original[:matches[0].start()], original[matches[-1].end():]
    if header.count(AUTHORITATIVE) != 1 or not suffix.startswith(b"def outputBodyTokens_block_0_1 :"):
        raise ValueError("unexpected certificate header or reconstruction boundary")
    if re.findall(rb"(?m)^theorem (outputBodyTokens_\w+)", suffix) != [
            b"outputBodyTokens_source", b"outputBodyTokens_values", b"outputBodyTokens_correct"]:
        raise ValueError("unexpected final theorem set")
    declarations = [m[0] for m in matches]
    if header + b"".join(declarations) + suffix != original:
        raise ValueError("extraction does not recover exact original bytes")
    # Independently recover the actual Ada bytes, including the final newline.
    actual_source = b"\n".join(json.loads(m[2]).encode("ascii") for m in matches)
    if actual_source != (ROOT / "src/silver_output_profile.adb").read_bytes():
        raise ValueError("candidate declarations do not reconstruct this worktree's actual source")
    return header, declarations, suffix


def closure(roots: list[str]) -> dict[Path, bytes]:
    files = {}

    def visit(module: str) -> None:
        if not module.startswith("Silver."):
            return  # Pinned Lean/Std dependencies come from the toolchain only.
        path = ROOT / "proof" / (module.replace(".", "/") + ".lean")
        if path in files:
            return
        files[path] = path.read_bytes()
        for imported in IMPORT.findall(files[path]):
            visit(imported.decode())

    for module in roots:
        visit(module)
    return files


def lakefile(full: bool) -> bytes:
    text = '''import Lake
open Lake DSL

package silverLineExperiment where
  moreLeanArgs := #["-DwarningAsError=true"]
  weakLeanArgs := #["-j1"] ++ (match get_config? silverMemoryMb with
    | some limit => #["-M" ++ limit]
    | none => #[])

@[default_target]
lean_lib Silver
'''
    if full:
        text += '''
input_file outputProfileBodySource where
  path := "../src/silver_output_profile.adb"
  text := false

lean_lib OutputProfileBodySource where
  roots := #[]
  globs := #[.one `Silver.OutputProfileBodySource]
  needs := #[outputProfileBodySource]
'''
    return text.encode()


def tool_path(value: Path | None) -> Path:
    if value is not None:
        return value.resolve()
    common = subprocess.check_output(
        ["git", "-C", str(ROOT), "rev-parse", "--path-format=absolute", "--git-common-dir"],
        text=True).strip()
    candidates = [HOST.lean, Path(common).parent / ".tools" / HOST.key / "lean"]
    return next((p.resolve() for p in candidates if (p / "bin/lean").is_file()), candidates[0])


def tool_hashes(tools: Path) -> dict[str, str]:
    return {name: sha((tools / "bin" / name).read_bytes()) for name in ("lean", "lake", "leanchecker")}


def prepare(output: Path, tools: Path) -> dict:
    original_path = ROOT / "proof/Silver/OutputBodyCertificate.lean"
    original = original_path.read_bytes()
    header, declarations, suffix = extract(original)
    common = closure(COMMON)
    full_inputs = closure([*COMMON, "Silver.OutputProfileBodySource"])
    source = ROOT / "src/silver_output_profile.adb"
    inputs = {**full_inputs, original_path: original, source: source.read_bytes(),
              ROOT / "proof/lean-toolchain": (ROOT / "proof/lean-toolchain").read_bytes(),
              Path(__file__).resolve(): Path(__file__).read_bytes(),
              ROOT / "scripts/run_history.py": (ROOT / "scripts/run_history.py").read_bytes(),
              ROOT / "scripts/platforms.py": (ROOT / "scripts/platforms.py").read_bytes()}
    selected = [i * (len(declarations) - 1) // 511 for i in range(512)]
    chunk_header = header.replace(AUTHORITATIVE, b"")
    imports = b"".join(f"public import {module}\n".encode() for module in CHUNKS)
    payloads = {}
    groups = {}
    for kind, indices, dependencies in (
            ("full", list(range(len(declarations))), full_inputs), ("micro", selected, common)):
        groups[kind] = [indices[len(indices) * i // 4:len(indices) * (i + 1) // 4] for i in range(4)]
        for path, data in dependencies.items():
            payloads[Path(kind) / "proof" / path.relative_to(ROOT / "proof")] = data
        recovered = []
        for module, group in zip(CHUNKS, groups[kind]):
            body = b"".join(declarations[i] for i in group)
            data = chunk_header + body + b"end Silver.Source\n"
            # Re-extract emitted bytes: names, literals and proof bodies all match.
            emitted = [m[0] for m in DECLARATION.finditer(data)]
            if emitted != [declarations[i] for i in group]:
                raise ValueError("emitted chunk differs from original declarations")
            recovered.extend(emitted)
            payloads[Path(kind) / "proof" / (module.replace(".", "/") + ".lean")] = data
        if b"".join(recovered) != b"".join(declarations[i] for i in indices):
            raise ValueError("concatenated chunks do not recover exact original declarations")
        if kind == "full":
            aggregator = header.replace(AUTHORITATIVE, AUTHORITATIVE + imports) + suffix
            if aggregator[len(aggregator) - len(suffix):] != suffix:
                raise ValueError("reconstruction/final-theorem suffix changed")
            payloads[Path(kind) / "proof/Silver/OutputBodyCertificate.lean"] = aggregator
        else:
            payloads[Path(kind) / "proof/Silver/OutputBodyLineMicro.lean"] = b"module\n\n" + imports
        payloads[Path(kind) / "proof/lakefile.lean"] = lakefile(kind == "full")
        payloads[Path(kind) / "proof/lean-toolchain"] = inputs[ROOT / "proof/lean-toolchain"]
    manifest = dict(schema=1, status="UNVALIDATED: complete candidate; no Lean run or audit",
                    repository=str(ROOT), host=HOST.key, tools=str(tools), tools_sha256=tool_hashes(tools),
                    input_sha256={str(p): sha(b) for p, b in inputs.items()},
                    output_sha256={str(p): sha(b) for p, b in payloads.items()},
                    groups=groups, suffix_sha256=sha(suffix), original_sha256=sha(original),
                    checks=dict(exact_declarations=True, exact_reconstruction_and_final_theorems=True,
                                actual_worktree_source=True, micro_includes_first_and_last=True),
                    controls=dict(lake_workers=[1, 4], lean_threads_per_process=1,
                                  budgets="unchanged maxRecDepth 100000 / maxHeartbeats 10000000",
                                  cache="prebuild common once; force all four chunks and root each trial",
                                  no_active_cache_copy=True, full_candidate_formally_accepted=False))
    if (output / "manifest.json").exists():
        if json.loads((output / "manifest.json").read_text()) != manifest:
            raise ValueError("prepared inputs changed; preserve evidence and choose a fresh --output")
        verify(output, manifest)
        return manifest
    if output.exists() and any(output.iterdir()):
        raise ValueError("output must be empty or an identical prepared experiment")
    output.mkdir(parents=True, exist_ok=True)
    (output / "lean").symlink_to(tools, target_is_directory=True)
    for relative, data in payloads.items():
        path = output / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
    # Keep the handwritten binding connected to the actual authoritative bytes.
    (output / "full/src").symlink_to(ROOT / "src", target_is_directory=True)
    write_json(output / "manifest.json", manifest)
    verify(output, manifest)
    return manifest


def verify(output: Path, manifest: dict) -> None:
    for name, digest in manifest["input_sha256"].items():
        if sha(Path(name).read_bytes()) != digest:
            raise ValueError(f"input changed: {name}")
    for name, digest in manifest["output_sha256"].items():
        if (output / name).is_symlink() or sha((output / name).read_bytes()) != digest:
            raise ValueError(f"prepared source changed: {name}")
    if any(p.is_symlink() for p in (output / "micro").rglob("*")):
        raise ValueError("micro experiment sources/cache must not contain links to other workspaces")
    if (output / "lean").resolve() != Path(manifest["tools"]) or tool_hashes(output / "lean") != manifest["tools_sha256"]:
        raise ValueError("pinned tool identity changed")
    if (output / "full/src").resolve() != ROOT / "src":
        raise ValueError("authoritative source link changed")


def host_sample() -> dict:
    fields = dict(line.split(":", 1) for line in Path("/proc/meminfo").read_text().splitlines())
    return dict(available_bytes=int(fields["MemAvailable"].split()[0]) * 1024,
                load_average=list(os.getloadavg()), monotonic_seconds=time.monotonic())


def capacity(exclude_run_id: str = "") -> dict:
    state = status(HOST)
    return dict(free_workers=state["available_cpus"] - state["reserved_workers"],
                other_active_runs=[dict(run_id=r["run_id"], task=r["task"], workers=r["workers"])
                                   for r in state["runs"] if r["active"] and r["run_id"] != exclude_run_id], **host_sample())


@contextmanager
def acquire(output: Path, workers: int, inputs: dict, command: list[str], minimum_gib: int):
    while True:
        observed = capacity()
        if observed["free_workers"] >= 4 and observed["available_bytes"] >= minimum_gib * 1024**3:
            run = ManagedRun(HOST, "lean-experiment", command, inputs, [output], workers=workers,
                             task="#8", reason="Matched line-check measurement: fixed one thread/process; force identical candidate closure", expensive=True)
            try:
                run.__enter__()
            except RunHistoryError as error:
                if not any(s in str(error) for s in ("worker budget unavailable", "resources are held")):
                    raise
            else:
                break
        print(json.dumps(dict(waiting=True, no_reservation_held=True, **observed)), flush=True)
        time.sleep(30)
    try:
        run.event("capacity", observation=observed, minimum_available_gib=minimum_gib)
        yield run
    except BaseException:
        run.__exit__(*sys.exc_info())
        raise
    else:
        run.__exit__(None, None, None)


def environment(output: Path, workers: int) -> dict[str, str]:
    env = {k: v for k, v in os.environ.items()
           if k not in ("LEAN", "LAKE", "ELAN") and not k.startswith(("LEAN_", "LAKE_", "ELAN_"))}
    tools, proof = output / "lean", output / "micro/proof"
    env.update(LEAN=str(tools / "bin/lean"), LEAN_SYSROOT=str(tools),
               LAKE=str(tools / "bin/lake"), LAKE_HOME=str(tools), LAKE_OVERRIDE_LEAN="false",
               LAKE_CONFIG=str(proof / ".lake/system-config.toml"), LAKE_CACHE_DIR=str(proof / ".lake/cache"),
               LAKE_NO_CACHE="true", LAKE_ARTIFACT_CACHE="false", LAKE_RESTORE_ARTIFACTS="false",
               LEAN_NUM_THREADS=str(workers), ELAN="", LC_ALL="C",
               PATH=str(tools / "bin") + os.pathsep + env.get("PATH", ""))
    return env


def command(output: Path, targets: list[str], memory_mb: int) -> list[str]:
    return [str(output / "lean/bin/lake"), "--rehash", "--reconfigure",
            *(["-K", f"silverMemoryMb={memory_mb}"] if memory_mb else []),
            "build", *("+" + module for module in targets)]


def candidate_artifact(path: Path) -> bool:
    return any(path.name.startswith(module.split(".")[-1] + ".") for module in [*CHUNKS, MICRO_ROOT])


def common_artifacts(output: Path) -> dict[str, str]:
    build = output / "micro/proof/.lake/build"
    # Compare loaded/compiled objects. Lake may legitimately rewrite traces,
    # hash sidecars, setup JSON and editor indexes during reconfiguration.
    object_suffixes = (".olean", ".olean.private", ".olean.server", ".ir", ".ir.sig", ".so", ".o", ".a")
    return {str(p.relative_to(build)): sha(p.read_bytes()) for p in sorted(build.rglob("*"))
            if p.is_file() and p.name.endswith(object_suffixes) and not candidate_artifact(p)}


def force_candidate(output: Path) -> list[str]:
    deleted = []
    for path in (output / "micro/proof/.lake/build").rglob("*"):
        if path.is_file() and candidate_artifact(path):
            deleted.append(str(path.relative_to(output)))
            path.unlink()
    return sorted(deleted)


def group_sample(pgid: int) -> dict:
    rss, cpu, pids = 0, 0, []
    for path in Path("/proc").glob("[0-9]*/stat"):
        try:
            fields = path.read_text().rsplit(") ", 1)[1].split()
            if int(fields[2]) == pgid:
                pids.append(int(path.parent.name))
                rss += int(fields[21]) * os.sysconf("SC_PAGE_SIZE")
                cpu += (int(fields[11]) + int(fields[12])) / os.sysconf("SC_CLK_TCK")
        except (OSError, ValueError, IndexError):
            pass  # A process may exit while /proc is sampled.
    return dict(process_group=pgid, pids=pids, group_rss_bytes=rss,
                live_group_cpu_seconds=cpu, **host_sample())


def execute(cmd: list[str], output: Path, evidence: Path, workers: int, run: ManagedRun) -> dict:
    run.event("command", command=cmd, cwd=str(output / "micro/proof"),
              environment_controls=dict(LEAN_NUM_THREADS=workers, lean_process_threads=1))
    peak, minimum = 0, host_sample()["available_bytes"]
    with (evidence / "build.log").open("wb") as log, (evidence / "samples.jsonl").open("w") as samples:
        env = environment(output, workers)
        # Nothing else launches/reaps child tools inside this measurement interval.
        cpu_before = resource.getrusage(resource.RUSAGE_CHILDREN)
        started = time.monotonic()
        process = subprocess.Popen(cmd, cwd=output / "micro/proof", env=env,
                                   stdout=log, stderr=subprocess.STDOUT, start_new_session=True,
                                   pass_fds=run.pass_fds)
        try:
            while True:
                sample = group_sample(process.pid)
                samples.write(json.dumps(sample) + "\n")
                samples.flush()
                peak, minimum = max(peak, sample["group_rss_bytes"]), min(minimum, sample["available_bytes"])
                if sample["available_bytes"] < PRESSURE_BYTES:
                    interruption = dict(outcome="interrupted", reason="host RAM pressure; experiment yields first",
                                        threshold_bytes=PRESSURE_BYTES, sample=sample)
                    raise ExperimentPressureInterrupt("MemAvailable below 8 GiB; stopping only the experiment process group")
                if process.poll() is not None:
                    break
                try:
                    process.wait(timeout=2)
                except subprocess.TimeoutExpired:
                    pass
                else:
                    break
            cpu_after = resource.getrusage(resource.RUSAGE_CHILDREN)
            wall_seconds = time.monotonic() - started
        except BaseException as error:
            # The direct child may already have exited while group descendants
            # remain. Kill the entire disposable group regardless of wait status.
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            process.wait()
            cpu_after = resource.getrusage(resource.RUSAGE_CHILDREN)
            wall_seconds = time.monotonic() - started
            if isinstance(error, ExperimentPressureInterrupt):
                write_json(evidence / "interruption.json", interruption)
                run.event("pressure-interruption", **interruption)
            write_json(evidence / "result.json", dict(
                outcome="interrupted" if isinstance(error, (KeyboardInterrupt, SystemExit)) else "failure",
                error=f"{type(error).__name__}: {error}", returncode=process.returncode,
                wall_seconds=wall_seconds, user_cpu_seconds=cpu_after.ru_utime - cpu_before.ru_utime,
                system_cpu_seconds=cpu_after.ru_stime - cpu_before.ru_stime, sampled_peak_group_rss_bytes=peak,
                sampled_min_available_bytes=minimum))
            raise
    result = dict(returncode=process.returncode, wall_seconds=wall_seconds,
                  user_cpu_seconds=cpu_after.ru_utime - cpu_before.ru_utime,
                  system_cpu_seconds=cpu_after.ru_stime - cpu_before.ru_stime,
                  sampled_peak_group_rss_bytes=peak, sampled_min_available_bytes=minimum,
                  cpu_scope="RUSAGE_CHILDREN deltas; no other child tools inside interval; aggregate RSS is sampled")
    write_json(evidence / "result.json", result)
    if process.returncode:
        raise subprocess.CalledProcessError(process.returncode, cmd)
    return result


def run_pair(output: Path, memory_mb: int, minimum_gib: int) -> None:
    manifest = json.loads((output / "manifest.json").read_text())
    verify(output, manifest)
    if not HOST.key.startswith("linux-"):
        raise ValueError("measurement currently requires native Linux /proc")
    if (output / "pair.json").exists():
        raise ValueError("pair already retained; use a fresh --output for another matched pair")
    pair = []
    baseline = None
    for phase, workers, targets in [("common", 4, COMMON), ("workers-1", 1, [MICRO_ROOT]), ("workers-4", 4, [MICRO_ROOT])]:
        cmd = command(output, targets, memory_mb)
        identity = dict(scope=f"line-chunks-{phase}", manifest_sha256=sha((output / "manifest.json").read_bytes()),
                        controls=dict(workers=workers, threads=1, memory_mb=memory_mb, minimum_available_gib=minimum_gib))
        with acquire(output, workers, identity, cmd, minimum_gib) as run:
            verify(output, manifest)
            evidence = run.directory / "line-chunks"
            evidence.mkdir()
            write_json(evidence / "manifest.json", manifest)
            run.evidence.append(evidence)
            if phase == "common":
                # Version probe belongs to the leased setup, outside timed trials.
                version = subprocess.check_output([str(output / "lean/bin/lean"), "--short-version"],
                                                 env=environment(output, workers), text=True, pass_fds=run.pass_fds).strip()
                pin = (output / "micro/proof/lean-toolchain").read_text().strip().removeprefix("leanprover/lean4:v")
                if version != pin:
                    raise ValueError(f"Lean {version} does not match {pin}")
            else:
                if common_artifacts(output) != baseline:
                    raise ValueError("common compiled inputs changed between trials")
                run.event("force-candidate", removed=force_candidate(output), common_artifacts=baseline)
            run.event("trial-context", stage="start", observation=capacity(run.run_id), measurement_control="one Lean thread per process; -M is not an aggregate or hard OS cap")
            try:
                result = execute(cmd, output, evidence, workers, run)
            finally:
                run.event("trial-context", stage="end", observation=capacity(run.run_id))
            verify(output, manifest)
            after = common_artifacts(output)
            if phase == "common":
                baseline = after
                if not baseline:
                    raise ValueError("common build produced no isolated artifacts")
            elif after != baseline:
                raise ValueError("common compiled inputs changed during trial")
            write_json(evidence / "common-artifacts.json", baseline)
            pair.append(dict(phase=phase, workers=workers, run_id=run.run_id, evidence=str(evidence), **result))
            run.finish(returncode=0, result=result)
    write_json(output / "pair.json", dict(status="microbench only; full candidate remains UNVALIDATED", phases=pair,
               limitations="single ordered pair; host load may vary; no complete audit, fresh kernel replay, or formal acceptance"))
    print(json.dumps(pair, indent=2))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--prepare", action="store_true", help="write scratch full/micro candidates; Python equality checks only")
    modes.add_argument("--dry-run", action="store_true", help="verify preparation and print exact experiment plan; no Lean launch")
    modes.add_argument("--run-pair", action="store_true", help="wait without reservations; then run isolated common setup and matched 1/4-worker trials")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT, help="ignored scratch directory inside this worktree's .silver/<host>/line-chunks")
    parser.add_argument("--tools", type=Path, help="existing pinned Lean distribution, linked read-only; preparation only")
    parser.add_argument("--memory-mb", type=int, default=4096, help="Lean internal per-process allowance, 0 to omit (default: 4096 MiB)")
    parser.add_argument("--min-available-gib", type=int, default=20, help="MemAvailable start gate, minimum 8 (default: 20 GiB)")
    args = parser.parse_args()
    output = args.output.absolute()
    if not output.is_relative_to(SCRATCH) or output == SCRATCH:
        parser.error("--output must be a child of this worktree's dedicated line-chunks scratch directory")
    if any(p.is_symlink() for p in [output, *output.parents] if p.is_relative_to(ROOT)):
        parser.error("--output and its ancestors must not link to other workspaces")
    if args.memory_mb < 0 or args.min_available_gib < 8:
        parser.error("memory allowance must be nonnegative and available-RAM gate at least 8 GiB")
    if args.prepare:
        with ManagedRun(HOST, "lean-experiment", sys.argv, {"scope": "line-chunks-prepare"},
                        [output], workers=0, task="#8", evidence=[output / "manifest.json"]) as run:
            manifest = prepare(output, tool_path(args.tools))
            run.event("python-equality-checks", checks=manifest["checks"], lean_executed=False)
        print(json.dumps(dict(output=str(output), status=manifest["status"], checks=manifest["checks"]), indent=2))
    elif args.dry_run:
        manifest = json.loads((output / "manifest.json").read_text())
        verify(output, manifest)
        print(json.dumps(dict(status=manifest["status"], no_lean_launch=True, capacity=capacity(),
                  start_gate=dict(free_workers=4, available_gib=args.min_available_gib, poll_seconds=30),
                  phases=[dict(phase=p, workers=w, threads=1, command=command(output, t, args.memory_mb))
                          for p, w, t in [("common", 4, COMMON), ("workers-1", 1, [MICRO_ROOT]), ("workers-4", 4, [MICRO_ROOT])]],
                  cache_control=manifest["controls"]["cache"], full_candidate="prepared only; never built by --run-pair"), indent=2))
    else:
        run_pair(output, args.memory_mb, args.min_available_gib)


if __name__ == "__main__":
    try:
        main()
    except ExperimentPressureInterrupt as error:
        raise SystemExit(f"line-chunks: interrupted: {error}") from error
    except (OSError, ValueError, RunHistoryError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"line-chunks: {error}") from error
