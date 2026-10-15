"""Existing library calls retain Ada visibility and association meaning."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings
from tests.test_shared_bindings import output, program


ARGUMENT_CONTEXT = b'with Silver_IO;with Silver_Arguments;'
VISIBLE_CONTEXT = b'with Silver_Arguments,Silver_IO;use Silver_IO,Silver_Arguments;'


def visible(source: bytes) -> bytes:
    """Expose only the two existing packages in an argument program."""
    return source.replace(ARGUMENT_CONTEXT, VISIBLE_CONTEXT, 1)


class NamesCallsTests(unittest.TestCase):
    check = test_shared_bindings.SharedBindingsTests.check
    compile = test_shared_bindings.SharedBindingsTests.compile
    run_program = test_shared_bindings.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver names and calls-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'names_calls.adb'

    def test_context_order_grouping_and_repetition_preserve_package_requirements(self) -> None:
        source = program(b'', output(b'Input'), arguments=True)
        contexts = (
            b'with Silver_Arguments;with Silver_IO;',
            b'with Silver_IO,Silver_Arguments;',
            b'with Silver_Arguments,Silver_IO;',
            b'with Silver_IO;use Silver_IO;with Silver_Arguments;use Silver_Arguments;',
            VISIBLE_CONTEXT,
            b'with Silver_IO,Silver_IO;with Silver_Arguments;'
            b'use Silver_Arguments,Silver_IO,Silver_Arguments;'
            b'with Silver_Arguments;use Silver_IO;',
            b'WiTh-- packages\r\nSilver_Arguments , Silver_IO;'
            b'UsE Silver_Arguments , Silver_IO;',
        )
        for context in contexts:
            with self.subTest(context=context):
                self.check(source.replace(ARGUMENT_CONTEXT, context, 1))
        pairs = (
            (VISIBLE_CONTEXT, b'use Silver_IO;' + VISIBLE_CONTEXT),
            (VISIBLE_CONTEXT, b'with Silver_Arguments;use Silver_IO;with Silver_IO;'),
            (VISIBLE_CONTEXT, VISIBLE_CONTEXT.replace(b'with Silver_Arguments,', b'with ')),
            (VISIBLE_CONTEXT, VISIBLE_CONTEXT.replace(b',Silver_IO;', b';', 1)),
            (VISIBLE_CONTEXT, VISIBLE_CONTEXT + b'with Ada.Text_IO;'),
            (VISIBLE_CONTEXT, VISIBLE_CONTEXT.replace(b'use Silver_IO,', b'use type Silver_IO,')),
            (VISIBLE_CONTEXT, VISIBLE_CONTEXT.replace(b'Arguments,Silver_IO', b'Arguments Silver_IO')),
        )
        for admitted, rejected in pairs:
            with self.subTest(rejected_context=rejected):
                self.check(source.replace(ARGUMENT_CONTEXT, admitted, 1))
                self.check(source.replace(ARGUMENT_CONTEXT, rejected, 1), 2)
        static = program(b'', output(b'"ok"'))
        self.check(static)
        self.check(static.replace(b'with Silver_IO;', ARGUMENT_CONTEXT, 1), 2)
        self.check(static.replace(b'pragma SPARK_Mode(On);',
                                  b'pragma SPARK_Mode(On);use Silver_IO;'), 2)
        # Repeated context items consume source bytes, with no independent cap.
        prefix = b'with Silver_IO;use Silver_IO;'
        repeated = prefix * ((4096 - len(static)) // len(prefix)) + static
        bounded = repeated + b' ' * (4096 - len(repeated))
        self.check(bounded)
        self.check(bounded + b' ', 2)

    def test_unqualified_calls_need_their_own_use_clause(self) -> None:
        source = program(b'', output(b'Input'), arguments=True)
        for operation in (b'Silver_IO.Put_Line', b'Silver_Arguments.First_Or_Default',
                          b'Silver_Arguments.Input_Is_Valid', b'Silver_Arguments.Reject'):
            with self.subTest(operation=operation):
                unqualified = source.replace(operation, operation.split(b'.')[1])
                self.check(visible(unqualified))
                self.check(unqualified, 2)
        self.check(visible(source))  # Qualification stays legal with use visibility.
        io_only = source.replace(ARGUMENT_CONTEXT, ARGUMENT_CONTEXT + b'use Silver_IO;', 1)
        self.check(io_only.replace(b'Silver_IO.Put_Line', b'Put_Line'))
        self.check(io_only.replace(b'Silver_Arguments.Input_Is_Valid', b'Input_Is_Valid'), 2)
        args_only = source.replace(ARGUMENT_CONTEXT,
                                   ARGUMENT_CONTEXT + b'use Silver_Arguments;', 1)
        self.check(args_only.replace(b'Silver_Arguments.Reject', b'Reject'))
        self.check(args_only.replace(b'Silver_IO.Put_Line', b'Put_Line'), 2)

    def test_named_associations_preserve_actuals_and_formal_names(self) -> None:
        source = visible(program(b'Item:String:="ok";Default:String:=Item;',
                                 output(b'Item&Default'), arguments=True))
        for qualified in (True, False):
            base = source if qualified else source.replace(b'Silver_IO.', b'').replace(
                b'Silver_Arguments.', b'')
            named = base.replace(b'First_Or_Default("old")',
                                 b'First_Or_Default(dEfAuLt-- formal\n=>"old")').replace(
                                     b'Put_Line(Item&Default)', b'Put_Line(iTeM => (Item&Default))')
            with self.subTest(qualified=qualified):
                self.check(base)
                self.check(named)
                for accepted, rejected in (
                    (b'dEfAuLt-- formal\n=>"old"', b'Item=>"old"'),
                    (b'dEfAuLt-- formal\n=>"old"', b'Default=>Default'),
                    (b'dEfAuLt-- formal\n=>"old"', b'Default=>"old","new"'),
                    (b'iTeM => (Item&Default)', b'Default=>(Item&Default)'),
                    (b'iTeM => (Item&Default)', b'Item=>(Item&Default),Item=>"x"'),
                    (b'iTeM => (Item&Default)', b'Item=>(Item&Default),"x"'),
                    (b'iTeM => (Item&Default)', b'Item = > (Item&Default)'),
                    (b'iTeM => (Item&Default)', b'Item=>'),
                ):
                    with self.subTest(rejected_actual=rejected):
                        self.check(named.replace(accepted, rejected), 2)
                self.check(base.replace(b'Input_Is_Valid', b'Input_Is_Valid()'), 2)
                self.check(base.replace(b'Reject;', b'Reject();'), 2)

    def test_partial_output_uses_the_same_visibility_and_association_rules(self) -> None:
        source = program(b'Item:String:="ok";', b'Silver_IO.Put(Item);').replace(
            b'with Silver_IO;', b'with Silver_IO;use Silver_IO;', 1)
        for call in (b'Silver_IO.Put', b'Put', b'pUt'):
            named = source.replace(b'Silver_IO.Put(Item)', call + b'(iTeM => (Item))')
            with self.subTest(call=call):
                self.check(named)
                self.check(named.replace(b'iTeM => (Item)', b'Default => (Item)'), 2)
                self.check(named.replace(b'iTeM => (Item)', b'Item, Item'), 2)
        unqualified = source.replace(b'Silver_IO.Put', b'Put')
        self.check(unqualified)
        self.check(unqualified.replace(b'use Silver_IO;', b''), 2)
        local = source.replace(b'Item:String', b'pUt:String').replace(b'Put(Item)', b'Put(Put)')
        argument = visible(program(b'', b'Silver_IO.Put(Input);', arguments=True)).replace(
            b'Input:', b'pUt:').replace(b'Put(Input)', b'Put(Put)')
        for hidden in (local, argument):
            with self.subTest(hidden=hidden):
                self.check(hidden)
                self.check(hidden.replace(b'Silver_IO.Put(', b'Put('), 2)
        # These distinct operation names do not hide each other.
        self.check(source.replace(b'Item:String', b'Put_Line:String').replace(
            b'Silver_IO.Put(Item)', b'Put(Put_Line)'))
        self.check(source.replace(b'Item:String', b'Put:String').replace(
            b'Silver_IO.Put(Item)', b'Put_Line(Put)'))

    def test_local_objects_hide_operations_but_not_qualified_calls(self) -> None:
        cases = (
            (b'pUt_LiNe:String:="old";', b'Put_Line'),
            (b'iNpUt_Is_VaLiD:String:="old";', b'Input_Is_Valid'),
            (b'rEjEcT:String:="old";', b'Reject'),
        )
        for declarations, operation in cases:
            source = visible(program(declarations, output(b'Input'), arguments=True))
            qualifier = b'Silver_IO.' if operation == b'Put_Line' else b'Silver_Arguments.'
            with self.subTest(hidden_operation=operation):
                self.check(source)
                self.check(source.replace(qualifier + operation, operation), 2)
        self_named = visible(program(b'', output(b'Input'), arguments=True)).replace(
            b'Input:', b'fIrSt_Or_DeFaUlT:').replace(b'Put_Line(Input)', b'Put_Line(First_Or_Default)')
        self.check(self_named)
        self.check(self_named.replace(b'Silver_Arguments.First_Or_Default', b'First_Or_Default'), 2)
        # A declaration following Input cannot hide Input's earlier initializer.
        later_named = visible(program(b'First_Or_Default:String:="later";',
                                      output(b'Input'), arguments=True)).replace(
                                          b'Silver_Arguments.First_Or_Default', b'First_Or_Default')
        self.check(later_named)
        # Operation spelling is not reserved when it denotes an initialized object.
        declarations = (b'Put_Line:String:="old";Reject:String:="old";'
                        b'Input_Is_Valid:String:="old";First_Or_Default:String:="old";')
        body = (b'Put_Line:="new";Reject:=Put_Line;'
                b'if Input_Is_Valid="old" and then Input_Is_Valid\'Length=3 then '
                b'First_Or_Default:=Reject;end if;' + output(b'First_Or_Default'))
        self.check(visible(program(declarations, body, arguments=True)))

    def test_input_objects_hide_operations_but_not_qualified_calls(self) -> None:
        for operation in (b'Put_Line', b'Reject', b'Input_Is_Valid'):
            source = visible(program(b'', output(b'Input'), arguments=True)).replace(
                b'Input:', operation + b':').replace(b'Put_Line(Input)',
                                                    b'Put_Line(' + operation + b')')
            qualifier = b'Silver_IO.' if operation == b'Put_Line' else b'Silver_Arguments.'
            with self.subTest(input_name=operation):
                self.check(source)
                self.check(source.replace(qualifier + operation, operation), 2)

    def test_use_does_not_admit_other_library_entities_or_extra_initializers(self) -> None:
        for name in (b'Max_Length', b'Written_Bytes', b'Written_Count', b'Flushed', b'Succeeded'):
            with self.subTest(name=name):
                declared = program(name + b':String:="ok";', output(name)).replace(
                    b'with Silver_IO;', b'with Silver_IO;use Silver_IO;', 1)
                self.check(declared)
                self.check(declared.replace(name + b':String:="ok";', b''), 2)
        source = visible(program(b'', output(b'Input'), arguments=True)).replace(
            b'Silver_Arguments.First_Or_Default("old")', b'First_Or_Default(Default=>"old")')
        self.check(source)
        for admitted, rejected in (
            (b'Input:constant String:=', b'Input:String:='),
            (b'Input:constant String:=', b'Earlier:String:="x";Input:constant String:='),
            (b'begin ', b'Other:constant String:=First_Or_Default("x");begin '),
        ):
            with self.subTest(rejected_initializer=rejected):
                self.check(source.replace(admitted, rejected, 1), 2)

    def test_native_named_calls_and_local_operation_names(self) -> None:
        declarations = (b'Put_Line:String:="old";Reject:String:="old";'
                        b'Input_Is_Valid:String:="old";First_Or_Default:String:="old";'
                        b'Item:String:="!";Max_Length:String:="?";')
        body = (b'Put_Line:="new";Reject:=Put_Line;'
                b'if Input_Is_Valid="old" and then Input_Is_Valid\'Length=3 then '
                b'First_Or_Default:=Reject;end if;'
                b'Silver_IO.Put_Line(Item=>First_Or_Default&Item&Max_Length);')
        source = program(declarations, body).replace(
            b'with Silver_IO;', b'with Silver_IO,Silver_IO;use Silver_IO;with Silver_IO;', 1)
        executable, _ = self.compile(source, 'assigned')
        self.run_program(executable, b'new!?\n')

    def test_native_qualified_initializer_allows_its_own_operation_name(self) -> None:
        source = visible(program(b'', output(b'Input'), arguments=True)).replace(
            b'Input:', b'First_Or_Default:').replace(
                b'First_Or_Default("old")', b'First_Or_Default(Default=>"old")').replace(
                    b'Silver_IO.Put_Line(Input)', b'Put_Line(Item=>First_Or_Default)').replace(
                        b'Silver_Arguments.Input_Is_Valid', b'Input_Is_Valid').replace(
                            b'Silver_Arguments.Reject', b'Reject')
        executable, _ = self.compile(source, 'argument')
        self.run_program(executable, b'old\n')
        self.run_program(executable, b'custom\n', (b'custom',))
        self.run_program(executable, b'\n', (b'',))
        self.run_program(executable, b'', (b'one', b'two'), 1)


if __name__ == '__main__':
    unittest.main()
