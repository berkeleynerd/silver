"""Manifest-driven admission, proof, build and application behavior checks."""
from __future__ import annotations

import json
from pathlib import Path
import re
import shutil
import subprocess
import unittest

from scripts.check_evidence import audit_reports
from tests.test_silver import HOST, ROOT, SILVER, invoke


class SupportedSampleTests(unittest.TestCase):
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
                command = json.loads(reports[0].read_text())["runs"][0]["invocations"][0]["commandLine"].split()
                assignment = "string_assignment" in sample["capabilities"]
                output = "runtime_context" in sample["capabilities"]
                self.assertEqual([argument for argument in command if argument.startswith("--warnings=")],
                                 ["--warnings=continue" if output else "--warnings=error"])
                self.assertIn("--checks-as-errors=on", command)
                units = {snapshots[0].stem}
                if output:
                    units |= {"silver_io", "silver_output_libc", "silver_arguments", "silver_runtime"}
                statistics = audit_reports(reports[0].parent, units,
                                           {"silver_output_libc", "silver_runtime"} if output else set(),
                                           application_kind=("selected" if assignment else "argument")
                                           if "argument_context" in sample["capabilities"]
                                           else ("assigned" if assignment else "static") if output else None)
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


if __name__ == "__main__":
    unittest.main()
