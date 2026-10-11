# Silver language specification

Silver is one evolving language before 1.0. This document specifies its complete
current admitted language under the [Oracle](oracle.md). The
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

Exactly eight productions are admitted. The null production is:

```ada
procedure Main is
   pragma SPARK_Mode (On);
begin
   null;
end Main;
```

Its complete token sequence is:

```text
procedure main is pragma spark_mode ( on ) ; begin null ; end main ;
```

The literal-output production is:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   Silver_IO.Put_Line ("Hello, world!");
end Main;
```

Its complete token sequence is:

```text
with silver_io ; procedure main is pragma spark_mode ( on ) ;
begin silver_io . put_line ( <string_literal> ) ; end main ;
```

`<string_literal>` stands for any Ada string literal satisfying these rules:

- Opening and closing double quotes enclose zero or more printable ASCII bytes
  (32 through 126). Two consecutive quotes inside the literal represent one
  quote in its value. The empty literal `""` is admitted.
- Literal case is preserved. Spaces and `--` inside a literal are content.
  Tabs, line breaks and non-ASCII characters inside literals are excluded.
- The complete source, including quotes, escaping and trivia, must still fit
  the 4096-byte source limit. This production's argument is one literal;
  concatenation is admitted only in the separate production below.

The named-constant output production is:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Message : constant String := "Hello, world!";
begin
   Silver_IO.Put_Line (Message);
end Main;
```

Its complete token sequence is:

```text
with silver_io ; procedure main is pragma spark_mode ( on ) ;
<declaration_name> : constant string := <string_literal> ;
begin silver_io . put_line ( <reference_name> ) ; end main ;
```

The declaration name starts with an ASCII letter, followed by letters or decimal
digits, optionally separated by single underscores. It has no trailing or
consecutive underscore. Equivalently it matches
`[A-Za-z]([A-Za-z0-9]|_[A-Za-z0-9])*`. The 74 Ada 2022 reserved words, `String`
and `Silver_IO` are excluded, ignoring ASCII case. `Main` is a legal constant
name. The reference must match the entire declared name, ignoring ASCII case.
There is no separate identifier-length limit beyond the complete source bound.

The constant is declared immediately after the pragma, has the unconstrained
predefined type `String`, and is initialized from one admitted literal. Its
bounds are determined by that value, including the empty string. `:=` is one
contiguous token; comments or whitespace cannot separate its characters.
Exactly one reference supplies the sole output call. This named-output
production contains no concatenation. Reassignment, slicing, further
declarations and other uses of the name remain excluded.

### Literal-backed concatenation

The concatenated-output production is:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Name : constant String := "world";
begin
   Silver_IO.Put_Line ("Hello, " & Name & "!");
end Main;
```

Its complete token sequence is:

```text
with silver_io ; procedure main is pragma spark_mode ( on ) ;
<declaration_name> : constant string := <string_literal> ;
begin silver_io . put_line (
<string_literal> & <reference_name> & <string_literal>
) ; end main ;
```

The initializer, prefix and suffix are independently chosen literals from the
domain above, including empty literals and doubled quotes. The declaration and
reference follow the named-literal rules, including case-insensitive binding.
`Main` and `Silver_Arguments` remain legal names. The output argument contains
exactly two predefined String concatenations: a prefix literal, one reference
to the initialized constant, then a suffix literal. Ada associates the operators
to the left, so the first result joins prefix and value, and the second appends
the suffix. No parentheses around subexpressions, repeated reference, literal-only
concatenation, different operand order or extra operand is admitted.

Each of the three decoded strings occurs once in the result and comes from a
different literal in the source. Their combined length, and each intermediate
result, cannot exceed the complete source's 4096-byte bound. Doubled quotes,
trivia and syntax consume source bytes without increasing that decoded length.
The name's single use is essential to this argument. The initializer remains
one literal; command-line initialization is not admitted in this composition.

### Guarded command-line initialization

The guarded command-line production is:

```ada
with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Message : constant String :=
     Silver_Arguments.First_Or_Default ("Hello, world!");
begin
   if Silver_Arguments.Input_Is_Valid then
      Silver_IO.Put_Line (Message);
   else
      Silver_Arguments.Reject;
   end if;
