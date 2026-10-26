# Independent final guard source-cohort review — 2026-10-26

**No remaining blocker in this scoped static review after the root's bounded repair.** One low-severity integration/compile finding was identified and repaired during review. No new semantic counterexample, contract-domain gap, raw-token dependency omission, or generic ghost-erasure path was found in the reviewed final cohort. This verdict does not claim successful final native discharge or whole-source/kernel validation.

Selected reviewer: GPT-6 Astra, Extra High, per the root's bounded assignment. Runtime model/effort are not independently exposed. Review began at 06:25:55 UTC; source inspection and repair recheck completed at 06:31:13 UTC (318 seconds). The final report/input recheck timestamp and total elapsed time are recorded below. Token/cost measurements are unavailable. No native/Lean runner, GitHub action, source edit, commit, or proof-workspace mutation was performed by this reviewer; only this scratch report was written.

Authorization: independent read-only review of owner-authorized #234/#239 scalar-guard delivery. Governing inputs were AGENTS.md, oracle.md, development.md's source-correspondence/review requirements, and the canonical capability/assurance records. Prior semantic review at `0655fa76be` was reused rather than reopened. The #243 source-contract finding and repair reviews, and #244 context-domain finding and repair reviews, were read and used as the scope boundary.

## Exact final cohort

Reviewed the eight transfer files plus the strengthened BodyWrappers prerequisite from `tmp/scalar-guards-source-author`, as identified by `tmp/guard-final-source-v13-readiness.json`. The manifest SHA-256 is `ca3470af77cc3a82e73fc431a668129da12012b7a90a64981a174f033055e0d2`. All nine file hashes were independently recomputed at intake and again before writing this report; they match the manifest.

All table paths are under `proof/Silver/` in that author worktree.

| File | SHA-256 |
| --- | --- |
| `PredicateBodyWrappers.lean` | `bded87472824e18a7aea1887bfcddff3c1b7ad9de25e03959f169596749ef30f` |
| `ComposeSourceChecks.lean` | `b733f741eb39c0db69005ee11319639c81435d943f935981e9561126ce07c274` |
| `PredicateNativeSourceChecks.lean` | `106e7bacc06027494d6d4460ea64c868073253a70a8786d4d002d0e3bc470b47` |
| `PredicateBasicSourceCandidate.lean` | `b824107eae924095ce304a913e9a53a7957197d5005a218e9c72bfb069233933` |
| `PredicateBodyCandidates.lean` | `890c42cb661c9bc4af832815cef8869e6cde26fae46622193844f9ca5136703c` |
| `PredicateScalarBodyCandidate.lean` | `d0422aa873db4efc116d17e7d702565ab93ddb177ccd8b7abef38cb1dea5cdd1` |
| `PredicateSourceRequirements.lean` | `65cd14799e2199396b3f63412da1ce96f4585cee8016853bb6a7c22d432792eb` |
| `PredicateSourceCandidate.lean` | `8dda562226046e6073ea642afe59295a46f53ff1f7b1c53d37118f8b05c8ca66` |
| `PredicateSourceBridge.lean` | `66cb83160567f502f7afbc5bb59aaac1f2480d575bcf04eecc6413500be8bd08` |

Canonical dependency context was `tmp/scalar-guard-refinement`, initially the briefed `347ca694a57995e31c23756cebec826b5152a61c`; during review HEAD advanced to `74b186f76914a2e864186e7badc01646b7cff0d2`. This is an exact-byte cohort review, not approval of every file in either worktree. The repaired NativeSourceBridge working-tree bytes are identified separately below. Its pre-repair bytes are identical at both canonical commits.

Native comparison inputs:

- `tmp/scalar-guard-refinement/tmp/profile-v13-pending.adb`: SHA-256 `15b6ccc1bda58c506cdadf0b401c91b6b5bffbd6674d3128bbacd0be102c21d1`.
- `tmp/guard-native-repair-continued/profile-relation-condition-repair.adb`: SHA-256 `fac884ac673bb06f947152c0073e42fccaa4881a8e3bdddb29c45d34f061bb9d`.

Both hashes were independently recomputed. The v13→v14 diff adds/repositions Static ghost material and encloses existing runtime statements in declaration blocks; the inspected runtime operations, choices and callees remain the same. The source-check interface reviewed here binds worker contracts explicitly; final complete source-shape binding must use the ultimately frozen native bytes.

## F1 — stale public native-source facade (repaired)

Before the root's repair, canonical `PredicateNativeSourceBridge.lean:57–71` still declared both `condition_correct` and `condition_valid` with `facts : PathFacts.Context` and `fv : facts.Bounded`. The second theorem also used the old `ValidResult text result` application. The current interfaces instead require:

- `PredicateNativeExpressions.lean:155`: `condition : Source → Context → Nat → ActiveFlow → ConditionResult`.
- `PredicateNativeHelpers.lean:273`: `condition_of_source_equations` takes `facts : ActiveFlow` and `fv : ValidFlow context facts`.
- `PredicateNativeCorrespondence.lean:14`: `ValidResult text context result`.

`proof/Silver.lean:5` imports this facade directly. Thus the omitted consumer would prevent the complete proof facade from elaborating. This is a concrete source/API mismatch, not merely a finding that final validation has not yet run.

