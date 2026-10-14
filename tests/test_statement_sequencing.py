"""Finite statements preserve fixed bounds, value snapshots and returning effects."""
from __future__ import annotations

import os
from pathlib import Path
import subprocess
import tempfile
import unittest

from scripts.platforms import alire_command, tool_environment
from tests import test_shared_bindings
from tests.test_shared_bindings import output, program
from tests.test_silver import HOST


class StatementSequencingTests(unittest.TestCase):
    check = test_shared_bindings.SharedBindingsTests.check
    compile = test_shared_bindings.SharedBindingsTests.compile
    run_program = test_shared_bindings.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver sequences-')
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name).resolve()
        self.source = self.directory / 'sequence.adb'

    def test_statement_rules_have_admitted_and_rejected_neighbours(self) -> None:
        declarations = b'A:String:="old";B:String:=A;Saved:constant String:=A;'
        body = b'null;' + output(b'A') + b'A:="new";B:=A;A:=A;' + output(b'B')
        good = program(declarations, body)
        pairs = [(good, good.replace(b'B:=A;', b'Saved:=A;')),
                 (good, good.replace(b'B:=A;', b'Absent:=A;')),
                 (good, good.replace(b'B:=A;', b'B:=Absent;')),
                 (good, good.replace(b'A:="new";', b'A:="no";')),
                 (good, good.replace(b'B:=A;', b'B:=A')),
                 (good, good.replace(b'null;', b'null'))]
        branch = program(declarations, b'if A="old" then A:="new";null;else B:=A;end if;')
        nested = branch.replace(b'null;', b'if B="old" then null;else null;end if;')
        pairs.extend([(branch, branch.replace(b'else B:=A;', b'else B:="x";')),
                      (branch, branch.replace(b'else B:=A;', b'else ')),
                      (nested, nested.replace(b'if B="old"', b'if Absent="old"'))])
        dynamic = program(b'A:String:=Input;B:String:="old";', b'A:=Input;null;', arguments=True)
        pairs.append((dynamic, dynamic.replace(b'A:=Input;', b'A:=B;')))
        sixteen = b'&'.join([b'""'] * 16)
        pairs.append((program(b'', output(sixteen) * 2),
                      program(b'', output(sixteen) * 2 + output(b'""&""'))))
        pairs.append((program(b'', b'null;' + output(sixteen)),
                      program(b'', b'null;' + output(sixteen + b'&""'))))
        bound = program(b'A:String:="' + b'x' * 2048 + b'";', output(b'A&A'))
        pairs.append((bound, bound.replace(output(b'A&A'), output(b'A&A&"!"'))))
        padded = good + b' ' * (4096 - len(good))
        pairs.append((padded, padded + b' '))
        for admitted, rejected in pairs:
            with self.subTest(rejected=rejected[:150]):
                self.check(admitted)
                self.check(rejected, 2)

    def test_sequence_boundaries_have_single_edit_neighbours(self) -> None:
        static = program(b'', b'null;')
        guarded = program(b'', b'null;', arguments=True)
        branch = program(b'A:String:="old";', b'if A="old" then null;else null;end if;')
        nested_else = branch.replace(b'else null;', b'else if A="old" then null;end if;')
        bounded = program(b'', output(b'Input') + output(b'Input&Input'),
                          arguments=True, capacity=2048)
        assignment = program(b'A:String:=Input;', b'A:=Input;', arguments=True)
        before_guard = guarded.replace(b'begin if ', b'begin null;if ')
        self.check(before_guard)
        self.check(before_guard.replace(b'begin null;if ', b'begin null if '), 2)
        pairs = [
            ('empty static body', static, static.replace(b'null;', b'')),
            ('empty guard success branch', guarded, guarded.replace(b'null;', b'')),
            ('empty then arm', branch, branch.replace(b'then null;', b'then ')),
            ('empty nested else choice arm', nested_else,
             nested_else.replace(b'else if A="old" then null;', b'else if A="old" then ')),
            ('later output exceeds capacity', bounded,
             bounded.replace(output(b'Input&Input'), output(b'Input&Input&"!"'))),
            ('immutable argument target', assignment, assignment.replace(b'A:=Input;', b'Input:=Input;')),
        ]
        for rule, admitted, rejected in pairs:
            with self.subTest(rule=rule):
                self.check(admitted)
                self.check(rejected, 2)

    def test_expression_leaf_limit_in_initializers_assignments_and_comparisons(self) -> None:
        declarations = b'A:String:="";'
        sixteen = b'&'.join([b'A'] + [b'""'] * 15)
        # Empty contributions preserve length; only the seventeenth leaf changes
        # admission, and neither case approaches the thirty-operator budget.
        for expression, status in ((sixteen, 0), (sixteen + b'&""', 2)):
            sources = {
                'initializer': program(declarations + b'B:String:=' + expression + b';', b'null;'),
                'assignment': program(declarations, b'A:=' + expression + b';'),
                'left comparison': program(declarations,
                                           b'if ' + expression + b'="" then null;else null;end if;'),
                'right comparison': program(declarations,
                                            b'if ""=' + expression + b' then null;else null;end if;'),
            }
            for position, source in sources.items():
                with self.subTest(position=position, leaves=16 if status == 0 else 17):
                    self.check(source, status)

    def test_former_single_statement_restrictions_are_sequences(self) -> None:
        from tests import (test_branching, test_composed_results, test_copy_values,
                           test_greeting, test_named_output, test_output,
                           test_string_assignment)
        assignment = test_copy_values.source_for()
        result = test_composed_results.source_for(b'Message&Input', form='result', capacity=b'40')
        literal = test_output.source_for(b'hello')
        fixed = test_string_assignment.source_for()
        branch = test_branching.source_for()
        cases = [assignment.replace(b'begin Result:=Detailed;', b'begin Result:=Detailed;Result:=Ready;'),
                 assignment.replace(b'Silver_IO.Put_Line(Result);',
                                    b'Silver_IO.Put_Line(Result);Silver_IO.Put_Line(Ready);'),
                 result.replace(b'Message:="old";end if;', b'Message:="old";Message:="new";end if;'),
                 literal.replace(b'; end', b'; Silver_IO.Put_Line("more"); end'),
                 literal.replace(b'begin ', b'begin null; '),
                 literal.replace(b'Silver_IO.Put_Line("hello")', b'null'),
                 test_named_output.source_for(b'Hello').replace(b';end ', b';null;end '),
                 branch.replace(b'Silver_IO.Put_Line("Ready.");',
                                b'Silver_IO.Put_Line("Ready.");Silver_IO.Put_Line("again");'),
                 fixed.replace(b';Silver_IO', b';Message:="Again";Silver_IO'),
                 fixed.replace(b'begin Message:="World";Silver_IO.Put_Line(Message);',
                               b'begin Silver_IO.Put_Line(Message);Message:="World";'),
                 fixed.replace(b';end ', b';null;end '),
                 test_greeting.source_for().replace(b';end', b';null;end')]
        for source in cases:
            with self.subTest(source=source[:120]):
                self.check(source)
                # Exact sibling: sequence still needs its final delimiter.
                self.check(source.replace(b'end Main;', b'end Main'), 2)

    def test_native_assignments_and_outputs_preserve_order_and_snapshots(self) -> None:
        declarations = b'A:String:="old";B:String:=A;Saved:constant String:=A;'
        body = (b'null;' + output(b'A') + b'A:="new";B:=A;A:=A;'
                + output(b'Saved&"/"&A&"/"&B') + b'null;')
        executable, report = self.compile(program(declarations, body), 'assigned')
        self.run_program(executable, b'old\nold/new/new\n')
        messages = {item['message']['text'] for item in report['flow']}
        self.assertTrue(any('is set by "Put_Line"' in message for message in messages))

    def test_native_argument_sequences_cover_both_paths_and_rejection(self) -> None:
        body = (output(b'Input') + b'if Input="old" then Label:="new";Work:=Input;'
                b'else Label:="raw";null;end if;Work:=Work;'
                + output(b'Label') + output(b'Work'))
        source = program(b'Work:String:=Input;Label:String:="old";', body,
                         arguments=True, capacity=4096)
        executable, _ = self.compile(source, 'selected')
        self.run_program(executable, b'old\nnew\nold\n')
        for value in (b'', b'old', b'new', b'x' * 4096):
            label = b'new' if value == b'old' else b'raw'
            self.run_program(executable, value + b'\n' + label + b'\n' + value + b'\n', (value,))
        for arguments in ((b'x' * 4097,), (b'one', b'two'), (b'\x01',)):
            self.run_program(executable, b'', arguments, 1)

    def test_native_no_output_sequences_retain_complete_proof_records(self) -> None:
        for source, kind in ((program(b'', b'null;null;'), 'static'),
                             (program(b'A:String:="old";B:String:=A;',
                                      b'A:="new";B:=A;A:=A;null;'), 'assigned'),
                             (program(b'A:String:=Input;', b'A:=Input;A:=A;',
                                      arguments=True), 'selected')):
            with self.subTest(kind=kind):
                executable, _ = self.compile(source, kind)
                self.run_program(executable, b'')

    def test_native_source_maximum_outputs_exceed_old_report_capacity(self) -> None:
        body = b''
        while len(program(b'', body + output(b'""'))) <= 4096:
            body += output(b'""')
        source = program(b'', body)
        source += b' ' * (4096 - len(source))
        executable, report = self.compile(source, 'static')
        count = body.count(b'Put_Line')
        self.assertGreater(count, 100)
        self.run_program(executable, b'\n' * count)
        report_path = executable.parent.parent / 'obj/gnatprove/main.spark'
        self.assertGreater(report_path.stat().st_size, 262_144)
        self.assertEqual(len(report['flow']), 4 * (count - 1))

    def test_native_output_failure_continues_and_status_stays_failed(self) -> None:
        if not HOST.key.startswith('linux-'):
            self.skipTest('ELF interposition is Linux-specific')
        static, _ = self.compile(program(b'', output(b'"first"') + output(b'"second"')
                                         + output(b'"third"')), 'static')
        guarded_body = (output(b'"first"') + b'if Input="old" then '
                        b'if Input="" then ' + output(b'"empty"')
                        + b'elsif Input="old" then ' + output(b'"matched"') + b'end if;'
                        b'elsif Input="new" then ' + output(b'"other"')
                        + b'else ' + output(b'"fallback"') + b'end if;'
                        b'if Input="missing" then ' + output(b'"unexpected"') + b'end if;'
                        + output(b'"third"'))
        guarded, _ = self.compile(program(b'', guarded_body, arguments=True), 'argument')
        cases = [(static, (), b'second\nthird\n'),
                 (guarded, (), b'matched\nthird\n'),
                 (guarded, ('new',), b'other\nthird\n'),
                 (guarded, ('',), b'fallback\nthird\n')]
        # Test-only libc adapter makes one environmental failure recoverable.
        # Actual Silver_IO remains unchanged and executes every subsequent call.
        shim = self.directory / 'failure.c'
        shim.write_text(r'''
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
static int writes, flushes;
int putchar(int c) {
    ++writes;
    if (getenv("FAIL_WRITE") && writes == 1) return EOF;
    unsigned char byte = (unsigned char)c;
    return write(1, &byte, 1) == 1 ? c : EOF;
}
int fflush(FILE *stream) {
    (void)stream;
    ++flushes;
    if (getenv("FAIL_FLUSH") && flushes == 1) return EOF;
    return 0;
}
''')
        shared = self.directory / 'failure.so'
        built = subprocess.run(alire_command(HOST, 'exec', '--', 'gcc', '-shared', '-fPIC',
                                             str(shim), '-o', str(shared)),
                               cwd=HOST.context, env=tool_environment(HOST),
                               capture_output=True, text=True, timeout=30)
        self.assertEqual(built.returncode, 0, built.stdout + built.stderr)
        with shared.open('rb') as preload:
            # LD_PRELOAD splits on spaces; the descriptor path also exercises
            # temporary directories whose names intentionally contain spaces.
            for executable, arguments, later_output in cases:
                for variable, prefix in (('FAIL_WRITE', b''), ('FAIL_FLUSH', b'first\n')):
                    with self.subTest(arguments=arguments, failure=variable, program=executable):
                        environment = dict(os.environ, LD_PRELOAD=f'/proc/self/fd/{preload.fileno()}',
                                           **{variable: '1'})
                        result = subprocess.run([str(executable), *arguments], env=environment,
                                                pass_fds=(preload.fileno(),), capture_output=True, timeout=10)
                        self.assertEqual((result.returncode, result.stdout, result.stderr),
                                         (1, prefix + later_output, b''))


if __name__ == '__main__':
    unittest.main()
