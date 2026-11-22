"""Manifest-driven admission, proof, build and application behavior checks."""
from __future__ import annotations

import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from unittest import mock
import xml.etree.ElementTree as ET

from scripts.check_evidence import audit_reports
from tests.test_silver import HOST, ROOT, SILVER, invoke


def _compile_maximum_dynamic_expression(
        source: Path, *, timeout: float = 3 * 60 * 60) -> subprocess.CompletedProcess[str]:
    command = [str(SILVER), "compile", str(source)]
    with subprocess.Popen(command, cwd=ROOT, text=True, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, start_new_session=True) as process:
        try:
            stdout, stderr = process.communicate(timeout=timeout)
        except subprocess.TimeoutExpired:
            # Stop Why3's launch group first: it puts solvers in separate
            # process groups within this isolated session. Keep the compiler
            # unreaped until the remaining session groups have been killed.
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            try:
                pids = subprocess.run(["ps", "-e", "-o", "pid="], text=True,
                                      capture_output=True, check=True, timeout=5).stdout
                groups = set()
                for pid in map(int, pids.split()):
                    try:
                        if os.getsid(pid) == process.pid:
                            groups.add(os.getpgid(pid))
                    except (ProcessLookupError, PermissionError):
                        continue
                for group in groups - {process.pid}:
                    try:
                        os.killpg(group, signal.SIGKILL)
                    except ProcessLookupError:
                        pass
            finally:
                process.wait()
            # Preserve subprocess.run's POSIX timeout exception, including its
            # raw partial-output snapshot, rather than decoding output again.
            raise
    return subprocess.CompletedProcess(command, process.returncode, stdout, stderr)


class MaximumExpressionProcessTests(unittest.TestCase):
    def compiler_fixture(self, code: str) -> tuple[Path, Path]:
        directory = tempfile.TemporaryDirectory(prefix="silver-compile-process-")
        self.addCleanup(directory.cleanup)
        root = Path(directory.name)
        compiler = root / "silver"
        compiler.write_text(f"#!{sys.executable}\n" + code)
        compiler.chmod(0o700)
        return compiler, root / "main.adb"

    def test_success_and_failure_preserve_output_and_return_code(self) -> None:
        for status in (0, 7):
            with self.subTest(status=status):
                compiler, source = self.compiler_fixture(
                    "import os\n"
                    "os.write(1, b'compiler \\xe2\\x9c\\x93\\n')\n"
                    "os.write(2, b'proof diagnostics\\n')\n"
                    f"raise SystemExit({status})\n")
                with mock.patch(__name__ + ".SILVER", compiler):
                    result = _compile_maximum_dynamic_expression(source, timeout=5)
                self.assertEqual(result.args, [str(compiler), "compile", str(source)])
                self.assertEqual(result.returncode, status)
                self.assertEqual(result.stdout, "compiler ✓\nproof diagnostics\n")
                self.assertIsNone(result.stderr)

    def test_timeout_kills_session_groups_and_reaps_compiler(self) -> None:
        compiler, source = self.compiler_fixture("")
        group_file = compiler.parent / "group"

        def cleanup_group() -> None:
            if group_file.exists():
                for group in map(int, group_file.read_text().split()):
                    try:
                        os.killpg(group, signal.SIGKILL)
                    except ProcessLookupError:
                        pass

        self.addCleanup(cleanup_group)
        descendant = ("import os,sys,time\n"
                      "print(f'{sys.argv[1]}:{os.getpid()}:{os.getpgrp()}:{os.getsid(0)}', flush=True)\n"
                      "if sys.argv[1] == 'separate': os.write(1, b'\\xe2')\n"
                      "time.sleep(10)\n")
        compiler.write_text(
            f"#!{sys.executable}\n"
            "import os,subprocess,sys,time\n"
            "from pathlib import Path\n"
            f"Path({str(group_file)!r}).write_text(str(os.getpid()))\n"
            "print(f'compiler:{os.getpid()}:{os.getpgrp()}:{os.getsid(0)}', flush=True)\n"
            f"subprocess.Popen([sys.executable, '-c', {descendant!r}, 'inherited'])\n"
            f"separate = subprocess.Popen([sys.executable, '-c', {descendant!r}, 'separate'], process_group=0)\n"
            f"Path({str(group_file)!r}).write_text(f'{{os.getpid()}} {{separate.pid}}')\n"
            "time.sleep(10)\n")
        started = time.monotonic()
        with mock.patch(__name__ + ".SILVER", compiler), \
                self.assertRaises(subprocess.TimeoutExpired) as raised:
            _compile_maximum_dynamic_expression(source, timeout=1)
        self.assertLess(time.monotonic() - started, 5, "timeout cleanup did not finish promptly")
        error = raised.exception
        self.assertEqual(error.cmd, [str(compiler), "compile", str(source)])
        self.assertEqual(error.timeout, 1)
        self.assertIsNone(error.stderr)
        self.assertIsInstance(error.output, bytes)
        # A timeout can interrupt a UTF-8 diagnostic. Cleanup must not decode
        # that partial byte sequence and replace TimeoutExpired with an error.
        self.assertIn(b"\xe2", error.output)
        processes = {name: (int(pid), int(group), int(session))
                     for name, pid, group, session in (
                         line.split(":")
                         for line in error.output.replace(b"\xe2", b"").decode().splitlines())}
        self.assertEqual(set(processes), {"compiler", "inherited", "separate"})
        pid, group, session = processes["compiler"]
        self.assertEqual(group, pid)
        self.assertEqual(session, pid)
        self.assertNotEqual(group, os.getpgrp())
        self.assertEqual(processes["inherited"][1:], (group, session))
        separate_pid, separate_group, separate_session = processes["separate"]
        self.assertEqual(separate_group, separate_pid)
        self.assertNotEqual(separate_group, group)
        self.assertEqual(separate_session, session)
        with self.assertRaises(ChildProcessError):
            os.waitpid(pid, os.WNOHANG)
        # Descendants belong to their new parent, which reaps them. A zombie
        # is already terminated even if that parent has not run yet.
        descendants = ",".join(str(processes[name][0]) for name in ("inherited", "separate"))
        deadline = time.monotonic() + 3
        while True:
            status = subprocess.run(["ps", "-o", "pid=,stat=", "-p", descendants],
                                    text=True, capture_output=True, timeout=5)
            self.assertIn(status.returncode, (0, 1), status.stderr)
            self.assertEqual(status.stderr, "")
            states = [line.split()[1] for line in status.stdout.splitlines()]
            if all(state.startswith("Z") for state in states):
                break
            self.assertLess(time.monotonic(), deadline, status.stdout)
            time.sleep(.01)


