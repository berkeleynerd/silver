"""Pinned-frontend folds must not expose illegal arithmetic in empty loops."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared
from tests.test_shared_bindings import output, program
from tests.test_silver import HOST, invoke


class EmptyLoopFoldTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check
    compile = shared.SharedBindingsTests.compile
    run_program = shared.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver empty loop folds-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'empty_folds.adb'

    def test_admission_constant_producing_empty_identities_are_rejected(self) -> None:
        declarations = (b'K:Integer:=1;Flag:Boolean:=False;S:String:="x";'
                        b'Zero:constant Integer:=0;One:constant Integer:=1;'
                        b'A:constant array(1..1)of Integer:=(1=>0);')
        seeds = (b'(I * 0)', b'(0 * I)', b'(I * Zero)', b'((I + 1) * (1 - 1))',
                 b'(I * A(1))', b'(I mod 1)', b'(I rem 1)', b'(I mod One)',
                 b'(I rem One)', b'(I mod (-1))', b'(I rem (-1))')
        for seed in seeds:
            expression = b'((' + seed + b' + 2147483647) + 1)'
            contexts = (
                output(b"Integer'Image(" + expression + b')'),
                b'S:=Integer\'Image(' + expression + b');',
                b'for J in ' + expression + b'..0 loop null;end loop;',
                b'if ' + expression + b'>I then null;end if;',
                b'Flag:=' + expression + b'>I;',
                output(b"Integer'Image((" + expression + b' + I))'),
            )
            for header in (b'for I in 2..1 loop ', b'K:=1;for I in 2..K loop ',
                           b'for I in reverse (-5)..(-6) loop '):
                for context in contexts:
                    with self.subTest(seed=seed, header=header, context=context):
                        source = program(declarations, header + context + b'end loop;')
                        self.check(source, 2)
                        before = set(HOST.artifacts.glob('program-*'))
                        result = invoke('compile', self.source)
                        self.assertEqual(result.returncode, 2, result.stdout)
                        self.assertEqual(self.source.read_bytes(), source)
                        self.assertEqual(set(HOST.artifacts.glob('program-*')), before)

    def test_admission_empty_identity_rules_do_not_change_nonempty_arithmetic(self) -> None:
        for seed in (b'(I * 0)', b'(0 * I)', b'(I mod 1)', b'(I rem 1)',
                     b'(I mod (-1))', b'(I rem (-1))'):
            with self.subTest(seed=seed):
                self.check(program(b'', b'for I in (-5)..5 loop if ' + seed
                                   + b'=0 then null;end if;end loop;'))

    def test_native_identity_free_empty_expressions_survive_full_build(self) -> None:
        # Each expression remains abstractly empty. The pinned frontend keeps
        # these forms nonstatic, including the tempting correlated x-x form.
        declarations = b'K:Integer:=1;Flag:Boolean:=False;S:String:="x";'
        expression = b'(((I * 1) + 2147483647) + 1)'
        body = (b'K:=1;for I in 2..K loop '
                + output(b"Integer'Image(" + expression + b')')
                + b'S:=Integer\'Image(' + expression + b');'
                + b'for J in ' + expression + b'..0 loop null;end loop;'
                + b'if ' + expression + b'>I then null;end if;'
                + b'Flag:=' + expression + b'>I;'
                + output(b"Integer'Image((" + expression + b' + I))')
                + b'end loop;for I in 2..1 loop '
                + output(b"Integer'Image((((I / 1) + 2147483647) + 1))")
                + output(b"Integer'Image((((I mod 2) + 2147483647) + 1))")
                + output(b"Integer'Image((((I rem 2) + 2147483647) + 1))")
                + output(b"Integer'Image((((I - I) + 2147483647) + 1))")
                + b'end loop;')
        executable, _ = self.compile(program(declarations, body), 'assigned')
        self.run_program(executable, b'')


if __name__ == '__main__':
    unittest.main()
