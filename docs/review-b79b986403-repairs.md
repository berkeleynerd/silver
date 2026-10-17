# Bounded mutable integers review remediation

**Implementation, independent review and Linux x86_64 validation complete, 2026-10-17.**
Delivery is through [PR #86](https://github.com/berkeleynerd/silver/pull/86).

Authorized on 2026-10-17 after [review-b79b986403](reviews/review-b79b986403.md).
The review target is merge `b79b98640373056b71e396eb8e7741b0b9c233b5`
([PR #76](https://github.com/berkeleynerd/silver/pull/76)); the original delivery
implementation/proof input tree is `bbd5989b2b`. Original evidence remains in the
[capability record](bounded-mutable-integers.md) and
[delivery validation](evidence/bounded-mutable-integers/delivery-validation.json).
Combined implementation/proof/test input commit is `78cf419452`.
Its complete validation and independent review passed; neither the review
target nor original delivery evidence is a repair result. Completion
documentation and Rosetta assessment wording are later, separate changes.

## Ordered scope and disposition

[Milestone 4](https://github.com/berkeleynerd/silver/milestone/4) was reopened
for these repairs; the issue and board handoffs track final publication/closure.
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

B1 and M1 were the first implementation/proof increment, with documentation
alongside them. Required native audit, full suite and complete cached Lean/source
validation passed for the combined repair inputs. Independent reviews covered
both implementation streams. Successful evidence and caches are retained;
checks were selected for changed inputs and actual failures. Completing this
repair authorizes no next construct.

### B1 repair correction

The implemented repair selects Option A, requiring a non-empty RHS interval for **every**
Integer assignment. Its suggested native recipe is insufficient: removing the
`not Is_Empty ... and then` bypass alone still admits the normalized empty
interval `(1,0)` inside `0..9`. The repair must explicitly reject emptiness
before testing range containment. This intentional pre-1.0 language restriction
reflects the pinned frontend's compile-time range checks under `SPARK_Mode (On)`.
It may reject dead assignments GNAT accepts. Other admitted empty-loop forms
retain their existing rules and passed compile-level regressions. The rejection
matrix covers 12 forms in both shells, and all 74 retained review mismatches
are rejected. Two retained-form programs passed actual proof/build/execution.

### M1 correspondence

Absent constraints must independently denote the full Integer range. Present
constraints must have independent source readings, static endpoint expressions,
correct endpoint evaluations and ordered bounds. Connect that result to the
declaration/source argument, rather than merely adding an unused lemma.
The implementation in `78cf419452` (M1 lane `4c8dbae39e`) makes
`ScalarConstraintAt` mandatory in `ScalarDeclarationAt`. Its source readings,
exact cursors and evaluated bounds flow through declaration checking and
`Sequence.scalar_tokens_source_bounds` to `Predicate.meaning_scalar_source_bounds`.
Focused run `20261017T121341-ac959d5a4cbb` passed a fresh audit of 13,537
declarations with only the three standard axioms; complete combined validation
also passed as recorded below. Current native bounds were already computed correctly; this repairs
the independent universal source argument.

### Minor and optional dispositions

The nine minor documentation corrections are complete with D4: assignment
theorem attribution, historic declaration-byte wording, scalar slot rationale,
native cache-reuse description, run-inventory scope, limited cache-transfer
provenance, local/published commit mappings, RESUME publication state and precise
roadmap test wording. Original validation failures and evidence classes remain
preserved.

O1's updated stack observation is documented; stack redesign and a new stack
regression are deferred. O2 catalogue-skeleton generation, O3 sample-policy
selection, O4 stronger unused expression guards and O5 expanded adapter theorem
composition or scratch cleanup are deferred because the review found no current
incorrectness from them. Scratch is preserved. D1 clarifies the existing
fixed-model denotation; no producer premise is weakened. Q1 is resolved by Option A. Q2 CVC5 failure diagnosis remains deferred:
required obligations were discharged by the configured alternate provers, and
no unresolved current obligation or admission failure was shown.

## Published commit mappings

The original review and run records name local lane commits. The following
published equivalents have identical stable Git patch IDs, checked read-only
on 2026-10-17. A patch mapping does not assert that the two surrounding trees or
executed workspaces were identical; captured input inventories remain authoritative.

| Local lane commit | Published commit | Change |
| --- | --- | --- |
| `9a337d0c39` | [`134a3beead`](https://github.com/berkeleynerd/silver/commit/134a3beead) | Derive predicate body environment import from native contract |
| `b89c36a0cc` | [`9b2a0d8127`](https://github.com/berkeleynerd/silver/commit/9b2a0d8127) | Factor exact scalar declaration values and mirror delimiter guard (Refs #69) |
| `264c7edbd0` | [`d3a4885ed6`](https://github.com/berkeleynerd/silver/commit/d3a4885ed6) | Admit bounded mutable Integer declarations and assignments |
| `04240f5df6` | [`537c1a245d`](https://github.com/berkeleynerd/silver/commit/537c1a245d) | Expose required scalar range delimiter for cursor proof |
| `c0811ae49b` | [`bab3c7e9f8`](https://github.com/berkeleynerd/silver/commit/bab3c7e9f8) | Connect mutable scalar body helpers to inherited source meanings |
| `768ce4d4ed` | [`54551e49f9`](https://github.com/berkeleynerd/silver/commit/54551e49f9) | Include scalar assignments in predicate selector proofs |
| `cf15eb1bd4` | [`41d4bb07da`](https://github.com/berkeleynerd/silver/commit/41d4bb07da) | Review mutable assignment selector completion (Refs #70) |
| `edd9187247` | [`aa613e0c26`](https://github.com/berkeleynerd/silver/commit/aa613e0c26) | Close mutable Integer producer capacity and retain probe evidence |
| `1023037fcb` | [`7e1aa645ee`](https://github.com/berkeleynerd/silver/commit/7e1aa645ee) | Map square difference to delivered mutable Integer fragment |

## Validation and handoff

Repair implementation and bidirectional independent source review are complete.
The integrated validation checkpoint passed. The
original review's targeted checks are review evidence, not a repair checkpoint.
No clean rebuild, independent kernel replay, native macOS run or hosted CI is
required or claimed. The original report is preserved verbatim; this record
corrects its B1 recipe without rewriting the review.


### Native repair checkpoint — 2026-10-17

Complete native run `20261017T121201-b6d6ef10643e` passed strict auditing of
75 units and 1,000 entities: 1,295 flow checks and 13,854 proof checks, totaling
15,149. Its managed elapsed time was 983.369 seconds. It reused the original
native validation workspace and solver cache; this is a complete cached audit,
not a cold-proof measurement. All 141 captured tracked repository inputs match
frozen implementation/proof/test commit `78cf419452`. The other 2,378 captured
generated, vendor and tool inputs retain their native-workspace identities.
All 77 retained reports hash-match the completed provenance manifest.

The [repair evidence](evidence/bounded-mutable-integers/review-remediation-validation.json)
records those manifests and exact comparisons. The complete regression run
below and final combined Lean/source validation also passed. The original
PR #76 delivery evidence remains separate.


### Regression repair checkpoint — 2026-10-17

Full-suite run `20261017T121442-e0df446200f8` passed all 471 tests in
1,613.207 seconds of unittest time (1,614.213 seconds managed elapsed time).
All 22 manifest samples passed. Its 679 captured tracked repository inputs,
including the complete test and proof trees, hash-match frozen `78cf419452`;
the other eight captured inputs retain their executable/generated/environment
identities in the run. This is a successful full-suite run on the combined
repair inputs, distinct from PR #76's earlier suite and focused repair.
The focused source-correspondence build and final complete Lean audit below
also passed.


### Focused source-correspondence checkpoint — 2026-10-17

Run `20261017T121424-bdf9ff7af233` passed `Silver.ComposeSourceChecks` and its
fresh standard-axiom audit of 21,971 declarations. Its inventory records 41
modules: the 40-module target closure plus `AxiomAudit`. The changed
`OutputBodyCertificate` took 1,927 seconds and `ComposeSourceChecks` took 1,584
seconds; the build phase lasted 3,515.874 seconds, the audit 10.936 seconds,
and the managed run 3,539.610 seconds. Successful objects were retained.

This is a distinct frozen-input checkpoint in the B1 lane, not the final
combined audit. Its 581 authoritative input hashes have digest
`e178e4e663071fbffacc3d9f882b07197aeffb4fe956890ec4f63e9810317aad`;
five M1 proof files still had their earlier contents. The evidence lists those
exact differences against `78cf419452`. After merging the M1 repairs, complete
cached run `20261017T131347-1e8f26041a23` passed on the combined inputs. Both
the focused source result and final audit retain their actual scopes and costs.


### Complete combined Lean checkpoint and handoff — 2026-10-17

Complete cached run `20261017T131347-1e8f26041a23` passed all 466 modules and
freshly audited 89,369 declarations using only `propext`, `Classical.choice`
and `Quot.sound`. All 581 authoritative native/proof/script inputs and all 468
handwritten/generated workspace inputs hash-match `78cf419452`. The authoritative
input digest is
`bedfa1a99d1a8fb358b9bce10aadc9d10c9fa4fb66884412d75e89ccb7f9c91f`.
All 2,800 recorded workspace artifact hashes matched when the evidence was
assembled; that inventory can include retained orphan objects, while the fresh
module audit covers exactly the 466 current project modules.

The build phase lasted 1,279.664 seconds and the fresh audit 9.828 seconds.
The Lean evidence reports 1,304.152 seconds overall; the managed ledger records
1,303.435667 seconds under its separate timing boundary. These are distinct
measurements, and neither is a clean-build or independent-kernel-replay cost.
The final run reused the successful source checkpoint's objects and rebuilt
remaining downstream dependencies of the combined B1 and M1 repairs.

B1's initial focused run `20261017T120951-b4fbf15724a7` failed on an unused
simp argument. M1's initial run `20261017T121047-e19104dd2fd1` failed on
unavailable helper names; its declaration repair passed in
`20261017T121133-23a241487ccb`. The later consumer run
`20261017T121210-fbdaf1c37005` exposed unavailable `List.Forall` and an obsolete
lemma application. Updated membership quantification and consumers passed the
final focused M1 and complete combined runs. All failures, successful repairs
and their actual input differences remain in the evidence; none is described
as successful complete validation.

The B1 reviewer checked native/test/language changes through `8b3f01a209`
and independently re-reviewed final M1 lane commit `4c8dbae39e`. Its one
language wording nit was corrected in `188ab21408`. The M1 reviewer separately
checked B1 over `e21331303c..78cf419452`. Both found no remaining material
finding. Their retained notes are hashed in the evidence and do not replace
validation or claim self-review of their own implementation.

After validation, the idle root cache received the 466 audited module families
and all 7,440 artifact-family files. The transfer copied 506 changed artifacts
and 13 workspace sources (519 files), backing up every replaced file under
`tmp/review-b79-final-lean-cache-backup/20261017T131347-1e8f26041a23`.
`tmp/review-b79-final-lean-cache-promotion.json` has SHA-256
`792f8735a61b0afaa2aee8d5284966b8001de2c19f1c4d4ab9602494a4987f31`.
The independent transfer check verified all target artifacts, 468 workspace
inputs and replaced-file backups. This is a cache handoff, not another proof
run or a claim of complete earlier-object provenance; the original delivery
record retains those historical limits.

The report envelope remains 15,292,416 bytes, with 1,484,800 bytes of headroom.
Rosetta descriptions now include nonempty assignment intervals; rendering left
all generated files and stage positions unchanged. Broad stage #11 remains
Open/Backlog. Worktrees, old evidence, scratch and other-host artifacts are
preserved. Repository session memory is updated; CLI memory was unavailable
and was not updated. No next construct or new harness goal was started.
