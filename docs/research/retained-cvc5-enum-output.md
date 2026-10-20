# CVC5 generated histogram key spellings

2026-10-20 UTC, Linux x86_64, authorized research #119 / #153; Silver base
`8d9cee6f09`. Selected author setting: GPT-6.1 Sol / Extra High; runtime setting,
token and cost telemetry unavailable.

**The four previously open enum families have finite ordinary histogram key
domains in the exact candidate source.** Internal Kind needs a language-specific
table, API Kind has a separate map-based table, and ProofRewriteRule includes
both normal and expert generated rules. The bounds below close those spelling
components. They do not close the selected registry, diagnostic output, native
refinement or whole-output capacity. `q_cvc5` and weighted `O` remain null.

The [packet](../evidence/retained-cvc5-enum-output-20261020/README.md) pins complete
generator scripts, templates, build lists, enum headers and rule inputs from
CVC5 revision `86cecd83b685f59e884094693b9a4c5c90a62e03`. It reuses the full exact
[candidate archive](../evidence/retained-cvc5-output-capacity-20261020/cvc5-source.tar.gz),
SHA-256 `19d7bbe18166fa175ff537f226e8df5e229b6a28497cb823f82eb734ceed684c`.
The seven literal `toString` tables and formatting premises already accepted in
the [predecessor review](../reviews/review-solver-output-and-identity-20261020.md)
are reused without rerunning their checker or changing their conclusions.

## Ordinary printer bounds

These are exact finite spelling sets for the inspected dispatch/generator
routes, used as conservative domains: no claim that every spelling is reached
by a selected task. K counts distinct exported string keys, L their total UTF-8
bytes, and M the maximum spelling length. Each allowance bounds one histogram
value, excluding its statistic name and ` = ` / LF record wrapper:

| Key route | K | L | M | Allowance `4+L+24K` |
| --- | ---: | ---: | ---: | ---: |
| Internal Kind, AST or direct generated names | 385 | 5,504 | 35 | 14,748 |
| Internal Kind, SMT-LIB / SyGuS | 380 | 3,934 | 35 | 13,058 |
| Internal Kind, union of supported languages | 659 | 7,633 | 35 | 23,453 |
| API `cvc5::Kind` | 297 | 3,760 | 32 | 10,892 |
| TypeConstant | 12 | 265 | 39 | 557 |
| ProofRule | 157 | 2,250 | 33 | 6,022 |
| ProofRewriteRule | 528 | 9,851 | 34 | 22,527 |

The full sorted spelling sets and enum-to-spelling maps are in
[result.json](../evidence/retained-cvc5-enum-output-20261020/result.json).
Fallbacks are included. API Kind's fallback duplicates its named
`UNDEFINED_KIND` spelling, so it adds no distinct exported key. The ordinary
histogram's `getViewer` creates a fresh stringstream for each positive bucket
and inserts its string into a `std::map`; equal spellings collapse there. The
accepted uint64 count formatting gives `4+L+22K+2*max(K-1,0) <= 4+L+24K`.
These bounds use the predecessor's ordinary-object, valid-conversion, stream and
formatting premises. They supply no allocation or solver-completion guarantee.

## Generator and dispatch attachment

All source coordinates here refer to the exact retained upstream archive.
`src/CMakeLists.txt` supplies 14 `KINDS_TOML_FILES`. In
`src/expr/mkkind.py`, `register_kind` emits the `name` property for variable,
operator, constant and nullaryoperator entries, and `K1` for parameterized
entries. There are 381 such entries. `kind_template.h` additionally declares
`UNDEFINED_KIND`, `NULL_EXPR` and `LAST_KIND`. The generated `toString` emits
their `UNDEFINED_KIND`, `NULL` and `LAST_KIND` spellings and `?` for its default.
That gives the 385-entry generated-name domain.

The same input lists contain 11 sort entries. `register_sort` uses each sort's
`comment` as its TypeConstant spelling. `kind_template.cpp` sends TypeConstant
streaming directly to that `toString`, whose default is
`UNKNOWN_TYPE_CONSTANT`. This includes the `LAST_TYPE` sentinel's spelling
without assuming sentinels are reached. Both upstream Kind generation commands
ran successfully in isolated scratch using the exact 14-file list. Retained
complete generated `.h` and `.cpp` files are checked against the independent
TOML-derived name/description inventory.

Internal Kind's ordinary streaming operator calls `Printer::getPrinter(out)`.
`src/printer/printer.cpp` maps AUTO to SMT-LIB v2.6; its factory selects only
SMT-LIB, SyGuS or AST for supported language values. SyGuS uses Smt2Printer.
AST calls `kind::kindToString`, which delegates to the generated `toString`.
Smt2Printer's `smtKindString` returns fixed literals for its explicit cases,
with shared spellings such as `*`, `-` and `to_fp`; `SEXPR`, `APPLY_UF` and the
default fall through to generated names. The checker joins the complete switch
to every generated kind and includes `?`. The union is sufficient when the
valid supported language is unfixed or changes between bucket renderings.
Unsupported language values can reach `Unhandled()`; that diagnostic is outside
this normal returned-key component. No arbitrary-language safety is inferred.

