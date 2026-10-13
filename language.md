# Silver language specification

Silver is one evolving language before 1.0. This specification describes the
statement-sequencing language under the [Oracle](oracle.md), with a completed
[Linux checkpoint](docs/statement-sequencing.md). The
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

The language has the separate null program and three output-capable shells:
static statements, argument-guarded statements, and argument/capacity-guarded
statements. They share ordered declarations and finite statement sequences.
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

Every output-capable shell has `with Silver_IO;`. The two argument-bearing shells
add exactly `with Silver_Arguments;` after that clause. There are no `use`
clauses or additional application units. Context-clause reordering/grouping and
broader visibility rules remain explicit later work with the existing argument
operations. The grammar below uses `L` for a literal, `S` for an assignment's
mutable target, `D` for the original immutable argument binding, and `E` for a String
expression. Initializers, assignment values, comparison operands and output
share that expression grammar.
These are grammar metavariables; authors write ordinary Ada source.

### Literals and names

A literal is enclosed in double quotes and decodes only printable ASCII bytes
32 through 126. Doubled quotes encode one quote. Empty literals are allowed;
literal case, spaces and `--` are preserved. Tabs and line breaks cannot occur
inside a literal. All delimiters, escapes and trivia still count toward the
4096-byte source bound.

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

Initialization, assignment, both operands of the inner equality, and output use:

```text
expression ::= atom { "&" atom }
atom       ::= L | initialized_name | "(" expression ")"
```

An expression has one through sixteen literal/name leaves. Each occurrence
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

Here `C = 4096` for declaration initializers and unguarded bodies. Guarded body
expressions use the explicit capacity, or 4096 if absent. Repeated dynamic
references are permitted when that bound holds. The total bound covers all
intermediate groups because operand lengths are nonnegative. Initializers cannot
borrow the later body's capacity. Assignment additionally requires exact equality
of its affine length and the target's fixed/static or symbolic length.

