"""Literal-output admission and behavior through the actual SPARK compiler."""
from __future__ import annotations

import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

from scripts.check_evidence import audit_reports
from tests.test_silver import HOST, ROOT, invoke

PREFIX = b'with Silver_IO; procedure Main is pragma SPARK_Mode(On); begin Silver_IO.Put_Line('
SUFFIX = b'); end Main;'


def source_for(data: bytes) -> bytes:
    return PREFIX + b'"' + data.replace(b'"', b'""') + b'"' + SUFFIX


class LiteralOutputTests(unittest.TestCase):
    def setUp(self) -> None:
        directory = tempfile.TemporaryDirectory(prefix="silver output-")
        self.addCleanup(directory.cleanup)
        self.source = Path(directory.name) / "literal.adb"

    def test_literal_lexing_and_token_boundaries(self) -> None:
        cases = {
            "empty": source_for(b""),
            "all printable bytes": source_for(bytes(range(32, 127))),
            "comment markers are content": source_for(b'-- "begin"; end Main;'),
            "case sensitive content": PREFIX.upper() + b'"MiXeD"' + SUFFIX.upper(),
            "trivia around qualification": source_for(b"hello").replace(
                b"Silver_IO.Put_Line", b"Silver_IO -- dot next\r\n .\tPut_Line"),
            "leading trailing comments": b"-- before\r\n" + source_for(b"hello") + b"-- after",
            "maximum source": source_for(b"x" * (4096 - len(source_for(b"")))),
        }
        for label, data in cases.items():
            with self.subTest(label=label):
                self.source.write_bytes(data)
                result = invoke("check", self.source)
                self.assertEqual(result.returncode, 0, result.stdout)
                self.assertEqual(self.source.read_bytes(), data)

    def test_nearby_forms_are_excluded(self) -> None:
        valid = source_for(b"hello")
        cases = {
            "missing context": valid[len(b"with Silver_IO; "):],
            "different package": valid.replace(b"Silver_IO", b"Ada.Text_IO"),
            "different operation": valid.replace(b"Put_Line", b"Put"),
            "unqualified call": valid.replace(b"Silver_IO.Put_Line", b"Put_Line"),
            "use clause": b"use Silver_IO; " + valid,
            "second call": valid.replace(b"; end", b'; Silver_IO.Put_Line("more"); end'),
            "extra null": valid.replace(b"begin ", b"begin null; "),
            "context only": valid.replace(b'Silver_IO.Put_Line("hello")', b"null"),
            "identifier boundary": valid.replace(b"Put_Line", b"Put_Line2"),
            "concatenation": valid.replace(b'"hello"', b'"hel" & "lo"'),
            "missing closing quote": valid.replace(b'"hello"', b'"hello'),
            "bare doubled quotes": valid.replace(b'"hello"', b'"""'),
            "newline in literal": source_for(b"hel\nlo"),
            "tab in literal": source_for(b"hel\tlo"),
            "non ASCII": source_for(b"caf\xc3\xa9"),
            "forbidden comment byte": valid + b"--\x0bhidden",
            "too long": source_for(b"x" * (4097 - len(source_for(b"")))),
        }
        for label, data in cases.items():
            with self.subTest(label=label):
                self.source.write_bytes(data)
                result = invoke("check", self.source)
                self.assertEqual(result.returncode, 2, result.stdout)

    def compile(self, contents: bytes) -> Path:
        source = source_for(contents)
        self.source.write_bytes(source)
        result = invoke("compile", self.source)
        self.assertEqual(result.returncode, 0, result.stdout)
        match = re.search(r"^Executable: (.+)$", result.stdout, re.MULTILINE)
        self.assertIsNotNone(match, result.stdout)
        executable = Path(match.group(1))
        if not executable.is_absolute():
            executable = ROOT / executable
        workspace = executable.parent.parent
        self.assertEqual(workspace.parent, HOST.artifacts)
        self.addCleanup(shutil.rmtree, workspace)
        self.assertEqual((workspace / "main.adb").read_bytes(), source)
        for name in ("silver_io.ads", "silver_io.adb", "silver_output_libc.ads"):
            self.assertEqual((workspace / name).read_bytes(), (ROOT / "src" / name).read_bytes())
        statistics = audit_reports(workspace / "obj/gnatprove",
                                   {"main", "silver_io", "silver_output_libc"},
                                   {"silver_output_libc"})
        self.assertGreater(statistics["proof_checks"], 0)
        main = json.loads((workspace / "obj/gnatprove/main.spark").read_text())
        self.assertEqual(main["flow"], [])
        self.assertEqual(main["proof"], [])
        return executable

    def test_empty_escaped_and_maximum_literals_execute(self) -> None:
        maximum = 4096 - len(source_for(b""))
        for contents in (b"", bytes(range(32, 127)), b"x" * maximum):
            with self.subTest(length=len(contents)):
                executable = self.compile(contents)
                run = subprocess.run([str(executable)], capture_output=True, timeout=10)
                self.assertEqual(run.returncode, 0, run.stderr)
                self.assertEqual(run.stdout, contents + b"\n")
                self.assertEqual(run.stderr, b"")

    def test_output_failure_cannot_report_success(self) -> None:
        executable = self.compile(b"failure check")
        # Linux's full device deterministically fails writes. This exercises
        # flushing failure for the default buffered C stdout stream.
        if HOST.key.startswith("linux-"):
            with open("/dev/full", "wb", buffering=0) as full:
                run = subprocess.run([str(executable)], stdout=full,
                                     stderr=subprocess.PIPE, timeout=10)
            self.assertNotEqual(run.returncode, 0)
        # Closing stdout is portable across supported POSIX hosts. The Python
        # process only supplies the environment; it does not replace the app.
        run = subprocess.run([sys.executable, "-c",
                              "import os, sys; os.close(1); os.execv(sys.argv[1], [sys.argv[1]])",
                              str(executable)], capture_output=True, timeout=10)
        self.assertNotEqual(run.returncode, 0)
        self.assertEqual(run.stdout, b"")


if __name__ == "__main__":
    unittest.main()
