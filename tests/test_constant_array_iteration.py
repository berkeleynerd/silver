"""Constant Integer-array iteration and its existing flow compositions."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared_bindings
from tests.test_integer_arrays import addition
from tests.test_predicates import argument_program

program = shared_bindings.program
output = shared_bindings.output


class ConstantArrayIterationTests(unittest.TestCase):
    check = shared_bindings.SharedBindingsTests.check
    compile = shared_bindings.SharedBindingsTests.compile
    run_program = shared_bindings.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver constant array iteration-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'foreach.adb'

    def test_admission_forward_reverse_singleton_and_comments(self) -> None:
        for declaration in (
            b'A:constant array(-2..0)of Integer:=(-1,0,1);',
            b'A:constant array(2147483647..2147483647)of Integer:=(2147483647=>7);',
            b'A:constant array(-2147483648..-2147483648)of Integer:=(-2147483648=>0);',
        ):
            for reverse in (b'', b'reverse '):
                for arguments in (False, True):
                    with self.subTest(declaration=declaration, reverse=reverse, arguments=arguments):
                        self.check(program(declaration, b'for E of ' + reverse + b'A loop '
                                           + output(b"Integer'Image(E)") + b'end loop;',
                                           arguments=arguments))
        self.check(program(b'A:constant array(1..2)of Integer:=(1,2);',
                           b'fOr E oF-- iterable\nReVeRsE a LoOp null;EnD lOoP;'))

    def test_admission_only_bare_visible_constant_integer_arrays(self) -> None:
        declarations = (b'A:constant array(1..2)of Integer:=(1,2);'
                        b'B:array(1..2)of Integer:=(1,2);N:constant Integer:=1;S:String:="ab";')
        for specification in (b'B', b'N', b'S', b'Absent', b'(A)', b'A(1)', b'A(1..2)',
                              b"A'Range", b'A when 1=1', b'1..2', b'reverse reverse A'):
            with self.subTest(specification=specification):
                self.check(program(declarations, b'for E of ' + specification
                                   + b' loop null;end loop;'), 2)
        for body in (b'for E:Integer of A loop null;end loop;',
                     b'for E of A loop end loop;',
                     b'for E of A loop exit;end loop;',
                     b'for E of A loop null;end;',
                     b'for E of A loop E:=0;end loop;',
                     b'for E of A loop A(1):=0;end loop;'):
            self.check(program(declarations, body), 2)

    def test_admission_full_integer_entry_range_and_guarded_element_uses(self) -> None:
        declarations = (b'A:constant array(1..2)of Integer:=(1,2);'
                        b'B:array(1..2)of Integer:=(0,0);X:Integer range 1..2:=1;')
        for body in (b'X:=E;', output(b"Integer'Image((E + 1))"),
                     b'B(E):=0;', b'for I in 1..E loop B(I):=0;end loop;'):
            self.check(program(declarations, b'for E of A loop ' + body + b'end loop;'), 2)
        self.check(program(declarations,
                           b'for E of A loop if E>=1 and then E<=2 then '
                           b'B(E):=E;X:=E;' + output(b"Integer'Image((E + 1))")
                           + b'end if;end loop;'))
        # A singleton source value does not make the element binding Ada-static.
        self.check(program(declarations + b'N:Integer range 0..3:=0;',
                           b'for E of A loop if N=E then B(N):=0;end if;end loop;'), 2)

    def test_admission_nested_loops_and_mutable_array_writes(self) -> None:
        declarations = (b'A:constant array(1..2)of Integer:=(1,2);'
                        b'B:array(1..2)of Integer:=(0,0);')
        for body in (
            b'for I in 1..2 loop for E of A loop B(I):=E;end loop;end loop;',
            b'for E of reverse A loop if E>=1 and then E<=2 then '
            b'for F of A loop B(E):=F;end loop;end if;end loop;',
            b'for E of A loop if E>=1 and then E<=2 then '
            b'for I in 1..2 loop B(E):=I;end loop;end if;end loop;',
            b'for E of A loop for E of reverse A loop B(1):=E;end loop;end loop;',
        ):
            with self.subTest(body=body):
                self.check(program(declarations, body))

    def test_admission_hiding_own_specification_and_restored_scope(self) -> None:
        declarations = (b'A:constant array(1..2)of Integer:=(1,2);'
                        b'E:String:="ok";N:constant Integer:=3;')
        self.check(program(declarations, b'for E of A loop '
                           + output(b"Integer'Image(E)") + b'end loop;' + output(b'E')))
        self.check(program(declarations, b'for N of A loop null;end loop;'
                           b'if N=3 then null;end if;'))
        self.check(program(declarations, b'for String of A loop if String=1 then null;end if;end loop;'))
        self.check(program(declarations, b'for Integer of A loop null;end loop;'))
        for body in (
            b'for A of A loop null;end loop;',
            b'for a of reverse A loop null;end loop;',
            b'for A in 1..2 loop for E of A loop null;end loop;end loop;',
            b'for E of A loop for F of E loop null;end loop;end loop;',
            b'for E of A loop E:="no";end loop;',
            b'for E of A loop null;end loop;if E=1 then null;end if;',
            b'for Integer of A loop ' + output(b"Integer'Image(1)") + b'end loop;',
            b'for Silver_IO of A loop null;end loop;',
        ):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        qualified = program(declarations, b'for Put of A loop Silver_IO.Put("x");end loop;')
        qualified = qualified.replace(b'with Silver_IO;', b'with Silver_IO;use Silver_IO;')
        self.check(qualified)
        self.check(qualified.replace(b'Silver_IO.Put("x")', b'Put("x")'), 2)
        self.check(program(declarations, b'for Silver_Arguments of A loop null;end loop;',
                           arguments=True), 2)

    def test_admission_mutables_widen_and_element_facts_do_not_escape(self) -> None:
        declarations = (b'A:constant array(1..2)of Integer:=(1,2);'
                        b'N:Integer range 0..2:=1;X:Integer range 1..1:=1;')
        self.check(program(declarations, b'N:=1;for E of A loop X:=N;end loop;'), 2)
        self.check(program(declarations, b'for E of A loop N:=1;end loop;X:=N;'), 2)
        self.check(program(declarations, b'for E of A loop if E<9 then null;end if;'
                           + output(b"Integer'Image((E + 1))") + b'end loop;'), 2)
        self.check(program(declarations, b'for E of A loop if N>=1 and then N<=1 then '
                           b'X:=N;end if;end loop;'))

    def test_admission_definitely_nonempty_input_and_string_transfer(self) -> None:
        declarations = b'A:constant array(0..0)of Integer:=(0=>0);Work:String:="old";'
        body = (b'for E of A loop if Silver_Arguments.Input_Is_Valid then '
                b'if Input\'Length=3 then Work:=Input;end if;else '
                b'Silver_Arguments.Reject;end if;end loop;'
                b'if Silver_Arguments.Input_Is_Valid then ' + output(b'Work') + b'end if;')
        self.check(argument_program(declarations, body))
        self.check(argument_program(declarations, body.replace(b'for E of A', b'for E in 1..0')), 2)
        # Reject returns and does not eliminate valid executions of its arm.
        self.check(program(declarations,
                           b'for E of A loop if Input="old" then null;else '
                           b'Silver_Arguments.Reject;end if;end loop;Work:=Input;',
                           arguments=True), 2)
        # A scalar-only contradiction cannot discard independent String paths.
        self.check(program(declarations,
                           b'for E of A loop if E<0 then Work:=Input;end if;end loop;',
                           arguments=True), 2)

    def test_admission_source_operator_operand_and_nested_frame_boundaries(self) -> None:
        declarations = b'A:constant array(0..1)of Integer:=(0,0);'
        for count, status in ((63, 0), (64, 2)):
            self.check(program(declarations, b'for E of A loop '
                               + b'if (+E)=0 then null;end if;' * count + b'end loop;'), status)
        for count, status in ((64, 0), (65, 2)):
            expression = addition([b'E'] * count)
            self.check(program(declarations, b'for E of A loop if E=0 then if ' + expression
                               + b'=0 then null;end if;end if;end loop;'), status)
        depth = 0
        source = b''
        while True:
            candidate = program(declarations, b'for E of A loop ' * (depth + 1)
                                + b'null;' + b'end loop;' * (depth + 1))
            if len(candidate) > 4096:
                break
            source = candidate
            depth += 1
        self.assertGreater(depth, 150)
        source += b' ' * (4096 - len(source))
        self.check(source)
        self.check(source + b' ', 2)

    def test_native_order_guards_nested_writes_and_original_source(self) -> None:
        declarations = (b'A:constant array(-1..3)of Integer:=(-1,0,1,2,3);'
                        b'B:array(1..3)of Integer:=(0,0,0);')
        body = (b'for E of A loop Silver_IO.Put(Integer\'Image(E));end loop;'
                b'Silver_IO.Put_Line("");'
                b'for E of reverse A loop Silver_IO.Put(Integer\'Image(E));end loop;'
                b'Silver_IO.Put_Line("");'
                b'for E of A loop if E>=1 and then E<=3 then '
                b'for I in 1..1 loop B(E):=(E + 1);end loop;end if;end loop;'
                b'for I in 1..3 loop Silver_IO.Put(Integer\'Image(B(I)));end loop;'
                b'Silver_IO.Put_Line("");')
        executable, report = self.compile(program(declarations, body, arguments=True), 'selected')
        expected = b'-1 0 1 2 3\n 3 2 1 0-1\n 2 3 4\n'
        self.run_program(executable, expected)
        self.run_program(executable, expected, (b'foreach',))
        self.assertTrue(any(item['rule'] == 'VC_INDEX_CHECK' for item in report['proof']))
        self.assertTrue(any(item['rule'] == 'VC_OVERFLOW_CHECK' for item in report['proof']))

    def test_native_nonempty_reject_transfer(self) -> None:
        declarations = b'A:constant array(0..0)of Integer:=(0=>0);Work:String:="old";'
        body = (b'for E of reverse A loop if Silver_Arguments.Input_Is_Valid then '
                b'if Input\'Length=3 then Work:=Input;end if;else '
                b'Silver_Arguments.Reject;end if;end loop;'
                b'if Silver_Arguments.Input_Is_Valid then ' + output(b'Work') + b'end if;')
        executable, _ = self.compile(argument_program(declarations, body), 'selected')
        self.run_program(executable, b'old\n')
        self.run_program(executable, b'new\n', (b'new',))
        self.run_program(executable, b'old\n', (b'xx',))
        self.run_program(executable, b'', (b'one', b'two'), 1)


if __name__ == '__main__':
    unittest.main()
