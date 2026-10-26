#!/usr/bin/env python3
"""Export chosen completed Silver guard checks; never selects the latest run.

`focused` and `inspect` only read evidence. `delivery` reuses the fresh auditor
invocation inside the chosen full native run. An explicit --audit-source fresh
runs check_evidence.py once more; no proof/build/test runner is launched here.
See README.md beside this file.
"""
from __future__ import annotations

import argparse
import ast
from datetime import datetime, timezone
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import time


PROFILE_SHA = "ec2f0a72dcbdcf1ff6dadc9fb8ec2975653a8c0c11db2bf3d53b7a5b8dec3a3d"
FOCUSED_RUN = "20261026T083814-1b657c3ee2da"
RENDERER = {"rosetta/refresh.py", "rosetta/coverage.json", "rosetta/manifest.json"}
OWNED = Path(__file__).resolve().parent
REPOSITORY = OWNED.parents[1]


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def json_bytes(value):
    return (json.dumps(value, indent=2, sort_keys=True) + "\n").encode()


def utc():
    return datetime.now(timezone.utc).isoformat()


def instant(value):
    result = datetime.fromisoformat(value)
    require(result.tzinfo is not None, "timestamp has no time zone")
    return result


def one(rows, event, **fields):
    found = [row for row in rows if row.get("event") == event and
             all(row.get(key) == value for key, value in fields.items())]
    require(len(found) == 1, f"expected one {event} {fields}, found {len(found)}")
    return found[0]


def command(value):
    require(isinstance(value, list) and bool(value) and
            all(isinstance(item, str) and bool(item) for item in value), "empty/invalid command")
    return value


def hashes(value):
    require(isinstance(value, dict) and bool(value), "empty input capture")
    require(all(isinstance(k, str) and re.fullmatch(r"[0-9a-f]{64}", v)
                for k, v in value.items()), "invalid captured input hashes")
    return value


