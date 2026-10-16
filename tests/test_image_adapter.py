"""Production Image proof routing preserves source and required length checks."""
from __future__ import annotations

import json
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

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
        before = set(HOST.artifacts.glob("program-*"))
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
        report = json.loads((workspace / "obj/gnatprove/main.spark").read_text())
        checks = [item for item in report["proof"] if item["rule"] == "VC_LENGTH_CHECK"]
        self.assertTrue(checks, "loop assignment lost its original required length check")
        self.assertTrue(all(item["severity"] == "info" for item in checks), checks)
        # GNATprove normalizes its SARIF argv[0] to its basename. Identify the
        # adapter invocation by its exact preserved copy of Main's native model.
        original = (workspace / "obj/gnatprove/main.gnat-json").read_bytes()
        routed = [directory for directory in set(HOST.artifacts.glob("program-*")) - before
                  if (directory / "original.gnat-json").is_file()
                  and (directory / "original.gnat-json").read_bytes() == original
                  and (directory / "refined.gnat-json").is_file()]
        self.assertEqual(len(routed), 1)
        self.assertNotEqual((routed[0] / "refined.gnat-json").read_bytes(), original)
        self.assertTrue(list(routed[0].rglob("silver_image.mlw")))
        # Retain reports and the exact application snapshot as test evidence.

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
