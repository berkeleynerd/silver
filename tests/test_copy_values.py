"""Literal-backed String copies, distinct bindings, fixed lengths and output."""
from __future__ import annotations

import itertools
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

from scripts.check_evidence import audit_reports
from tests.test_composed_results import literal
from tests.test_silver import HOST, ROOT, invoke


def source_for(*, constants: tuple[tuple[bytes, bytes], ...] =
               ((b'Ready', b'ready'), (b'Detailed', b'extra')),
               initial: bytes = b'Ready', assigned: bytes = b'Detailed',
               alternative: bytes = b'Ready', output: bytes = b'Result',
               selected: bool = False, capacity: bytes | None = None,
               name: bytes = b'Result', input_name: bytes = b'Mode') -> bytes:
    """Initializer/RHS parameters are source operands; constant values are bytes."""
    source = b'with Silver_IO;'
    if selected:
        source += b'with Silver_Arguments;'
    source += b'procedure Main is pragma SPARK_Mode(On);'
    if selected:
        source += (input_name + b':constant String:='
                   b'Silver_Arguments.First_Or_Default("brief");')
    source += b''.join(key + b':constant String:=' + literal(value) + b';'
                       for key, value in constants)
    source += name + b':String:=' + initial + b';begin '
    if selected:
        source += b'if Silver_Arguments.Input_Is_Valid'
        if capacity is not None:
            source += b' and then ' + input_name + b"'Length<=" + capacity
        source += (b' then if ' + input_name + b'="verbose" then '
                   + name + b':=' + assigned + b';else '
                   + name + b':=' + alternative + b';end if;')
    else:
        source += name + b':=' + assigned + b';'
    source += b'Silver_IO.Put_Line(' + output + b');'
    if selected:
        source += b'else Silver_Arguments.Reject;end if;'
    return source + b'end Main;'


