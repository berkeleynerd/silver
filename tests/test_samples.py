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
        catalogue = json.loads((ROOT / "catalogue/silver-null-0.json").read_text())
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
                before = set(HOST.artifacts.glob("program-*"))
                compilation = invoke("compile", source)
                created = set(HOST.artifacts.glob("program-*")) - before
                for workspace in created:
                    self.addCleanup(shutil.rmtree, workspace)
                self.assertEqual(compilation.returncode, 0, compilation.stdout)
                self.assertEqual(len(created), 1, compilation.stdout)
                workspace = created.pop()
                snapshots = [path for path in workspace.rglob("*.adb")
                             if path.read_bytes() == data]
                self.assertEqual(len(snapshots), 1, "missing byte-identical proof/build source")
                reports = list(workspace.rglob("gnatprove.sarif"))
                self.assertEqual(len(reports), 1)
                statistics = audit_reports(reports[0].parent, {snapshots[0].stem})
                self.assertEqual(statistics["units"], 1)
                self.assertEqual(statistics["proof_checks"], 0)
                match = re.search(r"^Executable: (.+)$", compilation.stdout, re.MULTILINE)
                self.assertIsNotNone(match, compilation.stdout)
                executable = Path(match.group(1))
                if not executable.is_absolute():
                    executable = ROOT / executable
                self.assertTrue(executable.is_file(), compilation.stdout)
                # Compiler diagnostics are not application output. Execute the
                # published binary directly and compare each stream as bytes.
                execution = subprocess.run([str(executable)], timeout=10, capture_output=True)
                expected = sample["expected"]
                self.assertEqual(execution.returncode, expected["exit_status"], execution.stderr)
                self.assertEqual(execution.stdout, expected["stdout"].encode("utf-8"))
                self.assertEqual(execution.stderr, expected["stderr"].encode("utf-8"))
                self.assertEqual(source.read_bytes(), data, "compilation modified sample source")


if __name__ == "__main__":
    unittest.main()
