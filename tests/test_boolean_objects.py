"""Boolean values preserve Ada evaluation, visibility and existing safety facts."""
from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared
from tests.test_predicates import argument_program
from tests.test_silver import ROOT

program = shared.program
output = shared.output


class BooleanObjectTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check
    compile = shared.SharedBindingsTests.compile
    run_program = shared.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver Boolean objects-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'booleans.adb'

    def test_initialized_objects_typing_and_assignment(self) -> None:
        declarations = (b'A:Boolean:=True;B:constant Boolean:=not A;'
                        b'C:Boolean:=(A and B);N:Integer:=1;S:String:="x";')
        self.check(program(declarations, b'A:=B;C:=not (A or B);if C then null;end if;'))
        for declaration in (b'A:Boolean;', b'A:constant Boolean;', b'A:Boolean:=A;',
                            b'A:Boolean:=B;B:Boolean:=True;', b'A:Boolean:=1;',
                            b'A:Boolean:="x";', b'A:Integer:=True;',
                            b'A:String:=False;', b'A:Boolean range False..True:=True;',
                            b'subtype Flag is Boolean;',
                            b'A:Boolean:=True;a:String:="x";'):
            with self.subTest(declaration=declaration):
                self.check(program(declaration, b'null;'), 2)
        for statement in (b'B:=True;', b'A:=N;', b'N:=A;', b'A:=S;', b'S:=A;',
                          output(b'A'), output(b"Boolean'Image(A)"),
                          b'if A<False then null;end if;', b'for I in False..True loop null;end loop;'):
            with self.subTest(statement=statement):
                self.check(program(declarations, statement), 2)

    def test_name_hiding_uses_binding_kind_and_declaration_scope(self) -> None:
        admitted = (
            (b'True:String:="yes";False:Integer:=0;',
             b'if TRUE="yes" and then fAlSe=0 then null;end if;'),
            (b'True:Boolean:=False;False:Boolean:=not True;',
             b'if tRuE or fAlSe then null;end if;'),
            (b'Boolean:String:="x";', output(b'BOOLEAN')),
            (b'Boolean:Integer:=1;', b'if Boolean=1 then null;end if;'),
            (b'subtype True is Integer range 1..2;N:True:=1;', b'null;'),
            (b'Flag:Boolean:=True;', b'for True in 1..2 loop '
             b'if True=1 then Flag:=False;end if;end loop;if True then null;end if;'),
            (b'Flag:Boolean:=False;', b'for Boolean in 1..1 loop '
             b'Flag:=not Flag;end loop;Flag:=True;'),
            (b'A:constant array(1..1)of Integer:=(1=>1);Flag:Boolean:=False;',
             b'for False of A loop if False=1 then Flag:=True;end if;end loop;'),
        )
        for declarations, body in admitted:
            with self.subTest(declarations=declarations, body=body):
                self.check(program(declarations, body))
        rejected = (
            (b'True:Boolean:=True;', b'null;'),
            (b'False:Boolean:=False;', b'null;'),
            (b'True:String:="x";Flag:Boolean:=True;', b'null;'),
            (b'False:Integer:=0;Flag:Boolean:=False;', b'null;'),
            (b'Boolean:String:="x";Flag:Boolean:=True;', b'null;'),
            (b'Boolean:Boolean:=True;', b'null;'),
            (b'Integer:Boolean:=True;', output(b"Integer'Image(0)")),
            (b'Integer:Boolean:=Integer\'Image(0)=" 0";', b'null;'),
            (b'Integer:Boolean:=True;S:String:=Integer\'Image(0);', b'null;'),
            (b'Flag:Boolean:=True;', b'for Flag in 1..1 loop Flag:=False;end loop;'),
            (b'Flag:Boolean:=True;', b'for True in 1..1 loop Flag:=True;end loop;'),
            (b'Flag:Boolean:=True;', b'for False in False..1 loop null;end loop;'),
            (b'subtype True is Integer range 1..2;Flag:Boolean:=True;', b'null;'),
            (b'subtype False is Integer range 1..2;Flag:Boolean:=False;', b'null;'),
            (b'True:array(1..1)of Integer:=(1=>1);Flag:Boolean:=True;', b'null;'),
            (b'Boolean:Integer:=1;Flag:Boolean:=True;', b'null;'),
            (b'Boolean:array(1..1)of Integer:=(1=>1);Flag:Boolean:=True;', b'null;'),
            (b'subtype Boolean is Integer range 1..2;Flag:Boolean:=True;', b'null;'),
            (b'Integer:Boolean:=True;N:Integer:=0;', b'null;'),
            (b'Integer:Boolean:=True;subtype S is Integer range 1..2;', b'null;'),
            (b'False:Integer:=0;Flag:Boolean:=not False;', b'null;'),
        )
        for declarations, body in rejected:
            with self.subTest(declarations=declarations, body=body):
                self.check(program(declarations, body), 2)
        guard = (b'if Silver_Arguments.Input_Is_Valid then null;'
                 b'else Silver_Arguments.Reject;end if;')
        for initializer, status in ((b'Input_Is_Valid', 2),
                                    (b'Silver_Arguments.Input_Is_Valid', 0)):
            source = argument_program(b'Input_Is_Valid:Boolean:=' + initializer + b';', guard)
            source = source.replace(b'with Silver_Arguments;',
                                    b'with Silver_Arguments;use Silver_Arguments;')
            self.check(source, status)

        for operation in (b'Put', b'Put_Line'):
            declaration = operation + b':Boolean:=True;'
            prefix = operation + b':=False;if ' + operation + b' then null;end if;'
            for call, status in ((operation, 2), (b'Silver_IO.' + operation, 0)):
                source = program(declaration, prefix + call + b'("ok");')
                source = source.replace(b'with Silver_IO;', b'with Silver_IO;use Silver_IO;')
                self.check(source, status)
        for rejection, status in ((b'Reject', 2), (b'Silver_Arguments.Reject', 0)):
            source = argument_program(b'Reject:Boolean:=True;',
                b'if Silver_Arguments.Input_Is_Valid then Reject:=False;'
                b'if Reject then null;end if;else ' + rejection + b';end if;')
            source = source.replace(b'with Silver_Arguments;',
                                    b'with Silver_Arguments;use Silver_Arguments;')
            self.check(source, status)

    def test_native_boolean_hiding_and_loop_scope_restoration(self) -> None:
        declarations = (b'True:Boolean:=False;False:Boolean:=not True;'
                        b'Put:Boolean:=not True;Put_Line:Boolean:=True;')
        body = (b'for True in 1..2 loop '
                b'if True=1 then Put_Line:=Put;end if;end loop;'
                b'if (not True) and False and Put_Line then '
                b'Silver_IO.Put("scope");Silver_IO.Put_Line(" restored");'
                b'else Silver_IO.Put_Line("bad");end if;')
        source = program(declarations, body).replace(
            b'with Silver_IO;', b'with Silver_IO;use Silver_IO;')
        executable, _ = self.compile(source, 'assigned')
        self.run_program(executable, b'scope restored\n')

    def test_homogeneous_chains_and_boolean_equality(self) -> None:
        declarations = b'A:Boolean:=True;B:Boolean:=False;C:Boolean:=True;'
        for condition in (b'True', b'False', b'not True', b'A=B', b'A/=False',
                          b'(A and B)=C', b'not A=True', b'A=not B',
                          b'A and B and C', b'A or B or C', b'A xor B',
                          b'A and then B and then C', b'A or else B or else C',
                          b'(A and B) or (C xor False)', b'not (A=B)',
                          b'(A and then B) or else not C'):
            with self.subTest(condition=condition):
                self.check(program(declarations, b'if ' + condition + b' then null;end if;'))
        for condition in (b'A and B or C', b'A or B xor C', b'A and then B and C',
                          b'A xor B xor C',
                          b'A=B=C', b'A<False', b'not not A', b'not ()',
                          b'True(1)', b'Boolean', b'A and', b'xor A'):
            with self.subTest(condition=condition):
                self.check(program(declarations, b'if ' + condition + b' then null;end if;'), 2)

    def test_xor_operand_spans_ignore_strings_comments_and_identifier_parts(self) -> None:
        declarations = (b'A:Boolean:=True;B:Boolean:=False;C:Boolean:=True;'
                        b'Xor_Value:Boolean:=False;Myxor:Boolean:=True;Xor1:Boolean:=True;S:String:="xor";')
        accepted = (
            b'A XoR B', b'(A xor B) and (C xor False)',
            b'(A xor B)=(C xor False)', b'Xor_Value xor Myxor', b'A xor Xor1',
            b'(S="xor") xor A', b'A xor ("XOR"=S)',
            b'(S="x""xor""y") xor A',
            b'A xor ("-- xor"=S)',
            b'(A -- xor in a comment\n) xor B',
            b'A xor (-- XoR in a comment\n B)',
            b'(A -- " xor\n) xor (B -- xor "\n)',
        )
        rejected = (
            b'A xor B xor C', b'A xor (B xor C)', b'(A xor B) xor C',
            b'A xor (B XoR C)', b'A xor (B and (A xor C))',
            b'((A xor B)=C) xor A', b'A xor ((B xor C)=A)',
            b'A xor (B -- ignored xor\n xor C)',
        )
        for condition in accepted + rejected:
            status = 0 if condition in accepted else 2
            with self.subTest(condition=condition):
                self.check(program(declarations + b'Flag:Boolean:=' + condition + b';',
                                   b'if Flag then null;end if;'), status)
                self.check(program(declarations, b'A:=' + condition + b';'), status)
                self.check(program(declarations, b'if ' + condition + b' then null;end if;'), status)
        # The span starts at each new expression, so an earlier xor cannot leak in.
        self.check(program(declarations + b'First:Boolean:=A xor B;Second:Boolean:=B xor C;',
                           b'A:=First xor Second;B:=A xor C;if B xor C then null;end if;'))

    def test_eager_rhs_requires_its_own_incoming_safety(self) -> None:
        declarations = b'D:Integer range 0..1:=0;Flag:Boolean:=False;'
        for operator, left in ((b'and', b'D/=0'), (b'or', b'D=0'), (b'xor', b'D/=0')):
            rhs = left + b' ' + operator + b' (1/D)=1'
            with self.subTest(operator=operator):
                self.check(program(declarations, b'if ' + rhs + b' then null;end if;'), 2)
                self.check(program(declarations, b'Flag:=' + rhs + b';'), 2)
        for condition in (b'D/=0 and then (1/D)=1', b'D=0 or else (1/D)=1',
                          b'not (D=0) and then (1/D)=1'):
            with self.subTest(condition=condition):
                self.check(program(declarations, b'Flag:=' + condition + b';'))
        # Eager composition also discards operand-derived facts on its outcome.
        self.check(program(declarations, b'if D/=0 and True then '
                           + output(b"Integer'Image((1/D))") + b'end if;'), 2)
        # Neither outcome keeps right-operand facts; each source divides by zero if admitted.
        for condition in (b'if True or D/=0 then ', b'if Flag and D=0 then null;else '):
            with self.subTest(condition=condition):
                self.check(program(declarations, condition + output(b"Integer'Image((1/D))")
                                   + b'end if;'), 2)
        for operator, status in ((b'and', 2), (b'and then', 0)):
            body = (b'if Silver_Arguments.Input_Is_Valid then Flag:=Input\'Length<=2048 '
                    + operator + b' Input&Input=Input;'
                    b'else Silver_Arguments.Reject;end if;')
            self.check(argument_program(b'Flag:Boolean:=False;', body), status)

    def test_stored_flags_do_not_keep_scalar_string_or_validity_relations(self) -> None:
        declarations = (b'D:Integer range 0..1:=1;N:Integer:=0;'
                        b'Safe:Boolean:=D/=0;')
        for body in (b'if Safe then N:=(1/D);end if;',
                     b'D:=0;if Safe then N:=(1/D);end if;',
                     b'if D/=0 then Safe:=True;end if;if Safe then N:=(1/D);end if;',
                     b'if (D/=0)=True then N:=(1/D);end if;',
                     b'for D in 1..1 loop Safe:=D/=0;end loop;'
                     b'if Safe then N:=(1/D);end if;'):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        # Boolean equality and assignment keep no RHS facts; each source divides by zero if admitted.
        for body in (b'if False=(D/=0) then N:=(1/D);end if;',
                     b'if False=(D=0) then null;else N:=(1/D);end if;',
                     b'Safe:=D/=0;N:=(1/D);',
                     b'Safe:=D=0;N:=(1/D);'):
            with self.subTest(body=body):
                self.check(program(b'D:Integer range 0..1:=0;N:Integer:=0;Safe:Boolean:=False;',
                                   body), 2)
        self.check(argument_program(b'Fits:Boolean:=Input\'Length<=3;S:String:="abc";',
                                    b'if Silver_Arguments.Input_Is_Valid and then Fits then '
                                    b'S:=Input;else Silver_Arguments.Reject;end if;'), 2)
        self.check(argument_program(b'Valid:Boolean:=Silver_Arguments.Input_Is_Valid;',
                                    b'if Valid then null;else Silver_Arguments.Reject;end if;'), 2)

    def test_comparison_initializers_arrays_and_argument_fact_composition(self) -> None:
        declarations = (b'subtype Digit is Integer range 1..9;'
                        b'A:array(1..2)of Digit:=(2,3);N:Integer:=A(1);'
                        b'Flag:Boolean:=(N/A(2))=0;'
                        b'Same:constant Boolean:=Input="old";'
                        b'Work:String:="abc";')
        body = (b'Flag:=A(1)<A(2);'
                b'if Silver_Arguments.Input_Is_Valid and then Input\'Length=3 then '
                b'if Flag then Work:=Input;end if;'
                b'Flag:=not Flag;Work:=Input;'
                b'else Silver_Arguments.Reject;end if;')
        self.check(argument_program(declarations, body))
        # The initializer uses exact earlier components; body reads use ranges.
        self.check(program(b'A:array(1..2)of Integer:=(1,2);Flag:Boolean:=(1/A(1))=1;',
                           b'Flag:=(1/A(1))=1;'), 2)
        self.check(program(b'A:array(1..2)of Integer:=(1,2);Flag:Boolean:=(1/A(1))=1;',
                           b'if Flag then null;end if;'))

    def test_source_and_existing_operator_leaf_limits(self) -> None:
        for count, status in ((63, 0), (64, 2)):
            self.check(program(b'Flag:Boolean:=True;', b'Flag:=(+1)=1;' * count), status)
        for leaves, status in ((64, 0), (65, 2)):
            expression = b'1'
            for _ in range(leaves - 1):
                expression = b'(' + expression + b'+1)'
            self.check(program(b'Flag:Boolean:=False;', b'Flag:=' + expression + b'>0;'), status)
        for reads, status in ((32, 0), (33, 2)):
            expression = b'A(1)'
            for _ in range(reads - 1):
                expression = b'(' + expression + b'+A(1))'
            self.check(program(b'subtype Unit is Integer range 0..1;'
                               b'A:constant array(1..1)of Unit:=(1=>0);Flag:Boolean:=False;',
                               b'Flag:=' + expression + b'=0;'), status)
        # Logical operators and literal/name leaves do not spend arithmetic gas.
        self.check(program(b'Flag:Boolean:=True;', b'Flag:=' + b' and '.join([b'True'] * 80) + b';'))
        source = program(b'Flag:Boolean:=True;', b'if Flag then null;end if;')
        source += b' ' * (4096 - len(source))
        self.check(source)
        self.check(source + b' ', 2)

    def test_native_truth_tables_and_boolean_snapshots(self) -> None:
        body = b''
        expected = b''
        operations = ((b'and', lambda a, b: a and b), (b'or', lambda a, b: a or b),
                      (b'xor', lambda a, b: a != b),
                      (b'and then', lambda a, b: a and b),
                      (b'or else', lambda a, b: a or b),
                      (b'=', lambda a, b: a == b), (b'/=', lambda a, b: a != b))
        for operator, result in operations:
            for left in (False, True):
                for right in (False, True):
                    body += b'L:=' + str(left).encode() + b';R:=' + str(right).encode() + b';'
                    body += (b'if L ' + operator + b' R then Silver_IO.Put("1");'
                             b'else Silver_IO.Put("0");end if;')
                    expected += b'1' if result(left, right) else b'0'
        declarations = (b'L:Boolean:=True;R:Boolean:=False;Snapshot:constant Boolean:=L;'
                        b'Negated:constant Boolean:=not R;')
        body += b'L:=False;R:=True;'
        for condition, result in ((b'not L=True', True), (b'L=not R', True),
                                  (b'not (L=True)', True), (b'not L/=R', False)):
            body += (b'if ' + condition + b' then Silver_IO.Put("1");'
                     b'else Silver_IO.Put("0");end if;')
            expected += b'1' if result else b'0'
        body += (b'L:=False;R:=True;if Snapshot and Negated and not L then '
                 b'Silver_IO.Put_Line(" snapshot");else Silver_IO.Put_Line("bad");end if;')
        executable, _ = self.compile(program(declarations, body), 'assigned')
        self.run_program(executable, expected + b' snapshot\n')

    def test_rosetta_expected_outputs_use_independent_task_oracles(self) -> None:
        samples = {sample['source']: sample for sample in
                   json.loads((ROOT / 'samples/manifest.json').read_text())['samples']}
        # Eratosthenes marks multiples, independently of the driver's trial division.
        composite = {multiple for divisor in range(2, 11)
                     for multiple in range(divisor * divisor, 101, divisor)}
        primes = ''.join(f' {number}\n' for number in range(2, 101) if number not in composite)
        self.assertEqual(samples['rosetta_sequence_of_primes_by_trial_division.adb']['expected']['stdout'], primes)
        squares = [number * number for number in range(1, 41)]
        cubes = {number ** 3 for number in range(1, 14)}
        selected = [square for square in squares if square not in cubes][:30]
        self.assertEqual(len(selected), 30)
        self.assertEqual(samples['rosetta_square_but_not_cube.adb']['expected']['stdout'],
                         ''.join(f' {number}' for number in selected) + '\n')
        first = [2, 5, 1, 3, 8, 9, 4, 6]
        common = set(first) & {3, 5, 6, 2, 9, 8, 4} & {1, 3, 7, 6, 9}
        self.assertEqual(common, {3, 6, 9})
        self.assertEqual(samples['rosetta_common_list_elements.adb']['expected']['stdout'],
                         '[' + ','.join(f' {number}' for number in first if number in common) + ']\n')

    def test_native_common_elements_no_match_boundary(self) -> None:
        source = (ROOT / 'samples/rosetta_common_list_elements.adb').read_bytes()
        # The third list contains no first-list element: no stale flag or comma.
        source = source.replace(b'(1, 3, 7, 6, 9)', b'(7, 7, 7, 7, 7)')
        executable, _ = self.compile(source, 'assigned')
        self.run_program(executable, b'[]\n')

    def test_native_trial_division_empty_inner_loop_boundary(self) -> None:
        source = (ROOT / 'samples/rosetta_sequence_of_primes_by_trial_division.adb').read_bytes()
        source = source.replace(b'2 .. 100', b'2 .. 2')
        executable, _ = self.compile(source, 'assigned')
        self.run_program(executable, b' 2\n')


if __name__ == '__main__':
    unittest.main()
