"""Integer Image admission, interval lengths and inherited name visibility."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared
from tests.test_shared_bindings import output, program


class IntegerImageTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver integer image-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'image.adb'

    def test_scalar_expression_and_string_positions(self) -> None:
        declarations = (b'N:constant Integer:=3;'
                        b'S:String:=Integer\'Image((N * N));'
                        b'Copy:constant String:="["&S&"]";')
        body = (b'S:=Integer\'Image((-N));'
                b'if Integer\'Image(N)=" 3" then ' + output(b'Copy&S') + b'end if;')
        self.check(program(declarations, body))
        for value in (b'-2147483648', b'2147483647', b'0', b'+1', b'-1',
                      b'16#7FFF_FFFF#', b'(-(-3))'):
            with self.subTest(value=value):
                self.check(program(b'', output(b"iNtEgEr ' iMaGe (" + value + b')')))

    def test_type_visibility_and_scalar_visibility(self) -> None:
        self.check(program(b'Integer:String:="old";', output(b'Integer')))
        self.check(program(b'I:String:="old";',
                           b'for I in 1..3 loop ' + output(b"Integer'Image(I)") + b'end loop;'))
        for source in (
            program(b'Integer:String:="old";', output(b"Integer'Image(1)")),
            program(b'Integer:String:=Integer\'Image(1);', b'null;'),
            program(b'', b'for Integer in 1..3 loop ' + output(b"Integer'Image(1)") + b'end loop;'),
            program(b'S:String:="old";', output(b"Integer'Image(S)")),
            program(b'', output(b"Integer'Image(Missing)")),
            program(b'', output(b"Integer'Image(2147483648)")),
            program(b'', output(b"Integer'Image((2147483647 + 1))")),
            program(b'', output(b"Integer'Images(1)")),
            program(b'', output(b"Integer'Image 1")),
            program(b'', output(b"Integer'Image(1,2)")),
            program(b'', output(b"Integer'Image(Value=>1)")),
            program(b'', output(b"Standard.Integer'Image(1)")),
        ):
            with self.subTest(source=source):
                self.check(source, 2)

    def test_assignment_requires_both_length_endpoints(self) -> None:
        for lower, upper, width, status in ((1, 9, 2, 0), (-9, 9, 2, 0),
                                           (10, 99, 3, 0), (9, 10, 2, 2),
                                           (9, 10, 3, 2), (-10, -9, 3, 2),
                                           (-2147483648, -1000000000, 11, 0)):
            with self.subTest(lower=lower, upper=upper, width=width):
                body = (f'for I in {lower}..{upper} loop S:=Integer\'Image(I);end loop;'.encode())
                self.check(program(b'S:String:="' + b'x' * width + b'";', body), status)

    def test_empty_image_keeps_static_resource_and_target_checks(self) -> None:
        empty = b'for I in 3..1 loop '
        self.check(program(b'S:String:="x";', empty + b'S:=Integer\'Image(I);end loop;'))
        self.check(program(b'S:String:="x";', empty + b'S:="x"&Integer\'Image(I);end loop;'))
        self.check(program(b'S:String:="x";', empty + b'S:="too long"&Integer\'Image(I);end loop;'), 2)
        self.check(program(b'', empty + output(b"Integer'Image((I + 2147483647))") + b'end loop;'))
        self.check(program(b'', empty + output(b"Integer'Image((2147483647 + 1))") + b'end loop;'), 2)
        declarations = b'Long:constant String:="' + b'x' * 2100 + b'";'
        self.check(program(declarations, empty + output(b"Long&Integer'Image(I)&Long") + b'end loop;'), 2)

    def test_predicate_overlap_refines_selected_input_capacity(self) -> None:
        for comparison in (b"Input=Integer'Image(I)", b"Integer'Image(I)=Input"):
            body = (b'for I in 1..99 loop if ' + comparison + b' then '
                    + output(b'Input&Input') + b'end if;end loop;')
            self.check(program(b'', body, arguments=True))
        # Two selected-input occurrences overlap a two-to-three-byte Image only
        # at length one; the ceiling/floor bounds must not round this upward.
        body = (b'for I in 1..99 loop if Input&Input=Integer\'Image(I) then '
                + output(b'Input&Input&Input') + b'end if;end loop;')
        self.check(program(b'', body, arguments=True, capacity=2048))
        self.check(program(b'', b'for I in 1..99 loop ' + output(b"Input&Integer'Image(I)")
                           + b'end loop;', arguments=True, capacity=4093))
        self.check(program(b'', b'for I in 1..99 loop ' + output(b"Input&Integer'Image(I)")
                           + b'end loop;', arguments=True, capacity=4094), 2)

    def test_image_is_one_string_leaf_with_shared_operator_budget(self) -> None:
        image = b"Integer'Image(1)"
        self.check(program(b'', output(b'&'.join([image] * 64))))
        self.check(program(b'', output(b'&'.join([image] * 65))), 2)
        body = b'if (+N)=1 then null;end if;' * 63
        self.check(program(b'N:constant Integer:=1;', body + output(b"Integer'Image(N)")))
        self.check(program(b'N:constant Integer:=1;', body + output(b"Integer'Image((N + 1))")), 2)


if __name__ == '__main__':
    unittest.main()
