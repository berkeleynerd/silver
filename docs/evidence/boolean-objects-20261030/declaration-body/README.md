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

## Native initializer domain and condition

`76bd973786` derives the exact native initializer context and flow preconditions
from `OuterReadiness.ValidState` and the executable declaration guard. This uses
the #293 repair: mutable scalar snapshots lie within declared bounds, while
immutable cells retain their snapshots. The initializer retains all array values,
its explicit result count, Boolean bindings, elaboration mode and identifier mask.

`ba3d275b0a` then derives `worker_condition_meaning` from the concrete native
worker refinement, its source equations, helper meanings and verified contracts.
It establishes the condition import used by the low declaration proof, on the
actual initializer arguments; it does not assume declaration-scanner equivalence.

| Focused target | Managed run | Modules / declarations | Build / audit |
| --- | --- | --- | --- |
| `ComposeBooleanDeclarationDomain` | `20261030T115342-de6b67a114c8` | 86 / 12,044 | 261.322 s / 10.138 s |
| `ComposeBooleanDeclarationCondition` | `20261030T120520-59daf66d813a` | 123 / 16,824 | 40.926 s / 8.095 s |

Both used Linux x86_64, Lean 4.34.1, one worker/thread and 8,192 MiB. Their fresh
audits passed with only `propext`, `Classical.choice` and `Quot.sound`; the retained
[domain](domain/lean-focused-evidence.json) and
[condition](condition/lean-focused-evidence.json) records identify the exact input
digests and scope. The condition run reused 114 audited dependency modules from
the source worktree's successful `20261030T115607-9d2560e0d3d6` run after verifying
byte equality of every transitive proof source. The
[transfer record](native-cache-transfer.json) retains the source hashes and
copied artifact counts. This was cached elaboration with a fresh audit, not a
clean build or independent kernel replay.

The lead subsequently recovered the selected subthread setting, GPT-6 Astra at
Extra High, from its durable checkpoint and capability record. Runtime settings
remain unavailable and no live switch is claimed. These rounds closed the native
initializer domain and condition obligations. Elapsed native checks are recorded
above; total implementation time and token/cost measurements remain unavailable.

## Imported native libraries

`9693849edd` adds `ComposeBooleanDeclarationLibraries`. `Links` records direct
native callee identities, the checked context expression, interpreted finite
initial-flow storage and the concrete worker refinement. `imports_meaning`
constructs the low declaration premises from raw helper equations on
`OuterReadiness.domain`, the native helper meanings, source equations and
contracts. `declaration_meaning` concludes that the complete typed ordinary body
equals `booleanDeclarationAt`. `model_links` supplies the concrete model witness
for the full source interface. Neither structure assumes declaration-scanner or
predicate-scanner equivalence to language membership.

Managed run `20261030T125012-f7b21b9c556b` checked
`Silver.ComposeBooleanDeclarationLibraries` and its 167 imported modules, auditing
23,606 declarations with only the approved three foundations. Build: 18.561 s;
fresh audit: 8.277 s; managed elapsed: 48.334 s. Platform/tool settings remain
Linux x86_64, Lean 4.34.1, one worker/thread and 8,192 MiB. The
[final evidence](libraries/lean-focused-evidence.json),
[log](libraries/lean-focused.log) and
[relevant source hashes](libraries/input-hashes.json) identify the exact inputs.
`git diff --check` passed.

The final run reused 160 audited dependency modules from source run
`20261030T124434-509822bae49c` after exact transitive source-byte checks; see the
[library transfer record](library-cache-transfer.json). Earlier scalar dependency
reuse is retained in [its transfer record](scalar-cache-transfer.json). Transfers
occurred during explicitly coordinated idle windows and copied complete artifact
groups, excluding setup JSON. The final declaration audit was fresh. No clean
build or independent kernel replay is claimed.

This round closed the native declaration-import constructor and model-witness
obligations. Local failed attempts exposed finite token membership instance
selection, let-binding reduction and equivalent initial-path condition syntax;
the proofs were corrected without changing their domains or conclusions. An
earlier attempt was interrupted after 32.987 s of build time to avoid duplicating
the source agent's shared helper compilation. The managed ledger retains those
attempts. The selected model/effort and unavailable runtime/cost measurements are
as recorded above.

The parent integration still must instantiate the complete-body/header checks
on authoritative certified source tokens and run the complete source, Lean and
native validation. These focused results do not alone complete #291 or #293,
authorize a merge, or replace independent review.
