"""Only established path facts justify expression bounds and returning effects."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings
from tests.test_predicates import argument_program
from tests.test_shared_bindings import output, program


VALID = b'Silver_Arguments.Input_Is_Valid'
REJECT = b'Silver_Arguments.Reject;'


class PathRefinementTests(unittest.TestCase):
    check = test_shared_bindings.SharedBindingsTests.check
    compile = test_shared_bindings.SharedBindingsTests.compile
    run_program = test_shared_bindings.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver path facts-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'paths.adb'

    def test_short_circuit_operands_use_only_preceding_facts(self) -> None:
        doubled = b'Input&Input=""'
        admitted = (b"Input'Length<=2048 and then " + doubled,
                    b"Input'Length>2048 or else " + doubled,
                    b"not (Input'Length>2048) and then " + doubled,
                    b"(Input'Length=0 or else Input'Length=1) and then " + doubled)
        rejected = (doubled + b" and then Input'Length<=2048",
                    b"Input'Length<=2048 or else " + doubled,
                    b"Input'Length>2048 and then " + doubled)
        for expected, predicates in ((0, admitted), (2, rejected)):
            for predicate in predicates:
                with self.subTest(predicate=predicate):
                    self.check(program(b'', b'if ' + predicate + b' then null;end if;',
                                       arguments=True), expected)

    def test_true_and_false_lengths_refine_fixed_assignments(self) -> None:
        declarations = b'Work:String:=Input;Fixed:String:="old";'
        admitted = (b'if Input="old" then Work:=Fixed;end if;',
                    b'if Input/="old" then null;else Work:=Fixed;end if;',
                    b"if Input'Length=3 then Work:=Fixed;end if;",
                    b"if Work'Length=Fixed'Length then Work:=Fixed;end if;",
                    b"if Input'Length/=3 then null;else Work:=Fixed;end if;",
                    b"if Input'Length<3 then null;elsif Input'Length>3 then null;"
                    b'else Work:=Fixed;end if;',
                    b"if Input'Length>=3 and then Input'Length<=3 then Work:=Fixed;end if;",
                    b"if Input'Length>2 and then Input'Length<4 then Fixed:=Input;end if;",
                    b'if Input="old" then Fixed:="new";Work:=Fixed;end if;')
        rejected = (b'if Input/="old" then Work:=Fixed;end if;',
                    b'if Input="old" then null;else Work:=Fixed;end if;',
                    b"if Input'Length<=3 then Work:=Fixed;end if;",
                    b"if Input'Length>=3 then Work:=Fixed;end if;",
                    b"if Input'Length=2 then Work:=Fixed;end if;",
                    b'if Input="old" then Work:="xx";end if;')
        for expected, bodies in ((0, admitted), (2, rejected)):
            for body in bodies:
                with self.subTest(body=body):
                    self.check(program(declarations, body, arguments=True), expected)

    def test_interval_join_and_string_inequality_do_not_invent_exact_length(self) -> None:
        declarations = b'Work:String:=Input;Fixed:constant String:="Hello";'
        admitted = (b"if Input'Length=5 and then Input/=\"\" then "
                    b'Work:=Fixed;end if;')
        rejected = admitted.replace(b"Input'Length=5", b"(Input'Length=5 or else Input'Length=0)")
        self.check(program(declarations, admitted, arguments=True))
        # The union is approximated by [0, 5]; true String inequality adds no
        # exact-length fact. Logical safety alone does not establish admission.
        self.check(program(declarations, rejected, arguments=True), 2)

    def test_unreachable_static_assignment_requires_equal_lengths(self) -> None:
        declarations = b'Fixed:String:="abc";'
        body = (b'if not ' + VALID + b' then ' + REJECT
                + b"elsif Input'Length>4096 then Fixed:=\"xyz\";end if;")
        sibling = argument_program(declarations, body)
        static = program(declarations, b"if Fixed'Length>4096 then Fixed:=\"xyz\";end if;")
        for admitted in (sibling, static):
            with self.subTest(argument_shell=admitted == sibling):
                self.check(admitted)
                for value in (b'"toolong"', b'"xy"', b'""'):
                    with self.subTest(value=value):
                        self.check(admitted.replace(b'Fixed:="xyz"', b'Fixed:=' + value), 2)
        # GNAT's frontend-only check misses this regression: exercise proof,
        # code generation and execution through the normal compiler helper.
        executable, _ = self.compile(sibling, 'selected')
        self.run_program(executable, b'')
        self.run_program(executable, b'', (b'x' * 4096,))
        self.run_program(executable, b'', (b'old', b'extra'), 1)

    def test_static_targets_bound_all_static_rhs_contributions_even_when_unreachable(self) -> None:
        declarations = (b'Fixed:String:="abc";Long:constant String:="abcd";'
                        b'Copy:constant String:=Input;Work:String:=Input;')
        pairs = ((b'"abc"&Input', b'"abcd"&Input'),
                 (b'Input&"abc"', b'Input&"abcd"'),
                 (b'"a"&Input&"bc"', b'"ab"&Input&"cd"'),
                 (b'"abc"&Copy', b'Long&Copy'),
                 (b'Copy&"abc"', b'Copy&Long'))
        prefix = b"if Input'Length>4096 then Fixed:="
        for admitted, rejected in pairs:
            with self.subTest(rhs=rejected):
                self.check(program(declarations, prefix + admitted + b';end if;', arguments=True))
                self.check(program(declarations, prefix + rejected + b';end if;', arguments=True), 2)
        # A smaller static contribution is legal only with the required path
        # length; the repair must retain that check as well as the new floor.
        for expression in (b'"ab"&Input', b'Input&"ab"', b'"a"&Copy&"b"'):
            body = b"if Input'Length=1 then Fixed:=" + expression + b';end if;'
            with self.subTest(refined_rhs=expression):
                self.check(program(declarations, body, arguments=True))
                self.check(program(declarations, body.replace(b'Length=1', b'Length=2'),
                                   arguments=True), 2)
        # The static floor applies to static targets, not symbolic input bounds.
        dynamic = b"if Input'Length>4096 then Work:=\"abcd\"&Input;end if;"
        self.check(program(declarations, dynamic, arguments=True))

    def test_native_static_rhs_floor_preserves_refined_and_unreachable_siblings(self) -> None:
        declarations = b'Fixed:String:="abc";'
        body = (b"if Input'Length>4096 then Fixed:=\"abc\"&Input;"
                b"elsif Input'Length=1 then Fixed:=\"ab\"&Input;"
                b'else null;end if;' + output(b'Fixed'))
        executable, _ = self.compile(program(declarations, body, arguments=True), 'selected')
        self.run_program(executable, b'abc\n')
        self.run_program(executable, b'abx\n', (b'x',))
        self.run_program(executable, b'abc\n', (b'',))
        self.run_program(executable, b'abc\n', (b'x' * 4096,))
        self.run_program(executable, b'', (b'one', b'two'), 1)

    def test_affine_lengths_and_alias_bounds_refine_together(self) -> None:
        declarations = b'Work:String:=Input;Fixed:String:="ok";Copy:constant String:=Input;'
        body = b'if Input&"x"="old" then Work:=Fixed;end if;'
        self.check(program(declarations, body, arguments=True, capacity=4095))
        self.check(program(declarations, body, arguments=True), 2)
        alias_body = b"if Copy'Length<=2048 then " + output(b'Input&Work') + b'end if;'
        self.check(program(declarations, alias_body, arguments=True))
        self.check(program(declarations, alias_body.replace(b'2048', b'2049'),
                           arguments=True), 2)
        sixteen = b'&'.join([b'Input'] * 16)
        zero = (b"if Input'Length<=2048 and then Input&Input=Input then "
                + output(sixteen) + b'end if;')
        self.check(program(b'', zero, arguments=True))

    def test_joins_assignments_and_initializers_do_not_invent_facts(self) -> None:
        doubled = output(b'Input&Input')
        bodies = (b"if Input'Length<=2048 then null;else null;end if;" + doubled,
                  b"if Input'Length<=2048 then " + doubled + b'end if;' + doubled,
                  b"if Input'Length>2048 then " + REJECT + b'end if;' + doubled)
        for body in bodies:
            with self.subTest(body=body):
                self.check(program(b'', body, arguments=True), 2)
        initializer = b'Copy:constant String:=Input&Input;'
        body = b"if Input'Length<=2048 then " + output(b'Copy') + b'end if;'
        self.check(program(initializer, body, arguments=True), 2)
        declarations = b'Work:String:=Input;Fixed:String:="new";'
        preserved = (b"if Work'Length=3 then Work:=Fixed;"
                     b'if Work="new" then null;else null;end if;'
                     + output(b'Input&Input') + b'end if;')
        self.check(program(declarations, preserved, arguments=True))

    def test_generalized_validity_paths_require_rejection_without_output(self) -> None:
        admitted = (b'null;if not ' + VALID + b' then ' + REJECT
                    + b'else ' + output(b'Input') + b'end if;null;',
                    REJECT,
                    b"if Input'Length>0 then " + output(b'Input') + b'else ' + REJECT + b'end if;',
                    b'if Input="old" then ' + output(b'Input') + b'else ' + REJECT + b'end if;',
                    REJECT + b'if ' + VALID + b' then ' + output(b'Input') + b'end if;',
                    b'if ' + VALID + b' then null;else ' + REJECT + b'null;end if;')
        rejected = (b'if not ' + VALID + b' then ' + REJECT + b'end if;' + output(b'Input'),
                    REJECT + output(b'"still returns"'),
                    b'if Input="" then ' + output(b'Input') + b'else ' + REJECT + b'end if;',
                    b'if ' + VALID + b' then null;end if;',
                    b'if ' + VALID + b' then ' + output(b'Input') + b'else null;end if;',
                    output(b'"before validation"') + b'if not ' + VALID
                    + b' then ' + REJECT + b'end if;')
        for expected, bodies in ((0, admitted), (2, rejected)):
            for body in bodies:
                with self.subTest(body=body):
                    self.check(argument_program(b'', body), expected)

    def test_native_refined_assignments_preserve_snapshots_and_input_domain(self) -> None:
        declarations = b'Work:String:=Input;Saved:constant String:=Work;Fixed:String:="new";'
        body = (b'if not ' + VALID + b' then ' + REJECT
                + b"elsif Input'Length=3 then Work:=Fixed;"
                + output(b'Work') + output(b'Saved')
                + b'else ' + output(b'Work') + output(b'Saved') + b'end if;')
        executable, _ = self.compile(argument_program(declarations, body), 'selected')
        self.run_program(executable, b'new\nold\n')
        for value in (b'', b'x', b'abc', b'longer', b'x' * 4096):
            selected = b'new' if len(value) == 3 else value
            with self.subTest(argument_length=len(value)):
                self.run_program(executable, selected + b'\n' + value + b'\n', (value,))
        for arguments in ((b'old', b'extra'), (b'x' * 4097,), (b'\x01',)):
            self.run_program(executable, b'', arguments, 1)

    def test_native_short_circuit_length_branches(self) -> None:
        body = (b'if ' + VALID + b" and then Input'Length<=2 then "
                + output(b'Input&Input') + b'elsif ' + VALID + b' then '
                + output(b'Input') + b'else ' + REJECT + b'end if;')
        executable, _ = self.compile(argument_program(b'', body), 'argument')
        self.run_program(executable, b'old\n')
        for value in (b'', b'a', b'ab', b'abc', b'x' * 4096):
            expected = value * 2 if len(value) <= 2 else value
            self.run_program(executable, expected + b'\n', (value,))
        self.run_program(executable, b'', (b'\x01',), 1)
        self.run_program(executable, b'', (b'old', b'extra'), 1)

    def test_native_length_guard_can_establish_validity_without_query(self) -> None:
        body = (b"if Input'Length>0 then " + output(b'Input')
                + b'else ' + REJECT + b'end if;')
        executable, _ = self.compile(argument_program(b'', body), 'argument')
        self.run_program(executable, b'old\n')
        self.run_program(executable, b'nonempty\n', (b'nonempty',))
        for arguments in ((b'',), (b'\x01',), (b'old', b'extra'), (b'x' * 4097,)):
            self.run_program(executable, b'', arguments, 1)

    def test_native_invalid_input_assignments_use_the_empty_initializer(self) -> None:
        declarations = b'Work:String:="";'
        assignment = b'Work:=Input&Input;'
        body = (b'if not ' + VALID + b' then ' + assignment + REJECT
                + b'else ' + output(b'"valid"') + b'end if;')
        executable, _ = self.compile(argument_program(declarations, body), 'selected')
        self.run_program(executable, b'valid\n')
        self.run_program(executable, b'valid\n', (b'',))
        self.run_program(executable, b'', (b'\x01',), 1)
        self.run_program(executable, b'', (b'old', b'extra'), 1)
        self.run_program(executable, b'', (b'x' * 4097,), 1)
        rejected = (b'if ' + VALID + b' then ' + assignment
                    + b'else ' + REJECT + b'end if;')
        self.check(argument_program(declarations, rejected), 2)

    def test_native_reject_returns_and_failure_status_is_sticky(self) -> None:
        body = (b'if ' + VALID + b' then ' + REJECT + output(b'Input')
                + output(b'"after rejection"') + b'else ' + REJECT + b'end if;')
        executable, _ = self.compile(argument_program(b'', body), 'argument')
        self.run_program(executable, b'old\nafter rejection\n', status=1)
        self.run_program(executable, b'\nafter rejection\n', (b'',), 1)
        self.run_program(executable, b'', (b'\x01',), 1)
        self.run_program(executable, b'', (b'old', b'extra'), 1)


if __name__ == '__main__':
    unittest.main()
