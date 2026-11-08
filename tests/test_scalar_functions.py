"""Closed scalar functions, full formal domains and assignment-only calls."""
from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared

program = shared.program
IDENTITY = b'function Id(X:in Integer)return Integer is begin return X;end Id;'
BOOLEAN = b'function Flip(B:in Boolean)return Boolean is begin return not B;end Flip;'


class ScalarFunctionTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check
    compile = shared.SharedBindingsTests.compile
    run_program = shared.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver scalar functions-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'functions.adb'

    def test_typed_terminal_returns_and_assignment_calls(self) -> None:
        cases = (
            (IDENTITY + b'R:Integer:=0;', b'R:=id(7);R:=Id(R);'),
            (BOOLEAN + b'R:Boolean:=False;', b'R:=fLIP(True);R:=Flip(R);'),
            (b'subtype Small is Integer range -2..2;'
             b'function Id(X:in Small)return Small is begin return X;end Id;'
             b'R:Small:=0;', b'R:=Id((-2));R:=Id(2);'),
            (b'function Select_Value(X:in Integer;B:in Boolean)return Integer is '
             b'R:Integer:=0;begin if B then R:=X;end if;return R;end Select_Value;'
             b'R:Integer:=0;', b'R:=Select_Value(7,1<2);'),
        )
        for declarations, body in cases:
            with self.subTest(declarations=declarations):
                self.check(program(declarations, body))

    def test_formal_syntax_and_closing_names(self) -> None:
        for declaration in (
            b'function F return Integer is begin return 0;end F;',
            b'function F()return Integer is begin return 0;end F;',
            b'function F(X:Integer)return Integer is begin return X;end F;',
            b'function F(X,Y:in Integer)return Integer is begin return X;end F;',
            b'function F(X:out Integer)return Integer is begin return X;end F;',
            b'function F(X:in out Integer)return Integer is begin return X;end F;',
            b'function F(X:in Integer:=0)return Integer is begin return X;end F;',
            b'function F(X:in Integer range 0..1)return Integer is begin return X;end F;',
            b'function F(X:in Integer)return Integer range 0..1 is begin return 0;end F;',
            b'function F(X:in Integer)return Integer is begin return X;end Other;',
            b'function F(X:in Integer;x:in Integer)return Integer is begin return X;end F;',
            b'function F(X:in Integer)return Integer;',
            b'function F(X:in Integer)return Integer is(X);',
        ):
            with self.subTest(declaration=declaration):
                self.check(program(declaration, b'null;'), 2)

    def test_return_must_be_single_terminal_and_typed(self) -> None:
        for body in (
            b'null;', b'if X=0 then return 0;else return X;end if;',
            b'return X;null;', b'return X;return X;',
            b'for I in 1..2 loop return X;end loop;return X;',
            b'return True;', b'return "x";',
        ):
            with self.subTest(body=body):
                declaration = b'function F(X:in Integer)return Integer is begin ' + body + b'end F;'
                self.check(program(declaration, b'null;'), 2)

    def test_actual_arity_kinds_and_positional_association(self) -> None:
        declarations = IDENTITY + BOOLEAN + b'R:Integer:=0;B:Boolean:=False;'
        for body in (
            b'R:=Id();', b'R:=Id(1,2);', b'R:=Id(X=>1);',
            b'R:=Id(True);', b'B:=Flip(1);', b'R:=Flip(True);',
            b'B:=Id(1);', b'R:=Id;', b'Id(1);',
        ):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)

    def test_calls_are_whole_scalar_assignment_rhs_only(self) -> None:
        declarations = IDENTITY + BOOLEAN + (
            b'R:Integer:=0;B:Boolean:=False;A:array(1..1)of Integer:=(1=>0);')
        for body in (
            b'R:=(Id(1));', b'R:=(Id(1)+1);', b'R:=Id(Id(1));',
            b'if Flip(True) then null;end if;',
            b'if Id(1)=1 then null;end if;', b'B:=not Flip(True);',
            b"Silver_IO.Put_Line(Integer'Image(Id(1)));",
            b'A(1):=Id(1);', b'for I in 1..Id(2) loop null;end loop;',
        ):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        for initializer in (b'R:Integer:=Id(1);', b'B:Boolean:=Flip(True);'):
            self.check(program(IDENTITY + BOOLEAN + initializer, b'null;'), 2)
        self.check(program(IDENTITY + b'function F(X:in Integer)return Integer is '
                           b'begin return Id(X);end F;', b'null;'), 2)

    def test_full_formal_domain_is_checked_even_if_unused(self) -> None:
        unsafe = b'function F(X:in Integer)return Integer is begin return (X+1);end F;'
        self.check(program(unsafe, b'null;'), 2)
        self.check(program(unsafe + b'R:Integer:=0;', b'R:=F(0);'), 2)
        bounded = (b'subtype Small is Integer range 0..9;'
                   b'function F(X:in Small)return Integer is begin return (X+1);end F;')
        self.check(program(bounded, b'null;'))
        self.check(program(IDENTITY.replace(b'return X;', b'return (1/X);'), b'null;'), 2)

    def test_actual_and_result_ranges_use_declared_subtypes(self) -> None:
        declaration = (b'subtype Small is Integer range 0..9;'
                       b'function F(X:in Small)return Small is begin return 0;end F;')
        for actual, status in ((b'0', 0), (b'9', 0), (b'(-1)', 2), (b'10', 2)):
            with self.subTest(actual=actual):
                self.check(program(declaration + b'R:Small:=0;', b'R:=F(' + actual + b');'), status)
        self.check(program(declaration + b'R:Integer range 0..8:=0;', b'R:=F(0);'), 2)
        self.check(program(IDENTITY + b'R:Integer range 0..9:=0;', b'R:=Id(0);'), 2)
        self.check(program(declaration.replace(b'return 0;', b'return 10;'), b'null;'), 2)
        self.check(program(declaration + b'R:Small:=0;N:Integer:=0;',
                           b'if N>=0 and then N<=9 then R:=F(N);end if;'))
        self.check(program(declaration + b'R:Small:=0;N:Integer:=0;',
                           b'R:=1;R:=F(R);N:=(1/R);'), 2)

    def test_nonempty_actuals_and_returns_even_in_empty_loops(self) -> None:
        self.check(program(IDENTITY + b'R:Integer:=0;',
                           b'for I in 2..1 loop R:=Id(I);end loop;'), 2)
        declaration = (b'subtype Small is Integer range 0..9;'
                       b'function F(X:in Small)return Small is begin return X;end F;'
                       b'R:Small:=0;')
        self.check(program(declaration, b'if 1=0 then R:=F(10);end if;'), 2)

    def test_actuals_share_incoming_state_without_cross_argument_refinement(self) -> None:
        declarations = (b'function F(B:in Boolean;X:in Integer)return Integer is '
                        b'begin return X;end F;N:Integer range 0..1:=0;R:Integer:=0;')
        self.check(program(declarations, b'R:=F(N/=0,(1/N));'), 2)
        self.check(program(declarations, b'if N/=0 then R:=F(True,(1/N));end if;'))

    def test_boolean_result_carries_no_argument_or_input_facts(self) -> None:
        declarations = (b'function Nonzero(X:in Integer)return Boolean is '
                        b'begin return X/=0;end Nonzero;'
                        b'N:Integer range 0..1:=0;R:Integer:=0;B:Boolean:=False;')
        self.check(program(declarations, b'B:=Nonzero(N);if B then R:=(1/N);end if;'), 2)
        self.check(program(BOOLEAN + b'B:Boolean:=False;',
                           b'B:=Flip(not Silver_Arguments.Input_Is_Valid);'
                           b'if B then Silver_IO.Put_Line("ok");else '
                           b'Silver_Arguments.Reject;end if;', arguments=True))
        # The helper's outer real guard above permits it; a stored call result
        # alone must not discharge the shell's input requirement.
        source = (b'with Silver_IO;with Silver_Arguments;procedure Main is pragma SPARK_Mode(On);'
                  b'Input:constant String:=Silver_Arguments.First_Or_Default("");' + BOOLEAN +
                  b'B:Boolean:=False;begin B:=Flip(not Silver_Arguments.Input_Is_Valid);'
                  b'if B then Silver_IO.Put_Line("ok");else Silver_Arguments.Reject;end if;end Main;')
        self.check(source, 2)

    def test_boolean_actuals_use_caller_string_and_character_facts(self) -> None:
        declarations = (BOOLEAN + b'R:Boolean:=False;S:String:="ab";'
                        b"C:Character:='a';")
        self.check(program(declarations,
                           b'R:=Flip(S="ab");R:=Flip(C=S(1));'
                           b"R:=Flip(S'Length=2 and then S(2)='b');"))
        self.check(program(BOOLEAN + b'R:Boolean:=False;',
                           b'R:=Flip(Input="old");', arguments=True))
        # Each actual still needs its own established String index bounds.
        self.check(program(declarations, b"R:=Flip(S(3)='b');"), 2)

    def test_function_names_hide_predefined_names_in_later_closed_frames(self) -> None:
        named_true = IDENTITY.replace(b'Id', b'True')
        named_boolean = IDENTITY.replace(b'Id', b'Boolean')
        result = b'function F(X:in Integer)return Boolean is begin return '
        self.check(program(named_true + result + b'False;end F;', b'null;'))
        self.check(program(named_true + result + b'True;end F;', b'null;'), 2)
        self.check(program(named_boolean + BOOLEAN, b'null;'), 2)

    def test_earlier_calls_and_recursion_rejection(self) -> None:
        wrapper = (b'function Twice(X:in Integer)return Integer is R:Integer:=0;'
                   b'begin R:=Id(X);R:=Id(R);return R;end Twice;')
        self.check(program(IDENTITY + wrapper + b'R:Integer:=0;', b'R:=Twice(7);'))
        self.check(program(wrapper + IDENTITY, b'null;'), 2)
        self_call = (b'function F(X:in Integer)return Integer is R:Integer:=0;'
                     b'begin R:=F(X);return R;end F;')
        self.check(program(self_call, b'null;'), 2)
        mutual = self_call.replace(b'R:=F(X)', b'R:=G(X)') + self_call.replace(b'function F', b'function G').replace(b'end F', b'end G')
        self.check(program(mutual, b'null;'), 2)

    def test_local_initializers_are_independent_exact_snapshots(self) -> None:
        body = (b'function F(X:in Integer)return Integer is A:Integer:=7;'
                b'K:constant Integer:=A;begin A:=X;return K;end F;')
        self.check(program(body, b'null;'))
        for locals_ in (b'A:Integer:=X;', b'B:Boolean:=X=0;', b'A:Integer:=Outer;',
                        b'A:Integer:=Id(0);', b'X:Integer:=0;',
                        b'subtype S is Integer range 0..9;A:S:=0;'):
            with self.subTest(locals=locals_):
                self.check(program(b'Outer:Integer:=0;' + IDENTITY +
                                   b'function F(X:in Integer)return Integer is ' + locals_ +
                                   b'begin return X;end F;', b'null;'), 2)

    def test_functions_cannot_capture_or_perform_effects(self) -> None:
        prefix = b'Outer:Integer:=0;function F(X:in Integer)return Integer is '
        for locals_, body in (
            (b'', b'return Outer;'), (b'', b'Outer:=X;return X;'),
            (b'', b'Silver_IO.Put_Line("bad");return X;'),
            (b'', b'if "a"="a" then null;end if;return X;'),
            (b'S:String:="x";', b'return X;'),
            (b"C:Character:='a';", b'return X;'),
            (b'A:array(1..1)of Integer:=(1=>0);', b'return X;'),
            (b'A:array(1..1)of Boolean:=(1=>True);', b'return X;'),
            (IDENTITY, b'return X;'),
        ):
            with self.subTest(locals=locals_, body=body):
                self.check(program(prefix + locals_ + b'begin ' + body + b'end F;', b'null;'), 2)
        for body in (b'Silver_Arguments.Reject;return X;',
                     b'if Silver_Arguments.Input_Is_Valid then null;end if;return X;'):
            self.check(program(prefix + b'begin ' + body + b'end F;', b'null;', arguments=True), 2)

    def test_formals_are_immutable_and_guard_refinable(self) -> None:
        self.check(program(IDENTITY.replace(b'return X;', b'X:=0;return X;'), b'null;'), 2)
        declaration = (b'function F(X:in Integer)return Integer is R:Integer:=0;begin '
                       b'if X>0 then for I in 1..2 loop R:=(1/X);end loop;end if;'
                       b'return R;end F;')
        self.check(program(declaration, b'null;'))
        self.check(program(declaration.replace(b'X>0', b'X/=0'), b'null;'), 2)

    def test_hiding_and_duplicate_names(self) -> None:
        self.check(program(IDENTITY + IDENTITY, b'null;'), 2)
        self.check(program(IDENTITY + b'Id:Integer:=0;', b'null;'), 2)
        self.check(program(b'Id:Integer:=0;' + IDENTITY, b'null;'), 2)
        self.check(program(IDENTITY + b'R:Integer:=0;',
                           b'for Id in 1..2 loop R:=Id(0);end loop;'), 2)
        wrapper = (b'function F(Id:in Integer)return Integer is R:Integer:=0;'
                   b'begin R:=Id(0);return R;end F;')
        self.check(program(IDENTITY + wrapper, b'null;'), 2)
        self.check(program(b'Integer:String:="x";' + IDENTITY, b'null;'), 2)
        self.check(program(b'Boolean:Integer:=0;' + BOOLEAN, b'null;'), 2)

    def test_existing_array_actuals_and_nested_loops(self) -> None:
        declarations = (IDENTITY + BOOLEAN + b'R:Integer:=0;B:Boolean:=False;'
                        b'A:array(1..2)of Integer:=(4,5);Flags:array(1..2)of Boolean:=(True,False);')
        self.check(program(declarations, b'for I in 1..2 loop for J in 1..2 loop '
                           b'R:=Id(A(I));B:=Flip(Flags(J));end loop;end loop;'))

    def test_source_wide_operator_budget_spans_functions(self) -> None:
        for count, status in ((63, 0), (64, 2)):
            functions = b'subtype Small is Integer range 0..9;' + b''.join(
                b'function F' + str(i).encode() + b'(X:in Small)return Integer is '
                b'begin return (X+1);end F' + str(i).encode() + b';'
                for i in range(2))
            # Two operators in the functions plus the rest in Main. Separate
            # assignments keep each expression below its operand budget.
            body = b'R:=(R+0);' * (count - 2)
            with self.subTest(count=count):
                self.check(program(functions + b'R:Integer range 0..1:=0;', body), status)

    def test_dense_formals_and_complete_source_bound(self) -> None:
        formals = b';'.join(b'P' + str(i).encode() + b':in Integer' for i in range(150))
        declaration = b'function F(' + formals + b')return Integer is begin return P149;end F;'
        source = program(declaration, b'null;')
        self.assertLess(len(source), 4096)
        padded = source + b' ' * (4096 - len(source))
        self.check(padded)
        self.check(padded + b' ', 2)

    def test_dense_locals_and_function_list(self) -> None:
        locals_ = b''.join(b'L' + str(i).encode() + b':T:=0;' for i in range(250))
        declaration = (b'subtype T is Integer range 0..9;'
                       b'function F(X:in Integer)return Integer is ' + locals_ +
                       b'begin return X;end F;')
        self.assertLess(len(program(declaration, b'null;')), 4096)
        self.check(program(declaration, b'null;'))
        functions = b''
        count = 0
        while True:
            name = b'F' + str(count).encode()
            candidate = functions + (b'function ' + name + b'(X:in Integer)return Integer is '
                                     b'begin return X;end ' + name + b';')
            if len(program(candidate, b'null;')) > 4096:
                break
            functions = candidate
            count += 1
        self.assertGreater(count, 30)
        self.check(program(functions, b'null;'))

    def test_native_ordered_calls_snapshot_and_full_unused_coverage(self) -> None:
        declarations = (b'subtype Small is Integer range 0..9;'
                        b'function Next_Value(X:in Small)return Integer is begin return (X+1);end Next_Value;'
                        b'function Wrapper(X:in Small;B:in Boolean)return Integer is R:Integer:=0;'
                        b'begin if B then R:=Next_Value(X);end if;return R;end Wrapper;'
                        b'function Unused(X:in Integer)return Integer is R:Integer:=0;'
                        b'begin if X>0 then R:=(10/X);end if;return R;end Unused;'
                        b'function Zero(X:in Integer;B:in Boolean)return Integer is Spare:Integer:=7;'
                        b'C:constant Integer:=Spare;'
                        b'begin return 0;end Zero;'
                        b'R:Integer:=0;')
        executable, report = self.compile(program(declarations,
            b'R:=wRAPPER(9,True);Silver_IO.Put_Line(Integer\'Image(R));'),
            'assigned', functions=('Next_Value', 'Wrapper', 'Unused', 'Zero'))
        self.run_program(executable, b' 10\n')
        self.assertTrue(any(item.get('rule') == 'SUBPROGRAM_TERMINATION'
                            for item in report['flow']))
        self.assertTrue(any(item.get('rule') == 'VC_DIVISION_CHECK'
                            for item in report['proof']))

    def test_native_boolean_and_integer_self_actuals(self) -> None:
        executable, _ = self.compile(program(IDENTITY + BOOLEAN + b'R:Integer:=7;B:Boolean:=False;',
            b'R:=Id(R);B:=Flip(B);if B then Silver_IO.Put_Line(Integer\'Image(R));end if;'),
            'assigned', functions=('Id', 'Flip'))
        self.run_program(executable, b' 7\n')
