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

The current language has **six output shells plus null**. The
[composed-String capability record](docs/string-results.md) records its completed
Linux validation; the [assurance argument](docs/assurance.md) gives the universal
claims and their explicit premises. The rules below describe the complete
grammar. Existing samples remain valid.

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

Every output shell has `with Silver_IO;`. The three argument-bearing shells
add exactly `with Silver_Arguments;` after that clause. There are no `use`
clauses, additional application units, additional declarations or statements
outside the selected shell. The grammar below uses `L` for an admitted literal,
`S` for the static-length binding, `D` for the immutable argument binding and
`E` for an output expression. These are grammar metavariables; authors write
ordinary Ada source, as the examples show.

### Literals, names and output expressions

A literal is enclosed in double quotes and decodes only printable ASCII bytes
32 through 126. Doubled quotes encode one quote. Empty literals are allowed;
literal case, spaces and `--` are preserved. Tabs and line breaks cannot occur
inside a literal. All delimiters, escapes and trivia still count toward the
4096-byte source bound.

A declared name matches `[A-Za-z]([A-Za-z0-9]|_[A-Za-z0-9])*`: an ASCII letter
followed by letters or digits, optionally separated by single underscores,
without a trailing underscore. The 74 Ada 2022 reserved words, `String` and
`Silver_IO` are excluded ignoring ASCII case. In an argument-bearing shell,
`Silver_Arguments` is also excluded for **both** declarations. `Main` is legal;
`Silver_Arguments` remains legal in the static and assignment shells. Every
reference matches the entire declared identifier ignoring ASCII case. There is
no additional identifier-length limit beyond the complete source bound.

Every output position uses the same expression grammar:

```text
E ::= operand | operand & operand | ...   (1 through 16 operands)
operand ::= L | an existing bound name
```

The chain is flat and Ada associates `&` to the left. Parenthesized
subexpressions, indexing, slices, other operators and implicit string conversion
are excluded. Each operand counts, including an empty literal or a reference
to an empty String. The static-length name may occur repeatedly; the dynamic
argument name occurs at most once **per output expression**, in any position.
Literals alone are allowed. An assignment-bearing shell must reference its
mutable result at least once in the final output expression. A static constant
need not be referenced. No expression can reference a name absent from its shell.

Membership computes the decoded length of every literal and counts every
static-name occurrence at its declared fixed length. Let `W` be that total,
and let `C` be the explicit capacity, or 4096 when the capacity clause is absent.
Each output expression independently must satisfy:

```text
W + (C if the dynamic name occurs, otherwise 0) <= 4096
```

Thus repeated references cannot multiply a value past the output bound. Every
intermediate concatenation fits as well because operand lengths are nonnegative.
The 16-operand bound also bounds application obligation/report growth; source
length alone would permit hundreds of empty concatenations.

### Direct output

There are no declarations after the pragma. The body is exactly
`Silver_IO.Put_Line (E);`:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   Silver_IO.Put_Line ("Hello" & ", " & "world!");
end Main;
```

Only literals are available as operands in this shell.

### Static output

One declaration `S : constant String := L;` follows the pragma. The body is
exactly `Silver_IO.Put_Line (E);`:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Message : constant String := "Ready";
begin
   Silver_IO.Put_Line ("Result: " & Message & " / " & Message);
end Main;
```

The literal determines the constant's bytes and bounds, including the empty
String. No assignment or additional binding is present.

### Fixed-length string assignment

One declaration `S : String := L;` follows the pragma. The body consists of
exactly `S := L;` followed by `Silver_IO.Put_Line (E);`:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Message : String := "Hello";
begin
   Message := "World";
   Silver_IO.Put_Line ("Result: " & Message & " / " & Message);
