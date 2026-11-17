"""Closed scalar procedures, explicit output initialization and copy-back."""
from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared
from tests import test_scalar_functions as scalar_functions

program = shared.program
RESET = b'procedure Reset(X:out Integer)is begin X:=0;end Reset;'
PAIR = (b'procedure Pair(N:in Integer;X:out Integer;Y:out Integer)is '
        b'begin X:=N;Y:=N;end Pair;')
FLAG = b'procedure Flip(B:in out Boolean)is begin B:=not B;end Flip;'


class ScalarProcedureTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check
    check_full_route = shared.SharedBindingsTests.check_full_route
    compile = shared.SharedBindingsTests.compile
    run_program = shared.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver scalar procedures-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'procedures.adb'

    def test_output_and_inout_calls_are_case_insensitive(self) -> None:
        self.check_full_route(program(RESET + FLAG + b'R:Integer:=7;B:Boolean:=False;',
                                     b'rESET(R);fLIP(B);'),
                              kind='assigned', procedures={'Reset': ('X',), 'Flip': ()})
        self.check_full_route(program(PAIR + b'A:Integer:=0;B:Integer:=0;', b'Pair(7,A,B);'),
                              kind='assigned', procedures={'Pair': ('X', 'Y')})

    def test_formal_modes_names_and_closing_name(self) -> None:
        for declaration in (
            b'procedure P is begin null;end P;',
            b'procedure P()is begin null;end P;',
            b'procedure P(X:Integer)is begin null;end P;',
            b'procedure P(X:in Integer)is begin null;end P;',
            b'procedure P(X:in out Integer)is begin end P;',
            b'procedure P(X,Y:out Integer)is begin X:=0;Y:=0;end P;',
            b'procedure P(X:out Integer;)is begin X:=0;end P;',
            b'procedure P(X:out Integer:=0)is begin X:=0;end P;',
            b'procedure P(X:out Integer range 0..9)is begin X:=0;end P;',
            b'procedure P(X:out Integer;x:out Integer)is begin X:=0;x:=0;end P;',
            b'procedure P(X:out Integer)is begin X:=0;end Q;',
            b'procedure P(X:out Integer);',
        ):
            with self.subTest(declaration=declaration):
                self.check(program(declaration, b'null;'), 2)
        self.check_full_route(program(b'procedure P(X:in out Integer)is begin null;end P;', b'null;'),
                              kind='static', procedures={'P': ()})

    def test_outputs_have_ordered_unconditional_initialization(self) -> None:
        prefix = b'procedure P(X:out Integer;Y:out Integer)is begin '
        for body in (
            b'null;', b'X:=0;', b'Y:=0;X:=0;', b'X:=0;X:=1;Y:=0;',
            b'null;X:=0;Y:=0;', b'X:=0;null;Y:=0;',
            b'if True then X:=0;Y:=0;end if;',
            b'for I in 1..1 loop X:=0;Y:=0;end loop;',
        ):
            with self.subTest(body=body):
                self.check(program(prefix + body + b'end P;', b'null;'), 2)
        self.check_full_route(program(prefix + b'X:=0;Y:=1;X:=Y;Y:=X;end P;', b'null;'),
                              kind='assigned', procedures={'P': ('X', 'Y')})

    def test_prefix_cannot_read_any_output_or_call_a_function(self) -> None:
        identity = b'function Id(N:in Integer)return Integer is begin return N;end Id;'
        prefix = identity + b'procedure P(X:out Integer;Y:out Integer)is begin '
        for body in (b'X:=X;Y:=0;', b'X:=Y;Y:=0;', b'X:=0;Y:=X;',
                     b'X:=Id(0);Y:=0;'):
            with self.subTest(body=body):
                self.check(program(prefix + body + b'end P;', b'null;'), 2)
        # An unavailable formal must still hide the identically named outer object.
        self.check(program(b'X:Integer:=7;' + RESET.replace(b'X:=0;', b'X:=X;'),
                           b'null;'), 2)

    def test_prefix_reads_locals_and_input_formals(self) -> None:
        declaration = (b'procedure P(N:in Integer;X:out Integer;Y:in out Integer)is '
                       b'K:Integer:=7;begin X:=N;Y:=K;X:=Y;end P;'
                       b'R:Integer:=0;S:Integer:=0;')
        self.check_full_route(program(declaration, b'P(3,R,S);'),
                              kind='assigned', procedures={'P': ('X',)})
        boolean = (b'procedure P(A:in Boolean;B:out Boolean;C:in out Boolean)is '
                   b'begin B:=A and then C;C:=not C;end P;'
                   b'B:Boolean:=False;C:Boolean:=True;')
        self.check_full_route(program(boolean, b'P(True,B,C);'),
                              kind='assigned', procedures={'P': ('B',)})

    def test_full_input_domain_checked_even_for_unused_procedures(self) -> None:
        unsafe = (b'procedure P(N:in Integer;X:out Integer)is '
                  b'begin X:=(N+1);end P;')
        self.check(program(unsafe, b'null;'), 2)
        self.check(program(unsafe + b'R:Integer:=0;', b'P(0,R);'), 2)
        safe = b'subtype Small is Integer range 0..9;' + unsafe.replace(b'N:in Integer', b'N:in Small')
        self.check_full_route(program(safe, b'null;'), kind='assigned', procedures={'P': ('X',)})
        divisor = (b'procedure P(D:in Integer;X:out Integer)is '
                   b'begin X:=0;if D>0 then X:=(10/D);end if;end P;')
        self.check_full_route(program(divisor, b'null;'), kind='assigned', procedures={'P': ('X',)})
        self.check(program(divisor.replace(b'if D>0 then ', b'').replace(b'end if;', b''),
                           b'null;'), 2)

    def test_prefix_guards_refine_input_formals_like_body_guards(self) -> None:
        subtype = b'subtype Den is Integer range 0..1;'
        declaration = (b'procedure P(N:in Den;B:out Boolean)is '
                       b'begin B:=N>0 and then (1/N)=1;end P;')
        self.check_full_route(program(subtype + declaration, b'null;'),
                              kind='assigned', procedures={'P': ('B',)})
        self.check_full_route(program(subtype + declaration.replace(b'begin B:=', b'begin B:=False;B:='),
                                     b'null;'), kind='assigned', procedures={'P': ('B',)})
        self.check_full_route(program(subtype + declaration.replace(b'N:in Den', b'N:in out Den'),
                                     b'null;'), kind='assigned', procedures={'P': ('B',)})
        self.check_full_route(program(subtype + declaration.replace(b'N>0 and then', b'N=0 or else'),
                                     b'null;'), kind='assigned', procedures={'P': ('B',)})
        self.check(program(subtype + declaration.replace(b'N>0 and then ', b''), b'null;'), 2)

    def test_ordinary_body_starts_with_full_declared_output_ranges(self) -> None:
        prefix = (b'subtype Small is Integer range 0..9;'
                  b'procedure P(X:out Small)is begin X:=1;')
        self.check(program(prefix + b'X:=(X+1);end P;', b'null;'), 2)
        self.check_full_route(program(prefix + b'if X<9 then X:=(X+1);end if;end P;', b'null;'),
                              kind='assigned', procedures={'P': ('X',)})
        self.check_full_route(program(prefix + b'X:=1;X:=(X+1);end P;', b'null;'),
                              kind='assigned', procedures={'P': ('X',)})

    def test_input_and_copyback_boundaries_use_declared_ranges(self) -> None:
        declaration = (b'subtype Small is Integer range 0..9;'
                       b'procedure P(N:in Small;X:out Small)is begin X:=N;end P;')
        for actual, expected in ((b'0', 0), (b'9', 0), (b'(-1)', 2), (b'10', 2)):
            with self.subTest(actual=actual):
                self.check_full_route(program(declaration + b'R:Small:=0;',
                                             b'P(' + actual + b',R);'), expected,
                                      kind='assigned', procedures={'P': ('X',)})
        self.check_full_route(program(declaration + b'R:Integer:=0;', b'P(0,R);'),
                              kind='assigned', procedures={'P': ('X',)})
        self.check(program(declaration + b'R:Integer range 0..8:=0;', b'P(0,R);'), 2)
        self.check(program(RESET + b'R:Integer range 0..9:=0;', b'Reset(R);'), 2)
        self.check(program(declaration.replace(b'X:=N;', b'X:=10;'), b'null;'), 2)

    def test_inout_requires_input_fit_and_copyback_fit(self) -> None:
        declaration = (b'subtype Small is Integer range 0..9;'
                       b'procedure P(X:in out Small)is begin X:=0;end P;')
        self.check_full_route(program(declaration + b'R:Small:=0;', b'P(R);'),
                              kind='assigned', procedures={'P': ()})
        self.check(program(declaration + b'R:Integer:=0;', b'P(R);'), 2)
        self.check_full_route(program(declaration + b'R:Integer:=0;', b'R:=0;P(R);'),
                              kind='assigned', procedures={'P': ()})
        self.check(program(declaration + b'R:Integer range 0..8:=0;', b'P(R);'), 2)

    def test_outputs_and_inout_invalidate_prior_refinements(self) -> None:
        declaration = (b'subtype Small is Integer range 0..9;'
                       b'procedure P(X:out Small)is begin X:=5;end P;'
                       b'R:Small:=0;Q:Integer:=0;')
        self.check(program(declaration, b'R:=1;P(R);Q:=(1/R);'), 2)
        self.check_full_route(program(declaration, b'P(R);if R>0 then Q:=(1/R);end if;'),
                              kind='assigned', procedures={'P': ('X',)})
        self.check(program(declaration.replace(b'X:out Small', b'X:in out Small'),
                           b'R:=1;P(R);Q:=(1/R);'), 2)

    def test_writable_actuals_are_bare_mutable_names(self) -> None:
        declarations = (RESET + b'R:Integer:=0;K:constant Integer:=0;'
                        b'B:Boolean:=False;A:array(1..1)of Integer:=(1=>0);')
        for actual in (b'0', b'K', b'(R)', b'(R+0)', b'A(1)', b'B'):
            with self.subTest(actual=actual):
                self.check(program(declarations, b'Reset(' + actual + b');'), 2)
        self.check(program(declarations, b'for I in 1..1 loop Reset(I);end loop;'), 2)
        self.check(program(declarations, b'for I in 2..1 loop Reset(I);end loop;'), 2)

    def test_arity_and_call_statement_positions(self) -> None:
        declarations = RESET + b'R:Integer:=0;'
        for body in (b'Reset();', b'Reset(R,R);', b'Reset(R,);', b'Reset(X=>R);',
                     b'Reset;', b'R:=Reset(R);', b'R:=(Reset(R)+1);'):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        self.check(program(PAIR + b'A:Integer:=0;B:Integer:=0;', b'Pair(0 A,B);'), 2)

    def test_duplicate_writes_and_read_write_aliases_are_rejected(self) -> None:
        declarations = PAIR + b'R:Integer:=0;S:Integer:=0;'
        for body in (b'Pair(0,R,R);', b'Pair(0,R,r);', b'Pair(R,R,S);',
                     b'Pair(S,R,S);'):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        self.check_full_route(program(declarations, b'Pair(0,R,S);'),
                              kind='assigned', procedures={'Pair': ('X', 'Y')})
        self.check(program(PAIR + b'R:Integer range 0..9:=0;S:Integer:=0;',
                           b'Pair((R+0),S,R);'), 2)
        boolean = (b'procedure P(A:in Boolean;B:out Boolean)is begin B:=A;end P;'
                   b'B:Boolean:=False;')
        self.check(program(boolean, b'P(not B,B);'), 2)
        sliced = (b'subtype One is Integer range 1..1;'
                  b'procedure P(B:in Boolean;X:out One)is begin X:=1;end P;'
                  b'S:constant String:="x";Input_Is_Valid:One:=1;Other:One:=1;')
        self.check(program(sliced, b'P(S(1..Input_Is_Valid)="x",Input_Is_Valid);'), 2)
        self.check_full_route(program(sliced, b'P(S(1..Input_Is_Valid)="x",Other);'),
                              kind='assigned', procedures={'P': ('X',)})

    def test_actuals_share_incoming_state(self) -> None:
        declarations = (b'procedure P(B:in Boolean;N:in Integer;X:out Integer)is '
                        b'begin X:=N;end P;D:Integer range 0..1:=0;R:Integer:=0;')
        self.check(program(declarations, b'P(D/=0,(1/D),R);'), 2)
        self.check_full_route(program(declarations, b'if D/=0 then P(True,(1/D),R);end if;'),
                              kind='assigned', procedures={'P': ('X',)})

    def test_qualified_validity_selector_is_not_a_writable_variable_read(self) -> None:
        queries = (
            b'Silver_Arguments.Input_Is_Valid',
            b'not (not Silver_Arguments.Input_Is_Valid) and then True',
            b'SiLvEr_ArGuMeNtS -- package\n . -- selector\n InPuT_Is_VaLiD',
        )
        for kind, initial, assignment, alias in (
            (b'Boolean', b'False', b'X:=B;', b'Input_Is_Valid'),
            (b'Integer', b'0', b'X:=0;if B then X:=1;end if;', b'Input_Is_Valid=0'),
        ):
            for mode in (b'out', b'in out'):
                for target_first in (False, True):
                    writable = b'X:' + mode + b' ' + kind
                    formals = (writable + b';B:in Boolean' if target_first
                               else b'B:in Boolean;' + writable)
                    declarations = (b'procedure Copy_Flag(' + formals + b')is begin '
                                    + assignment + b'end Copy_Flag;'
                                    b'Input_Is_Valid:' + kind + b':=' + initial + b';')
                    for query in (*queries, alias):
                        actuals = (b'Input_Is_Valid,' + query if target_first
                                   else query + b',Input_Is_Valid')
                        with self.subTest(kind=kind, mode=mode, target_first=target_first,
                                          query=query):
                            self.check_full_route(
                                program(declarations, b'Copy_Flag(' + actuals + b');', arguments=True),
                                2 if query == alias else 0, kind='selected',
                                procedures={'Copy_Flag': ('X',) if mode == b'out' else ()},
                                runs=scalar_functions.ARGUMENT_SILENT_RUNS)

    def test_literal_letters_are_not_actual_variable_reads(self) -> None:
        procedure = b'procedure P(N:in Integer;X:out Integer)is begin X:=N;end P;'
        for literal, target in ((b'16#F#', b'F'), (b'16#Ff#', b'Ff'),
                                (b'16#F_FFF#', b'F_FFF'), (b'1E3', b'E3'),
                                (b'1E+3', b'E'), (b'1E4', b'E4'),
                                (b'(-16#F#)', b'F')):
            declarations = procedure + target + b':Integer:=0;'
            with self.subTest(literal=literal, target=target):
                self.check_full_route(program(declarations, b'P(' + literal + b',' + target + b');'),
                                      kind='assigned', procedures={'P': ('X',)})
                self.check(program(declarations, b'P(' + target + b',' + target + b');'), 2)
        boolean = (b'procedure P(A:in Boolean;X:out Boolean)is begin X:=A;end P;'
                   b'F:Boolean:=False;S:String:="F";C:Character:=\'F\';')
        for condition in (b'16#F#=15', b'S="F"', b"C='F'"):
            with self.subTest(condition=condition):
                self.check_full_route(program(boolean, b'P(' + condition + b',F);'),
                                      kind='assigned', procedures={'P': ('X',)})

    def test_boolean_output_does_not_export_predicate_facts(self) -> None:
        declarations = (b'procedure Nonzero(D:in Integer;B:out Boolean)is '
                        b'begin B:=D/=0;end Nonzero;'
                        b'D:Integer range 0..1:=0;B:Boolean:=False;R:Integer:=0;')
        self.check(program(declarations,
                           b'Nonzero(D,B);if B then R:=(1/D);end if;'), 2)

    def test_calls_preserve_unrelated_scalar_and_input_facts(self) -> None:
        declarations = RESET + b'D:Integer range 0..1:=0;R:Integer:=0;Q:Integer:=0;'
        self.check_full_route(program(declarations,
                                     b'if D>0 then Reset(R);Q:=(1/D);end if;'),
                              kind='assigned', procedures={'Reset': ('X',)})
        self.check_full_route(program(RESET + b'R:Integer:=0;',
                                     b'Reset(R);Silver_IO.Put_Line(Input);', arguments=True),
                              kind='selected', procedures={'Reset': ('X',)},
                              runs=scalar_functions.ARGUMENT_ECHO_RUNS)

    def test_earlier_procedure_and_function_calls_and_recursion(self) -> None:
        identity = b'function Id(N:in Integer)return Integer is begin return N;end Id;'
        wrapper = (b'procedure Wrapper(N:in Integer;X:out Integer)is '
                   b'begin X:=0;Reset(X);X:=Id(N);end Wrapper;')
        self.check_full_route(program(identity + RESET + wrapper + b'R:Integer:=0;', b'Wrapper(7,R);'),
                              kind='assigned', functions=('Id',),
                              procedures={'Reset': ('X',), 'Wrapper': ('X',)})
        self.check(program(identity + wrapper + RESET, b'null;'), 2)
        recursive = b'procedure P(X:out Integer)is begin X:=0;P(X);end P;'
        self.check(program(recursive, b'null;'), 2)
        function = (b'function F(N:in Integer)return Integer is R:Integer:=0;'
                    b'begin Reset(R);return R;end F;')
        self.check(program(RESET + function, b'null;'), 2)

    def test_procedure_frames_are_closed_and_inputs_immutable(self) -> None:
        prefix = b'Outer:Integer:=0;procedure P(N:in Integer;X:out Integer)is '
        for locals_, body in (
            (b'', b'X:=Outer;'), (b'', b'X:=0;Outer:=N;'), (b'', b'X:=0;N:=1;'),
            (b'K:Integer:=N;', b'X:=K;'), (b'K:Integer:=Outer;', b'X:=K;'),
            (b'S:String:="x";', b'X:=0;'), (b'B:array(1..1)of Boolean:=(1=>True);', b'X:=0;'),
            (b'', b'X:=0;Silver_IO.Put_Line("bad");'),
            (b'', b'X:=0;return;'), (b'', b'X:=0;return X;'),
        ):
            with self.subTest(locals=locals_, body=body):
                self.check(program(prefix + locals_ + b'begin ' + body + b'end P;', b'null;'), 2)

    def test_hiding_duplicate_names_and_immutable_formal_targets(self) -> None:
        self.check(program(RESET + RESET, b'null;'), 2)
        self.check(program(b'Reset:Integer:=0;' + RESET, b'null;'), 2)
        self.check(program(RESET + b'Reset:Integer:=0;', b'null;'), 2)
        self.check(program(RESET + b'R:Integer:=0;',
                           b'for Reset in 1..1 loop Reset(R);end loop;'), 2)
        wrapper = (b'procedure P(N:in Integer;X:out Integer)is '
                   b'begin X:=0;Reset(N);end P;')
        self.check(program(RESET + wrapper, b'null;'), 2)
        local_hiding = (b'X:String:="outer";procedure P(X:out Integer)is '
                        b'begin X:=7;end P;R:Integer:=0;')
        self.check_full_route(program(local_hiding, b'P(R);'),
                              kind='assigned', procedures={'P': ('X',)})
        named_boolean = RESET.replace(b'Reset', b'Boolean')
        self.check_full_route(program(named_boolean, b'null;'),
                              kind='assigned', procedures={'Boolean': ('X',)})
        self.check(program(named_boolean + b'B:Boolean:=False;', b'null;'), 2)
        self.check(program(named_boolean
                           + b'procedure Later(X:out Integer)is B:Boolean:=False;'
                           b'begin X:=0;end Later;', b'null;'), 2)

    def test_source_wide_operator_and_source_size_boundaries(self) -> None:
        declaration = (b'subtype Small is Integer range 0..9;'
                       b'procedure P(N:in Small;X:out Integer)is begin X:=(N+1);end P;'
                       b'R:Integer range 0..1:=0;')
        for count, expected in ((63, 0), (64, 2)):
            with self.subTest(count=count):
                self.check_full_route(program(declaration, b'R:=(R+0);' * (count - 1)), expected,
                                      kind='assigned', procedures={'P': ('X',)})
        source = program(RESET, b'null;')
        source += b' ' * (4096 - len(source))
        self.check_full_route(source, kind='assigned', procedures={'Reset': ('X',)})
        self.check(source + b' ', 2)

    def test_native_multiple_outputs_inout_and_unused_full_domain(self) -> None:
        declarations = (
            b'subtype Small is Integer range 0..9;'
            b'function Id(N:in Integer)return Integer is begin return N;end Id;'
            b'procedure Sum_And_Diff(L:in Small;R:in Small;Sum:out Integer;Diff:out Integer)is '
            b'begin Sum:=(L+R);Diff:=(L-R);end Sum_And_Diff;'
            b'procedure Advance(N:in out Small)is begin if N<9 then N:=(N+1);end if;end Advance;'
            b'procedure Unused(D:in Integer;Q:out Integer)is '
            b'begin Q:=0;if D>0 then Q:=(10/D);end if;end Unused;'
            + FLAG +
            b'procedure Wrapper(N:in Small;R:out Integer;B:out Boolean)is '
            b'T:Integer:=0;begin R:=0;B:=False;Sum_And_Diff(N,1,R,T);'
            b'R:=Id(R);Flip(B);end Wrapper;'
            b'A:Integer:=0;B:Integer:=0;R:Integer:=0;N:Small:=7;Flag:Boolean:=False;')
        body = (b'Sum_And_Diff(9,1,A,B);'
                b"Silver_IO.Put_Line(Integer'Image(A));Silver_IO.Put_Line(Integer'Image(B));"
                b'for I in 1..2 loop Advance(N);end loop;Wrapper(N,R,Flag);'
                b"if Flag then Silver_IO.Put_Line(Integer'Image(R));end if;")
        procedures = {'Sum_And_Diff': ('Sum', 'Diff'), 'Advance': (),
                      'Unused': ('Q',), 'Flip': (), 'Wrapper': ('R', 'B')}
        executable, report = self.compile(program(declarations, body), 'assigned',
                                          functions=('Id',), procedures=procedures)
        self.run_program(executable, b' 10\n 8\n 10\n')
        identities = {entry['name']: int(key) for key, entry in report['entities'].items()}
        for name, outputs in procedures.items():
            identity = identities['Main.' + name]
            self.assertEqual(report['spark'][next(key for key in report['spark']
                                                 if int(key) == identity)], 'all')
            for output in outputs:
                self.assertTrue(any(item.get('entity') == identity
                                    and item.get('rule') == 'UNINITIALIZED'
                                    and item.get('severity') == 'info'
                                    and item.get('message', {}).get('text') == f'initialization of "{output}" proved'
                                    for item in report['flow']), (name, output, report['flow']))
        self.assertTrue(any(item.get('entity') == identities['Main.Unused']
                            and item.get('rule') == 'VC_DIVISION_CHECK'
                            for item in report['proof']))
        self.assertTrue(any(item.get('entity') == identities['Main.Id']
                            and item.get('rule') == 'SUBPROGRAM_TERMINATION'
                            for item in report['flow']))

    def test_native_calls_compose_with_arrays_and_argument_facts(self) -> None:
        declarations = (
            b'subtype Small is Integer range 0..9;'
            b'procedure Select_Value(A:in Boolean;N:in Small;X:out Small;B:out Boolean)is '
            b'begin X:=N;B:=A;end Select_Value;'
            b'Values:constant array(1..2)of Small:=(2,3);'
            b'Flags:array(1..2)of Boolean:=(True,False);'
            b'Saved:constant String:=Input;'
            b'D:Integer range 0..1:=0;R:Small:=0;Input_Is_Valid:Boolean:=False;Q:Integer:=0;')
        body = (
            b'D:=1;for E of Values loop '
            b"Select_Value(Silver_Arguments.Input_Is_Valid and then Input'Length=3 "
            b'and then Flags(1),E,R,Input_Is_Valid);end loop;'
            b'if D>0 then Q:=(1/D);end if;'
            b'if Input_Is_Valid then Silver_IO.Put_Line(Saved);else Silver_IO.Put_Line("none");end if;'
            b"Silver_IO.Put_Line(Integer'Image(R));Silver_IO.Put_Line(Integer'Image(Q));"
            b"Silver_IO.Put_Line(Integer'Image(Values(1)));"
            b'if Flags(1) then Silver_IO.Put_Line("kept");end if;')
        executable, _ = self.compile(program(declarations, body, arguments=True), 'selected',
                                     procedures={'Select_Value': ('X', 'B')})
        self.run_program(executable, b'abc\n 3\n 1\n 2\nkept\n', arguments=(b'abc',))
        self.run_program(executable, b'none\n 3\n 1\n 2\nkept\n', arguments=(b'',))

