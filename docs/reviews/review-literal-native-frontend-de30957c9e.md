# Independent review: literal native frontend Main interface

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119).

**Disposition: scoped acceptance; no material finding.** The packet connects
the selected literal-family source bytes to the accepted Main constructor
and gigi source-visit interfaces. Its five stated linear bounds follow from
the source projection and unchanged predecessor formulas. Fixed/configuration
terms, physical storage and complete gigi/native capacity remain unattached.

## Exact inputs and scope

The frozen target is `de30957c9e242dd783cda187c71122a2b757f0a1`, checked out
clean on `review/literal-native-frontend-de30957c9e` in an isolated worktree.
The eight-file change is the
[research argument](../research/retained-literal-native-frontend.md) and the
seven files in its
[evidence packet](../evidence/retained-literal-native-frontend-20261018/README.md):
`README.md`, `compose.py`, `check.py`, `inputs.json`, `result.json`,
`check-results.json` and `round.json`.

I read the applicable AGENTS and review bookkeeping, reused the existing
Oracle and #119 research authorization, and read the relevant predecessor
parser, constructor-vector and gigi source-visit arguments. The bounded task
was to review this specialization, not reprove every predecessor component
or compose an invocation, fixed frontend or native allocation lifetime.

The adapter pins 21 repository inputs and uses the unchanged source-checked
model at GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Its loader verifies
151 selected source files by SHA-256 and Git blob identity, and hashes the
2,319 Ada files in the existing macro inventory. The focused replay exercised
these checks. I also inspected the actual selected scanner/parser and literal
resolution branches. These identities support retained-source correspondence;
they do not freshly attest installed compiler behavior.

## Source and arithmetic assessment

### Complete recognition and parser projection

The adapter first restricts bytes to printable ASCII plus HT/CR/LF, then
calls the complete retained literal recognizer. Thus the predecessor lexer's
VT/FF acceptance cannot admit those bytes, including inside comments. The
recognizer requires the exact single-with Main/SPARK shell, qualified direct
literal Put/Put_Line calls or null statements, and at least one output call.
Its complete byte/token consumption rejects trailing syntax, partial keyword
matches, declarations, concatenation, extra actuals and extra context clauses.
No new grammar is introduced by the second token projection.

The projection counts actual word lexemes and whole literal tokens. It
skips comments/trivia, decodes doubled quotes, and checks literal lengths
and counts against the complete recognizer. A dot or source-looking text
inside a literal contributes no qualified-name dot or source word. The
fixed shell has eleven words; a call contributes two and a null contributes
one, so W=11+2C+N. Word-character demand uses actual spellings, correctly
distinguishing Put from Put_Line. Counting repeated/interned names and
keywords as separate Name allowances is conservative.

The existing successful-parser proof supplies at most two allocation-bearing
scanner visits per identifier/literal. Counting every word as an identifier
only enlarges that bound. Specializing the accepted parser transfer gives
scanner nodes 2(W+C), then C selected-component nodes, C argument-bearing
call wrappers, N null nodes, seven shell nodes and one with-clause node:

```text
P = 2(W+C) + 2C + N + 8 = 30 + 8C + 3N.
```

The cited constructors agree with the retained source, including the
compilation-unit pair, procedure specification/body, pragma/association,
handled sequence, with clause, selected component and call wrapper
(`par-ch10.adb:216–220,920`; `par-ch6.adb:521,981`;
`par-ch2.adb:352,634`; `par-ch11.adb:62`; `par-ch4.adb:278,700–756`).
Procedure-call conversion changes the wrapper kind rather than allocating
another identity (`par-ch5.adb:650–692`). The extra C slot charge pays that
growth. Main's defining-name promotion likewise retains its scanner identity,
while the full 61-slot entity allowance pays the promotion. This supports
parser entities 1, slots 9(P+C)+61, and lists 4+C. The four fixed lists are
context items, declarations, statements and pragma arguments.

Scanner pools remain separate from parser node identities: W Name entries,
T+W name characters, 2C String descriptors and 2D String characters. There
are no source numeric tokens or parser concat flattenings. Numeral-looking
literal/comment text does not introduce Uint scanner demand.

### Constructor specialization and content dependence

The zero defaults match the recognized grammar: no scalar operators or
variables, loops, declarations, assignments, comparisons, branches, Image,
input calls or concats. The retained largest-scalar-tree and incoming-depth
seeds are both 1. Each literal occurrence supplies its own (1,1) bound
descriptor; duplicate payloads do not collapse constructor occurrences.
The unchanged query transfer then yields source H=2, effective H=4 and A=19.
These are expression-query weights, not literal byte lengths.

