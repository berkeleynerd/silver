"""Selected scalar guard refinement, assignment flow and loop boundaries."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared
from tests.test_shared_bindings import output, program


class ScalarGuardTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check
    compile = shared.SharedBindingsTests.compile
    run_program = shared.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver scalar guards-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'guards.adb'

    def test_admission_all_comparisons_both_orders_and_outcomes(self) -> None:
        # Each arm's destination requires exactly its selected refined interval.
        cases = (
            (b'=', b'=', 0, (0, 0), (1, 9)),
            (b'/=', b'/=', 0, (1, 9), (0, 0)),
            (b'<', b'>', 9, (0, 8), (9, 9)),
            (b'<=', b'>=', 0, (0, 0), (1, 9)),
            (b'>', b'<', 0, (1, 9), (0, 0)),
            (b'>=', b'<=', 9, (9, 9), (0, 8)),
        )
        for operator, reversed_operator, threshold, yes, no in cases:
            declarations = (b'X:Integer range 0..9:=0;'
                            + f'T:Integer range {yes[0]}..{yes[1]}:={yes[0]};'.encode()
                            + f'F:Integer range {no[0]}..{no[1]}:={no[0]};'.encode())
            conditions = (b'X' + operator + str(threshold).encode(),
                          str(threshold).encode() + reversed_operator + b'X')
            for condition in conditions:
                with self.subTest(condition=condition):
                    self.check(program(declarations, b'if ' + condition
                                       + b' then T:=X;else F:=X;end if;'))

    def test_admission_endpoint_guards_and_negation(self) -> None:
        for condition, update in (
            (b'X<2147483647', b'X:=(X + 1);'),
            (b'2147483647>X', b'X:=(X + 1);'),
            (b'X>(-2147483648)', b'X:=(-X);'),
            (b'not (X=(-2147483648))', b'X:=(-X);'),
        ):
            self.check(program(b'X:Integer:=0;', b'if ' + condition + b' then ' + update + b'end if;'))
        declarations = b'X:Integer range 0..9:=0;'
        self.check(program(declarations, b'if not (X=9) then X:=(X + 1);end if;'))
        self.check(program(declarations, b'if (X<9) then X:=(X + 1);end if;'))
        self.check(program(declarations, b'if X>=9 then null;else X:=(X + 1);end if;'))

    def test_admission_bare_targets_and_static_thresholds_only(self) -> None:
        declarations = b'X:Integer range 0..9:=0;A:Integer range 0..9:=9;'
        self.check(program(declarations + b'K:constant Integer:=(8 + 1);',
                           b'if X<K then X:=(X + 1);end if;'))
        for condition in (b'(X)<9', b'((X))<9', b'(X + 0)<9', b'X<A'):
            self.check(program(declarations, b'if ' + condition + b' then X:=(X + 1);end if;'), 2)
        self.check(program(declarations + b'K:constant Integer:=A;',
                           b'if X<K then X:=(X + 1);end if;'), 2)
        self.check(program(declarations, b'A:=9;if X<A then X:=(X + 1);end if;'), 2)
        self.check(program(declarations, b'for T in 9..9 loop if X<T then X:=(X + 1);end if;end loop;'), 2)

    def test_admission_refinement_uses_binding_identity(self) -> None:
        declarations = b'X:Integer range 0..9:=0;Y:Integer range 0..9:=0;'
        self.check(program(declarations, b'if x-- same resolved identifier\n<9 then X:=(x + 1);end if;'))
        self.check(program(declarations, b'if X<9 then Y:=(Y + 1);end if;'), 2)
        self.check(program(declarations, b'if Y<9 then X:=(X + 1);end if;'), 2)
        # An appended index hides the declaration without sharing its identity.
        declarations += b'R:Integer range 0..8:=0;'
        self.check(program(declarations, b'for X in 0..9 loop if X<9 then R:=X;end if;end loop;'))
        self.check(program(declarations, b'for X in 0..9 loop if X<9 then R:=Y;end if;end loop;'), 2)

    def test_admission_both_operands_checked_before_refinement(self) -> None:
        declarations = b'X:Integer range 0..9:=0;'
        for condition in (b'X<(2147483647 + 1)', b'(2147483647 + 1)>X',
                          b'X=(1 / 0)', b'(1 / 0)=X', b'(X + 2147483647)<0'):
            self.check(program(declarations, b'if ' + condition + b' then null;end if;'), 2)
        self.check(program(declarations,
                           b'if X<0 then if (2147483647 + 1)=0 then null;end if;end if;'), 2)

    def test_admission_contradictions_keep_incoming_and_empty_index(self) -> None:
        declarations = b'X:Integer range 0..0:=0;'
        self.check(program(declarations, b'if X>0 then X:=X;else X:=X;end if;'))
        self.check(program(declarations,
                           b'if X>0 then if (1 / X)=0 then null;end if;end if;'), 2)
        self.check(program(b'X:Integer range 0..9:=0;',
                           b'for I in 2..1 loop if I=0 then X:=I;end if;end loop;'), 2)
        self.check(program(b'', b'for I in 2..1 loop if I=0 then '
                           b'if (I + 2147483647)=0 then null;end if;end if;end loop;'))

    def test_admission_nonzero_hulls_and_division_sign_arms(self) -> None:
        for operator in (b'/', b'mod', b'rem'):
            expression = b'(7 ' + operator + b' X)'
            for lower, upper, initial in ((0, 9, 0), (-9, 0, 0)):
                declarations = f'X:Integer range {lower}..{upper}:={initial};'.encode()
                self.check(program(declarations, b'if X/=0 then if ' + expression
                                   + b'=0 then null;end if;end if;'))
            declarations = b'X:Integer range -9..9:=0;'
            self.check(program(declarations, b'if X/=0 then if ' + expression
                               + b'=0 then null;end if;end if;'), 2)
            self.check(program(declarations, b'if X>0 then if ' + expression
                               + b'=0 then null;end if;elsif X<0 then if ' + expression
                               + b'=0 then null;end if;end if;'))
        self.check(program(b'X:Integer:=0;',
                           b'if X/=(-2147483648) then if (X / (-1))=0 then null;end if;end if;'))

    def test_admission_short_circuit_reached_flows(self) -> None:
        declarations = b'X:Integer range 0..9:=0;'
        self.check(program(declarations, b'if X=0 or else (7 / X)>0 then null;end if;'))
        self.check(program(declarations, b'if X/=0 and then (7 / X)>0 then null;end if;'))
        self.check(program(declarations, b'if X=0 and then (7 / X)>0 then null;end if;'), 2)
        self.check(program(declarations, b'if X/=0 or else (7 / X)>0 then null;end if;'), 2)
        self.check(program(b'X:Integer:=0;',
                           b'if X<2147483647 and then (X + 1)>0 then null;end if;'))
        # Every accepted true alternative fits the same destination hull.
        declarations = b'X:Integer range 0..2:=0;R:Integer range 0..1:=0;'
        self.check(program(declarations, b'if X=0 or else X=1 then R:=X;end if;'))
        self.check(program(declarations, b'if X=0 or else X=2 then R:=X;end if;'), 2)

    def test_admission_assignment_replaces_only_written_identity(self) -> None:
        declarations = b'X:Integer range 0..9:=0;Y:Integer range 0..9:=0;'
        self.check(program(declarations, b'X:=0;X:=(X + 1);'))
        self.check(program(declarations, b'if X<9 then Y:=9;X:=(X + 1);end if;'))
        self.check(program(declarations, b'if X=0 then X:=9;X:=(X + 1);end if;'), 2)
        self.check(program(declarations, b'X:=0;X:=Y;X:=(X + 1);'), 2)
        self.check(program(declarations, b'if X=0 then X:=10;end if;'), 2)

    def test_admission_branch_joins_elsif_and_omitted_else(self) -> None:
        declarations = b'X:Integer range 0..9:=0;R:Integer range 1..2:=1;'
        self.check(program(declarations, b'if X=0 then X:=1;else X:=2;end if;R:=X;'))
        self.check(program(declarations, b'if X=0 then X:=1;elsif X=1 then X:=2;else X:=1;end if;R:=X;'))
        self.check(program(declarations, b'if X=0 then X:=1;end if;R:=X;'), 2)
        self.check(program(declarations, b'if X=0 then null;elsif X<9 then X:=(X + 1);end if;'))
        self.check(program(declarations, b'if X<9 then null;end if;X:=(X + 1);'), 2)

    def test_admission_image_reads_and_string_writes_use_scalar_flow(self) -> None:
        declarations = b'X:Integer range 9..10:=9;S:String:="xx";'
        self.check(program(declarations, b'if X<10 then S:=Integer\'Image(X);end if;'))
        self.check(program(declarations, b'X:=9;S:=Integer\'Image(X);'))
        self.check(program(declarations, b'X:=10;S:=Integer\'Image(X);'), 2)
        self.check(program(declarations, b'if X<10 and then Integer\'Image(X)=S then null;end if;'))
        self.check(program(declarations, b'if X=10 or else Integer\'Image(X)=S then null;end if;'))
        self.check(program(declarations, b'if X<10 then S:="yy";S:=Integer\'Image(X);end if;'))
        snapshots = b'X:Integer range 0..9:=7;K:constant Integer:=X;S:String:=Integer\'Image(X);'
        self.check(program(snapshots, b'X:=9;if K=7 then S:=Integer\'Image(K);end if;'))

    def test_admission_input_length_facts_survive_scalar_write(self) -> None:
        declarations = b'X:Integer range 9..10:=9;S:String:="xx";'
        body = b'X:=9;if Input=Integer\'Image(X) then X:=10;S:=Input;end if;'
        self.check(program(declarations, body, arguments=True))
        # Input retains its old length, while a live Image sees the new value.
        body = b'X:=9;if Input=Integer\'Image(X) then X:=10;S:=Integer\'Image(X);end if;'
        self.check(program(declarations, body, arguments=True), 2)
        body = b'X:=9;if Input=Integer\'Image(X) then X:=10;' + output(b'Input&Integer\'Image(X)') + b'end if;'
        self.check(program(declarations, body, arguments=True))

    def test_admission_loop_bounds_captured_before_widening(self) -> None:
        declarations = b'X:Integer range 0..9:=0;R:Integer range 1..1:=1;'
        self.check(program(declarations, b'X:=1;for I in 1..X loop X:=9;R:=I;end loop;'))
        self.check(program(declarations, b'if X=1 then for I in 1..X loop R:=I;end loop;end if;'))
        self.check(program(declarations, b'X:=1;for I in 1..X loop R:=I;end loop;R:=X;'), 2)

    def test_admission_loop_mutables_widen_at_entry_and_exit(self) -> None:
        declarations = b'X:Integer range 0..9:=0;N:Integer range 0..9:=0;'
        self.check(program(declarations, b'X:=0;for I in 1..2 loop X:=(X + 1);end loop;'), 2)
        self.check(program(declarations, b'X:=0;for I in 1..2 loop if X<9 then X:=(X + 1);end if;end loop;'))
        for bounds in (b'1..1', b'1..N'):
            self.check(program(declarations, b'X:=0;for I in ' + bounds + b' loop null;end loop;X:=(X + 1);'), 2)
        self.check(program(declarations, b'X:=0;for I in 2..1 loop X:=9;end loop;X:=(X + 1);'))
        self.check(program(declarations, b'if X<9 then for I in 1..2 loop X:=(X + 1);end loop;end if;'), 2)

    def test_admission_outer_index_facts_restored_and_inner_facts_discarded(self) -> None:
        self.check(program(b'', b'for I in 0..2147483647 loop if I<9 then '
                           b'for J in 1..1 loop if (I + 1)>0 then null;end if;end loop;'
                           b'if (I + 1)>0 then null;end if;end if;end loop;'))
        self.check(program(b'', b'for I in 0..2147483647 loop '
                           b'for J in 1..1 loop if I<9 then null;end if;end loop;'
                           b'if (I + 1)>0 then null;end if;end loop;'), 2)
        self.check(program(b'X:Integer range 0..9:=0;',
                           b'for I in 0..9 loop if I<9 then '
                           b'for I in 9..9 loop X:=I;end loop;X:=(I + 1);end if;end loop;'))

    def test_admission_precise_bounds_reveal_excluded_empty_assignment(self) -> None:
        # Deliberate current-language change: captured X=0 makes I empty.
        # The retained nonempty assignment-RHS rule still applies in dead loops.
        declarations = b'X:Integer range 0..9:=0;R:Integer range 1..9:=1;'
        self.check(program(declarations, b'for I in 1..X loop R:=I;end loop;'))
        self.check(program(declarations, b'X:=0;for I in 1..X loop R:=I;end loop;'), 2)
        self.check(program(declarations, b'if X=0 then for I in 1..X loop R:=I;end loop;end if;'), 2)

    def test_admission_exact_source_limit_with_active_scalar_counts(self) -> None:
        for count in (0, 1, 32):
            declarations = b''.join(f'X{index}:Integer:=0;'.encode() for index in range(count))
            predicate = b'X0=0' if count else b'0=0'
            fixed = program(declarations, b'if ' + predicate + b' then null;end if;')
            depth = (4096 - len(fixed)) // 2
            source = program(declarations, b'if ' + b'(' * depth + predicate
                             + b')' * depth + b' then null;end if;')
            source += b' ' * (4096 - len(source))
            with self.subTest(count=count, depth=depth):
                self.assertEqual(len(source), 4096)
                self.check(source)
                self.check(source + b' ', 2)

    def test_admission_long_boolean_and_statement_tails(self) -> None:
        declarations = b'X:Integer range 0..9:=0;'
        # These source-bounded tails must not keep one flow vector per item.
        predicate = b' and then '.join([b'X=0'] * 250)
        self.check(program(declarations, b'if ' + predicate + b' then null;end if;'))
        self.check(program(declarations, b'X:=0;' + b'null;' * 700 + b'X:=(X + 1);'))

    def test_native_guarded_updates_division_and_captured_bounds(self) -> None:
        declarations = (b'X:Integer range 0..9:=9;D:Integer range -9..9:=0;'
                        b'N:Integer range 1..3:=3;R:Integer range 0..3:=0;')
        body = (b'if X<9 then X:=(X + 1);elsif X=9 then X:=0;end if;'
                + output(b"Integer'Image(X)")
                + b'D:=(-3);if D>0 then ' + output(b"Integer'Image((7 / D))")
                + b'elsif D<0 then ' + output(b"Integer'Image((7 / D))") + b'end if;'
                + b'for I in 1..N loop N:=1;R:=I;end loop;'
                + output(b"Integer'Image(R)&Integer'Image(N)"))
        executable, report = self.compile(program(declarations, body), 'static')
        self.run_program(executable, b' 0\n-2\n 3 1\n')
        self.assertTrue(report['proof'])

    def test_native_complete_100_doors(self) -> None:
        declarations = b'Visits:Integer range 0..100:=0;'
        body = (b'for Door in 1..100 loop Visits:=0;for Pass in 1..100 loop '
                b'if (Door mod Pass)=0 then if Visits<100 then Visits:=(Visits + 1);end if;end if;'
                b'end loop;if (Visits mod 2)=1 then '
                + output(b"Integer'Image(Door)&\": open\"") + b'else '
                + output(b"Integer'Image(Door)&\": closed\"") + b'end if;end loop;')
        # Independent pass-major toggle model, not another visit-count model.
        opened = [False] * 101
        for step in range(1, 101):
            for door in range(step, 101, step):
                opened[door] = not opened[door]
        expected = b''.join(f' {door}: {"open" if opened[door] else "closed"}\n'.encode()
                            for door in range(1, 101))
        executable, _ = self.compile(program(declarations, body), 'static')
        self.run_program(executable, expected)


if __name__ == '__main__':
    unittest.main()
