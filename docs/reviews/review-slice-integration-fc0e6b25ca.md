# B1/B2 integration review — 2026-11-05

**Result:** no concrete semantic or source-wiring defect found in the reviewed integration. One selected-scope regression omission needs repair: preserve the four original B1 source shapes. Full integrated kernel/native assurance remains a separate checkpoint.

**Identity and limits.** Reviewed commit `fc0e6b25caa83a95a53d711df736f6b2f3c0e74c` in `tmp/string-review-repairs`, especially `1faafc48bad28bbc379d6934be350996b992383a` and `fc0e6b25ca`. Selected settings supplied by the lead: GPT-6 Astra / Extra High; runtime settings were not independently exposed. Review interval: 10:44:35–10:49:00 UTC, 265 seconds to final evidence inspection. Token/cost measurements unavailable. Actual host: Linux 7.0.14 x86_64. No builds, expensive runs, GitHub actions or tracked edits were performed for this review. Concurrent lead edits were documentation/evidence only; `git diff --name-only fc0e6b25ca -- proof src tests` was empty at the final inspection.

**Authorship caveat:** this reviewer authored the earlier B1/B2 core and forwarding patch. This is not author-independent review of those files. The existing independent `review-slice-core-proof-58719361ed.md` is reused for the core. The new source-wiring commit and B3/B5 composition were inspected as integration changes.

## Source and semantic connections

The original check chains still consume the repairs:

- `ComposeHelperSourceCandidate.string_helper_ordinary_bodies` now supplies the scanner body, implementation header and contract required by `StringNative.SourceChecks.Checked`. `candidate_string_helpers` retains that record; `ComposeSourceChecks.actual_string_helpers` transports it through `Output.SourceBridge.actual_complete_shape`; `Compose.SourceBridge.checked_source.stringHelpers` and `Predicate.SourceChecks.actualSource.helpers` retain it. Existing indexed-body checks remain required, so the B1 span guard and B2 invocation are not merely pinned as unconsumed excerpts.
- `normalized_rawHelpers.guardedAt` transports the actual typed body through lexical normalization. `model_helpers.guardedAt` uses the proved model denotation. `PredicateInheritedReady.model_definitions` forwards the same domain-independent field; it does not replace the arbitrary-call scanner interpretation with assumed scanner equality. The earlier scanner/helper audit and subsequent model/evaluation audit remain distinct evidence (runs `20261105T095856-2092056e2e9b`, 13,419 declarations; `20261105T100155-085373c7fcd3`, 19,894 declarations).
- `PredicateSourceRequirements.Checked.counted_bound` is constructed in `PredicateSourceCandidate.candidate_checked`, then transported by `PredicateSourceChecks.actualSource.profile`. Both counted-loop reads render `read_counted_bound`; the independent loop candidate and required `loop_body_body` equality retain those calls. `LoopHelpers.Links.readScalar` requires the new wrapper refinement, and `helpers_meaning` invokes `CountedBoundNative.wrapper_meaning`.
- B3's filter gates admission but returns the original scalar result. Its accepted-result theorem therefore retains original array identities and all B5 arithmetic decisions. B5's changed Multiply/Modulo/Remainder trees and equations remain consumed by `ScalarsNativeSourceChecks.ExpressionTranslation` and the scalar source bridge used by the predicate/flow readers. No original scalar source-check chain was bypassed.

Additional inspected inputs: `PredicateCountedBoundModel`, `PredicateCountedBoundSource`, `PredicateLoopNative`, `PredicateLoopImports`, `PredicateLoopProperties`, `PredicateBodyAdmission`, `PredicateSourceBridge`, `ScalarsNativeEquations`, `ScalarsNativeSourceBridge`; native/helper excerpts and the specified interim response/report. Prior reviewed B1/B2 definitions were reused rather than reproved.

## Regression finding R1 — original B1 shapes absent

`tests/test_string_review_blockers.py` pins the conservative endpoint limit on both sides, both interval branches, static extreme nulls, and retained copy/concatenation execution. Existing String tests add null bounds, sliding, endpoint and empty-interval controls. B2 tests cover its primary snapshot guard, length/concat, foreach, nested static-loop, constant-array guard, Boolean-chain and lexical-reset cases, with full-build positive controls. B3/B5 tests retain their independent gates and alternatives.

However, the committed tests do not preserve the report's original B1 equality with two-element endpoint ranges, body-assigned extreme endpoints using separate A/B declarations, first-declaration `D` with the guarded `S := D`, or first-declaration `Arg` with the invalid-input output branch. The latter two exercise the argument shell, absent from the B1 test module. This is a coverage omission, not a discovered implementation failure.

Minimal repair: one parameterized method containing those four original source shapes, expecting both `check` and `compile` status 2, unchanged source bytes, and no new program artifact. Preserve argument declaration order and separate A/B declarations. Do not use `shared.program(arguments=True)`: it injects another first declaration and wraps the body. Keep the existing unguarded span controls: B2 independently rejects the original conditional shapes, so those originals alone would not discriminate removal of B1's span restriction.

The lead accepted R1 and assigned its isolated test-only repair after this review. That repair and its integrated execution are not claimed by this report.

## Authorized follow-up

After accepting R1, the lead assigned exactly one parameterized rejection method in the isolated `tmp/string-admission-repairs` worktree. Commit `824b66a27c` adds the four explicit source fixtures and check/compile rejection, source-preservation and no-artifact assertions; only `tests/test_string_review_blockers.py` changed. Python AST parsing, fixture count/size, declaration-order checks and `git diff --check` passed. No native test was run here: the lead will validate on the integrated B1–B5 compiler. Measured review-plus-repair handoff interval: 10:44:35–10:50:47 UTC, 372 seconds; token/cost measurements unavailable.
