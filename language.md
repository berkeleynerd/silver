# Silver language specification

Silver is one evolving language before 1.0. This document specifies its complete
current admitted language under the [Oracle](oracle.md). The existing compiler
and catalogue call this null-only implementation **`silver-null-0`**; that label
does not establish separately maintained language versions. The
[machine-readable catalogue](catalogue/silver-null-0.json), compiler, and this
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
- A comment begins with `--` and continues to carriage return, line feed, or
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

The sole admitted production is:

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

Whitespace around punctuation is optional. Adjacent word tokens require a
lexical separator. Both occurrences of the procedure name must be `Main`,
ignoring ASCII letter case.

The following capability identifiers are shared with the catalogue:

| Capability | Admitted form and restrictions |
| --- | --- |
| `main_procedure` | Exactly one library-level procedure body named `Main`, with no parameters or context clauses and the required closing name. |
| `spark_mode_on` | Exactly one `pragma SPARK_Mode (On);`, in the procedure's declarative part. No other declarations or pragmas are admitted. |
| `null_statement` | Exactly one `null;` statement, forming the entire procedure body. |

These capabilities have exactly one permitted composition: the pragma is the
sole declarative item of `Main`, and the null statement is its sole executable
statement. No exception handlers or additional compilation units are admitted.
The capabilities are not independently optional or freely repeatable.

Everything else is excluded, including context clauses, calls, variables,
expressions, string literals, and library operations. Trusting a toolchain or
runtime dependency does not admit it into application source.

## Meaning and assurance

`SPARK_Mode (On)` selects SPARK analysis and adds no executable computation.
The null statement performs no action, and the procedure returns normally.
At source level the program has no data accesses, calls, or output and leaves
the initial state unchanged. Runtime startup and external execution conditions
remain within the documented [trusted boundary](docs/trusted-boundary.md).

Every member of the current language has an empty set of user-program Bronze
and Silver obligations. The language-wide argument covers every permitted
lexical variant and the sole composition, not just the sample. See the
[assurance argument](docs/assurance.md) for the checked theorems, source
correspondence, external-tool premises, and limitations.

Application authors supply neither contracts nor proof annotations. Admission,
proof, and compilation use the same source bytes; the compiler snapshots the
input as `main.adb` without adding annotations. The input file's name does not
change language membership. Verification or compilation failure on an admitted
source is an implementation or toolchain defect.

## Examples and growth

[samples/null.adb](samples/null.adb) is the supported baseline example. The
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
