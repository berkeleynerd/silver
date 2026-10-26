# Scalar guard final integration review — 2026-10-26

**No scoped blocker or additional source repair found.** The final branch-local
Static equality annotations preserve the reviewed executable behavior and native
contract domains. The integrated source-check and public endpoint interfaces
retain the repairs from the earlier reviews. This is an independent static
integration review, not a claim that final native discharge, complete source
correspondence, or delivery validation has finished.

Selected reviewer: GPT-6 Astra, Extra High (`gpt-6-astra`, `xhigh`), explicitly
confirmed by the lead's spawn configuration; live runtime model/effort are not
independently exposed. Initial inspection ran 08:47:56–08:50:58 UTC
(182 seconds). A requested applicability follow-up covering the earlier semantic
review and final frame evidence completed at 08:53:37 UTC; final report time is
recorded below. Token/cost measurements
are unavailable. The reviewer ran no validator, changed no source or proof
workspace, and performed no Git/GitHub mutation. Only this report is owned and
written by the reviewer. The live harness goal read returned null; the bounded
assignment and owner's roadmap-continuation authorization govern this work.

## Scope and exact inputs

Owner-authorized #234/#238–#240 final integration, with division delivered first
at `a5305f1b04`. No deferred item was reopened. Governing inputs: AGENTS.md,
oracle.md, development.md's source-correspondence and review bookkeeping rules,
docs/scalar-guard-refinement.md, and the prepared scalar-guard assurance section
of docs/assurance.md. The scope is the final Static join delta, native
contracts/domains, source-check instantiation, and public endpoints. Earlier
universal semantic reviews are reused rather than repeated.

Canonical worktree:
`/home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-guard-refinement`.
Initial HEAD was `b5d561ed65` with the three briefed pending files. During review,
the lead committed precisely those files unchanged as
`bc9b0815ebf4c6be42abe50cb48a94b0ea08c5f5`. The commit range changes only these
three paths; their hashes were independently recomputed before and after commit:

| File | SHA-256 |
| --- | --- |
| src/silver_output_profile.adb | `ec2f0a72dcbdcf1ff6dadc9fb8ec2975653a8c0c11db2bf3d53b7a5b8dec3a3d` |
| proof/Silver/ReviewedOutputShape.lean | `788a6de733fc588826eb2321e60b8b09ae6f2dddd9e9f93eb7debd821a969b8e` |
| proof/Silver/OutputBodyCertificate.lean | `be7988e967dde675420af25a62124d29133ef8b128fa90c5649199dce17e223a` |

Read and reused these exact checked-in review records:

- docs/reviews/review-scalar-guard-final-source-20261026.md.
- docs/reviews/review-scalar-guard-orientation-20261026.md.
- docs/reviews/review-scalar-guard-context-domain-repair.md.
- docs/reviews/review-scalar-guard-token-wrapper-repair.md.
- docs/reviews/review-scalar-guard-semantics-0655fa76be.md.
- docs/reviews/review-scalar-guard-source-contracts-4a4435a5ba.md.

Also read the root checkout's
tmp/guard-native-repair-continued/relation-true-join-report.md, including its
distinction between local-update evidence, the formerly failing joined equality,
and the final two-arm proposal. Its candidate hash matches the final source.

## Integration assessment

1. **The final join delta adds proved cuts, not premises.** At final source
   lines 2144–2154, the nonzero target arm asserts the true-flow equality directly
   after its indexed write and calls Lemma_Flow_Equality. The newly explicit
   zero-target arm asserts the same equality and invokes the same helper. Its
   equality follows from the initial copy and Refined_Flow's existing zero case.
   The existing false-flow write, joined equality assertion, subsequent equality
   bridges, final model equality and flow-validity obligations remain in place.
   No executable assignment, target-selection test, threshold, refinement rule,
   return, native contract, domain, or prover setting changes in this delta.
   The new else arm contains only Static proof material.

