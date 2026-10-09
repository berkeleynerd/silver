"""Named constant binding, lexical boundaries and unchanged source compilation."""
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


def source_for(value: bytes, name: bytes = b'Message', reference: bytes | None = None) -> bytes:
    return (b'with Silver_IO; procedure Main is pragma SPARK_Mode(On); '
            + name + b':constant String:="' + value.replace(b'"', b'""')
            + b'";begin Silver_IO.Put_Line(' + (name if reference is None else reference)
            + b');end Main;')


class NamedOutputTests(unittest.TestCase):
    def setUp(self) -> None:
        directory = tempfile.TemporaryDirectory(prefix='silver named-')
        self.addCleanup(directory.cleanup)
        self.source = Path(directory.name).resolve() / 'named.adb'

    def test_names_and_declaration_trivia(self) -> None:
        valid = source_for(b'Hello')
        cases = [source_for(b'', b'A'), source_for(b'" -- MiXeD', b'Main', b'mAiN'),
                 source_for(b'Hello', b'Name_2_A', b'nAME_2_a'),
                 valid.replace(b':constant', b' : -- declaration\r\nconstant'),
                 valid.replace(b'String:=', b'String -- initialization\n := '),
                 valid + b'-- final comment',
                 source_for(b'x' * (4096 - len(source_for(b''))))]
        longest_name = b'X' * ((4096 - len(source_for(b'', b''))) // 2)
        longest = source_for(b'', longest_name)
        cases.append(longest + b' ' * (4096 - len(longest)))
        for contents in cases:
            with self.subTest(length=len(contents), start=contents[:90]):
                self.source.write_bytes(contents)
                result = invoke('check', self.source)
                self.assertEqual(result.returncode, 0, result.stdout)

    def test_excluded_names_and_nearby_forms(self) -> None:
        reserved = '''abort abs abstract accept access aliased all and array at begin body
        case constant declare delay delta digits do else elsif end entry exception exit
        for function generic goto if in interface is limited loop mod new not null of or
        others out overriding package parallel pragma private procedure protected raise
        range record rem renames requeue return reverse select separate some subtype
        synchronized tagged task terminate then type until use when while with xor'''.split()
        self.assertEqual(len(reserved), 74)
        excluded = [b'', b'_x', b'1x', b'x_', b'x__y', b'x-y', b'String', b'SILVER_IO']
        excluded += [word.upper().encode('ascii') for word in reserved]
        cases = [source_for(b'Hello', name) for name in excluded]
        valid = source_for(b'Hello')
        cases += [source_for(b'Hello', b'Message', b'Other'),
                  source_for(b'Hello', b'Message', b'Message_2'),
                  valid.replace(b':constant', b':'),
                  valid.replace(b'String', b'Integer'),
                  valid.replace(b':=', b': ='),
                  valid.replace(b':=', b':-- split\n='),
                  valid.replace(b'"Hello"', b'"Hel" & "lo"'),
                  valid.replace(b'begin ', b'Other:constant String:="Hi";begin '),
                  valid.replace(b'Put_Line(Message)', b'Put_Line("Hello")'),
                  valid.replace(b'Put_Line(Message)', b'Put_Line(Message(1..2))'),
                  valid.replace(b';end ', b';null;end '),
                  source_for(b'\t'), source_for(b'\x80'),
                  valid + b'--\x0b hidden',
                  source_for(b'x' * (4097 - len(source_for(b''))))]
        for contents in cases:
            with self.subTest(source=contents[:120]):
                self.source.write_bytes(contents)
                result = invoke('check', self.source)
                self.assertEqual(result.returncode, 2, result.stdout)

    def test_native_empty_escaped_and_boundary_constants(self) -> None:
        longest_name = b'X' * ((4096 - len(source_for(b'', b''))) // 2)
        cases = [(b'', b'Main', b'mAiN'), (b'" -- MiXeD', b'A_2', b'a_2'),
                 (b'local name', b'Silver_Arguments', b'sILVER_aRGUMENTS'),
                 (b'', longest_name, longest_name),
                 (b'x' * (4096 - len(source_for(b''))), b'Message', b'Message')]
        sources = [(source_for(value, name, reference), value) for value, name, reference in cases]
        # Remove optional trivia around semicolons in the empty-value template
        # to exercise the tighter bound, not merely the spaced template's bound.
        overhead = len(source_for(b'', b'').replace(b'; ', b';'))
        compact_name = b'X' * ((4096 - overhead) // 2)
        compact = source_for(b'', compact_name).replace(b'; ', b';')
        sources.append((compact + b' ' * (4096 - len(compact)), b''))
        for data, value in sources:
            with self.subTest(source_length=len(data), value_length=len(value)):
                self.source.write_bytes(data)
                result = invoke('compile', self.source)
                self.assertEqual(result.returncode, 0, result.stdout)
                match = re.search(r'^Executable: (.+)$', result.stdout, re.MULTILINE)
                self.assertIsNotNone(match, result.stdout)
                executable = Path(match.group(1))
                if not executable.is_absolute():
                    executable = ROOT / executable
                workspace = executable.parent.parent
                self.assertEqual(workspace.parent, HOST.artifacts)
                self.addCleanup(shutil.rmtree, workspace)
                self.assertEqual((workspace / 'main.adb').read_bytes(), data)
                reports = workspace / 'obj/gnatprove'
                audit_reports(reports, {'main', 'silver_io', 'silver_output_libc', 'silver_arguments', 'silver_runtime'},
                              {'silver_output_libc', 'silver_runtime'})
                main = json.loads((reports / 'main.spark').read_text())
                self.assertEqual(main['flow'], [])
                self.assertEqual(main['proof'], [])
                execution = subprocess.run([str(executable)], capture_output=True, timeout=10)
                self.assertEqual(execution.returncode, 0, execution.stderr)
                self.assertEqual(execution.stdout, value + b'\n')
                self.assertEqual(execution.stderr, b'')
                failed_output = subprocess.run(
                    [sys.executable, '-c',
                     'import os, sys; os.close(1); os.execv(sys.argv[1], [sys.argv[1]])',
                     str(executable)], capture_output=True, timeout=10)
                self.assertEqual(failed_output.returncode, 1, failed_output.stderr)
                self.assertEqual(failed_output.stdout, b'')
                self.assertEqual(failed_output.stderr, b'')
                self.assertEqual(self.source.read_bytes(), data)


if __name__ == '__main__':
    unittest.main()
