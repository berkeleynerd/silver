"""Native Main discovery preserves source trivia and admitted name casing."""
from __future__ import annotations

import json
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

from scripts.check_evidence import IMAGE_ADVISORY_TEXT, audit_reports
from tests.test_silver import HOST, invoke


class MainDiscoveryTests(unittest.TestCase):
    def test_image_advisory_follows_main_unit_casing(self) -> None:
        with tempfile.TemporaryDirectory(prefix="silver-main-image-casing-") as directory:
            source = Path(directory) / "author.adb"
            for name, attribute in (("main", "image"), ("MAIN", "IMAGE")):
                with self.subTest(name=name):
                    data = (f"with Silver_IO;\nprocedure {name} is\n"
                            "   pragma SPARK_Mode (On);\nbegin\n"
                            "   Silver_IO.Put_Line (Integer'Image (1));\n"
                            f"end {name};\n").encode("ascii")
                    source.write_bytes(data)
                    checked = invoke("check", source)
                    self.assertEqual(checked.returncode, 0, checked.stdout)
                    result = invoke("run", source)
                    self.assertEqual(result.returncode, 0, result.stdout)
                    self.assertIn("Execution completed successfully.", result.stdout)
                    match = re.search(r"^Executable: (.+)$", result.stdout, re.MULTILINE)
                    self.assertIsNotNone(match, result.stdout)
                    executable = Path(match.group(1))
                    workspace = executable.parent.parent
                    self.assertEqual(source.read_bytes(), data)
                    self.assertEqual((workspace / "main.adb").read_bytes(), data)
                    reports = workspace / "obj/gnatprove"
                    stats = audit_reports(
                        reports, {"main", "silver_io", "silver_output_libc", "silver_arguments", "silver_runtime"},
                        {"silver_output_libc", "silver_runtime"}, application_kind="static", indexed_main=True)
                    report = json.loads((reports / "main~1.spark").read_text())
                    expected = IMAGE_ADVISORY_TEXT.replace('"Image"', f'"{attribute}"')
                    messages = [record["message"]["text"] for record in report["warn_error"]]
                    self.assertGreater(len(messages), 0)
                    self.assertEqual(messages, [expected] * len(messages))
                    self.assertEqual(stats["image_advisories"], len(messages))
                    execution = subprocess.run([str(executable)], capture_output=True, timeout=10)
                    self.assertEqual(execution.returncode, 0, execution.stderr)
                    self.assertEqual(execution.stdout, b" 1\n")
                    self.assertEqual(execution.stderr, b"")
                    # Preserve the proof/build workspaces as native repair evidence.

    def test_indexed_main_preserves_cr_source_in_all_shells(self) -> None:
        null = (b"procedure -- note\rMain is\n   pragma SPARK_Mode (On);\n"
                b"begin\n   null;\nend Main;\n")
        static = b"""with -- context\rSilver_IO;
procedure -- note\rMain is
   pragma SPARK_Mode (On);
   N : Integer range 0 .. 9 := 0;
   S : String := Integer'Image (N);
begin
   for I in 1 .. 2 loop
      N := I;
      S := Integer'Image (N);
      Silver_IO.Put_Line (S);
   end loop;
end Main;
"""
        argument = b"""-- leading\rwith Silver_IO, -- package\rSilver_Arguments;
procedure -- note\rMain is
   pragma SPARK_Mode (On);
   D : constant String := Silver_Arguments.First_Or_Default ("default");
begin
   if Silver_Arguments.Input_Is_Valid then
      Silver_IO.Put_Line (D);
   else
      Silver_Arguments.Reject;
   end if;
end Main;
"""
        cases = (
            ("null-cr", null, "run", None, [], b""),
            ("null-lf", null.replace(b"\r", b"\n"), "compile", None, [], b""),
            ("null-trivia", b"-- leading\r\t" + null.upper().replace(
                b"MAIN IS", b"MAIN -- second\r\tIS").replace(b"\n", b"\r")
                + b"-- trailing", "compile", None, [], b""),
            ("static-image-mutation", static, "run", "assigned", [], b" 1\n 2\n"),
            ("argument", argument, "compile", "argument", ["selected"], b"selected\n"),
        )
        with tempfile.TemporaryDirectory(prefix="silver-main-discovery-") as directory:
            source = Path(directory) / "author.adb"
            for name, data, command, kind, arguments, expected in cases:
                with self.subTest(case=name):
                    source.write_bytes(data)
                    checked = invoke("check", source)
                    self.assertEqual(checked.returncode, 0, checked.stdout)
                    result = invoke(command, source)
                    self.assertEqual(result.returncode, 0, result.stdout)
                    self.assertNotIn("does not match", result.stdout)
                    self.assertEqual("Execution completed successfully." in result.stdout,
                                     command == "run", result.stdout)
                    match = re.search(r"^Executable: (.+)$", result.stdout, re.MULTILINE)
                    self.assertIsNotNone(match, result.stdout)
                    executable = Path(match.group(1))
                    workspace = executable.parent.parent
                    self.assertEqual(workspace.parent, HOST.artifacts)
                    self.assertEqual(executable.name, "main")
                    self.assertEqual(source.read_bytes(), data)
                    self.assertEqual((workspace / "main.adb").read_bytes(), data)
                    project = (workspace / "program.gpr").read_text()
                    self.assertIn('for Body ("Main") use "main.adb" at 1;', project)
                    reports = workspace / "obj/gnatprove"
                    self.assertTrue((reports / "main~1.spark").is_file())
                    self.assertFalse((reports / "main.spark").exists())
                    self.assertTrue((workspace / "obj/main~1.ali").is_file())
                    units = {"main"}
                    imports = set()
                    if kind is not None:
                        units |= {"silver_io", "silver_output_libc", "silver_arguments", "silver_runtime"}
                        imports = {"silver_output_libc", "silver_runtime"}
                    stats = audit_reports(reports, units, imports, application_kind=kind,
                                          indexed_main=True)
                    self.assertEqual(stats["units"], len(units))
                    report = json.loads((reports / "main~1.spark").read_text())
                    main = [entity for entity in report["entities"].values()
                            if entity["name"].lower() == "main"]
                    self.assertEqual(len(main), 1)
                    self.assertTrue(all(Path(location["file"]).name == "main.adb"
                                        for location in main[0]["sloc"]))
                    execution = subprocess.run([str(executable), *arguments], capture_output=True,
                                               timeout=10)
                    self.assertEqual(execution.returncode, 0, execution.stderr)
                    self.assertEqual(execution.stdout, expected)
                    self.assertEqual(execution.stderr, b"")
                    # Keep these small workspaces as native repair evidence.


if __name__ == "__main__":
    unittest.main()
