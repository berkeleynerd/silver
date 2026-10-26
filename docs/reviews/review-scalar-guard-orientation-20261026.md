# Scalar-condition orientation follow-up — 2026-10-26

**No blocker found in this bounded static review.** The changed ghost/formal model now selects comparison orientation by the same first-candidate test as the executable worker. Runtime statements and native/helper domains are unchanged. No assurance premise was weakened. No additional handwritten renderer repair was identified beyond the already-pending integration and final authoritative source-shape refresh.

Selected reviewer: GPT-6 Astra, Extra High, per the root's follow-up assignment; runtime settings are not independently exposed. Inspection interval: 07:25:18–07:28:30 UTC (192 seconds); report writing and final hash checks follow. Final elapsed time is below. Token/cost measurements are unavailable. This reuses the earlier `report.md` and prior #243/#244 reviews rather than repeating their scope. Authorization remains owner-approved #234/#239. No source/workspace edits, native/Lean runner, GitHub action or Git mutation was performed; only this follow-up report was written.

## Exact inputs

Canonical context: `tmp/scalar-guard-refinement`, HEAD `408569f3b256936e259d5f976ac61f3ec85431e5`, with the identified pending files. Native candidate: `tmp/guard-native-repair-continued/relation-scalar-profile.adb`. Compared its full diff with previously reviewed `profile-relation-condition-repair.adb` SHA-256 `fac884ac673bb06f947152c0073e42fccaa4881a8e3bdddb29c45d34f061bb9d`.

| Input | Final reviewed SHA-256 |
| --- | --- |
| native candidate | `956eff6874727f95fcb1ede29b537705f96bf916d05483d1813198aeb0f1ea74` |
| canonical PredicateAdmission | `8dc5af3972449dfb8baf8cf6e679e1aa56888573778377d569345f5f122b34cc` |
| canonical PredicateNativeScalarHelpers | `3e92c9ecebd6d027c7ac4dd445a354dd28c031470f570dd9641f9a00d1aa9c03` |
| canonical PredicateScalarGuardMeaning | `55ff550d918f49e04123ed32fd254e3c9878e834b1784d4fba3629252b72c73e` |
| canonical PredicateNativeSourceChecks | `fc2328ddadfa3d1166fe76d921e4bfc151eab49b66b30dd21b6ba502e05230e2` |
| canonical PredicateSourceCandidate | `1ca4c654328841835a62904993210071847a716d2481f1efe04e44564eb1a29e` |
| canonical PredicateSourceRequirements | `59149beae0b1fdfb59f819c8e53c7729ad8708045abb946f4a23673687bc2552` |
| canonical ReviewedOutputShape | `494c8929023acdc05476bfb144bf784b6a171d90eb9f43a6f77879ae5ca98c89` |
| pending author ComposeSourceChecks | `b733f741eb39c0db69005ee11319639c81435d943f935981e9561126ce07c274` |
| pending author PredicateScalarBodyCandidate | `d0422aa873db4efc116d17e7d702565ab93ddb177ccd8b7abef38cb1dea5cdd1` |
| pending author PredicateSourceBridge | `66cb83160567f502f7afbc5bb59aaac1f2480d575bcf04eecc6413500be8bd08` |

The originally assigned NativeScalarHelpers hash `d284f057489742e0b79b92cd214f755fcfe1402d671ea93dbb462c8bdeb433f5` and ScalarGuardMeaning hash `81072a6e1c9c0242c46259e64ba1cc90843cfc613aa67f96be6a9bb1e2b41fd9` were read first. During review the root removed one unused `decide_eq_true_eq` simp argument in scalarCondition_denotation and one unused `↓reduceIte` in the chooseLeft branch of scalarCondition_outcome_model. Both exact edits were rechecked; terms and theorem statements are unchanged. The table records the final proof-only revisions. All table hashes were independently recomputed before report writing.

## Orientation and assurance assessment

Native `Scalar_Condition` now uses `Left_Target /= 0 and then Right.Static and then Right.Bounds.Lower = Right.Bounds.Upper` for Target, Selected and Threshold. The executable `Read_Relation_Into` already uses that same first-candidate condition, retaining the unswapped operator/right threshold there, and swapping the operator/using the left threshold only in the second-candidate branch. The candidate does not alter that executable branch.