end Main;
```

Its complete token sequence is:

```text
with silver_io ; with silver_arguments ;
procedure main is pragma spark_mode ( on ) ;
<declaration_name> : constant string :=
silver_arguments . first_or_default ( <string_literal> ) ;
begin if silver_arguments . input_is_valid then
silver_io . put_line ( <reference_name> ) ;
else silver_arguments . reject ; end if ; end main ;
```

The two separate context clauses have this fixed order. The declaration and
reference follow the named-constant rules, with the additional exclusion of
`Silver_Arguments` as a constant name, ignoring ASCII case. That name remains
legal in the literal-initialized form. The literal supplies the default for
`First_Or_Default`; the constant's bounds come from its returned value. This production admits only
the complete conditional shown, including both branches. Parameterless
calls have no parentheses. Its guard cannot be replaced, omitted or negated. The separate guarded
concatenation production below adds exactly one capacity condition.

### Guarded command-line concatenation

The guarded command-line greeting production is:

```ada
with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Name : constant String := Silver_Arguments.First_Or_Default ("world");
begin
   if Silver_Arguments.Input_Is_Valid
     and then Name'Length <= 4088
   then
      Silver_IO.Put_Line ("Hello, " & Name & "!");
   else
      Silver_Arguments.Reject;
   end if;
end Main;
```

Its complete token sequence is:

```text
with silver_io ; with silver_arguments ;
procedure main is pragma spark_mode ( on ) ;
<declaration_name> : constant string :=
silver_arguments . first_or_default ( <string_literal> ) ;
begin if silver_arguments . input_is_valid and then
<reference_name> ' length <= <capacity_literal> then
silver_io . put_line (
<string_literal> & <reference_name> & <string_literal>
) ; else silver_arguments . reject ; end if ; end main ;
```

The default, prefix and suffix are independently chosen from the existing literal
domain. Both references must match the declared name, ignoring ASCII case, with
the command-line name exclusions. The capacity must equal **4096 minus the decoded
prefix and suffix lengths**. It is written as canonical decimal: `0` or a nonzero
digit followed by decimal digits. Signs, leading zeroes, underscores, exponents,
based literals and source arithmetic are excluded. `<=` is one contiguous token.

Only this attribute, comparison and short-circuit composition are admitted.
No weaker bound, reordered or negated condition, extra parentheses, additional
operand, repeated output reference or omitted rejection branch is permitted.
Both concatenations occur only after the complete guard succeeds. As with the
literal-backed expression, Ada associates the operators to the left.

The initialized String is one-based, including empty values, as established by
the verified `First_Or_Default` implementation. Its bytes and length are unchanged
by normalization. This settles the intermediate String bounds even when the
prefix is empty. The capacity guard separately establishes that the complete
result fits the output operation's 4096-byte domain. The default and decorations
fit together because their distinct literal spans consume the bounded source.
A command-line value must pass the explicit runtime capacity test.

### Fixed-length string assignment

The assignment-output production is:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Message : String := "Hello";
begin
   Message := "World";
   Silver_IO.Put_Line (Message);
end Main;
```

Its complete token sequence is:

```text
with silver_io ; procedure main is pragma spark_mode ( on ) ;
<declaration_name> : string := <string_literal> ;
begin <reference_name> := <string_literal> ;
silver_io . put_line ( <reference_name> ) ; end main ;
```

The declaration introduces one variable, with no `constant` keyword or explicit
index constraint. Its name follows the named-literal identifier rules, including
the exclusions of reserved words, `String` and `Silver_IO`; `Main` and
`Silver_Arguments` remain legal. Both references must match the complete declared
name, ignoring ASCII case.

Initialization fixes the variable's bounds. The sole assignment must use an
admitted literal with exactly the same **decoded length** as the initializer.
Equality is checked from source before proof; it does not depend on a solver.
Both empty literals are legal. Doubled quotes count as one value byte, so raw
literal spans can differ even when their decoded lengths agree. Assignment
replaces the bytes while preserving the object's bounds; it neither resizes nor
truncates the string. The final call prints the replacement value followed by LF
under the existing output contract.

Exactly this sequence is admitted: initialization, one assignment, one output
call, and return. Unequal lengths, a missing or additional assignment, assignment
to a constant, extra declarations, output of the initializer before assignment,
name-to-name assignment, command-line initialization, concatenation and other
expressions are excluded from this composition. `:=` remains one contiguous token.
The full source, including both literals and all three name occurrences, must
fit the existing 4096-byte bound.

### Input-dependent branching

The eighth production selects between two literal outputs by comparing validated
command-line input with a literal. Its completed assurance and Linux validation
are recorded in [input-branching.md](docs/input-branching.md).

```ada
with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Mode : constant String :=
     Silver_Arguments.First_Or_Default ("brief");
begin
   if Silver_Arguments.Input_Is_Valid then
      if Mode = "verbose" then
         Silver_IO.Put_Line ("Silver is ready. Input validation succeeded.");
      else
         Silver_IO.Put_Line ("Ready.");
      end if;
   else
      Silver_Arguments.Reject;
   end if;
end Main;
```

