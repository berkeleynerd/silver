"""Counted bounds exclude direct constant-array reads while preserving alternatives."""
from __future__ import annotations

from pathlib import Path
import subprocess
import tempfile
import unittest

from tests import test_shared_bindings as shared
from tests.test_silver import HOST, SILVER


class CountedBoundReviewTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check
    compile = shared.SharedBindingsTests.compile
    run_program = shared.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix="silver-counted-bound-")
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / "counted.adb"

    def test_constant_array_components_are_excluded_at_both_counted_bounds(self) -> None:
        declarations = b'A:constant array(1..2)of Integer:=(5,6);'
        for expression in (b'A(1)', b'(A(1))', b'(A(1)+0)', b'((A(1)*0)+1)', b'(A(1) mod 2)'):
            for bounds in (expression + b'..9', b'0..' + expression):
                for direction in (b'', b'reverse '):
                    with self.subTest(expression=expression, bounds=bounds, direction=direction):
                        self.check(shared.program(declarations,
                            b'for I in ' + direction + bounds + b' loop null;end loop;'), 2)
        # The one-element association follows the producer's other failing route.
        self.check(shared.program(b'A:constant array(1..1)of Integer:=(1=>5);',
            b'for I in A(1)..A(1) loop null;end loop;'), 2)

    def test_scalar_snapshots_and_constant_foreach_keep_the_full_route(self) -> None:
        source = shared.program(
            b'A:constant array(1..2)of Integer:=(5,6);'
            b'Lo:constant Integer:=A(1);Hi:constant Integer:=A(2);',
            b'for I in Lo..Hi loop ' + shared.output(b"Integer'Image(I)") + b'end loop;'
            b'for V of A loop ' + shared.output(b"Integer'Image(V)") + b'end loop;')
        self.check(source)
        executable, _ = self.compile(source, "static")
        self.run_program(executable, b" 5\n 6\n 5\n 6\n")

    def test_mutable_array_bounds_keep_original_offsets_and_full_route(self) -> None:
        source = shared.program(
            b'Before:constant array(1..1)of Integer:=(1=>9);'
            b'Bounds:array(5..6)of Integer:=(1,2);'
            b'Between:constant array(1..2)of Integer:=(7,8);'
            b'Last:array(7..8)of Integer:=(2,3);',
            b'for I in Bounds(5)..Bounds(6) loop ' + shared.output(b"Integer'Image(I)") + b'end loop;'
            b'for J in reverse Last(7)..Last(8) loop ' + shared.output(b"Integer'Image(J)") + b'end loop;'
            + shared.output(b"Integer'Image(Before(1))&Integer'Image(Between(2))"))
        self.check(source)
        executable, _ = self.compile(source, "static")
        self.run_program(executable, b" 1\n 2\n 3\n 2\n 9 8\n")

    @unittest.skipUnless(HOST.key == "linux-x86_64", "8 MiB stack evidence is native Linux x86-64")
    def test_maximal_nested_loops_keep_filter_scratch_out_of_frames(self) -> None:
        import resource

        declarations = (b'K:constant array(1..1)of Integer:=(1=>9);'
                        b'A:array(1..2)of Integer:=(0,0);')
        depth = 0
        source = b''
        while True:
            candidate = shared.program(declarations,
                b'for I in 1..1 loop ' * (depth + 1) + b'A(1):=I;' + b'end loop;' * (depth + 1))
            if len(candidate) > 4096:
                break
            source = candidate
            depth += 1
        self.assertGreaterEqual(depth, 140)
        source += b' ' * (4096 - len(source))
        self.source.write_bytes(source)

        def stack_limit() -> None:
            resource.setrlimit(resource.RLIMIT_STACK, (8 * 1024 * 1024, 8 * 1024 * 1024))

        result = subprocess.run([str(SILVER), 'check', str(self.source)], text=True,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=20, preexec_fn=stack_limit)
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertEqual(self.source.read_bytes(), source)


if __name__ == "__main__":
    unittest.main()