class SupportedSampleTests(unittest.TestCase):
    def assert_application_proof_policy(self, report: Path, *, output: bool,
                                        functions: bool = False) -> None:
        command = json.loads(report.read_text())["runs"][0]["invocations"][0]["commandLine"].split()
        options = {
            "mode": "all", "report": "all", "checks-as-errors": "on",
            "warnings": "continue" if output else "error", "level": "2",
            "prover": "cvc5,z3,altergo", "steps": "100000", "timeout": "0",
            "memlimit": "1000",
        }
        for name, value in options.items():
            self.assertEqual([arg for arg in command if arg.startswith(f"--{name}=")],
                             [f"--{name}={value}"])
        self.assertIn("-U", command)
        self.assertEqual([arg for arg in command if arg.startswith("-j")], ["-j1"])
        self.assertIn("--no-loop-unrolling", command)
        self.assertEqual("--no-inlining" in command, functions)

        # GNATprove normalizes --steps for each pinned solver; Why3 records
        # the resulting raw limits. Per-attempt overrides also take effect.
        steps = {"altergo": "100000", "CVC5": "3515000", "Z3": "80450000"}
        attempted = set()
        sessions = list(report.parent.rglob("why3session.xml"))
        if output:
            self.assertTrue(sessions, "missing effective application prover limits")
        for path in sessions:
            session = ET.parse(path).getroot()
            provers = {item.attrib["id"]: item.attrib for item in session.findall("prover")}
            for prover in provers.values():
                if prover["name"] == "Trivial":
                    continue  # Why3's internal trivial prover has its own limits.
                name = prover["name"]
                self.assertIn(name, steps, path)
                expected = {"timelimit": "0", "steplimit": steps[name], "memlimit": "1000"}
                self.assertEqual({key: prover.get(key) for key in expected}, expected, path)
            for proof in session.iter("proof"):
                prover = provers[proof.attrib["prover"]]
                if prover["name"] != "Trivial":
                    if proof.find("result") is not None:
                        attempted.add(prover["name"])
                    expected = {"timelimit": "0", "steplimit": steps[prover["name"]],
                                "memlimit": "1000"}
                    self.assertEqual({key: proof.get(key, prover.get(key)) for key in expected},
                                     expected, path)
        if output:
            # Serial proving can discharge every goal with the first configured
            # solver. Require observed effective limits, not redundant attempts.
            self.assertTrue(attempted, "missing external application proof results")

    def test_manifest_samples(self) -> None:
        self.assertTrue(SILVER.is_file(), "build the actual SPARK compiler first")
        directory = ROOT / "samples"
        manifest = json.loads((directory / "manifest.json").read_text())
        self.assertEqual(manifest["schema_version"], 1)
        self.assertTrue(manifest["samples"])
        sources = [sample["source"] for sample in manifest["samples"]]
        self.assertEqual(len(sources), len(set(sources)))
        packages = [sample["application_package"] for sample in manifest["samples"]
                    if "application_package" in sample]
        package_bodies = {package["body"] for package in packages}
        package_specs = {package["specification"] for package in packages}
        self.assertFalse(set(sources) & package_bodies, "package body listed as standalone Main")
        self.assertEqual(set(sources) | package_bodies,
                         {str(path.relative_to(directory)) for path in directory.rglob("*.adb")})
        self.assertEqual(package_specs,
                         {str(path.relative_to(directory)) for path in directory.rglob("*.ads")})
        catalogue = json.loads((ROOT / "catalogue/silver.json").read_text())
        capabilities = {item["id"] for item in catalogue["constructs"]}
        for sample in manifest["samples"]:
            with self.subTest(source=sample["source"]):
                source = directory / sample["source"]
                self.assertTrue(source.is_file())
                self.assertTrue(sample["capabilities"])
                self.assertTrue(set(sample["capabilities"]) <= capabilities)
                reference, fragment = sample["specification"].split("#", 1)
                self.assertTrue((directory / reference).is_file())
                self.assertTrue(fragment)
                data = source.read_bytes()
                package = sample.get("application_package")
                originals = {"main.adb": (source, data)}
                if package is not None:
                    package = {**package,
                               "functions": tuple(package["functions"]),
                               "procedures": {name: tuple(formals) for name, formals in package["procedures"].items()},
                               "formals": {name: tuple(tuple(formal) for formal in formals)
                                           for name, formals in package["formals"].items()},
                               "states": tuple(package["states"]),
                               "writes": {name: tuple(states) for name, states in package["writes"].items()}}
                    for key, extension in (("specification", ".ads"), ("body", ".adb")):
                        original = directory / package[key]
                        self.assertEqual(original.parent, source.parent)
                        self.assertEqual(original.name, package["name"].lower() + extension)
                        originals[original.name] = (original, original.read_bytes())
                admission = invoke("check", source)
                self.assertEqual(admission.returncode, 0, admission.stdout)
                compilation = invoke("compile", source)
                self.assertEqual(compilation.returncode, 0, compilation.stdout)
                match = re.search(r"^Executable: (.+)$", compilation.stdout, re.MULTILINE)
                self.assertIsNotNone(match, compilation.stdout)
                executable = Path(match.group(1))
                if not executable.is_absolute():
                    executable = ROOT / executable
                workspace = executable.parent.parent
                self.assertEqual(workspace.parent, HOST.artifacts)
                self.addCleanup(shutil.rmtree, workspace)
                snapshots = [path for path in workspace.rglob("*.adb")
                             if path.read_bytes() == data]
                self.assertEqual(len(snapshots), 1, "missing byte-identical proof/build source")
                for name, (_, original_data) in originals.items():
                    self.assertEqual((workspace / name).read_bytes(), original_data,
                                     f"missing byte-identical original unit: {name}")
                reports = list(workspace.rglob("gnatprove.sarif"))
                self.assertEqual(len(reports), 1)
                # Every admitted write selects the existing assignment policy
                # and its advisories, including Character and String elements.
                assignment = bool({"string_assignment", "integer_assignment", "integer_array_assignment",
                                   "boolean_assignment", "boolean_array_assignment", "character_assignment", "string_element_assignment",
                                   "scalar_function_call", "scalar_procedure_call"}
                                  & set(sample["capabilities"]))
                output = "runtime_context" in sample["capabilities"]
                functions = tuple(sample.get("application_functions", []))
                procedures = {name: tuple(outputs) for name, outputs in
                              sample.get("application_procedures", {}).items()}
                self.assert_application_proof_policy(reports[0], output=output,
                                                     functions=bool(functions or procedures or package))
                units = {snapshots[0].stem}
                if package is not None:
                    units.add(package["name"].lower())
                if output:
                    units |= {"silver_io", "silver_output_libc", "silver_arguments", "silver_runtime"}
                statistics = audit_reports(reports[0].parent, units,
                                           {"silver_output_libc", "silver_runtime"} if output else set(),
                                           application_kind=("selected" if assignment else "argument")
                                           if "argument_context" in sample["capabilities"]
                                           else ("assigned" if assignment else "static") if output else None,
                                           indexed_main=True, application_functions=functions,
                                           **({'application_procedures': procedures} if procedures else {}),
                                           **({'application_package': package, 'indexed_packages': True}
                                              if package is not None else {}))
                self.assertEqual(statistics["units"], len(units))
                if output:
                    self.assertGreater(statistics["proof_checks"], 0)
                else:
                    self.assertEqual(statistics["proof_checks"], 0)
                self.assertTrue(executable.is_file(), compilation.stdout)
                # Compiler diagnostics are not application output. Execute the
                # published binary directly and compare each stream as bytes.
                cases = [{"arguments": [], "expected": sample["expected"]},
                         *sample.get("argument_cases", [])]
                for case in cases:
                    with self.subTest(arguments=case["arguments"]):
                        execution = subprocess.run([str(executable), *case["arguments"]],
                                                   timeout=10, capture_output=True)
                        expected = case["expected"]
                        self.assertEqual(execution.returncode, expected["exit_status"], execution.stderr)
                        self.assertEqual(execution.stdout, expected["stdout"].encode("utf-8"))
                        self.assertEqual(execution.stderr, expected["stderr"].encode("utf-8"))
                for original, original_data in originals.values():
                    self.assertEqual(original.read_bytes(), original_data,
                                     "compilation modified an original application unit")

    def test_maximum_dynamic_expression(self) -> None:
        # This admitted 64-leaf source previously needed more than the old
        # 10,000 normalized steps. Compile it, not just its membership check.
        data = ("with Silver_IO;with Silver_Arguments;procedure Main is pragma SPARK_Mode(On);"
                'D:constant String:=Silver_Arguments.First_Or_Default("");begin '
                "if Silver_Arguments.Input_Is_Valid and then D'Length<=64 then Silver_IO.Put_Line("
                + "&".join(["D"] * 64)
                + ");else Silver_Arguments.Reject;end if;end Main;").encode("ascii")
        with tempfile.TemporaryDirectory(prefix="silver-proof-policy-") as directory:
            source = Path(directory) / "main.adb"
            source.write_bytes(data)
            admission = invoke("check", source)
            self.assertEqual(admission.returncode, 0, admission.stdout)
            # Test-runner deadline only; production proof has no wall-clock limit.
            # The one-worker application prover took 6,973 seconds on the host's
            # eight-CPU allocation. Allow three hours for this maximal case;
            # ordinary tests and production solver limits remain unchanged.
            compilation = _compile_maximum_dynamic_expression(source)
            self.assertEqual(compilation.returncode, 0, compilation.stdout)
            match = re.search(r"^Executable: (.+)$", compilation.stdout, re.MULTILINE)
            self.assertIsNotNone(match, compilation.stdout)
            executable = Path(match.group(1))
            if not executable.is_absolute():
                executable = ROOT / executable
            workspace = executable.parent.parent
            self.assertEqual(workspace.parent, HOST.artifacts)
            self.addCleanup(shutil.rmtree, workspace)
            snapshots = [path for path in workspace.rglob("*.adb") if path.read_bytes() == data]
            self.assertEqual(len(snapshots), 1, "missing byte-identical proof/build source")
            reports = list(workspace.rglob("gnatprove.sarif"))
            self.assertEqual(len(reports), 1)
            self.assert_application_proof_policy(reports[0], output=True)
            statistics = audit_reports(reports[0].parent,
                                       {snapshots[0].stem, "silver_io", "silver_output_libc",
                                        "silver_arguments", "silver_runtime"},
                                       {"silver_output_libc", "silver_runtime"},
                                       application_kind="argument", indexed_main=True)
            self.assertEqual(statistics["units"], 5)
            self.assertGreater(statistics["proof_checks"], 0)
            for arguments, expected in (([], b"\n"), (["x" * 64], b"x" * 4096 + b"\n")):
                with self.subTest(arguments=arguments):
                    execution = subprocess.run([str(executable), *arguments], timeout=10,
                                               capture_output=True)
                    self.assertEqual(execution.returncode, 0, execution.stderr)
                    self.assertEqual(execution.stdout, expected)
                    self.assertEqual(execution.stderr, b"")
            self.assertEqual(source.read_bytes(), data, "compilation modified author source")


if __name__ == "__main__":
    unittest.main()