API Kind uses `src/api/cpp/cvc5.cpp`'s separate 297-entry `s_kinds` map.
`KIND_ENUM` stringifies the external name and removes `Kind::`; the ordinary
stream operator calls `std::to_string`, which returns those names or
`UNDEFINED_KIND`. Every public C++ Kind enumerator, including `LAST_KIND`, has
exactly one map entry. The deprecated `kindToString` function's different
`Kind::UNDEFINED_KIND` fallback is not called by this histogram route.

`src/api/cpp/cvc5_proof_rule_template.cpp` contains 156 ProofRule literal cases
and default `?`; no generated insertion occurs in that function. Its
ProofRewriteRule function has 93 literal cases, one generated insertion and
default `?`. `src/rewriter/CMakeLists.txt` passes both `REWRITES_FILES` and
`REWRITES_FILES_EXPERT` to `mkrewrites.py` unconditionally. The 11 normal files
contain 422 RARE rules; the two expert files contain 12. Expert selection changes
the generated rule's level, not inclusion in the enum or spelling switch.
The generator prints each `rule.name` literally; `Rule.get_enum` changes hyphens
to underscores and uppercases the enum identifier. All 434 generated identifiers
are distinct and disjoint from the 93 template cases. The complete archived API
header independently matches the resulting 527 C++ enum identifiers. Its C-only
`LAST` sentinels add no C++ histogram key route.

The host lacks `pyparsing`, a required rewrite-generator dependency. No install,
fetch or full rewrite-generator execution occurred. Instead, the checker scans
every complete selected rule file with a balanced S-expression lexer that
respects strings/comments, accepts only the three top-level tags admitted by
`Parser.parse_rules`, and records every rule name. Inspection of that parser's
name transfer and the generator's fixed printer format derives the domain
conditional on successful generation from these exact build inputs. The header
cross-check confirms the identifier list; it is not a DSL typecheck or proof
that this host can complete the upstream build. No missing-generation result is
fabricated or used as a native/source claim.

## Safe printing has a different key count

`StatisticHistogramValue::printSafe` traverses each positive vector bucket and
prints it directly. It has no exported string map and cannot reuse K or L after
duplicate-spelling collapse. The safe route is:

| Key type | Safe spelling route | Maximum bytes per spelling |
| --- | --- | ---: |
| Internal Kind | Generated `kind::toString`; no language dispatch | 35 |
| API Kind | `safe_print`'s `<unsupported>` fallback | 13 |
| TypeConstant | Generated `toString`, including its default | 39 |
| ProofRule | Public `cvc5::toString`, including its default | 33 |
| ProofRewriteRule | Generated public `cvc5::toString`, including its default | 34 |

There is no API-Kind `toString` overload satisfying `safe_print`'s unqualified
lookup/ADL; `std::to_string` and deprecated `kindToString` do not satisfy it.
Thus 297 named API kinds may yield 297 `<unsupported>` entries in a safe dump,
even though all those spellings are equal. Likewise, arbitrary underlying enum
values taking `?` or another fallback can remain separate positive buckets.

For a separately proved bound N on positive buckets, safe histogram value bytes
are at most `4 + sum_buckets(length(safe_spelling)+24)`, hence `4+N*(M+24)`
using the corresponding M above. A smaller named-enumerator N requires a proof
that all positive keys lie in that named domain; this packet makes no such
source-to-task claim and exports no numeric safe bucket-count bound. The
predecessor's signal-state, conversion and handler-output obligations also
remain. Finite spelling sets alone do not close safe statistics output.

## Evidence and remaining work

The offline check verifies the full archive hash, all 55 complete used source
files, generated Kind outputs, build input lists, balanced rule headers, enum
maps, fallback domains and arithmetic. It does not invoke a solver, compiler,
target, native proof, proof suite or network operation. The generator dependency
probe and one successful Kind generation are recorded separately from the
reproducible lexical checks. The round record distinguishes author elapsed time
from subprocess time and records the one extraction-parser correction.

This packet closes the stated ordinary enum-spelling subproblem in candidate
source. The registry/name join belongs to the parallel registry lane. Selected
task/option preservation, warnings, exception/termination payloads, safe bucket
counts and executable/source attachment remain required before any per-attempt
q or weighted O can be admitted. Oracle, language admission, native commands,
toolchain pins and the accepted seven-table results are unchanged. #119/#153
remain open. Independent review and integration belong to the lead.
