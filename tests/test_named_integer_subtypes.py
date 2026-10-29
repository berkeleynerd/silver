"""Named Integer ranges, bounded components and their existing flow compositions."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared_bindings
from tests.test_integer_arrays import addition

program = shared_bindings.program
output = shared_bindings.output


class NamedIntegerSubtypeTests(unittest.TestCase):
    check = shared_bindings.SharedBindingsTests.check
    compile = shared_bindings.SharedBindingsTests.compile
    run_program = shared_bindings.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver named Integer subtypes-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'subtypes.adb'

    def test_admission_static_bounds_scalar_objects_and_local_narrowing(self) -> None:
        for declarations in (
            b'subtype S is Integer range 0..9;X:S:=0;K:constant S:=9;',
            b'subtype S is Integer range -2147483648..2147483647;X:S:=-2147483648;',
            b'subtype S is Integer range 7..7;X:S:=7;',
            b'L:constant Integer:=-2;H:constant Integer:=2;'
            b'subtype S is Integer range L..H;X:S range -1..1:=0;',
            b'subtype S is Integer range 0..9;K:constant S:=2;'
            b'subtype T is Integer range K..(K + 1);X:T:=3;',
            b'sUbTyPe S iS iNtEgEr RaNgE 0..9;X:s RaNgE 1..8:=1;',
            b'subtype-- name\nS is Integer range-- bounds\n0..9;X:S:=0;',
        ):
            for arguments in (False, True):
                with self.subTest(declarations=declarations, arguments=arguments):
                    self.check(program(declarations, b'null;', arguments=arguments))

    def test_admission_rejects_unselected_or_invalid_subtype_declarations(self) -> None:
        for declarations in (
            b'subtype S is Integer;',
            b'subtype S is Integer range 1..0;',
            b'subtype S is Integer range -2147483649..0;',
            b'subtype S is Integer range 0..2147483648;',
            b'subtype S is Integer range (2147483647 + 1)..0;',
            b'subtype S is Integer range 0..9;subtype T is S range 1..8;',
            b'subtype S is Integer range 0..9;subtype T is S;',
            b'type S is range 0..9;',
            b'type S is new Integer range 0..9;',
            b'subtype S is String range 0..9;',
            b'subtype S is Integer range S..9;',
            b'subtype S is Integer range K..9;K:constant Integer:=0;',
            b'X:S:=0;subtype S is Integer range 0..9;',
        ):
            with self.subTest(declarations=declarations):
                self.check(program(declarations, b'null;'), 2)

    def test_admission_initial_values_and_every_store_respect_declared_range(self) -> None:
        base = b'subtype S is Integer range 0..9;'
        for declaration in (
            b'X:S:=-1;', b'X:constant S:=10;', b'X:S range -1..9:=0;',
            b'X:S range 0..10:=0;', b'X:S range 2..1:=2;', b'X:S range 2..7:=1;',
            b'A:array(1..2)of S:=(-1,0);', b'A:constant array(1..2)of S:=(0,10);',
            b'A:array(1..1)of S:=(1=>10);',
            b'A:array(1..2)of S range 0..8:=(0,1);',
        ):
            with self.subTest(declaration=declaration):
                self.check(program(base + declaration, b'null;'), 2)
        declarations = base + b'X:S range 2..7:=2;A:array(1..2)of S:=(0,9);'
        self.check(program(declarations, b'X:=7;A(1):=0;A(2):=9;'))
        for body in (b'X:=1;', b'X:=8;', b'A(1):=-1;', b'A(2):=10;',
                     b'if 1=0 then A(1):=10;end if;',
                     b'for I in 2..1 loop A(1):=10;end loop;'):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)

    def test_admission_component_bounds_enable_reads_and_foreach_arithmetic(self) -> None:
        for constant in (b'', b'constant '):
            declarations = (b'subtype S is Integer range 0..9;A:' + constant
                            + b'array(1..2)of S:=(1,2);X:S:=0;')
            self.check(program(declarations, b'X:=A(1);'
                               + output(b"Integer'Image((A(2) * A(2)))")))
            # Identical initialized cells with full Integer components lack the bound.
            self.check(program(declarations.replace(b'of S', b'of Integer'), b'X:=A(1);'), 2)
            self.check(program(declarations.replace(b'of S', b'of Integer'),
                               output(b"Integer'Image((A(2) * A(2)))")), 2)
        declarations = (b'subtype S is Integer range 0..9;'
                        b'A:constant array(1..2)of S:=(1,2);X:S:=0;')
        for reverse in (b'', b'reverse '):
            self.check(program(declarations, b'for E of ' + reverse + b'A loop X:=E;'
                               + output(b"Integer'Image((E * E))") + b'end loop;'))
        self.check(program(declarations.replace(b'of S', b'of Integer'),
                           b'for E of A loop X:=E;end loop;'), 2)
        # A cell comparison does not refine a subsequent read of that cell.
        self.check(program(declarations, b'if A(1)<9 then X:=(A(1) + 1);end if;'), 2)

    def test_admission_exact_initializer_snapshots_do_not_become_static(self) -> None:
        base = (b'subtype S is Integer range 0..9;N:S:=7;'
                b'A:array(1..2)of S:=(N,9);K:constant S:=A(1);'
                b'X:S range 9..9:=A(2);Text:String:=Integer\'Image(K);')
        self.check(program(base, b'N:=8;A(1):=0;' + output(b'Text')))
        for suffix in (b'subtype T is Integer range K..9;',
                       b'X2:S range K..9:=7;',
                       b'B:array(K..9)of S:=(7,8,9);'):
            with self.subTest(suffix=suffix):
                self.check(program(base + suffix, b'null;'), 2)
        self.check(program(b'subtype S is Integer range 0..9;N:S:=7;'
                           b'K:constant S:=N;subtype T is Integer range K..9;', b'null;'), 2)

    def test_admission_subtype_names_are_metadata_and_share_name_visibility(self) -> None:
        for declarations in (
            b'subtype S is Integer range 0..9;s:Integer:=0;',
            b'S:Integer:=0;subtype s is Integer range 0..9;',
            b'S:String:="x";subtype s is Integer range 0..9;',
            b'S:array(1..2)of Integer:=(0,0);subtype s is Integer range 0..9;',
            b'subtype S is Integer range 0..9;subtype s is Integer range 0..9;',
            b'subtype Integer is Integer range 0..9;',
            b'subtype String is Integer range 0..9;',
            b'subtype Silver_IO is Integer range 0..9;',
            b'subtype begin is Integer range 0..9;',
            b'Integer:String:="x";subtype S is Integer range 0..9;',
            b'subtype S is Integer range 0..9;X:S:=S;',
            b'subtype S is Integer range 0..9;X:S:=X;',
        ):
            with self.subTest(declarations=declarations):
                self.check(program(declarations, b'null;'), 2)
        declarations = b'subtype S is Integer range 0..9;X:S:=0;'
        for body in (b'S:=0;', b'X:=S;', b'X:=S(1);', b'if S=0 then null;end if;',
                     output(b"S'Image(X)"), b'for E of S loop null;end loop;'):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        self.check(program(b'subtype S is Integer range 0..9;Integer:String:="x";'
                           b'X:S:=0;A:array(1..2)of S:=(0,9);', b'X:=A(1);'))
        self.check(program(declarations, b'for S in 1..2 loop X:=S;end loop;'))
        self.check(program(declarations, b'for S in S..2 loop null;end loop;'), 2)
        self.check(program(declarations, b'for S in 1..2 loop null;end loop;X:=S;'), 2)
        self.check(program(b'subtype Silver_Arguments is Integer range 0..9;', b'null;'))
        self.check(program(b'subtype Silver_Arguments is Integer range 0..9;',
                           b'null;', arguments=True), 2)
        source = program(b'subtype Put is Integer range 0..9;', b'Silver_IO.Put("x");')
        source = source.replace(b'with Silver_IO;', b'with Silver_IO;use Silver_IO;')
        self.check(source)
        self.check(source.replace(b'Silver_IO.Put("x")', b'Put("x")'), 2)

    def test_admission_guards_loop_widening_and_narrow_component_stores(self) -> None:
        declarations = (b'subtype Small is Integer range 0..9;'
                        b'subtype Wide is Integer range 0..10;'
                        b'A:array(1..2)of Small:=(0,0);'
                        b'C:constant array(1..2)of Wide:=(0,10);'
                        b'X:Wide:=0;Y:Small:=0;')
        self.check(program(declarations, b'if X<=9 then A(1):=X;Y:=X;end if;'))
        self.check(program(declarations, b'for E of C loop if E<=9 then '
                           b'for I in 1..2 loop A(I):=E;Y:=E;end loop;end if;end loop;'))
        self.check(program(declarations, b'X:=0;for I in 1..2 loop A(I):=X;end loop;'), 2)
        self.check(program(declarations, b'for E of C loop A(1):=E;end loop;'), 2)
        self.check(program(declarations, b'if X<=9 then null;end if;A(1):=X;'), 2)
        # A singleton element refinement is still not an Ada-static threshold.
        self.check(program(declarations, b'for E of C loop if E=1 then '
                           b'if X=E then A(1):=X;end if;end if;end loop;'), 2)

    def test_admission_retains_expression_and_source_derived_binding_budgets(self) -> None:
        declarations = b'subtype S is Integer range 0..9;X:S:=0;'
        for count, status in ((64, 0), (65, 2)):
            expression = addition([b'0'] * count)
            self.check(program(declarations, b'X:=' + expression + b';'), status)
        for count, status in ((63, 0), (64, 2)):
            # The subtype-bound addition consumes one program operator.
            source = program(b'subtype S is Integer range 0..(8 + 1);X:S:=0;',
                             b'X:=(X + 0);' * (count - 1))
            self.check(source, status)
        bindings = b''.join(b'X' + str(index).encode() + b':S:=0;' for index in range(370))
        source = program(b'subtype S is Integer range 0..9;' + bindings, b'null;')
        self.assertGreater(370, 4096 // 12)
        self.assertLessEqual(len(source), 4096)
        self.check(source + b' ' * (4096 - len(source)))
        self.check(source + b' ' * (4097 - len(source)), 2)

    def test_native_subtype_snapshots_narrow_stores_and_argument_composition(self) -> None:
        declarations = (b'subtype S is Integer range 0..9;'
                        b'subtype W is Integer range 0..10;N:S:=7;'
                        b'A:array(1..2)of S:=(N,9);K:constant S:=A(1);'
                        b'C:constant array(1..2)of W:=(0,10);X:S range 2..7:=2;')
        body = (b'N:=8;A(1):=0;X:=7;'
                b'for E of C loop if E<=9 then for I in 1..2 loop A(I):=E;'
                b'end loop;end if;end loop;'
                + output(b'Input')
                + output(b"Integer'Image(K)&Integer'Image(N)&Integer'Image(X)"
                         b"&Integer'Image(A(1))&Integer'Image(A(2))"))
        executable, report = self.compile(program(declarations, body, arguments=True), 'selected')
        expected = b' 7 8 7 0 0\n'
        self.run_program(executable, b'old\n' + expected)
        self.run_program(executable, b'new\n' + expected, (b'new',))
        self.run_program(executable, b'', (b'one', b'two'), 1)
        self.assertTrue(any(item['rule'] == 'VC_RANGE_CHECK' for item in report['proof']))

    def test_native_contradictory_guards_with_named_scalar_and_component_bounds(self) -> None:
        # Preserve the frontend-completion fix for #284 with bounded type metadata.
        declarations = (b'subtype S is Integer range 0..9;X:Integer:=0;R:S:=0;'
                        b'A:array(0..9)of S:=(0,0,0,0,0,0,0,0,0,0);'
                        b'C:constant array(1..2)of S:=(0,9);')
        body = (b'if X>=0 and then X<=9 then if X=99 then R:=X;A(X):=X;'
                b'end if;end if;for E of C loop for I in 1..2 loop '
                b'if E=99 then R:=E;A(E):=E;end if;end loop;end loop;'
                + output(b"Integer'Image(R)&Integer'Image(A(0))"))
        executable, _ = self.compile(program(declarations, body), 'static')
        self.run_program(executable, b' 0 0\n')


if __name__ == '__main__':
    unittest.main()
