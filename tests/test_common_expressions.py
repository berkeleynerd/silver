"""Common String expressions across declarations, assignments and comparisons."""
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
from tests.test_shared_bindings import output, program
from tests.test_silver import HOST, ROOT, invoke


class CommonExpressionsTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver expressions-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'expressions.adb'

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
                      {'silver_output_libc', 'silver_runtime'}, application_kind=kind)
        return executable, json.loads((reports / 'main.spark').read_text())

    def run_program(self, executable: Path, expected: bytes,
                    arguments: tuple[bytes, ...] = (), status: int = 0) -> None:
        result = subprocess.run([bytes(executable), *arguments], capture_output=True, timeout=10)
        self.assertEqual((result.returncode, result.stdout, result.stderr),
                         (status, expected, b''))

    def test_common_expression_positions_and_grouping(self) -> None:
        declarations = (b'A:String:=("a"&("b"&""));'
                        b'Saved:constant String:=(A);B:String:=(""&Saved);')
        cases = [program(declarations, output(b'((A)&(Saved&"!"))')),
                 program(declarations, b'A:=("c"&"d");' + output(b'Saved&"/"&A')),
                 program(declarations, b'B:=(A&"");' + output(b'B')),
                 program(b'E:String:=(""&"");', b'E:=(E&"");' + output(b'((E))')),
                 program(b'A:String:=("("&"--)");', output(b'A')),
                 program(b'A:String:=(-- before atom\n"a"&("b"));', output(b'(A)'))]
        for source in cases:
            with self.subTest(source=source):
                self.check(source)

    def test_repeated_dynamic_values_use_weighted_capacity(self) -> None:
        declarations = b'A:constant String:=(Input&"");B:String:=(""&A);'
        for expression, capacity in [(b'A&B', 2048), (b'"["&(A&B)&"]"', 2047),
                                     (b'A&(B&(Input&A))', 1024), (b'A&B', 0)]:
            with self.subTest(expression=expression, capacity=capacity):
                self.check(program(declarations, output(expression), arguments=True,
                                   capacity=capacity))
        for expression, capacity in [(b'A&B', 2049), (b'"["&(A&B)&"]"', 2048),
                                     (b'A&(B&(Input&A))', 1025)]:
            with self.subTest(expression=expression, capacity=capacity):
                self.check(program(declarations, output(expression), arguments=True,
                                   capacity=capacity), 2)
        self.check(program(declarations, output(b'A&B'), arguments=True), 2)

    def test_initializer_bounds_precede_body_guards(self) -> None:
        for initializer in (b'Input&Input', b'"!"&Input', b'Input&("!"&"")'):
            for capacity in (0, 1, 2048):
                with self.subTest(initializer=initializer, capacity=capacity):
                    self.check(program(b'A:String:=' + initializer + b';', output(b'"ok"'),
                                       arguments=True, capacity=capacity), 2)
        self.check(program(b'A:String:=((Input)&("")&"");', output(b'A'),
                           arguments=True))
        self.check(program(b'A:String:=(Later&"");Later:String:="x";', output(b'A')), 2)
        self.check(program(b'A:String:=(A&"");', output(b'"x"')), 2)

    def test_assignment_expression_preserves_exact_bounds(self) -> None:
        declarations = b'A:String:=("ab"&"");B:constant String:="c";'
        self.check(program(declarations, b'A:=(B&"d");' + output(b'A')))
        for assignment in (b'A:=(B&"");', b'A:=(A&"!");', b'B:=("d");'):
            with self.subTest(assignment=assignment):
                self.check(program(declarations, assignment + output(b'A')), 2)
        dynamic = b'A:String:=(Input&"");B:constant String:=(""&Input);'
        body = b'if (Input)=("old") then A:=(B&"");else A:=(Input);end if;' + output(b'A')
        self.check(program(dynamic, body, arguments=True))
        self.check(program(dynamic, body.replace(b'A:=(B&"");', b'A:=(B&B);'),
                           arguments=True, capacity=2048), 2)

    def test_comparison_expressions_need_string_type_anchor(self) -> None:
        declarations = b'A:constant String:=("o"&"ld");'
        for condition in (b'(Input&"")=("o"&"ld")', b'("o"&"ld")=(A&"")',
                          b'((A))=((Input))', b'("x"&A)=("y"&"")'):
            with self.subTest(condition=condition):
                body = b'if ' + condition + b' then ' + output(b'"yes"') + b'else ' + output(b'"no"') + b'end if;'
                self.check(program(declarations, body, arguments=True))
        for condition in (b'("x"&"y")=("xy")', b'""=("")', b'Absent=("x")'):
            with self.subTest(condition=condition):
                body = b'if ' + condition + b' then ' + output(b'"yes"') + b'else ' + output(b'"no"') + b'end if;'
                self.check(program(declarations, body, arguments=True), 2)

    def test_comparison_operands_have_independent_capacity_checks(self) -> None:
        for condition in (b'(Input&Input)=("xx")', b'("xx")=(Input&Input)'):
            body = b'if ' + condition + b' then ' + output(b'"yes"') + b'else ' + output(b'"no"') + b'end if;'
            self.check(program(b'', body, arguments=True, capacity=2048))
            self.check(program(b'', body, arguments=True, capacity=2049), 2)

    def test_grouping_does_not_reset_operand_work_limit(self) -> None:
        sixteen = b'&'.join([b'""'] * 16)
        self.check(program(b'', output(b'(' + sixteen + b')')))
        self.check(program(b'', output(b'(' + sixteen + b')&""')), 2)
        for expression in (b'()', b'("x"', b'"x")', b'("x"&)', b'(&"x")',
                           b'("x")("y")', b'("x"&&"y")', b'("x"|"y")'):
            with self.subTest(expression=expression):
                self.check(program(b'', output(expression)), 2)

    def test_whole_program_concatenation_work_budget(self) -> None:
        expression = b'&'.join([b'""'] * 16)
        declarations = b'A:String:=' + expression + b';B:String:=' + expression + b';'
        self.check(program(declarations, output(b'B')))
        self.check(program(declarations, output(b'B&""')), 2)
        body = (b'if Input="old" then ' + output(expression) + b'else '
                + output(expression) + b'end if;')
        self.check(program(b'', body, arguments=True))
        self.check(program(b'', body.replace(b'Input="old"', b'Input&""="old"'),
                           arguments=True), 2)
        # Literal and comment bytes do not represent concatenation operators.
        decorated = declarations.replace(b'""', b'"&""&&"', 1) + b'-- "' + b'&' * 100 + b'\n'
        self.check(program(decorated, output(b'B')))

    def test_concatenation_budget_is_shared_by_every_expression_position(self) -> None:
        def joined(atom: bytes, count: int) -> bytes:
            return b'&'.join([atom] + [b'""'] * count)

        declarations = b'A:String:=' + joined(b'Input', 7) + b';B:String:=A;'
        body = (b'if ' + joined(b'Input', 7) + b'=' + joined(b'"old"', 5)
                + b' then B:=' + joined(b'A', 5) + b';else B:=' + joined(b'Input', 3)
                + b';end if;' + output(joined(b'B', 3)))
        self.check(program(declarations, body, arguments=True))
        self.check(program(declarations, body.replace(output(joined(b'B', 3)),
                                                     output(joined(b'B', 4))), arguments=True), 2)

    def test_deep_parentheses_and_complete_source_bound(self) -> None:
        source = program(b'', output(b'(' * 1900 + b'"x"' + b')' * 1900))
        self.check(source)
        padded = source + b' ' * (4096 - len(source))
        self.check(padded)
        self.check(padded + b' ', 2)

    def test_native_expression_initializers_preserve_snapshots(self) -> None:
        declarations = b'A:String:=("a"&"b");Saved:constant String:=(A&"");'
        source = program(declarations, b'A:=("c"&("d"&""));' + output(b'Saved&"/"&A'))
        executable, report = self.compile(source, 'assigned')
        self.assertTrue(report['proof'])
        self.run_program(executable, b'ab/cd\n')

    def test_native_repeated_aliases_and_empty_grouping(self) -> None:
        declarations = b'A:String:=(""&Input);B:constant String:=(A&"");'
        executable, report = self.compile(program(declarations, output(b'((A)&B)'),
                                                  arguments=True, capacity=2048), 'argument')
        self.assertTrue(any(item.get('rule') == 'VC_RANGE_CHECK' for item in report['proof']))
        self.run_program(executable, b'oldold\n')
        for value in (b'', b'x', b'x' * 2048):
            self.run_program(executable, value + value + b'\n', (value,))
        for args in ((b'x' * 2049,), (b'one', b'two'), (b'\x01',)):
            self.run_program(executable, b'', args, 1)
        failed = subprocess.run(
            [sys.executable, '-c',
             'import os,sys;os.close(1);os.execv(sys.argv[1],sys.argv[1:])', str(executable), 'x'],
            capture_output=True, timeout=10)
        self.assertEqual((failed.returncode, failed.stderr), (1, b''))

    def test_native_common_comparison_and_selected_assignment(self) -> None:
        declarations = b'A:String:=(Input&"");B:constant String:=(""&Input);'
        body = (b'if (Input&"")=("o"&"ld") then A:=(B&"");else A:=(Input);end if;'
                + output(b'A'))
        executable, report = self.compile(program(declarations, body, arguments=True), 'selected')
        self.assertTrue(any(item.get('rule') == 'VC_LENGTH_CHECK' for item in report['proof']))
        self.run_program(executable, b'old\n')
        for value in (b'', b'old', b'new', b'x' * 4096):
            self.run_program(executable, value + b'\n', (value,))
        self.run_program(executable, b'', (b'x' * 4097,), 1)

    def test_native_constant_comparisons_preserve_precise_advisories(self) -> None:
        declarations = b'A:constant String:="xy";'
        for right, expected in ((b'("x"&"y")', b'yes\n'), (b'("z"&"z")', b'no\n')):
            body = (b'if (A&"")=' + right + b' then ' + output(b'"yes"')
                    + b'else ' + output(b'"no"') + b'end if;')
            executable, report = self.compile(program(declarations, body, arguments=True), 'argument')
            self.assertEqual({(item['rule'], item['message']['text']) for item in report['flow']},
                             {('INEFFECTIVE', 'statement has no effect'),
                              ('DEAD_CODE', 'this statement is never reached')})
            self.run_program(executable, expected)