Its complete token sequence is:

```text
with silver_io ; with silver_arguments ;
procedure main is pragma spark_mode ( on ) ;
<declaration_name> : constant string :=
silver_arguments . first_or_default ( <string_literal> ) ;
begin if silver_arguments . input_is_valid then
if <reference_name> = <string_literal> then
silver_io . put_line ( <string_literal> ) ;
else silver_io . put_line ( <string_literal> ) ; end if ;
else silver_arguments . reject ; end if ; end main ;
```

The default, comparison literal and two output literals are independently chosen
from the existing literal domain, including empty values and doubled quotes.
Each selected output fits the 4096-byte domain because it is decoded from one
literal within the bounded source. The two outputs are alternatives; their
contents need not differ.

The declaration and comparison reference use the command-line identifier rules:
complete names bind ignoring ASCII case, and reserved words, `String`, `Silver_IO`
and `Silver_Arguments` are excluded. Predefined String `=` compares the input's
bytes with the **decoded literal value**, preserving character case. Unequal
lengths compare false; no truncation, case folding or resizing occurs. With no
argument, compare the default. With one valid argument, compare that argument,
including an explicitly empty one. Invalid input reaches `Reject` without
evaluating the inner choice or producing application output.

Only identifier-on-the-left, literal-on-the-right equality in this fixed nested
guard is permitted. `/=`, reversed operands, parentheses, Boolean combinations,
additional decisions, branch assignments, named/concatenated output arguments
and additional statements remain excluded. There are two literal-output call
sites, but exactly one terminal call executes on a valid-input path. Neither
output call is followed by another application operation.

### Shared composition rules

Whitespace around punctuation is optional. Adjacent word tokens require a
lexical separator. Both occurrences of the procedure name must be `Main`,
ignoring ASCII letter case.

The following capability identifiers are shared with the catalogue:

| Capability | Admitted form and restrictions |
| --- | --- |
| `main_procedure` | Exactly one library-level procedure body named `Main`, with no parameters and the required closing name. |
| `spark_mode_on` | Exactly one `pragma SPARK_Mode (On);`, in the procedure's declarative part. The named, concatenated and command-line compositions additionally declare their one constant; the assignment composition declares one variable. No other pragmas are admitted. |
| `null_statement` | Exactly one `null;` statement, forming the entire procedure body. |
| `runtime_context` | Exactly one `with Silver_IO;` before the output procedure, followed by `argument_context` in the command-line compositions, including branching. No `use` clause. |
| `literal_output` | One qualified `Silver_IO.Put_Line` call with one string-literal argument per terminal branch: the entire direct-output body, or either inner branch of `branching_output`. |
| `string_literal` | A literal in the domain above, used as an output argument, named initializer, concatenation decoration, argument default, assignment value or branching comparison. |
| `named_string_constant` | One `constant String` declaration initialized by a literal or `argument_initialization`, as fixed by the composition. |
| `named_output` | One qualified `Silver_IO.Put_Line` call whose argument is the declared constant or variable identifier, as fixed by the composition. |
| `named_string_variable` | One `String` variable initialized by a literal, with bounds fixed by that value. |
| `string_assignment` | One assignment to that variable from an equal-decoded-length literal, followed by `named_output`. |
| `string_concatenation` | Exactly a prefix literal, one reference to the constant, and a suffix literal joined by two left-associated predefined String `&` operators; a command-line initializer requires `capacity_guard`. |
| `concatenated_output` | One qualified `Silver_IO.Put_Line` call with the complete `string_concatenation` expression as its sole argument. |
| `argument_context` | Exactly one `with Silver_Arguments;`, after `with Silver_IO;`, in the command-line compositions, including branching. |
| `argument_initialization` | One qualified `Silver_Arguments.First_Or_Default` call with one admitted literal default, initializing the constant. |
| `input_guard` | Exactly the validity guard with named output in its `then` branch and mandatory rejection in its `else` branch, as in direct command-line output. |
| `capacity_guard` | Exactly the `Input_Is_Valid and then Name'Length <= capacity` conditional and its fixed branches, with capacity matching the decoded decorations. |
| `string_equality` | One predefined String `=` between the declared constant identifier and a literal; exact case-sensitive value equality, false for unequal lengths. |
| `input_branch` | The complete outer validity/rejection guard and inner equality choice shown above, with a terminal literal output in each inner branch. |
| `argument_rejection` | One qualified `Silver_Arguments.Reject;` as the sole statement of the guard's `else` branch. |

