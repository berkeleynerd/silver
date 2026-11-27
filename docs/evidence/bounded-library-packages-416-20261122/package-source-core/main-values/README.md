# Shared package reader values and name meanings

Linux x86-64 focused check `20261122T172401-a9ebadcd83b5` passed at two Lake
workers and two process threads within the shared eight-CPU allocation. Targets:
ApplicationNativeGuards, ApplicationPackageDeclarationsTypes and
ApplicationPackageNamesMeaning. Fresh axiom audit passed 20,310 declarations
using only standard foundations.

The additions retain fixed typed fields, operators and aggregate shapes; all
expression children participate in precedence and scope checking. Names imported
primitive meanings preserve their inherited lexical domains. Type interpretation
retains one explicit Function_Type_At callee equality, requiring the corresponding
native-domain source-library instantiation later.

The declaration records preserve full object fields and in-out metadata even
when a signature header is invalid. They do not yet establish parser correctness.
Names candidate token matching, authoritative full source binding, declaration
interpretations and complete application assurance remain outstanding.

## Imported_Package source values

The empty String literal and inclusive slice of normalized one-based text
render the original return and Result initializer. The slice evaluates to the
selected bytes for arbitrary inputs. The grammar checks the source prefix and
both simple bounds, including their scope and named arguments. A raw slice
preserves its Ada lower bound. The byte-list representation permits the
slice as a value and rejects it as an attribute or further slice prefix.

The declaration renderer writes `String (1 .. Result_Length)`. The
initializer supplies the bytes of the rebased local. Focused controls cover
both initialized String forms, reject a missing initializer or malformed
range bound, and check the exact type spellings from the native body. The
enclosing native proof supplies the range and length checks for this copy.

| Linux x86-64 focused run | Targets and result |
| --- | --- |
| `20261127T141522-8139a0168c6c` | ApplicationNativeGuards. Build 9.478 seconds and fresh audit of 20,444 declarations in 2.947 seconds. |
| `20261127T141954-04b1ce295fea` | ApplicationNativeDeclarationLaws, including ApplicationNativeCommands. Build 6.657 seconds and fresh audit of 20,752 declarations in 2.997 seconds. |

Both used Lean 4.34.1, two workers, two threads per process and an 8192 MiB
per-process limit. The `source-slice-` and `source-constraint-` logs and
runner records contain their exact inputs. The full Imported_Package body
and its source binding have separate proof targets.
