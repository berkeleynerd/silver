"""Native frontend boundaries found in the String indexing review (#309–#311)."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared
from tests.test_silver import HOST, invoke

program = shared.program
output = shared.output


class StringReviewBlockerTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check
    compile = shared.SharedBindingsTests.compile
    run_program = shared.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver string review-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'review.adb'

    def test_admission_inverted_span_is_bounded_before_any_consumer(self) -> None:
        # No enclosing guard: each rejection isolates the endpoint-span rule.
        text = b'S:constant String:="xy";'
        for upper, status in ((0, 0), (-1, 2), (-2147483648, 2)):
            declarations = (text + b'L:Integer range 2147483647..2147483647:=2147483647;'
                            + f'R:Integer range {upper}..{upper}:={upper};'.encode())
            with self.subTest(upper=upper):
                self.check(program(declarations, output(b'S(L..R)')), status)
                self.check(program(declarations + b'F:Boolean:=S(L..R)="ab";', b'null;'), status)
        # The potentially-nonnull admission branch must enforce the span too.
        self.check(program(text + b'L:Integer range 1..2147483647:=1;'
                           b'R:Integer range -2147483648..2:=2;', output(b'S(L..R)')), 2)
        for bounds in (b'2147483647..2147483646', b'0..(-1)'):
            self.check(program(text, output(b'S(' + bounds + b')')))
        self.check(program(text, output(b'S(2147483647..(-1))')), 2)

    def test_original_extreme_null_slice_failures_are_rejected(self) -> None:
        # Preserve the reported shells: argument bindings must be first, and
        # the crash case needs separate declarations and body assignments.
        # The unguarded span controls above isolate B1 from the B2 restriction.
        cases = (
            ('equality_wrong_answer', b'''with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   T : constant String := "xy";
   A : Integer range 2147483646 .. 2147483647 := 2147483647;
   B : Integer range -2147483648 .. -2147483647 := -2147483648;
begin
   if T (A .. B) = "ab" then
      Silver_IO.Put_Line ("EQ");
   else
      Silver_IO.Put_Line ("NE");
   end if;
end Main;
'''),
            ('assigned_endpoints_crash', b'''with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   T : constant String := "xy";
   A : Integer := 0;
   B : Integer := 0;
begin
   A := 2147483647;
   B := -2147483648;
   if T (A .. B) = "ab" then
      Silver_IO.Put_Line ("EQ");
   else
      Silver_IO.Put_Line ("NE");
   end if;
end Main;
'''),
            ('argument_length_check', b'''with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   D : constant String := Silver_Arguments.First_Or_Default ("");
   T : constant String := "xy";
   A : Integer range 2147483646 .. 2147483647 := 2147483647;
   B : Integer range -2147483648 .. -2147483647 := -2147483648;
   S : String := "abc";
begin
   if Silver_Arguments.Input_Is_Valid then
      if T (A .. B) = "ab" then
         S := D;
      end if;
      Silver_IO.Put_Line (S);
   else
      Silver_Arguments.Reject;
   end if;
end Main;
'''),
            ('invalid_argument_output', b'''with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Arg : constant String := Silver_Arguments.First_Or_Default ("uvw");
   T : constant String := "xy";
   A : Integer range 2147483646 .. 2147483647 := 2147483647;
   B : Integer range -2147483648 .. -2147483647 := -2147483648;
begin
   if T (A .. B) /= "ab" then
      if Silver_Arguments.Input_Is_Valid then
         Silver_IO.Put_Line (Arg);
      else
         Silver_Arguments.Reject;
      end if;
   else
      Silver_IO.Put_Line ("unexpected");
   end if;
end Main;
'''),
        )
        for name, source in cases:
            with self.subTest(case=name):
                self.check(source, 2)
                before = set(HOST.artifacts.glob('program-*'))
                result = invoke('compile', self.source)
                self.assertEqual(result.returncode, 2, result.stdout)
                self.assertEqual(self.source.read_bytes(), source)
                self.assertEqual(set(HOST.artifacts.glob('program-*')), before)

    def test_admission_guarded_nonstatic_slice_endpoints(self) -> None:
        text = b'S:constant String:="abc";'
        snapshot = b'X:Integer:=3;K:constant Integer:=X;'
        for guard in (b'K>3', b'3<K', b'not(K<=3)', b'(K + 0)>3',
                      b'X=5 and then K>3', b'X=5 and K>3'):
            self.check(program(text + snapshot, b'if ' + guard + b' then '
                               + output(b'S(4..K)') + b'end if;'), 2)
        for body in (
            b'if K<=3 then null;else ' + output(b'S(4..K)') + b'end if;',
            b'if K=3 then null;elsif K>3 then ' + output(b'S(4..K)') + b'end if;',
            b'for I in 1..9 loop if I<=8 and then I>=6 then if I=2 then '
            + output(b'S(I..5)') + b'end if;end if;end loop;',
            b'if S(1..K)="abc" then null;end if;',
        ):
            self.check(program(text + snapshot, body), 2)
        self.check(program(text + snapshot + b'Z:constant array(1..2)of Integer:=(-5,6);',
                           b'if K=Z(1) then ' + output(b'S(K..(-1))') + b'end if;'), 2)
        self.check(program(text + b'subtype P is Integer range 5..9;'
                           b'A:constant array(1..2)of P:=(5,6);',
                           b'for K of A loop if K=-5 then ' + output(b'S(K..(-1))')
                           + b'end if;end loop;'), 2)
        self.check(program(text + b'X:Integer:=2;K:constant Integer:=X;T:String:="xy";',
                           b'if K=0 then T:=S(1..K);end if;'), 2)
        self.check(program(text + b'X:Integer:=2;K:constant Integer:=X;T:String:="xyz";',
                           b'if K=0 then T:=S(1..K)&"z";end if;'), 2)

    def test_admission_guard_scanner_chains_tokens_and_resets(self) -> None:
        declarations = b'S:String:="abc";X:Integer:=3;K:constant Integer:=X;'
        for operator in (b'and then', b'or else', b'and', b'or', b'xor'):
            relation = b'K=9 ' + operator + b' S(1..K)="abc"'
            self.check(program(declarations + b'F:Boolean:=' + relation + b';', b'null;'), 2)
            self.check(program(declarations + b'F:Boolean:=False;', b'F:=' + relation + b';'), 2)
        # A completed conditional or Boolean statement must not taint later slices.
        for prefix in (b'if K=3 then null;end if;',
                       b'if K=3 then null;end -- comment between the closing words\nif;',
                       b'if K=3 then if K=3 then null;end if;else null;end if;',
                       b'F:=True and then False;',
                       b'-- if and or xor end if\r\n',
                       output(b'"if and or xor end if"')):
            self.check(program(declarations + b'F:Boolean:=False;', prefix + output(b'S(1..K)')))
        self.check(program(declarations + b'If_Name:Integer:=0;And_Name:Integer:=0;',
                           b'If_Name:=And_Name;' + output(b'S(1..K)')))
        self.check(program(declarations + b'F:Boolean:=K=9 and then ";"=S(1..K);', b'null;'), 2)
        self.check(program(declarations,
                           b'if K=9 then ' + output(b'"""end if;"""')
                           + output(b'S(1..K)') + b'end if;'), 2)
        # Both static endpoints remain usable throughout guarded contexts.
        self.check(program(declarations + b'Last:constant Integer:=2;',
                           b'if K=3 then ' + output(b'S(1..Last)') + b'else '
                           + output(b'S(0..(-1))') + b'end if;'))
        self.check(program(declarations + b'F:Boolean:=K=9 and then S(1..2)="ab";', b'null;'))

    def test_native_boundary_nulls_copies_and_concatenation(self) -> None:
        declarations = (b'S:constant String:="xy";'
                        b'L:Integer range 2147483647..2147483647:=2147483647;'
                        b'R:Integer range 0..0:=0;'
                        b'Z:constant String:=S(L..R);Copy:constant String:=Z;'
                        b'Joined:constant String:=""&Copy;')
        body = (b'if Joined="ab" then ' + output(b'"bad"') + b'else '
                + output(b'"NE"') + b'end if;' + output(b'S(L..R)&"ok"'))
        executable, _ = self.compile(program(declarations, body), 'assigned')
        self.run_program(executable, b'NE\nok\n')

    def test_native_static_guarded_slices_and_dynamic_reset(self) -> None:
        declarations = (b'S:constant String:="abc";X:Integer:=3;K:constant Integer:=X;'
                        b'Last:constant Integer:=3;'
                        b'Z:constant array(1..2)of Integer:=(-5,6);'
                        b'F:Boolean:=K=9 and then S(1..2)="ab";')
        body = (b'if K=Z(1) then ' + output(b'S(4..Last)')
                + b'elsif K=3 then if F then null;else ' + output(b'S(1..2)')
                + b'end if;else ' + output(b'S(0..(-1))') + b'end if;'
                b'F:=K=9 or else S(1..2)="ab";' + output(b'S(1..K)'))
        executable, _ = self.compile(program(declarations, body), 'assigned')
        self.run_program(executable, b'ab\nabc\n')

    def test_native_static_slices_on_nonstatic_prefix_snapshots(self) -> None:
        # A guard on an initializer endpoint must not change captured prefix bounds.
        declarations = (b'X:Integer:=3;K:constant Integer:=X;Base:constant String:="abc";'
                        b'S:constant String:=Base(1..K);')
        for suffix, name in ((b'', b'S'), (b'T:constant String:=S;', b'T'),
                             (b'T:constant String:=S&"";', b'T')):
            with self.subTest(suffix=suffix):
                body = (b'if K=0 then ' + output(name + b'(1..2)') + b'end if;'
                        + output(b'"end"'))
                executable, _ = self.compile(program(declarations + suffix, body), 'assigned')
                self.run_program(executable, b'end\n')