In the null and literal-output compositions the pragma is the sole declarative
item of `Main`; the named, concatenated and command-line compositions add exactly their
constant after the pragma. The assignment composition instead adds its one variable.
The null composition has no context clause and exactly one null statement.
The literal-output composition requires the context clause and exactly one
literal call. The named composition requires the same context and a call by name.
The concatenated composition uses that same context and literal-backed constant,
with the fixed prefix/reference/suffix expression as its sole output argument.
The command-line composition requires both context clauses, argument
initialization and the complete guard, with output by the bound name.
The guarded-concatenation composition uses both context clauses, argument
initialization and `capacity_guard`, with the fixed prefix/reference/suffix output.
The assignment composition has the same single IO context, one variable and the
fixed assignment-then-output sequence. Branching requires both context clauses,
argument initialization and the complete `input_branch`; it has no other
declaration or statement. Context plus null, null plus output, and sequences of
output calls are excluded.
No exception handlers or additional application compilation units are admitted.
Capabilities are not independently optional or freely repeatable.

Everything else is excluded, including other context clauses or calls, additional variable forms,
general conditionals, other string expressions/operations, general arrays, access types, and file
handles. Admitting these operations admits no other API or implementation feature. In particular,
application code cannot call `Ada.Text_IO` or the underlying libc imports.

## Meaning and assurance

`SPARK_Mode (On)` selects SPARK analysis and adds no executable computation.
The null statement performs no action, and the procedure returns normally.
At source level the null program has no data accesses, calls, or output and leaves
the initial state unchanged. Runtime startup and external execution conditions
remain within the documented [trusted boundary](docs/trusted-boundary.md).

Literal and named-literal output request their decoded literal bytes followed by exactly LF
(byte 10) on standard output. Successful completion requires every byte write and the
final `fflush(NULL)` to succeed. Completion means the host stream accepted the
output; it does not guarantee consumption by a reader or durable storage.
With healthy, progressing output and normal process startup, the program prints
those bytes and exits successfully. Empty literals produce just LF.

Concatenated output requests the decoded prefix, initialized constant value and
decoded suffix in that order, followed by LF, with the same completion and
failure behavior. Three empty strings produce just LF. No spaces are inserted
implicitly and the literal contents receive no special treatment.

Command-line forms observe the process arguments after the executable name.
Normal supported startup supplies that executable-name slot (`argc >= 1`);
"no arguments" means no entries after it. For direct command-line output:

| Input | Observable behavior |
| --- | --- |
| No arguments | Print the decoded default followed by LF. |
| Exactly one argument of 0 through 4096 printable ASCII bytes | Print those exact bytes followed by LF. An explicit empty argument prints just LF. |
| Extra arguments, an argument longer than 4096 bytes, or any byte outside 32 through 126 | Produce no application output and set status 1. |

For guarded concatenation, prepend the prefix and append the suffix to the
selected value before LF. One otherwise valid argument must also fit the
remaining capacity. An oversized value causes status 1 and no application output;
it is never truncated. Explicitly empty input produces the decorations and LF.

For input-dependent branching, a valid selected value determines which literal
is printed: equality selects the `then` literal, inequality selects the `else`
literal. The input itself is not printed. The sample prints `Ready.` for no
argument, an empty argument or `Verbose`, and the longer response for exactly
`verbose`. Invalid or extra arguments still produce no output and status 1.

