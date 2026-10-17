# Bounded mutable integers review remediation

Authorized on 2026-10-17 after [review-b79b986403](reviews/review-b79b986403.md).
The review target is merge `b79b98640373056b71e396eb8e7741b0b9c233b5`
([PR #76](https://github.com/berkeleynerd/silver/pull/76)); the original delivery
implementation/proof input tree is `bbd5989b2b`. Original evidence remains in the
[capability record](bounded-mutable-integers.md) and
[delivery validation](evidence/bounded-mutable-integers/delivery-validation.json).
Repair implementation and validation are pending and will be identified separately.

## Ordered scope and disposition

[Milestone 4](https://github.com/berkeleynerd/silver/milestone/4) is reopened.
The owner authorized this repair, its commits/publication and the milestone
correction; there is no Oracle amendment or new harness goal.

| Finding | Issue | Selected work and completion condition |
| --- | --- | --- |
| B1, blocker | [#77](https://github.com/berkeleynerd/silver/issues/77) | Explicitly reject empty Integer assignment RHS intervals; align native/model/source/spec/catalogue and regression coverage. |
| M1, medium | [#78](https://github.com/berkeleynerd/silver/issues/78) | Independently interpret declared endpoints and connect the lemma to the declaration/source argument. |
| D1, low | [#79](https://github.com/berkeleynerd/silver/issues/79) | Separate Image source-route, fixed-template semantic and native evidence; retain producer/per-program premises. |
| D2, low | [#80](https://github.com/berkeleynerd/silver/issues/80) | Explain default versus compact inventory digest encoding without changing historical evidence. |
| D3, low | [#81](https://github.com/berkeleynerd/silver/issues/81) | Correct reopened milestone description now and its closure after repair delivery. |
| D4, low | [#82](https://github.com/berkeleynerd/silver/issues/82) | Link preparatory records to actual delivery and repairs; batch minor record corrections. |
| D5, low | [#83](https://github.com/berkeleynerd/silver/issues/83) | Link current language assurance to the mutable records. |
| D6, low | [#84](https://github.com/berkeleynerd/silver/issues/84) | Explain static endpoint requirements as current Silver scope and their purpose. |

B1 and M1 form the first implementation/proof increment. Documentation proceeds
alongside it. Complete required native audit, full suite and cached complete
Lean/source validation once at stable repair inputs, with independent review.
Retain successful evidence and repeat only checks invalidated by changed inputs,
failures or unresolved concerns. Do not begin another construct first.

### B1 repair correction

Select the report's Option A, requiring a non-empty RHS interval for **every**
Integer assignment. Its suggested native recipe is insufficient: removing the
`not Is_Empty ... and then` bypass alone still admits the normalized empty
interval `(1,0)` inside `0..9`. The repair must explicitly reject emptiness
before testing range containment. This intentional pre-1.0 language restriction
reflects the pinned frontend's compile-time range checks under `SPARK_Mode (On)`.
It may reject dead assignments GNAT accepts. Other admitted empty-loop forms
retain their existing rules and need compile-level regressions.

### M1 correspondence

Absent constraints must independently denote the full Integer range. Present
constraints must have independent source readings, static endpoint expressions,
correct endpoint evaluations and ordered bounds. Connect that result to the
declaration/source argument, rather than merely adding an unused lemma.
Current bounds are computed correctly; this closes a universal argument gap.

### Minor and optional dispositions

The nine minor documentation items are authorized with D4: correct assignment
theorem attribution, historic declaration-byte wording, scalar slot rationale,
native cache-reuse description, run-inventory scope, limited cache-transfer
provenance, local/published commit mappings, RESUME publication state and precise
roadmap test wording. Preserve original validation failures and evidence classes.

O1's updated stack observation is documented; stack redesign and a new stack
regression are deferred. O2 catalogue-skeleton generation, O3 sample-policy
selection, O4 stronger unused expression guards and O5 expanded adapter theorem
composition or scratch cleanup are deferred because the review found no current
incorrectness from them. Preserve scratch rather than deleting it. Clarify the
existing fixed-model denotation where needed with D1; no producer premise is
weakened. Q1 is resolved by Option A. Q2 CVC5 failure diagnosis remains deferred:
required obligations were discharged by the configured alternate provers, and
no unresolved current obligation or admission failure was shown.

## Validation and handoff

Repair implementation, independent review and validation are pending. The
original review's targeted checks are review evidence, not a repair checkpoint.
No clean rebuild, independent kernel replay, native macOS run or hosted CI is
required or claimed. The original report is preserved verbatim; this record
corrects its B1 recipe without rewriting the review.
