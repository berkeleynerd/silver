# Boolean Body_Tail proof repair

Two bounded read-only inspections selected GPT-6 Astra / Extra High. Runtime
confirmation and token/cost measurements were unavailable. The lead retains
the returned conclusions here; native validation is recorded separately.

## Failed-task diagnosis

Inspection: 2026-10-31 02:07:19–02:13:03 UTC, 5m44s. Source input was
`87dd912436`, output-profile SHA-256
`88b54a1df3e6cb1b59c482d36cd29a9f15c2506c69227fbef78c9ab93ab67ddb`.
The [failed complete native packet](../evidence/boolean-objects-20261030/full-native-failed-214853/README.md)
retains the task/session identity and all three return paths.

The failed `def'vc.360` merges all returns. Its goal is Ada record equality
between the executable result and `Body_Tail_Model`, unlike the logical-equality
goal in the preceding reader repair. Model expansion and `Invalid_Body`'s
equality/element-preservation postconditions are present. No missing model
equation or semantic counterexample was established.

The invalid returns at source lines 4040 and 4054 bypass the normal return's
`Lemma_Flow_Equality` calls. The normal return also converts the constrained
`Original_Tail` snapshot back to the unconstrained model value. Neither
observation identifies the failing branch. The entire model/specification/body
region is byte-identical to baseline `b6aeb9f978`, region SHA-256
`183dd82bf942309b3186112a4444d1650255772214a441283ba9b1c2c25c2b77`.
The earlier session proved this postcondition with Z3 at 79,426,365 steps;
solver sensitivity is plausible but is not an established cause.

The proposed discriminator adds one checked Static assertion immediately before
each unchanged return, stating that return expression's exact original
model-equality postcondition. This splits the merged obligation into three
paths without a new helper, restricted domain or weaker contract.
Why3 was used only to print/transform retained tasks, with no prover selected.

## Candidate and source-binding review

Inspection: 2026-10-31 02:22:15–02:23:20 UTC, 1m05s. Candidate source SHA-256:
`bb3bd71eb53e7f0637ed27ac4b5eb7c283b66dc0fb81131ebe73543c3950d01f`.
The baseline is `87dd912436`; binding inspection used documentation-only
integration HEAD `e94b3c5327`. No static blocker was found. This inspection
performed no edits, tests, builds, proofs or GitHub actions.

The delta is exactly three Static assertions and formatting of the first return
branch. Removing the assertions and normalizing whitespace reproduces the
baseline. Contracts, model equations, loop invariants/variants, discriminants,
admission domains and executable operations are unchanged. Added model calls
use the original immutable arguments and existing precondition, retaining the
model's lower variant rank. `Invalid_Body` is side-effect-free, `Global => null`,
and has no added precondition. Additional calls occur only in Static assertions
and are erased under the existing policy. Every equality adds a checked
obligation rather than an assumption.

Only `ReviewedOutputShape.outputImplementation` and the regenerated
`OutputBodyCertificate.lean` need source-binding updates. Specifically,
`PredicateSourceRequirements.Checked` extracts the unchanged `body_tail_model`
expression body, and the unchanged executable `body_tail` specification and
implementation header. `PredicateSourceCandidate` checks the same requirements.
The tail equations in `PredicateBodyHelpers` and `PredicateBodyCorrespondence`
use the existing exact contract; no rendered executable Body_Tail tree changes.
The authoritative Ada embedding and binary Lake dependency remain in place.
Mechanical parity and complete source/kernel/audit validation remain required.

The existing 46-test refresh remains sufficient: 12 source, 16 platform,
17 output-integrity and one Silver tool/source-change identity. The 18 integrity
identities compile current Ada; source/platform fixtures consume changed source
and proof bytes. `test_evidence` references synthetic report filenames, not this
source. Other runtime/sample results retain the reviewed ghost-erasure basis.
Conditional on successful refreshes and final-input verification, the existing
46 refreshed plus 522 retained reconciliation covers all 568 identities.

## Subsequent focused result

The native agent's run `20261031T021634-ccc87594f70c` passed all 74 checks
(3 flow, 71 proof) in 372.167 s on the exact reviewed candidate. All three
assertions and the original postcondition passed; all 2,561 terminal input
hashes matched. This establishes the decomposition under unchanged proof limits,
not a unique failing return in the old merged obligation. Source/evidence commit
`f5ab46cdef` retains this result. Complete native and Lean assurance, matching
source bindings and the affected regressions remain pending.