end Main;
```

The initializer fixes the object's bounds. The assigned literal must have
exactly the same **decoded** length; doubled quotes count as one byte, and
zero-length values are allowed. Assignment replaces bytes without resizing or
truncation. `E` must reference `S` at least once and reads the replacement value.
The initializer and replacement are individual literals, not expressions or
name-to-name copies. `:=` is one contiguous token.

### Guarded command-line initialization

One declaration `D : constant String :=
Silver_Arguments.First_Or_Default (L);` follows the pragma. Its returned String
is immutable and one-based. The body is exactly an outer guard whose successful
branch contains `Silver_IO.Put_Line (E);` and whose false branch contains
`Silver_Arguments.Reject;`:

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
The capacity reference must bind `D`. Parameterless calls have no parentheses.
The conditions cannot be reordered, negated or extended.

A capacity can be smaller than the maximum allowed by `E`; equality with the
remaining output capacity is no longer required. Without a capacity clause,
`C = 4096`, so a dynamic expression can have only zero total static length.
An expression without `D` may still occur under either guard. The explicit
capacity applies to the selected argument/default even when output omits it.
A default longer than the capacity is legal and reaches `Reject` when selected.
The same guard alternatives apply to the following two shells.

### Input-dependent branching

The declaration is the same immutable argument binding. Inside the successful
outer guard, one equality `D = L` selects two terminal output expressions:

```ada
with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Mode : constant String := Silver_Arguments.First_Or_Default ("brief");
begin
   if Silver_Arguments.Input_Is_Valid and then Mode'Length <= 4080 then
      if Mode = "verbose" then
         Silver_IO.Put_Line ("Selected: " & Mode);
      else
         Silver_IO.Put_Line (Mode & " mode");
      end if;
   else
      Silver_Arguments.Reject;
   end if;
end Main;
```

The complete inner form is `if D = L then Silver_IO.Put_Line (E);
else Silver_IO.Put_Line (E); end if;`. Both expressions independently satisfy
the shared operand/reference/length bounds; one executes. Equality is predefined
String equality of decoded byte values, case-sensitive and false for unequal
lengths. Only identifier-on-the-left, literal-on-the-right equality is admitted.
There is no extra nesting, reversed comparison, Boolean combination or branch
assignment in this shell.

### Branch-selected fixed-length result

Exactly two declarations follow the pragma in order: immutable argument binding
`D`, then `S : String := L;`. Their names are distinct ignoring ASCII case, and
both follow the argument-bearing name exclusions. The successful outer guard
contains an equality choice whose two branches assign `S`, followed by one
common output expression:

```ada
with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Mode : constant String := Silver_Arguments.First_Or_Default ("brief");
   Result : String := "Ready";
begin
   if Silver_Arguments.Input_Is_Valid then
      if Mode = "verbose" then
         Result := "HELLO";
      else
         Result := "Hello";
      end if;
      Silver_IO.Put_Line ("Result: " & Result & " / " & Result);
   else
      Silver_Arguments.Reject;
   end if;
