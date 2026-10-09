"""Closed command-line composition and total input/failure behavior."""
from __future__ import annotations

import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

from scripts.check_evidence import audit_reports
from tests.test_silver import HOST, ROOT, invoke
from tests.test_named_output import source_for as named_source


def source_for(default: bytes = b'Hello, world!', name: bytes = b'Message',
               reference: bytes | None = None) -> bytes:
    return (b'with Silver_IO; with Silver_Arguments; procedure Main is pragma SPARK_Mode(On); '
            + name + b':constant String:=Silver_Arguments.First_Or_Default("'
            + default.replace(b'"', b'""') + b'");begin if Silver_Arguments.Input_Is_Valid then '
            + b'Silver_IO.Put_Line(' + (name if reference is None else reference)
            + b');else Silver_Arguments.Reject;end if;end Main;')


class ArgumentTests(unittest.TestCase):
    def setUp(self) -> None:
        temp = tempfile.TemporaryDirectory(prefix='silver arguments-')
        self.addCleanup(temp.cleanup)
        self.source = Path(temp.name).resolve() / 'arguments.adb'

    def test_closed_guard_admission(self) -> None:
        valid = source_for()
        accepted = [valid, named_source(b"local name", b"Silver_Arguments"), source_for(b'', b'Main', b'mAiN'),
                    source_for(b'" -- quoted', b'Name_2', b'nAME_2'),
                    valid.replace(b' then ', b' -- true branch\r\nthen\t'),
                    source_for(b'x' * (4096 - len(source_for(b''))))]
        name = b'X' * ((4096 - len(source_for(b'', b''))) // 2)
        maximum = source_for(b'', name)
        accepted.append(maximum + b' ' * (4096 - len(maximum)))
        rejected = [source_for(name=b'Silver_Arguments'), source_for(name=b'String'),
                    source_for(name=b'Silver_IO'), source_for(name=b'if'),
                    source_for(reference=b'Other'),
                    valid.replace(b'with Silver_Arguments; ', b''),
                    valid.replace(b'with Silver_IO; with Silver_Arguments;',
                                  b'with Silver_Arguments; with Silver_IO;'),
                    valid.replace(b'if Silver_Arguments.Input_Is_Valid then ', b'')
                         .replace(b'else Silver_Arguments.Reject;end if;', b''),
                    valid.replace(b'Input_Is_Valid', b'Input_Is_Valid()'),
                    valid.replace(b'Input_Is_Valid', b'Argument_Count=1'),
                    valid.replace(b'if Silver_Arguments.Input_Is_Valid', b'if True'),
                    valid.replace(b'else Silver_Arguments.Reject;', b''),
                    valid.replace(b'Silver_Arguments.Reject', b'null'),
                    valid.replace(b'Silver_Arguments.Reject', b'Silver_Arguments.Reject()'),
                    valid.replace(b'First_Or_Default', b'Argument'),
                    valid.replace(b'Put_Line(Message)', b'Put_Line("wrong")'),
                    valid.replace(b'end if;', b'end if;null;'),
                    source_for(b'\n'),
                    source_for(b'x' * (4097 - len(source_for(b''))))]
        for expected, cases in ((0, accepted), (2, rejected)):
            for contents in cases:
                with self.subTest(expected=expected, source=contents[:130]):
                    self.source.write_bytes(contents)
                    checked = invoke('check', self.source)
                    self.assertEqual(checked.returncode, expected, checked.stdout)

    def compile(self, source: bytes) -> Path:
        self.source.write_bytes(source)
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
        self.assertEqual((workspace / 'main.adb').read_bytes(), source)
        reports = workspace / 'obj/gnatprove'
        audit_reports(reports, {'main', 'silver_io', 'silver_output_libc',
                                'silver_arguments', 'silver_runtime'},
                      {'silver_output_libc', 'silver_runtime'})
        main = json.loads((reports / 'main.spark').read_text())
        self.assertEqual(main['flow'], [])
        self.assertEqual(main['proof'], [])
        self.assertEqual(self.source.read_bytes(), source)
        return executable

    def test_every_argument_outcome(self) -> None:
        default = b'Hello, world!'
        executable = self.compile(source_for(default))
        valid = [((), default), ((b'',), b''), ((b'MiXeD -- "value"',), b'MiXeD -- "value"'),
                 ((bytes(range(32, 127)),), bytes(range(32, 127))),
                 ((b'x' * 4096,), b'x' * 4096)]
        invalid = [(b'x' * 4097,), (b'\t',), (b'\n',), (b'\r',), (b'\x7f',),
                   (b'\x80',), (b'caf\xc3\xa9',), (b'one', b'two'), (b'', b'')]
        for arguments, expected in valid + [(args, None) for args in invalid]:
            with self.subTest(arguments=[len(arg) for arg in arguments], expected=expected is not None):
                run = subprocess.run([bytes(executable), *arguments], capture_output=True, timeout=10)
                self.assertEqual(run.returncode, 0 if expected is not None else 1, run.stderr)
                self.assertEqual(run.stdout, expected + b'\n' if expected is not None else b'')
                self.assertEqual(run.stderr, b'')
        if HOST.key.startswith('linux-'):
            with open('/dev/full', 'wb', buffering=0) as full:
                failed_output = subprocess.run([str(executable), 'valid'], stdout=full,
                                               stderr=subprocess.PIPE, timeout=10)
            self.assertEqual(failed_output.returncode, 1, failed_output.stderr)
            self.assertEqual(failed_output.stderr, b'')

    def test_boundary_defaults_and_names(self) -> None:
        maximum = b'x' * (4096 - len(source_for(b'')))
        name = b'X' * ((4096 - len(source_for(b'', b''))) // 2)
        cases = [(source_for(default, declared, reference), default)
                 for default, declared, reference in ((b'', b'Main', b'mAiN'),
                                                      (maximum, b'Message', b'Message'),
                                                      (b'', name, name))]
        overhead = len(source_for(b'', b'').replace(b'; ', b';'))
        compact_name = b'X' * ((4096 - overhead) // 2)
        compact = source_for(b'', compact_name).replace(b'; ', b';')
        cases.append((compact + b' ' * (4096 - len(compact)), b''))
        for source, default in cases:
            with self.subTest(default_length=len(default), source_length=len(source)):
                executable = self.compile(source)
                run = subprocess.run([str(executable)], capture_output=True, timeout=10)
                self.assertEqual(run.returncode, 0, run.stderr)
                self.assertEqual(run.stdout, default + b'\n')
                self.assertEqual(run.stderr, b'')


if __name__ == '__main__':
    unittest.main()
