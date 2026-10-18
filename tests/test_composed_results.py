"""Bounded output expressions and equal-length branch-selected results."""
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


def literal(value: bytes) -> bytes:
    return b'"' + value.replace(b'"', b'""') + b'"'


def source_for(expression: bytes, *, form: str = 'direct', initial: bytes = b'old',
               replacement: bytes = b'new', unmatched: bytes = b'old',
               default: bytes = b'pick', comparison: bytes = b'pick',
               alternative: bytes = b'"other"', capacity: bytes | None = None,
               name: bytes = b'Message', input_name: bytes = b'Input') -> bytes:
    arguments = form in ('argument', 'branching', 'result')
    source = b'with Silver_IO;'
    if arguments:
        source += b'with Silver_Arguments;'
    source += b'procedure Main is pragma SPARK_Mode(On);'
    if arguments:
        source += (input_name + b':constant String:=Silver_Arguments.First_Or_Default('
                   + literal(default) + b');')
    if form in ('static', 'assignment', 'result'):
        source += name + b':' + (b'constant ' if form == 'static' else b'')
        source += b'String:=' + literal(initial) + b';'
    source += b'begin '
    if arguments:
        source += b'if Silver_Arguments.Input_Is_Valid'
        if capacity is not None:
            source += b' and then ' + input_name + b"'Length<=" + capacity
        source += b' then '
    if form == 'assignment':
        source += name + b':=' + literal(replacement) + b';'
    if form in ('branching', 'result'):
        source += b'if ' + input_name + b'=' + literal(comparison) + b' then '
    if form == 'result':
        source += (name + b':=' + literal(replacement) + b';else '
                   + name + b':=' + literal(unmatched) + b';end if;')
    source += b'Silver_IO.Put_Line(' + expression + b');'
    if form == 'branching':
        source += b'else Silver_IO.Put_Line(' + alternative + b');end if;'
    if arguments:
        source += b'else Silver_Arguments.Reject;end if;'
    return source + b'end Main;'


