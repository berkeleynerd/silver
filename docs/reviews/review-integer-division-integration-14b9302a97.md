# Review: division grammar and source correspondence integration

2026-10-25. Independent static review; selected GPT-6 Astra at Extra High.
Runtime model/effort were not independently exposed. Recorded review interval:
22:45:59–22:49:01 UTC (3 minutes 2 seconds). Token and cost measurements are
unavailable. Actual host: Linux x86_64.

Exact integration target: `ca4242ff5a80a735be3dc4dd029a659c2af3114c` through
`14b9302a9783d171ac37f1ccf7f75f0ace845ab6` (24 proof files). The initial working
diff was subsequently frozen at that commit; the reviewed proof/source files
match its blobs. Native comparison baseline:
`4f37f6272c03930804be7beba539a5294ad7a7c1`. The existing arithmetic/native core
review at `16d0f0cfaa4b1be97f8c0f89761d7eb1c29cc2a0` is retained rather than
duplicated. Governing inputs included AGENTS.md, oracle.md, relevant development,
assurance and trusted-boundary sections, and the division capability/producer
records.

## Verdict

**No findings in the reviewed integration.**

- **Grammar and recognition:** `ScalarExpressionGrammar.lean:142` independently
  describes complete symbolic and keyword terminals. Its soundness/completeness
  results feed both directions of the recursive parser proof
  (`ScalarExpressionRecognition.lean:9,130`). Case folding, full `mod`/`rem`
  identifiers, `/=` exclusion, right-operand cursor advancement and the existing
  sign/grouping restrictions match `src/silver_scalar_expressions.adb:204`.
  Existing scalar-literal boundary rejection also excludes numeral/keyword
  adjacency such as `7mod`.
- **Operation accounting:** `ComposeAdmission.lean:211`, the rendered
  `workTailBody` at `ComposeExpressions.lean:823`, and its interpretation at
  `ComposeEquations.lean:116` agree with both native ghost and executable
  scanners. Each whole keyword and `/` consumes one unit; `/=` consumes none.
  Literals, comments, names and the existing 63-operator bound retain their
  handling. Native executable/ghost refinement still requires GNATprove.
- **Semantic helper bridge:** the typed trees preserve signed division using
  `Int.tdiv`, divisor-sign modulus using `Int.fmod`, and remainder using
  `Int.tmod`. Guarded endpoint quotient helpers, zero-before-empty rejection,
  singleton precision and sign/magnitude bounds match the native definitions.
  Acyclic helper equations (`ScalarsNativeEquations.lean:68`) determine arbitrary
  callees, and `ScalarsNativeSourceBridge.lean:44,52,60` connects their accepted
  results to definedness and interval safety. The scalar reader's new primitive
  domains, operator equation, recursive interpretation and model witness are
  consistently extended (`ScalarExpressionNativeEquations.lean:107,158,262,402`).
- **Actual source mapping:** the changes to all three complete token shapes
  were compared with the native changes. Their additions correspond to the
  changed counter, parser and scalar helper bodies. Each new scalar helper has
  an expression-body and header check (`ScalarsNativeSourceChecks.lean:40`);
  `binary_after` has both checks in `ScalarExpressionSourceChecks.lean:37,129`.
  Typed rendering, precedence checks, definition equations and source-bridge
  endpoints accompany the pins; the review does not treat pins alone as
  semantic correspondence.
- **Universal discharge:** the already-reviewed `IntegerChecks` constructors
  carry nonzero-divisor definedness as well as result bounds. Its recursive
  `Expr.obligations` (`IntegerChecks.lean:80`) reaches declarations, initializer
  checks, conditions, loop bounds, assignments and Image through the existing
  Predicate folds. `Current.all_obligations_discharge` (`Current.lean:100`)
  therefore closes over the added constructors. A native `VC_DIVISION_CHECK`
  corresponds to the definedness component of those scalar schemas under the
  documented faithful-producer premise. Acceptance of the report class is not
  used as a substitute for that component.

## Limits and delivery follow-up

No proof, test or build runner was invoked; no source was edited and no GitHub
write or subdelegation was performed. Static inspection and `git diff --check`
do not establish that the complete Lean/source-certificate/axiom audit or full
native audit passed. Those stable checkpoints remain the lead's responsibility;
the lead reported the complete Lean run active during this review. The frontend,
faithful obligation generation and physical solver-completion premises remain
the documented ones; no universal native-solver resource bound is claimed.

Final documentation should enumerate nonzero-divisor checks alongside the
existing channels: at the reviewed commit, `docs/assurance.md:563,590`,
`docs/trusted-boundary.md:900` and `language.md:800` still describe only
range/length/overflow. This was communicated to the lead as delivery
synchronization, not a missing mathematical obligation. Concurrent final
documentation changes and final validation evidence are outside this exact
proof-diff review.
