"""Predicate grammar follows Ada grouping and bounded integer spelling rules."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings
from tests.test_composed_results import literal
from tests.test_shared_bindings import output, program


def argument_program(declarations: bytes, body: bytes) -> bytes:
    """Build an argument program whose body supplies its own validity checks."""
    return (b'with Silver_IO;with Silver_Arguments;'
            b'procedure Main is pragma SPARK_Mode(On);'
            b'Input:constant String:=Silver_Arguments.First_Or_Default("old");'
            + declarations + b'begin ' + body + b'end Main;')


class PredicateTests(unittest.TestCase):
    check = test_shared_bindings.SharedBindingsTests.check
    compile = test_shared_bindings.SharedBindingsTests.compile
    run_program = test_shared_bindings.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver predicates-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'predicates.adb'

    def condition(self, predicate: bytes, expected: int = 0) -> None:
        self.check(program(b'A:String:="old";B:constant String:=A;',
                           b'if ' + predicate + b' then null;end if;'), expected)

    def test_predicate_atoms_have_rejected_neighbours(self) -> None:
        for predicate in (b'A=B', b'A/=B', b'A/="new"', b'("o"&"ld")=A',
                          b'not (A=B)', b'(A=B)', b'((A/=B))',
                          b"A'Length=B'Length"):
            with self.subTest(predicate=predicate):
                self.condition(predicate)
        for operator in (b'=', b'/=', b'<', b'<=', b'>', b'>='):
            self.condition(b"A'Length" + operator + b'3')
            self.condition(b"A'Length" + operator + b"B'Length")
        for predicate in (b'A<>B', b'A==B', b'A<B', b'A>=B', b'Absent=A',
                          b'not A=B', b"A'First=1", b"Absent'Length=3",
                          b"3=A'Length", b'A=B=A',
                          b'Silver_Arguments.Input_Is_Valid'):
            with self.subTest(predicate=predicate):
                self.condition(predicate, 2)

    def test_boolean_grouping_and_short_circuit_spelling(self) -> None:
        admitted = (b'A=B and then A="old" and then B/="new"',
                    b'A=B or else A="old" or else B/="new"',
                    b'(A=B and then A="old") or else B="new"',
                    b'A=B and then (A="old" or else B="new")',
                    b'not (A=B or else A="new")',
                    b'(not (A=B)) or else not (A="new")',
                    b"A'Length>=1 AnD-- operator\r\nThEn A'Length<=4")
        rejected = (b'A=B and then A="old" or else B="new"',
                    b'A=B or else A="old" and then B="new"',
                    b'A=B and A="old"', b'A=B or A="old"', b'A=B xor A="old"',
                    b'A=B and then', b'or else A=B', b'not not (A=B)',
                    b'not ()', b'((A=B)', b'A=B)', b'True', b'False', b'not True')
        for expected, predicates in ((0, admitted), (2, rejected)):
            for predicate in predicates:
                with self.subTest(predicate=predicate):
                    self.condition(predicate, expected)
        valid = b'Silver_Arguments.Input_Is_Valid'
        self.check(argument_program(b'', b'if not ' + valid
                                    + b' then Silver_Arguments.Reject;else null;end if;'))
        # Existing String bindings may use these identifiers.
        self.check(program(b'True:String:="yes";False:String:="no";',
                           b'if True="yes" and then False="no" then null;end if;'))

    def test_integer_spellings_values_and_exponent_bounds(self) -> None:
        admitted = (b'0', b'00', b'03', b'0_3', b'4_096', b'3E0', b'3e+0',
                    b'1_0E+1', b'2#11#', b'3#10#', b'16#0_4#', b'016#0ff#',
                    b'2#1#E+3', b'16#1#E3', b'16#F_f#', b'0E4096',
                    b'16#0#E4096', b'1_6#3#', b'0_1_6:3:', b'16:1:', b'2:11:', b'16:0_4:',
                    b'2:1:E+3', b'16:0:E4096')
        rejected = (b'4097', b'4_097', b'16#1001#', b'1E4', b'0E4097',
                    b'16#0#E4097', b'+3', b'-0', b'3.0', b'1E-1', b'0E-0',
                    b'_3', b'3_', b'3__0', b'1E', b'1E+', b'1E_0', b'1E0_',
                    b'1#0#', b'17#1#', b'2#2#', b'16#G#', b'16##',
                    b'16#_1#', b'16#1_#', b'16#1__0#', b'16#1',
                    b'16#1:', b'16:1#', b'16::', b'16:1', b'16:0:E4097',
                    b'16#1.0#', b'16#1#E-0', b'9' * 100)
        for expected, literals in ((0, admitted), (2, rejected)):
            for literal in literals:
                with self.subTest(literal=literal):
                    self.condition(b"A'Length<=" + literal, expected)
        self.condition(b"A'Length<=0E" + b'9' * 100, 2)

    def test_final_bracket_literals_require_a_separator_before_word_tokens(self) -> None:
        cases = ((b'A="["', b'then null;end if;'),
                 (b'A="["', b'ThEn null;end if;'),
                 (b'A="["', b'and then A="[" then null;end if;'),
                 (b'A="["', b'Or ElSe A="" then null;end if;'),
                 (b'(A="["', b'and then A="[") then null;end if;'),
                 (b'A=""&"["', b'then null;end if;'),
                 (b'A=' + literal(b'"['), b'then null;end if;'),
                 (b'A=' + literal(b'x["['), b'then null;end if;'),
                 (b'A="" then null;elsif A="["', b'then null;end if;'))
        for predicate, tail in cases:
            with self.subTest(predicate=predicate, tail=tail):
                rejected = program(b'A:String:="[";', b'if ' + predicate + tail)
                self.check(rejected, 2)
                for separator in (b' ', b'\t', b'\r\n', b'-- separator\n'):
                    self.check(program(b'A:String:="[";',
                                       b'if ' + predicate + separator + tail))
        # Parentheses delimit tokens; brackets elsewhere and an escaped quote
        # after the bracket remain ordinary printable literal bytes.
        for predicate in (b'(A="[")then', b'A=("[")then',
                          b'A="[x"then', b'A="[]"then',
                          b'A=' + literal(b'["x') + b'then',
                          b'A=' + literal(b'["') + b'then',
                          b'A=' + literal(b'["41"]') + b'then'):
            with self.subTest(admitted_predicate=predicate):
                self.check(program(b'A:String:="[";', b'if ' + predicate + b' null;end if;'))

    def test_bracket_encoded_character_spelling_is_rejected_in_each_position(self) -> None:
        # GNAT interprets this spelling as one encoded character, A. It must
        # never become an admitted alternative spelling of Silver's byte literal.
        encoded = b'"["41"]"'
        cases = (program(b'A:constant String:=' + encoded + b';', output(b'A')),
                 program(b'', output(encoded)),
                 program(b'A:constant String:="A";',
                         b'if A=' + encoded + b' then null;end if;'))
        for position, source in zip(('initializer', 'output', 'comparison'), cases):
            with self.subTest(position=position):
                self.check(source, 2)

    def test_native_bracket_literal_siblings_preserve_decoded_bytes(self) -> None:
        declarations = (b'A:String:="[";B:String:=' + literal(b'"[')
                        + b';C:String:=' + literal(b'["')
                        + b';D:String:=' + literal(b'["41"]')
                        + b';E:String:=' + literal(b'x["[') + b';')
        predicates = (b'A="[" then', b'A="["-- separator\nthen',
                      b'(A="[")then', b'A=("[")then',
                      b'A="[" and then A="[" then',
                      b'A="[" or else A="" then',
                      b'B=' + literal(b'"[') + b' then',
                      b'C=' + literal(b'["') + b'then',
                      b'D=' + literal(b'["41"]') + b'then',
                      b'E=' + literal(b'x["[') + b' then',
                      b'A="" then null;elsif A="[" then')
        body = b'\n'.join(b'if ' + predicate + b' ' + output(b'A')
                          + b'else ' + output(b'"bad"') + b'end if;' for predicate in predicates)
        body += output(b'B') + output(b'C') + output(b'D') + output(b'E')
        executable, _ = self.compile(program(declarations, body), 'static')
        self.run_program(executable, b'[\n' * len(predicates) + b'"[\n["\n["41"]\nx["[\n')

    def test_source_bound_literal_spellings_do_not_gain_a_digit_count_limit(self) -> None:
        declarations = b'A:String:="old";'
        prefix, suffix = b"if A'Length<=", b' then null;end if;'
        room = 4096 - len(program(declarations, prefix + suffix))
        literals = (b'0' * (room - 4) + b'4096',
                    b'0' * (room - 5) + b'16#3#',
                    b'0' * (room - 5) + b'16:3:',
                    b'0E' + b'0' * (room - 6) + b'4096')
        for literal in literals:
            with self.subTest(ending=literal[-10:]):
                source = program(declarations, prefix + literal + suffix)
                self.assertEqual(len(source), 4096)
                self.check(source)
                self.check(source + b' ', 2)

    def test_native_literal_meaning_boolean_grouping_and_inequality(self) -> None:
        declarations = b'A:String:="old";Empty:String:="";Eight:String:="12345678";'
        predicates = (b"A'Length=03", b"A'Length=3E+0", b"A'Length=2#11#",
                      b"A'Length<16#0_4#", b"Eight'Length=2#1#E+3",
                      b"Empty'Length=0E4096", b"Empty'Length=16#0#E4096",
                      b"A'Length=2:11:", b"Eight'Length=2:1:E+3",
                      b"Empty'Length=16:0:E4096",
                      b'A/="new"', b'not (A="new")',
                      b'(A="old" and then A/="new") or else A="missing"')
        body = b''.join(b'if ' + predicate + b' then ' + output(b'"yes"')
                        + b'else ' + output(b'"bad"') + b'end if;' for predicate in predicates)
        executable, _ = self.compile(program(declarations, body), 'static')
        self.run_program(executable, b'yes\n' * len(predicates))


if __name__ == '__main__':
    unittest.main()
