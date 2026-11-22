"""Nominal Integer arrays, static shape queries and read-only call frames."""
from pathlib import Path
import sys
import tempfile
import unittest

from tests import test_shared_bindings as shared

program = shared.program
output = shared.output
VECTOR = (b'subtype Small is Integer range -10..10;'
          b'type Vector is array(-1..1)of Small;')
FIRST = (b'function First_Value(Data:in Vector)return Small is '
         b'begin return Data(Data\'First);end First_Value;')


class ArrayParameterTests(unittest.TestCase):
    check = shared.SharedBindingsTests.check
    check_full_route = shared.SharedBindingsTests.check_full_route
    compile = shared.SharedBindingsTests.compile
    run_program = shared.SharedBindingsTests.run_program

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix='silver array parameters-')
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name).resolve() / 'array_parameters.adb'

    def test_source_limit_loop_shapes_complete_the_native_route(self) -> None:
        if sys.platform.startswith('linux'):
            import resource

            original_limits = resource.getrlimit(resource.RLIMIT_STACK)
            stack_bytes = 16 * 1024 * 1024
            self.assertTrue(original_limits[1] == resource.RLIM_INFINITY
                            or original_limits[1] >= stack_bytes,
                            'native stack regressions require a 16 MiB stack limit')
            resource.setrlimit(resource.RLIMIT_STACK, (stack_bytes, original_limits[1]))
            self.addCleanup(resource.setrlimit, resource.RLIMIT_STACK, original_limits)

        # Named metadata grows every recursive loop frame. Keep the old counted
        # and foreach shapes alongside the new Range header at the source limit.
        # Unused callable bodies still exercise parsing and are audited in full;
        # their native executables run only the empty Main body.
        cases = (
            ('Main counted', program(b'A:array(1..2)of Integer:=(0,0);', b'%s'),
             b'for I in 1..1 loop ', b'A(1):=I;', 'assigned', (), None),
            ('Main foreach', program(b'A:constant array(1..1)of Integer:=(1=>0);', b'%s'),
             b'for I of A loop ', b'null;', 'static', (), None),
            ('Main Range', program(b'type T is array(1..1)of Integer;A:T:=(1=>0);', b'%s'),
             b"for I in A'Range loop ", b'null;', 'static', (), None),
            ('function counted', program(b'function F(X:in Integer)return Integer is '
                                         b'begin %sreturn 0;end F;', b'null;'),
             b'for I in 1..1 loop ', b'null;', 'static', ('F',), None),
            ('procedure counted', program(b'procedure P(X:out Integer)is '
                                          b'begin X:=0;%send P;', b'null;'),
             b'for I in 1..1 loop ', b'null;', 'assigned', (), {'P': ('X',)}),
            ('array formal Range', program(b'type T is array(1..1)of Integer;'
                                           b'function F(X:in T)return Integer is '
                                           b'begin %sreturn 0;end F;', b'null;'),
             b"for I in X'Range loop ", b'null;', 'static', ('F',), None),
        )
        for name, template, header, body, kind, functions, procedures in cases:
            with self.subTest(shape=name):
                depth = 0
                source = template % body
                while True:
                    candidate = template % (header * (depth + 1)
                                            + body + b'end loop;' * (depth + 1))
                    if len(candidate) > 4096:
                        break
                    source = candidate
                    depth += 1
                self.assertGreater(depth, 120)
                source += b' ' * (4096 - len(source))
                self.check_full_route(source, kind=kind, functions=functions,
                                      procedures=procedures)
                self.check(source + b' ', 2)

    def test_named_objects_keep_bounds_initialization_and_mutability(self) -> None:
        declarations = (VECTOR + b'A:Vector:=(-3,4,5);'
                        b'B:constant Vector:=(6,-7,8);'
                        b"N:constant Integer:=Vector'Length;"
                        b"C:array(1..N)of Small:=(A(-1),A(0),A(1));")
        body = (b"A(A'First):=0;for I in reverse A'Range loop "
                + output(b"Integer'Image(A(I))") + b'end loop;'
                + output(b"Integer'Image(Vector'First)&Integer'Image(B'Last)"
                         b"&Integer'Image(C'Length)&Integer'Image(C(1))"))
        self.check_full_route(program(declarations, body), kind='assigned',
                              runs=(((), b' 5\n 4\n 0\n-1 1 3-3\n', 0),))
        for declaration in (
            VECTOR + b'A:Vector;',
            VECTOR + b'A:Vector:=(1,2);',
            VECTOR + b'A:Vector:=(1,2,3,4);',
            VECTOR + b'A:Vector:=(1,2,11);',
            VECTOR + b'A:Vector:=(others=>0);',
            VECTOR + b'A:Vector:=(A(-1),0,0);',
        ):
            with self.subTest(declaration=declaration):
                self.check(program(declaration, b'null;'), 2)
        self.check(program(VECTOR + b'A:constant Vector:=(0,0,0);', b'A(0):=1;'), 2)

    def test_bounds_queries_compose_with_boolean_and_string_initializers(self) -> None:
        declarations = (
            b'type T is array(1..2)of Integer;'
            b'function Size(Data:in T)return Integer is '
            b"Good:Boolean:=T'Length=2;R:Integer:=0;"
            b"begin if Good then R:=Data'Length;end if;return R;end Size;"
            b'procedure Copy_Size(Data:in T;Result:out Integer)is '
            b"Good:Boolean:=T'Length=2;"
            b"begin Result:=0;if Good then Result:=Data'Length;end if;end Copy_Size;"
            b'A:T:=(3,4);'
            b"Good:Boolean:=T'Length=2;"
            b"Flags:array(1..1)of Boolean:=(1=>T'Length=2);"
            b"S:String:=Integer'Image(A(A'First));C:Character:=S(2);"
            b'R:Integer:=0;')
        body = (b"if Good and then Flags(1) and then C='3' then "
                + output(b'S') + b'R:=Size(A);' + output(b"Integer'Image(R)")
                + b'Copy_Size(A,R);' + output(b"Integer'Image(R)") + b'end if;')
        self.check_full_route(program(declarations, body), kind='assigned',
                              functions=('Size',), procedures={'Copy_Size': ('Result',)},
                              runs=(((), b' 3\n 2\n 2\n', 0),))

    def test_function_named_mixed_repeated_and_forwarded_array_actuals(self) -> None:
        declarations = (
            VECTOR
            + b'function Difference(Left:in Vector;Right:in Vector;Flag:in Boolean)'
              b'return Integer is R:Integer:=0;begin if Flag then '
              b"R:=(Left(Left'First)-Right(Right'Last));else "
              b"R:=(Right(Right'First)-Left(Left'Last));end if;"
              b'return R;end Difference;'
              b'function Wrap(Data:in Vector)return Integer is R:Integer:=0;'
              b'begin R:=Difference(Right=>Data,Flag=>True,Left=>Data);'
              b'return R;end Wrap;'
              b'A:Vector:=(-3,4,5);B:constant Vector:=(6,-7,8);R:Integer:=0;')
        body = b''.join(call + output(b"Integer'Image(R)") for call in (
            b'R:=Difference(A,B,True);',
            b'R:=Difference(Right=>B,Flag=>False,Left=>A);',
            b'R:=Difference(A,Flag=>True,Right=>A);',
            b'R:=Wrap(Data=>A);',
            b"A(A'First):=0;R:=Wrap(A);",
        )) + output(b"Integer'Image(B(B'First))")
        self.check_full_route(program(declarations, body), kind='assigned',
                              functions=('Difference', 'Wrap'),
                              runs=(((), b'-11\n 1\n-8\n-8\n-5\n 6\n', 0),))

    def test_procedure_array_inputs_preserve_scalar_modes_and_forwarding(self) -> None:
        declarations = (
            VECTOR
            + b'procedure Read_First(Data:in Vector;Value:out Small)is '
              b"begin Value:=Data(Data'First);end Read_First;"
              b'procedure Wrap(Data:in Vector;Value:out Small;Copy:in out Small)is '
              b'begin Value:=0;Read_First(Value=>Value,Data=>Data);Copy:=Value;end Wrap;'
              b'A:Vector:=(-3,4,5);R:Small:=0;S:Small:=0;')
        body = (b'Wrap(A,Copy=>S,Value=>R);'
                + output(b"Integer'Image(R)&Integer'Image(S)&Integer'Image(A(-1))")
                + b'A(-1):=7;Wrap(Data=>A,Value=>R,Copy=>S);'
                + output(b"Integer'Image(R)&Integer'Image(S)&Integer'Image(A(-1))"))
        self.check_full_route(program(declarations, body), kind='assigned',
                              procedures={'Read_First': ('Value',), 'Wrap': ('Value',)},
                              runs=(((), b'-3-3-3\n 7 7 7\n', 0),))

    def test_type_identity_cannot_be_replaced_by_equal_shape(self) -> None:
        declarations = (
            VECTOR + b'type Other is array(-1..1)of Small;' + FIRST
            + b'A:Vector:=(1,2,3);B:Other:=(1,2,3);'
              b'C:array(-1..1)of Small:=(1,2,3);R:Small:=0;')
        self.check(program(declarations, b'R:=First_Value(A);'))
        for actual in (b'B', b'C', b'Vector', b'(1,2,3)', b'A(-1..1)',
                       b'A(-1)', b'Vector(B)', b'(A)'):
            with self.subTest(actual=actual):
                self.check(program(declarations, b'R:=First_Value(' + actual + b');'), 2)
        self.check(program(declarations, b'R:=First_Value(Data=>A,Data=>A);'), 2)
        self.check(program(declarations, b'R:=First_Value(Missing=>A);'), 2)

    def test_type_cardinality_and_integer_endpoint_boundaries(self) -> None:
        for bounds in (b'1..2048', b'-2147483648..-2147481601',
                       b'2147481600..2147483647'):
            with self.subTest(bounds=bounds):
                self.check(program(b'type T is array(' + bounds + b')of Integer;'
                                   b"N:Integer range 2048..2048:=T'Length;", b'null;'))
        for bounds in (b'1..2049', b'2..1', b'-2147483648..2147483647',
                       b'-2147483649..-2147483648', b'2147483647..2147483648'):
            with self.subTest(bounds=bounds):
                self.check(program(b'type T is array(' + bounds + b')of Integer;', b'null;'), 2)
        for bounds, value in ((b'-2147483648..-2147483648', b'-2147483648'),
                              (b'2147483647..2147483647', b'2147483647')):
            declaration = (b'type T is array(' + bounds + b')of Integer;'
                           b"A:T:=(T'First=>7);N:Integer:=" + value + b';')
            self.check(program(declaration, b"N:=A(A'First);"))

    def test_formals_do_not_reserve_physical_element_storage(self) -> None:
        # Two views have 4096 logical cells, although neither consumes the
        # 2048-cell physical pool. Their unused body is checked in full.
        declaration = (
            b'type T is array(-1024..1023)of Integer;'
            b'function Count(Left:in T;Right:in T)return Integer is '
            b"begin return (Left'Length+Right'Length);end Count;")
        self.check(program(declaration, b'null;'))
        declaration += (b'function Edge(Left:in T;Right:in T;Use_Left:in Boolean)'
                        b'return Integer is R:Integer:=0;begin if Use_Left then '
                        b"R:=Left(Left'First);else R:=Right(Right'Last);end if;"
                        b'return R;end Edge;')
        self.check(program(declaration, b'null;'))

    def test_unused_functions_check_full_component_domain_and_index_range(self) -> None:
        wide = (b'type T is array(1..2)of Integer;'
                b'function F(Data:in T)return Integer is '
                b'begin return (Data(1)+1);end F;')
        self.check(program(wide, b'null;'), 2)
        self.check(program(wide + b'A:T:=(0,0);R:Integer:=0;', b'R:=F(A);'), 2)
        self.check(program(VECTOR + FIRST, b'null;'))
        for body in (b'return Data(2);',
                     b'if False then R:=Data(2);end if;return R;',
                     b'for I in 3..2 loop R:=Data(I);end loop;return R;',
                     b'if Data(0)>0 then R:=(1/Data(0));end if;return R;'):
            declaration = (VECTOR + b'function F(Data:in Vector)return Integer is '
                           b'R:Integer:=0;begin ' + body + b'end F;')
            with self.subTest(body=body):
                self.check(program(declaration, b'null;'), 2)

    def test_read_only_formals_and_scalar_only_results_outputs_and_locals(self) -> None:
        for declaration in (
            b'function F(Data:in Vector)return Integer is begin Data(0):=1;return 0;end F;',
            b'function F(Data:in Vector)return Integer is begin Data:=Data;return 0;end F;',
            b'function F(Data:in Vector)return Vector is begin return Data;end F;',
            b'function F(Data:in Vector)return Integer is A:Vector:=(1,2,3);begin return 0;end F;',
            b'procedure P(Data:out Vector)is begin Data(0):=0;end P;',
            b'procedure P(Data:in out Vector)is begin null;end P;',
            b'procedure P(Data:in Vector;N:out Integer)is begin N:=0;Data(0):=1;end P;',
        ):
            with self.subTest(declaration=declaration):
                self.check(program(VECTOR + declaration, b'null;'), 2)

    def test_bounds_queries_are_static_but_component_reads_are_not(self) -> None:
        declaration = (VECTOR + b'A:Vector:=(-3,4,5);'
                       b"L:constant Integer:=A'First;H:constant Integer:=Vector'Last;"
                       b"B:array(L..H)of Small:=(1,2,3);"
                       b"function Size(Data:in Vector)return Integer is "
                       b"N:Integer:=Vector'Length;begin N:=Data'Length;return N;end Size;"
                       b'R:Integer:=0;')
        self.check(program(declaration, b"R:=Size(A);R:=A(A'First);"))
        self.check(program(VECTOR + b'A:constant Vector:=(-1,0,1);'
                           b'K:constant Integer:=A(0);type T is array(0..K)of Integer;', b'null;'), 2)
        formal_initializer = (VECTOR + b'function F(Data:in Vector)return Integer is '
                              b"N:Integer:=Data'Length;begin return N;end F;")
        self.check(program(formal_initializer, b'null;'), 2)

    def test_anonymous_integer_queries_preserve_constant_component_bound_rule(self) -> None:
        declaration = b'A:constant array(-1..1)of Integer:=(1,2,3);R:Integer:=0;'
        self.check_full_route(program(declaration,
                                     b"for I in A'First..A'Last loop R:=A(I);"
                                     + output(b"Integer'Image(R)") + b'end loop;'),
                              kind='assigned', runs=(((), b' 1\n 2\n 3\n', 0),))
        self.check(program(declaration, b'for I in A(-1)..A(1)loop null;end loop;'), 2)
        for attribute in (b"A'First(1)", b"A'Last(2)", b"A'Length(1)", b"A'Range"):
            with self.subTest(attribute=attribute):
                self.check(program(declaration, b'R:=' + attribute + b';'), 2)
        self.check(program(b'A:array(1..2)of Boolean:=(True,False);R:Integer:=0;',
                           b"R:=A'Length;"), 2)

    def test_visibility_and_loop_hiding_do_not_fall_back_to_array_metadata(self) -> None:
        declarations = VECTOR + b'A:Vector:=(1,2,3);R:Integer:=0;'
        for body in (b"for A in 1..1 loop R:=A'Length;end loop;",
                     b"for Vector in 1..1 loop R:=Vector'First;end loop;",
                     b"for A in A'Range loop null;end loop;",
                     b"for Vector in Vector'Range loop null;end loop;"):
            with self.subTest(body=body):
                self.check(program(declarations, body), 2)
        for declaration in (
            b'type T is array(1..2)of Integer;t:Integer:=0;',
            b'N:Integer:=2;type T is array(1..N)of Integer;',
            b'type T is array(1..2)of Later;subtype Later is Integer range 0..9;',
            b'type T is array(1..2)of Boolean;',
            VECTOR + b'function F(Vector:in Integer)return Integer is begin return Vector;end F;',
            VECTOR + b'A:Vector:=(1,2,3);function F(X:in Integer)return Integer is '
                     b"begin return A'Length;end F;",
        ):
            with self.subTest(declaration=declaration):
                self.check(program(declaration, b'null;'), 2)

    def test_metadata_bound_accounts_for_short_named_object_declarations(self) -> None:
        # 180 initialized named objects exceed the old source/24 descriptor
        # bound while remaining below 4096 source bytes and 2048 stored cells.
        declaration = b'type T is array(1..2)of Integer;' + b''.join(
            b'A' + str(index).encode() + b':T:=(0,0);' for index in range(180))
        source = program(declaration, b'null;')
        self.assertLessEqual(len(source), 4096)
        self.check(source)

    def test_queries_share_expression_operand_budget(self) -> None:
        # No unary signs in these declarations: the 63-operator budget is
        # shared by declarations and the tested expression.
        declaration = (b'subtype Small is Integer range 0..9;'
                       b'type Vector is array(1..3)of Small;'
                       b'A:Vector:=(1,2,3);R:Integer:=0;')
        def addition(terms):
            result = terms[0]
            for term in terms[1:]:
                result = b'(' + result + b'+' + term + b')'
            return result
        self.check(program(declaration, b'R:=' + addition([b"A'Length"] * 64) + b';'))
        # A component prefix is an extra leaf; the attribute itself is one
        # scalar leaf. The rejection below still uses only 63 operators.
        for count, status in ((62, 0), (63, 2)):
            with self.subTest(count=count):
                terms = [b"A(A'First)"] + [b"Vector'Length"] * count
                self.check(program(declaration, b'R:=' + addition(terms) + b';'), status)

    def test_array_inputs_do_not_relax_scalar_alias_or_incoming_state_rules(self) -> None:
        declaration = (
            VECTOR + b'procedure P(Data:in Vector;X:in Small;Y:out Small)is '
            b'begin Y:=X;end P;A:Vector:=(1,2,3);R:Small:=0;')
        self.check(program(declaration, b'P(Data=>A,X=>1,Y=>R);'))
        for call in (b'P(A,R,R);', b'P(Y=>R,Data=>A,X=>R);',
                     b'P(A,1,A(0));', b'P(A,11,R);', b'P(A,Y=>R,1);'):
            with self.subTest(call=call):
                self.check(program(declaration, call), 2)

    def test_argument_shell_and_named_constant_iteration_compose(self) -> None:
        declaration = (VECTOR + FIRST + b'A:constant Vector:=(-3,4,5);'
                       b'R:Small:=0;S:String:="abc";C:Character:=\'x\';'
                       b'Flags:array(-1..1)of Boolean:=(True,False,True);')
        body = (b"R:=First_Value(Data=>A);C:=S(A'Length);"
                b"if Flags(A'First) and then C='c' then "
                + output(b"Integer'Image(R)&Input") + b'end if;'
                b'for E of reverse A loop ' + output(b"Integer'Image(E)") + b'end loop;')
        self.check_full_route(program(declaration, body, arguments=True, capacity=32),
                              kind='selected', functions=('First_Value',),
                              runs=(((), b'-3old\n 5\n 4\n-3\n', 0),
                                    ((b'new',), b'-3new\n 5\n 4\n-3\n', 0),
                                    ((b'a', b'b'), b'', 1)))
