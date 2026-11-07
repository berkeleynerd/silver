"""Boolean array typing, snapshots and flow boundaries."""
from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared
from tests.test_predicates import argument_program

program = shared.program


class BooleanArrayTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check
    compile = shared.SharedBindingsTests.compile
    run_program = shared.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver Boolean arrays-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'flags.adb'

    def test_explicit_aggregates_and_static_bounds(self) -> None:
        for declarations in (
            b'A:array(0..1)of Boolean:=(True,False);',
            b'A:constant array(-1..-1)of Boolean:=(-1=>False);',
            b'L:constant Integer:=-1;A:array(L..0)of Boolean:=(False,True);',
            b'A:array(-2147483648..-2147483648)of Boolean:=(-2147483648=>True);',
            b'A:array(2147483647..2147483647)of Boolean:=(2147483647=>False);',
            b'Flag:Boolean:=True;A:array(1..2)of Boolean:=(Flag,not Flag);',
        ):
            with self.subTest(declarations=declarations):
                self.check(program(declarations, b'null;'))
        for declarations in (
            b'A:array(0..1)of Boolean;',
            b'A:array(1..0)of Boolean:=();',
            b'A:array(0..1)of Boolean:=(True);',
            b'A:array(0..1)of Boolean:=(True,False,True);',
            b'A:array(0..0)of Boolean:=(True);',
            b'A:array(0..0)of Boolean:=(1=>True);',
            b'A:array(0..1)of Boolean:=(0=>True,1=>False);',
            b'A:array(0..1)of Boolean:=(others=>False);',
            b'A:array(0..1)of Boolean:=((True,False));',
            b'A:array(0..1)of Boolean:=(1,0);',
            b'A:array(0..1)of Boolean:=(True,"x");',
            b'A:array(0..1,0..1)of Boolean:=((True,False),(False,True));',
            b'N:Integer:=1;A:array(0..N)of Boolean:=(True,False);',
            b'A:array(0..2147483648)of Boolean:=(True,False);',
        ):
            with self.subTest(declarations=declarations):
                self.check(program(declarations, b'null;'), 2)

    def test_visibility_and_integer_subtype_named_boolean(self) -> None:
        for declarations, body in (
            (b'Integer:array(0..1)of Boolean:=(True,False);', b'if Integer(0) then null;end if;'),
            (b'True:array(0..1)of Boolean:=(False,False);', b'True(0):=not True(1);'),
            (b'subtype Boolean is Integer range 0..1;A:array(0..1)of Boolean:=(0,1);N:Integer:=A(0);',
             b'A(0):=1;N:=A(1);'),
            (b'subtype Boolean is Integer range 0..1;A:constant array(0..1)of Boolean:=(0,1);N:Integer:=0;',
             b'for E of A loop N:=E;end loop;'),
        ):
            with self.subTest(declarations=declarations):
                self.check(program(declarations, body))
        for declarations in (
            b'Boolean:array(0..1)of Boolean:=(True,False);',
            b'Boolean:Integer:=0;A:array(0..1)of Boolean:=(True,False);',
            b'True:array(0..1)of Boolean:=(False,True);',
            b'A:array(0..1)of Boolean:=(A(0),False);',
            b'A:array(0..1)of Boolean:=(B(0),False);B:array(0..1)of Boolean:=(True,False);',
            b'Integer:array(0..1)of Boolean:=(Integer\'Image(0)=" 0",False);',
            b'Integer:array(0..1)of Boolean:=(True,False);N:Integer:=0;',
            b'A:array(0..1)of Boolean:=(True,False);a:Boolean:=True;',
        ):
            with self.subTest(declarations=declarations):
                self.check(program(declarations, b'null;'), 2)

    def test_typed_indexed_operations_and_loop_hiding(self) -> None:
        declarations = (b'A:array(0..1)of Boolean:=(True,False);'
                        b'B:constant array(0..1)of Boolean:=(False,True);'
                        b'I:array(0..1)of Integer:=(0,1);N:Integer:=0;F:Boolean:=True;')
        self.check(program(declarations, b'A(0):=not B(1);F:=A(1);'
                           b'for J in reverse 0..1 loop A(J):=not A(J);end loop;'))
        for body in (
            b'A(0):=1;', b'N:=A(0);', b'F:=I(0);', b'B(0):=False;',
            b'A:=B;', b'if A=B then null;end if;', b'for E of B loop null;end loop;',
            b'if A(I(0)) then null;end if;', b'if A(A(0)) then null;end if;',
            b'for A in 0..1 loop if A(0) then null;end if;end loop;',
            b'for A in 0..1 loop A(0):=False;end loop;',
        ):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        self.check(program(declarations, b'for A in 0..1 loop N:=A;end loop;A(0):=False;'))

    def test_nonempty_contained_indices_even_in_dead_code(self) -> None:
        declarations = b'A:array(1..2)of Boolean:=(True,False);N:Integer range 0..3:=0;'
        self.check(program(declarations, b'if N>=1 and then N<=2 then A(N):=not A(N);end if;'))
        for body in (
            b'if A(N) then null;end if;', b'if N>=1 then A(N):=False;end if;',
            b'for J in 2..1 loop A(J):=False;end loop;',
            b'for J in 20..10 loop if A(J) then null;end if;end loop;',
            b'if 1=0 then A(3):=False;end if;',
            b'if N>=0 and then N<=2 then if N=99 then A(N):=False;end if;end if;',
            b'if A((2147483647+1)) then null;end if;',
        ):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)

    def test_eager_and_stored_flags_do_not_supply_safety_facts(self) -> None:
        declarations = (b'N:Integer range 0..1:=0;'
                        b'A:array(0..1)of Boolean:=(N/=0,False);')
        for rhs, status in ((b'N/=0 and then (1/N)=1', 0),
                            (b'N=0 or else (1/N)=1', 0),
                            (b'N/=0 and (1/N)=1', 2),
                            (b'N=0 or (1/N)=1', 2),
                            (b'N/=0 xor (1/N)=1', 2)):
            with self.subTest(rhs=rhs):
                self.check(program(declarations, b'A(0):=' + rhs + b';'), status)
        for body in (
            b'if A(0) then if (1/N)=1 then null;end if;end if;',
            b'A(0):=N/=0;if (1/N)=1 then null;end if;',
            b'if N/=0 then A(0):=True;end if;if A(0) then N:=(1/N);end if;',
        ):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        self.check(program(b'N:Integer:=0;A:array(0..1)of Boolean:=(True,(1/N)=1);', b'null;'), 2)
        self.check(argument_program(
            b'A:array(0..1)of Boolean:=(Silver_Arguments.Input_Is_Valid,False);',
            b'if A(0) then null;else Silver_Arguments.Reject;end if;'), 2)

    def test_string_character_conditions_in_initializers_and_writes(self) -> None:
        declarations = (b"S:String:=\"ab\";C:Character:='a';I:Integer range 0..2:=1;"
                        b'A:array(0..1)of Boolean:=(S(1)=C,S(1..1)="a");')
        self.check(program(declarations, b"A(0):=S(2)='b';"
                           b'if I>=1 then A(1):=S(I)=C;end if;'))
        for condition in (b'S(0)=C', b'S(1..3)="abc"'):
            with self.subTest(condition=condition):
                self.check(program(b"S:String:=\"ab\";C:Character:='a';"
                                   b'A:array(0..1)of Boolean:=(' + condition + b',False);',
                                   b'null;'), 2)
                self.check(program(declarations, b'A(0):=' + condition + b';'), 2)
        self.check(program(declarations, b'A(0):=S(I)=C;'), 2)

    def test_index_operand_boundary_counts_the_array_read(self) -> None:
        def addition(count: int) -> bytes:
            expression = b'1'
            for _ in range(count - 1):
                expression = b'(' + expression + b'+1)'
            return expression
        for terms, status in ((63, 0), (64, 2)):
            declarations = b'A:array(63..64)of Boolean:=(True,False);'
            index = addition(terms)
            with self.subTest(terms=terms):
                self.check(program(declarations, b'if A(' + index + b') then null;end if;'), status)
                self.check(program(declarations, b'A(' + index + b'):=False;'), status)

    def test_native_snapshots_updates_and_loop_persistence(self) -> None:
        declarations = (b"Seed:Boolean:=True;S:String:=\"ab\";A:array(1..2)of Boolean:=(Seed and (S(1)='a'),not Seed);"
                        b'B:constant array(1..2)of Boolean:=(A(2),A(1));C:Boolean:=B(2);')
        body = (b"Seed:=False;S:=\"zz\";A(1):=S(2)='a';A(2):=A(1);"
                b'for I in 1..2 loop A(I):=not A(I);end loop;'
                b'if A(1) and A(2) and B(2) and not B(1) and C then '
                b'Silver_IO.Put_Line("snapshots");else Silver_IO.Put_Line("bad");end if;')
        executable, _ = self.compile(program(declarations, body), 'assigned')
        self.run_program(executable, b'snapshots\n')

    def test_native_integer_subtype_spelled_boolean(self) -> None:
        declarations = (b'subtype Boolean is Integer range 0..1;'
                        b'A:constant array(0..1)of Boolean:=(0,1);N:Integer range 0..1:=0;')
        body = b'for E of A loop N:=E;end loop;Silver_IO.Put_Line(Integer\'Image(N));'
        executable, _ = self.compile(program(declarations, body), 'assigned')
        self.run_program(executable, b' 1\n')
