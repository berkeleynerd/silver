"""Production Image proof routing preserves source and required length checks."""
from __future__ import annotations

import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest
from unittest import mock

from tests.test_silver import HOST, invoke


class ImageAdapterTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix="silver image routing '")
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name) / "main.adb"

    def test_initializer_and_loop_assignment_prove_and_execute_unchanged(self) -> None:
        source = b'''with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   N : constant Integer := 3;
   S : String := Integer'Image (N);
begin
   Silver_IO.Put_Line (S);
   for I in -1 .. 1 loop
      S := Integer'Image (I);
      Silver_IO.Put_Line (S);
   end loop;
end Main;
'''
        self.source.write_bytes(source)
        before = set(HOST.artifacts.glob("imagews-*"))
        with mock.patch.dict(os.environ, {"SILVER_KEEP_IMAGE_WORKSPACES": "1"}):
            result = invoke("run", self.source)
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertIn("Execution completed successfully.", result.stdout)
        self.assertEqual(self.source.read_bytes(), source)
        match = re.search(r"^Executable: (.+)$", result.stdout, re.MULTILINE)
        self.assertIsNotNone(match, result.stdout)
        executable = Path(match.group(1))
        self.assertTrue(executable.is_absolute())
        workspace = executable.parent.parent
        self.assertTrue(workspace.is_relative_to(HOST.artifacts))
        self.assertEqual((workspace / "main.adb").read_bytes(), source)
        executed = subprocess.run([str(executable)], capture_output=True, timeout=10)
        self.assertEqual(executed.returncode, 0, executed.stderr)
        self.assertEqual(executed.stdout, b" 3\n-1\n 0\n 1\n")
        report = json.loads((workspace / "obj/gnatprove/main~1.spark").read_text())
        checks = [item for item in report["proof"] if item["rule"] == "VC_LENGTH_CHECK"]
        self.assertTrue(checks, "loop assignment lost its original required length check")
        self.assertTrue(all(item["severity"] == "info" for item in checks), checks)
        # GNATprove normalizes its SARIF argv[0] to its basename. Identify the
        # adapter invocation by its exact preserved copy of Main's native model.
        original = (workspace / "obj/gnatprove/main.gnat-json").read_bytes()
        routed = [directory for directory in set(HOST.artifacts.glob("imagews-*")) - before
                  if (directory / "original.gnat-json").is_file()
                  and (directory / "original.gnat-json").read_bytes() == original
                  and (directory / "refined.gnat-json").is_file()]
        self.assertEqual(len(routed), 1)
        self.assertNotEqual((routed[0] / "refined.gnat-json").read_bytes(), original)
        self.assertTrue(list(routed[0].rglob("silver_image.mlw")))
        # Retain reports and the exact application snapshot as test evidence.

        # Exercise caller-owned proof directories with this already produced
        # Refine model. Native --help exits synchronously without another proof.
        supplied = self.source.parent / "caller proof directory"
        theories = supplied / "_theories"
        theories.mkdir(parents=True)
        marker = supplied / "caller-owned.txt"
        marker.write_text("preserve")
        theory = theories / "silver_image.mlw"
        theory.write_text("conflicting caller theorem")
        arguments = [HOST.image_adapter, "--help", "--proof-dir", supplied,
                     workspace / "obj/gnatprove/main.gnat-json"]
        failed = subprocess.run(arguments, capture_output=True, text=True, timeout=10)
        self.assertEqual(failed.returncode, 3, failed.stdout + failed.stderr)
        self.assertEqual(json.loads(failed.stdout), {
            "error": "Silver Image adapter: cannot install or verify Image theory in proof directory",
            "internal": False, "results": [],
        })
        self.assertEqual(theory.read_text(), "conflicting caller theorem")
        theory.unlink()  # Remove only this test's deliberately conflicting file.
        before = set(HOST.artifacts.glob("imagews-*"))
        with mock.patch.dict(os.environ, {"SILVER_KEEP_IMAGE_WORKSPACES": ""}):
            succeeded = subprocess.run(arguments, capture_output=True, text=True, timeout=10)
        self.assertEqual(succeeded.returncode, 0, succeeded.stdout + succeeded.stderr)
        self.assertEqual(set(HOST.artifacts.glob("imagews-*")), before)
        self.assertEqual(marker.read_text(), "preserve")
        self.assertTrue(theory.is_file())

    def test_adapter_failures_are_actionable_and_preserve_snapshots(self) -> None:
        model = self.source.with_suffix(".gnat-json")
        model.write_bytes(b"not a native model")
        cases = (
            (["--proof-dir", model], "duplicate or missing proof-directory argument", False),
            (["--proof-dir=first", "--proof-dir=second", model],
             "duplicate or missing proof-directory argument", False),
            ([model.with_name("missing.gnat-json")],
             "cannot read or snapshot a valid input model", True),
            ([model], "cannot read or snapshot a valid input model", True),
        )
        for arguments, reason, retained in cases:
            with self.subTest(arguments=arguments):
                before = set(HOST.artifacts.glob("imagews-*"))
                result = subprocess.run([HOST.image_adapter, *arguments], capture_output=True,
                                        text=True, timeout=10)
                self.assertEqual(result.returncode, 3, result.stdout + result.stderr)
                self.assertEqual(json.loads(result.stdout), {
                    "error": "Silver Image adapter: " + reason,
                    "internal": False, "results": [],
                })
                self.assertEqual(result.stderr, "")
                created = set(HOST.artifacts.glob("imagews-*")) - before
                self.assertEqual(len(created), int(retained))
                if arguments == [model]:
                    self.assertEqual((created.pop() / "original.gnat-json").read_bytes(),
                                     model.read_bytes())

    def test_unchanged_cleanup_retention_and_native_failure(self) -> None:
        model = self.source.with_suffix(".gnat-json")
        model.write_text(json.dumps({'theory_declarations': [
            ['W_THEORY_DECLARATION', 1, 3, None, 'Unselected_Theory', 0, None, '']]}))
        # An unrelated existing artifact must survive every cleanup call.
        old = Path(tempfile.mkdtemp(prefix="imagews-", dir=HOST.artifacts))
        marker = old / "earlier-evidence"
        marker.write_text("preserve")
        for flag, option, retained in (("", "--help", False),
                                        ("1", "--help", True),
                                        ("", "--silver-invalid-option", True)):
            with self.subTest(flag=flag, option=option):
                before = set(HOST.artifacts.glob("imagews-*"))
                with mock.patch.dict(os.environ, {"SILVER_KEEP_IMAGE_WORKSPACES": flag}):
                    result = subprocess.run([HOST.image_adapter, option, model], capture_output=True,
                                            text=True, timeout=10)
                if option == "--help":
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                else:
                    self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
                created = set(HOST.artifacts.glob("imagews-*")) - before
                self.assertEqual(len(created), int(retained))
                if retained:
                    self.assertEqual((created.pop() / "original.gnat-json").read_bytes(),
                                     model.read_bytes())
                self.assertEqual(marker.read_text(), "preserve")

    def test_wrong_image_width_never_reaches_proof(self) -> None:
        source = b'''with Silver_IO; procedure Main is pragma SPARK_Mode (On);
S : String := "x";
begin for I in -1 .. 1 loop S := Integer'Image (I); end loop; end Main;
'''
        self.source.write_bytes(source)
        before = set(HOST.artifacts.glob("program-*"))
        result = invoke("run", self.source)
        self.assertEqual(result.returncode, 2, result.stdout)
        self.assertEqual(self.source.read_bytes(), source)
        self.assertEqual(set(HOST.artifacts.glob("program-*")), before)


if __name__ == "__main__":
    unittest.main()