2. **The equality bridge remains a native proof obligation.**
   Lemma_Flow_Equality is explicitly Ghost => Static and Global => null, with
   Pre => Left = Right and Post => Same_Flow (Left, Right). Its body embeds the
   flows in equal conditions and invokes Lemma_Condition_Equality. Same_Flow
   retains discriminant, path and componentwise value equality, and the exact
   Ghost/Global/Logical_Equal aspects remain source-checked. The bounds checks in
   Lemma_Condition_Equality distinguish native array equality from sliding.
   Neither the new call nor the Logical_Equal annotation is treated as an
   unproved assumption by this review. Native verification must establish the
   annotation, helper body, every call precondition and retained assertions.

3. **Worker correspondence still uses the exact native domain.**
   Read_Relation_Into retains its text/cursor, Valid_Context, Valid_Flow and output
   count preconditions, its runtime validity/progress postcondition, and its
   Static equality to Relation_Model. PredicateNativeWorkers.outputSpec checks
   that header, including rank 2; Workers.Refinement exposes the same equality
   on legal calls with count = facts.count. The implementation body is connected
   through that verified contract. The final proof-only body changes therefore
   do not require another handwritten executable-body renderer. They do require
   the already-planned complete native verification and final authoritative
   source refresh. The orientation repair remains unchanged: Scalar_Condition,
   its typed native equation, and semantic refinement use the executable
   worker's first-candidate test rather than equality of target identities.

4. **The previous domain and callee repairs survived integration.** All five
   token-wrapper repair hashes match their reviewed candidates. Four of the five
   context-domain repair hashes match exactly. The remaining file,
   PredicateLoopFlowValidity.lean, has SHA-256
   `627763dfd808915f9031f2705a5b12dfc35a474bf64943762523c6e2aabdc1f0`:
   replacing only `theorem nativeLoopInner_baseReady` with its earlier name
   `theorem loopInner_baseReady` reproduces the reviewed hash
   `3e844f99ea6e9a906fe8da1ca2bc32653226cfdca4d2ffe6c476587e38f5eaba`.
   Thus the reviewed argument is retained under the integration rename.
   Native.ValidContext still carries BaseReady independently of ValidFlow,
   covering active mutable suffix cells while permitting empty immutable loop
   indexes. The source bridge still requests inherited helpers on
   OuterReadiness.domain. Raw Take_Token meaning and arbitrary Initial_Flow
   normalization are not replaced with unconditional semantic shortcuts.

5. **Source-check instantiation and the public facade retain the reviewed
   interfaces.** ComposeSourceChecks, PredicateScalarBodyCandidate and
   PredicateSourceBridge match the final-source review's exact transfer hashes.
   PredicateAdmission, PredicateNativeScalarHelpers,
   PredicateScalarGuardMeaning, PredicateNativeSourceChecks,
   PredicateSourceCandidate and PredicateSourceRequirements match the final
   orientation review's hashes. The candidate retains the added
   lemma_flow_equality_impl field and all 50 native-source requirements; the
   earlier 49-field copy has not been restored. PredicateNativeSourceBridge
   matches the repaired hash
   `ee72f79cfd6a635d38feb32e4425333ba96afc8dbf2726920db8bc7514eb7ebf`:
   its public condition theorems take ActiveFlow/ValidFlow and include context
   in ValidResult.

6. **Public assurance stays conditional at the documented boundary.**
   PredicateSourceChecks.actualSource transports candidate checks through
   actual_complete_shape on the authoritative spec/body tokens; its checked
   source also retains inherited helper checks, precedence and scope.
   PredicateSourceBridge.checked_source assembles these checks without replacing
   them with a model witness. InterpretedSource still requires inherited helper
   interpretation and Implementation.Definitions, and executable_correspondence
   additionally requires all four ExecutableRefinement equalities. The public
   PredicateCorrespondence membership, main-correctness and pipeline theorems
   continue through these interfaces; automatic external generation/solver
   completion retains the existing Current.ToolContract. There is no new claim
   that syntax matching, a model witness or a passing example alone proves the
   native implementation or discharges every application obligation.

## Earlier review coverage and retained frame evidence

