"""Partial writes retain byte bounds, statement order and returning failures."""
from __future__ import annotations

import os
from pathlib import Path
import subprocess
import tempfile
import unittest

from scripts.platforms import alire_command, tool_environment
from tests import test_shared_bindings
from tests.test_composed_results import literal
from tests.test_shared_bindings import output, program
from tests.test_silver import HOST


def put(expression: bytes) -> bytes:
    return b'Silver_IO.Put(' + expression + b');'


class PartialOutputTests(unittest.TestCase):
    check = test_shared_bindings.SharedBindingsTests.check
    compile = test_shared_bindings.SharedBindingsTests.compile
    run_program = test_shared_bindings.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver partial output-')
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name).resolve()
        self.source = self.directory / 'partial.adb'

    def test_partial_calls_keep_expression_and_source_bounds(self) -> None:
        base = program(b'', put(b'"ok"'))
        static = program(b'A:String:=' + literal(b'x' * 2048) + b';', put(b'A&A'))
        dynamic = program(b'', put(b'Input&"!"'), arguments=True, capacity=4095)
        leaves = b'&'.join([b'""'] * 64)
        bounded = base + b' ' * (4096 - len(base))
        pairs = (
            (static, static.replace(b'Put(A&A)', b'Put(A&A&"!")')),
            (dynamic, dynamic.replace(b"Length<=4095", b"Length<=4096")),
            (program(b'', put(leaves)), program(b'', put(leaves + b'&""'))),
            (bounded, bounded + b' '),
            (base, base.replace(b'Put("ok")', b'Put("line\nbreak")')),
            (base, base.replace(b'Put("ok")', b'Put_Char("ok")')),
            (base, base.replace(b'Put("ok")', b'Put2("ok")')),
            (base, base.replace(b'Put("ok")', b'Put')),
        )
        for accepted, rejected in pairs:
            with self.subTest(rejected=rejected[:160]):
                self.check(accepted)
                self.check(rejected, 2)
        guarded = program(b'', put(b'Input'), arguments=True)
        self.check(guarded)
        self.check(guarded.replace(b'if Silver_Arguments.Input_Is_Valid then ', b'')
                   .replace(b'else Silver_Arguments.Reject;end if;', b''), 2)

    def failure_shim(self) -> Path:
        # A transient libc failure lets the real SPARK implementation continue
        # to later statements, unlike a permanently closed output descriptor.
        source = self.directory / 'failure.c'
        source.write_text(r'''
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
                                             str(source), '-o', str(shared)),
                               cwd=HOST.context, env=tool_environment(HOST),
                               capture_output=True, text=True, timeout=30)
        self.assertEqual(built.returncode, 0, built.stdout + built.stderr)
        return shared

    def test_native_mixed_output_preserves_bytes_and_continues_after_failure(self) -> None:
        content = bytes(range(32, 127))
        body = put(literal(content)) + output(b'"line"') + put(b'"tail"')
        executable, _ = self.compile(program(b'', body), 'static')
        expected = content + b'line\ntail'
        self.run_program(executable, expected)
        if not HOST.key.startswith('linux-'):
            return
        with self.failure_shim().open('rb') as preload:
            for failure, accepted in (('FAIL_WRITE', b'line\ntail'), ('FAIL_FLUSH', expected)):
                with self.subTest(failure=failure):
                    environment = dict(os.environ, LD_PRELOAD=f'/proc/self/fd/{preload.fileno()}',
                                       **{failure: '1'})
                    result = subprocess.run([str(executable)], env=environment,
                                            pass_fds=(preload.fileno(),), capture_output=True, timeout=10)
                    self.assertEqual((result.returncode, result.stdout, result.stderr),
                                     (1, accepted, b''))

    def test_native_empty_put_flushes_without_writing_a_newline(self) -> None:
        executable, _ = self.compile(program(b'', put(b'""')), 'static')
        self.run_program(executable, b'')
        if not HOST.key.startswith('linux-'):
            return
        with self.failure_shim().open('rb') as preload:
            environment = dict(os.environ, LD_PRELOAD=f'/proc/self/fd/{preload.fileno()}',
                               FAIL_FLUSH='1')
            result = subprocess.run([str(executable)], env=environment,
                                    pass_fds=(preload.fileno(),), capture_output=True, timeout=10)
            self.assertEqual((result.returncode, result.stdout, result.stderr), (1, b'', b''))

    def test_native_branches_and_inputs_preserve_each_call_bound(self) -> None:
        body = (put(b'"<"') + b'if Input="line" then Silver_IO.Put_Line(Item=>Copy);'
                b'elsif Input="" then Silver_IO.Put("");'
                b'else Silver_IO.Put(Item=>(Copy&""));end if;' + output(b'">"'))
        executable, _ = self.compile(program(b'Copy:constant String:=Input;', body,
                                             arguments=True), 'argument')
        self.run_program(executable, b'<old>\n')
        for value in (b'', b'line', b'quoted " and apostrophe\'', b'x' * 4096):
            with self.subTest(input_length=len(value)):
                self.run_program(executable, b'<' + value + (b'\n' if value == b'line' else b'')
                                 + b'>\n', (value,))
        for arguments in ((b'x' * 4097,), (b'one', b'two'), (b'\x80',)):
            with self.subTest(invalid_input_lengths=[len(value) for value in arguments]):
                self.run_program(executable, b'', arguments, 1)


if __name__ == '__main__':
    unittest.main()
