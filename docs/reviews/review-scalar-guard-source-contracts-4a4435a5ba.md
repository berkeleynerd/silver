# Review: scalar guard native-contract interpretation

2026-10-26. Independent bounded critical review; selected GPT-6 Astra at Extra
High. Runtime model/effort are not independently exposed. Inspection interval:
04:49:51–04:55:48 UTC (5 minutes 57 seconds). Report writing and the final
input-state check completed at 04:56:53 UTC (7 minutes 2 seconds total). Token
and cost measurements are unavailable.

Exact target: `4a4435a5ba9807884d0b1bab9855e182730376b6` in
`tmp/scalar-guard-refinement`, compared with the earlier semantic-review target
`0655fa76beffc2126c3441471d292d5eaafb8d44`. Initial and final inspection checks
found that exact HEAD and only untracked `tmp/` content. Authorization is the
lead's bounded review of owner-authorized scalar guard work; no deferred work
is included.

## Verdict

**One material source-correspondence finding.** The new `Body_Token_Model`
interpretation requires an equality that is false for some tokens admitted by
its stated native/formal domain. Its normalization path also omits the raw
`Take_Token` dependency. This must be repaired before the interface can establish
actual-source correspondence. No additional concrete mismatch was found in the
other inspected interfaces. This does not identify an application admission bug:
the existing basic/body/loop call sites use narrower fixed-token sets.

## R1 — Body_Token_Model assumes the wrong token semantics on its declared domain

`PredicateAdapterEnvironment.lean:136` defines `Wrappers.TokenDomain` using
`Compose.Expressions.ValidToken`. That includes `.capacity`, `.literal`, and
other non-fixed pseudo tokens (`ComposeContracts.lean:29`). The new
`ModelEquations.token` requires the model function to equal `tokenExpr.eval`
throughout that domain (`PredicateAdapterEnvironment.lean:141`).

However, the evaluator hardcodes `Predicate.bodyToken`
(`PredicateAdapter.lean:233`). This calls `Compose.tokenAfter`
(`PredicateBodyAdmission.lean:30`), which returns zero for every non-`.fixed`
token (`ComposeAdmission.lean:115`). The native `Body_Token_Model` instead calls
the actual `Take_Token` (`silver_output_profile.adb:1374`), whose contract and
implementation use `Fixed_After`/`Spelling` (`:264`). Native `Spelling` maps
`Capacity_Literal` to `"0"`, `String_Literal` to a quote, and pseudo tokens to
`"_"` (`:33`).

A concrete legal API witness requires no program-level assumptions:

- `Text = "0"`, one-based, length one; `Scan.Position = 1`.
- Empty valid String/scalar environments, `Declaration_Count = 0`, zero dynamic
  name positions, and a zero-count valid scalar flow; target/capacity can be zero.
- `Token = Capacity_Literal`, represented by `.capacity`, which satisfies
  `ValidToken`.

The native model/wrapper returns position **2** after matching `"0"`; the stated
Lean model equation returns position **0**. Both the source precondition and
`Wrappers.TokenDomain` permit this call. Consequently the actual native function
cannot inhabit the current `ModelEquations.token` interface. The concrete
mathematical witness remains inhabitable because it uses the same hardcoded
model; that witness does not resolve the source-domain contradiction.

The missing dependency is visible separately:
`normalize_models` normalizes `Initial_Flow` but copies
`token := definitions.token` unchanged (`PredicateAdapterEnvironment.lean:149`).
`Implementation.wrapper_models` explicitly omits inherited helpers
(`PredicateEquations.lean:90`), and `body_helpers.bodyToken` consumes that premise
(`:111`). The adjacent `body_helpers.token` proves the inherited raw token
meaning (`:106`) but does not connect it to `Body_Token_Model`. Thus this is more
than an unfinished top-level source check: the committed interface itself asks
for the wrong equality on a legal input.

