# Silver language specification

Silver is one evolving language before 1.0. This specification describes the
predicate and path-sensitive language under the [Oracle](oracle.md), including
the context, visibility and association rules validated in the
[Names and Calls checkpoint](docs/names-and-calls.md). The
[conditional-statement delivery record](docs/branches.md) records the completed
Linux milestone, building on the earlier [sequencing checkpoint](docs/statement-sequencing.md). The
[machine-readable catalogue](catalogue/silver.json), compiler, and this
specification must agree. A discrepancy is a defect to resolve, not an extension
of the language. Membership depends on source bytes, never on prover success.

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

A literal is enclosed in double quotes and decodes only printable ASCII bytes
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
followed by letters or digits, optionally separated by single underscores,
without a trailing underscore. The 74 Ada 2022 reserved words, `String` and
`Silver_IO` are excluded ignoring ASCII case. In an argument-bearing shell,
`Silver_Arguments` is also excluded for **every** declaration. All names within
one program must be distinct ignoring ASCII case. `Main` is legal;
`Silver_Arguments` remains legal in the static shell. Every
reference matches the entire declared identifier ignoring ASCII case. There is
no additional identifier-length limit beyond the complete source bound.

### Ordered declarations, names and copies

After the pragma, each nonargument output form has zero or more declarations:

```text
declaration ::= name ":" [ "constant" ] "String" ":=" initializer ";"
initializer ::= expression
```

Each declaration introduces exactly one name. Every initializer is required;
it may read any earlier constant or mutable object. Forward, cyclic and
self-initializer references are excluded. Each initializer evaluates its literals, earlier names and concatenations
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
values has a known fixed length. A dynamic initializer must have exactly one
dynamic occurrence and no nonempty static contribution, since it executes
before guards and must fit for every `d <= 4096`. Such an object and `D` share
the symbolic selected-input length `d`; each object's bounds remain fixed during that execution. This length
relationship survives copies, including mutable-source snapshots. Native binding
storage has `4096 / 12 = 341` slots because even `A:String:=B;` consumes twelve
source bytes. This is capacity derived from the complete-source bound, not an
independent declaration-count restriction.

### Common String expressions

Initialization, assignment, both operands of String equality/inequality, and output use:

```text
expression ::= atom { "&" atom }
atom       ::= L | initialized_name | "(" expression ")"
```

An expression has one through sixty-four literal/name leaves. Each occurrence
counts, including empty values and repeated names. Parentheses control grouping;
unparenthesized concatenation associates to the left. The catalogue's `association`
field for concatenation records this default; its separate parentheses flag
permits explicit grouping. There is no independent
parenthesis-depth limit beyond the complete-source bound. Indexing, slices,
other operators and implicit conversion are excluded. References resolve to
initialized objects in the common declaration environment. The output may omit
an assignment target entirely.

Let `S` be the total decoded literal and static-name length, `K` the number of
dynamic occurrences (including aliases), and `d` the selected argument length.
Expression length is exactly `S + K*d`. Every complete expression and intermediate
String value must fit within 4096 bytes. Admission requires:

```text
S + K*C <= 4096
```

Here `C = 4096` for declaration initializers. Body expressions use the greatest
selected-input length still reachable on the current path. Valid-input lengths
are represented by a closed interval; invalid input has length zero and is
tracked separately. If no path reaches an expression, its evaluation bound is
vacuous only for the dynamic contribution: the static contribution must always
fit within 4096 bytes. Names, mutability and expression grammar must still be
valid. For an assignment to a static target of length `T`, the RHS static
contribution `S` must satisfy `S <= T`, with `S = T` when `K = 0`, even on an
unreachable path.
Repeated dynamic references are permitted when the applicable bound holds. The total bound covers all
intermediate groups because operand lengths are nonnegative. Initializers cannot
borrow the later body's capacity. Assignment additionally requires equality of its affine length and the target's
fixed/static or symbolic length throughout the reachable interval, and at zero
if invalid input remains reachable.