class Export:
    def __init__(self, args):
        self.args = args
        self.root = args.root.resolve()
        self.target = self.git("rev-parse", args.target + "^{commit}").decode().strip()
        self.tracked = set(self.git("ls-tree", "-r", "--name-only", self.target).decode().splitlines())
        self.cache = {}
        self.out = args.out.resolve()
        self.artifacts = {}
        require(sha(self.blob("src/silver_output_profile.adb")) == PROFILE_SHA,
                "target does not contain the frozen v18 profile")

    def git(self, *arguments):
        return subprocess.check_output(["git", "-C", str(self.root), *arguments])

    def blob(self, path):
        if path not in self.cache:
            self.cache[path] = self.git("show", self.target + ":" + path)
        return self.cache[path]

    def retain(self, path, data):
        if self.args.mode == "inspect":
            return {"inspection_only": True, "would_retain": path + ".gz",
                    "sha256": sha(data), "bytes": len(data)}
        compressed = gzip.compress(data, mtime=0)
        destination = self.out / (path + ".gz")
        # Identical retries may reuse evidence; never silently overwrite it.
        if destination.exists():
            require(destination.read_bytes() == compressed, "existing export differs: " + str(destination))
        else:
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(compressed)
        item = {"path": str(destination.relative_to(self.out)), "sha256": sha(data),
                "compressed_sha256": sha(compressed), "bytes": len(data)}
        self.artifacts[item["path"]] = item
        return item

    def inventory(self, value):
        data = json_bytes(value)
        return self.retain("inputs/" + sha(data) + ".json", data)

    def expected(self, kind):
        if kind in ("prove", "build"):
            return {name for name in self.tracked if
                    (name.startswith("src/") and Path(name).suffix in (".ads", ".adb")) or
                    (name.startswith("scripts/") and name.endswith(".py"))} | {
                        "silver.gpr", "proof/silver_proof_containers.gpr", "alire.toml"}
        if kind == "test":
            return {name for name in self.tracked if name.split("/", 1)[0] in
                    {"scripts", "tests", "src", "proof", "samples", "catalogue"}} | {
                        "silver.gpr", "alire.toml"}
        require(kind == "lean", "unknown input policy: " + kind)
        # Parse the delivered runner's candidate inventory, without executing it.
        tree = ast.parse(self.blob("scripts/check_lean.py"))
        declarations = [node.value for node in tree.body if isinstance(node, ast.Assign) and
                        any(isinstance(t, ast.Name) and t.id == "CANDIDATES" for t in node.targets)]
        require(len(declarations) == 1 and isinstance(declarations[0], ast.Dict), "candidate inventory shape changed")
        candidates = set()
        for node in declarations[0].keys:
            require(isinstance(node, ast.Call) and isinstance(node.func, ast.Name) and
                    node.func.id == "Path" and len(node.args) == 1 and not node.keywords,
                    "candidate path shape changed")
            candidates.add("proof/" + ast.literal_eval(node.args[0]))
        require(candidates and candidates <= self.tracked, "incomplete candidate inventory")
        return {name for name in self.tracked if
                (name.startswith("proof/") and name.endswith(".lean") and
                 ".lake" not in Path(name).parts and Path(name).name != "lakefile.lean" and name not in candidates) or
                (Path(name).parent == Path("src") and Path(name).suffix in (".ads", ".adb")) or
                (Path(name).parent == Path("scripts") and name.endswith(".py"))} | {
                    "proof/lakefile.lean", "proof/lean-toolchain", "proof/generate_source_certificate.py"}

    def compare(self, captured, worktree, kind):
        captured = hashes(captured)
        local = {}
        external = {}
        for name, digest in captured.items():
            path = Path(name)
            if path.is_absolute():
                if not path.is_relative_to(worktree):
                    external[name] = digest
                    continue
                name = path.relative_to(worktree).as_posix()
            require(name not in local, "duplicate normalized captured input: " + name)
            local[name] = digest
        expected = self.expected(kind)
        actual = set(local) & self.tracked
        require(actual == expected,
                f"incomplete {kind} input comparison: missing={sorted(expected - actual)}, "
                f"unexpected={sorted(actual - expected)}")
        governed_extras = {name for name in local if name not in expected and
            ((kind == "lean") or
             (kind == "test" and name.split("/", 1)[0] in {"scripts", "tests", "src", "proof", "samples", "catalogue"}) or
             (kind in {"prove", "build"} and
              ((name.startswith("src/") and Path(name).suffix in {".ads", ".adb"}) or
               (name.startswith("scripts/") and name.endswith(".py")))))}
        require(not governed_extras, "captured input absent from committed target: " + str(sorted(governed_extras)))
        for name in sorted(expected):
            require(sha(self.blob(name)) == local[name], "captured/target mismatch: " + name)
            require(sha((self.root / name).read_bytes()) == local[name], "canonical source drift: " + name)
        # Also check generated/configuration/tool inputs, rather than silently
        # dropping non-Git paths. Reused workspaces must remain stable at export.
        for name, digest in captured.items():
            path = Path(name)
            path = path if path.is_absolute() else worktree / path
            require(path.is_file() and sha(path.read_bytes()) == digest, "captured/live input drift: " + str(path))
        return {"target_commit": self.target, "policy": kind, "expected": len(expected),
                "matched": len(expected), "missing": [], "mismatches": {},
                "all_captured_inputs_live_match": True,
                "additional_local_inputs": len(local) - len(expected), "external_inputs": len(external),
                "target_inputs": self.inventory({name: local[name] for name in sorted(expected)})}

    def managed(self, run_id, worktree, kind):
        require(re.fullmatch(r"\d{8}T\d{6}-[0-9a-f]{12}", run_id), "invalid run ID")
        directory = self.args.registry.resolve() / run_id
        data = (directory / "events.jsonl").read_bytes()
        rows = [json.loads(line) for line in data.splitlines()]
        start, finish = one(rows, "started"), one(rows, "finished")
        require(all(row.get("run_id") == run_id for row in rows), "mixed run IDs")
        require(start["kind"] == kind, "wrong managed run kind: " + run_id)
        require(Path(start["worktree"]["resolved"]) == worktree, "wrong worktree: " + run_id)
        require(start["host"] == "linux-x86_64", "unexpected native host")
        require(finish["outcome"] == "success" and finish["returncode"] in (None, 0),
                "unfinished/failed run cannot be delivery evidence: " + run_id)
        require(not finish.get("failure_keys"), "successful run retains unresolved failures")
        require(instant(start["utc"]) < instant(finish["utc"]), "invalid managed time interval")
        invocation = command(start["command"])
        if kind == "lean":
            capture = start
            captured = start["inputs"]["sources"]
            require(start["scope"] == "complete" and start["inputs"]["scope"] == "complete",
                    "focused Lean is not complete validation")
            begun = [row for row in rows if row["event"] == "phase_started"]
            ended = [row for row in rows if row["event"] == "phase_finished"]
            require([row["phase"] for row in begun] == ["build", "audit"] and
                    [row["phase"] for row in ended] == ["build", "audit"],
                    "require ordinary complete Lean build and fresh audit")
            require(all(row["exit_code"] == 0 for row in ended), "failed Lean phase")
            commands = [command(row["command"]) for row in begun]
        else:
            capture = one(rows, "prepared")
            captured = capture["inputs"]["inputs_sha256"]
            commands = [command(row["command"]) for row in rows if row["event"] == "command"]
        require(commands, "missing managed command")
        result = {"run_id": run_id, "kind": kind, "worktree": str(worktree),
                  "invocation_command": invocation, "commands": commands,
                  "workers": start["workers"], "reason": start.get("reason"),
                  "started_utc": start["utc"], "finished_utc": finish["utc"],
                  "duration_seconds": finish["duration_seconds"], "outcome": finish["outcome"],
                  "input_capture_event": capture["event"], "input_capture_utc": capture["utc"],
                  "tracked_input_comparison": self.compare(captured, worktree, kind),
                  "captured_inputs": self.inventory(capture["inputs"]),
                  "events": self.retain("runs/" + run_id + "-events.jsonl", data)}
        if kind != "lean":
            result["log"] = self.retain("runs/" + run_id + "-native.log", (directory / "native.log").read_bytes())
        return result, rows, capture["inputs"], directory

    def native(self, run_id):
        result, rows, inputs, directory = self.managed(run_id, self.args.native_worktree.resolve(), "prove")
        require(inputs["mode"] == "full" and inputs["scope"] == ["compiler"] and not inputs["arguments"],
                "require complete ordinary --full native compiler proof")
        begin, end = one(rows, "phase-start", phase="audit"), one(rows, "phase-end", phase="audit")
        require(begin["monotonic_ns"] < end["monotonic_ns"], "incomplete native audit")
        reports = directory / "proof-evidence"
        provenance = json.loads((reports / "proof-provenance.json").read_bytes())
        require(provenance["complete"] is True and provenance["mode"] == "full", "incomplete native provenance")
        require(provenance["inputs_sha256"] == inputs["inputs_sha256"] and
                provenance["tools"] == inputs["tools"], "native provenance/input mismatch")
        report_names = {path.name for path in reports.glob("*.spark")} | {"gnatprove.sarif", "gnatprove.out"}
        require(report_names == set(provenance["reports_sha256"]), "incomplete native report inventory")
        for name, digest in provenance["reports_sha256"].items():
            require(sha((reports / name).read_bytes()) == digest, "native report mismatch: " + name)
        initial = json.loads((reports / "proof-inputs.json").read_bytes())
        require({key: provenance[key] for key in initial} == initial, "native initial/final snapshot mismatch")
        require(command(provenance["command"]) == result["invocation_command"] or
                any(provenance["command"] == cmd[-len(provenance["command"]):] for cmd in result["commands"]),
                "native effective command mismatch")
        log = (directory / "native.log").read_text()
        outputs = [line for line in log.splitlines() if line.startswith("Complete GNATprove evidence:")]
        require(len(outputs) == 1, "missing native complete-audit output")
        result["audit"] = {"started_utc": begin["utc"], "finished_utc": end["utc"], "output": outputs[0],
                           "scope": "complete coverage/provenance audit; native sessions and cache may be reused"}
        # The captured runner invokes this exact child with check=True behavior;
        # a nonzero child return prevents audit phase-end and managed success.
        runner = self.blob("scripts/dev.py").decode()
        require('invoke(host, [sys.executable, str(host.root / "scripts/check_evidence.py"),' in runner and
                'if result:\n                raise subprocess.CalledProcessError(result, command)' in runner,
                "auditor invocation/checked-exit source shape changed")
        native = self.args.native_worktree.resolve()
        result["fresh_check_evidence"] = {
            "source": "chosen complete managed native run; no duplicate audit",
            "command": [inputs["tools"]["python"]["path"], str(native / "scripts/check_evidence.py"),
                        "--source-dir", str(native / "src"), "--generated-dir",
                        str(native / ".silver/linux-x86_64/generated"), "--report-dir",
                        str(native / ".silver/linux-x86_64/compiler/obj/gnatprove")],
            "command_evidence": "reconstructed from captured dev.py, captured Python identity and selected native workspace",
            "command_reconstruction_limits": "resolved Python executable identity retained; original selector spelling unavailable",
            "exit_code": 0,
            "exit_code_evidence": "inferred from checked child invocation followed by audit phase-end and successful managed finish",
            "enclosing_started_utc": begin["utc"], "enclosing_finished_utc": end["utc"],
            "enclosing_elapsed_seconds": (end["monotonic_ns"] - begin["monotonic_ns"]) / 1e9,
            "timing_scope": "audit envelope includes in-process source audit, provenance completion and auditor child; separate child time unavailable",
            "output": outputs[0], "transcript": result["log"]}
        result["reports"] = {name: self.retain("native-proof/" + name, (reports / name).read_bytes())
                             for name in sorted(report_names | {"proof-provenance.json", "proof-inputs.json"})}
        return result, reports, inputs

    def lean(self, run_id):
        result, rows, inputs, directory = self.managed(run_id, self.args.lean_worktree.resolve(), "lean")
        data = (directory / "lean-evidence.json").read_bytes()
        evidence = json.loads(data)
        require(evidence["run_id"] == run_id and evidence["scope"] == "complete" and
                evidence["axiom_audit"] == "passed" and evidence["kernel_recheck"] is None,
                "wrong complete Lean result/replay scope")
        require(evidence["inputs_digest_sha256"] == sha(json.dumps(inputs["sources"], sort_keys=True).encode()),
                "Lean result/input digest mismatch")
        if "inputs_sha256" in evidence:
            require(evidence["inputs_sha256"] == inputs["sources"], "detailed Lean inputs differ")
        require(evidence["tools_sha256"] == inputs["tools"], "Lean tool capture mismatch")
        for name, digest in hashes(inputs["tools"]).items():
            require(sha((self.args.lean_worktree / name).read_bytes()) == digest, "Lean tool drift: " + name)
        phases = [row for row in rows if row["event"] == "phase_finished"]
        require(evidence["phases"] == [{key: row[key] for key in
                ("phase", "started_at", "finished_at", "elapsed_seconds", "exit_code")} for row in phases],
                "Lean phase result mismatch")
        log = (directory / "lean-proof.log").read_bytes()
        if "log_sha256" in evidence:
            require(evidence["log_sha256"] == sha(log), "Lean result/log mismatch")
        audit = one(rows, "phase_finished", phase="audit")
        audit_start = one(rows, "phase_started", phase="audit")
        marker = ("Lean phase audit started at " + audit["started_at"]).encode()
        require(log.count(marker) == 1, "missing freshly executed Lean audit marker")
        offset = log.index(marker)
        transcript = log[offset:]
        lines = transcript.decode().splitlines()
        outputs = [line for line in lines if line.startswith("Silver axiom audit passed:")]
        require(len(outputs) == 1, "missing fresh Lean audit result")
        require(sorted(line.removeprefix("SILVER_MODULE ") for line in lines if line.startswith("SILVER_MODULE "))
                == evidence["modules"], "Lean module coverage transcript mismatch")
        result.update({key: evidence[key] for key in
                       ("mode", "axiom_audit", "kernel_recheck", "modules", "elapsed_seconds", "tools_sha256")})
        result["result"] = self.retain("lean/complete-lean-result.json", data)
        result["log"] = self.retain("lean/complete-lean.log", log)
        result["fresh_audit"] = {"command": command(audit_start["command"]),
                                 "started_utc": audit["started_at"], "finished_utc": audit["finished_at"],
                                 "exit_code": audit["exit_code"], "output": outputs[0],
                                 "transcript_log_byte_offset": offset, "transcript_sha256": sha(transcript)}
        result["certificate_scope"] = ("Complete Lean regenerates candidates from captured source/generator inputs; "
            "checked-in candidate parity is separately exercised by the successful complete test suite.")
        return result

    def suite(self, run_id):
        result, rows, inputs, directory = self.managed(run_id, self.args.native_worktree.resolve(), "test")
        require(inputs["arguments"] == [] and inputs["scope"] == ["all-tests"], "require the complete unittest suite")
        require(len(result["commands"]) == 1 and result["commands"][0][1:] ==
                ["-m", "unittest", "discover", "-s", "tests", "-v"], "wrong suite command")
        require(result["invocation_command"] == result["commands"][0], "suite invocation/command mismatch")
        log = (directory / "native.log").read_text()
        summary = re.findall(r"(?m)^Ran (\d+) tests in ([\d.]+)s$", log)
        require(len(summary) == 1 and int(summary[0][0]) > 0 and
                re.search(r"\nRan \d+ tests in [\d.]+s\s+OK\s*$", log), "missing successful complete unittest result")
        require(not re.search(r"(?m)^(?:FAIL|ERROR):|^.*\.\.\. (?:skipped|expected failure|unexpected success)", log),
                "suite has failures, skips, or unexpected outcomes")
        require(re.search(r"(?m)^test_checked_in_certificates_equal_regeneration .* \.\.\. ok$", log),
                "suite did not pass generated-certificate parity")
        result.update(tests=int(summary[0][0]), unittest_seconds=float(summary[0][1]), errors=0, skipped=0)
        result["renderer_inputs"] = self.renderer(result)
        compiler = self.args.native_worktree / ".silver/linux-x86_64/compiler/bin/silver"
        require(inputs["inputs_sha256"][str(compiler.resolve())] == sha(compiler.read_bytes()), "suite compiler drift")
        result["compiler_sha256"] = sha(compiler.read_bytes())
        return result

    def renderer(self, suite):
        require(self.args.renderer_snapshot is not None, "suite requires before/after renderer input capture")
        data = self.args.renderer_snapshot.read_bytes()
        capture = json.loads(data)
        require(capture["run_id"] == suite["run_id"], "renderer snapshot belongs to another suite")
        require(capture["exit_code"] == 0 and capture["rejection"] is None, "suite capture failed")
        require(set(capture["before"]) == RENDERER and capture["before"] == capture["after"], "renderer inputs changed/incomplete")
        require(instant(capture["before_utc"]) <= instant(suite["started_utc"]) <
                instant(suite["finished_utc"]) <= instant(capture["after_utc"]), "renderer snapshot does not bracket suite")
        for name, digest in hashes(capture["before"]).items():
            require(sha(self.blob(name)) == digest and sha((self.args.native_worktree / name).read_bytes()) == digest,
                    "renderer target/live mismatch: " + name)
        sample_sha = sha(self.blob("samples/manifest.json"))
        require(capture["sample_manifest_before_sha256"] == sample_sha and
                capture["sample_manifest_after_sha256"] == sample_sha and
                capture["sample_manifest_managed_sha256"] == sample_sha, "sample manifest capture mismatch")
        return {"expected": len(RENDERER), "matched": len(RENDERER), "missing": [], "mismatches": {},
                "snapshot": self.retain("suite-renderer-before-after.json", data)}

    def fresh_native_audit(self, reports, prepared):
        native = self.args.native_worktree.resolve()
        cmd = [sys.executable, str(native / "scripts/check_evidence.py"), "--source-dir", str(native / "src"),
               "--generated-dir", str(native / ".silver/linux-x86_64/generated"), "--report-dir", str(reports)]
        begun, tick = utc(), time.monotonic()
        completed = subprocess.run(cmd, cwd=native, capture_output=True)
        record = {"command": cmd, "cwd": str(native), "started_utc": begun, "finished_utc": utc(),
                  "elapsed_seconds": time.monotonic() - tick, "exit_code": completed.returncode,
                  "stdout": self.retain("fresh-check-evidence.stdout", completed.stdout),
                  "stderr": self.retain("fresh-check-evidence.stderr", completed.stderr)}
        (self.out / "fresh-check-evidence.json").write_bytes(json_bytes(record))
        require(completed.returncode == 0, "fresh check_evidence failed; transcript retained; no delivery index written")
        require(len([line for line in completed.stdout.decode().splitlines() if
                     line.startswith("Complete GNATprove evidence:")]) == 1, "fresh audit output missing")
        # Read-only validation and export must not conceal a source race.
        self.compare(prepared["inputs_sha256"], native, "prove")
        return record


