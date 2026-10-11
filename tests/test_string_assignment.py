"""Fixed-length variable assignment: binding, decoded lengths and exact output."""
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


def source_for(initial: bytes = b'Hello', assigned: bytes = b'World',
               name: bytes = b'Message', target: bytes | None = None,
               reference: bytes | None = None) -> bytes:
    def literal(value: bytes) -> bytes:
        return b'"' + value.replace(b'"', b'""') + b'"'

    return (b'with Silver_IO;procedure Main is pragma SPARK_Mode(On);'
            + name + b':String:=' + literal(initial) + b';begin '
            + (name if target is None else target) + b':=' + literal(assigned)
            + b';Silver_IO.Put_Line(' + (name if reference is None else reference)
            + b');end Main;')


class StringAssignmentTests(unittest.TestCase):
    def setUp(self) -> None:
        directory = tempfile.TemporaryDirectory(prefix='silver assignment-')
        self.addCleanup(directory.cleanup)
        self.source = Path(directory.name).resolve() / 'assignment.adb'

    def check_sources(self, cases: list[bytes], expected: int) -> None:
        for contents in cases:
            with self.subTest(length=len(contents), source=contents[:180]):
                self.source.write_bytes(contents)
                checked = invoke('check', self.source)
                self.assertEqual(checked.returncode, expected, checked.stdout)
                self.assertEqual(self.source.read_bytes(), contents)

    def test_admitted_decoded_lengths_names_and_layout(self) -> None:
        canonical = source_for()
        cases = [canonical, canonical.upper(), canonical + b'-- final comment',
                 canonical.replace(b'Put_Line(Message)', b'Put_Line("Hi "&Message&"!")'),

                 source_for(b'', b'', b'Main', b'mAIN', b'MaIn'),
                 source_for(b'A', b'"'), source_for(b'"', b'Z'),
                 source_for(b'" --', b'MiXe', b'Silver_Arguments',
                            b'sILVER_aRGUMENTS', b'SILVER_ARGUMENTS'),
                 source_for(b'old', b'new', b'Name_2_A', b'nAME_2_a', b'NaMe_2_A'),
                 canonical.replace(b':String', b' -- declaration\r\n: String'),
                 canonical.replace(b':=', b'\t:= -- value\r\n'),
                 canonical.replace(b';begin ', b';-- initialized\nbegin\t'),
                 canonical.replace(b';Silver_IO', b';-- assigned\rSilver_IO'),
                 canonical.replace(b'Put_Line(Message)', b'Put_Line(-- name\nMessage\t)')]
        room = (4096 - len(source_for(b'', b''))) // 2
        longest_values = source_for(b'x' * room, b'y' * room)
        cases.append(longest_values + b' ' * (4096 - len(longest_values)))
        name = b'X' * ((4096 - len(source_for(b'', b'', b''))) // 3)
        longest_name = source_for(b'', b'', name)
        cases.append(longest_name + b' ' * (4096 - len(longest_name)))
        self.check_sources(cases, 0)

    def test_rejected_lengths_bindings_and_compositions(self) -> None:
        canonical = source_for()
        cases = [source_for(b'', b'x'), source_for(b'x', b''),
                 source_for(b'Hello', b'World!'), source_for(b'Hello', b'Worl'),
                 # Equal raw literal spans must not hide unequal decoded lengths.
                 source_for(b'"', b'AA'), source_for(b'AA', b'"'),
                 source_for(target=b'Other'), source_for(reference=b'Other'),
                 source_for(target=b'Message_2'), source_for(reference=b'Message_2'),
                 canonical.replace(b':String', b':constant String'),
                 canonical.replace(b':String', b':String(1..5)'),
                 canonical.replace(b':String', b':Integer'),
                 canonical.replace(b':="Hello"', b''),
                 canonical.replace(b'"Hello"', b'Silver_Arguments.First_Or_Default("Hello")'),
                 canonical.replace(b'"World"', b'Message'),
                 canonical.replace(b'"World"', b'"Wo"&"rld"'),
                 canonical.replace(b'"World"', b'("World")'),
                 canonical.replace(b'begin Message:=', b'begin Message(1..5):='),
                 canonical.replace(b'begin Message:=', b'begin Message= '),
                 canonical.replace(b'begin Message:=', b'begin Message: ='),
                 canonical.replace(b'begin Message:=', b'begin Message:-- split\n='),
                 canonical.replace(b'begin Message:="World";', b'begin '),
                 canonical.replace(b';Silver_IO', b';Message:="Again";Silver_IO'),
                 canonical.replace(b';begin', b';Other:String:="Other";begin'),
                 canonical.replace(b'Put_Line(Message)', b'Put_Line("World")'),
                 canonical.replace(b'begin Message:="World";Silver_IO.Put_Line(Message);',
                                   b'begin Silver_IO.Put_Line(Message);Message:="World";'),
                 canonical.replace(b';end ', b';null;end '),
                 b'with Silver_Arguments;' + canonical,
                 source_for(b'\t', b'x'), source_for(b'x', b'\n'),
                 source_for(b'\x80', b'x'), source_for(b'x', b'\x80'),
                 canonical + b'--\x0b hidden',
                 canonical + b' ' * (4097 - len(canonical))]
        self.check_sources(cases, 2)

    def test_excluded_declaration_names(self) -> None:
        reserved = '''abort abs abstract accept access aliased all and array at begin body
        case constant declare delay delta digits do else elsif end entry exception exit
        for function generic goto if in interface is limited loop mod new not null of or
        others out overriding package parallel pragma private procedure protected raise
        range record rem renames requeue return reverse select separate some subtype
        synchronized tagged task terminate then type until use when while with xor'''.split()
        self.assertEqual(len(reserved), 74)
        names = [b'', b'_x', b'1x', b'x_', b'x__y', b'x-y', b'String', b'SILVER_IO']
        names += [word.upper().encode('ascii') for word in reserved]
        self.check_sources([source_for(name=name) for name in names], 2)

    def test_native_replacement_boundaries_and_output_failure(self) -> None:
        room = (4096 - len(source_for(b'', b''))) // 2
        cases = [(source_for(), b'World'),
                 (source_for(b'', b'', b'Main', b'mAIN', b'MaIn'), b''),
                 (source_for(b'A', b'"'), b'"'),
                 (source_for(b'"', b'Z'), b'Z'),
                 (source_for(b'old', b'new', b'Unused_Message'), b'new'),
                 (source_for(b'" --', b'MiXe', b'Silver_Arguments',
                             b'sILVER_aRGUMENTS', b'SILVER_ARGUMENTS'), b'MiXe'),
                 (source_for(bytes(range(32, 127)), bytes(reversed(range(32, 127))),
                             b'Standard', b'sTANDARD', b'STANDARD'),
                  bytes(reversed(range(32, 127)))),
                 (source_for(b'x' * room, b'y' * room), b'y' * room)]
        name = b'X' * ((4096 - len(source_for(b'', b'', b''))) // 3)
        cases.append((source_for(b'', b'', name), b''))
        for contents, expected in cases:
            if len(contents) > 4000:
                contents += b' ' * (4096 - len(contents))
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
                              {'silver_output_libc', 'silver_runtime'},
                              application_kind="assigned")
                main = json.loads((reports / 'main.spark').read_text())
                self.assertLessEqual(len(main['flow']), 1)
                for advisory in main['flow']:
                    self.assertEqual(advisory['rule'], 'INEFFECTIVE')
                    self.assertEqual(advisory['severity'], 'warning')
                self.assertEqual(main['proof'], [])
                run = subprocess.run([str(executable)], capture_output=True, timeout=10)
                self.assertEqual((run.returncode, run.stdout, run.stderr),
                                 (0, expected + b'\n', b''))
                failed = subprocess.run(
                    [sys.executable, '-c',
                     'import os,sys;os.close(1);os.execv(sys.argv[1],[sys.argv[1]])',
                     str(executable)], capture_output=True, timeout=10)
                self.assertEqual((failed.returncode, failed.stdout, failed.stderr), (1, b'', b''))
                self.assertEqual(self.source.read_bytes(), contents)


if __name__ == '__main__':
    unittest.main()
