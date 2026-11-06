# B1/B2 independent core proof review — 2026-11-05

**Result: PASS within the assigned core proof scope.** No concrete defect was
identified in the scanner interpretation, native body representation, or the
strengthened slice admission and freezing arguments. This does not complete the
explicitly pending forwarding, actual-source, native proof or final guarantee
checkpoints.

## Identity, authorization and exact inputs

- Reviewer: independent subthread `/root/assess_inherited_blockers`.
- Selected model/effort: GPT-6 Astra, Extra High. Runtime settings were not
  independently exposed; no runtime confirmation is claimed.
- Review interval: 2026-11-05 10:04:03–10:10:38 UTC, 395 seconds to the recorded
  clock checkpoint at report finalization. Token and cost measurements were
  unavailable. Native tool execution times below are separate from review time.
- Owner authorization: bounded review assigned by the lead within the authorized
  repair round; PR #307 remains open. No source edits, builds, expensive checks,
  infrastructure changes, GitHub actions or additional agents were authorized
  for this review. Only this report was written.
- Exact reviewed commit: `58719361ed35d07fdf17b233e74c09c2c156cf0b` in
  `/home/canto/src/github.com/berkeleynerd/silver/tmp/string-admission-repairs`.
- Review used committed sources through `git show`, excluding concurrent
  integration edits. The commit diff whitespace check passed.
- Host observed directly: Linux 7.0.14 x86_64. The retained Lean evidence is
  labelled `linux-x86_64`, using Lean 4.34.1.

The exact changed review inputs, all under `proof/Silver/`, were:

1. `ComposeAtomAdmission.lean`
2. `ComposeContracts.lean`
3. `ComposeExpressions.lean`
4. `ComposeGuardedSliceEquations.lean`
5. `ComposeIndexedReading.lean`
6. `ComposeModelCalls.lean`
7. `ComposeStringDenotations.lean`
8. `ComposeStringEquations.lean`
9. `ComposeStringHelperEquations.lean`
10. `ComposeStringNative.lean`
11. `StringFreezing.lean`
12. `StringIndexing.lean`

Supporting inputs were the existing typed expression/body interpreter, lexical
and helper equation contracts, relevant native scanner/admission definitions,
and retained managed-run logs. The preceding native B1/B2 commit
`71911ad04995842720a1e60dae50a3ac94e76544` and B3 commit `6f6723c7e8` already
passed their separate assigned reviews; this report does not duplicate or
expand those verdicts.

## Scanner interpretation and native correspondence obligations

`ComposeAtomAdmission.guardedAt` implements the intended source restriction:
unfinished `if` nesting, or any `and`, `or` or `xor` token since the preceding
actual semicolon, requires both slice endpoints to be Ada-static. Whole names,
trivia, String literals with doubled quotes, and Character literals are handled
through the existing lexical helpers. Totalization at position zero or beyond
the source/limit domain affects calls outside the native preconditions.

The central theorem, `ComposeGuardedSliceEquations.interpreted_guarded`, is
quantified over arbitrary `Calls` satisfying `RawHelperEquations`. Its premise
is the native body equation on the native helper's domain, not an assumption
that the helper already equals the scanner model. Lexical substitution leaves
the recursive function calls arbitrary. The proof therefore establishes the
recursive helper's interpretation rather than merely checking a model witness.

Each recursive branch discharges positive cursor and valid cursor bounds,
preserves the limit bound and depth bound, and decreases
`text.length + 1 - position`. Quoted, character and identifier skips use the
corresponding advancement and bounds facts. `NameIs` equations are used only
after constructing `ValidName`. The depth increment/decrement cases respect
the native bounds. The indexed-helper proof invokes the theorem from position
1 with the indexed expression position as limit and zero initial depth.

The typed `guardedBody` represents the native declarations, nested conditionals,
recursive calls and semicolon reset. Its evaluation and rendering use the same
tree. The scanner participates in both tree well-formedness and scope checks.
The source-check structure adds the ordinary `guarded_at` body, implementation
header and forward declaration contract, including the native cursor/depth
preconditions and variant. Inspection found no source/model mismatch in these
additions. These are meaningful correspondence obligations; their presence is
not a claim that the final actual-source certificate has already been checked.

`ComposeModelCalls` installs the model scanner, and
`ComposeStringDenotations` proves its body equation by unfolding on the valid
native domain. This model witness is consistent with, and distinct from, the
arbitrary-call recursive interpretation above. Forwarding the witness through
the complete helper-equation construction remains assigned integration work.

## B1 span and B2 static endpoints

`StringIndexing.sliceCheck` adds
`lower.upper - upper.lower <= Integer.maxValue`. The new
`sliceCheck_nativeSpan` derives the corresponding concrete endpoint difference
from checked intervals and interval membership. It does not assume the desired
endpoint bound. `sliceCheck_singletons` requires the bound explicitly, and
`StringFreezing` supplies it from the original check and concrete inference
soundness facts, preserving the restriction through freezing.

`ComposeAtomAdmission.indexedAt` rejects the oversized span and guarded
nonstatic endpoints before accepting a slice. `IndexedReading` carries both
`nativeSpan` and `guardedStatic`. Soundness derives these fields from successful
checker guards; completeness uses them to establish those guards. The semantic
slice check receives the span condition. The Character-element branch retains
its existing behavior and has no substantive slice obligations.

The B2 condition is an explicit restriction of the admitted source language.
The proofs establish soundness/completeness for that restricted recognition
relation; they do not prove universal absence of unrelated GNAT frontend
failures. No diagnostic suppression or trusted scanner-equality axiom was
introduced in the reviewed changes.

## Retained evidence and remaining integration

Managed-run records were read under
`/home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/`.
No validation was rerun by this reviewer.

| Managed run | Inspected evidence and scope |
| --- | --- |
| `20261105T095856-2092056e2e9b` | Successful focused incremental build of `ComposeGuardedSliceEquations` and `ComposeStringHelperEquations`, followed by a fresh axiom audit of 13,419 declarations; only `propext`, `Classical.choice`, `Quot.sound`. Build phase 24.181 s; audit phase 10.188 s; recorded total 49.391 s. |
| `20261105T095341-6bb42689c71e` | `reports/0/lean-focused.log:221` records successful `ComposeStringDenotations` build, 3.8 s. The enclosing run failed on an earlier scanner proof draft; it is not a successful complete run. |
| `20261105T093703-059695feb531` | `reports/0/lean-focused.log:59` records successful `ComposeModelCalls` build, 3.4 s. The enclosing run failed on later scanner/model-denotation drafts; it is not a successful complete run. |

The first run's explicit module list covers the core admission, typed native
tree, recursive interpretation, indexing and freezing changes. It does **not**
include `ComposeModelCalls` or `ComposeStringDenotations`; the separate module
build evidence must not be represented as coverage by that 13,419-declaration
audit. Its metadata records `clean_build: false` and no separate kernel recheck.
It is focused incremental evidence, not a clean whole-project rerun.

Already assigned and excluded from defect classification in this review are
`ComposeEvaluation.lean`, `ComposeModelHelperEquations.lean`,
`PredicateInheritedReady.lean`, the shared output pin/certificate and complete
actual-source checkpoint, full native proof/audit, and final guarantees. The
first three were concurrently modified and were not reviewed as completed
implementation. Required explicit language/catalogue integration and final
resource assessment also retain their separate ownership.

Proceed with that integration. No unexpected core proof issue requires rework
before it. The scoped PASS does not mark the repair or its parent issue complete.
