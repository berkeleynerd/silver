"""Literal-backed concatenation: closed syntax, decoded bounds and native output."""
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
from tests.test_arguments import source_for as argument_source
from tests.test_silver import HOST, ROOT, invoke


def source_for(value: bytes = b'world', prefix: bytes = b'Hello, ',
               suffix: bytes = b'!', name: bytes = b'Name',
               reference: bytes | None = None) -> bytes:
    def literal(part: bytes) -> bytes:
        return b'"' + part.replace(b'"', b'""') + b'"'

    return (b'with Silver_IO; procedure Main is pragma SPARK_Mode(On); '
            + name + b':constant String:=' + literal(value)
            + b';begin Silver_IO.Put_Line(' + literal(prefix) + b'&'
            + (name if reference is None else reference) + b'&' + literal(suffix)
            + b');end Main;')


class GreetingTests(unittest.TestCase):
    def setUp(self) -> None:
        directory = tempfile.TemporaryDirectory(prefix='silver greeting-')
        self.addCleanup(directory.cleanup)
        self.source = Path(directory.name).resolve() / 'greeting.adb'

    def test_closed_form_admission(self) -> None:
        canonical = source_for()
        cases = [canonical,
                 source_for(b'', b'', b'', b'Main', b'mAiN'),
                 source_for(b'"--', b'" & ', b'"', b'Silver_Arguments', b'sILVER_aRGUMENTS'),
                 source_for(b'x', b'y', b'z', b'Name_2_A', b'nAME_2_a'),
                 canonical.replace(b'&', b' -- operator\r\n&\t'),
                 canonical.replace(b'&Name&', b'&-- before reference\nName-- after reference\r&'),
                 canonical.upper(), canonical + b' -- final & comment']
        # Flat expressions now compose across the earlier greeting shell.
        cases += [canonical.replace(b'"Hello, "&Name&"!"', replacement) for replacement in
                  (b'"Hello, "&"world"&"!"', b'Name&Name&"!"', b'"Hello, "&Name&Name',
                   b'Name&"Hello, "&"!"', b'"Hello, "&"!"&Name', b'"Hello, "&Name',
                   b'Name&"!"', b'"Hello, "&Name&"!"&"extra"')]
        room = 4096 - len(source_for(b'', b'', b''))
        cases.extend((source_for(b'x' * room, b'', b''),
                      source_for(b'', b'x' * room, b''),
                      source_for(b'', b'', b'x' * room)))
        name = b'X' * ((4096 - len(source_for(b'', b'', b'', b''))) // 2)
        longest = source_for(b'', b'', b'', name)
        cases.append(longest + b' ' * (4096 - len(longest)))
        for contents in cases:
            with self.subTest(length=len(contents), source=contents[:110]):
                self.source.write_bytes(contents)
                result = invoke('check', self.source)
                self.assertEqual(result.returncode, 0, result.stdout)
                self.assertEqual(self.source.read_bytes(), contents)

    def test_excluded_neighbour_expressions(self) -> None:
        canonical = source_for()
        expression = b'"Hello, "&Name&"!"'
        replacements = [b'("Hello, "&Name)&"!"', b'"Hello, "&(Name&"!")',
                        b'"Hello, "&Name(1..2)&"!"', b'"Hello, "+Name+"!"',
                        b'"Hello, "&&Name&"!"', b'"Hello, "&Other&"!"']
        cases = [canonical.replace(expression, replacement) for replacement in replacements]
        cases += [source_for(name=name) for name in
                  (b'', b'1Name', b'Name_', b'Name__2', b'String', b'SILVER_IO', b'if')]
        cases += [canonical.replace(b'"world"', b'"wo"&"rld"'),
                  canonical.replace(b';end', b';null;end'),
                  argument_source().replace(b'Put_Line(Message)', b'Put_Line("Hello, "&Message&"!")'),
                  source_for(b'\t'), source_for(prefix=b'\n'), source_for(suffix=b'\x80'),
                  canonical + b'--\x0b hidden',
                  canonical + b' ' * (4097 - len(canonical))]
        for contents in cases:
            with self.subTest(length=len(contents), source=contents[:150]):
                self.source.write_bytes(contents)
                result = invoke('check', self.source)
                self.assertEqual(result.returncode, 2, result.stdout)

    def test_shared_binding_lists_and_mutable_greeting_operand(self) -> None:
        canonical = source_for()
        for contents in (canonical.replace(b':constant', b':'),
                         canonical.replace(b';begin', b';Other:constant String:="x";begin')):
            with self.subTest(source=contents):
                self.source.write_bytes(contents)
                result = invoke('check', self.source)
                self.assertEqual(result.returncode, 0, result.stdout)

    def test_native_decoded_output_boundaries_names_and_failure(self) -> None:
        room = 4096 - len(source_for(b'', b'', b''))
        cases = [(b'world', b'Hello, ', b'!', b'Name', b'Name'),
                 (b'', b'', b'', b'Main', b'mAiN'),
                 (b'" -- ', b'& "', b'" &', b'Silver_Arguments', b'sILVER_aRGUMENTS'),
                 (bytes(range(32, 127)), b'prefix ', b' suffix', b'Standard', b'Standard'),
                 (b'x' * room, b'', b'', b'Name', b'Name'),
                 (b'', b'x' * room, b'', b'Name', b'Name'),
                 (b'', b'', b'x' * room, b'Name', b'Name'),
                 (b'v' * (room // 3), b'p' * (room // 3),
                  b's' * (room - 2 * (room // 3)), b'Name', b'Name')]
        sources = [(source_for(value, prefix, suffix, name, reference), prefix + value + suffix)
                   for value, prefix, suffix, name, reference in cases]
        # Exercise a maximum-length identifier with optional trivia removed.
        overhead = len(source_for(b'', b'', b'', b'').replace(b'; ', b';'))
        name = b'X' * ((4096 - overhead) // 2)
        compact = source_for(b'', b'', b'', name).replace(b'; ', b';')
        sources.append((compact + b' ' * (4096 - len(compact)), b''))
        for contents, expected in sources:
            with self.subTest(source_length=len(contents), output_length=len(expected)):
                self.source.write_bytes(contents)
                compiled = invoke('compile', self.source)
                self.assertEqual(compiled.returncode, 0, compiled.stdout)
                match = re.search(r'^Executable: (.+)$', compiled.stdout, re.MULTILINE)
                self.assertIsNotNone(match, compiled.stdout)
                executable = Path(match.group(1))
                if not executable.is_absolute():
                    executable = ROOT / executable
                workspace = executable.parent.parent
                self.assertEqual(workspace.parent, HOST.artifacts)
                self.addCleanup(shutil.rmtree, workspace)
                self.assertEqual((workspace / 'main.adb').read_bytes(), contents)
                reports = workspace / 'obj/gnatprove'
                audit_reports(reports, {'main', 'silver_io', 'silver_output_libc',
                                        'silver_arguments', 'silver_runtime'},
                              {'silver_output_libc', 'silver_runtime'})
                main = json.loads((reports / 'main.spark').read_text())
                self.assertEqual(main['flow'], [])
                self.assertEqual(main['proof'], [])
                run = subprocess.run([str(executable)], capture_output=True, timeout=10)
                self.assertEqual(run.returncode, 0, run.stderr)
                self.assertEqual(run.stdout, expected + b'\n')
                self.assertEqual(run.stderr, b'')
                failed = subprocess.run(
                    [sys.executable, '-c',
                     'import os,sys;os.close(1);os.execv(sys.argv[1],[sys.argv[1]])',
                     str(executable)], capture_output=True, timeout=10)
                self.assertEqual(failed.returncode, 1, failed.stderr)
                self.assertEqual(failed.stdout, b'')
                self.assertEqual(failed.stderr, b'')
                self.assertEqual(self.source.read_bytes(), contents)


if __name__ == '__main__':
    unittest.main()