The previous `Target = Left_Target` test lost the branch identity when both targets were equal. The helper precondition permits hypothetical reader results that are not consistent with actually parsing those positions. For example, use text `a`, a valid single mutable binding with declared/current flow bounds `0..10`, both positions 1 and both After values 2, left result Static with bounds `5..5`, right result nonstatic with bounds `2..10`, and operator `<`. Both bare targets are 1. The first candidate is false and the second true. The previous helper selects `< 2` because Target equals Left_Target, producing true-flow `0..1`; the executable right-candidate branch selects `> 5`, producing `6..10`. The revised helper selects the latter as required. This is a mathematical helper-input witness, not a newly run program or claim that contradictory reader results arise in an admitted execution.

If neither candidate is selected, Target is zero. Native `Refined_Flow` returns Facts at index zero, and ActiveFlow.refine also leaves the flow unchanged there; the orientation/threshold choice is consequently unobservable. If both candidates hold, the original left-first priority remains. No target eligibility, staticness criterion, singleton requirement, bound, precondition or input type was relaxed or narrowed.

The same branch predicate appears in all relevant representations:

- PredicateAdmission.scalarCondition uses it for selected operator and threshold.
- Native.ScalarHelpers.scalarConditionBody uses the existing typed candidate expression in both locals; scalarConditionEquation mirrors it with Boolean operations. Its rendered fragment matches the new native declaration, including normal short-circuit conjunction and grouping.
- scalarCondition_meaning retains its existing ValidText, ValidContext, ValidFlow, cursor and bounded-result premises; only the local threshold proof is adjusted.
- scalarCondition_outcome_model has the same public statement and parsed-reader assumptions. Its first/second-candidate case split now directly matches Integer.refineComparison. The removed proof that equal parsed targets could not select different orientations is no longer needed to recover a branch identity from equality. Universal execution/discharge conclusions are not weakened by that simplification.

The remaining native diff introduces Static equality lemmas/assertions and transports already-declared ghost model identities. Lemma_Flow_Equality is explicitly Ghost => Static and Global => null, with Pre => Left = Right and Post => Same_Flow (Left, Right); its body embeds equal flows in conditions and calls the existing checked equality bridge. Native verification still owes its body and all call preconditions. Nothing in this review treats matching syntax as their discharge.

## Source correspondence and smallest remaining shape work

Read-only diagnostic token extraction compared 90 direct header/expression/postfix-aspect clauses from canonical NativeSourceChecks, SourceRequirements and BodyWrappers with native candidate `956eff...`; all matched. The nine retained literal Basic/Body/Adapter candidate bodies also matched. This reused lexer/extractor functions in memory and wrote no certificate or source file; these comparisons are static diagnostics, not Lean evidence. The typed Scalar_Condition renderer was additionally inspected directly with its equation/model changes.

NativeSourceChecks now requires **50** fields, and canonical SourceCandidate supplies all **50**, with no missing/extra field. The added Lemma_Flow_Equality implementation-header field and candidate theorem retain the exact Ghost/Global/Pre/Post clauses. Existing equality helper body/postfix checks remain in place. Canonical SourceRequirements differs from the previously reviewed author copy only by its explicit PredicateAdapterEnvironment import.

No further handwritten shape/renderer change was found. The smallest remaining work is the already-known transfer of author ComposeSourceChecks, PredicateScalarBodyCandidate and PredicateSourceBridge, followed by the authoritative native-body installation and complete output-body shape/certificate refresh against the final frozen bytes. ReviewedOutputShape remains the earlier source shape; that known pending refresh is not a new finding. Preserve the newer canonical NativeSourceChecks/SourceCandidate when integrating the old manifest: copying their older author versions would remove the new flow-equality check and regress 50 fields to 49.

The final source-dependent candidate assertions, complete source/kernel/axiom/provenance validation and native discharge remain separate root-owned obligations. The root reported an initial focused Lean attempt with only the two unused-simp lint diagnostics, a new focused run in progress, and 13 successful native Scalar_Condition checks; this reviewer did not execute or independently audit those runs. No completed whole-feature or final-source validation is claimed.

Report and final exact-input recheck: 2026-10-26 07:31:14 UTC; total elapsed 356 seconds, including report writing.