The source has at most **30 concatenation operators** across all initializers,
assignment values, equality operands and output expressions, including both
branches. Ampersands inside literals or comments do not count. This explicit
proof-work resource budget redistributes the earlier two-output form's maximum
`2 * (16 - 1)` concatenations across the new expression positions. Atomic copies
and parentheses consume no concatenation budget. The sixteen-leaf and thirty-
operator limits restrict expression complexity; they do not bound total proof,
translation or report cost from repeated assignments and control flow. These are
project resource policies, not Ada/SPARK restrictions or proved solver-time bounds.
The [expression capacity evidence](docs/common-expressions.md) records their
justification. The [sequencing capacity record](docs/statement-sequencing.md#external-review-and-capacity-follow-up)
records measured whole-program cost and the remaining external-tool premises.

### Statement sequences and fixed-bound assignment

A static body contains a nonempty sequence of these statements:

```text
statements       ::= statement { statement }
statement        ::= basic_statement | string_choice
basic_statements ::= basic_statement { basic_statement }
basic_statement  ::= "null" ";"
                   | mutable_name ":=" expression ";"
                   | "Silver_IO" "." "Put_Line" "(" expression ")" ";"
string_choice    ::= "if" expression "=" expression "then" basic_statements
                     "else" basic_statements "end" "if" ";"
```

The same sequence is used inside an argument shell's successful outer guard.
Statements execute in source order. Null does nothing. Assignment evaluates the
RHS using the current store, replaces the target's bytes and preserves its fixed
bounds and every other object's value. Only initialized mutable names are targets;
constants and the original argument binding cannot be assigned. Assignment
requires equal affine length shapes: equal static lengths, or the same symbolic
input length `d`. Empty values and self-copy are legal. Branch-refined equality
of otherwise different length shapes is not used for admission. `:=` is one
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
1,734,274 bytes of the 2 MiB application capacity. These are observations for
that program and host, not worst-case bounds. The densest argument-bearing case
is being measured separately in the [capacity follow-up](docs/statement-sequencing.md#external-review-and-capacity-follow-up).
Sufficient host resources and pinned-tool completion remain operational premises;
failed compilation of admitted source is still a defect, never nonmembership.

### String equality choices

A choice evaluates both String expressions from the current store and executes
exactly one nonempty basic statement sequence. Equality compares exact bytes,
case-sensitive and false for unequal lengths. At least one comparison operand
must contain an initialized String name so Ada resolves the array type; either
operand may supply it. Both operands independently satisfy the expression bound.

Each arm may mix null, assignments and output. Arms need not assign the same
objects or make the same number of calls. Initialization and fixed object bounds
hold after either arm; following statements observe only the selected updates.
Multiple choices may occur sequentially, including in the static shell. Nested
equality choices and new Boolean predicates remain excluded in this increment.
The mandatory `else` keeps this staged grammar to an explicit pair of nonempty
arms; it is not an Ada requirement. Else-less, nested and `elsif` choices, broader
predicates and branch-refined assignment are tracked together in
[roadmap item 5](roadmap.md#existing-feature-consolidation), where their path facts
and join rules can be established consistently.

### Guarded command-line initialization

One declaration `D : constant String :=
Silver_Arguments.First_Or_Default (L);` follows the pragma before all other
declarations. It is the only such call. Its returned String is immutable and
one-based; ordinary declarations may copy it. The body is exactly an outer
guard whose successful branch contains a nonempty statement sequence and whose
false branch contains
`Silver_Arguments.Reject;`. The guard establishes validity and capacity before
body expressions, and the rejection arm preserves the specified no-output
outcome for invalid input. Requiring the guard to enclose the entire body, with
no surrounding statements and `Reject` alone in its false arm, is a staging
restriction that avoids partially guarded effects. It is not required for every
safe Ada statement; broader placement belongs to
[roadmap items 5 and 7](roadmap.md#existing-feature-consolidation).

For example:

```ada
with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Name : constant String := Silver_Arguments.First_Or_Default ("world");
begin
   if Silver_Arguments.Input_Is_Valid and then Name'Length <= 4088 then
      Silver_IO.Put_Line ("Hello, " & Name & "!");
   else
      Silver_Arguments.Reject;
   end if;
end Main;
```

The outer condition is exactly one of:

```text
silver_arguments . input_is_valid
silver_arguments . input_is_valid and then D ' length <= C
```

The capacity is a canonical decimal integer from 0 through 4096: `0` or a
nonzero digit followed by decimal digits. Leading zeroes, signs, underscores,
exponents, based literals and arithmetic are excluded. `<=` is contiguous.
The capacity reference must bind the original `D`, not an alias. Parameterless calls have no parentheses.
The conditions cannot be reordered, negated or extended.

A capacity can be smaller than the maximum allowed by `E`; equality with the
remaining output capacity is no longer required. Without a capacity clause,
`C = 4096`, so a dynamic expression has exactly one dynamic occurrence and
zero total static length.
An expression without any dynamic operand may still occur under either guard. The explicit
capacity applies to the selected argument/default even when output omits it.
A default longer than the capacity is legal and reaches `Reject` when selected.
Every statement in the successful branch uses the same established capacity.

The [sequencing sample](samples/statement_sequence.adb) combines guarded input,
mutable objects, a snapshot, repeated output, and two sequential equality choices.
The existing [input-branching](samples/input_branching.adb) and
[branch-selected-result](samples/composed_result.adb) samples are smaller instances
of these rules.

### Shared composition rules

Whitespace around punctuation is optional; adjacent word tokens require a
separator. Declarations precede the entire executable body. Statements and
one-level choices compose under the shared state, expression and effect rules;
the outer argument guard and rejection alternative retain their fixed placement.
No application can call `Ada.Text_IO`, libc imports or an unlisted library API.

The catalogue uses these construct identifiers:

| Capability | Admitted scope |
| --- | --- |
| `main_procedure`, `spark_mode_on`, `null_statement` | Fixed Main skeleton, required pragma, separate null shell and basic null statements. |
| `runtime_context`, `argument_context` | Fixed qualified output/argument package context clauses. |
| `string_literal`, `named_string_constant`, `named_string_variable` | Restricted literals and ordered initialized constant/mutable declarations. |
| `string_copy` | Snapshot initialization and current name reads for compatible assignments. |
| `string_expression`, `string_concatenation` | One through sixteen literal/name leaves with parentheses; at most thirty concatenations per program. |
| `expression_output`, `literal_output`, `named_output`, `concatenated_output` | Returning output calls anywhere a basic statement is allowed. |
| `argument_initialization`, `input_guard`, `capacity_guard`, `argument_rejection` | Immutable input, mandatory validity/rejection and optional bounded capacity clause. |
| `string_equality`, `string_choice` | One-level equality with nonempty basic sequences in both arms. |
| `string_assignment` | Compatible fixed-bound expression assignment, including self-copy. |
| `statement_sequence`, `basic_statement_sequence` | Nonempty finite ordered statements, with basic-only sequences inside equality arms. |

Everything else is excluded, including loops, nested equality, general Boolean
conditions, additional declaration regions, resizable strings, other array
operations, access types and file handles.

## Meaning and assurance

`SPARK_Mode (On)` selects analysis without adding executable computation. Null
performs no action and returns normally. Runtime startup and external execution
conditions remain within the [trusted boundary](docs/trusted-boundary.md).

An output expression concatenates its operands' values in order; no separators
are inserted. Each name contributes its current bytes; declaration copies keep
their own snapshots when the original is later assigned. A dynamic-length binding
contributes the selected argument/default; each occurrence counts independently.
Literals preserve decoded bytes, including empty Strings and
escaped quotes. Each output call requests the resulting bytes followed by
exactly LF (byte 10). An empty expression value therefore requests one LF.

Command-line forms observe the arguments after the executable-name slot,
which normal supported startup supplies (`argc >= 1`):

| Input | Selected value and execution |
| --- | --- |
| No arguments | Select the decoded default. |
| Exactly one argument of 0 through 4096 printable ASCII bytes | Select those exact bytes, including an explicitly empty argument. |
| Extra arguments, an argument longer than 4096 bytes, or any byte outside 32 through 126 | Reject with status 1 and no application output. |

A valid selected value must also satisfy the optional explicit capacity clause;
otherwise it is rejected with status 1 and no output. This applies equally to a
default and an actual argument. Declaration initializers execute before the capacity guard. The guard then
precedes every statement in the successful sequence. Each choice compares the
current values of its operands, then executes exactly one basic sequence; later
statements observe its selected updates. Unequal lengths compare false; there is no case folding, truncation or resizing.

The initializer and validity query observe the same immutable GNAT argument
vector. Invalid input produces an internal empty initializer value, but the
mandatory rejection branch never prints that fallback. Retrieving an argument
precedes its length check; the input limit does not bound GNAT's allocation.
Storage exhaustion remains environmental. See the
[argument boundary](docs/trusted-boundary.md#command-line-boundary).

Successful output requires every byte write and the final `fflush(NULL)` to
succeed. Completion means host-stream acceptance, not reader consumption or
durable storage. A detected write/flush failure sets status 1 and returns from
`Put_Line`; later statements and output calls still execute. A subsequent
success never clears a failed status. Accepted bytes concatenate in call order;
under failure the cumulative bytes need not be a prefix of the full intended
output. For `n` executed output calls the accepted trace has at most `n * 4097`
bytes. Reject sets status 1 and returns through the fixed false branch. Partial output may
remain, including bytes flushed by runtime finalization. Signals such as SIGPIPE
may terminate the process before an imported call returns. External blocking,
storage exhaustion and process failure remain environmental; progress is an
explicit assumption. Standard output must be initialized and must not be
concurrently written or rebound. These
[external effect assumptions](docs/trusted-boundary.md#literal-output-boundary)
are unchanged.

Membership decides source shape, binding, operand counts, fixed assignment
length shapes and every initializer/body/intermediate value bound before invoking a prover. Initialization
establishes bytes and fixed bounds; assignments preserve each target's bounds
and other objects' snapshots. Argument normalization establishes a one-based
String of at most 4096 printable bytes. The validity/capacity guard establishes
the output-domain bound for `D` and its dynamic aliases. The universal argument
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
`this statement is never reached`, produced by statically known String equality.
Repeated output additionally permits only the four exact `INEFFECTIVE`
messages naming the overwritten ghost outputs `Written_Count`, `Flushed`,
`Succeeded` and `Written_Bytes` of `Put_Line`. Every accepted advisory retains
Main location, flow provenance and no suppression. Initializers still establish
object bounds even when their bytes are unused. Other warnings in the audited reports fail; naming conventions that make
GNATprove omit an advisory do not change membership.

Faithful static evaluation, complete obligation/report generation, completeness
of the accepted producer shapes and pinned solver completion for the bounded
range/length fragment remain explicit
[tool premises](docs/trusted-boundary.md#source-identity-and-program-proof-evidence).
Native examples corroborate them; they do not prove universal assurance.
Complete selected-library obligations remain mandatory for every output compile.
See [assurance.md](docs/assurance.md) and the completed
[checkpoint](docs/statement-sequencing.md) for exact validation scope.

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
