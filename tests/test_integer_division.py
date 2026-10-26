"""Integer division admission, sign bounds and same-source execution."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared_bindings

output = shared_bindings.output
program = shared_bindings.program


class IntegerDivisionTests(unittest.TestCase):
    check = shared_bindings.SharedBindingsTests.check
    compile = shared_bindings.SharedBindingsTests.compile
    run_program = shared_bindings.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver integer division-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'division.adb'

    def test_admission_singletons_follow_ada_sign_and_truncation_rules(self) -> None:
        cases = (
            (b'(7 / 3)', 2), (b'((-7) / 3)', -2),
            (b'(7 / (-3))', -2), (b'((-7) / (-3))', 2),
            (b'(7 mod 3)', 1), (b'((-7) mod 3)', 2),
            (b'(7 mod (-3))', -2), (b'((-7) mod (-3))', -1),
            (b'(7 rem 3)', 1), (b'((-7) rem 3)', -1),
            (b'(7 rem (-3))', 1), (b'((-7) rem (-3))', -1),
            (b'((-2147483648) / 1)', -2147483648),
            (b'((-2147483648) / 2)', -1073741824),
            (b'((-2147483648) mod (-1))', 0),
            (b'((-2147483648) rem (-1))', 0),
            (b'(2147483647 mod (-2147483648))', -1),
            (b'((-2147483648) rem 2147483647)', -1),
        )
        for expression, value in cases:
            with self.subTest(expression=expression):
                bound = str(value).encode()
                self.check(program(b'X:Integer range ' + bound + b'..' + bound
                                   + b':=' + expression + b';', b'null;'))

    def test_admission_every_shared_scalar_expression_position(self) -> None:
        for operator, value in ((b'/', b'4'), (b'mod', b'1'), (b'rem', b'1')):
            expression = b'(9 ' + operator + b' 2)'
            declarations = (b'K:constant Integer:=' + expression + b';'
                            b'X:Integer range ' + expression + b'..' + expression
                            + b':=' + value + b';')
            body = (b'X:=' + expression + b';if ' + expression + b'=' + value
                    + b' then null;end if;for I in ' + expression + b'..'
                    + expression + b' loop null;end loop;'
                    + output(b"Integer'Image(" + expression + b')'))
            for arguments in (False, True):
                with self.subTest(operator=operator, arguments=arguments):
                    self.check(program(declarations, body, arguments=arguments))

    def test_admission_nonzero_divisors_and_division_overflow(self) -> None:
        for operator in (b'/', b'mod', b'rem'):
            for lower, upper, initial in ((0, 0, 0), (-1, 1, 1), (0, 3, 3), (-3, 0, -3)):
                declarations = (f'D:Integer range {lower}..{upper}:={initial};'.encode())
                expression = b'(7 ' + operator + b' D)'
                with self.subTest(operator=operator, lower=lower, upper=upper):
                    self.check(program(declarations, b'if ' + expression + b'=0 then null;end if;'), 2)
                    self.check(program(declarations, b'if D/=0 then if ' + expression
                                       + b'=0 then null;end if;end if;'), 2)
            self.check(program(b'X:constant Integer:=(1 ' + operator + b' 0);', b'null;'), 2)
        self.check(program(b'X:constant Integer:=((-2147483648) / (-1));', b'null;'), 2)
        declarations = b'X:Integer:=-2147483648;D:Integer range -1..-1:=-1;'
        self.check(program(declarations, b'if (X / D)=0 then null;end if;'), 2)
        for operator in (b'mod', b'rem'):
            self.check(program(declarations, b'if (X ' + operator + b' D)=0 then null;end if;'))

    def test_admission_quotient_hulls_for_positive_and_negative_divisors(self) -> None:
        for lower, upper in ((2, 3), (-3, -2)):
            declarations = (b'X:Integer range -9..9:=0;'
                            + f'D:Integer range {lower}..{upper}:={lower};'.encode())
            self.check(program(declarations + b'R:Integer range -4..4:=0;', b'R:=(X / D);'))
            self.check(program(declarations + b'R:Integer range -3..3:=0;', b'R:=(X / D);'), 2)
        declarations = b'X:Integer:=0;D:Integer range 2..2:=2;R:Integer range -1073741824..1073741823:=0;'
        self.check(program(declarations, b'R:=(X / D);'))

    def test_admission_modulus_and_remainder_include_interior_extrema(self) -> None:
        for operator in (b'mod', b'rem'):
            declarations = b'X:Integer range 0..6:=6;D:Integer range 3..3:=3;'
            self.check(program(declarations + b'R:Integer range 0..2:=0;',
                               b'R:=(X ' + operator + b' D);'))
            self.check(program(declarations + b'R:Integer range 0..0:=0;',
                               b'R:=(X ' + operator + b' D);'), 2)
        for lower, upper, result_lower, result_upper in (
            (2, 41, 0, 40), (-41, -2, -40, 0),
            (-2147483648, -1, -2147483647, 0),
        ):
            declarations = (b'X:Integer:=0;'
                            + f'D:Integer range {lower}..{upper}:={lower};'.encode()
                            + f'R:Integer range {result_lower}..{result_upper}:=0;'.encode())
            self.check(program(declarations, b'R:=(X mod D);'))
        for lower, upper, result_lower, result_upper in (
            (-6, 0, -2, 0), (-6, 6, -2, 2), (0, 1, 0, 1), (-1, 0, -1, 0),
        ):
            declarations = (f'X:Integer range {lower}..{upper}:=0;'.encode()
                            + b'D:Integer range -3..-3:=-3;'
                            + f'R:Integer range {result_lower}..{result_upper}:=0;'.encode())
            self.check(program(declarations, b'R:=(X rem D);'))
        declarations = b'X:Integer:=0;D:Integer range -2147483648..-1:=-1;'
        self.check(program(declarations + b'R:Integer range -2147483647..2147483647:=0;', b'R:=(X rem D);'))

    def test_admission_initializers_capture_values_and_staticness_is_preserved(self) -> None:
        declarations = (b'A:Integer range -9..9:=7;B:Integer range 0..3:=3;'
                        b'Q:constant Integer:=(A / B);M:constant Integer:=(A mod B);'
                        b'R:constant Integer:=(A rem B);'
                        b'X:Integer range 2..2:=Q;Y:Integer range 1..1:=M;Z:Integer range 1..1:=R;')
        self.check(program(declarations, b'A:=0;B:=0;'))
        for endpoint in (b'Q', b'M', b'R'):
            self.check(program(declarations + b'T:Integer range 0..' + endpoint + b':=0;', b'null;'), 2)
        self.check(program(declarations, b'if (A / B)=0 then null;end if;'), 2)

    def test_admission_empty_operands_do_not_waive_divisor_or_static_legality(self) -> None:
        for operator in (b'/', b'mod', b'rem'):
            body = b'for I in 2..1 loop if (I ' + operator + b' 1)=0 then null;end if;end loop;'
            self.check(program(b'', body))
            body = b'for I in 2..1 loop if (1 ' + operator + b' I)=0 then null;end if;end loop;'
            self.check(program(b'', body))
            for expression in (b'(I ' + operator + b' 0)',
                               b'((2147483647 + 1) ' + operator + b' I)',
                               b'(I + (1 ' + operator + b' 0))'):
                self.check(program(b'', b'for I in 2..1 loop if ' + expression
                                   + b'=0 then null;end if;end loop;'), 2)

    def test_admission_operator_words_are_case_insensitive_whole_tokens(self) -> None:
        for expression in (b'(7 MoD 3)', b'(7 rEm 3)', b'((7)mod(3))',
                           b'(7-- operator follows comment\nREM-- right follows comment\n3)', b'(7/3)'):
            self.check(program(b'X:Integer:=' + expression + b';', b'null;'))
        for expression in (b'(7mod 3)', b'(7 rem3)', b'(7 modulus 3)', b'(7 rem_ 3)',
                           b'(7 /= 3)', b'7 / 3', b'(7 / -3)', b'(7 mod -3)', b'(7 rem -3)'):
            self.check(program(b'X:Integer:=' + expression + b';', b'null;'), 2)

    def test_admission_division_shares_exactly_the_existing_operator_budget(self) -> None:
        declarations = (b'N:constant Integer:=1;A:constant Integer:=1E+0;'
                        b'Modulus:constant Integer:=1;Rem2:constant Integer:=1;'
                        b'S:String:="/ mod rem -- & + -*";')
        filler = b'if N/=0 then null;end if;'
        for operator in (b'/', b'mod', b'REM'):
            unit = b'if (N ' + operator + b' 1)>=0 then null;end if;'
            for count, status in ((63, 0), (64, 2)):
                with self.subTest(operator=operator, count=count):
                    self.check(program(declarations, b'-- / mod rem & - + *\n' + filler * 20
                                       + unit * count), status)
            for extra in (b'if (+N)=1 then null;end if;', b'S:=S&"";',
                          b'if (Modulus+Rem2)=2 then null;end if;'):
                self.check(program(declarations, unit * 63 + extra), 2)

    def test_native_dynamic_signs_and_minimum_integer(self) -> None:
        declarations = (b'A:Integer range -7..7:=-7;P:Integer range 2..3:=3;'
                        b'N:Integer range -3..-2:=-3;L:Integer:=-2147483648;'
                        b'M:Integer range -1..-1:=-1;')
        images = [b'(A / P)', b'(A / N)', b'(A mod P)', b'(A mod N)',
                  b'(A rem P)', b'(A rem N)']
        line = output(b'&"/"&'.join(b"Integer'Image(" + item + b')' for item in images))
        body = (line + b'A:=7;' + line
                + output(b"Integer'Image((L mod M))&Integer'Image((L rem M))"))
        executable, report = self.compile(program(declarations, body), 'static')
        self.run_program(executable, b'-2/ 2/ 2/-1/-1/-1\n 2/-2/ 1/-2/ 1/ 1\n 0 0\n')
        self.assertTrue(any(item['rule'] == 'VC_DIVISION_CHECK' for item in report['proof']))

    def test_native_josephus_and_remainder_interior_values(self) -> None:
        declarations = (b'R:Integer range 0..40:=0;X:Integer range -6..6:=0;'
                        b'D:Integer range 3..3:=3;Y:Integer range -2..2:=0;')
        body = (b'for I in 2..41 loop R:=((R + 3) mod I);end loop;'
                + output(b"Integer'Image((R + 1))")
                + b'X:=5;Y:=(X rem D);' + output(b"Integer'Image(Y)")
                + b'X:=(-5);Y:=(X rem D);' + output(b"Integer'Image(Y)"))
        for arguments in (False, True):
            executable, _ = self.compile(program(declarations, body, arguments=arguments),
                                         'selected' if arguments else 'static')
            self.run_program(executable, b' 31\n 2\n-2\n', (b'ok',) if arguments else ())


if __name__ == '__main__':
    unittest.main()
