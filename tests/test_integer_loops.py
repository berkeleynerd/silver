"""Typed integer constants, checked arithmetic and scoped finite for loops."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests.test_shared_bindings import SharedBindingsTests, output, program


class IntegerLoopsTests(unittest.TestCase):
    check = SharedBindingsTests.check
    compile = SharedBindingsTests.compile
    run_program = SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver integer loops-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'integers.adb'

    def test_scalar_literals_and_every_intermediate_operation(self) -> None:
        good = [b'0', b'+1', b'-1', b'(-2147483648)', b'-2_147_483_648',
                b'2147483647', b'16#7FFF_FFFF#', b'(-16#80000000#)',
                b'2:1:E+10', b'0E4096', b'((2 * 3) + (-4))',
                b'((1))', b'(+3)', b'(-(-3))']
        bad = [b'2147483648', b'-2147483649', b'(+2147483648)',
               b'(2147483647 + 1)', b'(-2147483648 - 1)', b'(-(-2147483648))',
               b'((2147483647 + 1) - 1)', b'(46341 * 46341)', b'2E31',
               b'0E4097', b'2E-1', b'16#FF:', b'1__0', b'1_',
               b'1 + 2', b'(1 + -1)', b'(- -1)', b'(+ +1)', b'abs 1']
        for value, status in [(value, 0) for value in good] + [(value, 2) for value in bad]:
            with self.subTest(value=value):
                self.check(program(b'N:constant Integer:=' + value + b';', b'null;'), status)

    def test_constants_are_initialized_typed_and_immutable(self) -> None:
        declarations = b'A:constant Integer:=3;B:constant Integer:=(A * A);S:String:="x";'
        self.check(program(declarations, b'if B=9 then ' + output(b'S') + b'end if;'))
        for source in [
            program(b'A:Integer:=3;', b'null;'),
            program(b'A:constant Integer;', b'null;'),
            program(b'A:constant Integer:=A;', b'null;'),
            program(b'A:constant Integer:=B;B:constant Integer:=1;', b'null;'),
            program(declarations, b'A:=2;'),
            program(declarations, output(b'A')),
            program(declarations, b'S:=A;'),
            program(declarations, b'if A=S then null;end if;'),
            program(b'S:String:="x";A:constant Integer:=S;', b'null;'),
            program(b'A:constant Integer:=1;A:String:="x";', b'null;'),
            program(b'A:String:="x";A:constant Integer:=1;', b'null;'),
        ]:
            with self.subTest(source=source):
                self.check(source, 2)

    def test_integer_type_visibility_preserves_existing_string_names(self) -> None:
        self.check(program(b'Integer:String:="x";', output(b'Integer')))
        self.check(program(b'N:constant Integer:=1;Integer:String:="x";', output(b'Integer')))
        for declarations in (b'Integer:constant Integer:=1;',
                             b'Integer:String:="x";N:constant Integer:=1;'):
            self.check(program(declarations, b'null;'), 2)

    def test_loop_scope_reverse_null_ranges_and_own_bounds(self) -> None:
        good = [b'for I in 1..3 loop null;end loop;',
                b'for I in reverse -2..2 loop null;end loop;',
                b'for I in 3..1 loop null;end loop;',
                b'for I in 1..3 loop for J in 1..I loop null;end loop;end loop;',
                b'for I in 1..3 loop for I in 1..2 loop null;end loop;end loop;',
                b'for I in 1..3 loop null;end loop;for I in 1..3 loop null;end loop;',
                b'for String in 1..3 loop if String=2 then null;end if;end loop;']
        bad = [b'for I in 1..3 loop end loop;',
               b'for I in 1..3 loop I:=2;end loop;',
               b'for I in 1..3 loop null;end loop;if I=1 then null;end if;',
               b'for I in 1..3 loop for I in 1..I loop null;end loop;end loop;',
               b'for Silver_IO in 1..3 loop null;end loop;',
               b'for I in 1..3 loop null;end;',
               b'while 1=1 loop null;end loop;',
               b'for I in 1..3 loop exit;end loop;']
        for body, status in [(body, 0) for body in good] + [(body, 2) for body in bad]:
            with self.subTest(body=body):
                self.check(program(b'', body), status)

    def test_scoped_indexes_hide_strings_constants_and_unqualified_calls(self) -> None:
        declarations = b'I:String:="x";N:constant Integer:=3;'
        self.check(program(declarations,
                           b'for I in 1..N loop if I=1 then null;end if;end loop;' + output(b'I')))
        self.check(program(declarations,
                           b'for N in 1..2 loop null;end loop;if N=3 then null;end if;'))
        for body in (b'for I in 1..N loop ' + output(b'I') + b'end loop;',
                     b'for I in 1..N loop I:="y";end loop;',
                     b'for N in 1..N loop null;end loop;'):
            self.check(program(declarations, body), 2)
        qualified = program(b'', b'for Put in 1..2 loop Silver_IO.Put("x");end loop;')
        qualified = qualified.replace(b'with Silver_IO;', b'with Silver_IO;use Silver_IO;')
        self.check(qualified)
        self.check(qualified.replace(b'Silver_IO.Put("x")', b'Put("x")'), 2)

    def test_loop_arithmetic_checks_whole_index_range_without_guard_refinement(self) -> None:
        self.check(program(b'', b'for I in -100..100 loop if (I * I)<=10000 then null;end if;end loop;'))
        self.check(program(b'', b'for I in 0..2147483647 loop if I<10 then '
                                b'if (I + 1)>0 then null;end if;end if;end loop;'), 2)
        self.check(program(b'', b'for I in 3..1 loop if (I + 2147483647)>0 then null;end if;end loop;'))
        self.check(program(b'', b'for I in 3..1 loop if (2147483647 + 1)>0 then null;end if;end loop;'), 2)

    def test_shared_work_budget_counts_operators_but_not_exponent_signs(self) -> None:
        declarations = b'N:constant Integer:=1E+0;S:String:="";'
        body = b''.join(b'if (+N)=1 then null;end if;' for _ in range(63))
        self.check(program(declarations, body))
        self.check(program(declarations, body + output(b'S&""')), 2)
        self.check(program(declarations, body + b'if (-N)<0 then null;end if;'), 2)

    def test_shared_work_budget_counts_plus_after_digit_e_identifiers(self) -> None:
        filler = b'if (+N)=1 then null;end if;'
        for name in (b'N1E', b'I1e', b'X_1E'):
            declarations = b'N:constant Integer:=1;' + name + b':constant Integer:=1;'
            expression = b'(' + name + b'+1)'
            placements = {
                'predicate': (b'', b'if ' + expression + b'=2 then null;end if;'),
                'loop_bound': (b'', b'for J in ' + expression + b'..2 loop null;end loop;'),
                'initializer': (b'B:constant Integer:=' + expression + b';', b'null;'),
            }
            for position, (extra_declarations, body) in placements.items():
                for preceding, status in ((62, 0), (63, 2)):
                    with self.subTest(name=name, position=position, operators=preceding + 1):
                        self.check(program(declarations + extra_declarations,
                                           filler * preceding + body), status)

    def test_shared_work_budget_is_independent_of_identifier_and_operator_spacing(self) -> None:
        declarations = (b'N:constant Integer:=1;N1E:constant Integer:=1;'
                        b'N1X:constant Integer:=1;')
        filler = b'if (+N)=1 then null;end if;'
        for expression in (b'(N1E + 1)', b'(N1E+ 1)', b'(N1E +1)',
                           b'(N1E-- exponent-like 1E+1 & -*\n+1)',
                           b'(N1E-1)', b'(N1E*1)', b'(N1E+N1E)', b'(N1X+1)'):
            for preceding, status in ((62, 0), (63, 2)):
                with self.subTest(expression=expression, operators=preceding + 1):
                    self.check(program(declarations, filler * preceding + b'if '
                                       + expression + b'>=0 then null;end if;'), status)

    def test_shared_work_budget_ignores_real_exponents_and_quoted_or_comment_operators(self) -> None:
        declarations = (b'N:constant Integer:=1;A:constant Integer:=1E+0;'
                        b'B:constant Integer:=2#1#E+0;C:constant Integer:=2:1:E+0;'
                        b'S:constant String:="N1E+1 & ""+"" -*";')
        body = b'-- N1E+1 & -*\n' + b'if (+N)=1 then null;end if;' * 63
        self.check(program(declarations, body))
        self.check(program(declarations, body + b'if (+N)=1 then null;end if;'), 2)

    def test_native_triangle_and_reverse_composition(self) -> None:
        body = (b'for I in 1..5 loop for J in 1..I loop Silver_IO.Put("*");end loop;'
                b'Silver_IO.Put_Line("");end loop;'
                b'for I in reverse 1..3 loop if I=3 then Silver_IO.Put("3");'
                b'elsif I=2 then Silver_IO.Put("2");else Silver_IO.Put("1");end if;end loop;')
        executable, _ = self.compile(program(b'', body), 'static')
        self.run_program(executable, b'*\n**\n***\n****\n*****\n321')

    def test_native_string_assignments_and_argument_guards_compose_with_loops(self) -> None:
        declarations = b'S:String:="old";Saved:constant String:=S;N:constant Integer:=2;'
        body = (b'for I in 1..N loop if I=1 then S:="new";else S:=Saved;end if;'
                + output(b'S&Input') + b'end loop;')
        executable, _ = self.compile(program(declarations, body, arguments=True, capacity=4093), 'selected')
        self.run_program(executable, b'new!\nold!\n', (b'!',))
        self.run_program(executable, b'', (b'x' * 4097,), 1)


if __name__ == '__main__':
    unittest.main()