class CopyValuesTests(unittest.TestCase):
    def setUp(self) -> None:
        directory = tempfile.TemporaryDirectory(prefix='silver copies-')
        self.addCleanup(directory.cleanup)
        self.source = Path(directory.name).resolve() / 'copies.adb'

    def check_sources(self, sources: list[bytes], expected: int) -> None:
        before = set(HOST.artifacts.glob('program-*'))
        for contents in sources:
            with self.subTest(length=len(contents), source=contents[:220]):
                self.source.write_bytes(contents)
                result = invoke('check', self.source)
                self.assertEqual(result.returncode, expected, result.stdout)
                self.assertEqual(self.source.read_bytes(), contents)
        self.assertEqual(set(HOST.artifacts.glob('program-*')), before)

    def test_literals_and_each_constant_at_every_copy_position(self) -> None:
        cases = []
        constants = ((b'Ready', b'ready'), (b'Detailed', b'extra'))
        for count in range(3):
            bindings = constants[:count]
            operands = [b'"other"', *(key for key, _ in bindings)]
            for initial, assigned in itertools.product(operands, repeat=2):
                cases.append(source_for(constants=bindings, initial=initial, assigned=assigned))
            for initial, assigned, alternative in itertools.product(operands, repeat=3):
                cases.append(source_for(constants=bindings, initial=initial, assigned=assigned,
                                        alternative=alternative, selected=True))
        self.check_sources(cases, 0)

    def test_distinct_names_decoded_values_and_layout(self) -> None:
        empty = ((b'Ready', b''), (b'Detailed', b''))
        quotes = ((b'Ready', b'"'), (b'Detailed', b'!'))
        cases = [source_for(constants=empty, output=b'Ready&Result&Detailed'),
                 source_for(constants=empty, selected=True, output=b'Result&Mode', capacity=b'0'),
                 source_for(constants=quotes, output=b'Ready&Result&Detailed'),
                 source_for(constants=quotes, selected=True),
                 source_for(constants=((b'Ready', b'ready'), (b'Decoration', b'!')),
                            assigned=b'Ready', output=b'Decoration&Result&Decoration'),
                 source_for(constants=((b'Unused_A', b'a'), (b'Unused_B', b'unused')),
                            initial=b'"ready"', assigned=b'"extra"'),
                 source_for(constants=((b'Seed', b'ready'),), initial=b'Seed',
                            assigned=b'"extra"'),
                 source_for(constants=((b'Main', b'ready'),), initial=b'mAIN',
                            assigned=b'MAIN'),
                 source_for(constants=((b'Silver_Arguments', b'ready'),),
                            initial=b'sILVER_aRGUMENTS', assigned=b'SILVER_ARGUMENTS'),
                 source_for(constants=((b'Ready_1_A', b'ready'), (b'Detailed_2', b'extra')),
                            initial=b'rEADY_1_a', assigned=b'dETAILED_2',
                            alternative=b'READY_1_A', output=b'reSULT&Ready_1_A', selected=True),
                 source_for(name=b'Main', output=b'mAIN', selected=True)]
        ordinary = source_for(selected=True, output=b'Ready&Result&Detailed')
        cases += [ordinary.upper(), ordinary + b'-- final comment',
                  ordinary.replace(b':=', b':=-- value\r\n')
                  .replace(b'&', b'-- next operand\n&\t')]
        self.check_sources(cases, 0)

    def test_operand_output_capacity_and_complete_source_bounds(self) -> None:
        bindings = ((b'Ready', b'a' * 256), (b'Detailed', b'b' * 256))
        expression = b'&'.join([b'Ready', b'Detailed'] * 7 + [b'Ready', b'Result'])
        full = source_for(constants=bindings, output=expression)
        padded = full + b' ' * (4096 - len(full))
        guarded = source_for(output=b'Ready&Result&Detailed&Mode', selected=True, capacity=b'4081')
        self.check_sources([full, padded, guarded,
                            source_for(constants=((b'Ready', b''), (b'Detailed', b'')),
                                       output=b'&'.join([b'Ready'] * 15 + [b'Result']))], 0)
        rejected = [source_for(constants=bindings, output=expression + b'&""'),
                    source_for(constants=((b'Ready', b'a' * 257), (b'Detailed', b'b' * 257)),
                               output=expression),
                    guarded.replace(b"'Length<=4081", b"'Length<=4082"),
                    guarded.replace(b" and then Mode'Length<=4081", b''),
                    guarded.replace(b'&Mode)', b'&Mode&Mode)'),
                    source_for(output=b'Ready&Detailed'),
                    source_for(output=b'Ready&Detailed&Mode', selected=True, capacity=b'10'),
                    padded + b' ']
        self.check_sources(rejected, 2)

    def test_rejected_copy_sources_lengths_order_and_extra_statements(self) -> None:
        assignment = source_for()
        selected = source_for(selected=True)
        cases = [source_for(initial=b'"four"'), source_for(assigned=b'"four"'),
                 source_for(selected=True, alternative=b'"four"'),
                 source_for(constants=((b'Ready', b'"'), (b'Detailed', b'AA'))),
                 source_for(initial=b'Result'), source_for(assigned=b'Result'),
                 source_for(selected=True, initial=b'Mode'),
                 source_for(selected=True, assigned=b'Mode'),
                 source_for(selected=True, alternative=b'Mode'),
                 source_for(initial=b'Unknown'), source_for(assigned=b'Unknown'),
                 source_for(initial=b'(Ready)'), source_for(assigned=b'Ready&""'),
                 source_for(initial=b'Ready(1..5)'), source_for(assigned=b'Ready_Extra'),
                 source_for(constants=((b'Ready', b'ready'), (b'Detailed', b'extra'),
                                       (b'Third', b'third'))),
                 assignment.replace(b'Detailed:constant String:="extra";',
                                    b'Detailed:constant String:=Ready;'),
                 assignment.replace(b'Ready:constant String:="ready";',
                                    b'Ready:constant String:=Detailed;'),
                 assignment.replace(b'Ready:constant String', b'Ready:String'),
                 assignment.replace(b'begin Result:=Detailed;', b'begin Ready:=Detailed;'),
                 assignment.replace(b'begin Result:=Detailed;', b'begin Result:=Detailed;Result:=Ready;'),
                 assignment.replace(b'Silver_IO.Put_Line(Result);',
                                    b'Silver_IO.Put_Line(Result);Silver_IO.Put_Line(Ready);'),
                 assignment.replace(b'Result:String:=Ready;',
                                    b'Result:String:=Ready;Later:constant String:="later";'),
                 selected.replace(b'Mode:constant String:=Silver_Arguments.First_Or_Default("brief");', b'')
                 .replace(b'Ready:constant String:="ready";',
                          b'Ready:constant String:="ready";Mode:constant String:=Silver_Arguments.First_Or_Default("brief");'),
                 selected.replace(b'else Result:=Ready;', b'else Ready:=Result;'),
                 selected.replace(b'else Silver_Arguments.Reject;', b'')]
        self.check_sources(cases, 2)

    def test_rejected_case_insensitive_collisions_and_excluded_names(self) -> None:
        cases = []
        for first, second in ((b'Ready', b'rEADY'), (b'Result', b'Detailed'),
                              (b'Ready', b'RESULT'), (b'String', b'Detailed'),
                              (b'Ready', b'SILVER_IO'), (b'begin', b'Detailed'),
                              (b'Ready_', b'Detailed'), (b'Ready', b'Detailed__2')):
            cases.append(source_for(constants=((first, b'ready'), (second, b'extra')),
                                    initial=b'"ready"', assigned=b'"extra"'))
        for name in (b'MODE', b'Silver_Arguments', b'SILVER_IO', b'String', b'parallel'):
            for slot in (0, 1):
                constants = [(b'Ready', b'ready'), (b'Detailed', b'extra')]
                constants[slot] = (name, constants[slot][1])
                cases.append(source_for(constants=tuple(constants), initial=b'"ready"',
                                        assigned=b'"extra"', alternative=b'"other"', selected=True))
        self.check_sources(cases, 2)

    def compile(self, contents: bytes, kind: str) -> tuple[Path, dict]:
        self.source.write_bytes(contents)
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
        self.assertEqual((workspace / 'main.adb').read_bytes(), contents)
        self.assertEqual(self.source.read_bytes(), contents)
        reports = workspace / 'obj/gnatprove'
        audit_reports(reports, {'main', 'silver_io', 'silver_output_libc',
                                'silver_arguments', 'silver_runtime'},
                      {'silver_output_libc', 'silver_runtime'}, application_kind=kind)
        return executable, json.loads((reports / 'main.spark').read_text())

    def assert_run(self, executable: Path, arguments: list[bytes], expected: bytes | None) -> None:
        result = subprocess.run([bytes(executable), *arguments], capture_output=True, timeout=10)
        self.assertEqual((result.returncode, result.stdout, result.stderr),
                         (1, b'', b'') if expected is None else (0, expected + b'\n', b''))

    def assert_output_failure(self, executable: Path, argument: str | None = None) -> None:
        result = subprocess.run(
            [sys.executable, '-c',
             'import os,sys;os.close(1);os.execv(sys.argv[1],sys.argv[1:])',
             str(executable), *([] if argument is None else [argument])],
            capture_output=True, timeout=10)
        self.assertEqual((result.returncode, result.stdout, result.stderr), (1, b'', b''))

    def test_native_copies_advisories_quotes_and_full_output(self) -> None:
        bindings = ((b'Ready', b'a' * 256), (b'Detailed', b'b' * 256))
        full = source_for(constants=bindings,
                          output=b'&'.join([b'Ready', b'Detailed'] * 7 + [b'Ready', b'Result']))
        cases = [(source_for(initial=b'"other"', output=b'Ready&"/"&Result'),
                  b'ready/extra'),
                 (source_for(constants=((b'Quote', b'"'), (b'Unused', b'unused')),
                             initial=b'Quote', assigned=b'"!"', output=b'Quote&Result'), b'"!'),
                 (full + b' ' * (4096 - len(full)), (b'a' * 256 + b'b' * 256) * 8)]
        for contents, expected in cases:
            with self.subTest(source_bytes=len(contents), output_bytes=len(expected)):
                executable, report = self.compile(contents, 'assigned')
                self.assertLessEqual(len(report['flow']), 1)
                self.assert_run(executable, [], expected)
                self.assert_output_failure(executable)

    def test_native_selected_copies_both_branches_dynamic_input_and_empty_values(self) -> None:
        executable, report = self.compile(source_for(
            selected=True, output=b'Ready&"/"&Result&"/"&Detailed&"/"&Mode', capacity=b'7'), 'selected')
        self.assertTrue(report['proof'], 'exercise dynamic and copied String range checks')
        for arguments, expected in [([], b'ready/ready/extra/brief'),
                                    ([b'verbose'], b'ready/extra/extra/verbose'),
                                    ([b'Verbose'], b'ready/ready/extra/Verbose'),
                                    ([b''], b'ready/ready/extra/'),
                                    ([b'12345678'], None), ([b'bad\n'], None),
                                    ([b'\x80'], None), ([b'verbose', b'extra'], None)]:
            self.assert_run(executable, arguments, expected)
        self.assert_output_failure(executable, 'verbose')
        self.assert_output_failure(executable, 'brief')
        empty, _ = self.compile(source_for(constants=((b'Ready', b''), (b'Detailed', b'')),
                                          selected=True, output=b'Ready&Result&Detailed'), 'selected')
        self.assert_run(empty, [], b'')
        self.assert_run(empty, [b'verbose'], b'')
        self.assert_output_failure(empty)


if __name__ == '__main__':
    unittest.main()
