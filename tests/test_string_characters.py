"""Fixed String bounds, Character values and source-preserving mutation."""
from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tests import test_shared_bindings as shared

program = shared.program
output = shared.output


class StringCharacterTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check
    check_full_route = shared.SharedBindingsTests.check_full_route
    compile = shared.SharedBindingsTests.compile
    run_program = shared.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver string characters-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'characters.adb'

    def test_admission_character_literals_copies_and_types(self) -> None:
        declarations = b''.join(
            f"C{i}:Character:='{chr(i)}';".encode() for i in range(32, 127))
        self.check(program(declarations, b'C32:=C126;'))
        declarations = b"S:String:=\"abc\";C:Character:='a';D:constant Character:=(C);"
        self.check(program(declarations, b"C:=S(1);S(2):=D;if C<D then C:='z';end if;"))
        for declarations, body in (
            (b'C:Character;', b'null;'),
            (b"C:Character:=C;", b'null;'),
            (b"C:Character:=D;D:Character:='a';", b'null;'),
            (b'C:Character:="a";', b'null;'),
            (b'S:String:="a";C:Character:=S;', b'null;'),
            (b"C:constant Character:='a';", b"C:='b';"),
            (b"C:Character:='a';", output(b'C')),
            (b"C:Character:='a';", output(b'"x"&C')),
            (b"C:Character:='a';", b"if C'Length=1 then null;end if;"),
            (b"C:Character:='a';", b'if C="a" then null;end if;'),
            (b"C:Character:='a';S:String:=\"a\";", b'S:=C;'),
            (b"C:Character:='a';S:String:=\"a\";", b'C:=S;'),
            (b"C:Character:='a';", b"C:='ab';"),
            (b"C:Character:='a';", b"C:='\t';"),
            (b"C:Character:='a';", b"if 'a'='a' then null;end if;"),
        ):
            with self.subTest(declarations=declarations, body=body):
                self.check(program(declarations, body), 2)

    def test_admission_all_character_relations_and_boolean_composition(self) -> None:
        declarations = b"S:String:=\"abc\";C:Character:='a';F:Boolean:=C='a';"
        for operator in (b'=', b'/=', b'<', b'<=', b'>', b'>='):
            for left, right in ((b'C', b"'b'"), (b"'b'", b'S(2)'), (b'(C)', b'(S(1))')):
                condition = left + operator + right
                self.check(program(declarations, b'F:=' + condition + b';if not (' + condition
                                   + b') or else F then null;end if;'))
        self.check(program(declarations, b"if (C='a') xor (S(1)='b') then null;end if;"))
        # A quote character must not hide a nested xor from the span scanner.
        self.check(program(declarations, b'''if (C='"') xor ((C='a') xor F) then null;end if;'''), 2)

    def test_admission_index_bounds_guards_arrays_and_dead_paths(self) -> None:
        declarations = (b'S:String:="abc";N:Integer range 0..4:=0;'
                        b"C:Character:=' ';subtype Index is Integer range 1..3;"
                        b'A:array(1..2)of Index:=(1,2);')
        self.check(program(declarations,
            b"if N>=1 and then N<=3 then C:=S(N);S(N):=C;end if;C:=S(A(1));"))
        for body in (b'C:=S(N);', b"S(0):='x';", b"if 1=0 then S(4):='x';end if;",
                     b"for I in 2..1 loop S(I):='x';end loop;",
                     b"for I in 1..3 loop S((I + 1)):='x';end loop;",
                     b"if N>=1 and N<=3 and S(N)='a' then null;end if;"):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        self.check(program(declarations, b"if N>=1 and then N<=3 and then S(N)='a' then null;end if;"))
        self.check(program(b'C:Character:=Input(1);', b'null;', arguments=True), 2)

    def test_admission_slices_keep_actual_bounds_and_slide_assignments(self) -> None:
        declarations = (b'S:String:="abcd";T:String:=S(2..3);U:String:=(T);'
                        b'V:String:=T&"x";Z:String:=S(0..(-1));'
                        b'H:String:=S(2147483647..2147483646);')
        self.check(program(declarations, b"U(2):='x';V(4):='y';T:=S(1..2);Z:=H;" + output(b'S(1..3)&Z')))
        for body in (b"U(1):='x';", b"V(1):='x';", b'T:=S(1..3);',
                     b'T(2..3):="xy";', b"Z(1):='x';", b'S:=S(0..3);'):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        declarations += b'L:Integer range 1..2:=1;R:Integer range 2..3:=2;'
        self.check(program(declarations, output(b'S(L..R)')))
        # Independent endpoint intervals do not prove a one-byte slice length.
        self.check(program(declarations + b'One:String:="x";', b'One:=S(L..L);'), 2)
        self.check(program(declarations, output(b'S(L..1)&H&"x"')))

    def test_admission_slice_boundary_rules(self) -> None:
        text = b'S:String:="abc";'
        four = b'S:String:="abcd";'
        for declarations, body in (
            (text + b'R:Integer range 3..4:=3;', output(b'S(1..R)')),  # d>E, c<=E
            (text, output(b'S(9..9)')),  # a=d is potentially nonnull
            (text + b'L:Integer range 0..5:=1;', output(b'S(L..3)')),  # a<B, b>d
            (text + b'R:Integer range 0..5:=1;', output(b'S(2..R)')),  # d>E, a>c
            (text, b'for I in 5..4 loop ' + output(b'S(1..I)') + b'end loop;'),  # empty upper
            (text, b'for I in 2..1 loop ' + output(b'S(I..1)') + b'end loop;'),  # empty lower
            (four + b'L:Integer range 1..2:=1;One:String:="x";', b'One:=S(L..1);'),  # min=c-b+1
            (four + b'R:Integer range 1..2:=1;Two:String:="xy";', b'Two:=S(1..R);'),  # min=c-b+1
            (four + b'L:Integer range 2..3:=2;R:Integer range 1..2:=1;Z:String:="";',
             b'Z:=S(L..R);'),  # max=d-a+1
            (text + b'Z:String:=S(5..4)&"ab";C:Character:=Z(5);', b'null;'),  # null left
        ):
            with self.subTest(declarations=declarations, body=body):
                self.check(program(declarations, body), 2)
        self.check(program(text + b'Z:String:=S(5..4)&"ab";C:Character:=Z(1);', b'null;'))
        self.check(program(text + b'Z:String:=""&S(0..(-5));', output(b'Z')))  # null right keeps bounds

    def test_admission_names_and_hiding_use_resolved_kinds(self) -> None:
        for declarations, body in (
            (b"Character:Character:='x';", b'null;'),
            (b'Character:Integer:=1;C:Character:=\'x\';', b'null;'),
            (b"C:Character:='x';c:String:=\"x\";", b'null;'),
            (b"Integer:Character:='x';", output(b"Integer'Image(0)")),
            (b"True:Character:='x';F:Boolean:=True;", b'null;'),
            (b"C:Character:='x';", b"for C in 1..1 loop C:='y';end loop;"),
            (b'S:String:="x";C:Character:=\'x\';', b'for S in 1..1 loop C:=S(1);end loop;'),
            (b'Character:String:="x";C:Character:=\'y\';', b'null;'),
            (b'Character:array(1..1)of Integer:=(1=>1);C:Character:=\'y\';', b'null;'),
            (b'subtype Character is Integer range 1..2;C:Character:=\'y\';', b'null;'),
            (b'Character:Boolean:=True;C:Character:=\'y\';', b'null;'),
            (b"C:Character:='x';D:Character:='y';", b'for C in 1..1 loop D:=C;end loop;'),
            (b'K:constant String:="x";', b"K(1):='y';"),
        ):
            with self.subTest(declarations=declarations, body=body):
                self.check(program(declarations, body), 2)
        self.check(program(b"True:Character:='x';", b"if TRUE='x' then null;end if;"))
        source = program(b"Put_Line:Character:='x';", b"Silver_IO.Put_Line(\"ok\");")
        self.check(source.replace(b'with Silver_IO;', b'with Silver_IO;use Silver_IO;'))

    def test_admission_source_operator_and_leaf_accounting(self) -> None:
        arithmetic = b'0'
        for _ in range(63):
            arithmetic = b'(' + arithmetic + b' + 0)'
        declarations = b'N:Integer:=' + arithmetic + b";C:Character:='+';"
        self.check(program(declarations, b"C:='&';C:='/';"))
        self.check(program(declarations, b'N:=(N + 0);'), 2)
        declarations = b'S:String:="ab";'
        self.check(program(declarations, output(b'&'.join([b'""'] * 61 + [b'S(1..2)']))))
        self.check(program(declarations, output(b'&'.join([b'""'] * 62 + [b'S(1..2)']))), 2)
        index = b'1'
        for _ in range(62):
            index = b'(' + index + b' + 0)'
        declarations = b'S:String:="x";C:Character:=\' \';'
        self.check(program(declarations, b'C:=S(' + index + b');'))
        self.check(program(declarations, b'S(' + index + b"):=C;"))
        index = b'(' + index + b' + 0)'
        self.check(program(declarations, b'C:=S(' + index + b');'), 2)
        self.check(program(declarations, b'S(' + index + b"):=C;"), 2)
        source = program(b"C:Character:='x';", b'null;')
        self.check(source + b' ' * (4096 - len(source)))
        self.check(source + b' ' * (4097 - len(source)), 2)

    def test_admission_nested_character_and_dense_comparison_boundaries(self) -> None:
        body = output(b'"ok"')
        base = program(b"C:Character:='x';", body)
        depth = (4096 - len(base)) // 2
        declaration = b'C:Character:=' + b'(' * depth + b"'x'" + b')' * depth + b';'
        source = program(declaration, body)
        self.check(source + b' ' * (4096 - len(source)))

        declarations = b'S:String:="aaaa";'
        statement = b"if S(I)='a'then S(I):='b';end if;"
        prefix = b'for I in 1..4 loop '
        suffix = b'end loop;' + output(b'S')
        count = (4096 - len(program(declarations, prefix + suffix))) // len(statement)
        source = program(declarations, prefix + statement * count + suffix)
        self.check(source + b' ' * (4096 - len(source)))

    def test_native_character_snapshots_bounds_nulls_and_sliding(self) -> None:
        declarations = (b'S:String:="abcd";T:String:=S(2..3);Copy:constant String:=T;'
                        b'C:Character:=T(2);Saved:constant Character:=C;'
                        b'Z:String:=S(0..(-1));H:String:=S(2147483647..2147483646);')
        body = (b"C:='x';T(2):=C;T:=S(1..2);Z:=H;"
                b"if Saved='b' and C='x' then " + output(b'Copy&"/"&T&Z') + b'end if;')
        executable, _ = self.compile(program(declarations, body), 'assigned')
        self.run_program(executable, b'bc/ab\n')

    def test_native_argument_copy_index_and_invalid_printable_boundary(self) -> None:
        declarations = b'Work:String:="abc";C:Character:=\' \';'
        body = (b"if Input'Length=3 then Work:=Input;C:=Work(1);"
                b"if C='z' then " + output(b'Work')
                + b'else ' + output(b'"other"') + b'end if;end if;')
        executable, _ = self.compile(program(declarations, body, arguments=True), 'selected')
        self.run_program(executable, b'zoo\n', (b'zoo',))
        self.run_program(executable, b'', (b'\xffxx',), 1)

    def test_native_dynamic_copies_with_noncanonical_null_bounds(self) -> None:
        declarations = (b'S:constant String:="x";'
                        b'H:constant String:=S(2147483647..2147483646);'
                        b'D:String:=Input&H;Copy:constant String:=D;')
        # Empty Input gives D the actual null bounds of H. Whole assignment
        # retains D's target bounds; later concatenations must remain safe.
        body = output(b'Copy&H') + b'D:=Input;' + output(b'D')
        executable, _ = self.compile(program(declarations, body, arguments=True), 'selected')
        self.run_program(executable, b'\n\n', (b'',))
        self.run_program(executable, b'abc\nabc\n', (b'abc',))
        self.run_program(executable, b'', (b'\xff',), 1)

    def test_native_bounded_character_append_clear_and_reuse(self) -> None:
        declarations = (b'Buffer:String:="  ";Item:Character:=\'x\';'
                        b'Len:Integer range 0..2:=0;')
        body = (output(b'Buffer(1..Len)')
                + b'for Attempt in 1..3 loop if Len<2 then '
                b'Buffer((Len + 1)):=Item;Len:=(Len + 1);else '
                + output(b'"full"') + b'end if;'
                + output(b'Buffer(1..Len)') + b'end loop;Len:=0;'
                + output(b'Buffer(1..Len)') + b"Item:='Z';if Len<2 then "
                b'Buffer((Len + 1)):=Item;Len:=(Len + 1);end if;'
                + output(b'Buffer(1..Len)'))
        self.check_full_route(program(declarations, body), kind='assigned',
                              runs=(((), b'\nx\nxx\nfull\nxx\n\nZ\n', 0),))

    def test_native_bounded_repeat_all_declared_counts(self) -> None:
        declarations = (b'Source:constant String:="ha";'
                        b'Buffer:String:="                    ";'
                        b'Len:Integer range 0..20:=0;')
        body = (b'for Count in 0..10 loop for I in 1..Count loop '
                b'for J in 1..2 loop Buffer((((I - 1) * 2) + J)):=Source(J);'
                b'end loop;end loop;Len:=(Count * 2);'
                + output(b'Buffer(1..Len)') + b'end loop;')
        expected = b''.join(b'ha' * count + b'\n' for count in range(11))
        self.check_full_route(program(declarations, body), kind='assigned',
                              runs=(((), expected, 0),))

    def test_native_bounded_repeated_prepend_shift_order(self) -> None:
        declarations = (b'Buffer:String:="      ";Prefix:String:="W";'
                        b'Len:Integer range 0..6:=0;')
        body = (b'for Attempt in 1..7 loop if Len<6 then Len:=(Len + 1);'
                b'for J in reverse 1..(Len - 1) loop '
                b'Buffer((J + 1)):=Buffer(J);end loop;'
                b"Buffer(1):=Prefix(1);Prefix(1):='X';else "
                + output(b'"full"') + b'end if;'
                + output(b'Buffer(1..Len)') + b'end loop;')
        expected = b'W\nXW\nXXW\nXXXW\nXXXXW\nXXXXXW\nfull\nXXXXXW\n'
        self.check_full_route(program(declarations, body), kind='assigned',
                              runs=(((), expected, 0),))

    def test_native_bounded_literal_append_refuses_whole_with_one_free_cell(self) -> None:
        declarations = (b'Buffer:String:="abcd    ";Suffix:constant String:="XYZ";'
                        b'Len:Integer range 0..8:=4;Start:Integer range 0..5:=0;')
        body = (b'for Attempt in 1..2 loop if Len<=5 then '
                b'Start:=Len;Len:=(Len + 3);'
                b'for J in 1..3 loop Buffer((Start + J)):=Suffix(J);end loop;'
                b'else ' + output(b'"full"') + b'end if;'
                + output(b'Buffer(1..Len)') + output(b'Buffer')
                + output(b"Integer'Image(Len)") + b'end loop;')
        # Inspect the spare cell and the logical length as well as the prefix.
        expected = b'abcdXYZ\nabcdXYZ \n 7\nfull\nabcdXYZ\nabcdXYZ \n 7\n'
        self.check_full_route(program(declarations, body), kind='assigned',
                              runs=(((), expected, 0),))

    def test_native_bounded_literal_prepend_refuses_whole_with_one_free_cell(self) -> None:
        declarations = (b'Buffer:String:="abcd    ";Prefix:constant String:="XYZ";'
                        b'Len:Integer range 0..8:=4;')
        body = (b'for Attempt in 1..2 loop if Len<=5 then Len:=(Len + 3);'
                b'for J in reverse 1..(Len - 3) loop '
                b'Buffer((J + 3)):=Buffer(J);end loop;'
                b'for J in 1..3 loop Buffer(J):=Prefix(J);end loop;'
                b'else ' + output(b'"full"') + b'end if;'
                + output(b'Buffer(1..Len)') + output(b'Buffer')
                + output(b"Integer'Image(Len)") + b'end loop;')
        expected = b'XYZabcd\nXYZabcd \n 7\nfull\nXYZabcd\nXYZabcd \n 7\n'
        self.check_full_route(program(declarations, body), kind='assigned',
                              runs=(((), expected, 0),))

    def test_bounded_prefix_output_after_conditional_control(self) -> None:
        declarations = b'Buffer:String:="  ";Len:Integer range 0..2:=0;'
        mutation = b"Buffer((Len + 1)):='x';Len:=(Len + 1);"
        prefix = output(b'Buffer(1..Len)')
        self.check(program(declarations, b'if Len<2 then ' + mutation + prefix + b'end if;'), 2)
        self.check_full_route(program(declarations, b'if Len<2 then ' + mutation + b'end if;' + prefix),
                              kind='assigned', runs=(((), b'x\n', 0),))

    def test_admission_bounded_append_requires_bare_name_refinement(self) -> None:
        declarations = (b'Buffer:String:="Hello ";Suffix:constant String:="!";'
                        b'Len:Integer range 0..6:=5;')
        mutation = b'Buffer((Len + 1)):=Suffix(1);Len:=(Len + 1);'
        for extra, guard in ((b'', b'True'), (b'', b'(Len + 1)<=6'),
                             (b'Room:Boolean:=Len<6;', b'Room')):
            with self.subTest(guard=guard):
                self.check(program(declarations + extra, b'if ' + guard + b' then '
                                   + mutation + b'end if;' + output(b'Buffer(1..Len)')), 2)