The selected native static-low literal path creates one literal subtype per
resolution. Standard Character's complete range avoids the character-array
aggregate conversion, so increasing printable literal length does not add
ordinary AST nodes per character (`sem_res.adb:12039–12322`). Empty literals
return through their already-checked path. Operator-like quoted spellings
also remain covered: the scanner uses predefined operator names, and later
operator-to-String normalization mutates the node kind; the predecessor's
per-literal growth term already pays it (`scng.adb: Set_String`;
`sem_res.adb:1483–1490`; `sinfo-cn.adb:140–145`). This does not infer costs
of later GCC payload allocation from a content-independent AST count.

The only nonzero generated rows are the static literal suffix, conservative
output wrapper, and source call/leaf bookkeeping. They give ordinary nodes
O=W+7C, growth G=5C, fresh entities E=2C, and lists L=W+5C. The wrapper
overcharge is safe even though the accepted direct-literal path creates no
transient scope or secondary-stack cleanup. It is not evidence that those
constructors occur in this family.

Substitution into the unchanged constructor sum gives:

| Main interface | Bound |
| --- | ---: |
| Node identities: P+O+E | 41+19C+4N |
| Entity identities: 1+E | 1+2C |
| Dynamic slots: 9(P+C)+61+9(O+G)+61E | 430+329C+36N |
| Syntax-list headers: 4+C+L | 15+8C+N |

The same rows give generated Name entries 2C+2, name characters 26C+44,
and Uint appends 7C. The predecessor retains its separate digit-family
calculation. Promoted parser entities are not added as fresh node identities;
generated entities are. No scanner pool is silently included twice or omitted
merely because scanner nodes appear in P.

### Named gigi interface and boundaries

The gigi transfer receives ordinary allowance P+O=41+17C+4N, entity count
1+2C, and zero Integer stores. Its accepted occurrence/type-root transfer
therefore gives 73+81C+4N source syntax visits. This is a bound on source
syntax occurrences and the named entity-bound roots, not distinct GCC nodes,
all helper calls or gigi allocation events. It introduces no entity-times-
syntax product. The predecessor's conservative two-procedure/two-return Main
scaffold remains separately named; it is not a claim about the exact selected
literal lowering.

The two fixed frontend node/entity fields are explicitly None. The adapter
does not invoke `native_frontend_logical_join` or attach the historical
configuration fixture. Although model loading evaluates old examples, the
selected result uses only the requested Main constructor and named gigi
interface. The callable's supplied-model premise is explicit: callers must
pass the checked, unchanged model returned by `load_model`.

The length <= INT_MAX premise is reported locally; the mathematical Python
counts do not establish native intermediate, index, table or backing widths.
The packet preserves the separate fixed/configuration/indexed-invocation,
physical sources and tables, common metadata, late heaps/callbacks, annotation
roots, imported gigi type graph, helper/folder and subsequent-phase obligations.
Neither a fixed null-process lifetime nor today's 4096-byte admission cap is
used as a theorem about this unbounded offline family.

## Evidence and round record

One focused replay imported `check.py`, loaded the checked model once and
called `run(model)`. It passed all seven groups: lexical/parser projection,
case/trivia equality, monotonicity/content isolation, 84 call/null combinations,
hello predecessor equality, 5,000 calls and 23 negative cases. The result
exactly matches the committed `check-results.json` and is retained at
`/tmp/silver-review-native-frontend-de30957c9e-10zj_j8k/check-results.json`.

Using that same loaded model, I additionally compared all recomputed hello
interface fields and native-source identities with committed `result.json`.
They match. A recursive check found precisely the two named fixed frontend
null fields, with every Main constructor/source-visit field concrete. These
exercises supplement the source projection and inherited arguments; they
are not universal proofs.

The replay ran on Linux x86-64 (`Linux-7.0.14-x86_64-with-glibc2.43`), taking
0.756529962 seconds for model loading and the focused checker. No native
compiler, prover, Lean build, debugger, full suite or aggregate replay ran.
No native worker reservation was needed.

Selected reviewer settings were **GPT-6 Astra / Extra High**, assigned by
the parent. Runtime model/effort confirmation and token/cost measurements
were unavailable. Review began at 2026-10-18 19:53:45 UTC; source review,
replay and report completed at 19:57:14 UTC, elapsed 209 seconds. This is
the review round's elapsed time, not whole-team runtime. The intended
outcome was an independent source-to-counter and scope review; the achieved
result is scoped acceptance with no material finding or implementation rework.

The live harness returned no goal; none was created or changed. No GitHub
write or delegation occurred. CLI memory was not updated. The parent owns
task integration, any aggregate attachment and publication.
