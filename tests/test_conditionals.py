"""Recursive String choices preserve state, source bounds and branch order."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings
from tests.test_shared_bindings import output, program


class ConditionalTests(unittest.TestCase):
    check = test_shared_bindings.SharedBindingsTests.check
    compile = test_shared_bindings.SharedBindingsTests.compile
    run_program = test_shared_bindings.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver conditionals-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'conditionals.adb'

    def test_nested_elsif_and_optional_else_have_rejected_neighbours(self) -> None:
        declarations = b'A:String:="old";B:String:="new";'
        optional = b'if A="old" then null;end if;'
        alternatives = (b'if A="old" then null;elsif B="new" then A:=B;'
                        b'elsif A=B then null;else B:=A;end if;')
        nested = (b'if A="old" then if B="new" then A:=B;else null;end if;'
                  b'else if A=B then null;elsif A="old" then B:=A;end if;end if;')
        pairs = [
            ('missing then statement', optional, optional.replace(b'null;', b'')),
            ('missing terminator', optional, optional.replace(b'end if;', b'end;')),
            ('empty explicit else', optional, optional.replace(b'end if;', b'else end if;')),
            ('empty elsif arm', alternatives,
             alternatives.replace(b'elsif B="new" then A:=B;', b'elsif B="new" then ')),
            ('missing elsif condition', alternatives,
             alternatives.replace(b'elsif B="new" then', b'elsif then')),
            ('missing elsif then', alternatives,
             alternatives.replace(b'elsif B="new" then', b'elsif B="new"')),
            ('elsif after else', alternatives,
             alternatives.replace(b'else B:=A;', b'else B:=A;elsif A=B then null;')),
            ('second else', alternatives,
             alternatives.replace(b'else B:=A;', b'else B:=A;else null;')),
            ('nested unknown reference', nested, nested.replace(b'if B="new"', b'if Missing="new"')),
            ('nested length mismatch', nested, nested.replace(b'A:=B;', b'A:="no";')),
            ('missing nested end', nested, nested.replace(b'else null;end if;', b'else null;', 1)),
        ]
        for rule, admitted, rejected in pairs:
            with self.subTest(rule=rule):
                self.check(program(declarations, admitted))
                self.check(program(declarations, rejected), 2)
        layout = alternatives.replace(b'elsif B=', b'ELSIF-- next condition\r\nb=')
        self.check(program(declarations, layout))

    def test_nested_conditions_and_elsif_share_expression_limits(self) -> None:
        declarations = b'A:String:="x";'
        first = b'&'.join([b'"x"'] + [b'""'] * 31)
        second = b'&'.join([b'"x"'] + [b'""'] * 32)
        sixty_four = b'&'.join([b'"x"'] + [b'""'] * 63)
        body = (b'if A=' + first + b' then null;elsif A=' + second
                + b' then null;end if;')
        self.check(program(declarations, body))
        self.check(program(declarations, body.replace(b'end if;',
                   b'elsif A="x"&"" then null;end if;')), 2)
        self.check(program(declarations,
                           b'if A="x" then null;elsif A=' + sixty_four
                           + b'&"" then null;end if;'), 2)
        bounded = (b'if Input="old" then null;else if Input=Input then '
                   + output(b'Input&Input') + b'end if;end if;')
        self.check(program(b'', bounded, arguments=True, capacity=2048))
        self.check(program(b'', bounded.replace(output(b'Input&Input'),
                                                output(b'Input&Input&"!"')),
                           arguments=True, capacity=2048), 2)

    def test_source_bound_limits_nesting_and_elsif_chains(self) -> None:
        declarations = b'A:String:="x";'
        nested = b'null;'
        while len(program(declarations, b'if A="x" then ' + nested + b'end if;')) <= 4096:
            nested = b'if A="x" then ' + nested + b'end if;'
        later_nested = b'null;'
        while len(program(declarations, b'null;if A="x" then ' + later_nested + b'end if;')) <= 4096:
            later_nested = b'null;if A="x" then ' + later_nested + b'end if;'
        alternatives = b'if A="x" then null;'
        while len(program(declarations, alternatives + b'elsif A="x" then null;end if;')) <= 4096:
            alternatives += b'elsif A="x" then null;'
        for label, body in (('nested', nested), ('later nested', later_nested),
                            ('elsif', alternatives + b'end if;')):
            with self.subTest(shape=label):
                self.assertGreater(body.count(b'then'), 100)
                source = program(declarations, body)
                source += b' ' * (4096 - len(source))
                self.check(source)
                self.check(source + b' ', 2)

    def test_native_nested_assignments_observe_current_values_and_snapshots(self) -> None:
        declarations = b'A:String:="old";Saved:constant String:=A;B:String:="raw";'
        body = (b'if A="old" then A:="new";'
                b'if A="new" then B:="yes";elsif A="old" then B:="bad";end if;'
                b'elsif A="new" then B:="bad";else B:="bad";end if;'
                b'if A="old" then B:="bad";end if;'
                + output(b'Saved&"/"&A&"/"&B'))
        executable, _ = self.compile(program(declarations, body), 'assigned')
        self.run_program(executable, b'old/new/yes\n')

    def test_native_elsif_first_match_optional_paths_and_argument_rejection(self) -> None:
        declarations = b'Work:String:=Input;Saved:constant String:=Work;Tag:String:="raw";'
        body = (b'if Input="old" then '
                b'if Tag="raw" then Tag:="one";end if;'
                b'elsif Input="old" then Tag:="bad";'
                b'elsif Input="new" then Tag:="two";'
                b'elsif Input="" then Tag:="nil";'
                b'else if Tag="raw" then Tag:="oth";else Tag:="bad";end if;end if;'
                b'if Tag="one" then Work:=Input;elsif Tag="two" then Work:=Saved;end if;'
                + output(b'Tag') + output(b'Work') + output(b'Saved'))
        executable, _ = self.compile(program(declarations, body, arguments=True), 'selected')
        self.run_program(executable, b'one\nold\nold\n')
        for value, tag in ((b'old', b'one'), (b'new', b'two'), (b'', b'nil'),
                           (b'other', b'oth'), (b'x' * 4096, b'oth')):
            with self.subTest(argument_length=len(value), tag=tag):
                self.run_program(executable, tag + b'\n' + value + b'\n' + value + b'\n', (value,))
        for arguments in ((b'old', b'extra'), (b'x' * 4097,), (b'\x01',)):
            self.run_program(executable, b'', arguments, 1)


if __name__ == '__main__':
    unittest.main()
