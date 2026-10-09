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

## Grammar and capabilities

Exactly two productions are admitted. The null production is:

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
  the 4096-byte source limit. No concatenation or other expression is admitted.

Whitespace around punctuation is optional. Adjacent word tokens require a
lexical separator. Both occurrences of the procedure name must be `Main`,
ignoring ASCII letter case.

The following capability identifiers are shared with the catalogue:

| Capability | Admitted form and restrictions |
| --- | --- |
| `main_procedure` | Exactly one library-level procedure body named `Main`, with no parameters and the required closing name. |
| `spark_mode_on` | Exactly one `pragma SPARK_Mode (On);`, in the procedure's declarative part. No other declarations or pragmas are admitted. |
| `null_statement` | Exactly one `null;` statement, forming the entire procedure body. |
| `runtime_context` | Exactly one `with Silver_IO;` before the output procedure. No `use` clause. |
| `literal_output` | Exactly one qualified `Silver_IO.Put_Line` call with one string-literal argument, forming the entire output procedure body. |
| `string_literal` | A literal in the domain above, used only as the output argument. |

In both compositions the pragma is the sole declarative item of `Main`.
The null composition has no context clause and exactly one null statement.
The output composition requires the context clause and exactly one literal call.
Context plus null, null plus output, and repeated output calls are excluded.
No exception handlers or additional application compilation units are admitted.
Capabilities are not independently optional or freely repeatable.

Everything else is excluded, including other context clauses or calls, variables,
string operations, general arrays, access types, and file handles. Admitting
`Silver_IO.Put_Line` admits no other API or implementation feature. In particular,
application code cannot call `Ada.Text_IO` or the underlying libc imports.

## Meaning and assurance

`SPARK_Mode (On)` selects SPARK analysis and adds no executable computation.
The null statement performs no action, and the procedure returns normally.
At source level the null program has no data accesses, calls, or output and leaves
the initial state unchanged. Runtime startup and external execution conditions
remain within the documented [trusted boundary](docs/trusted-boundary.md).

The output program requests its decoded literal bytes followed by exactly LF
(byte 10) on standard output. Successful completion requires every byte write and the
final `fflush(NULL)` to succeed. Completion means the host stream accepted the
output; it does not guarantee consumption by a reader or durable storage.
With healthy, progressing output and normal process startup, the program prints
those bytes and exits successfully. Empty literals produce just LF.

A detected failed write or flush sets process status 1 and returns from
`Put_Line`; the sole-call `Main` then returns with that unsuccessful status.
Wrapper return by itself does not mean successful output. Partial output may
remain, including bytes flushed by runtime finalization. An operating-system signal such as SIGPIPE may
terminate it unsuccessfully before an imported call returns. External blocking,
storage exhaustion and process failure remain environmental conditions; progress
is an explicit assumption, not an unconditional termination claim. Standard
output must be initialized and must not be concurrently written or rebound.
The exact libc/ABI and effect assumptions are in the
[trusted boundary](docs/trusted-boundary.md#literal-output-boundary).

Both productions have empty **application-unit** obligation sets: the literal
call has no caller precondition, constrained argument or dynamic expression.
The selected SPARK library bodies have nonempty obligations, all of which must
be proved and checked before building an output program. Library initialization,
bounds and the conditional success contract are verified. The language-wide
argument covers all permitted literals, lexical variants and both compositions,
not just the samples. See the
[assurance argument](docs/assurance.md) for the checked theorems, source
correspondence, external-tool premises, and limitations.

Application authors supply neither contracts nor proof annotations. Admission,
proof, and compilation use the same source bytes; the compiler snapshots the
input as `main.adb` without adding annotations. It also copies the three selected
library source files unchanged and checks them after proof and build. The input
file's name does not change language membership. Verification or compilation
failure on an admitted source is an implementation or toolchain defect. A
specified environmental output failure is an execution outcome, not rejection
of the source language.

## Examples and growth

[samples/null.adb](samples/null.adb) is the baseline example;
[samples/hello_world.adb](samples/hello_world.adb) exercises literal output. The
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
