"""Fixed Integer array admission and its scalar/flow composition boundaries."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared_bindings

program = shared_bindings.program
output = shared_bindings.output


def addition(terms: list[bytes]) -> bytes:
    expression = terms[0]
    for term in terms[1:]:
        expression = b'(' + expression + b' + ' + term + b')'
    return expression


class IntegerArrayTests(unittest.TestCase):
    check = shared_bindings.SharedBindingsTests.check
    compile = shared_bindings.SharedBindingsTests.compile
    run_program = shared_bindings.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver integer arrays-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'arrays.adb'

    def test_admission_anonymous_bounds_and_exact_aggregate_shapes(self) -> None:
        for declarations in (
            b'A:array(1..2)of Integer:=(1,2);',
            b'A:constant array(-2..0)of Integer:=(-1,0,1);',
            b'L:constant Integer:=-1;H:constant Integer:=1;'
            b'A:array(L..H)of Integer:=(1,2,3);',
            b'A:array(0..0)of Integer:=(0=>7);',
            b'A:constant array(-2147483648..-2147483648)of Integer:=(-2147483648=>0);',
            b'A:array(2147483647..2147483647)of Integer:=((2147483646 + 1)=>0);',
            b'A:array(1..2)of Integer:=((1 + 2),(-4));',
        ):
            for arguments in (False, True):
                with self.subTest(declarations=declarations, arguments=arguments):
                    self.check(program(declarations, b'null;', arguments=arguments))
        self.check(program(b'A:aRrAy(1..2)oF iNtEgEr:=(1,2);', b'a(1):=2;'))
        self.check(program(b'A:array-- bounds\n(1..2)of-- type\nInteger:=(1,-- first\n2);', b'null;'))

    def test_admission_excludes_unselected_types_aggregates_and_bounds(self) -> None:
        declarations = (
            b'A:array(1..0)of Integer:=();',
            b'A:array(1..2)of Integer;',
            b'A:array(1..2)of Integer:=(1);',
            b'A:array(1..2)of Integer:=(1,2,3);',
            b'A:array(1..3)of Integer:=(1,2);',
            b'A:array(1..1)of Integer:=(7);',
            b'A:array(1..1)of Integer:=(0=>7);',
            b'A:array(1..2)of Integer:=(1=>7,2=>8);',
            b'A:array(1..2)of Integer:=(others=>0);',
            b'A:array(1..2)of Integer:=[1,2];',
            b'A:array(1..2)of Integer range 0..9:=(1,2);',
            b'A:array(1..2)of String:=("a","b");',
            b'A:array(1..2,1..2)of Integer:=((1,2),(3,4));',
            b'type T is array(1..2)of Integer;A:T:=(1,2);',
            b'N:Integer:=2;A:array(1..N)of Integer:=(1,2);',
            b'N:Integer:=2;K:constant Integer:=N;A:array(1..K)of Integer:=(1,2);',
            b'A:array(-2147483648..2147483647)of Integer:=(0,0);',
            b'A:array(1..2)of Integer:=(A(1),2);',
            b'A:array(1..2)of Integer:=(B(1),2);B:array(1..2)of Integer:=(1,2);',
        )
        for declaration in declarations:
            with self.subTest(declaration=declaration):
                self.check(program(declaration, b'null;'), 2)

    def test_admission_declaration_snapshots_are_exact_and_nonstatic(self) -> None:
        declarations = (
            b'N:Integer:=7;A:array(-1..0)of Integer:=(N,(N + 2));'
            b'K:constant Integer:=A(-1);X:Integer range 9..9:=A(0);'
            b'S:String:=Integer\'Image(A(-1));'
            b'B:constant array(1..2)of Integer:=(A(0),K);')
        self.check(program(declarations, b'N:=8;A(-1):=99;' + output(b"S&Integer'Image(K)")))
        for extra in (
            b'Z:Integer range K..K:=7;',
            b'Z:array(K..K)of Integer:=(7=>0);',
            b'Z:array(1..1)of Integer:=(A(-1)=>0);',
        ):
            with self.subTest(extra=extra):
                self.check(program(declarations + extra, b'null;'), 2)
        self.check(program(b'A:constant array(1..2)of Integer:=(1,1);'
                           b'K:constant Integer:=A(1);Z:Integer range K..K:=1;', b'null;'), 2)

    def test_admission_reads_are_scalar_atoms_in_existing_positions(self) -> None:
        declarations = (b'A:constant array(1..2)of Integer:=(1,2);'
                        b'X:Integer:=0;S:String:=" 0";')
        for body in (
            b'X:=A(1);',
            b'X:=(A(1) * 0);',
            b'if A(1)=A(2) then null;end if;',
            b'if A(1)<0 and then A(2)>=0 then null;end if;',
            output(b"Integer'Image(A(1))"),
            b'S:=Integer\'Image((A(1) * 0));',
        ):
            with self.subTest(body=body):
                self.check(program(declarations, body))
        # Direct constant-array bounds are an explicit frontend scope restriction.
        self.check(program(declarations, b'for I in A(1)..A(2) loop null;end loop;'), 2)
        # Body reads use the full component type for both constants and variables.
        for constant in (b'', b'constant '):
            declaration = b'A:' + constant + b'array(1..2)of Integer:=(1,2);'
            self.check(program(declaration + b'X:Integer range 1..2:=1;', b'X:=A(1);'), 2)
            self.check(program(declaration, b'if A(1)<9 then A(1):=(A(1) + 1);end if;'), 2)

    def test_admission_index_guards_use_scalar_flow_and_indices_stay_nonempty(self) -> None:
        declarations = b'A:array(1..2)of Integer:=(1,2);N:Integer range 0..3:=0;'
        use = output(b"Integer'Image(A(N))")
        self.check(program(declarations, b'if N>=1 and then N<=2 then A(N):=A(N);' + use + b'end if;'))
        self.check(program(declarations, b'N:=1;A(N):=2;'))
        for body in (
            use,
            b'if N>=1 then A(N):=0;end if;',
            b'for I in 2..1 loop A(I):=0;end loop;',
            b'for I in 2..1 loop ' + output(b"Integer'Image(A(I))") + b'end loop;',
            b'if 1=0 then A(3):=0;end if;',
            b'for I in 1..2 loop A(0):=0;end loop;',
            b'for I in 1..2 loop A((I + 1)):=0;end loop;',
            b'for I in 1..2 loop A(N):=0;end loop;',
        ):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        # Pinned GNAT rejects the empty loop's constant range error (language.md: nonempty RHS).
        self.check(program(b'subtype S is Integer range 0..9;A:array(1..1)of S:=(1=>0);',
                           b'for I in 20..19 loop A(1):=I;end loop;'), 2)

    def test_admission_mutability_type_and_subscript_boundaries(self) -> None:
        declarations = (b'A:array(1..2)of Integer:=(1,2);'
                        b'B:constant array(1..2)of Integer:=(1,2);X:Integer:=1;S:String:="a";')
        for body in (
            b'B(1):=0;', b'A:=B;', b'X:=A;', b'S:=A(1);', b'A(1):=S;',
            b'A(B(1)):=0;', b'A(A(1)):=0;', b'X:=A(B(1));',
            b'X:=A(1,2);', b'X:=A(1..2);', b"X:=A'First;", b"X:=A'Length;",
            b'X:=A();', b'A(1):=;', b'A(1):=2147483648;',
        ):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        self.check(program(declarations, b'A(1):=B(2);X:=A(2);'))

    def test_admission_names_and_scoped_hiding(self) -> None:
        for declarations in (
            b'A:array(1..2)of Integer:=(1,2);a:Integer:=0;',
            b'A:Integer:=0;a:array(1..2)of Integer:=(1,2);',
            b'A:String:="x";a:array(1..2)of Integer:=(1,2);',
            b'A:array(1..2)of Integer:=(1,2);a:String:="x";',
            b'Integer:array(1..2)of Integer:=(1,2);',
            b'Integer:String:="x";A:array(1..2)of Integer:=(1,2);',
            b'Silver_IO:array(1..2)of Integer:=(1,2);',
        ):
            with self.subTest(declarations=declarations):
                self.check(program(declarations, b'null;'), 2)
        declarations = b'A:array(1..2)of Integer:=(1,2);'
        self.check(program(declarations, b'for A in 1..2 loop ' + output(b"Integer'Image(A)")
                           + b'end loop;A(1):=3;'))
        for body in (b'for A in 1..2 loop A(1):=0;end loop;',
                     b'for A in A(1)..2 loop null;end loop;',
                     b'for I in )..2 loop null;end loop;'):
            self.check(program(declarations, body), 2)
        source = program(b'Put:array(1..2)of Integer:=(1,2);', b'Put("x");')
        self.check(source.replace(b'with Silver_IO;', b'with Silver_IO;use Silver_IO;'), 2)
        self.check(program(b'Put:array(1..2)of Integer:=(1,2);', b'Silver_IO.Put("x");'))

    def test_admission_index_leaves_and_program_operators_keep_existing_budgets(self) -> None:
        declarations = b'A:constant array(0..1)of Integer:=(0,0);X:Integer:=0;'
        # Each zeroed read contributes array + subscript + zero = three leaves.
        for count, status in ((21, 0), (22, 2)):
            self.check(program(declarations, b'X:=' + addition([b'(A(0) * 0)'] * count) + b';'), status)
        for count, status in ((63, 0), (64, 2)):
            index = addition([b'0'] * count)
            self.check(program(declarations, b'X:=A(' + index + b');'), status)
            self.check(program(b'A:array(0..1)of Integer:=(0,0);', b'A(' + index + b'):=0;'), status)
        for count, status in ((63, 0), (64, 2)):
            self.check(program(b'A:array(1..2)of Integer:=(0,0);', b'A(1):=(A(1) * 0);' * count), status)

    def test_admission_rotation_driver_and_argument_composition(self) -> None:
        declarations = (b'Source:constant array(1..9)of Integer:=(1,2,3,4,5,6,7,8,9);'
                        b'Result:array(1..9)of Integer:=(0,0,0,0,0,0,0,0,0);')
        body = (b'for I in 1..6 loop Result(I):=Source((I + 3));end loop;'
                b'for I in 7..9 loop Result(I):=Source((I - 6));end loop;'
                b'for I in 1..9 loop Silver_IO.Put(Integer\'Image(Result(I)));end loop;'
                b'Silver_IO.Put_Line("");')
        for arguments in (False, True):
            self.check(program(declarations, body, arguments=arguments))

    def test_admission_nested_loops_keep_the_initializer_table_out_of_body_frames(self) -> None:
        declaration = b'A:array(1..2)of Integer:=(0,0);'
        depth = 0
        source = b''
        while True:
            candidate = program(declaration, b'for I in 1..1 loop ' * (depth + 1)
                                + b'A(1):=I;' + b'end loop;' * (depth + 1))
            if len(candidate) > 4096:
                break
            source = candidate
            depth += 1
        self.assertGreater(depth, 140)
        self.check(source + b' ' * (4096 - len(source)))

    def test_native_rotation_snapshots_and_guarded_index_report(self) -> None:
        declarations = (
            b'Source:constant array(1..9)of Integer:=(1,2,3,4,5,6,7,8,9);'
            b'Result:array(1..9)of Integer:=(0,0,0,0,0,0,0,0,0);'
            b'Seed:Integer:=7;A:array(-1..0)of Integer:=(Seed,9);'
            b'K:constant Integer:=A(-1);S:String:=Integer\'Image(A(0));'
            b'N:Integer range 0..2:=1;')
        body = (b'Seed:=8;A(-1):=99;' + output(b"Integer'Image(K)&\"/\"&S")
                + b'for Pass in 1..2 loop if N>=1 and then N<=2 then '
                  b'Result(N):=Source(N);end if;if N<2 then N:=(N + 1);end if;end loop;'
                  b'for I in 1..9 loop Silver_IO.Put(Integer\'Image(Source(I)));end loop;'
                  b'Silver_IO.Put_Line(\"\");'
                  b'for I in 1..6 loop Result(I):=Source((I + 3));end loop;'
                  b'for I in 7..9 loop Result(I):=Source((I - 6));end loop;'
                  b'for I in 1..9 loop Silver_IO.Put(Integer\'Image(Result(I)));end loop;'
                  b'Silver_IO.Put_Line(\"\");')
        executable, report = self.compile(
            program(declarations, body, arguments=True, capacity=10), 'selected')
        expected = b' 7/ 9\n 1 2 3 4 5 6 7 8 9\n 4 5 6 7 8 9 1 2 3\n'
        self.run_program(executable, expected)
        self.run_program(executable, expected, (b'array',))
        self.assertTrue(any(item['rule'] == 'VC_INDEX_CHECK' for item in report['proof']))

    def test_admission_dense_explicit_initializers_fit_the_source_derived_table(self) -> None:
        # Near the source boundary, every component is explicit; no aggregate
        # choice silently creates a larger object than its written initializer.
        size = 1900
        values = b','.join([b'0'] * size)
        source = program(b'A:array(1..1900)of Integer:=(' + values + b');', b'A(1900):=1;')
        self.assertLessEqual(len(source), 4096)
        self.check(source + b' ' * (4096 - len(source)))
        self.check(program(b'A:array(1..1901)of Integer:=(' + values + b');', b'null;'), 2)


if __name__ == '__main__':
    unittest.main()