Repair by retaining an arbitrary raw `Take_Token` callee in the wrapper model
equation, then deriving its normalized meaning from
`Compose.Expressions.interpreted_take` (`ComposeEquations.lean:47`). Either model
the full native enum semantics, or restrict the semantic `bodyToken` projection
to the fixed-token domain actually used by callers and prove that restriction at
every relevant call site. The existing basic/body/loop token-completeness proofs
can support the latter. Do not silently narrow the source contract or retain an
unproved full-domain `ModelEquations.token` field. Propagate the corrected
interface through basic/loop wrapper links, the implementation definition record,
and its explicit witness.

The source author independently confirmed the absent raw-to-normalized wrapper
derivation after this reviewer raised it. No source-author draft was read or
approved, and no proposed repair is covered by this report.

## Other reviewed boundaries

- `HeaderReady`/`OuterReadiness.domain` matches the existing native
  `Valid_State` nonempty-declaration and mutable-containment clauses. Its initial,
  declaration, loop and outer preservation arguments do not introduce a new
  application restriction. The inherited helper equations are parameterized by
  this domain, and `InheritedReady` supplies the corresponding explicit witness.
- Scalar/String readers retain arbitrary overlay and reader calls until their
  source contracts and inherited meanings identify them. Immutable metadata,
  active count, scalar intervals and loop masks remain distinct in those links.
- `Initial_Flow` uses the native count-only input domain, and its complete
  count/path/cell contract is normalized before `Body_Of` projection. This avoids
  importing declaration readiness as an unsupported precondition for that helper.
- Joined/widened flow storage, invalid records, assignment replacement, the loop
  inner allocation/copy/index update, and recursive-body local assignments have
  explicit extent arguments. The model witnesses preserve the same entry and
  inner counts rather than erasing a mismatched discriminant.
- Basic/body/loop finite token inventories are checked against their complete
  typed command trees. They contain fixed tokens and therefore avoid R1 at
  those application call sites. R1 concerns the broader wrapper interface used
  to justify them.

## Inputs and limits

Reused the prior review's governing instructions and semantic conclusions;
reread the current capability record and inspected the change inventory since
`0655fa76be`. Read the native `Valid_State`, `Valid_Context`, flow/reader/adapter
and token contracts/implementations, plus the new native ghost-annotation diff.

Proof inputs inspected directly, in full or the relevant definitions/proofs:
`ComposeAdmission`, `ComposeContracts`, `ComposeExpressions`, `ComposeEquations`,
`ComposeEvaluation`, `ComposeSourceBridge`; `PredicateAdapter`,
`PredicateAdapterEnvironment`, `PredicateInheritedReady`,
`PredicateOuterReadiness`, `PredicateOuterEquations`, `PredicateEquations`;
`PredicateBasicHelpers`, `PredicateBasicLibraries`, `PredicateBasicSizing`;
`PredicateBodyAdmission`, `PredicateBodyExpressions`, `PredicateBodyEquations`,
`PredicateBodyCorrespondence`, `PredicateBodyHelpers`, `PredicateBodySizing`,
`PredicateBodyModelSizing`, `PredicateBodyWrappers`; `PredicateLoopNative`,
`PredicateLoopImports`, `PredicateLoopHelpers`, `PredicateLoopSizing`;
`PredicateScalarBodyNative`, `PredicateScalarBodyHelpers`,
`PredicateScalarBodySource`; `PredicateNativeState`,
`PredicateNativeScalarHelpers`, `PredicateNativeLibraries`,
`PredicateFlowReaders`, `PredicateFlowReaderLibraries`, and
`PredicateFlowSourceBridge`.

The old canonical `PredicateSourceBridge` and selected candidate/source-check
references were read only to locate dependencies. Their known pending final
integration is not a finding and receives no approval here. The lead-reported
fresh audit `20261026T044700-92f77d7e4b48` was not rerun or independently audited.
Conditional Lean theorems and concrete model witnesses remain distinct from
the applicability of their premises to native source, which is R1's concern.
Pending native proofs, final pins, full actual-source checks and later drafts are
outside this verdict. No runners, project edits, Git operations that change state,
or GitHub posts were performed; only this scratch report was written.
