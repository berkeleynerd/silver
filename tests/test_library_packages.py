"""Original three-unit package programs, state effects and nearby rejected forms."""
from __future__ import annotations

from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

from scripts.check_evidence import audit_reports
from tests.test_silver import HOST, ROOT, invoke

SPEC = (b'package P is pragma SPARK_Mode(On);'
        b'subtype Small is Integer range 0..9;'
        b'procedure Reset;procedure Increment;function Read return Small;end P;')
BODY = (b'package body P is pragma SPARK_Mode(On);Stored:Small:=0;'
        b'procedure Reset is begin Stored:=0;end Reset;'
        b'procedure Increment is begin if Stored<9 then Stored:=(Stored+1);end if;end Increment;'
        b'function Read return Small is begin return Stored;end Read;end P;')


def main(declarations: bytes = b'', statements: bytes = b'null;') -> bytes:
    return (b'with P,Silver_IO;procedure Main is pragma SPARK_Mode(On);'
            + declarations + b'begin ' + statements + b'end Main;')


class LibraryPackageTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver package sources-')
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name).resolve()
        self.source = self.directory / 'application.adb'
        self.specification = self.directory / 'p.ads'
        self.body = self.directory / 'p.adb'

    def write(self, source: bytes, specification: bytes = SPEC, body: bytes = BODY) -> None:
        self.source.write_bytes(source)
        self.specification.write_bytes(specification)
        self.body.write_bytes(body)

    def check(self, source: bytes, expected: int = 0, *,
              specification: bytes = SPEC, body: bytes = BODY) -> None:
        self.write(source, specification, body)
        before = set(HOST.artifacts.glob('program-*'))
        result = invoke('check', self.source)
        self.assertEqual(result.returncode, expected, result.stdout)
        self.assertEqual(self.source.read_bytes(), source)
        self.assertEqual(self.specification.read_bytes(), specification)
        self.assertEqual(self.body.read_bytes(), body)
        self.assertEqual(set(HOST.artifacts.glob('program-*')), before)

    def compile(self, source: bytes, *, specification: bytes = SPEC,
                body: bytes = BODY, expected: bytes = b'', kind: str = 'assigned',
                package: dict | None = None) -> Path:
        self.write(source, specification, body)
        result = invoke('compile', self.source)
        self.assertEqual(result.returncode, 0, result.stdout)
        matched = re.search(r'^Executable: (.+)$', result.stdout, re.MULTILINE)
        self.assertIsNotNone(matched, result.stdout)
        executable = Path(matched.group(1))
        if not executable.is_absolute():
            executable = ROOT / executable
        workspace = executable.parent.parent
        self.addCleanup(shutil.rmtree, workspace)
        for name, data in (('main.adb', source), ('p.ads', specification), ('p.adb', body)):
            self.assertEqual((workspace / name).read_bytes(), data)
        project = (workspace / 'program.gpr').read_text()
        self.assertIn('"p.ads"', project)
        self.assertIn('"p.adb"', project)
        reports = list(workspace.rglob('gnatprove.sarif'))
        self.assertEqual(len(reports), 1)
        if package is None:
            package = {'name': 'P', 'functions': ('Read',),
                       'procedures': {'Reset': (), 'Increment': ()},
                       'formals': {'Reset': (), 'Increment': (), 'Read': ()},
                       'states': ('Stored',),
                       'writes': {'Reset': ('Stored',), 'Increment': ('Stored',)},
                       'assigned': True}
        statistics = audit_reports(
            reports[0].parent,
            {'main', 'p', 'silver_io', 'silver_output_libc', 'silver_arguments', 'silver_runtime'},
            {'silver_output_libc', 'silver_runtime'}, application_kind=kind,
            indexed_main=True, application_package=package, indexed_packages=True)
        self.assertEqual(statistics['units'], 6)
        execution = subprocess.run([str(executable)], capture_output=True, timeout=10)
        self.assertEqual(execution.returncode, 0, execution.stderr)
        self.assertEqual(execution.stdout, expected)
        self.assertEqual(execution.stderr, b'')
        self.assertEqual(self.source.read_bytes(), source)
        self.assertEqual(self.specification.read_bytes(), specification)
        self.assertEqual(self.body.read_bytes(), body)
        return workspace

    def test_stateful_zero_formal_operations_preserve_original_units(self) -> None:
        self.compile(main(b'X:P.Small:=0;',
                          b'P.Reset;for I in 1..12 loop P.Increment;end loop;'
                          b"X:=P.Read;Silver_IO.Put_Line(Integer'Image(X));"), expected=b' 9\n')

    def test_unused_routines_and_package_state_remain_in_complete_audit(self) -> None:
        self.compile(main(), kind='static')

    def test_packages_compose_with_arguments_arrays_and_guarded_output(self) -> None:
        source = (b'with P,Silver_IO,Silver_Arguments;'
                  b'procedure Main is pragma SPARK_Mode(On);'
                  b'Name:constant String:=Silver_Arguments.First_Or_Default("ok");'
                  b'Values:constant array(1..2)of Integer:=(1,2);X:P.Small:=0;'
                  b"begin if Silver_Arguments.Input_Is_Valid and then Name'Length<=4 then "
                  b'P.Reset;for Value of Values loop P.Increment;end loop;'
                  b"X:=P.Read;Silver_IO.Put_Line(Name&Integer'Image(X));"
                  b'else Silver_Arguments.Reject;end if;end Main;')
        workspace = self.compile(source, kind='selected', expected=b'ok 2\n')
        for arguments, status, output in ((['hi'], 0, b'hi 2\n'),
                                           (['too long'], 1, b''),
                                           (['one', 'two'], 1, b'')):
            with self.subTest(arguments=arguments):
                execution = subprocess.run([str(workspace / 'bin/main'), *arguments],
                                           capture_output=True, timeout=10)
                self.assertEqual(execution.returncode, status, execution.stderr)
                self.assertEqual(execution.stdout, output)
                self.assertEqual(execution.stderr, b'')

    def test_package_only_context_does_not_require_an_unused_io_import(self) -> None:
        self.check(main(statements=b'P.Reset;').replace(b'with P,Silver_IO;', b'with P;'))
        self.check(main().replace(b'with P,Silver_IO;', b'with p;with P;with Silver_IO;'))

    def test_package_body_requires_an_exported_routine(self) -> None:
        specification = b'package P is pragma SPARK_Mode(On);N:constant Integer:=1;end P;'
        body = b'package body P is pragma SPARK_Mode(On);Stored:Integer:=0;end P;'
        self.check(main(), 2, specification=specification, body=body)
        self.check(main(), specification=specification.replace(b'end P;', b'procedure Noop;end P;'),
                   body=body.replace(b'end P;', b'procedure Noop is begin null;end Noop;end P;'))

    def test_public_constants_and_subtypes_are_qualified_in_main(self) -> None:
        specification = SPEC.replace(b'procedure Reset;',
                                     b'N:constant Integer:=3;Good:constant Boolean:=True;procedure Reset;')
        self.check(main(b'N:Integer:=2;X:P.Small:=P.N;Good:Boolean:=P.Good;',
                        b'if Good then X:=N;end if;'), specification=specification)
        self.check(main(b'X:Small:=0;'), 2)
        self.check(main(b'X:Integer:=P.Stored;'), 2)
        self.check(main(b'P:Integer:=0;'), 2)
        self.check(main(b'X:Integer:=0;', b'P.N:=X;'), 2, specification=specification)

    def test_zero_formal_operations_use_ada_syntax(self) -> None:
        for statements in (b'P.Reset();', b'X:=P.Read();', b'P.Read;', b'X:=P.Reset;'):
            with self.subTest(statements=statements):
                self.check(main(b'X:P.Small:=0;', statements), 2)

    def test_spec_body_signatures_match_in_order_and_full_identity(self) -> None:
        specification = (b'package P is pragma SPARK_Mode(On);'
                         b'procedure Copy(X:in Integer;Y:out Integer);end P;')
        body = (b'package body P is pragma SPARK_Mode(On);'
                b'procedure Copy(X:in Integer;Y:out Integer)is begin Y:=X;end Copy;end P;')
        self.check(main(b'Y:Integer:=0;', b'P.Copy(Y=>Y,X=>3);'),
                   specification=specification, body=body)
        for changed in (body.replace(b'X:in', b'Z:in'),
                        body.replace(b'Y:out', b'Y:in out'),
                        body.replace(b'X:in Integer', b'X:in Boolean'),
                        body.replace(b'end P;', b'procedure Extra is begin null;end Extra;end P;')):
            with self.subTest(body=changed):
                self.check(main(), 2, specification=specification, body=changed)
        self.check(main(), 2, body=BODY.replace(b'end P;', b'end Q;'))
        self.check(main(), 2, specification=SPEC.replace(b'package P', b'package Q'))
        self.check(main(), 2, specification=SPEC.replace(
            b'procedure Reset;procedure Increment;', b'procedure Increment;procedure Reset;'))

    def test_every_routine_is_checked_over_declared_state_and_formal_domains(self) -> None:
        self.check(main(), 2, body=BODY.replace(
            b'if Stored<9 then Stored:=(Stored+1);end if;', b'Stored:=(Stored+1);'))
        specification = (b'package P is pragma SPARK_Mode(On);'
                         b'function Bad(X:in Integer)return Integer;end P;')
        body = (b'package body P is pragma SPARK_Mode(On);'
                b'function Bad(X:in Integer)return Integer is begin return (X+1);end Bad;end P;')
        self.check(main(), 2, specification=specification, body=body)

    def test_writing_calls_invalidate_prior_state_guards(self) -> None:
        specification = SPEC.replace(b'function Read', b'procedure Twice;function Read')
        prefix = b'procedure Twice is begin if Stored<9 then Increment;'
        suffix = b'end if;end Twice;'
        safe = prefix + b'if Stored<9 then Stored:=(Stored+1);end if;' + suffix
        unsafe = prefix + b'Stored:=(Stored+1);' + suffix
        self.check(main(), specification=specification,
                   body=BODY.replace(b'function Read', safe + b'function Read'))
        self.check(main(), 2, specification=specification,
                   body=BODY.replace(b'function Read', unsafe + b'function Read'))

    def test_captures_are_bound_before_local_initializers(self) -> None:
        body = BODY.replace(b'function Read return Small is begin return Stored;',
                            b'function Read return Small is Saved:Small:=Stored;begin return Saved;')
        self.compile(main(b'X:P.Small:=0;',
                          b"P.Increment;P.Increment;X:=P.Read;Silver_IO.Put_Line(Integer'Image(X));"),
                     body=body, expected=b' 2\n')

    def test_explicit_actuals_cannot_alias_implicit_writable_state(self) -> None:
        specification = (b'package P is pragma SPARK_Mode(On);'
                         b'subtype Small is Integer range 0..9;'
                         b'procedure Set_Both(X:in out Small);procedure Call;end P;')
        body = (b'package body P is pragma SPARK_Mode(On);Stored:Small:=0;'
                b'procedure Set_Both(X:in out Small)is begin Stored:=0;X:=0;end Set_Both;'
                b'procedure Call is Local:Small:=0;begin Set_Both(Local);end Call;end P;')
        self.check(main(), specification=specification, body=body)
        self.check(main(), 2, specification=specification,
                   body=body.replace(b'Set_Both(Local)', b'Set_Both(Stored)'))

    def test_function_cannot_write_hidden_state(self) -> None:
        self.check(main(), 2, body=BODY.replace(b'begin return Stored;end Read;',
                                               b'begin Stored:=0;return Stored;end Read;'))

    def test_output_prefix_cannot_read_an_earlier_output_formal(self) -> None:
        specification = (b'package P is pragma SPARK_Mode(On);'
                         b'procedure Copy(A:out Integer;B:out Integer);end P;')
        body = (b'package body P is pragma SPARK_Mode(On);'
                b'procedure Copy(A:out Integer;B:out Integer)is '
                b'begin A:=1;B:=2;end Copy;end P;')
        self.check(main(), specification=specification, body=body)
        self.check(main(), 2, specification=specification,
                   body=body.replace(b'B:=2;', b'B:=A;'))

    def test_function_cannot_call_even_a_stateless_package_procedure(self) -> None:
        specification = (b'package P is pragma SPARK_Mode(On);'
                         b'procedure Noop;function Read return Integer;end P;')
        body = (b'package body P is pragma SPARK_Mode(On);'
                b'procedure Noop is begin null;end Noop;'
                b'function Read return Integer is begin return 1;end Read;end P;')
        self.check(main(), specification=specification, body=body)
        for statement in (b'Noop;', b'if False then Noop;end if;',
                          b'for I in 2..1 loop Noop;end loop;'):
            with self.subTest(statement=statement):
                self.check(main(), 2, specification=specification,
                           body=body.replace(b'begin return 1;', b'begin '+statement+b'return 1;'))

    def test_package_function_calls_require_a_whole_assignment_rhs(self) -> None:
        specification = (b'package P is pragma SPARK_Mode(On);'
                         b'function First return Integer;'
                         b'function Second return Integer;end P;')
        body = (b'package body P is pragma SPARK_Mode(On);'
                b'function First return Integer is begin return 1;end First;'
                b'function Second return Integer is X:Integer:=0;'
                b'begin X:=First;return X;end Second;end P;')
        self.check(main(), specification=specification, body=body)
        self.check(main(), 2, specification=specification,
                   body=body.replace(b'X:=First;return X;', b'return First;'))
        self.check(main(), 2, specification=specification,
                   body=body.replace(b'X:Integer:=0;', b'X:Integer:=First;'))
        self.check(main(), 2, specification=specification,
                   body=body.replace(b'X:=First;', b'X:=(First+1);'))

    def test_forward_and_recursive_calls_are_rejected_even_in_dead_code(self) -> None:
        for call in (b'Increment;', b'Reset;', b'if False then Increment;end if;',
                     b'for I in 2..1 loop Reset;end loop;'):
            with self.subTest(call=call):
                self.check(main(), 2, body=BODY.replace(b'Stored:=0;end Reset;', call+b'end Reset;'))

    def test_main_local_closed_routines_cannot_capture_the_package(self) -> None:
        declarations = (b'function Local(X:in Integer)return Integer is '
                        b'begin return P.Read;end Local;')
        self.check(main(declarations), 2)
        declarations = (b'procedure Local(X:out Integer)is '
                        b'begin P.Reset;X:=0;end Local;')
        self.check(main(declarations), 2)
        specification = SPEC.replace(b'procedure Reset;', b'Limit:constant Integer:=3;procedure Reset;')
        self.check(main(b'function Local(X:in Integer)return Integer is '
                        b'begin return P.Limit;end Local;'), 2, specification=specification)
        self.check(main(b'function Local(X:in P.Small)return P.Small is '
                        b'begin return X;end Local;'))

    def test_private_boolean_state_and_earlier_state_initialization(self) -> None:
        specification = (b'package P is pragma SPARK_Mode(On);'
                         b'procedure Flip;function Ready return Boolean;end P;')
        body = (b'package body P is pragma SPARK_Mode(On);'
                b'First:Boolean:=False;Flag:Boolean:=First;'
                b'procedure Flip is begin Flag:=not Flag;end Flip;'
                b'function Ready return Boolean is begin return Flag;end Ready;end P;')
        self.check(main(b'Good:Boolean:=False;', b'P.Flip;Good:=P.Ready;'),
                   specification=specification, body=body)
        self.check(main(), 2, specification=specification,
                   body=body.replace(b'First:Boolean:=False;', b'First:Boolean:=Flag;'))

    def test_private_state_initialization_is_exact_and_in_declared_bounds(self) -> None:
        for declaration in (b'Stored:Small;', b'Stored:Small:=10;',
                            b'Stored:Small:=Read;', b'Stored:Small:=Stored;'):
            with self.subTest(declaration=declaration):
                self.check(main(), 2, body=BODY.replace(b'Stored:Small:=0;', declaration))
        self.check(main(), 2, body=BODY.replace(b'end P;', b'begin null;end P;'))

    def test_byte_budget_is_shared_by_the_three_original_files(self) -> None:
        source = main()
        remaining = 4096 - len(source) - len(SPEC) - len(BODY)
        self.check(source, specification=SPEC+b' ' * remaining)
        self.check(source, 2, specification=SPEC+b' ' * (remaining+1))

    def test_operator_budget_counts_each_original_lexical_unit(self) -> None:
        specification = (b'package P is pragma SPARK_Mode(On);N:constant Integer:='
                         + b'('*31+b'0'+b'+0)'*31+b';function Read return Integer;end P;-- EOF +++++')
        body = (b'package body P is pragma SPARK_Mode(On);Stored:Integer:='
                +b'('*32+b'0'+b'+0)'*32+b';function Read return Integer is begin return Stored;end Read;end P;')
        self.check(main(), specification=specification, body=body)
        self.check(main(), 2, specification=specification,
                   body=body.replace(b':='+b'('*32+b'0'+b'+0)'*32,
                                     b':='+b'('*33+b'0'+b'+0)'*33))

    def test_case_and_cr_comments_preserve_the_native_route(self) -> None:
        # Each independent EOF terminates comments; GPR's explicit unit indices
        # must also prevent its LF-only scanner from losing a CR-delimited unit.
        self.compile(b'-- prefix\r'+main(b'X:p.SMALL:=0;',
                     b"p.RESET;p.INCREMENT;X:=p.READ;Silver_IO.Put_Line(Integer'Image(X));")+b'-- eof',
                     specification=b'-- prefix\r'+SPEC+b'-- specification eof',
                     body=b'-- prefix\r'+BODY+b'-- body eof', expected=b' 1\n')

    def test_missing_source_is_an_input_error_without_a_build_workspace(self) -> None:
        self.write(main())
        before = set(HOST.artifacts.glob('program-*'))
        self.specification.unlink()
        result = invoke('check', self.source)
        self.assertEqual(result.returncode, 3, result.stdout)
        self.specification.write_bytes(SPEC)
        self.body.unlink()
        result = invoke('check', self.source)
        self.assertEqual(result.returncode, 3, result.stdout)
        self.assertEqual(set(HOST.artifacts.glob('program-*')), before)

    def test_extra_dependencies_private_parts_and_nested_packages_are_excluded(self) -> None:
        cases = (
            (main().replace(b'with P,', b'with P,Q,'), SPEC, BODY),
            (main().replace(b'procedure Main', b'use P;procedure Main'), SPEC, BODY),
            (main(), SPEC.replace(b'end P;', b'private X:Integer:=0;end P;'), BODY),
            (main(), SPEC, BODY.replace(b'Stored:Small:=0;', b'package N is end N;Stored:Small:=0;')),
            (main(), SPEC, BODY.replace(b'Stored:Small:=0;', b'A:array(1..1)of Integer:=(1=>0);Stored:Small:=0;')),
        )
        for source, specification, body in cases:
            with self.subTest(source=source, specification=specification, body=body):
                self.check(source, 2, specification=specification, body=body)
