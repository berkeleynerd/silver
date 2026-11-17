"""Named scalar actuals preserve formal binding, incoming state and copy-back."""
from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared

program = shared.program
output = shared.output
SUBTRACT = (
    b'subtype Small is Integer range -100..100;'
    b'subtype Difference is Integer range -200..200;'
    b'function Subtract(Left:in Small;Right:in Small)return Difference is '
    b'begin return (Left-Right);end Subtract;')
RESET = b'procedure Reset(X:out Integer)is begin X:=0;end Reset;'


class NamedScalarArgumentTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check
    check_full_route = shared.SharedBindingsTests.check_full_route
    compile = shared.SharedBindingsTests.compile
    run_program = shared.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver named scalar arguments-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'named.adb'

    def test_function_positional_named_reordered_mixed_and_case(self) -> None:
        calls = (
            b'5,3', b'Left=>5,Right=>3', b'Right=>3,Left=>5',
            b'5,Right=>3', b'rIgHt=>3,lEfT=>5',
            b'Right -- selector\n => (2+1),Left=>5',
            b'Right=>5,Left=>3',
        )
        body = b''.join(b'R:=Subtract(' + actuals + b');'
                        + output(b"Integer'Image(R)") for actuals in calls)
        self.check_full_route(program(SUBTRACT + b'R:Difference:=0;', body),
                              kind='assigned', functions=('Subtract',),
                              runs=(((), b' 2\n' * 6 + b'-2\n', 0),))

    def test_mixed_integer_boolean_signature(self) -> None:
        declaration = (
            b'function Pick(Number:in Integer;Flag:in Boolean;Other:in Integer)'
            b'return Integer is R:Integer:=0;begin '
            b'if Flag then R:=Number;else R:=Other;end if;return R;end Pick;'
            b'R:Integer:=0;Number:Boolean:=False;Flag:Integer:=0;')
        calls = (b'Other=>9,Flag=>True,Number=>7',
                 b'7,Other=>9,Flag=>False', b'7,False,Other=>9')
        body = b''.join(b'R:=Pick(' + args + b');' + output(b"Integer'Image(R)")
                        for args in calls)
        self.check_full_route(program(declaration, body), kind='assigned',
                              functions=('Pick',), runs=(((), b' 7\n 9\n 9\n', 0),))

    def test_boolean_results_inout_and_nested_procedure_calls(self) -> None:
        declaration = (
            b'function Both(First:in Boolean;Second:in Boolean)return Boolean is '
            b'begin return First and Second;end Both;'
            b'procedure Flip(Enabled:in Boolean;Flag:in out Boolean)is begin '
            b'if Enabled then Flag:=not Flag;else null;end if;end Flip;'
            b'procedure Wrap(Enabled:in Boolean;Flag:in out Boolean)is begin '
            b'Flip(Flag=>Flag,Enabled=>Enabled);end Wrap;'
            b'B:Boolean:=False;R:Boolean:=False;')
        observation = (b'if B then ' + output(b'"true"')
                       + b'else ' + output(b'"false"') + b'end if;')
        body = (b'R:=Both(Second=>True,First=>True);Wrap(Flag=>B,Enabled=>R);'
                + observation
                + b'R:=Both(True,Second=>False);Wrap(R,Flag=>B);' + observation
                + b'Wrap(Flag=>B,Enabled=>True);' + observation)
        self.check_full_route(program(declaration, body), kind='assigned',
                              functions=('Both',), procedures={'Flip': (), 'Wrap': ()},
                              runs=(((), b'true\ntrue\nfalse\n', 0),))

    def test_procedure_modes_retain_selected_formal_and_copyback(self) -> None:
        declaration = (
            b'subtype Digit is Integer range 0..9;'
            b'subtype Pair is Integer range 0..99;'
            b'procedure Transform(Left:in Digit;Flag:in Boolean;Right:in out Digit;'
            b'Value:out Pair;Copy:out Boolean)is begin '
            b'Value:=((Left*10)+Right);Copy:=Flag;Right:=Left;end Transform;'
            b'D:Digit:=7;R:Pair:=0;B:Boolean:=False;')
        calls = (
            b'2,True,D,R,B',
            b'Copy=>B,Value=>R,Right=>D,Flag=>True,Left=>2',
            b'2,Copy=>B,Value=>R,Right=>D,Flag=>True',
        )
        observation = (output(b"Integer'Image(R)") + output(b"Integer'Image(D)")
                       + b'if B then ' + output(b'"true"')
                       + b'else ' + output(b'"false"') + b'end if;')
        body = b''.join(b'D:=7;Transform(' + args + b');' + observation for args in calls)
        self.check_full_route(program(declaration, body), kind='assigned',
                              procedures={'Transform': ('Value', 'Copy')},
                              runs=(((), b' 27\n 2\ntrue\n' * 3, 0),))

    def test_selector_names_are_not_caller_reads(self) -> None:
        self.check_full_route(
            program(RESET + b'X:Integer:=9;', b'Reset(x=>X);' + output(b"Integer'Image(X)")),
            kind='assigned', procedures={'Reset': ('X',)}, runs=(((), b' 0\n', 0),))
        declaration = (RESET + b'procedure Copy(N:in Integer;X:out Integer)is '
                       b'begin X:=N;end Copy;N:Integer:=0;V:Integer:=7;')
        self.check_full_route(program(declaration, b'Copy(X=>N,N=>V);'
                                     + output(b"Integer'Image(N)")),
                              kind='assigned', procedures={'Reset': ('X',), 'Copy': ('X',)},
                              runs=(((), b' 7\n', 0),))
        # The same spelling in an actual's payload is a genuine alias.
        for args in (b'X=>N,N=>N', b'N=>N,X=>N'):
            self.check(program(declaration, b'Copy(' + args + b');'), 2)

    def test_duplicate_missing_unknown_and_invalid_mixed_associations(self) -> None:
        declaration = SUBTRACT + b'R:Difference:=0;Unknown:Small:=1;'
        invalid = (
            b'Left=>5', b'Left=>5,Left=>3', b'Left=>5,lEfT=>3',
            b'5,Left=>3', b'Unknown=>5,Right=>3',
            b'Left=>5,3', b'Right=>3,5', b'Left=>5,Right=>3,Right=>2',
            b'Left= >5,Right=>3', b'Left=-- split arrow\n>5,Right=>3',
            b'Left=>,Right=>3', b'Left=>5,Right=>3,',
            b'Left=>5,,Right=>3', b'Left=>5,Right=>',
        )
        for args in invalid:
            with self.subTest(actuals=args):
                self.check(program(declaration, b'R:=Subtract(' + args + b');'), 2)
        pair = (b'procedure Pair(X:out Integer;Y:out Integer)is '
                b'begin X:=1;Y:=2;end Pair;A:Integer:=0;B:Integer:=0;')
        for args in (b'X=>A', b'X=>A,x=>B', b'A,X=>B', b'X=>A,B',
                     b'Z=>A,Y=>B', b'Y=>B,', b'X= >A,Y=>B'):
            with self.subTest(procedure_actuals=args):
                self.check(program(pair, b'Pair(' + args + b');'), 2)

    def test_types_and_ranges_follow_named_formal(self) -> None:
        declaration = SUBTRACT + b'R:Difference:=0;'
        for args in (b'Right=>True,Left=>5', b'Left=>101,Right=>0',
                     b'Right=>(-101),Left=>0'):
            with self.subTest(actuals=args):
                self.check(program(declaration, b'R:=Subtract(' + args + b');'), 2)
        procedure = (b'subtype Small is Integer range 0..9;'
                     b'procedure P(N:in Small;X:out Small)is begin X:=N;end P;')
        for objects, args in (
            (b'R:Small:=0;', b'X=>R,N=>10'),
            (b'R:Integer range 0..8:=0;', b'N=>0,X=>R'),
            (b'R:Boolean:=False;', b'X=>R,N=>0'),
            (b'R:constant Small:=0;', b'X=>R,N=>0'),
            (b'R:Small:=0;', b'X=>(R),N=>0'),
        ):
            with self.subTest(objects=objects, actuals=args):
                self.check(program(procedure + objects, b'P(' + args + b');'), 2)

    def test_named_inout_preserves_both_containment_checks(self) -> None:
        declaration = (b'subtype Small is Integer range 0..9;'
                       b'procedure P(X:in out Small)is begin X:=0;end P;')
        self.check_full_route(program(declaration + b'R:Integer:=0;',
                                     b'R:=7;P(X=>R);' + output(b"Integer'Image(R)")),
                              kind='assigned', procedures={'P': ()},
                              runs=(((), b' 0\n', 0),))
        self.check(program(declaration + b'R:Integer:=0;', b'P(X=>R);'), 2)
        self.check(program(declaration + b'R:Integer range 0..8:=0;', b'P(X=>R);'), 2)

    def test_named_writable_targets_remain_distinct(self) -> None:
        declaration = (b'procedure Pair(X:out Integer;Y:in out Integer)is '
                       b'begin X:=Y;Y:=0;end Pair;R:Integer:=1;')
        for args in (b'X=>R,Y=>R', b'Y=>R,X=>R', b'R,Y=>r'):
            with self.subTest(actuals=args):
                self.check(program(declaration, b'Pair(' + args + b');'), 2)

    def test_named_payload_preserves_qualified_validity_alias_rule(self) -> None:
        declarations = (b'procedure Copy_Flag(B:in Boolean;X:out Boolean)is '
                        b'begin X:=B;end Copy_Flag;Input_Is_Valid:Boolean:=False;')
        queries = (b'Silver_Arguments.Input_Is_Valid',
                   b'not (not SiLvEr_ArGuMeNtS -- package\n . InPuT_Is_VaLiD)')
        for query in queries:
            with self.subTest(query=query):
                body = (b'Copy_Flag(X=>Input_Is_Valid,B=>' + query + b');'
                        b'if Input_Is_Valid then ' + output(b'"yes"')
                        + b'else ' + output(b'"no"') + b'end if;')
                self.check_full_route(program(declarations, body, arguments=True),
                                      kind='selected', procedures={'Copy_Flag': ('X',)},
                                      runs=(((), b'yes\n', 0), ((b'',), b'yes\n', 0),
                                            ((b'valid',), b'yes\n', 0),
                                            ((b'one', b'two'), b'', 1), ((b'\x01',), b'', 1)))
        self.check(program(declarations,
                           b'Copy_Flag(X=>Input_Is_Valid,B=>Input_Is_Valid);',
                           arguments=True), 2)

    def test_named_payload_literals_and_nested_reads(self) -> None:
        copy = (b'procedure Copy(N:in Integer;X:out Integer)is '
                b'begin X:=N;end Copy;F:Integer:=0;')
        self.check_full_route(program(copy, b'Copy(X=>F,N=>16#F#);'
                                     + output(b"Integer'Image(F)")),
                              kind='assigned', procedures={'Copy': ('X',)},
                              runs=(((), b' 15\n', 0),))
        slice_read = (b'subtype One is Integer range 1..1;'
                      b'procedure P(B:in Boolean;X:out One)is begin X:=1;end P;'
                      b'S:constant String:="x";Index:One:=1;Other:One:=1;')
        self.check(program(slice_read, b'P(X=>Index,B=>S(1..Index)="x");'), 2)
        self.check_full_route(program(slice_read, b'P(X=>Other,B=>S(1..Index)="x");'
                                     + output(b"Integer'Image(Other)")),
                              kind='assigned', procedures={'P': ('X',)},
                              runs=(((), b' 1\n', 0),))

    def test_actuals_share_incoming_state_in_every_order(self) -> None:
        declaration = (b'subtype Den is Integer range 0..1;'
                       b'function F(X:in Integer;Safe:in Boolean)return Integer is '
                       b'begin return X;end F;'
                       b'procedure P(X:in Integer;Safe:in Boolean;R:out Integer)is '
                       b'begin R:=X;end P;D:Den:=1;R:Integer:=0;')
        for args in (b'Safe=>D>0,X=>(1/D)', b'X=>(1/D),Safe=>D>0'):
            with self.subTest(actuals=args):
                self.check(program(declaration, b'R:=F(' + args + b');'), 2)
                self.check(program(declaration, b'P(' + args + b',R=>R);'), 2)

    def test_named_calls_in_functions_procedures_branches_and_loops(self) -> None:
        declarations = (SUBTRACT
            + b'function Wrap(N:in Small)return Difference is R:Difference:=0;'
              b'begin R:=Subtract(0,Right=>N);return R;end Wrap;'
              b'procedure Compute(N:in Small;R:out Difference)is begin '
              b'R:=0;R:=Subtract(Right=>0,Left=>N);end Compute;'
              b'R:Difference:=0;')
        body = (b'for I in 1..2 loop if I=1 then Compute(R=>R,N=>7);'
                b'else R:=Wrap(N=>7);end if;' + output(b"Integer'Image(R)") + b'end loop;')
        self.check_full_route(program(declarations, body), kind='assigned',
                              functions=('Subtract', 'Wrap'), procedures={'Compute': ('R',)},
                              runs=(((), b' 7\n-7\n', 0),))

    def test_function_actual_reads_assignment_targets_incoming_value(self) -> None:
        declarations = (b'function Id(X:in Integer)return Integer is '
                        b'begin return X;end Id;R:Integer:=0;')
        self.check_full_route(program(declarations, b'R:=7;R:=Id(X=>R);'
                                     + output(b"Integer'Image(R)")),
                              kind='assigned', functions=('Id',), runs=(((), b' 7\n', 0),))

    def test_unreachable_named_calls_still_check_complete_rules(self) -> None:
        declarations = SUBTRACT + b'R:Difference:=0;'
        for invalid in (b'R:=Subtract(Right=>0,Left=>101);',
                        b'R:=Subtract(Left=>0,lEfT=>0);'):
            for wrapper in ((b'if False then ', b'end if;'),
                            (b'for I in 2..1 loop ', b'end loop;')):
                with self.subTest(call=invalid, wrapper=wrapper):
                    self.check(program(declarations, wrapper[0] + invalid + wrapper[1]), 2)

    def test_many_reordered_formals_and_complete_source_boundary(self) -> None:
        def source(count: int) -> bytes:
            names = [b'A' + str(i).encode() for i in range(count)]
            declaration = (b'function F('
                + b';'.join(name + b':in Integer' for name in names)
                + b')return Integer is begin return A0;end F;R:Integer:=0;')
            arguments = b','.join(name + (b'=>42' if name == b'A0' else b'=>0')
                                  for name in reversed(names))
            return program(declaration, b'R:=F(' + arguments + b');'
                           + output(b"Integer'Image(R)"))
        count = 1
        while len(source(count + 1)) <= 4096:
            count += 1
        self.assertGreater(count, 100)
        text = source(count)
        padded = text + b' ' * (4096 - len(text))
        self.check_full_route(padded, kind='assigned', functions=('F',),
                              runs=(((), b' 42\n', 0),))
        self.check(padded + b' ', 2)
        self.check(text.replace(b'A0=>42', b'A1=>42'), 2)


if __name__ == '__main__':
    unittest.main()
