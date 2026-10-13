"""Input-dependent String equality, terminal branches and native failure behavior."""
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


def source_for(default: bytes = b'brief', comparison: bytes = b'verbose',
               matched: bytes = b'Silver is ready. Input validation succeeded.',
               unmatched: bytes = b'Ready.', name: bytes = b'Mode',
               reference: bytes | None = None) -> bytes:
    def literal(value: bytes) -> bytes:
        return b'"' + value.replace(b'"', b'""') + b'"'

    return (b'with Silver_IO;with Silver_Arguments;procedure Main is '
            b'pragma SPARK_Mode(On);' + name
            + b':constant String:=Silver_Arguments.First_Or_Default('
            + literal(default) + b');begin if Silver_Arguments.Input_Is_Valid then if '
            + (name if reference is None else reference) + b'=' + literal(comparison)
            + b' then Silver_IO.Put_Line(' + literal(matched)
            + b');else Silver_IO.Put_Line(' + literal(unmatched)
            + b');end if;else Silver_Arguments.Reject;end if;end Main;')


def maximum_literal(index: int) -> tuple[bytes, bytes, bytes, bytes]:
    values = [b'brief', b'verbose', b'matched', b'unmatched']
    values[index] = b''
    values[index] = b'x' * (4096 - len(source_for(*values)))
    return tuple(values)


class BranchingTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver branching-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'branching.adb'

    def check_sources(self, cases: list[bytes], expected: int) -> None:
        for contents in cases:
            with self.subTest(length=len(contents), source=contents[:180]):
                self.source.write_bytes(contents)
                checked = invoke('check', self.source)
                self.assertEqual(checked.returncode, expected, checked.stdout)
                self.assertEqual(self.source.read_bytes(), contents)

    def test_admitted_literals_binding_and_layout(self) -> None:
        canonical = source_for()
        printable = bytes(range(32, 127))
        cases = [canonical, canonical.upper(), canonical + b'-- final comment',
                  canonical.replace(b'Silver_IO.Put_Line("Ready.");',
                                    b'Silver_IO.Put_Line(Mode);'),

                 source_for(b'', b'', b'', b''),
                 source_for(printable, printable, printable, printable),
                 source_for(b'" -- ', b'" -- ', b'"&"', b'else;end if;'),
                 source_for(name=b'Main', reference=b'mAIN'),
                 source_for(name=b'Name_2_A', reference=b'nAME_2_a'),
                 source_for(name=b'Standard', reference=b'sTANDARD'),
                 canonical.replace(b'Mode=', b'Mode -- bound name\r\n=\t'),
                 canonical.replace(b' then ', b' -- branch\rthen\t'),
                 canonical.replace(b';else ', b';-- next branch\nelse '),
                 canonical.replace(b';end if;', b';end-- matched end\r\nif;'),
                 canonical.replace(b':constant', b' -- declaration\n:constant')]
        cases += [canonical.replace(b'Mode="verbose"', replacement) for replacement in
                  (b'"verbose"=Mode', b'Mode=Mode', b'Mode=("verbose")', b'Mode="ver"&"bose"')]
        cases.append(canonical.replace(b';begin ', b';Other:constant String:="x";begin '))
        cases += [source_for(*maximum_literal(index)) for index in range(4)]
        name = b'X' * ((4096 - len(source_for(b'', b'', b'', b'', b''))) // 2)
        longest_name = source_for(b'', b'', b'', b'', name)
        cases.append(longest_name + b' ' * (4096 - len(longest_name)))
        self.check_sources(cases, 0)

    def test_rejected_guard_equality_and_branch_neighbours(self) -> None:
        canonical = source_for()
        cases = [source_for(reference=b'Other'), source_for(reference=b'Mode_2')]
        cases += [canonical.replace(b'Mode="verbose"', replacement) for replacement in
                  (b'Mode/="verbose"', b'Mode=="verbose"', b'Mode:="verbose"',
                   b'(Mode="verbose")',
                   b'Mode="verbose" and then True', b'True', b'not Mode="verbose"')]
        cases += [canonical.replace(b'with Silver_Arguments;', b''),
                  canonical.replace(b'with Silver_IO;with Silver_Arguments;',
                                    b'with Silver_Arguments;with Silver_IO;'),
                  canonical.replace(b':constant String', b':String'),
                  canonical.replace(b'First_Or_Default("brief")', b'First_Or_Default()'),
                  canonical.replace(b'Silver_Arguments.First_Or_Default("brief")', b'"brief"'),
                  canonical.replace(b'Input_Is_Valid', b'Input_Is_Valid()'),
                  canonical.replace(b'Input_Is_Valid', b'Input_Is_Valid=True'),
                  canonical.replace(b'if Silver_Arguments.Input_Is_Valid', b'if True'),
                  canonical.replace(b'if Silver_Arguments.Input_Is_Valid',
                                    b'if not Silver_Arguments.Input_Is_Valid'),
                  canonical.replace(b'if Silver_Arguments.Input_Is_Valid then ', b'')
                           .replace(b'else Silver_Arguments.Reject;end if;', b''),
                  canonical.replace(b'else Silver_Arguments.Reject;', b''),
                  canonical.replace(b'Silver_Arguments.Reject;', b'null;'),
                  canonical.replace(b'Silver_Arguments.Reject;', b'Silver_Arguments.Reject();'),
                  canonical.replace(b'Silver_IO.Put_Line("Ready.");', b''),
                  canonical.replace(b'else Silver_IO.Put_Line("Ready.");', b''),
                  canonical.replace(b'else Silver_IO.Put_Line("Ready.");',
                                    b'elsif Mode="brief" then Silver_IO.Put_Line("Ready.");'),
                  canonical.replace(b'Silver_IO.Put_Line("Ready.");',
                                    b'Silver_IO.Put_Line("Hi "&Mode&"!");'),
                  canonical.replace(b'Silver_IO.Put_Line("Ready.");',
                                    b'Mode:="other";'),
                  canonical.replace(b';end Main;', b';Silver_IO.Put_Line("after");end Main;'),
                  canonical.replace(b' then if Mode', b' then if True then if Mode')
                           .replace(b';else Silver_Arguments', b';end if;else Silver_Arguments'),
                  canonical + b'--\x0b hidden',
                  canonical + b' ' * (4097 - len(canonical))]
        for index in range(4):
            for invalid in (b'\t', b'\n', b'\r', b'\x7f', b'\x80'):
                values = [b'', b'', b'', b'']
                values[index] = invalid
                cases.append(source_for(*values))
        self.check_sources(cases, 2)

    def test_inner_arm_sequence_and_outer_reject_arm_have_separate_neighbours(self) -> None:
        canonical = source_for()
        inner_sequence = canonical.replace(b'Silver_IO.Put_Line("Ready.");',
                                           b'Silver_IO.Put_Line("Ready.");null;')
        self.check_sources([canonical, inner_sequence], 0)
        outer_sequence = inner_sequence.replace(b'Silver_Arguments.Reject;',
                                               b'Silver_Arguments.Reject;null;')
        self.check_sources([outer_sequence], 2)

    def test_excluded_declaration_names(self) -> None:
        reserved = '''abort abs abstract accept access aliased all and array at begin body
        case constant declare delay delta digits do else elsif end entry exception exit
        for function generic goto if in interface is limited loop mod new not null of or
        others out overriding package parallel pragma private procedure protected raise
        range record rem renames requeue return reverse select separate some subtype
        synchronized tagged task terminate then type until use when while with xor'''.split()
        self.assertEqual(len(reserved), 74)
        names = [b'', b'_x', b'1x', b'x_', b'x__y', b'x-y', b'String',
                 b'SILVER_IO', b'sIlVeR_aRgUmEnTs']
        names += [word.upper().encode('ascii') for word in reserved]
        self.check_sources([source_for(name=name) for name in names], 2)

    def compile(self, contents: bytes) -> Path:
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
        self.assertEqual(self.source.read_bytes(), contents)
        return executable

    def assert_run(self, executable: Path, arguments: tuple[bytes, ...],
                   expected: bytes | None) -> None:
        run = subprocess.run([bytes(executable), *arguments], capture_output=True, timeout=10)
        self.assertEqual((run.returncode, run.stdout, run.stderr),
                         (0, expected + b'\n', b'') if expected is not None else (1, b'', b''))

    def test_native_choice_argument_domain_and_output_failure(self) -> None:
        executable = self.compile(source_for())
        matched = b'Silver is ready. Input validation succeeded.'
        unmatched = b'Ready.'
        valid = [((), unmatched), ((b'verbose',), matched), ((b'',), unmatched),
                 ((b'Verbose',), unmatched), ((b'VERBOSE',), unmatched),
                 ((b'verbos',), unmatched), ((b'verboses',), unmatched),
                 ((b'verbosE',), unmatched), ((b'x' * 4096,), unmatched),
                 ((bytes(range(32, 127)),), unmatched)]
        invalid = [(b'x' * 4097,), (b'\t',), (b'\n',), (b'\r',), (b'\x7f',),
                   (b'\x80',), (b'caf\xc3\xa9',), (b'verbose', b'extra'), (b'', b'')]
        for arguments, expected in valid + [(args, None) for args in invalid]:
            with self.subTest(argument_lengths=[len(arg) for arg in arguments], expected=expected):
                self.assert_run(executable, arguments, expected)
        for arguments in (('verbose',), ('brief',)):
            with self.subTest(failed_branch=arguments):
                failed = subprocess.run(
                    [sys.executable, '-c',
                     'import os,sys;os.close(1);os.execv(sys.argv[1],sys.argv[1:])',
                     str(executable), *arguments], capture_output=True, timeout=10)
                self.assertEqual((failed.returncode, failed.stdout, failed.stderr), (1, b'', b''))
                if HOST.key.startswith('linux-'):
                    with open('/dev/full', 'wb', buffering=0) as full:
                        failed = subprocess.run([str(executable), *arguments], stdout=full,
                                                stderr=subprocess.PIPE, timeout=10)
                    self.assertEqual((failed.returncode, failed.stderr), (1, b''))

    def test_native_empty_escaped_and_maximum_literals(self) -> None:
        printable = bytes(range(32, 127))
        cases = [(b'', b'', b'', b'"different"'),
                 (printable, printable, printable[::-1], b'" -- unmatched')]
        cases += [maximum_literal(index) for index in range(4)]
        for default, comparison, matched, unmatched in cases:
            contents = source_for(default, comparison, matched, unmatched)
            if len(contents) < 4096:
                contents = source_for(default, comparison, matched, unmatched, b'Main', b'mAIN')
            with self.subTest(source_length=len(contents), value_lengths=[len(value) for value in
                              (default, comparison, matched, unmatched)]):
                executable = self.compile(contents)
                for arguments, expected in (((), matched if default == comparison else unmatched),
                                            ((comparison,), matched),
                                            ((comparison + b'!',), unmatched),
                                            ((b'',), matched if comparison == b'' else unmatched)):
                    with self.subTest(argument_lengths=[len(arg) for arg in arguments]):
                        self.assert_run(executable, arguments, expected)

    def test_native_maximum_binding(self) -> None:
        name = b'X' * ((4096 - len(source_for(b'', b'', b'', b'', b''))) // 2)
        contents = source_for(b'', b'', b'', b'', name, name.lower())
        contents += b' ' * (4096 - len(contents))
        executable = self.compile(contents)
        self.assert_run(executable, (), b'')


if __name__ == '__main__':
    unittest.main()