def focused(export):
    args = export.args
    directory = args.registry.resolve() / FOCUSED_RUN
    raw = (directory / "events.jsonl").read_bytes()
    rows = [json.loads(line) for line in raw.splitlines()]
    start, end, prepared = one(rows, "started"), one(rows, "finished"), one(rows, "prepared")
    require(all(row["run_id"] == FOCUSED_RUN for row in rows), "focused mixed run IDs")
    require(start["kind"] == "tool-gnatprove" and end["outcome"] == "success" and
            end["returncode"] in (None, 0) and not end.get("failure_keys"), "focused run did not finish successfully")
    invocation = command(start["command"])
    require("--limit-region=silver_output_profile.adb:2145:2157" in invocation and
            "--level=2" in invocation and "--timeout=30" in invocation, "focused scope/settings mismatch")
    inputs = hashes(prepared["inputs"]["inputs_sha256"])
    for name, digest in inputs.items():
        require(Path(name).is_file() and sha(Path(name).read_bytes()) == digest, "focused input drift: " + name)
    for identity in prepared["inputs"]["tools"].values():
        require(sha(Path(identity["path"]).read_bytes()) == identity["sha256"], "focused tool drift: " + identity["path"])
    profile = REPOSITORY / "tmp/guard-native-check/src/silver_output_profile.adb"
    require(inputs[str(profile)] == PROFILE_SHA, "focused candidate source mismatch")
    target_matches, historical_differences = {}, {}
    for name, digest in inputs.items():
        path = Path(name)
        if path.is_relative_to(profile.parent):
            relative = "src/" + path.relative_to(profile.parent).as_posix()
        elif path.is_relative_to(REPOSITORY):
            relative = path.relative_to(REPOSITORY).as_posix()
        else:
            continue
        if relative in export.tracked:
            target_sha = sha(export.blob(relative))
            if target_sha == digest:
                target_matches[relative] = digest
            else:
                historical_differences[relative] = {"captured_sha256": digest, "target_sha256": target_sha,
                    "retained_input": export.retain("focused-v18/historical-inputs/" + relative, path.read_bytes())}
    require(target_matches, "focused zero-match target comparison")
    reports = directory / "exploratory-evidence/0/explore/guard/gnatprove"
    report_bytes = (reports / "silver_output_profile.spark").read_bytes()
    report = json.loads(report_bytes)
    checks = report["proof"]
    require(len(checks) == 18 and all(row["severity"] == "info" and row["message"]["text"].endswith(" proved")
                                    for row in checks), "focused checks incomplete/unproved")
    require(all(not report[key] for key in ("pragma_assume", "skip_flow_proof", "skip_proof")),
            "focused report has assumptions/skips")
    require(all(row["severity"] == "warning" and row["rule"] in
                {"array-initialization", "contracts-recursive", "numeric-variant"}
                for row in report["warn_error"]), "unexpected focused diagnostic")
    assertions = [row for row in checks if row["rule"] == "VC_ASSERT"]
    require({row["line"] for row in assertions} == {2146, 2152, 2157}, "focused assertion coverage mismatch")
    require({row["line"] for row in checks if row["rule"] == "VC_PRECONDITION"} >= {2147, 2153},
            "focused bridge call coverage missing")
    log = (directory / "native.log").read_bytes()
    require(b"Success: all checks proved (22 checks)." in log, "focused log missing success summary")
    result = {"run_id": FOCUSED_RUN, "scope": "focused exploratory relation join; not complete compiler validation",
              "target_commit": export.target, "profile_sha256": PROFILE_SHA,
              "invocation_command": invocation,
              "commands": [command(row["command"]) for row in rows if row["event"] == "command"],
              "started_utc": start["utc"], "finished_utc": end["utc"], "duration_seconds": end["duration_seconds"],
              "all_captured_inputs_live_match": True, "captured_inputs": export.inventory(prepared["inputs"]),
              "captured_target_matches": export.inventory(target_matches),
              "historical_focused_input_differences": historical_differences,
              "retained_warning_records": report["warn_error"],
              "events": export.retain("focused-v18/events.jsonl", raw),
              "log": export.retain("focused-v18/native.log", log),
              "profile": export.retain("focused-v18/silver_output_profile.adb", profile.read_bytes()),
              "project": export.retain("focused-v18/probe.gpr", (profile.parent.parent / "probe.gpr").read_bytes()),
              "reports": {name: export.retain("focused-v18/" + name, (reports / name).read_bytes()) for name in
                          ("silver_output_profile.spark", "gnatprove.out", "gnatprove.sarif")},
              "assertions": [{key: row[key] for key in ("line", "col", "rule", "message", "stats")} for row in assertions],
              "diagnostic_history": {name: export.retain("focused-v18/history/" + name,
                   (REPOSITORY / "tmp/guard-native-repair-continued" / name).read_bytes()) for name in
                   ("relation-true-join-report.md", "relation-true-join-manifest.json", "relation-true-join-diagnostic.json")},
              "limits": ["Historical proposal report predates v18 success and retains its original pending language.",
                         "v17 isolated the proved update from the failing joined equality; v18 supplies checked logical equality in both branches.",
                         "Retained translation limitation warnings remain visible; the full compiler auditor decides full-run acceptance.",
                         "Historical probe source/tooling differences from the delivery target are explicit and their bytes retained; only the frozen profile/local region is claimed.",
                         "This local success does not discharge unrelated/native-full or final-source Lean obligations."]}
    require(result["commands"], "focused missing actual command")
    export.out.mkdir(parents=True, exist_ok=True)
    (export.out / "focused-v18.json").write_bytes(json_bytes(result))
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("mode", choices=("focused", "inspect", "delivery"))
    p.add_argument("--root", type=Path, default=REPOSITORY / "tmp/scalar-guard-refinement")
    p.add_argument("--target", required=True, help="exact committed delivery input target, not an implicit HEAD")
    p.add_argument("--registry", type=Path, default=REPOSITORY / ".git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs")
    p.add_argument("--native-worktree", type=Path, default=REPOSITORY / "tmp/bounded-mutable-integers-native")
    p.add_argument("--lean-worktree", type=Path, default=REPOSITORY / "tmp/review-b79-b1-lean")
    p.add_argument("--out", type=Path, default=OWNED / "export")
    p.add_argument("--native-full", help="successful complete dev.py prove --full run ID")
    p.add_argument("--build", help="successful complete dev.py build run ID")
    p.add_argument("--lean", help="successful complete check_lean.py run ID for final source")
    p.add_argument("--suite", help="successful complete dev.py test run ID")
    p.add_argument("--renderer-snapshot", type=Path, help="before/after capture from run-suite-with-renderer-capture.py")
    p.add_argument("--audit-source", choices=("managed", "fresh"), default="managed",
                   help="reuse fresh auditor inside full native run; fresh requests a separately timed repeat")
    args = p.parse_args()
    export = Export(args)
    if args.mode == "focused":
        result = focused(export)
        print(json.dumps({"focused_run": result["run_id"], "retained": str(export.out / "focused-v18.json"),
                          "claim": result["scope"]}, indent=2))
        return
    require(all((args.native_full, args.build, args.lean, args.suite)), "explicit IDs required for all four complete checks")
    require(not (export.out / "validation.json").exists(), "delivery index already exists; use a new output directory")
    native, reports, prepared = export.native(args.native_full)
    build, _, build_inputs, _ = export.managed(args.build, args.native_worktree.resolve(), "build")
    require(build_inputs["mode"] == "build" and build_inputs["scope"] == ["compiler"] and
            not build_inputs["arguments"], "require complete standard native build")
    lean = export.lean(args.lean)
    suite = export.suite(args.suite)
    result = {"schema_version": 1, "implementation_commit": export.target, "platform": "Linux x86_64",
              "exported_utc": utc(), "native_full": native, "native_build": build, "lean": lean, "full_suite": suite,
              "limits": ["Native and Lean caches may be reused; complete audits freshly execute.",
                         "No independent kernel replay, native macOS run, or hosted CI is claimed.",
                         "This index does not substitute for independent review or capability/issue integration."]}
    if args.mode == "inspect":
        export.out.mkdir(parents=True, exist_ok=True)
        (export.out / "inspection-only.json").write_bytes(json_bytes(result))
        print("Chosen completed runs and expected tracked inputs match; no fresh audit or delivery index produced.")
        return
    result["fresh_check_evidence"] = (export.fresh_native_audit(reports, prepared)
        if args.audit_source == "fresh" else native["fresh_check_evidence"])
    # Recheck every captured input set after all export work (and the optional
    # standalone audit), so concurrent workspace reuse cannot pass unnoticed.
    for run_id, kind, worktree in ((args.native_full, "prove", args.native_worktree),
                                  (args.build, "build", args.native_worktree),
                                  (args.lean, "lean", args.lean_worktree),
                                  (args.suite, "test", args.native_worktree)):
        rows = [json.loads(line) for line in (args.registry / run_id / "events.jsonl").read_bytes().splitlines()]
        capture = one(rows, "started" if kind == "lean" else "prepared")["inputs"]
        export.compare(capture["sources" if kind == "lean" else "inputs_sha256"], worktree.resolve(), kind)
    result["exported_utc"] = utc()
    (export.out / "artifact-index.json").write_bytes(json_bytes(export.artifacts))
    (export.out / "validation.json.tmp").write_bytes(json_bytes(result))
    (export.out / "validation.json.tmp").replace(export.out / "validation.json")
    print(json.dumps({"implementation_commit": export.target, "validation": str(export.out / "validation.json"),
                      "fresh_check_evidence_exit": result["fresh_check_evidence"]["exit_code"]}, indent=2))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError, subprocess.CalledProcessError) as error:
        print("evidence export rejected: " + str(error), file=sys.stderr)
        raise SystemExit(1)