class ComposedResultsTests(unittest.TestCase):
    def setUp(self) -> None:
        directory = tempfile.TemporaryDirectory(prefix='silver expressions-')
        self.addCleanup(directory.cleanup)
        self.source = Path(directory.name).resolve() / 'expressions.adb'

    def check_sources(self, cases: list[bytes], expected: int) -> None:
        for contents in cases:
            with self.subTest(length=len(contents), source=contents[:200]):
                self.source.write_bytes(contents)
                checked = invoke('check', self.source)
                self.assertEqual(checked.returncode, expected, checked.stdout)
                self.assertEqual(self.source.read_bytes(), contents)

    def test_flat_expressions_in_every_output_position(self) -> None:
        cases = [source_for(b'"a"&""&"b"'),
                 source_for(b'Message&"/"&mESSAGE', form='static'),
                 source_for(b'"unused constant"', form='static'),
                 source_for(b'"after:"&Message&Message', form='assignment'),
                 source_for(b'Input&""', form='argument'),
                 source_for(b'"["&Input&"]"', form='argument', capacity=b'40'),
                 source_for(b'Input&"matched"', form='branching', capacity=b'40',
                            alternative=b'"other"&Input'),
                 source_for(b'"literal"&"branch"', form='branching',
                            alternative=b'Input&""'),
                 source_for(b'Message&"/"&Message', form='result'),
                 source_for(b'Message&Input&Message', form='result', capacity=b'40'),
                 source_for(b'Main&Input', form='result', capacity=b'40', name=b'Main'),
                 source_for(b'Input&Standard', form='result', capacity=b'40', name=b'Standard')]
        cases += [source_for(b'Input', form='argument', capacity=value)
                  for value in (b'0', b'1', b'4096')]
        cases += [source_for(b'"static"', form='argument', capacity=b'0'),
                  source_for(b'Message', form='assignment', initial=b'"', replacement=b'x')]
        cases += [contents.replace(b';', b';-- boundary\r\n')
                  .replace(b'&', b'-- operator\r&\t') for contents in list(cases)]
        cases += [source_for(b'"unused"', form='assignment'), source_for(b'Input', form='result')]
        cases += [source_for(b'("x")'), source_for(b'Message&(Message)', form='static'),
                  source_for(b'Input&Input', form='argument', capacity=b'0'),
                  source_for(b'""&Input&Input', form='argument', capacity=b'0'),
                  source_for(b'Message', form='result').replace(b'Input="pick"', b'Message="pick"'),
                  source_for(b'Message&Input', form='result', capacity=b'40')
                  .replace(b'else Message:="old";', b'')]
        self.check_sources(cases, 0)

    def test_operand_and_expanded_output_boundaries(self) -> None:
        admitted = [source_for(b'&'.join([b'""'] * 64)),
                    source_for(b'&'.join([b'Message'] * 64), form='static', initial=b'x' * 64),
                    source_for(b'&'.join([b'Message'] * 64), form='assignment',
                               initial=b'x' * 64, replacement=b'y' * 64),
                    source_for(b'&'.join([b'Message'] * 63 + [b'Input']), form='result',
                               initial=b'x' * 65, replacement=b'y' * 65,
                               unmatched=b'z' * 65, capacity=b'1'),
                    source_for(b'Message&Input&Message', form='result',
                               initial=b'', replacement=b'', unmatched=b'', capacity=b'4096')]
        self.check_sources(admitted, 0)
        rejected = [source_for(b'&'.join([b'""'] * 65)),
                    source_for(b'&'.join([b'Message'] * 65), form='static', initial=b''),
                    source_for(b'&'.join([b'Message'] * 64), form='static', initial=b'x' * 65),
                    source_for(b'&'.join([b'Message'] * 64), form='assignment',
                               initial=b'x' * 65, replacement=b'y' * 65),
                    admitted[3].replace(b"'Length<=1", b"'Length<=2")]
        self.check_sources(rejected, 2)
        padded = admitted[3] + b' ' * (4096 - len(admitted[3]))
        self.check_sources([padded], 0)
        self.check_sources([padded + b' '], 2)

    def test_generalized_capacity_literals_keep_the_bound(self) -> None:
        self.check_sources([source_for(b'Input', form='argument', capacity=value)
                            for value in (b'00', b'01', b'1_0', b'1e0', b'16#1#')], 0)
        self.check_sources([source_for(b'Input', form='argument', capacity=value)
                            for value in (b'0_0_', b'1E-0', b'16#G#', b'4097')], 2)

    def test_rejected_operand_guard_and_binding_neighbours(self) -> None:
        cases = [source_for(expr, form='static') for expr in
                 (b'', b'&Message', b'Message&', b'Message&&Message', b'Message+Message',
                  b'Message&Other', b'1', b"'x'")]
        cases += [source_for(expr, form='argument', capacity=b'0') for expr in
                  (b'Other', b'Input(1..1)')]
        cases += [source_for(b'"x"&Input', form='argument'),
                  source_for(b'"x"&Input', form='argument', capacity=b'4096'),
                  source_for(b'Input', form='argument', capacity=b'4097'),
                  source_for(b'Message', form='result', initial=b'xx'),
                  source_for(b'Message', form='result', replacement=b'xx'),
                  source_for(b'Message', form='result', unmatched=b'xx'),
                  source_for(b'Message', form='result', input_name=b'MESSAGE'),
                  source_for(b'Silver_Arguments', form='result', name=b'Silver_Arguments')]
        cases += [source_for(b'Input', form='argument', capacity=value) for value in
                  (b'+1', b'1.0')]
        result = source_for(b'Message&Input', form='result', capacity=b'40')
        cases += [result.replace(b'Message:="new";', b'Other:="new";'),
                  result.replace(b'Message:="new";', b''),
                  result.replace(b'Input\'Length<=40', b'Message\'Length<=40'),
                  result.replace(b'else Silver_Arguments.Reject;', b''),
                  result.replace(b'&', b'&--\x0b invalid\n')]
        self.check_sources(cases, 2)

    def compile(self, contents: bytes, kind: str) -> tuple[Path, dict]:
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
                      {'silver_output_libc', 'silver_runtime'}, application_kind=kind, indexed_main=True)
        self.assertEqual(self.source.read_bytes(), contents)
        return executable, json.loads((reports / 'main~1.spark').read_text())

    def assert_run(self, executable: Path, arguments: list[bytes], expected: bytes | None) -> None:
        result = subprocess.run([bytes(executable), *arguments], capture_output=True, timeout=10)
        self.assertEqual((result.returncode, result.stdout, result.stderr),
                         (1, b'', b'') if expected is None else (0, expected + b'\n', b''))

    def assert_output_failure(self, executable: Path, argument: str | None = None) -> None:
        arguments = [] if argument is None else [argument]
        result = subprocess.run(
            [sys.executable, '-c',
             'import os,sys;os.close(1);os.execv(sys.argv[1],sys.argv[1:])',
             str(executable), *arguments], capture_output=True, timeout=10)
        self.assertEqual((result.returncode, result.stdout, result.stderr), (1, b'', b''))

    def test_native_static_shells_and_full_expanded_output(self) -> None:
        programs = [(source_for(b'"left"&""&"right"'), 'static', b'leftright'),
                    (source_for(b'Message&"/"&Message', form='static', initial=b'"'),
                     'static', b'"/"'),
                    (source_for(b'"after:"&Message&Message', form='assignment'),
                     'assigned', b'after:newnew'),
                    (source_for(b'&'.join([b'Message'] * 16), form='static', initial=b'x' * 256),
                     'static', b'x' * 4096)]
        for source, kind, expected in programs:
            with self.subTest(kind=kind, output_length=len(expected)):
                executable, _ = self.compile(source, kind)
                self.assert_run(executable, [], expected)
                self.assert_output_failure(executable)

    def test_native_guarded_expressions_and_branch_outputs(self) -> None:
        expression = b'"["&Input&"]"'
        for branching in (False, True):
            with self.subTest(branching=branching):
                source = source_for(expression, form='branching' if branching else 'argument',
                                    capacity=b'4', alternative=b'Input&"!"')
                executable, report = self.compile(source, 'argument')
                self.assertTrue(report['proof'], 'exercise genuine dynamic range checks')
                cases = [([], b'[pick]'), ([b'pick'], b'[pick]'),
                         ([b''], b'!' if branching else b'[]'),
                         ([b'four'], b'four!' if branching else b'[four]'),
                         ([b'12345'], None), ([b'bad\n'], None), ([b'\x80'], None),
                         ([b'one', b'two'], None)]
                for arguments, expected in cases:
                    self.assert_run(executable, arguments, expected)
                self.assert_output_failure(executable, 'pick')
                if branching:
                    self.assert_output_failure(executable, 'four')

    def test_native_tight_capacity_applies_to_default_and_empty_input(self) -> None:
        executable, _ = self.compile(
            source_for(b'"<"&Input&">"', form='argument', capacity=b'0'), 'argument')
        self.assert_run(executable, [], None)
        self.assert_run(executable, [b''], b'<>')
        self.assert_run(executable, [b'x'], None)
        self.assert_output_failure(executable, '')

    def test_native_branch_result_rejoins_with_maximal_expression(self) -> None:
        source = source_for(b'&'.join([b'Message'] * 15 + [b'Input']), form='result',
                            initial=b'x' * 273, replacement=b'y' * 273,
                            unmatched=b'z' * 273, default=b'Y', comparison=b'Y', capacity=b'1')
        executable, report = self.compile(source, 'selected')
        self.assertTrue(report['proof'], 'exercise the joined result and dynamic range policy')
        self.assertLessEqual(len(report['flow']), 1)
        for arguments, expected in [([], b'y' * 4095 + b'Y'), ([b'Y'], b'y' * 4095 + b'Y'),
                                    ([b'y'], b'z' * 4095 + b'y'), ([b''], b'z' * 4095),
                                    ([b'YY'], None), ([b'\n'], None), ([b'Y', b'X'], None)]:
            self.assert_run(executable, arguments, expected)
        self.assert_output_failure(executable, 'Y')
        self.assert_output_failure(executable, 'y')


if __name__ == '__main__':
    unittest.main()