The semantic review at `0655fa76be` covers selected guard eligibility/staticness,
both outcomes, short-circuit reachability, assignment replacement, exact immutable
cells, captured bounds, repeated loop execution and obligation/admission flow
agreement. A path-specific Git comparison of the 19 directly inspected proof
files named by that review finds changes in only PredicateFlowInvariant,
PredicateHeaderFlow, PredicateBodyMeaning and PredicateScalarGuardMeaning. The
first three have the exact independently reviewed #244 repair hashes; the last
has the exact independently reviewed orientation-repair hash. The other 15 files,
including ScalarFlow, PredicateChecking, PredicateStatements,
PredicateExecution and PredicateObligations, are unchanged. That semantic review
therefore remains applicable with the two bounded repair reviews; a second broad
semantic audit would duplicate covered work.

The source-contract review at `4a4435a5ba` identified the full-domain raw-token
finding tracked as #243. Its reviewed unaffected boundaries included native
header readiness, arbitrary reader/overlay imports, Initial_Flow's count-only
domain, active allocation extents and finite caller inventories. The exact
five-file token-wrapper repair, later #244 context-domain repair, final-source
review and orientation review supply the subsequent independent coverage.
Their final integrated bytes and public consumers were checked above. No
uncovered independent-review obligation was identified after that chain and
this final join review. Successful final validation remains necessary and is
not inferred from review coverage.

Read the final frame package's README/validation record and the final-source
section of docs/evidence/scalar-guard-refinement/parser-frame-account-20261026.md.
Independently decompressed the retained final-frame parser and confirmed its
SHA-256 is
`956eff6874727f95fcb1ede29b537705f96bf916d05483d1813198aeb0f1ea74`.
Its complete diff to final `ec2f...` is exactly the nine added lines reviewed
above: two Static assertions, two calls of the existing Static/pure helper, and
the else line. No runtime object, reader overlay, cursor invariant, contract,
branch test or allocation site is added. Under the existing GNAT static-ghost
erasure premise in docs/trusted-boundary.md, these additions preserve the
runtime allocation/lifetime analysis. The `956eff...` build and boundary
observations can therefore be retained with this explicit final-delta
applicability statement; they are not relabeled as a fresh `ec2f...` build or as
independently established binary identity.

The retained final frame evidence supersedes the old Body_Tail per-iteration
secondary-release claim: that mark/release pair is absent in the final observed
assembly. Its conservative successful-body payload count already counts every
allocation, including formerly released ones; the final Static-only delta does
not change that source/site accounting. The observed 105 admission cases and
20 source-boundary shapes at 8192 KiB remain bounded observations on the retained
inputs. The conditional source-budget/payload arithmetic, external allocator and
sufficient-resource premises remain exactly qualified. **No universal 8 MiB
bound, malformed-prefix capacity theorem, or all-route primary-stack bound is
claimed.** This applicability check does not repeat frame validation or resume
deferred capacity work.

## Remaining delivery evidence and review coverage

The brief reports all 22 selected region checks passing in
`20261026T083814-1b657c3ee2da` and the final-source full native run
`20261026T084316-ffe7696c9a8a` still active. The preceding complete Lean run
`20261026T074542-45d3cf58824e` captured the earlier `956eff...` native source;
even a successful completion of that run does not certify the final `ec2f...`
annotations. The lead also reported successful regenerated-certificate parity
run `20261026T084854-8fd2b4b2d2e8` (26 certificates, 8.424 seconds). These are
attributed lead reports, not independent proof executions or evidence audits by
this reviewer. Certificate parity is distinct from complete source/kernel
validation.

Delivery still requires the existing final-source native proof/audit, complete
Lean source/module/axiom/provenance checkpoint, and applicable full capability
validation and evidence reconciliation. Existing prepared capability/assurance
records must be updated only to the results actually achieved. No additional
independent semantic review is requested for these unchanged final bytes: this
review closes the identified final integration delta while reusing the previous
scoped reviews. New substantive changes or failures should receive targeted
review of their actual consequences. No new approval ceremony, deferred work,
or additional validation gate is proposed.

Final report preparation and applicability follow-up completed at
2026-10-26 08:54:26 UTC: 390 seconds elapsed since initial inspection, including
report writing. No token/cost measurements are available.
