"""Manifest-driven admission, proof, build and application behavior checks."""
from __future__ import annotations

import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET

from scripts.check_evidence import audit_reports
from tests.test_silver import HOST, ROOT, SILVER, invoke


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
        seen = set()
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
                seen.add(name)
                expected = {"timelimit": "0", "steplimit": steps[name], "memlimit": "1000"}
                self.assertEqual({key: prover.get(key) for key in expected}, expected, path)
            for proof in session.iter("proof"):
                prover = provers[proof.attrib["prover"]]
                if prover["name"] != "Trivial":
                    expected = {"timelimit": "0", "steplimit": steps[prover["name"]],
                                "memlimit": "1000"}
                    self.assertEqual({key: proof.get(key, prover.get(key)) for key in expected},
                                     expected, path)
        if output:
            self.assertEqual(seen, set(steps))

    def test_manifest_samples(self) -> None:
        self.assertTrue(SILVER.is_file(), "build the actual SPARK compiler first")
        directory = ROOT / "samples"
        manifest = json.loads((directory / "manifest.json").read_text())
        self.assertEqual(manifest["schema_version"], 1)
        self.assertTrue(manifest["samples"])
        sources = [sample["source"] for sample in manifest["samples"]]
        self.assertEqual(len(sources), len(set(sources)))
        self.assertEqual(set(sources), {str(path.relative_to(directory))
                                        for path in directory.rglob("*.adb")})
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
                                                     functions=bool(functions or procedures))
                units = {snapshots[0].stem}
                if output:
                    units |= {"silver_io", "silver_output_libc", "silver_arguments", "silver_runtime"}
                statistics = audit_reports(reports[0].parent, units,
                                           {"silver_output_libc", "silver_runtime"} if output else set(),
                                           application_kind=("selected" if assignment else "argument")
                                           if "argument_context" in sample["capabilities"]
                                           else ("assigned" if assignment else "static") if output else None,
                                           indexed_main=True, application_functions=functions,
                                           **({'application_procedures': procedures} if procedures else {}))
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
                self.assertEqual(source.read_bytes(), data, "compilation modified sample source")

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
            compilation = subprocess.run([str(SILVER), "compile", str(source)], cwd=ROOT,
                                         text=True, stdout=subprocess.PIPE,
                                         stderr=subprocess.STDOUT, timeout=300)
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