The source has at most **63 concatenation operators** across all initializers,
assignment values, equality operands and output expressions, including every
conditional arm and predicate operand. Ampersands inside literals or comments do not count. This explicit
proof-work resource budget permits one maximal 64-leaf expression, or the same
total number of operators distributed across expression positions. Atomic copies
and parentheses consume no concatenation budget. The sixty-four-leaf and sixty-three-
operator limits restrict expression complexity; they do not bound total proof,
translation or report cost from repeated assignments and control flow. These are
project resource policies, not Ada/SPARK restrictions or proved solver-time bounds.
The [expression capacity evidence](docs/larger-expressions.md) records their
justification. The [sequencing capacity record](docs/statement-sequencing.md#external-review-and-capacity-follow-up)
records measured whole-program cost and the remaining external-tool premises.

### Statement sequences and fixed-bound assignment

Every output-capable body contains a nonempty sequence of these statements:

```text
statements       ::= statement { statement }
statement        ::= basic_statement | string_choice
basic_statements ::= basic_statement { basic_statement }
basic_statement  ::= "null" ";"
                   | reject_name ";"
                   | mutable_name ":=" expression ";"
                   | output_name "(" [ "Item" "=>" ] expression ")" ";"
string_choice    ::= "if" condition "then" statements
                     { "elsif" condition "then" statements }
                     [ "else" statements ] "end" "if" ";"
```

`output_name` and `reject_name` are the corresponding qualified or unqualified
names under the context and hiding rules above.

The same sequence forms an argument-input body; its own predicates and rejection
calls must meet the path rules below. Reject is available only in that shell.
Statements execute in source order. Null does nothing. Assignment evaluates the
RHS using the current store, replaces the target's bytes and preserves its fixed
bounds and every other object's value. Only initialized mutable names are targets;
constants and the original argument binding cannot be assigned. Assignment
requires equal lengths on every reachable input: equal static lengths, the same
symbolic input length `d`, or equality established by a preceding predicate.
For a static target of length `T`, the RHS static contribution `S` must satisfy
`S <= T` regardless of reachability, and `S = T` when the RHS has no dynamic
occurrences. This explicit pre-1.0 restriction prevents GNAT's SPARK code
generation from rejecting impossible fixed-bound assignments in dead arms.
It applies to both `"abcd" & Input` and `Input & "abcd"` when `T = 3`, even
though GNAT can compile the latter in some dead arms. Membership therefore does
not depend on operand-order or dead-code-folding quirks. Dynamic targets retain
the reachable-path equality rule.
Empty values and self-copy are legal. For example, inside `if Input'Length = 3`,
a variable initialized from Input can receive a three-byte static value. `:=` is one
contiguous token.

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
1,734,274 bytes of the 2 MiB application capacity. A 4095-byte argument-input
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
distinguishes the deterministic floor, measured credits and pending capacity
repair. These specimens do not establish a universal resource bound. The
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
relation         ::= expression ( "=" | "/=" ) expression
                   | name "'" "Length" comparison length_operand
                   | primary | "not" primary
primary          ::= validity_name
                   | "(" condition ")"
comparison       ::= "=" | "/=" | "<" | "<=" | ">" | ">="
length_operand   ::= integer_literal | name "'" "Length"
```

`validity_name` follows the same context and hiding rules as the other calls.

String equality/inequality compares current bytes, case-sensitively. Unequal
lengths compare unequal. At least one operand must contain an initialized String
name so Ada resolves the array type. Both operands must fit their incoming path
bounds before the comparison can establish any further facts.

Length predicates may read any earlier initialized binding, including an alias or
mutable object. Length remains fixed after initialization. The left operand must
be a binding's Length. Reversing a literal and Length is excluded to keep one
canonical comparison orientation in this initial predicate fragment. Arithmetic
and other attributes are excluded because their evaluation and path-refinement
rules are outside its fixed-length analysis. Ordering String bytes is excluded
because this fragment refines lengths, not lexical order. These are current
scope limits, not inherited Ada restrictions. The validity query is available
only in the argument-input shell and
has no parentheses of its own. Boolean literals are not admitted; True and False
remain legal String binding names. This scope choice adds only predicates over
the existing String/input operations, without a Boolean value-expression grammar.

`and then` evaluates its right operand only after a true left operand; `or else`
evaluates it only after a false left operand. That path's facts justify the right
operand. Mixing these operators requires parentheses, following Ada's grammar.
`not` takes a primary, so write `not (A = B)`, not `not A = B`. Eager `and`, `or`
and `xor` remain excluded because the current predicate fragment models
short-circuit facts and has no need for their separate evaluation rules.

A conditional executes the first true arm, its optional else, or no statements
if every condition is false and else is absent. Each written arm is nonempty and
may contain null, assignment, output, Reject in an argument shell, and nested
conditionals. Multiple conditionals and elsif arms are permitted up to the
complete-source bound, without a separate count or nesting cap.

True String equality (or false inequality) implies equality of operand lengths
and can refine `S + K*d`. False String equality does not imply unequal lengths.
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

Whitespace around punctuation is optional; adjacent word tokens require a
separator, and the final-bracket literal rule above also applies. Declarations precede the entire executable body. Statements and
recursive choices compose under the shared state, expression and effect rules;
path facts and rejection requirements apply at each executed operation and join.
No application can call `Ada.Text_IO`, libc imports or an unlisted library API.

The catalogue uses these construct identifiers:

| Capability | Admitted scope |
| --- | --- |
| `main_procedure`, `spark_mode_on`, `null_statement` | Fixed Main skeleton, required pragma, separate null shell and basic null statements. |
| `runtime_context`, `argument_context` | Grouped, reordered or repeated with/use clauses for the shell's exact package set; with precedes use. |
| `string_literal`, `named_string_constant`, `named_string_variable` | Restricted literals and ordered initialized constant/mutable declarations. |
| `string_copy` | Snapshot initialization and current name reads for compatible assignments. |
| `string_expression`, `string_concatenation` | One through sixty-four literal/name leaves with parentheses; at most sixty-three concatenations per program. |
| `expression_output`, `literal_output`, `named_output`, `concatenated_output` | Returning output calls with qualified or visible unqualified names and positional or `Item =>` actuals. |
| `argument_initialization`, `input_guard`, `capacity_guard`, `argument_rejection` | First/unique immutable input with positional or `Default =>` literal, path-derived validity/capacity and returning rejection; existing calls follow the shared visibility rules. |
| `string_equality`, `string_choice` | Nested predicates with nonempty statements, repeated `elsif`, optional `else` and path refinement. |
| `length_predicate`, `boolean_predicate`, `integer_literal` | Fixed-bound length comparisons, grouped short-circuit logic and bounded decimal/based integer spelling. |
| `string_assignment` | Fixed-bound assignment, including self-copy and path-established length equality. |
| `statement_sequence`, `basic_statement_sequence` | Nonempty finite ordered statements; basic sequences contain null, assignment, output and argument-shell Reject; general sequences also contain choices. |

Everything else is excluded, including loops, Boolean values outside the specified predicate grammar,
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
Runtime concatenation can emit range checks; copied dynamic-length assignments
can emit length checks. Every emitted Main safety record must be a proved/info
`VC_RANGE_CHECK` or `VC_LENGTH_CHECK`, with complete coverage, approved dependencies
and no suppression. Length checks require the fixed-bound argument; their absence
through static elimination is no longer a prerequisite for supporting copies.

All output policies classify finite lists of the exact `INEFFECTIVE` initializer
advisory. Assignment-bearing policies also classify the exact `unused assignment`
advisory. All output-capable policies also classify the exact
`INEFFECTIVE` message `statement has no effect` and `DEAD_CODE` message
`this statement is never reached`, produced by statically known predicates.
Repeated output additionally permits only the four exact `INEFFECTIVE`
messages naming the overwritten ghost outputs `Written_Count`, `Flushed`,
`Succeeded` and `Written_Bytes` of either `Put` or `Put_Line` (eight exact messages). Every accepted advisory retains
Main location, flow provenance and no suppression. Initializers still establish
object bounds even when their bytes are unused. Other warnings in the audited reports fail; naming conventions that make
GNATprove omit an advisory do not change membership.

Faithful static evaluation, complete obligation/report generation, completeness
of the accepted producer shapes and pinned solver completion for the bounded
range/length fragment remain explicit
[tool premises](docs/trusted-boundary.md#source-identity-and-program-proof-evidence).
Native examples corroborate them; they do not prove universal assurance.
Complete selected-library obligations remain mandatory for every output compile.
See [assurance.md](docs/assurance.md) and the
[current delivery record](docs/branches.md) for exact validation scope.

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
capabilities and expected output/status. Existing null, literal, named,
command-line, greeting, assignment and branching samples remain instances of
the complete shells above. Tests admit, prove, build and execute the samples;
examples exercise the rules without replacing universal assurance.

Language changes must specify exact syntax, restrictions, inherited semantics
and compositions. Before 1.0, intentional changes are reflected consistently in
the specification, catalogue, implementation, proofs and samples; Git records
the history. Every admitted program retains the Oracle's complete automatic
assurance. New support is complete only after the
[development checkpoint](development.md#proof-loop-and-validation) passes.