end Main;
```

The complete successful branch is `if D = L then S := L; else S := L;
end if; Silver_IO.Put_Line (E);`. Both assigned literals have the initializer's
exact decoded length. Both branches definitely assign the result before output,
so its length and initialization agree where control rejoins. `E` must use `S`
at least once; it may also use `D` once, under the same weighted capacity rule.
A branch assignment cannot target `D`, and no extra declaration, copy or statement
is implied by this composition.

### Shared composition rules

Whitespace around punctuation is optional; adjacent word tokens require a
separator. These shells are complete program grammars, not independently
repeatable capabilities. Context plus null, null plus output, additional output
calls, arbitrary declarations or statement sequences remain excluded. No
application can call `Ada.Text_IO`, libc imports or any unlisted library API.

The catalogue uses these construct identifiers:

| Capability | Admitted scope |
| --- | --- |
| `main_procedure`, `spark_mode_on`, `null_statement` | Fixed Main skeleton, required pragma, and the separate null shell. |
| `runtime_context`, `argument_context` | Fixed qualified output/argument package context clauses. |
| `string_literal`, `named_string_constant`, `named_string_variable` | Restricted literals and the declarations fixed by each shell. |
| `string_expression`, `string_concatenation` | One through sixteen bound/literal operands; `&` requires at least two. |
| `expression_output`, `literal_output`, `named_output`, `concatenated_output` | One terminal output on each executed output path, with the shared expression rules. |
| `argument_initialization`, `input_guard`, `capacity_guard`, `argument_rejection` | Immutable input, mandatory validity/rejection and the optional bounded capacity clause. |
| `string_equality`, `input_branch` | Exact equality choice between two output expressions. |
| `string_assignment`, `result_branch` | Fixed-length literal assignment, either once directly or once on each selected-result branch. |

Everything else is excluded, including loops, general conditionals, additional
bindings, repeated dynamic references, resizable strings, other array operations,
access types and file handles.

## Meaning and assurance

`SPARK_Mode (On)` selects analysis without adding executable computation. Null
performs no action and returns normally. Runtime startup and external execution
conditions remain within the [trusted boundary](docs/trusted-boundary.md).

An output expression concatenates its operands' values in order; no separators
are inserted. A static binding contributes its initialized constant or assigned
result value at every occurrence. A dynamic binding contributes the selected
argument/default. Literals preserve decoded bytes, including empty Strings and
escaped quotes. The terminal output requests the resulting bytes followed by
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
default and an actual argument. The capacity guard runs before expression
concatenation or the inner choice. Branching compares the selected value with
its decoded comparison literal, then either evaluates one output expression or
assigns one result literal before the common output. Unequal lengths compare
false; there is no case folding, truncation or resizing.

The initializer and validity query observe the same immutable GNAT argument
vector. Invalid input produces an internal empty initializer value, but the
mandatory rejection branch never prints that fallback. Retrieving an argument
precedes its length check; the input limit does not bound GNAT's allocation.
Storage exhaustion remains environmental. See the
[argument boundary](docs/trusted-boundary.md#command-line-boundary).

Successful output requires every byte write and the final `fflush(NULL)` to
succeed. Completion means host-stream acceptance, not reader consumption or
durable storage. A detected write/flush failure sets status 1 and returns from
`Put_Line`; Main then returns without another application operation. Reject
likewise sets status 1 and returns through the false branch. Partial output may
remain, including bytes flushed by runtime finalization. Signals such as SIGPIPE
may terminate the process before an imported call returns. External blocking,
storage exhaustion and process failure remain environmental; progress is an
explicit assumption. Standard output must be initialized and must not be
concurrently written or rebound. These
[external effect assumptions](docs/trusted-boundary.md#literal-output-boundary)
are unchanged.

Membership decides source shape, binding, operand counts, fixed assignment
lengths and every expression's output bound before invoking a prover. Literal
initialization establishes bytes and fixed bounds; equal-length assignments
preserve them. Argument normalization establishes a one-based String of at most
4096 printable bytes. The validity/capacity guard establishes the output-domain
bound for any dynamic occurrence. The universal composition argument must cover
all admitted operands, names, lexical variants, argument vectors and paths.

Literal/static expressions and plain name output may have no Main safety
checks. Runtime concatenation involving a mutable or dynamic value can emit
range checks. The source-selected application policy checks every emitted Main
range check as proved/info, with complete Main coverage and approved dependencies.
Only assignment-bearing shells permit at most one exact `INEFFECTIVE`
initializer advisory: the initial bytes are overwritten, but establish the
variable's fixed bounds. Other warnings in the audited reports fail. Names such
as `Unused_Result` may suppress this advisory without changing membership.

Faithful static evaluation and elimination of statically satisfied assignment
length checks, complete obligation/report generation, completeness of the
accepted producer shapes and pinned solver completion for the bounded range
fragment remain explicit
[tool premises](docs/trusted-boundary.md#source-identity-and-program-proof-evidence).
Native examples corroborate them; they do not prove universal assurance.
Complete selected-library obligations remain mandatory for every output compile.
See [assurance.md](docs/assurance.md) for the current proof/checkpoint status.

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
