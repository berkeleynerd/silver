"""Guarded dynamic concatenation: exact capacity syntax and native outcomes."""
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


def source_for(default: bytes = b'world', prefix: bytes = b'Hello, ',
               suffix: bytes = b'!', name: bytes = b'Name',
               reference: bytes | None = None, capacity: bytes | None = None) -> bytes:
    def literal(value: bytes) -> bytes:
        return b'"' + value.replace(b'"', b'""') + b'"'

    reference = name if reference is None else reference
    capacity = str(4096 - len(prefix) - len(suffix)).encode('ascii') if capacity is None else capacity
    return (b'with Silver_IO;with Silver_Arguments;procedure Main is '
            b'pragma SPARK_Mode(On);' + name
            + b':constant String:=Silver_Arguments.First_Or_Default('
            + literal(default) + b');begin if Silver_Arguments.Input_Is_Valid and then '
            + reference + b"'Length<=" + capacity + b' then Silver_IO.Put_Line('
            + literal(prefix) + b'&' + reference + b'&' + literal(suffix)
            + b');else Silver_Arguments.Reject;end if;end Main;')


def largest(side: str) -> tuple[bytes, bytes, bytes]:
    values = [b'', b'', b'']
    index = ('default', 'prefix', 'suffix').index(side)
    for length in range(4097):
        values[index] = b'x' * length
        if len(source_for(*values)) > 4096:
            values[index] = b'x' * (length - 1)
            return tuple(values)
    raise AssertionError('source bound did not apply')


class CommandLineGreetingTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver guarded greeting-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'input.adb'

    def test_admitted_capacity_binding_and_layout(self) -> None:
        canonical = source_for()
        cases = [canonical, canonical.upper(), canonical + b'--end',
                 source_for(capacity=b'4087'), source_for(capacity=b'0'),
                 canonical.replace(b'&Name&', b'&"world"&'),
                 source_for(b'', b'', b''),
                 source_for(b'" -- ', b'" &', b'-- "', b'Main', b'mAIN'),
                 source_for(name=b'Length', reference=b'lENGTH'),
                 source_for(name=b'Name_2_A', reference=b'nAME_2_a'),
                 canonical.replace(b"'Length<=", b" ' -- attr\r\nLength <="),
                 canonical.replace(b'and then', b'and--short circuit\r\nthen'),
                 canonical.replace(b'&', b'--concat\r\n&\t')]
        for side in ('default', 'prefix', 'suffix'):
            source = source_for(*largest(side))
            cases.append(source + b' ' * (4096 - len(source)))
        overhead = len(source_for(b'', b'', b'', name=b''))
        name = b'X' * ((4096 - overhead) // 3)
        source = source_for(b'', b'', b'', name=name)
        cases.append(source + b' ' * (4096 - len(source)))
        for contents in cases:
            with self.subTest(length=len(contents), source=contents[:160]):
                self.source.write_bytes(contents)
                checked = invoke('check', self.source)
                self.assertEqual(checked.returncode, 0, checked.stdout)
                self.assertEqual(self.source.read_bytes(), contents)

    def test_rejected_guard_and_expression_neighbours(self) -> None:
        canonical = source_for()
        cases = [source_for(capacity=value) for value in
                 (b'4089', b'04088', b'+4088', b'4_088', b'4088.0',
                  b'4.088E3', b'4088e0', b'16#FF8#', b'4088_0', b'4097',
                  b'4088X', b'999999999999999999999999999')]
        cases += [canonical.replace(b'and then', replacement) for replacement in
                  (b'and', b'or else', b'or', b'andthen')]
        cases += [canonical.replace(b"Name'Length<=4088", replacement) for replacement in
                  (b"Name'Length<4088", b"Name'Length>=4088", b"Name'Last<=4088",
                   b"Other'Length<=4088", b"Name'Length<=4096-8", b"Name'Length< =4088",
                   b"Name'Length<=4088then", b"(Name'Length<=4088)")]
        cases += [canonical.replace(b'&Name&', replacement) for replacement in
                  (b'&Other&', b'&Name&Name&')]
        cases += [source_for(name=name) for name in
                  (b'Silver_Arguments', b'String', b'Silver_IO', b'if', b'Name_', b'Name__x', b'1Name')]
        cases += [canonical.replace(b'and then Name\'Length<=4088', b''),
                  canonical.replace(b'Silver_Arguments.Input_Is_Valid and then ', b''),
                  canonical.replace(b'Input_Is_Valid and', b'Input_Is_Valid=False and'),
                  canonical.replace(b'else Silver_Arguments.Reject;', b''),
                  source_for(default=b'\t'), source_for(prefix=b'\n'), source_for(suffix=b'\x80'),
                  canonical + b'--\x0b hidden', canonical + b' ' * (4097 - len(canonical))]
        for contents in cases:
            with self.subTest(source=contents[:250]):
                self.source.write_bytes(contents)
                checked = invoke('check', self.source)
                self.assertEqual(checked.returncode, 2, checked.stdout)

    def test_native_obligations_output_bounds_and_failures(self) -> None:
        cases = [(b'world', b'Hello, ', b'!', b'Name', b'Name'),
                 (b'world', b'', b'!', b'Length', b'lENGTH'),
                 (b'world', b'Hello, ', b'', b'Integer', b'iNTEGER'),
                 (b'', b'', b'', b'Main', b'mAIN'),
                 (b'" -- ', b'" &', b'-- "', b'Standard', b'sTANDARD')]
        cases += [(*largest(side), b'Name', b'Name') for side in ('default', 'prefix', 'suffix')]
        sources = [(source_for(default, prefix, suffix, name, reference), default, prefix, suffix)
                   for default, prefix, suffix, name, reference in cases]
        sources += [(source_for().upper(), b'WORLD', b'HELLO, ', b'!'),
                    (source_for().replace(b'procedure Main', b'procedure mAiN'), b'world', b'Hello, ', b'!')]
        saw_range = False
        for contents, default, prefix, suffix in sources:
            with self.subTest(length=len(contents), source=contents[:120]):
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
                for check in main['proof']:
                    self.assertEqual(check['rule'], 'VC_RANGE_CHECK')
                    self.assertEqual(check['severity'], 'info')
                    saw_range = True
                capacity = 4096 - len(prefix) - len(suffix)
                runs = [([], prefix + default + suffix + b'\n', 0),
                        ([b''], prefix + suffix + b'\n', 0),
                        ([b'Ada'], prefix + b'Ada' + suffix + b'\n', 0),
                        ([b'x' * capacity], prefix + b'x' * capacity + suffix + b'\n', 0),
                        ([b'x' * (capacity + 1)], b'', 1),
                        ([b'x' * 4097], b'', 1), ([b'one', b'two'], b'', 1),
                        ([b'bad\n'], b'', 1), ([b'\x80'], b'', 1)]
                for argv, stdout, status in runs:
                    run = subprocess.run([str(executable).encode(), *argv], capture_output=True, timeout=10)
                    self.assertEqual((run.returncode, run.stdout, run.stderr), (status, stdout, b''))
                failed = subprocess.run(
                    [sys.executable, '-c',
                     'import os,sys;os.close(1);os.execv(sys.argv[1],[sys.argv[1]])', str(executable)],
                    capture_output=True, timeout=10)
                self.assertEqual((failed.returncode, failed.stdout, failed.stderr), (1, b'', b''))
        self.assertTrue(saw_range, 'the dynamic form must exercise genuine application checks')


if __name__ == '__main__':
    unittest.main()