The pure initializer and validity query observe the same immutable GNAT argument
vector. On invalid input the initializer returns an internal empty value, but the
mandatory false branch calls `Reject` and never prints that value. No invalid
argument is truncated or replaced with a successful default. The default itself
always satisfies the literal domain and complete source bound. Retrieving an
argument precedes its length check; the input limit does not bound the storage
allocated by GNAT. Storage exhaustion remains environmental. See the
[argument boundary](docs/trusted-boundary.md#command-line-boundary).

A detected failed write or flush sets process status 1 and returns from
`Put_Line`; `Main` then returns with that unsuccessful status. `Reject` likewise
sets status 1 and returns normally through the fixed false branch.
Wrapper return by itself does not mean successful output. Partial output may
remain, including bytes flushed by runtime finalization. An operating-system signal such as SIGPIPE may
terminate it unsuccessfully before an imported call returns. External blocking,
storage exhaustion and process failure remain environmental conditions; progress
is an explicit assumption, not an unconditional termination claim. Standard
output must be initialized and must not be concurrently written or rebound.
The exact libc/ABI and effect assumptions are in the
[trusted boundary](docs/trusted-boundary.md#literal-output-boundary).

The first five productions, fixed-length assignment and branching have empty
**application-unit safety-obligation** sets. Literal
initialization establishes the constant value and bounds without a range
constraint or read of uninitialized data. Name binding selects that value; the
output call has no caller precondition or constrained argument.
Concatenation's literal-backed operands form a static String expression. Their
combined source-consumption bound keeps both intermediate and final lengths
within String's index range and the output library bound. Static evaluation
relies on the pinned frontend's faithful Ada semantics.
The argument initializer returns an unconstrained `String`; its verified contract
establishes the output domain. The Boolean guard and rejection call add no
application checks or caller obligations.
The variable initializer establishes fixed bounds and fully initialized bytes.
Equal decoded lengths establish the assignment's length compatibility statically;
the output reference reads the replacement value. Assurance relies on the pinned
frontend eliminating the statically satisfied length check, under the
[trusted producer premises](docs/trusted-boundary.md#source-identity-and-program-proof-evidence).
GNATprove may still record an `INEFFECTIVE` flow warning for the overwritten
initializer value. The assignment-only report policy classifies this precise
advisory while retaining it in the report; it accepts no failed safety check or
other warning record in the audited reports. Required complete library reports
are unchanged.
Branching compares two fully initialized Strings with predefined equality;
unequal lengths are valid operands. Its selected call receives one bounded
literal with no caller precondition. The native obligation experiment found
empty Main flow/proof lists under strict warnings, so branching uses the ordinary
empty-report route, not the assignment advisory or dynamic range-check policy.
Every selected-library obligation is still required. Completed capability
validation is in the [branching record](docs/input-branching.md).
Guarded concatenation generates range checks for the dynamic String operations.
The owned initializer's length and one-based bounds, the bounded literals, and
the executable capacity guard establish the necessary ranges and output domain.
The compiler audits complete Main coverage and every emitted range check; it does
not require a fixed check count or treat a successful tool exit as evidence.
The selected SPARK library bodies have nonempty obligations, all of which must
be proved and checked before building an output program. Library initialization,
bounds and the conditional success contract are verified. The language-wide
argument covers all permitted literals, identifiers, argument vectors, lexical
variants and all eight compositions, including equality and the selected terminal output,
not just the samples. See the
[assurance argument](docs/assurance.md) for the checked theorems, source
correspondence, external-tool premises, and limitations.

Application authors supply neither contracts nor proof annotations. Admission,
proof, and compilation use the same source bytes; the compiler snapshots the
input as `main.adb` without adding annotations. Every output form selects the
same six library source files: the `Silver_IO` spec/body, `Silver_Output_Libc`
spec, `Silver_Arguments` spec/body and `Silver_Runtime` spec. It copies these
unchanged and checks them after proof and build, auditing all four library-unit
reports. Null programs select no libraries. The input
file's name does not change language membership. Verification or compilation
failure on an admitted source is an implementation or toolchain defect. A
specified environmental output failure is an execution outcome, not rejection
of the source language.

## Examples and growth

[samples/null.adb](samples/null.adb) is the baseline example;
[samples/hello_world.adb](samples/hello_world.adb) exercises literal output;
[samples/string_constant.adb](samples/string_constant.adb) adds a named constant;
[samples/command_line.adb](samples/command_line.adb) initializes it from guarded
command-line input;
[samples/greeting.adb](samples/greeting.adb) concatenates a literal prefix and
suffix with one reference to a literal-initialized constant;
[samples/command_line_greeting.adb](samples/command_line_greeting.adb) adds the
capacity guard for a command-line value;
[samples/string_assignment.adb](samples/string_assignment.adb) assigns an
equal-length literal to one variable before output.
[samples/input_branching.adb](samples/input_branching.adb) exercises the
supported equality choice. The
[sample manifest](samples/manifest.json) records each supported sample's
capabilities and expected output and exit status. The suite admits, proves,
builds and executes each sample. Samples witness supported behavior; they do
not replace this specification or the universal assurance argument.

Language changes must specify their exact syntax, restrictions, inherited
semantics, and compositions, including interactions with existing capabilities.
Before 1.0, intentional changes to earlier admission rules or examples are
permitted when documented consistently; historical compatibility is not a
requirement. Git records the history. Every currently admitted program must
still receive the Oracle's complete automatic assurance, and a failed proof
cannot be hidden by weakening a declared guarantee.

Proposed examples and APIs remain excluded until the implementation, catalogue,
specification, and required assurance are complete under the
[development workflow](development.md).
