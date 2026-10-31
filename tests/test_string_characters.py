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

    def test_admission_names_and_hiding_use_resolved_kinds(self) -> None:
        for declarations, body in (
            (b"Character:Character:='x';", b'null;'),
            (b'Character:Integer:=1;C:Character:=\'x\';', b'null;'),
            (b"C:Character:='x';c:String:=\"x\";", b'null;'),
            (b"Integer:Character:='x';", output(b"Integer'Image(0)")),
            (b"True:Character:='x';F:Boolean:=True;", b'null;'),
            (b"C:Character:='x';", b"for C in 1..1 loop C:='y';end loop;"),
            (b'S:String:="x";C:Character:=\'x\';', b'for S in 1..1 loop C:=S(1);end loop;'),
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
        source = program(b"C:Character:='x';", b'null;')
        self.check(source + b' ' * (4096 - len(source)))
        self.check(source + b' ' * (4097 - len(source)), 2)

    def test_native_character_snapshots_bounds_nulls_and_sliding(self) -> None:
        declarations = (b'S:String:="abcd";T:String:=S(2..3);Copy:constant String:=T;'
                        b'C:Character:=T(2);Saved:constant Character:=C;'
                        b'Z:String:=S(0..(-1));H:String:=S(2147483647..2147483646);')
        body = (b"C:='x';T(2):=C;T:=S(1..2);Z:=H;"
                b"if Saved='b' and C='x' then " + output(b'Copy&"/"&T&Z') + b'end if;')
        executable, _ = self.compile(program(declarations, body), 'assigned')
        self.run_program(executable, b'bc/ab\n')
