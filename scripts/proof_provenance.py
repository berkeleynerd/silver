"""Content-bound development proof evidence. This is outside Silver admission."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import subprocess
import sys

if __package__:
    from .platforms import HostLayout, alire_command, tool_environment
    from .check_evidence import EvidenceError, PROOF_OPTIONS, read_json, require, source_tokens
else:
    from platforms import HostLayout, alire_command, tool_environment
    from check_evidence import EvidenceError, PROOF_OPTIONS, read_json, require, source_tokens

MANIFEST = "proof-provenance.json"
# Complete reviewed project token shape, including all source/output selection
# and compiler switches. Hashing a changed project as an input is not approval
# to add configuration pragmas, per-file switches, or different source roots.
REVIEWED_PROJECT_SHA256 = "0c3200cd7a057a7cfb0b8a622c693c17e56d7c0c4d6542be9fe45717384e4abf"


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def proof_cache(host: HostLayout) -> Path:
    """Native GNATprove cache, separated when Alire selects new releases.

    GNATprove owns cache matching and validity. The lock digest supplies only
    a local namespace; it is not an attestation of cached proof results.
    """
    lock = host.context / "alire/alire.lock"
    require(lock.is_file(), "missing native toolchain lock; run scripts/bootstrap.py")
    return host.artifacts / "proof-cache/gnatprove" / digest(lock)


def selected_proof_cache(host: HostLayout, report_dir: Path, *, cold: bool) -> Path:
    """A cold run owns a fresh object directory and a private sibling cache."""
    if not cold:
        return proof_cache(host)
    workspace = report_dir.parent
    require(report_dir.name == "gnatprove" and workspace.parent == host.compiler / "obj"
            and workspace.name.startswith("cold-") and len(workspace.name) > len("cold-"),
            "cold proof must use an isolated native object directory")
    return workspace / "cache"


def invalidate_proof(report_dir: Path) -> None:
    """A development run must not leave an earlier full-success claim behind."""
    (report_dir / MANIFEST).unlink(missing_ok=True)


def input_hashes(host: HostLayout) -> dict[str, str]:
    required = [host.root / "silver.gpr", host.root / "alire.toml",
                host.context / "alire.toml", host.context / "alire/alire.lock",
                host.generated / "silver_build.ads"]
    for path in required:
        require(path.is_file(), f"missing proof input: {path}")
    paths = set(required)
    for directory, suffixes in ((host.root / "src", {".ads", ".adb"}),
                                (host.generated, {".ads", ".adb"}),
                                (host.root / "scripts", {".py"}),
                                (host.alire_settings, {".toml"}),
                                (host.context / "alire", {".toml"})):
        paths.update(path for path in directory.rglob("*") if path.is_file() and path.suffix in suffixes)
    return {str(path.relative_to(host.root)): digest(path) for path in sorted(paths)}


def tool_identities(host: HostLayout) -> dict:
    # Resolve the exact executables in the same sanitized Alire environment as
    # the proof invocation; never infer tools from whatever happens to be on PATH.
    program = '''import json, pathlib, shutil, subprocess, sys
tools = {}
for name in ("gnatprove", "gnatls", "gcc", "gprbuild"):
    executable = shutil.which(name)
    if executable is None: raise RuntimeError("missing " + name)
    result = subprocess.run([executable, "--version"], check=True, capture_output=True, text=True)
    tools[name] = {"path": str(pathlib.Path(executable).resolve()), "version": result.stdout + result.stderr}
support = pathlib.Path(tools["gnatprove"]["path"]).parent.parent / "libexec/spark/bin"
for name in ("cvc5", "z3", "alt-ergo", "gnat2why", "gnatwhy3", "why3server"):
    path = support / name
    if not path.is_file(): raise RuntimeError("missing " + str(path))
    tools[name] = {"path": str(path.resolve())}
    if name in ("cvc5", "z3", "alt-ergo"):
        result = subprocess.run([str(path), "--version"], check=True, capture_output=True, text=True)
        tools[name]["version"] = result.stdout + result.stderr
tools["python"] = {"path": str(pathlib.Path(sys.executable).resolve()), "version": sys.version}
print("SILVER_TOOLS_JSON=" + json.dumps(tools, sort_keys=True))
'''
    result = subprocess.run(alire_command(host, "exec", "--", sys.executable, "-c", program),
                            cwd=host.context, env=tool_environment(host), check=True,
                            text=True, capture_output=True)
    lines = [line for line in result.stdout.splitlines() if line.startswith("SILVER_TOOLS_JSON=")]
    require(len(lines) == 1, "tool identification did not return an unambiguous result")
    identities = json.loads(lines[0].split("=", 1)[1])
    alire_version = subprocess.run([str(host.alr), "--version"], cwd=host.context,
                                   env=tool_environment(host), check=True, text=True, capture_output=True)
    identities["alr"] = {"path": str(host.alr.resolve()),
                          "version": alire_version.stdout + alire_version.stderr}
    for identity in identities.values():
        identity["sha256"] = digest(Path(identity["path"]))
        if "version" in identity:
            identity["version_sha256"] = hashlib.sha256(identity["version"].encode()).hexdigest()
    return identities


def validate_project(host: HostLayout) -> None:
    tokens = source_tokens(host.root / "silver.gpr")
    actual = hashlib.sha256("".join(tokens).encode("ascii")).hexdigest()
    require(actual == REVIEWED_PROJECT_SHA256,
            "project differs from the reviewed source selection and check configuration")


def begin_proof(host: HostLayout, command: list[str], report_dir: Path, *, cold: bool = False) -> dict:
    validate_project(host)
    cache = selected_proof_cache(host, report_dir, cold=cold)
    initial_state = {
        "sessions_present": any(report_dir.rglob("why3session.xml")),
        "cache_entries_present": cache.exists() and any(cache.iterdir()),
    }
    if cold:
        require(not any(initial_state.values()), "cold proof must start without sessions or cached results")
    report_dir.mkdir(parents=True, exist_ok=True)
    invalidate_proof(report_dir)
    # No earlier unit summary may fill a hole left by this invocation.
    for path in [*report_dir.glob("*.spark"), report_dir / "gnatprove.sarif", report_dir / "gnatprove.out"]:
        path.unlink(missing_ok=True)
    snapshot = {"schema": 1, "host": host.key, "command": command,
                "mode": "cold" if cold else "full", "initial_state": initial_state,
                "inputs_sha256": input_hashes(host), "tools": tool_identities(host)}
    (report_dir / "proof-inputs.json").write_text(json.dumps(snapshot, indent=2) + "\n")
    return snapshot


def report_hashes(report_dir: Path) -> dict[str, str]:
    paths = [*report_dir.glob("*.spark"), report_dir / "gnatprove.sarif", report_dir / "gnatprove.out"]
    return {path.name: digest(path) for path in sorted(paths)}


def complete_proof(host: HostLayout, report_dir: Path, snapshot: dict) -> None:
    require(input_hashes(host) == snapshot["inputs_sha256"], "proof inputs changed during verification")
    require(tool_identities(host) == snapshot["tools"], "proof tools changed during verification")
    manifest = dict(snapshot, complete=True, reports_sha256=report_hashes(report_dir))
    validate_provenance(host, report_dir, manifest)
    (report_dir / MANIFEST).write_text(json.dumps(manifest, indent=2) + "\n")


def validate_provenance(host: HostLayout, report_dir: Path, manifest: dict | None = None) -> dict:
    report_dir = report_dir.resolve()
    manifest = read_json(report_dir / MANIFEST) if manifest is None else manifest
    require(manifest.get("schema") == 1 and manifest.get("complete") is True,
            "missing completed content-bound proof provenance")
    require(manifest.get("host") == host.key, "proof provenance belongs to a different host")
    mode = manifest.get("mode")
    require(mode in ("full", "cold"), "missing proof validation mode")
    initial_state = manifest.get("initial_state", {})
    require(isinstance(initial_state, dict)
            and initial_state.keys() == {"sessions_present", "cache_entries_present"}
            and all(type(value) is bool for value in initial_state.values()),
            "missing initial proof session/cache state")
    require(mode != "cold" or not any(initial_state.values()),
            "cold proof did not start without sessions or cached results")
    validate_project(host)
    require(manifest.get("inputs_sha256") == input_hashes(host), "proof input hashes changed; rerun GNATprove")
    require(manifest.get("reports_sha256") == report_hashes(report_dir), "proof report hashes changed")
    for name, identity in manifest.get("tools", {}).items():
        require(name == "python" or Path(identity["path"]).is_relative_to(host.tools),
                f"proof tool is outside the selected native tool directory: {name}")
        require(digest(Path(identity["path"])) == identity["sha256"], f"proof tool changed: {name}")
        if "version" in identity:
            require(hashlib.sha256(identity["version"].encode()).hexdigest() == identity["version_sha256"],
                    f"proof version record changed: {name}")
        require(name in {"gnat2why", "gnatwhy3", "why3server"} or bool(identity.get("version")),
                f"missing proof tool version: {name}")
    require({"gnatprove", "gnatls", "gcc", "gprbuild", "cvc5", "z3", "alt-ergo",
             "gnat2why", "gnatwhy3", "why3server", "python", "alr"} == manifest.get("tools", {}).keys(),
            "incomplete proof tool identities")
    command = manifest.get("command", [])
    require(isinstance(command, list) and command[:3] == ["gnatprove", "-P", "../../../silver.gpr"],
            "unexpected proof project/command")
    require(command[3:3 + len(PROOF_OPTIONS)] == PROOF_OPTIONS, "unreviewed effective proof options")
    require(command[-1:] == [f"-XSILVER_HOST={host.key}"], "proof invocation host mismatch")
    # Scheduling and native result caching do not change the obligation policy.
    # Full evidence must still force analysis of every unit and cover all reports.
    remaining = command[3 + len(PROOF_OPTIONS):-1]
    require(len(remaining) >= 4 and remaining[0] == "-j"
            and isinstance(remaining[1], str) and remaining[1].isascii()
            and remaining[1].isdecimal(), "invalid full-proof worker count")
    cache = selected_proof_cache(host, report_dir, cold=mode == "cold")
    require(remaining[2] == f"--memcached-server=file:{cache}",
            "full proof must use the selected native cache")
    require(remaining[3] == "-f", "full proof must force analysis of every unit")
    remaining = remaining[4:]
    # Only output subdirectories may follow the full-proof controls.
    selected_reports = host.compiler / "obj/gnatprove"
    while remaining:
        argument = remaining.pop(0)
        if argument == "--subdirs":
            require(bool(remaining), "missing proof subdirectory")
            value = remaining.pop(0)
        else:
            require(argument.startswith("--subdirs="), f"unreviewed proof switch: {argument}")
            value = argument.split("=", 1)[1]
        require(value and not Path(value).is_absolute() and ".." not in Path(value).parts,
                "invalid proof output subdirectory")
        parts = Path(value).parts
        require(not parts or (parts[0] != "explore"
                and (mode == "cold" or not parts[0].startswith("cold-"))),
                "reserved proof output subdirectory")
        selected_reports = host.compiler / "obj" / value / "gnatprove"
    require(selected_reports == report_dir, "proof report directory differs from the selected output")
    invocation = read_json(report_dir / "gnatprove.sarif")["runs"][0]["invocations"][0]
    # GNATprove's SARIF field is a literal space join, not a shell command.
    # Compare to the captured argv's producer representation rather than
    # attempting to parse ambiguous quoting/whitespace in installation paths.
    require(invocation["commandLine"] == " ".join(command),
            "recorded GNATprove invocation differs from the approved effective configuration")
    return manifest
