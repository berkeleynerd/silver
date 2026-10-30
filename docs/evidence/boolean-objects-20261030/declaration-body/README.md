# Boolean declaration typed body

Issue #291, Linux x86_64, 2026-10-30. Implementation `a9ed2e41eb` adds the
complete typed ordinary `Boolean_Declaration_At` command body, retaining its
lexical calls, binding lookups, mutable context fields, initializer call's
explicit result count and array values, final semicolon and environment update.
The body has checked precedence and local initialization/scope. Its rendering
matches an independently extracted 402-token native body. Source requirements
also retain the exact complete function and specification/implementation headers.

`denotation` proves its complete statement evaluator equation; `model_meaning`
connects the model interpretation to `booleanDeclarationAt`. `imports_meaning`
derives the same result from primitive-call meanings at the actual arguments,
with the initializer and following-token premises required only after the
executable rejection guard passes. This layer imports no recursive native
condition interpreter. Its downstream constructor must derive the condition
call premise from the native source endpoint on the complete elaboration domain.

Managed run `20261030T114357-000391a04e07`, Lean 4.34.1, checked
`Silver.ComposeBooleanDeclarationMeaning` and
`Silver.ComposeBooleanDeclarationCandidate` with one worker/thread and 8,192 MiB.
Build: 20.697 s; fresh audit: 8.035 s. All 65 imported modules and 8,381
declarations passed, with only `propext`, `Classical.choice` and `Quot.sound`.
`git diff --check` passed. Retained input hashes and log identify the exact scope.

This is focused cached validation, not a complete certified-source checkpoint,
native proof, clean build, independent kernel replay or independent review. The
full source bridge must still instantiate the complete-body/header requirements
on authoritative certified tokens and derive the imported native condition law.
The separate native flow-domain repair is not covered by this packet.

The inherited subthread model/effort names were not preserved in the compact
handoff; no live setting change is claimed. Runtime confirmation, total elapsed
implementation time and token/cost measurements are unavailable. Development
failures remain in the managed ledger: missing low-level scan type, invalid
constructor-like pattern names, record syntax and dependent-instance reduction
were repaired before this successful checkpoint. No native source, language
rule, obligation or axiom was changed by this increment.