The root changed exactly the two facts/validity signatures to `ActiveFlow`/`ValidFlow context facts`, and supplied `context` to `ValidResult`. Independent static rechecking of that exact diff found the repair adequate: the two theorem bodies now apply their existing supporting results on precisely those results' domains.

- Pre-repair SHA-256: `71577db6e75be4ce31f2f459b54b50bce7d8ff12fccd63d8664e55888cf1c7f9`.
- Repaired SHA-256: `ee72f79cfd6a635d38feb32e4425333ba96afc8dbf2726920db8bc7514eb7ebf`.

Classification: low-severity integration/compile finding, **not** another substantive mathematical domain gap like #243/#244. The stale theorem could not elaborate against the current dependencies; no successfully compiled false theorem or changed native/application domain is alleged. Disposition: repaired in source; the root reported a focused NativeSourceBridge/SourceRequirements check running. Its result and final source validation remain root-owned evidence, not independently executed evidence from this review.

## Reviewed boundaries

1. **Final-cohort consistency.** Independently enumerated the required and supplied record fields: NativeSourceChecks has 49/49, and SourceRequirements has 112/112, without missing or extra fields. The candidate supplies the five equality-helper headers, five full expression-plus-postfix-aspect checks, and complete Lemma_Condition_Equality implementation header. Existing candidate rendering is compared to reviewed complete source tokens; SourceChecks.actualSource then transports it through authoritative complete-shape equality. Matching candidates are not substituted for that final authoritative check.

2. **Exact native domains.** ComposeSourceChecks checks strengthened Valid_State and both Valid_Mutable_Bounds/Valid_Declaration_Values helpers. PredicateSourceRequirements checks Valid_Context, Valid_Flow, Included and Valid_Body; NativeSourceChecks adds exact Valid_Condition. Canonical BaseReady/baseReady_iff_native covers every active mutable binding, including mutable suffix bindings, while allowing empty immutable loop indexes. Context-only target/length helper domains use Native.ValidContext directly. The final SourceBridge now requests inherited helper equations on OuterReadiness.domain and witnesses them with InheritedReady.model_interpreted. No broader base-domain native assumption was reintroduced.

3. **Raw token and initial-flow imports.** Implementation.Definitions.wrapperModels retains the inherited raw `.takeToken` callee and arbitrary initial-flow import. wrapper_models derives token normalization before initial-flow normalization. The native full TokenDomain stays intact; projection to bodyToken requires FixedToken, supported by complete basic/body/loop typed caller inventories. The original capacity-token witness therefore follows native spelling semantics rather than the old fixed-token-only result. Initial_Flow retains its count-only input domain and complete count/path/values contract before active-flow projection. The repaired #243 five-file hashes still match the retained repair review.

4. **Fixed annotations and equality helpers.** BodyExpressions and LoopNative render specific Static assertions/lemma calls as part of fixed commands; no constructor accepts arbitrary ignored source. The save/join renderer is paired with exact Ghost/Global/Pre/Post checks for Lemma_Joined_Flow. The new equality checks use expressionDeclaration, which retains postfix aspects, rather than expression-body matching alone: each helper explicitly requires `Ghost => Static`, `Global => null`, and `Annotate => (GNATprove, Logical_Equal)`. Lemma_Condition_Equality's exact Static/pure `Pre => Left = Right` and `Post => Same_Condition (Left, Right)` header is retained. Native verification remains responsible for the helper annotation, lemma body and call obligations. The strengthened Invalid_Body contract retains the typed Invalid_Body_Model equality plus exact count and per-index Lower/Upper preservation clauses. The review did not find arbitrary erasure or a replacement of required native proof by matching helper names.

## Dependency inputs and limits

Relevant canonical definitions were inspected in PredicateAdapter, PredicateAdapterEnvironment, PredicateEquations, PredicateBasicLibraries, PredicateLoopHelpers, PredicateFlowInvariant, PredicateNativeState, PredicateOuterReadiness, PredicateInheritedReady, PredicateNativeContracts, PredicateNativeHelpers, PredicateNativeCorrespondence, PredicateNativeExpressions, PredicateNativeWorkers, PredicateNativeSourceBridge, PredicateBodyExpressions, PredicateLoopNative, PredicateScalarBodySource, PredicateNativeScalarHelpers, PredicateSourceChecks, and SourceDeclarations, plus the main Silver facade. The already-integrated renderer/prerequisite hashes in the readiness manifest were independently checked and matched. The canonical docs read were scalar-guard-refinement.md and assurance.md, including the prepared-assurance claims and explicit frontend/native-verification premises.

The known pending authoritative source refresh, final native proof, complete kernel/source/axiom/provenance audit, and capability delivery checks are not reported as new findings. This review performed static source/contract analysis and hash/field inventory only; no native or Lean success is inferred from it. Prior successful focused runs were not rerun or independently re-audited. The root remains responsible for the frozen-source validation checkpoint and final publication/status record.

Final report and cohort/repair hash recheck: 2026-10-26 06:33:30 UTC; total elapsed since review start: 455 seconds, including report writing.
