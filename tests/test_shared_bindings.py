"""Ordered String bindings, copied values and fixed object bounds."""
from __future__ import annotations

import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

from scripts.check_evidence import audit_reports
from tests.test_composed_results import literal
from tests.test_silver import HOST, ROOT, invoke


def program(declarations: bytes, body: bytes, *, arguments: bool = False,
            capacity: int | None = None) -> bytes:
    context = b'with Silver_IO;'
    initializer = b''
    if arguments:
        context += b'with Silver_Arguments;'
        initializer = (b'Input:constant String:='
                       b'Silver_Arguments.First_Or_Default("old");')
        guard = b'if Silver_Arguments.Input_Is_Valid'
        if capacity is not None:
            guard += b" and then Input'Length<=" + str(capacity).encode()
        body = guard + b' then ' + body + b'else Silver_Arguments.Reject;end if;'
    return (context + b'procedure Main is pragma SPARK_Mode(On);'
            + initializer + declarations + b'begin ' + body + b'end Main;')


def output(expression: bytes) -> bytes:
    return b'Silver_IO.Put_Line(' + expression + b');'


class SharedBindingsTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver bindings-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'bindings.adb'

    def check(self, source: bytes, expected: int = 0) -> None:
        self.source.write_bytes(source)
        result = invoke('check', self.source)
        self.assertEqual(result.returncode, expected, result.stdout)
        self.assertEqual(self.source.read_bytes(), source)

    def compile(self, source: bytes, kind: str) -> tuple[Path, dict]:
        self.source.write_bytes(source)
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
        self.assertEqual((workspace / 'main.adb').read_bytes(), source)
        reports = workspace / 'obj/gnatprove'
        audit_reports(reports, {'main', 'silver_io', 'silver_output_libc',
                                'silver_arguments', 'silver_runtime'},
                      {'silver_output_libc', 'silver_runtime'}, application_kind=kind, indexed_main=True)
        return executable, json.loads((reports / 'main~1.spark').read_text())

    def run_program(self, executable: Path, expected: bytes,
                    arguments: tuple[bytes, ...] = (), status: int = 0) -> None:
        result = subprocess.run([bytes(executable), *arguments], capture_output=True, timeout=10)
        self.assertEqual((result.returncode, result.stdout, result.stderr),
                         (status, expected, b''))

    def test_arbitrary_ordered_constant_and_mutable_bindings(self) -> None:
        declarations = (b'A:String:="old";B:constant String:=A;C:String:=B;'
                        b'D:constant String:="new";E:String:=C;')
        cases = [program(declarations, output(b'A&B&C&D&E')),
                 program(declarations, b'A:=D;' + output(b'B&"/"&C&"/"&A')),
                 program(declarations, b'C:=C;' + output(b'C')),
                 program(declarations, b'E:=A;' + output(b'"done"')),
                 program(b'A:String:="";B:constant String:=A;C:String:=B;', output(b'A&B&C')),
                 program(b'Main:String:="old";Copy:constant String:=mAIN;', output(b'COPY')),
                 program(b'Silver_Arguments:String:="old";', output(b'SILVER_ARGUMENTS')),
                 program(b'A:String:="x";B:String:=(A);', output(b'B')),
                 program(b'A:String:="x";B:String:=A&"";', output(b'B'))]
        for source in cases:
            with self.subTest(source=source):
                self.check(source)

    def test_static_and_dynamic_snapshots_in_guarded_bodies(self) -> None:
        declarations = b'Copy:constant String:=Input;Work:String:=Copy;Other:String:=Work;'
        cases = [program(declarations, output(b'Copy'), arguments=True),
                 program(declarations, output(b'"["&Other&"]"'), arguments=True, capacity=4094),
                 program(declarations,
                         b'if Input="old" then Work:=Copy;else Work:=Other;end if;'
                         + output(b'Work'), arguments=True),
                 program(declarations + b'Label:String:="new";',
                         b'if Input="old" then ' + output(b'Copy') + b'else '
                         + output(b'Label') + b'end if;', arguments=True)]
        for source in cases:
            with self.subTest(source=source):
                self.check(source)

    def test_bindings_do_not_bypass_name_or_initialization_rules(self) -> None:
        declarations = [b'A:String:=A;', b'A:String:=B;B:String:="x";',
                        b'A:String:=B;B:String:=A;', b'A:String;',
                        b'A:String:="x";a:constant String:="x";',
                        b'String:String:="x";', b'END:String:="x";',
                        b'Silver_IO:String:="x";', b'A__B:String:="x";',
                        b'A:String:="x";B:String:=Absent;']
        for source in declarations:
            with self.subTest(declarations=source):
                self.check(program(source, output(b'"ok"')), 2)
        for name in (b'Input', b'iNPUT', b'Silver_Arguments'):
            self.check(program(name + b':String:="x";', output(b'"ok"'), arguments=True), 2)

    def test_assignment_respects_mutability_and_fixed_length(self) -> None:
        declarations = b'A:constant String:="old";B:String:=A;C:String:="xx";'
        for assignment in (b'A:=B;', b'B:=C;', b'Unknown:=B;', b'B:=Unknown;'):
            with self.subTest(assignment=assignment):
                self.check(program(declarations, assignment + output(b'B')), 2)
        dynamic = b'Copy:String:=Input;Fixed:String:="old";'
        refined = (b'if Input="old" then Copy:=Fixed;else Copy:=Input;end if;'
                   + output(b'Copy'))
        self.check(program(dynamic, refined, arguments=True))
        self.check(program(dynamic, refined.replace(b'Input="old"', b'Input/="old"'),
                           arguments=True), 2)

    def test_alias_occurrences_keep_expression_capacity_limits(self) -> None:
        declarations = b'A:String:=' + literal(b'x' * 2048) + b';B:constant String:=A;'
        self.check(program(declarations, output(b'A&B')))
        self.check(program(declarations, output(b'A&B&"!"')), 2)
        empty = b'A:String:="";B:String:=A;'
        self.check(program(empty, output(b'&'.join([b'B'] * 64))))
        self.check(program(empty, output(b'&'.join([b'B'] * 65))), 2)
        dynamic = b'A:constant String:=Input;B:String:=A;'
        self.check(program(dynamic, output(b'A&B'), arguments=True, capacity=0))
        self.check(program(dynamic, output(b'"!"&B'), arguments=True, capacity=4095))
        self.check(program(dynamic, output(b'"!"&B'), arguments=True, capacity=4096), 2)

    def test_dense_copy_chain_and_exact_source_bound(self) -> None:
        declarations = b'V0:String:="x";'
        last = b'V0'
        while True:
            name = b'V' + str(declarations.count(b';')).encode()
            candidate = declarations + name + b':constant String:=' + last + b';'
            if len(program(candidate, output(name))) > 4096:
                break
            declarations, last = candidate, name
        source = program(declarations, output(last))
        self.assertGreater(declarations.count(b';'), 100)
        padded = source + b' ' * (4096 - len(source))
        self.check(padded)
        self.check(padded + b' ', 2)

    def test_native_copy_snapshots_and_unused_assignment(self) -> None:
        declarations = (b'Original:String:="old";Saved:constant String:=Original;'
                        b'Another:String:=Saved;New_Value:constant String:="new";')
        source = program(declarations,
                         b'Original:=New_Value;' + output(b'Saved&"/"&Another&"/"&Original'))
        executable, _ = self.compile(source, 'assigned')
        self.run_program(executable, b'old/old/new\n')
        source = program(declarations, b'Original:=New_Value;' + output(b'Saved'))
        executable, report = self.compile(source, 'assigned')
        self.assertTrue(any(item.get('message', {}).get('text') == 'unused assignment' for item in report['flow']))
        self.run_program(executable, b'old\n')

    def test_native_unused_initializers_without_assignment(self) -> None:
        source = program(b'Spare:String:="a";Spare_Too:String:="b";'
                         b'Used:constant String:="ok";', output(b'Used'))
        executable, report = self.compile(source, 'static')
        self.assertGreaterEqual(len(report['flow']), 2)
        self.run_program(executable, b'ok\n')

    def test_native_dynamic_copies_preserve_argument_domain(self) -> None:
        declarations = b'Saved:constant String:=Input;Work:String:=Saved;Other:String:=Input;'
        body = (b'if Input="old" then Work:=Saved;else Work:=Other;end if;'
                + output(b'"["&Work&"]"'))
        executable, report = self.compile(program(declarations, body, arguments=True, capacity=4094), 'selected')
        self.assertTrue(any(item.get('rule') == 'VC_LENGTH_CHECK' for item in report['proof']))
        for value in (b'', b'old', b'changed', b'x' * 4094):
            self.run_program(executable, b'[' + value + b']\n', (value,))
        self.run_program(executable, b'[old]\n')
        for args in ((b'x' * 4095,), (b'one', b'two'), (b'\x01',)):
            self.run_program(executable, b'', args, 1)
