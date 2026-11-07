# Silver language specification

The fixed-size Boolean-array increment is recorded in the
[delivery account](docs/boolean-arrays.md#delivery-assurance-and-validation--2026-11-07).
The Linux native proof/build and complete Lean/source checkpoints passed; the
delivery account carries final runtime applicability and closing review status.
The bounded Boolean-array rules below keep the existing source, expression and
storage budgets; broad arrays, Boolean iteration and `others` aggregates remain
outside this increment.

The bounded String indexing, Character and slice additions have complete
repaired Linux native and Lean assurance after the
[interim external review](docs/interim-review-response-20261105.md).
The [repaired delivery checkpoint](docs/bounded-string-characters.md#repaired-delivery-checkpoint--2026-11-05)
records current evidence and reviewed regression applicability; the earlier
delivery retains its historical inputs and failed attempts. The
[closing delivery review](docs/reviews/review-interim-response-closing-20261105.md)
passed. The owner authorized delivery through
[PR #307](https://github.com/berkeleynerd/silver/pull/307) on 2026-11-06;
the external report remains interim and clears no unexamined scope.

Silver is one evolving language before 1.0. This specification describes the
predicate, path-sensitive and finite-loop language under the [Oracle](oracle.md),
including the context, visibility and association rules validated in the [Names and
Calls checkpoint](docs/names-and-calls.md). The [conditional-statement delivery
record](docs/branches.md) records the completed Linux milestone, building on the
earlier [sequencing checkpoint](docs/statement-sequencing.md). The [For loops and
integers delivery record](docs/for-loops-integers.md) covers immutable Integer
values, scoped loops and standard Integer Image. The [bounded mutable Integer
record](docs/bounded-mutable-integers.md) extends these rules with initialized
mutable objects, object-local static ranges and scalar assignment. The
[division record](docs/integer-division.md) extends shared scalar expressions
with interval-checked `/`, `mod` and `rem`. The
[scalar guard delivery record](docs/scalar-guard-refinement.md#delivery-assurance-and-validation)
records complete Linux native and Lean assurance, reviewed retained regression
results and successful focused repair tests for the flow rules below.
The [fixed-size Integer-array record](docs/fixed-integer-arrays.md) specifies the
bounded array increment and its implementation/validation status.
The [constant-array iteration record](docs/constant-array-iteration.md#delivery-assurance-and-validation)
records complete Linux native and Lean/source assurance for forward/reverse
element iteration over these constant arrays, including existing body compositions.
The [named Integer-subtype delivery record](docs/named-integer-subtypes.md#delivery-assurance-and-validation)
records complete Linux native and Lean/source assurance for static named scalar
ranges, optional narrower scalar object constraints and bounded components of
these fixed arrays. The feature was delivered through
[PR #289](https://github.com/berkeleynerd/silver/pull/289).
The [Boolean scalar delivery](docs/boolean-objects.md#delivery-assurance-and-validation)
records complete Linux native and Lean/actual-source assurance for initialized
Boolean objects, assignment and the logical expressions below, composed with
the existing language.
The [machine-readable
catalogue](catalogue/silver.json), compiler, and this specification must agree. A
discrepancy is a defect to resolve, not an extension of the language. Membership
depends on source bytes, never on prover success.

Inherited meanings are fixed by the checked-in
[Ada 2022 Reference Manual](references/ada/2022/RM-TOC.html) and
[SPARK 16.1 Reference Manual](references/spark/16.1/docs/lrm/source/index.rst).
Silver restricts those languages without adding syntax or changing meaning.
The [roadmap](roadmap.md) describes proposals; it does not admit them.

## Source and lexical rules

A source belongs to the current language exactly when it satisfies all the
following rules and the complete grammar below:

- Its length is between 1 and 4096 bytes inclusive. Comments and whitespace
  count toward this limit.
- Every byte is printable ASCII (32 through 126), horizontal tab (9), line feed
  (10), or carriage return (13). All other bytes, including vertical tab, form
  feed, NUL, non-ASCII bytes, and a byte-order mark, are excluded everywhere.
- Whitespace consists of space, horizontal tab, line feed, or carriage return.
- Outside a string literal, a comment begins with `--` and continues to carriage return, line feed, or
  end of file. Its contents may contain printable ASCII and horizontal tabs.
- Permitted whitespace and comments may occur before, between, or after tokens.
  A comment extending to end of file consumes the remaining bytes.
- Word tokens compare without ASCII letter case distinctions. They must be
  whole tokens: ASCII letters, decimal digits, and underscore are identifier
  characters and cannot be attached to form a larger identifier. For example,
  `procedureMain`, `Main2`, and `null_` do not match the required words.
- After accounting for whitespace and comments, all tokens must match the
  grammar exactly. Printable bytes are not generally legal executable syntax;
  being in the source alphabet alone does not establish membership.

The pinned Ada frontend must support every line and lexical element fitting
this complete-source bound. Boundary compilation tests exercise that capacity;
Ada's minimum implementation requirements alone do not establish it. See the
[frontend assumptions](docs/trusted-boundary.md#trusted-computing-base).

## Grammar and capabilities

The language has the separate null program and two output-capable shells:
static statements and argument-input statements. They share ordered declarations and finite statement sequences.
An output-capable shell need not actually call output. Earlier output, assignment
and branch-selected samples are instances of these shared rules.

All programs contain exactly one library-level `procedure Main`, without
parameters or exception handlers, and exactly one `pragma SPARK_Mode (On);` at
the beginning of its declarative part. The closing name is `Main`, ignoring
ASCII case. Null has no context clause and no declaration after the pragma:

```ada
procedure Main is
   pragma SPARK_Mode (On);
begin
   null;
end Main;
```

Every output-capable shell has a `with` clause naming `Silver_IO`. The
argument-input shell also names `Silver_Arguments`; the static shell cannot
name that package in its context. These exact package sets remain part of shell
membership, regardless of which body operations are used. There are no additional
application units. These package sets select the current shell, runtime dependencies
and corresponding proof-report policy; they are Silver's current scope, not an
Ada requirement that every imported operation be used.
The grammar below uses `L` for a literal, `S` for an assignment's
mutable target, `D` for the original immutable argument binding, and `E` for a String
expression. Initializers, assignment values, comparison operands and output
share that expression grammar.
These are grammar metavariables; authors write ordinary Ada source.

### Context clauses and call names

Before `procedure Main`, output-capable programs may arrange the two approved
packages in grouped or separate clauses:

```text
context_clause ::= "with" package_name { "," package_name } ";"
                 | "use" package_name { "," package_name } ";"
package_name   ::= "Silver_IO" | "Silver_Arguments"
```

The shell's required packages must each occur in a `with` clause. Any package
in a `use` clause must already have occurred in an earlier `with` clause.
Subject to those rules, clauses and names may be reordered or repeated without
an independent count limit; all bytes count toward the complete-source bound.
Context clauses cannot occur inside Main. Local `use` declarations, which Ada
permits, are also excluded: this fragment derives package use visibility from
context clauses and does not track changes to it inside Main. Other packages, `use type`, renamings,
and limited/private `with` clauses remain outside this fragment: the current
name rules cover only the existing library operations and a single declaration
region, not general Ada visibility.

Each operation may use its qualified name. It may instead use its unqualified
name when a context `use` clause names its package and no local declaration hides
that operation, ignoring ASCII case:

| Operation | Qualified name | Optional named actual |
| --- | --- | --- |
| Output | `Silver_IO.Put_Line` or `Silver_IO.Put` | `Item => expression` |
| Input initialization | `Silver_Arguments.First_Or_Default` | `Default => L` |
| Validity | `Silver_Arguments.Input_Is_Valid` | None; no parentheses |
| Rejection | `Silver_Arguments.Reject` | None; no parentheses |

Calls taking arguments accept exactly one actual, either positional or
named with the formal parameter shown. The `=>` delimiter is contiguous; trivia
may surround it. Formal names compare without ASCII case distinctions and are
not affected by a local object named `Item` or `Default`. Named association does
not expand the admitted argument expressions or API placements.

Operation names remain legal local object names. Such an object hides the
unqualified operation but remains available for ordinary String expressions and
assignments. Qualified calls remain available because the package names cannot
be redeclared in the corresponding shell. An input declaration named
`First_Or_Default` must itself use the qualified initializer: Ada already hides
the unqualified function inside that object's declaration. For example,
`First_Or_Default : constant String :=
Silver_Arguments.First_Or_Default (Default => "world");` is legal, whereas
removing `Silver_Arguments.` is not.
A later declaration named `First_Or_Default` does not hide the function at the
earlier input initializer.

A `use` clause admits no additional operation or package object. Names such as
`Max_Length` and `Written_Bytes` can be read only when independently declared as
local Strings; visibility of the library entities does not admit their use.
The [Names and Calls sample](samples/names_calls.adb) combines grouped clauses,
unqualified existing calls and named actuals.

### Literals and names

A String literal is enclosed in double quotes and decodes only printable ASCII bytes
32 through 126. Doubled quotes encode one quote. Empty literals are allowed;
literal case, spaces and `--` are preserved. Tabs and line breaks cannot occur
inside a literal. All delimiters, escapes and trivia still count toward the
4096-byte source bound.
If a literal's final decoded character is `[`, its closing quote cannot be
immediately followed by an ASCII letter, digit or underscore. GNAT recognizes
that adjacency as the start of an encoded wide character even under the pinned
ASCII settings. Separate it with whitespace, a comment or punctuation; for example,
write `X = "[" then` or `X = ("[")then`. Other bracket literals and ordinary
literal/keyword adjacency retain their existing rules.

A declared name matches `[A-Za-z]([A-Za-z0-9]|_[A-Za-z0-9])*`: an ASCII letter
followed by letters or digits, optionally separated by single underscores, without a
trailing underscore. The 74 Ada 2022 reserved words, `String` and `Silver_IO` are
excluded ignoring ASCII case. In an argument-bearing shell, `Silver_Arguments` is
also excluded for **every** declaration. Names in the ordered declaration region must
be distinct ignoring ASCII case across String, Character, Integer and Boolean objects, named
Integer subtypes and Integer/Boolean-array declarations. Loop indexes and elements
have the scoped hiding rules below. `Main` is legal; `Silver_Arguments` remains legal
in the static shell. Every reference matches the entire declared identifier ignoring
ASCII case. There is no additional identifier-length limit beyond the complete source
bound.

### Ordered declarations, names and copies

After the pragma, each nonargument output form has zero or more declarations:

```text
declaration ::= name ":" [ "constant" ] "String" ":=" expression ";"
              | name ":" [ "constant" ] "Character" ":=" character_expression ";"
              | name ":" [ "constant" ] "Boolean" ":=" condition ";"
              | name ":" [ "constant" ] integer_subtype_mark
                [ "range" static_scalar_expression ".." static_scalar_expression ]
                ":=" scalar_expression ";"
              | "subtype" name "is" "Integer" "range"
                static_scalar_expression ".." static_scalar_expression ";"
              | integer_array_declaration | boolean_array_declaration
integer_subtype_mark ::= "Integer" | earlier_named_integer_subtype
```

Each declaration introduces exactly one name. Every object initializer is required;
a String initializer may read or slice earlier String constants or mutable objects and
use Integer Image; an Integer initializer may read earlier initialized Integer
constants or mutable objects, including earlier initialized array components.
A Boolean initializer uses the condition grammar below and may read earlier
initialized Boolean objects or Boolean-array components and existing Integer, String, Character, length and validity
predicates. A Character initializer reads earlier Character objects or indexed
fixed-bound Strings, or uses a printable Character literal. Forward, cyclic and self-initializer references are excluded. Each String
initializer evaluates its literals, earlier names, slices, images and concatenations
immediately; parenthesized subexpressions preserve their grouping. A name
contributes the source object's current bytes:
a later write to the source does not change its earlier copies. Constants are
readable but cannot be assignment targets. Declarations may be unused.

An argument-bearing form first declares exactly one immutable `D` using
`First_Or_Default`, as specified below; ordinary declarations then follow and
may copy `D` or any earlier initialized object. Further calls or placements of
that API are excluded in this milestone. Every declaration executes before
body guards; later path facts cannot justify an earlier initializer.

Initialization fixes each object's bounds. An initializer using only static-length
values has a known fixed length and singleton inferred first and last bounds.
Copies and slices retain their actual bounds, including inverted null ranges.
A dynamic initializer must have exactly one dynamic
occurrence and no nonempty non-input contribution, since it executes before guards
and must fit for every `d <= 4096`. Such an object and `D` share the symbolic
selected-input length `d`; each object's bounds remain fixed during that execution.
This length relationship survives copies, including mutable-source snapshots.
Native String binding storage retains `4096 / 12 = 341` slots. Scalar storage
has `4096 / 7 = 585` slots because even `A:S:=0;`, using a one-letter named
subtype, consumes seven source bytes. Both capacities follow from the complete
source bound and minimum declaration spellings; they are not independent
language restrictions on declaration counts.

<a id="immutable-integer-expressions-and-comparisons"></a>

### Integer objects, expressions and comparisons

The predefined `Integer` range on the pinned native targets is -2147483648
through 2147483647. A named subtype declaration has the form
`subtype S is Integer range L .. U;`. It must name the visible predefined
Integer directly, and introduces a static nonempty range contained in Integer.
It constrains Integer values without creating a distinct type. Earlier named
subtypes may be used in scalar constant or mutable declarations and as fixed
array component marks. Subtype alias chains, derived types, conversions and
subtype attributes, including `S'Image`, are excluded.
The new subtype's name cannot be `Integer`, ignoring case. This is a Silver
scope restriction that keeps the predefined parent distinct from declared
subtypes; it does not introduce a new Ada naming rule.

Every scalar object declaration requires an initializer and may be constant or
mutable. Its subtype mark is the visible Integer or an earlier named Integer
subtype. An optional object-local `range L .. U` further constrains either kind
of object; without it, the declared range is the range of its subtype mark.
Both endpoints must fit that range and satisfy `L <= U`. Subtype and object
range endpoints use the scalar
expression grammar below, restricted to literals and earlier Ada-static Integer
constants. Every bound-expression intermediate must fit Integer. Dynamic range
constraints remain excluded.
Requiring static endpoints is a current Silver scope restriction, not an Ada
requirement: Ada permits dynamic object constraints. Admitting those would need
an elaboration and bound-lifetime argument for captured bounds.
Integer, Boolean, Character and String values are distinct, with no implicit conversion.
In particular, a one-byte String is not a Character.

Declaration elaboration computes each exact initial value in order and checks
that it lies within the declared range. Later initializers capture that value:
after `A : Integer range 0 .. 99 := 7`, `K : constant Integer := A` captures 7,
and `S : String := Integer'Image (A)` captures ` 7`. A later assignment to A
changes neither snapshot. Knowing the initial value does not make A or K
Ada-static. Static range endpoints may use only constants whose subtype and
initializer are recursively static under Ada RM 4.9; mutable objects, loop
indexes and constants initialized from them cannot supply an endpoint.
Constants declared with a named subtype and a recursively Ada-static initializer
remain Ada-static. An exact snapshot of a mutable object or an array component
does not become static by using a named subtype.

A subtype name is metadata, never a scalar or String value, an assignment
target, an iterable or an expression operand. Its declaration follows the
same ordering, case-insensitive uniqueness and reserved-name rules as objects.
It can hide a use-visible operation, and a loop index or element can hide its
spelling in the loop body. These rules do not create subtype conversions.

```text
scalar_expression ::= scalar_unsigned | sign scalar_integer_literal
scalar_unsigned   ::= scalar_integer_literal | scalar_name | scalar_group
                    | indexed_integer_component
scalar_group      ::= "(" scalar_unsigned ")"
                    | "(" sign scalar_unsigned ")"
                    | "(" scalar_unsigned scalar_operator scalar_unsigned ")"
scalar_operator   ::= "+" | "-" | "*" | "/" | "mod" | "rem"
sign              ::= "+" | "-"
```

Here `scalar_name` denotes a visible initialized Integer object, loop index or loop element.
Indexed Integer components follow the array rules below. Each scalar expression
has one through sixty-four operands: literal/name leaves and, for each indexed
read, one array-name operand plus every operand of its subscript. Binary operations
are fully parenthesized; `1 + 2` is excluded and `(1 + 2)` is admitted. A sign
outside a group can prefix only a numeral: `-1` is admitted, while negating a
name requires `(-N)`. Signed operands of binary operations need their own
groups: write `((-1) + 2)` or `(1 + (-2))`, not `(-1 + 2)` or `(1 + -2)`.
Parentheses have no separate depth limit within the complete-source bound.

Scalar numerals use the decimal/based spelling and exponent rules described
below for length literals, with magnitude at most 2147483648. This larger
magnitude permits the directly signed minimum `-2147483648`; every resulting
scalar value must still fit Integer. Thus `2147483648`, `+2147483648` and
`(-(2147483648))` are excluded. The exponent remains nonnegative and at most
4096, even for zero. `abs` and exponentiation as expression operators remain
excluded. The binary `mod` and `rem` keywords are whole tokens, without case
distinctions; `Model` and `Rem2` are names, not operator prefixes. The `/=`
comparison is distinct from division.

Admission propagates closed Integer intervals. During declaration elaboration,
earlier objects contribute their exact initial values. In the executable body,
constants retain singleton intervals. Mutable objects initially contribute their
declared ranges; assignments and selected scalar guards update their current
read intervals as specified below. Loop indexes use their captured intervals,
subject to selected guard refinement. Addition and subtraction use
their endpoint bounds, multiplication uses the minimum and maximum of the four
endpoint products, and negation reverses and negates the endpoints. Every
intermediate result must fit Integer for the entire inferred interval. The
analysis does not exploit correlations such as two occurrences of the same
index.

Division truncates toward zero. `rem` has the dividend's sign or is zero;
`mod` has the divisor's sign or is zero, following Ada RM 4.5.5. For every
operator, a nonempty divisor interval containing zero is rejected before
empty-operand propagation. This is a uniform conservative Silver rule even
when an empty dividend would make execution vacuous, not an Ada restriction.
If an operand interval is empty, multiplication is rejected when either operand
interval contains zero, and `mod` or `rem` is rejected when the divisor interval
contains 1 or -1. The divisor-zero check still comes first. These conservative
Silver restrictions prevent the pinned frontend from folding an unreachable
expression to a static value that it rejects in the enclosing context. They
also exclude some expressions the frontend would accept. Other empty-operand
results are empty. Static illegal subexpressions are independently rejected
before their enclosing operation.
For nonempty operand intervals `[a,b]` and `[c,d]`:

| Operator | Inferred result interval |
| --- | --- |
| `/` | The minimum and maximum of the four endpoint quotients, each truncated toward zero. The complete result interval must fit Integer. |
| `mod` | Exact result for two singleton intervals; otherwise `[0,d-1]` for positive divisors or `[c+1,0]` for negative divisors. |
| `rem` | Exact result for two singleton intervals; otherwise let `M = max(abs c, abs d)-1` mathematically. The lower endpoint is `max(a,-M)` if `a < 0`, else zero; the upper endpoint is `min(b,M)` if `b > 0`, else zero. |

Every intermediate must still fit Integer. Quotient rejects intervals that can
jointly reach `-2147483648 / (-1)`; `mod` and `rem` permit that pair and return
zero. Mathematical magnitudes in the rule do not admit an application `abs`
operator or widen application Integer. These are deliberately conservative
interval rules: no general operand correlation is used, and a safe runtime
value alone does not establish admission. Selected guards may narrow the incoming
interval before the operation; the operator rules themselves are unchanged.

An empty index interval makes remaining index-dependent arithmetic safety
vacuous only after the zero/unit identity restrictions above. It never permits
an out-of-range static subexpression. Integer assignments additionally
require a nonempty RHS interval, including in empty loops and unreachable arms.

Scalar comparisons admit `=`, `/=`, `<`, `<=`, `>` and `>=` between scalar
expressions and compose with the existing short-circuit predicates. Both
operands must pass the incoming expression check before refinement, including
all static subexpressions. A comparison refines a bare visible mutable Integer
name, loop-index name or loop-element name against an Ada-static nonempty singleton Integer
expression, in either operand order. Refinement follows resolved binding
identity, so shadowed names remain distinct. Parentheses around a whole condition
preserve refinement; parentheses around the target scalar name, arithmetic
targets and variable-to-variable comparisons do not refine. A nonstatic singleton,
including an immutable snapshot copied from a mutable object or a singleton loop
index, cannot supply the threshold. Immutable declaration constants keep their
exact values and declaration-derived staticness.

For each true or false outcome, intersect the target's current interval with
the comparison constraint (complementing the operator for false, and swapping
it for reversed operands). Retain the incoming interval if that refinement is
empty. Thus a contradictory guard does not create a new empty mutable interval
or bypass a statically illegal subtree; an already empty index stays empty.
Use the smallest closed interval covering the selected values: `X /= 0` removes
zero at an endpoint, but an interval crossing zero retains zero in its hull.
Separate `X > 0` and `X < 0` arms can justify division for both signs. Other
comparisons retain incoming scalar facts. Scalar impossibility does not prune
the independent input/String context.

True and false flows pass to the corresponding arms; `elsif` receives the
preceding false flow, and `not` swaps outcomes. An `and then` RHS receives the
left-true flow and an `or else` RHS the left-false flow, for every scalar read,
including Image arguments nested in String expressions. Branch exits and
alternative outcomes join each scalar identity by interval hull; an omitted
else contributes the false flow. These rules add no grammar or relational facts
between different objects.

The type mark used in a declaration must be visible; `Integer` must be visible
in Integer Image expressions and as the parent of a subtype declaration.
An Integer object, Integer-array object or subtype cannot itself be named `Integer`. A String object named
`Integer` remains legal, but hides the type in its own initializer and later
source. An earlier named subtype remains usable for scalar objects and array
components when a String object later hides the predefined Integer mark.

### Boolean objects and expressions

Every Boolean object has the predefined type `Boolean`, an initializer, and
optional `constant`. There are no Boolean subtype declarations, range constraints,
Image operations or enumeration loops. Fixed-size arrays of Boolean use the rules below. A Boolean value is admitted in a
Boolean initializer, Boolean assignment RHS or existing condition position;
output and Integer/String expressions retain their own types.

`Boolean`, `True` and `False` are ordinary predefined names, not reserved words.
The `Boolean` type mark must be visible at the declaration; a different-kind
declaration named `Boolean` hides it. A Boolean object cannot itself be named
`Boolean`, because its declaration hides that type mark. Declarations of other
kinds named `True` or `False` hide those literals. Boolean objects may have those
names when the initializer does not refer to the new object:
`True : Boolean := False` is permitted; `True : Boolean := True` is an excluded
self-reference. Lookup is case-insensitive and follows the same ordered
declaration and scoped loop hiding rules as other names.
A Boolean object named `Integer` hides the predefined Integer mark, including
in its own initializer and later Image expressions. An Integer index or element
named `True`, `False` or a Boolean object's name denotes that Integer binding
within its scope. Leaving the loop restores the outer visibility.

Initialization evaluates and stores the current Boolean value. Later initializers
capture that value; changing the original does not change a constant or mutable
copy. Assignment requires a visible mutable Boolean target and Boolean RHS,
and changes only that target's value. Constants and Integer loop binders cannot
be Boolean assignment targets, even in an empty loop or unreachable arm.

A Boolean literal, stored Boolean name or Boolean-array component contributes the incoming scalar and
String/input facts unchanged to both outcomes. It retains no relationship with
the predicate that computed its value. Consequently, saving `D /= 0` in a flag
does not justify later division under that flag, even before a later write to D.
Saving an input-length or validity predicate likewise does not establish those
facts when the stored flag is subsequently read. Boolean initialization and
assignment preserve the existing Integer intervals, String bounds and input
facts; evaluating their RHS still requires every reached expression to be safe.
Declaration checks use the exact initialized values of earlier Integer objects
and array components; body checks retain the existing flow and component rules.

### Character objects and fixed-bound String indexing

A Character literal is an apostrophe, one printable ASCII byte (32 through 126),
and an apostrophe. The apostrophe character itself is written as three consecutive
apostrophes, `'''`. Space, double quote and operator characters retain their byte
values; their contents are not operators or comments. No escape notation, Unicode,
Character conversion, Character attribute or Character subtype is admitted.

```text
character_expression ::= character_literal | initialized_character_name
                       | fixed_bound_string_name "(" scalar_expression ")"
                       | "(" character_expression ")"
```

A Character object has the visible predefined type `Character`, a required
initializer and optional `constant`. It stores a snapshot of the initializer's
one-byte value. The same declaration and scoped hiding rules apply as for other
objects. `Character` is not reserved, but a declaration with that name hides the
type mark, including in its own initializer. Character values cannot be used as
Strings, Integer operands, output arguments or concatenation operands.

An indexed prefix must name a visible initialized String whose actual first and
last bounds are known at declaration elaboration. The subscript uses the ordinary
Integer expression rules, including permitted Integer-array reads. Its inferred
interval must be nonempty and contained in those actual bounds. This rule also
applies in unreachable arms and empty loops, because the pinned frontend can
reject predictable static index errors there. A length guard on an input-dependent
String does not admit indexing: general dynamic-length indexing is outside this
increment. A null String consequently has no admitted indexed read or write.

A Character literal or name costs one expression leaf. An indexed read costs
one prefix leaf plus every scalar subscript leaf. Parentheses add no leaves;
each Character expression has at most 64 leaves. Arithmetic in subscripts shares
the program's 63-operator budget.

Character comparisons admit `=`, `/=`, `<`, `<=`, `>` and `>=` with predefined
Character ordering. At least one operand, possibly parenthesized, must be a typed
Character name or indexed String read. Two unqualified literals are excluded
because the pinned Ada frontend cannot resolve their type. Both operands are
checked in the incoming flow. Neither outcome adds byte-equality, ordering,
Integer or String/input facts; a comparison can appear wherever the existing
Boolean condition grammar permits it.

Character assignment requires a visible mutable Character target and evaluates
its RHS before replacing that one value. Indexed String assignment requires a
visible mutable fixed-bound String, an admitted subscript and a Character RHS.
Both the target index and RHS read the incoming store. The write replaces exactly
one element, preserving the target bounds, length, other elements, other objects
and earlier snapshots. The indexed target and RHS each have an independent
64-leaf limit. Constants, hidden outer names and loop binders cannot be targets.
Both assignment forms preserve existing Integer and String/input flow facts.
Slice assignment targets, Character concatenation and resizing are excluded.

### Fixed-size Integer arrays

The ordered declaration region admits anonymous, one-dimensional arrays:

```text
integer_array_declaration ::= name ":" [ "constant" ] "array" "("
                              static_scalar_expression ".." static_scalar_expression
                              ")" "of" integer_subtype_mark ":=" integer_array_aggregate ";"
integer_array_aggregate   ::= "(" scalar_expression "," scalar_expression
                              { "," scalar_expression } ")"
                            | "(" static_scalar_expression "=>" scalar_expression ")"
indexed_integer_component ::= integer_array_name "(" scalar_index_expression ")"
scalar_index_expression   ::= scalar_expression excluding indexed_integer_component
```

`scalar_index_expression` reuses `scalar_expression` and its recursive
productions, omitting the `indexed_integer_component` alternative from
`scalar_unsigned`.

Both index bounds must be Ada-static, fit Integer and form a nonempty range.
Each declaration creates its own anonymous Ada array type. Components use the
full predefined Integer range or the range of an earlier visible named Integer
subtype, according to the component mark. Named array types, inline component constraints,
multiple dimensions, null arrays and dynamic index bounds are outside this
fragment. These are Silver scope restrictions, not Ada requirements.

Initialization is mandatory and explicit. Arrays of at least two elements use
exactly one positional expression per component, in increasing index order.
A one-element array uses one named association whose Ada-static choice equals
its sole index; `(E)` alone is an ordinary parenthesized expression, not an
array aggregate. `others`, range choices, mixed associations, brackets and
aggregate expansion are excluded. Extra parentheses around the entire aggregate
are also outside this fragment: the bounded aggregate reader handles the two
listed outer forms directly. Ada permits additional aggregate forms; these
exclusions keep this initial reader and its correspondence argument small.
Every component expression passes the usual
Integer intermediate checks and evaluates to an exact initialized value within
the declared component range.
Expressions can read earlier declarations, including earlier array components;
self, cyclic and forward references remain excluded. There are no side effects
inside an initializer expression. Subsequent component writes do not change
earlier scalar, String or array snapshots.

Explicit components bound storage through the existing complete-source limit:
each uses an expression byte and a distinct comma or closing delimiter, so all
arrays' components together fit within `floor(source_bytes / 2)`, at most 2048.
The implementation compares the wide-arithmetic index cardinality with the
explicit component count before using an element-table offset. This storage
capacity is derived from source syntax, not an additional array-length policy.

A visible array component is an Integer atom wherever ordinary scalar
expressions occur: later initializers, arithmetic, comparisons, Image, assignment
values and, for mutable arrays only, counted-loop bounds. A subscript uses the existing scalar grammar with
array reads excluded; therefore `A((I + 1))` is permitted when its interval is
safe, but `A(B(I))` is outside this first fragment. Every inferred subscript
interval must be nonempty and lie inside the declared index range, including
in unreachable arms and empty loops. This also preserves frontend acceptance:
the pinned GNAT frontend rejects some out-of-range subscripts even in dead
arms or null loops, including a null loop range wholly outside the array bounds.
Silver applies one uniform interval rule rather than tracking which unreachable
shapes the frontend accepts; the rule also excludes some Ada-legal shapes.
Static illegal expressions remain excluded.
The array name and all subscript operands count toward the enclosing scalar
expression's 64-operand limit; arithmetic shares the existing 63-operator budget.

Declaration elaboration reads the exact initialized component values. In the
body, every array read contributes the declared component interval, including
reads from constant arrays. `of Integer` retains the full Integer interval;
`of S` contributes S's declared range. Array elements receive no per-element flow refinement.
This conservative body rule keeps array-cell facts independent of scalar guards,
component writes and loop composition; tracking individual cell values through
control flow is outside this fragment.
An indexed read is never Ada-static; a constant initialized from `A(1)` is an
exact snapshot but cannot supply a static range endpoint or guard threshold.
Scalar guards can establish a safe index interval, but a comparison of an array
element does not narrow a later read of that element.

An indexed assignment has the form
`A(scalar_index_expression) := scalar_expression;`. Only visible mutable arrays can
be targets. The index passes the same check as a read, and the RHS must have a
nonempty inferred interval contained in the declared component range, with every
intermediate fitting Integer. Both use
the incoming state; the assignment replaces precisely the selected component.
Other elements, array bounds, scalar-flow facts, String/input facts and earlier
snapshots are preserved. Array writes carry across loop iterations. Loop bounds
are captured on entry, including bounds read from arrays, and later writes do
not alter that iteration sequence. Empty loops preserve the entire store.

Array names share declaration uniqueness and operation/type hiding with String
and Integer names. A scoped loop index or element may hide an array. The new
binder's name is unavailable in its own bounds or iterable specification. Whole-array values, assignment, copying,
comparison, slices, concatenation and attributes are not admitted; copying
components explicitly through checked reads and writes is permitted.

### Fixed-size Boolean arrays

```text
boolean_array_declaration ::= name ":" [ "constant" ] "array" "("
                              static_scalar_expression ".." static_scalar_expression
                              ")" "of" "Boolean" ":=" boolean_array_aggregate ";"
boolean_array_aggregate ::= "(" condition "," condition { "," condition } ")"
                          | "(" static_scalar_expression "=>" condition ")"
```

Bounds are an Ada-static, nonempty Integer range. A positional aggregate has
exactly one Boolean expression for each element, in ascending index order; the
named form is admitted only for a singleton array, with its exact static index.
All expressions read the same incoming declaration store before the new array
becomes visible. Earlier initialized Boolean objects and array components may
supply values, alongside the existing condition forms. Each value is stored
independently; later writes to a source object do not change these snapshots.

The component mark must resolve to predefined `Boolean`. An earlier named
Integer subtype named `Boolean` instead selects the Integer-array rules. A
Boolean array cannot itself be named `Boolean`. Other predefined names and
operations follow the existing declaration and loop hiding rules, including
hiding in the new object's own initializer. Integer and Boolean arrays share
the existing source-derived descriptor and component-storage limits.

A Boolean indexed read is `A(scalar_index_expression)` and may appear in any
Boolean initializer, Boolean assignment RHS or condition. Its index contains
no array read, has a nonempty inferred Integer interval and lies wholly within
A's declared bounds. The index rule applies in unreachable arms and empty
loops as well: the pinned frontend can reject statically invalid subscripts
there, and Silver uses one conservative rule for all such paths. The prefix
plus the index's operands must fit the 64-operand limit; subscript arithmetic
shares the existing 63-operator budget. No new whole-condition operand limit
is imposed.

An indexed write is `A(scalar_index_expression) := condition;`. A must be a
visible mutable Boolean array; the index and RHS read the incoming state. The
write replaces exactly the selected Boolean cell and preserves all other
values, array bounds and existing scalar and String/input facts. Writes carry
across iterations of existing loops. Reading a stored component never recovers
facts about the condition that produced it; for example, a stored `N /= 0`
does not justify division by N. Checking each initializer and RHS still follows
the ordinary eager and short-circuit condition rules.

This fragment deliberately excludes `others`, general named associations,
parentheses around a whole aggregate, Boolean range constraints, Boolean
array iteration and whole-array assignment, comparison, copying, slices,
concatenation or attributes. These are Silver scope limits for explicit bounded
initialization and component operations, not Ada restrictions. Boolean values
cannot be used as Integer, Character or String expressions. Existing Integer
array iteration and counted loops can contain Boolean component reads/writes.

### Scoped finite for loops

```text
for_loop ::= "for" index_name "in" [ "reverse" ]
             scalar_expression ".." scalar_expression "loop"
             statements "end" "loop" ";"
```

A counted-loop bound cannot directly read a constant-array component, including
within a larger arithmetic expression. Mutable-array components, scalar
snapshots taken in earlier declarations, and constant-array `for ... of` iteration
remain admitted under their ordinary rules. This conservative Silver scope
restriction avoids pinned-frontend and proof-translation failures when constant
component values determine a loop range; it is not an Ada restriction.

Bounds are evaluated once on loop entry. A forward loop visits the inclusive
range in ascending order; `reverse` visits that same range in descending order.
Assignments to objects used in the bounds do not change that iteration sequence.
Each nested loop captures its bounds when entered. Scalar and String writes
carry across iterations and remain visible after the loop; only the scoped
index is removed on exit. An empty loop preserves both stores.
A lower bound greater than the upper bound gives zero iterations in either
direction. A body is nonempty and may contain any admitted statement, including
nested loops, choices, String and Integer assignments, output and argument-shell Reject.
The index is immutable and disappears on loop exit. Declarations stay in the
single outer declaration region; `exit`, `while`, unconstrained loops and
explicit iteration steps are excluded.

Indexes may hide a String, an Integer or Boolean object, an Integer or Boolean array, an enclosing index, an enclosing
element or a use-visible operation. The index's own name is hidden in both bounds: an inner
`for I in 1 .. I` cannot use the outer `I`. Differently named enclosing indexes and elements
remain available, as in `for J in 1 .. I`. Sequential loops may reuse names.
Index names obey the identifier/reserved-word rules and cannot be `Silver_IO`,
or `Silver_Arguments` in an argument shell. Unlike ordinary declarations, an
index may be named `String` or `Integer`; `Integer` then hides the Image type
mark within the body. Qualified library calls remain available when an index
hides an unqualified operation.

For bound intervals `[a,b]` and `[c,d]`, the body index interval is `[a,d]`, or
empty if either bound interval is empty or `a > d`. The loop is definitely
nonempty when both intervals are nonempty and `b <= c`. Admission checks the
body once over this interval, without enumerating iterations or inferring
loop-carried scalar invariants. Infer and capture both bounds in entry flow
before widening every mutable scalar to its declared range for body analysis.
Retain entry immutable and outer-index facts, then append the new index identity
and its captured interval. A guard immediately inside the body may narrow that
iteration's reads. Preloop or earlier-iteration mutable facts cannot justify a
later iteration. Even a read-only, possibly executing loop loses mutable
precision.

An abstractly empty loop restores entry scalar flow. Every possibly executing
loop returns mutable intervals widened to their declared ranges, restores entry
immutable and outer-index facts, and removes its new index identity. Body-derived
outer-index refinements do not escape. The independent input/String transfer is
unchanged: an empty loop preserves entry path facts; a definitely nonempty loop
retains body exit path facts; an uncertain loop joins entry and body exit path
facts. Every String assignment preserves its object's fixed bounds. Finite
Integer ranges establish termination; the application proof configuration
disables loop unrolling.

More precise captured bounds can intentionally exclude an earlier admitted
source: after `X := 0`, `for I in 1 .. X loop R := I; end loop;` has an empty
index interval, so the retained nonempty assignment-RHS rule excludes it. A
contradictory guard does not waive this rule. There is no blanket claim that
scalar refinement preserves admission of every earlier source.

### Constant Integer-array iteration

```text
array_iteration ::= "for" element_name "of" [ "reverse" ]
                    constant_integer_array_name "loop"
                    statements "end" "loop" ";"
```

The iterable is one visible, existing constant Integer-array object from the
declaration region. The loop visits every component once, in increasing index
order, or decreasing index order with `reverse`. Its identity and bounds are
selected once on entry. The element denotes the actual component under Ada's
iterator semantics; the array is constant and no admitted operation can change
its components. No array snapshot or source rewriting is involved.

The scoped element is immutable and nonstatic. Its entry interval is the
declared component range: full Integer for `of Integer`, or the named subtype's
range for `of S`, independent of the particular initializer values. A guard
on its bare name may refine its reads in that iteration, under the existing
scalar-guard rules. It neither refines array cells nor supplies an Ada-static
threshold. Element facts do not carry into another iteration or escape the loop.

Element names follow the counted-loop index rules, including hiding outer
objects, indexes, elements and use-visible operations. The new name is hidden
in its own iterable specification: `for A of A loop` cannot select an outer
array `A`. A nested binder hiding the array's spelling does not change the
identity already captured by an enclosing iteration. An element named `Integer`
hides the Image type mark in its body. Sequential loops may reuse element names.

The nonempty body may contain every admitted statement, including either loop
form, guards, assignments to other mutable objects, output and argument-shell
Reject. Mutable scalar facts are widened before body analysis; entry immutable
and enclosing-loop facts are retained. On exit, mutable facts remain widened,
entry immutable and enclosing-loop facts are restored, and the element binding
is removed. Every admitted array is nonempty, so the independent String/input
flow keeps body exit facts. Writes to other objects carry across iterations and
remain visible after the loop.

Mutable iterables, assignment through an element, subtype indications, iterator
filters, slices, array-valued expressions and general iterators are excluded.
These are scope limits for this constant-array fragment. Source, expression and
operator limits are unchanged; there is no separate iteration-count limit.

### Standard Integer Image

`Integer'Image (scalar_expression)` is a String atom in ordinary initializers,
assignment values, comparison operands and output, including concatenations.
Its one positional scalar argument is mandatory; named association, other
scalar images and `Standard.Integer'Image` are excluded. It uses Ada's standard
decimal bytes: a leading space for nonnegative values, a minus sign for negative
values, then the decimal magnitude without leading zeroes. Zero is `" 0"`.
No trimming, replacement formatting or hidden application source is involved.

For value `v`, image length is one plus the number of decimal digits in `abs v`,
with zero having one digit. Signed 32-bit images therefore have lengths 2 through
11. For an interval, the maximum is the larger endpoint length; the minimum is
2 when the interval crosses zero, otherwise the smaller endpoint length. An
empty interval records no possible value, with zero Image length contributions.
Image is one String leaf; its scalar argument has its own sixty-four-leaf limit,
and all operators still share the source budget below.

### Common String expressions

Initialization, assignment, both operands of String equality/inequality, and output use:

```text
expression ::= atom { "&" atom }
atom       ::= L | initialized_string_name | "(" expression ")"
             | "Integer" "'" "Image" "(" scalar_expression ")"
             | fixed_bound_string_name "(" scalar_expression ".." scalar_expression ")"
```

A String expression has one through sixty-four leaves. A literal, name or Image
counts as one; a slice counts its prefix name and every scalar leaf in both
endpoint expressions. Each occurrence counts, including empty values and repeated names. Parentheses control grouping;
unparenthesized concatenation associates to the left. The catalogue's `association`
field for concatenation records this default; its separate parentheses flag
permits explicit grouping. There is no independent
parenthesis-depth limit beyond the complete-source bound. An indexed read has
Character type and cannot be a String atom. Other operators and implicit conversion
are excluded. References resolve to
initialized objects in the common declaration environment. The output may omit
an assignment target entirely.

A slice prefix follows the same fixed-bound String visibility rule as an indexed
read. Its endpoint Integer expressions must each infer a nonempty interval and
pass their ordinary arithmetic checks. For lower interval `[a,b]`, upper interval
`[c,d]` and prefix bounds `B .. E`, admission requires either `a > d` (every
possible slice is null), or `a >= B` and `d <= E` (every potentially nonnull
slice stays in the prefix). Additionally, `b - c <= 2147483647` must hold,
calculated in wide arithmetic. This bounds every possible inverted endpoint
separation so the pinned native equality expansion cannot overflow its signed
Integer endpoint subtraction. The rule applies before any slice consumer,
including copies and concatenations; ordinary null slices remain permitted.
Its length interval is
`max(0,c-b+1) .. max(0,d-a+1)`, calculated in wide arithmetic. Null slices retain
the requested inverted bounds, even outside the prefix; they are not rewritten
to `1 .. 0`. For example, `S (0 .. -1)` is null. Nonnull slices retain their
requested lower bound. Slices may be grouped, concatenated, compared, output
and assigned under the ordinary String length rules.

Both slice endpoints must be Ada-static in an `if`, `elsif` or `else` region,
including the conditions, and after any `and`, `or` or `xor` token since the
preceding semicolon in the current declaration or statement. Whole tokens count;
comments and String/Character literal contents do not. Closing `end if` leaves
its region, and a semicolon resets the Boolean-chain restriction. This uniform
Silver restriction prevents conditional frontend facts from turning admitted
nonstatic slice bounds into a native build failure, even in contradictory arms.
It deliberately also excludes some reachable slices that GNAT accepts. Outside
these contexts, endpoints may remain nonstatic under the interval rules above.

Concatenation retains a nonnull left operand's lower bound and has the sum of
the operand lengths. If the left operand is null, the result takes the right
operand's bounds, including its actual inverted bounds when both are null.
Grouping preserves Ada's corresponding intermediate bounds. A fixed-length
initializer must infer exact first and last bounds as well as exact length;
this makes subsequent indexing decidable from stored declaration metadata.
Whole-String assignment slides equal-length RHS bytes onto the target's unchanged
bounds. Strings with different lower bounds can therefore be assigned or compared.

Let `[M,N]` be the sum of the non-input length intervals: decoded literals,
fixed-length String names, slices and Image lengths. Let `K` count dynamic input-length
occurrences, including aliases, and `d` be the selected argument length. The
expression length lies in `[M + K*d, N + K*d]`; without a varying Image length,
`M = N` and this is the earlier exact affine length. Concatenation sums both
endpoints and counts occurrences with multiplicity.

Every expression and intermediate String must fit 4096 bytes. Admission always
requires `N <= 4096`, and requires `N + K*C <= 4096` for reachable evaluations,
where `C = 4096` in initializers and is the greatest currently reachable valid
input length in the body. Invalid input contributes length zero and is tracked
separately. Initializers require equal non-input endpoints and cannot borrow
later guards. Nonnegative operand lengths make the total bound cover every
intermediate concatenation.

Assignment requires both RHS length endpoints to equal the target's fixed or
symbolic length throughout the reachable input interval and at zero when invalid
input remains reachable. A varying image length cannot be assigned to a fixed
target merely because its maximum fits: an index from 9 through 10 has Image
lengths 2 through 3, so neither a two-byte nor a three-byte target is compatible.
An index from -9 through 9 always has Image length 2 and can use a two-byte target.

For a nonempty RHS and a static target of length `T`, both non-input endpoints
must be at most `T`, and both must equal `T` when `K = 0`, even in unreachable
arms. An Image over an empty index interval makes the expression unevaluated;
its other non-input contributions still count toward the 4096-byte limit and
its minimum retained contribution must fit a static target. Thus an empty-loop
assignment of `"too long" & Integer'Image (I)` to a one-byte target is excluded.
Names, types, mutability and static scalar legality remain checked everywhere.

The source has at most **63 operators shared by String concatenation and scalar
arithmetic**: every `&`, unary or binary `+`/`-`, `*`, `/`, `mod` and `rem` across declarations,
range constraints, subscripts, slice endpoints, loop bounds, all statements and predicate
operands in every arm counts. Operator characters in String/Character literals and comments and a numeric exponent's `+` do not count.
Each whole `mod`/`rem` keyword counts once. Copies, parentheses, comparisons
(including `/=`), Boolean logical operators and Image itself consume no operator
budget. Boolean literal/name leaves do not create a separate Boolean operand
limit; each embedded Integer, String or Character expression retains its own 64-leaf limit.
This explicit proof-work policy permits a maximal 64-leaf expression or the
same operator total distributed across positions. The expression and source
budgets do not bound iteration count, elapsed execution or total proof cost.
They are Silver resource policies, not Ada/SPARK restrictions or solver-time
guarantees; the [For loops and integers delivery](docs/for-loops-integers.md),
[bounded mutable Integer delivery](docs/bounded-mutable-integers.md) and
[mutable report-capacity record](docs/bounded-mutable-report-capacity.md) give
the associated report-capacity and validation evidence.

### Statement sequences and fixed-bound assignment

Every output-capable body contains a nonempty sequence of these statements:

```text
statements       ::= statement { statement }
statement        ::= basic_statement | string_choice | for_loop | array_iteration
basic_statements ::= basic_statement { basic_statement }
basic_statement  ::= "null" ";"
                   | reject_name ";"
                   | mutable_name ":=" expression ";"
                   | mutable_character_name ":=" character_expression ";"
                   | mutable_fixed_bound_string_name "(" scalar_expression ")"
                     ":=" character_expression ";"
                   | mutable_integer_name ":=" scalar_expression ";"
                   | mutable_boolean_name ":=" condition ";"
                   | mutable_integer_array_name "(" scalar_index_expression ")"
                     ":=" scalar_expression ";"
                   | mutable_boolean_array_name "(" scalar_index_expression ")"
                     ":=" condition ";"
                   | output_name "(" [ "Item" "=>" ] expression ")" ";"
string_choice    ::= "if" condition "then" statements
                     { "elsif" condition "then" statements }
                     [ "else" statements ] "end" "if" ";"
```

`output_name` and `reject_name` are the corresponding qualified or unqualified
names under the context and hiding rules above.

The same sequence forms an argument-input body; its own predicates and rejection
calls must meet the path rules below. Reject is available only in that shell.
Statements execute in source order. Null does nothing. String assignment evaluates the
RHS using the current store, replaces the target's bytes and preserves its fixed
bounds and every other object's value. Only initialized mutable names are targets;
constants and the original argument binding cannot be assigned. Assignment
requires the interval endpoint compatibility above on every reachable input,
including equality established by a preceding String or Length predicate.
Static target restrictions also apply in dead arms, independently of operand
order and the frontend's dead-code simplification. Dynamic targets retain the
reachable-path equality rule.
Empty values and self-copy are legal. For example, inside `if Input'Length = 3`,
a variable initialized from Input can receive a three-byte static value. `:=` is one
contiguous token.

Integer assignment evaluates the RHS in the current scalar store and changes
only its target. The target must be a visible mutable Integer object; constants,
loop indexes, loop elements and hidden outer objects cannot be assigned, including in empty
loops or unreachable arms. Every RHS intermediate must fit Integer and its
whole inferred interval must be nonempty and lie within the target's declared
range. Requiring nonemptiness is a Silver frontend-acceptance restriction:
pinned GNAT still checks predictable assignment range errors in dead loop bodies
under `SPARK_Mode (On)`. Thus an assignment depending on an index whose inferred
interval is empty is excluded even when a particular instance would compile. Empty loops
may still contain assignments whose RHS has a nonempty interval. Infer the RHS
in incoming flow and check inclusion against the immutable declared range,
then replace only the target's current read interval with the inferred RHS
interval. Do not intersect the replacement with the target's old guard facts.
Thus `X : Integer range 0 .. 9 := 0` excludes an unguarded body update
`X := (X + 1)` initially, but permits it after `X := 0` or inside `if X < 9`.
A write to another scalar preserves X's facts. String writes preserve all scalar
facts; immutable scalar and String snapshots remain unchanged.
Existing input-length facts remain valid across scalar writes. Image reads in
the body use the current flow interval; equality to an earlier Image does not
create a persistent fact about a later live Image.

For example, snapshots remain unchanged across later updates:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Message : String := "Hello";
   Original : constant String := Message;
begin
   Silver_IO.Put_Line (Message);
   Message := "World";
   null;
   Silver_IO.Put_Line (Original & " / " & Message);
end Main;
```

There is no separate statement or output-count limit. The 4096-byte source limit
and existing expression/operator budgets still apply. Declarations stay in the
single ordered declaration region. The context-free null program remains exactly
the earlier null shell; a multi-statement body uses the output-capable context,
even if every statement is null or assignment.

Compilation cost can be substantial even without concatenation: a 4096-byte
program containing 800 assignments proved in 36.4 minutes with 8.89 GiB peak
process-group memory on the reviewer's Linux sandbox. Its Main report was
1,734,274 bytes of the historical 2 MiB application capacity. A 4095-byte argument-input
program with 769 assignments proved in 49.5 minutes with 9.99 GiB peak
process-group memory. Its 1,983,843-byte report leaves 113,309 bytes (5.4%) of
headroom. These are observations for those programs and host, not worst-case
bounds. A later review compiled the 4095-byte, 782-assignment argument-input
specimen: all 826 checks proved and its 2,013,253-byte report uses 96.0% of the
buffer, leaving 83,899 bytes (4.0%). The reviewer reported 33.6 minutes and
6.1 GiB peak memory while other probes ran; this is not a clean performance
benchmark or a universal report-size bound. The
Names and Calls review also completed a 4092-byte, 785-assignment specimen:
829 checks proved and its 2,020,723-byte Main report uses 96.4% of the buffer,
leaving 76,429 bytes (3.6%). The reviewer reported 32 minutes; no duplicate timing
run was made. The [Names and Calls capacity record](docs/names-and-calls.md#dense-assignment-review-evidence)
identifies that retained measurement. The
[Larger Expressions dense probe](docs/larger-expressions.md#dense-composition-and-report-capacity)
combines 758 assignments and 63 concatenations in 4096 bytes. It proved all
865 checks in 53.6 minutes, with 8.71 GiB sampled aggregate process RSS and a
2,065,005-byte Main report, leaving 32,147 bytes (1.5%) in the historical 2 MiB
buffer. This was a separate fresh-session probe, not production `silver compile`.
Review B1 later found a denser static-shell construction with only 0.28–0.29%
headroom; timing-dependent prover credits can exceed that margin. The
[capacity correction](docs/review-343c2f8-repairs.md#report-capacity-correction)
distinguishes the deterministic floor and measured credits. The
[report-capacity repair](docs/report-capacity.md) derived the earlier 16 MiB
allocation. The [fixed-array extension](docs/fixed-integer-arrays-report-capacity.md)
raises retained Main report storage to 32 MiB, accounting for repeated loop
initialization advisories within the same 4,096-byte source budget. The
[constant-iteration extension](docs/constant-array-iteration-report-capacity.md)
also accounts for shorter loop syntax and implicit component accesses within
that allocation. These specimens do not
establish a universal resource bound. The
[branch capacity assessment](docs/branches.md#bounded-5bc-capacity-assessment--2026-10-14)
records the specimen and smaller matching probe. The original
[capacity follow-up](docs/statement-sequencing.md#external-review-and-capacity-follow-up)
records the measured shapes, results and their limits.
Sufficient host resources and pinned-tool completion remain operational premises;
failed compilation of admitted source is still a defect, never nonmembership.

### Predicates and conditional statements

```text
condition        ::= relation { "and" "then" relation }
                   | relation { "or" "else" relation }
                   | relation { "and" relation }
                   | relation { "or" relation }
                   | relation { "xor" relation }
relation         ::= expression ( "=" | "/=" ) expression
                   | scalar_expression comparison scalar_expression
                   | character_expression comparison character_expression
                   | name "'" "Length" comparison length_operand
                   | boolean_factor [ ( "=" | "/=" ) boolean_factor ]
boolean_factor   ::= primary | "not" primary
primary          ::= validity_name
                   | visible_boolean_name | visible_boolean_literal
                   | visible_boolean_array_name "(" scalar_index_expression ")"
                   | "(" condition ")"
comparison       ::= "=" | "/=" | "<" | "<=" | ">" | ">="
length_operand   ::= integer_literal | name "'" "Length"
```

`validity_name` follows the same context and hiding rules as the other calls.

String equality/inequality compares current bytes, case-sensitively. Unequal lengths
compare unequal. At least one operand must contain an initialized String name, slice or
Integer Image so Ada resolves the array type. Both operands must fit their incoming
path bounds before the comparison can establish any further facts.

Length predicates may read any earlier initialized String binding, including an alias or
mutable object; Character objects have no Length. Length remains fixed after initialization. The left operand must be a
binding's Length. Reversing a literal and Length is excluded to keep one canonical
comparison orientation in this initial predicate fragment. Arithmetic and attributes
other than Length are excluded from these length operands; the separate scalar
comparison grammar above admits Integer arithmetic. Ordering String bytes is excluded
because this fragment refines lengths, not lexical order. These are current scope
limits, not inherited Ada restrictions. The validity query is available only in the
argument-input shell and has no parentheses of its own. Visible predefined
`True` and `False` denote Boolean literals. Boolean equality and inequality
compare Boolean factors; ordering is excluded. The optional `not` belongs to its
factor, so `not Flag = True` compares `(not Flag)` with `True`, following Ada.
Comparing Boolean factors conservatively returns unchanged incoming facts on
both outcomes; facts established while evaluating a factor do not escape the
comparison.

`and then` evaluates its right operand only after a true left operand; `or else`
evaluates it only after a false left operand. That path's facts justify the right
operand. A chain uses exactly one of `and then`, `or else`, `and`, `or` or `xor`;
mixing them requires parentheses, following Ada's grammar. `not` takes one
primary, so a String, Character or Integer comparison requires `not (A = B)` and repeated
negation requires grouping. Eager `and`, `or` and `xor` evaluate both operands.
Each operand must be safe under the original incoming facts, independently of
the other operand's outcome; neither can guard the other. Both result outcomes
conservatively retain the original incoming scalar and String/input facts.
Neither operand of `xor` may contain another `xor`, including the implicit left
operand of a chain. Thus `A xor B` and independent `(A xor B) and (C xor D)`
are permitted, but `A xor B xor C` and `A xor (B xor C)` are excluded. Operator
spellings inside String or Character literals, comments or longer identifiers do not count.
This Silver resource restriction prevents repeated duplication by the pinned
proof producer's xor expansion; Ada itself allows the excluded forms. Multiple
parity steps can use ordinary Boolean assignments or initializers.
For example, `D /= 0 and (1 / D) = 1` cannot use the left test to justify its
division, whereas `D /= 0 and then (1 / D) = 1` can when the established interval
excludes zero. Parentheses and `not` retain existing short-circuit transfer rules.

A conditional executes the first true arm, its optional else, or no statements
if every condition is false and else is absent. Each written arm is nonempty and
may contain null, assignment, output, Reject in an argument shell, and nested
conditionals and loops. Multiple conditionals and elsif arms are permitted up to the
complete-source bound, without a separate count or nesting cap.

True String equality (or false inequality) requires overlap of the operand
length intervals and refines the input-length interval accordingly. Equal
dynamic occurrence counts retain a path only when the non-input intervals
overlap; unequal counts derive lower and upper input-length bounds using
integer ceiling/floor division. For example, equality of `Input & Input`
with a two-to-three-byte Image leaves only input length 1. False String
equality does not imply unequal lengths. This does not narrow scalar intervals
or establish equal bytes for later mutable reads.
Length comparisons refine the valid-input interval and the invalid-input case.
An assignment preserves length facts because it preserves bounds, even when the
bytes change. A join keeps an interval covering both arms and retains guaranteed
invalid-input rejection only when every reachable invalid arm has rejected.
An omitted else joins the unchanged false path. Admission does not track general
mutable byte equalities across statements or disjoint sets of valid lengths;
these deliberate analysis limits keep composition and automatic discharge bounded.

### Integer literals in length predicates

An integer literal has value 0 through 4096. This scope limit keeps comparison
thresholds within the admitted String-length domain; larger thresholds and their
constant-result simplification are not part of the current analysis. Decimal
digits and leading zeroes
are admitted, with single underscores only between digits. Based literals use a
base from 2 through 16, decimal base spelling and appropriate case-insensitive
extended digits; both matching `#...#` and `:...:` delimiters are admitted under
Ada 2022 J.2(3). Examples include `4_096`, `016#0_FF#` and `2:11:`.

An optional `E` exponent contains decimal digits, may have a leading `+`, and
may use separators and leading zeroes. It multiplies by the numeral's base.
The exponent value is at most 4096, even for zero; this is an explicit frontend
resource limit, not Ada's universal-integer range. Parsing checks each operation
before overflow. There is no separate digit-count limit within the source bound.
Negative exponents (including `E-0`), fractions and mismatched delimiters are
excluded by integer-literal rules. Unary plus/minus are expressions rather than
literal spelling and remain outside this length-operand fragment, which does
not yet interpret general integer expressions. These exclusions do not claim
that Ada itself forbids signed expressions or larger integer values.

### Command-line initialization and path requirements

One declaration `D : constant String := initializer_name ([Default =>] L);`
follows the pragma before all other
declarations. It is the only initializer API call. Its immutable, one-based
String may be copied by later ordinary declarations. Initializers run before
body predicates, so later facts cannot justify earlier initialization.
Here `initializer_name` is `Silver_Arguments.First_Or_Default` or its unqualified
name under the context and hiding rules; square brackets describe the optional
named association and are not written Ada syntax.

The body may place predicates, assignments and returning Reject calls within
ordinary sequences and nested branches. Every possible invalid-input execution
must perform Reject and must make no output call. An explicit validity query is
one way to establish a safe path; a positive input length also excludes invalid
input because its initializer is empty. Output still needs the expression bound.
Reject sets failed status and returns: it does not terminate the path or provide
any validity/length fact. Later statements must remain safe and preserve the
invalid-input no-output requirement. A program may reject valid input by its own
logic, including an input-capacity rule.

The familiar outer guard is an instance of these rules:

```ada
if Silver_Arguments.Input_Is_Valid and then Name'Length <= 4088 then
   Silver_IO.Put_Line ("Hello, " & Name & "!");
else
   Silver_Arguments.Reject;
end if;
```

The guard may use a smaller capacity, other admitted literal spellings or an
alias's fixed Length. Repeated dynamic references require the corresponding
bound, such as `Name'Length <= 2048` before `Name & Name`. Safety facts apply
only where established; joining a small-length arm with an unrestricted arm
does not retain the small bound. Reject in an oversized arm also cannot justify
an unsafe expression after that join because Reject returns.

The [path-guard sample](samples/path_guards.adb) combines length alternatives,
short-circuiting, a branch-refined assignment, snapshots and rejection. The
[conditional-statement sample](samples/conditional_statements.adb) and older
fixed-guard samples remain instances of the same rules.

### Shared composition rules

Whitespace around punctuation is optional; adjacent word tokens require a separator,
and the final-bracket literal rule above also applies. Declarations precede the
entire executable body. Statements and recursive choices and loops compose under the
shared state, expression and effect rules; path facts and rejection requirements
apply at each executed operation and join. No application can call `Ada.Text_IO`,
libc imports or an unlisted library API.

The catalogue uses these construct identifiers:

| Capability | Admitted scope |
| --- | --- |
| `main_procedure`, `spark_mode_on`, `null_statement` | Fixed Main skeleton, required pragma, separate null shell and basic null statements. |
| `runtime_context`, `argument_context` | Grouped, reordered or repeated with/use clauses for the shell's exact package set; with precedes use. |
| `string_literal`, `named_string_constant`, `named_string_variable` | Restricted literals and ordered initialized constant/mutable declarations. |
| `string_copy` | Snapshot initialization and current name reads for compatible assignments. |
| `string_expression`, `string_concatenation` | One through sixty-four leaves, including slice endpoint leaves; sixty-three operators shared with scalar arithmetic. |
| `character_literal`, `named_character_constant`, `named_character_variable`, `character_expression`, `character_comparison`, `character_assignment` | Printable Character values, initialized snapshots, assignment and all six comparisons with typed operands; no implicit String conversion or retained comparison facts. |
| `string_indexing`, `string_element_assignment`, `string_slice` | Fixed-bound String reads, element writes and bounded slices, with nonempty inferred index/endpoint intervals, actual lower bounds and explicit null-slice rules. |
| `scalar_integer_literal`, `named_integer_constant`, `named_integer_variable`, `integer_range_constraint`, `integer_expression`, `integer_assignment` | Scalar numerals, initialized Integer objects, optional static object constraints, checked interval arithmetic and range-preserving assignments. |
| `named_integer_subtype` | Direct Integer subtype declarations with nonempty static ranges, scalar object subtype marks and bounded fixed-array component marks. |
| `integer_array_object`, `integer_array_read`, `integer_array_assignment` | Explicitly initialized anonymous fixed-size Integer arrays, nonempty interval-checked subscripts and component-preserving indexed assignment. |
| `boolean_array_object`, `boolean_array_read`, `boolean_array_assignment` | Explicitly initialized fixed-size Boolean arrays, typed indexed reads and mutable cell writes; stored flags retain no scalar or String/input facts. |
| `integer_array_iteration` | Forward/reverse iteration over constant Integer arrays, with immutable nonstatic elements, declared component entry bounds and existing guard/statement compositions. |
| `named_boolean_constant`, `named_boolean_variable`, `boolean_assignment`, `boolean_expression`, `boolean_comparison` | Initialized scalar Boolean objects, snapshot copies, assignment, logical expressions and Boolean equality/inequality under the visibility, evaluation and xor restrictions above; stored flags retain no scalar or String/input facts. |
| `integer_comparison`, `scalar_guard_refinement`, `integer_image`, `for_loop` | Bare mutable/index/element names against static thresholds, current read intervals with assignment replacement and branch hulls, standard decimal Image and scoped finite loops with captured bounds and mutable widening. |
| `expression_output`, `literal_output`, `named_output`, `concatenated_output` | Returning output calls with qualified or visible unqualified names and positional or `Item =>` actuals. |
| `argument_initialization`, `input_guard`, `capacity_guard`, `argument_rejection` | First/unique immutable input with positional or `Default =>` literal, path-derived validity/capacity and returning rejection; existing calls follow the shared visibility rules. |
| `string_equality`, `string_choice` | Nested predicates with nonempty statements, repeated `elsif`, optional `else` and path refinement. |
| `length_predicate`, `boolean_predicate`, `integer_literal` | Fixed-bound length comparisons, grouped short-circuit logic and bounded decimal/based integer spelling. |
| `string_assignment` | Fixed-bound assignment, including self-copy and path-established length equality. |
| `statement_sequence`, `basic_statement_sequence` | Nonempty finite ordered statements; basic sequences contain null, assignment, output and argument-shell Reject; general sequences also contain choices and loops. |

Everything else is excluded, including derived scalar types, subtype alias chains, conversions,
other loop forms,
Boolean operations outside the specified fragment,
additional declaration regions, resizable strings, other array
operations, access types and file handles.
The catalogue's token arrays are informative skeletons, including qualified,
positional call examples; their construct conditions specify the context,
visibility and association alternatives. They are not a separate complete grammar.

## Meaning and assurance

`SPARK_Mode (On)` selects analysis without adding executable computation. Null
performs no action and returns normally. Runtime startup and external execution
conditions remain within the [trusted boundary](docs/trusted-boundary.md).

An output expression concatenates its operands' values in order; no separators
are inserted. Each name contributes its current bytes; declaration copies keep
their own snapshots when the original is later assigned. A dynamic-length binding contributes its current bytes, which assignments may
change while preserving its initially selected length. Each occurrence counts independently.
Literals preserve decoded bytes, including empty Strings and
escaped quotes. `Put_Line` requests the resulting bytes followed by exactly LF
(byte 10); `Put` requests just the resulting bytes. An empty `Put_Line` requests
one LF, while an empty `Put` writes no bytes. Both request a flush, including
empty `Put`; neither inserts separators between calls.

Command-line forms observe the arguments after the executable-name slot,
which normal supported startup supplies (`argc >= 1`):

| Input | Selected value and execution |
| --- | --- |
| No arguments | Select the decoded default. |
| Exactly one argument of 0 through 4096 printable ASCII bytes | Select those exact bytes, including an explicitly empty argument. |
| Extra arguments, an argument longer than 4096 bytes, or any byte outside 32 through 126 | Reject with status 1 and no application output. |

Valid input follows the written body predicates; a program may impose a smaller
capacity or reject for another specified condition. The initializer and validity
query observe the same immutable GNAT argument vector. Invalid input produces an
empty initializer, which may participate in safe assignments, but every admitted
invalid path must reject and cannot output. Retrieving an argument precedes its
length check; the input limit does not bound GNAT's allocation. Storage exhaustion
remains environmental. See the [argument boundary](docs/trusted-boundary.md#command-line-boundary).

The compiler convenience `silver run SOURCE -- [arguments...]` forwards the
suffix as the application's exact argument vector. It does not filter bytes or
relax the application input rules above. A bare `--`, or `silver run SOURCE`,
supplies no application arguments. Ordinary application exit statuses are
preserved; status 1 alone does not identify Reject, output failure or a failed
launch. The [CLI documentation](README.md#use-the-compiler) specifies diagnostics
and the external process/resource boundary.

Successful output requires every byte write and the final `fflush(NULL)` to
succeed. Completion means host-stream acceptance, not reader consumption or
durable storage. A detected write/flush failure sets status 1 and returns from
`Put` or `Put_Line`; later statements and output calls still execute. A subsequent
success never clears a failed status. Accepted bytes concatenate in call order;
under failure the cumulative bytes need not be a prefix of the full intended
output. For `n` executed output calls the accepted trace has at most `n * 4097`
bytes; a `Put` contributes at most 4096 and a `Put_Line` at most 4097.
Reject sets status 1 and returns to the following statement. Partial output may
remain, including bytes flushed by runtime finalization. Signals such as SIGPIPE
may terminate the process before an imported call returns. External blocking,
storage exhaustion and process failure remain environmental; progress is an
explicit assumption. Standard output must be initialized and must not be
concurrently written or rebound. These
[external effect assumptions](docs/trusted-boundary.md#literal-output-boundary)
are unchanged.

Membership decides source shape, binding, operand counts, assignment
length equality and every initializer/body/intermediate value bound before invoking a prover. Initialization
establishes bytes and fixed bounds; assignments preserve each target's bounds
and other objects' snapshots. Argument normalization establishes a one-based
String of at most 4096 printable bytes. Path-sensitive predicates establish
validity and output-domain bounds for `D` and its dynamic aliases. The universal argument
must cover all admitted names, declarations, copies, argument vectors and paths.

Literal/static expressions and plain name output may have no Main safety checks.
Runtime concatenation and constrained scalar initialization/assignment can emit
range checks; copied dynamic-length assignments can emit length checks; scalar
arithmetic can emit overflow checks, division/remainder can emit nonzero-divisor
checks, and indexed array/String reads and writes can emit index checks. Every emitted Main
safety record must be a proved/info `VC_RANGE_CHECK`, `VC_LENGTH_CHECK`,
`VC_OVERFLOW_CHECK`, `VC_DIVISION_CHECK` or `VC_INDEX_CHECK`, with complete coverage, approved dependencies and no
suppression. Length checks require the fixed-bound argument; their absence through
static elimination is no longer a prerequisite for supporting copies.

All output policies classify finite lists of the exact `INEFFECTIVE` initializer
advisory. Assignment-bearing policies also classify the exact `unused assignment`
advisory. All output-capable policies also classify the exact `INEFFECTIVE` message
`statement has no effect` and `DEAD_CODE` message `this statement is never reached`,
produced by statically known predicates. Repeated output additionally permits only
the four exact `INEFFECTIVE` messages naming the overwritten ghost outputs
`Written_Count`, `Flushed`, `Succeeded` and `Written_Bytes` of either `Put` or
`Put_Line` (eight exact messages). These flow advisories retain Main location, flow
provenance and no suppression. Initializers still establish object bounds even when
their bytes are unused. The warning list additionally permits only the exact producer
`imprecise-image` advisory, including its full message with exactly the producer's
`Image`, `image` or `IMAGE` spelling and its producer state; it never
discharges or removes a safety check. The [assurance policy](docs/assurance.md)
specifies its native/SARIF classification. Other warnings in the audited reports
fail; naming conventions that make GNATprove omit an advisory do not change
membership.

Faithful static evaluation, complete obligation/report generation, completeness
of the accepted producer shapes and pinned solver completion for the bounded
range/length/index/overflow/nonzero-divisor fragment remain explicit
[tool premises](docs/trusted-boundary.md#source-identity-and-program-proof-evidence).
Native examples corroborate them; they do not prove universal assurance.
Complete selected-library obligations remain mandatory for every output compile.
See [assurance.md](docs/assurance.md) and the
[For loops and integers delivery](docs/for-loops-integers.md) and
[bounded mutable Integer delivery](docs/bounded-mutable-integers.md) for exact
validation scope and subsequent review repairs.

Authors supply neither contracts nor proof annotations. Admission, proof and
compilation use the same source bytes, snapshotted as `main.adb`. Every output
shell selects the same six library files: the `Silver_IO` spec/body,
`Silver_Output_Libc` spec, `Silver_Arguments` spec/body and `Silver_Runtime` spec.
The compiler copies them unchanged, checks their identity after proof and build,
and audits all four library-unit reports. Null selects no libraries. A proof or
build failure for admitted source is an implementation/toolchain defect; a
specified environmental execution failure is an outcome, not source rejection.

## Examples and growth

The [sample manifest](samples/manifest.json) records each supported sample's
capabilities and expected output/status. Existing null, literal, named, command-line,
greeting, assignment and branching samples remain instances of the complete shells
above. Tests admit, prove, build and execute the samples; examples exercise the rules
without replacing universal assurance. The [triangle](samples/for_loop_triangle.adb),
[specified-step values](samples/for_loop_step.adb) and [reverse
countdown](samples/for_loop_countdown.adb) exercise loop, immutable Integer
and standard Image forms. [Find square difference](samples/find_square_difference.adb)
uses a constrained mutable result and prints the first satisfying index, 501.
The [100 doors sample](samples/rosetta_100_doors.adb) uses a guarded visit
counter and prints every door's final state; its expected bytes come from an
independent pass-major toggle model. Its validation evidence is recorded in the
[guard delivery record](docs/scalar-guard-refinement.md#delivery-assurance-and-validation).

The [Rosetta sample delivery](docs/rosetta-supported-samples.md) exercises existing
output, names, copies, expressions and branches for the runnable tasks in #9.
It adds regression programs without extending the language.
The [five finite follow-on samples](docs/rosetta-finite-samples.md) exercise
static calculation, immutability, Integer numerals, conditional loop output and
a computed grid using the same admitted rules.

Language changes must specify exact syntax, restrictions, inherited semantics
and compositions. Before 1.0, intentional changes are reflected consistently in
the specification, catalogue, implementation, proofs and samples; Git records
the history. Every admitted program retains the Oracle's complete automatic
assurance. New support is complete only after all requirements of the
[development checkpoint](development.md#proof-loop-and-validation) are satisfied,
including its requirements for any reused regression results.
