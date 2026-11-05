"""Bounded mutable Integer admission, snapshots and executable composition."""
from __future__ import annotations

import json
import os
from pathlib import Path
import re
import tempfile
import unittest
from unittest import mock

from tests import test_shared_bindings as shared
from tests.test_shared_bindings import output, program
from tests.test_silver import HOST, ROOT, invoke


class MutableIntegerTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check
    run_program = shared.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver mutable integers-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'integers.adb'

    def test_admission_declarations_and_exact_initialization_snapshots(self) -> None:
        for declarations in (
            b'A:Integer:=7;',
            b'A:Integer range 0..99:=7;',
            b'A:constant Integer range 0..99:=7;',
            b'A:Integer range 0..99:=7;K:constant Integer:=A;B:Integer range 7..7:=K;',
            b'A:Integer:=7;K:constant Integer:=(A * A);S:String:=Integer\'Image(A);',
            b'L:constant Integer:=(-9);H:constant Integer:=9;A:Integer range L..H:=0;',
            b'A:Integer range -2147483648..2147483647:=-2147483648;',
            b'A:constant Integer range 2#1#..16#F#:=3;B:Integer range A..(A + 1):=4;',
            b'A:Integer range 2:0:..16:F::=3;',
            b'A:Integer range 0..9 :=0;',
        ):
            with self.subTest(declarations=declarations):
                self.check(program(declarations, b'null;'))

    def test_admission_requires_static_nonempty_constraints_and_legal_names(self) -> None:
        for declarations in (
            b'A:Integer;', b'A:Integer range 0..9;',
            b'A:Integer range 0 9:=0;', b'A:Integer range 0..:=0;',
            b'A:Integer range 9..0:=0;', b'A:Integer range 0..9:=10;',
            b'A:Integer:=A;', b'A:Integer:=B;B:Integer:=0;',
            b'A:Integer:=0;a:Integer:=1;', b'A:Integer:=0;A:String:="";',
            b'A,B:Integer:=0;', b'A:Integer:=0;B:Integer range A..9:=0;',
            b'A:Integer:=0;K:constant Integer:=A;B:Integer range K..9:=0;',
            b'A:Integer range 0..(2147483647 + 1):=0;',
            b'A:Integer range -2147483649..0:=0;',
            b'Integer:Integer:=0;', b'Integer:String:="";A:Integer:=0;',
            b'A:Integer range 0..9:=0;B:Integer:=A;C:Integer range B..9:=0;',
        ):
            with self.subTest(declarations=declarations):
                self.check(program(declarations, b'null;'), 2)

    def test_admission_body_starts_declared_and_tracks_writes_and_guards(self) -> None:
        declarations = b'X:Integer range 0..9:=0;Y:Integer range -9..9:=0;'
        for body in (b'X:=9;X:=(9 - X);Y:=(-Y);',
                     b'for I in 0..9 loop X:=I;end loop;',
                     b'if X=0 then X:=9;else X:=0;end if;',
                     b'X:=X;Y:=X;', b'X:=0;X:=(X + 1);',
                     b'if X<9 then X:=(X + 1);end if;'):
            self.check(program(declarations, body))
        for body in (b'X:=(X + 1);', b'X:=(X - X);',
                     b'X:=Y;', b'X:=10;', b'X:=(-1);'):
            self.check(program(declarations, body), 2)
        self.check(program(b'X:Integer:=0;', b'X:=(X + 1);'), 2)
        self.check(program(b'X:Integer:=0;', b'X:=(-X);'), 2)
        self.check(program(b'X:Integer:=0;', b'X:=(X * 0);'))

    def test_admission_assignments_preserve_type_and_immutability(self) -> None:
        declarations = b'A:Integer range 0..9:=1;K:constant Integer:=A;S:String:="x";'
        for body in (b'K:=2;', b'A:=S;', b'S:=A;', b'Missing:=1;',
                     b'for A in 0..9 loop A:=1;end loop;',
                     b'for A in 9..0 loop A:=1;end loop;',
                     b'for S in 0..9 loop S:="y";end loop;'):
            self.check(program(declarations, body), 2)
        self.check(program(declarations, b'for A in 0..9 loop null;end loop;A:=2;'))
        self.check(program(declarations, b'for I in 9..0 loop A:=I;end loop;'), 2)
        self.check(program(declarations, b'for I in 9..0 loop A:=10;end loop;'), 2)

    def test_empty_interval_assignments_rejected_before_compilation(self) -> None:
        # GNAT checks predictable range errors even in dead loop bodies. The
        # last two cases also catch an incomplete repair that merely removes
        # the containment bypass: canonical empty (1, 0) fits these endpoints.
        cases = (
            (b'A:Integer range 0..9:=0;', b'for I in 20..10 loop A:=I;end loop;'),
            (b'A:Integer range 5..9:=5;', b'for I in 1..0 loop A:=I;end loop;'),
            (b'N:Integer range 0..9:=0;A:Integer range 0..9:=0;',
             b'for I in 10..N loop A:=I;end loop;'),
            (b'A:Integer range 0..9:=0;', b'for I in reverse 20..10 loop A:=I;end loop;'),
            (b'A:Integer range 0..9:=0;',
             b'for I in 20..10 loop if A=0 then A:=I;end if;end loop;'),
            (b'A:Integer range 0..3:=0;',
             b'for I in 1..2 loop for J in 5..I loop A:=J;end loop;end loop;'),
            (b'A:Integer range 0..9:=0;', b'for I in 2..1 loop A:=(I * 100);end loop;'),
            (b'A:Integer range 1..9:=1;', b'for I in 20..10 loop A:=(I * 0);end loop;'),
            (b'L:constant Integer:=20;H:constant Integer:=10;A:Integer range 0..9:=0;',
             b'for I in L..H loop A:=I;end loop;'),
            (b'N:Integer range -5..0:=0;A:Integer:=0;',
             b'for I in 1..N loop A:=(I + 2147483647);end loop;'),
            (b'A:Integer range 0..9:=0;', b'for I in 9..0 loop A:=I;end loop;'),
            (b'A:Integer:=0;', b'for I in 1..0 loop A:=I;end loop;'),
        )
        for arguments in (False, True):
            for declarations, body in cases:
                with self.subTest(arguments=arguments, declarations=declarations, body=body):
                    source = program(declarations, body, arguments=arguments)
                    self.check(source, 2)
                    before = set(HOST.artifacts.glob('program-*'))
                    result = invoke('compile', self.source)
                    self.assertEqual(result.returncode, 2, result.stdout)
                    self.assertEqual(self.source.read_bytes(), source)
                    self.assertEqual(set(HOST.artifacts.glob('program-*')), before)

    def test_native_retained_empty_loop_forms(self) -> None:
        # Nonempty assignment RHS intervals remain legal in empty loops.
        # Identity-free vacuous Image, String, comparison and inner-bound
        # positions still pass the actual frontend and automatic proof pipeline.
        declarations = b'A:Integer range 0..9:=7;N:Integer range 0..9:=0;S:String:="x";'
        body = (b'for I in 20..10 loop A:=0;A:=A;'
                b'if I<0 then null;end if;'
                b'S:=Integer\'Image((I + 2147483647));'
                + output(b"Integer'Image((I + 2147483647))")
                + b'for J in 5..I loop A:=0;end loop;end loop;'
                  b'for I in reverse 20..10 loop A:=0;end loop;'
                  b'for I in 10..N loop A:=0;end loop;'
                  b'for I in 1..2 loop for J in 5..I loop A:=I;end loop;end loop;'
                + output(b"Integer'Image(A)&\"/\"&S"))
        for arguments in (False, True):
            with self.subTest(arguments=arguments):
                executable, _ = self.compile_retained(program(declarations, body, arguments=arguments))
                self.run_program(executable, b' 7/x\n', (b'ok',) if arguments else ())

    def test_admission_mutable_images_use_declared_widths(self) -> None:
        for lower, upper, initial, width, status in (
            (-9, 9, 0, 2, 0), (10, 99, 10, 3, 0), (9, 10, 9, 2, 2),
            (9, 10, 10, 3, 2), (0, 1000, 0, 2, 2),
            (-2147483648, -1000000000, -2147483648, 11, 0),
        ):
            declarations = (f'A:Integer range {lower}..{upper}:={initial};'.encode()
                            + b'S:String:="' + b'x' * width + b'";')
            self.check(program(declarations, b'S:=Integer\'Image(A);'), status)
        self.check(program(b'A:Integer range 9..10:=9;S:String:=Integer\'Image(A);',
                           b'A:=9;S:=Integer\'Image(A);'))

    def test_admission_scalar_guard_composes_with_input_length_facts(self) -> None:
        declarations = b'A:Integer range 10..99:=10;'
        body = (b'if Input=Integer\'Image(A) then A:=99;'
                + output(b'Input&Integer\'Image(A)') + b'end if;')
        self.check(program(declarations, body, arguments=True))
        self.check(program(declarations, b'A:=99;' + output(b'Input&Integer\'Image(A)'),
                           arguments=True, capacity=4093))
        self.check(program(declarations, b'A:=99;' + output(b'Input&Integer\'Image(A)'),
                           arguments=True, capacity=4094), 2)

    def test_admission_range_operators_share_the_source_budget(self) -> None:
        declaration = b'A:Integer range 0..(+9):=0;'
        for count, status in ((62, 0), (63, 2)):
            self.check(program(declaration, b'A:=(9 - A);' * count), status)

    def compile_retained(self, source: bytes) -> tuple[Path, dict]:
        """Keep genuine probe sources/models/reports for the capability record."""
        self.source.write_bytes(source)
        before = set(HOST.artifacts.glob('imagews-*'))
        with mock.patch.dict(os.environ, {'SILVER_KEEP_IMAGE_WORKSPACES': '1'}):
            result = invoke('compile', self.source)
        print(result.stdout, flush=True)
        retained_images = sorted(str(path) for path in set(HOST.artifacts.glob('imagews-*')) - before)
        print('Retained Image workspaces: ' + json.dumps(retained_images), flush=True)
        self.assertEqual(result.returncode, 0, result.stdout)
        match = re.search(r'^Executable: (.+)$', result.stdout, re.MULTILINE)
        self.assertIsNotNone(match, result.stdout)
        executable = Path(match.group(1))
        if not executable.is_absolute():
            executable = ROOT / executable
        workspace = executable.parent.parent
        self.assertEqual(workspace.parent, HOST.artifacts)
        self.assertEqual((workspace / 'main.adb').read_bytes(), source)
        (workspace / 'mutable-integers-test.log').write_text(result.stdout)
        (workspace / 'mutable-integers-image-workspaces.json').write_text(json.dumps(retained_images, indent=2) + '\n')
        report = json.loads((workspace / 'obj/gnatprove/main~1.spark').read_text())
        return executable, report

    def test_native_declaration_snapshots_and_mutable_image(self) -> None:
        declarations = (b'A:Integer range 0..99:=7;K:constant Integer:=A;'
                        b'S:String:=Integer\'Image(A);W:Integer range 10..99:=10;'
                        b'T:String:=Integer\'Image(W);')
        body = (b'A:=8;W:=99;T:=Integer\'Image(W);'
                + output(b'Integer\'Image(K)&S&Integer\'Image(A)&T'))
        executable, report = self.compile_retained(program(declarations, body))
        self.run_program(executable, b' 7 7 8 99\n')
        self.assertTrue(report['proof'])

    def test_native_driver_and_frozen_loop_bounds(self) -> None:
        declarations = (b'Answer:Integer range 0..1000:=0;'
                        b'Last:Integer range 1..3:=3;Seen:Integer range 0..3:=0;'
                        b'Outer:Integer range 0..9:=7;')
        body = (b'for N in 1..1000 loop if Answer=0 and then '
                b'((N * N) - ((N - 1) * (N - 1)))>1000 then Answer:=N;end if;end loop;'
                + output(b"Integer'Image(Answer)")
                + b'for I in 1..Last loop Last:=1;Seen:=I;'
                  b'for Outer in reverse 2..1 loop Seen:=0;end loop;end loop;'
                + output(b"Integer'Image(Seen)&Integer'Image(Last)&Integer'Image(Outer)"))
        executable, report = self.compile_retained(program(declarations, body))
        self.run_program(executable, b' 501\n 3 1 7\n')
        self.assertTrue(report['proof'])

    def test_native_dense_static_subtypes_and_initializer_advisories(self) -> None:
        from tests.test_capacity import dense_mutable_source

        source, declarations = dense_mutable_source()
        executable, report = self.compile_retained(source)
        self.run_program(executable, b' 9\n')
        initializers = [item for item in report['flow']
                        if item['rule'] == 'INEFFECTIVE'
                        and item['message']['text'].startswith('initialization of ')]
        self.assertEqual(len(initializers), declarations)
        entities = {item['name'] for item in report['entities'].values()}
        self.assertIn('Main', entities)
        self.assertLessEqual(entities, {'Main', 'Silver_IO.Put_Line'})
