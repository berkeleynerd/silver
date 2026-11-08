# Minimal remaining native repair plan — 2026-11-08

This is an unapplied proposal for issue #298. It supplies the bounded native
changes, their semantic/source-correspondence obligations, and the evidence
invalidation needed before acceptance. No candidate Ada file was written and no
native or Lean validation was executed by this reviewer. Static construction,
inspection and artifact hashing are not proof discharge.

## Exact source and ownership

The original failed run is `20261108T040128-2651963b8574`, parser SHA256
`9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f`.
The native owner's separately authorized `Parameter_Frame` entry guard is source
commit `b8365c0606e0d2e185e89a73264b10cf72530e06`, parser SHA256
`e23559aa4b480bb4f69df99fb9c28c590ef9320388dc48c44e2604dd5226918c`.
`remaining-three.patch` applies only to that guard base and changes five sites in
`src/silver_output_profile.adb`. Its SHA256 is
`a6c87808887548b8723e7febfce0823a6679312b55fb3b21da5873d27355ee21`.
The combined candidate constructed in memory has SHA256
`036a53b4bd9a9d7c711b4ddf8d83467a6b470184bfce2ac6677b15cf4f57ef47`.
`inventory.json` records exact substitutions and body locations.

The native owner owns application, native checks and native evidence. The
coordinator owns integration, Lean implementation and the already prepared
`FunctionDeclarationSource.loops` guard update. This reviewer owns this plan,
scratch artifacts and the existing review report only. No active run's captured
inputs may be edited. The coordinator reports that Lean run `064001` has now
ended and its lease is released; retain its actual outcome and evidence before
resuming work on changed inputs.

The guard alone passed full selected-subprogram run
`20261108T084757-1036cb8a0958`: actual exit 0 after 82.341 s, 27 proof records,
2 flow records, all 82 proof-tree branches and all 14 postcondition branches
proved. Evidence commit `5a92be1916ae1d748c354a4ced9ad59102eea13d` contains its
155-artifact packet. This proves the selected function on the guard base; it is
not a complete native audit of the candidate. The owner's ledger clarification
found no earlier completed focused scope for these four failures; interrupted
run `014042` has no completed parser report. The earlier incomplete whole-run
reports do not establish success for those obligations.

## Five proposed changes and the argument each supplies

1. Strengthen `Scalar_Declaration_At`'s existing successful-result postcondition
   with preservation of `Functions`, `First_Parameter` and `Pure`.
2. Add the same successful-result facts to `Boolean_Declaration_At`.
   Their successful source branches change only the position and their own name
   environment. Failure returns `Invalid_State`, so preservation is guarded by
   nonzero result. Prove both strengthened callee contracts, then prove the
   unchanged `Function_Local_At` contract from those facts. Keep its whole-field
   equalities and every existing validity/progress fact.
3. In `Actuals_Model`, reject a zero comma-token result explicitly before
   recursing. On the recursive branch the comma position is positive and advances
   beyond the previous actual; the unchanged induction contract then gives the
   required progress from the original cursor. The zero branch needs no new
   recursive zero-input contract.
4. In `Actuals_After`, reject the zero comma cursor before incrementing the formal
   index. This matching executable guard is required: it keeps the loop's static
   model-equality invariant aligned with the changed ghost model. Keep every
   invariant and variant, including the complete model-equality postcondition.
5. In `Function_Return_After`, reject `Start = 0` before `Actual_After`. On the
   remaining branch the successful keyword and existing actual-result progress
   compose directly. This avoids introducing stronger native zero-input contracts
   throughout the predicate/scalar dependency chain.

All five changes preserve every precondition, the admitted domain, all existing
assertion levels, and all loop invariants/variants. The two early rejections are
semantically equivalent to the existing Lean models because the actual reader
returns zero on zero input; that equivalence must be proved, not inferred from a
new source pin. They are separate from `Parameter_Frame`, whose old executable
result actually disagreed with its existing model on an admitted zero-position
state.

## Exact Lean source and semantic work

Preserve existing model definitions and domains. The following are the required
direct edits and affected source checks, not permission to rewrite their broader
dependencies.

| File under `proof/Silver/` | Required work |
| --- | --- |
| `PredicateCallAdmission.lean` | Prove unconditional `actualAfter_zero` and `actualsAfter_zero` for arbitrary source/context/facts/formal/catalog/index values. Keep `actualAfter` and `actualsAfter` definitions unchanged. |
| `PredicateFunctionCallNative.lean` | Add the failed-comma `.elsif` to `actualsBody`, using existing `Expr` constructors and exact source order. No AST extension. |
| `PredicateFunctionCallEquations.lean` | Update `actuals_model`: after nonzero actual and nonfinal formal, split the comma result; zero uses `actualsAfter_zero`, nonzero uses the current equation. Preserve the existing ordered-domain hypothesis. |
| `PredicateFunctionCallHelpers.lean` | Update `normalized_actuals_at` for the same branch. The zero branch must show the unchanged model recursion at zero returns zero. The nonzero branch retains the induction on `last - first` and existing domain/totalization discipline. |
| `FunctionDeclarationNative.lean` | Add the existing `.guard` constructor for `Start = 0` to `returnAfterBody`, before `.returned`; render must match the Ada guard exactly. |
| `FunctionDeclarationDenotations.lean` | Replace `returnAfter_model`'s now-insufficient `rfl` with a zero/nonzero keyword split, using `actualAfter_zero` in the zero branch. Preserve the theorem statement. |
| `FunctionDeclarationImports.lean` | Update `returnAfter_imports` with the same split, its existing token/actual interpretation hypotheses, and `actualAfter_zero`. Preserve `ReturnImports` and its full existing equalities. |
| `ComposeContractSourceCandidate.lean` | Update both exact scalar declaration header lists: the contract requirement and `refinement_scalar_declaration_at` (currently around lines 26 and 148). Add the stronger postcondition, without dropping old clauses. |
| `ComposeBooleanDeclarationSource.lean` | Update `specHeader` (currently around line 45) with the three guarded preservation facts. Body and existing semantic denotation stay unchanged. |
| `FunctionDeclarationSource.lean` | Integrate the coordinator-owned `loops` expected-body update for the already proved `Parameter_Frame` guard. The return-function ordinary body is already based on `returnAfterBody.render`; its new guard follows that render. |
| `ReviewedOutputShape.lean` | Update the authoritative parser shape together with the actual source and semantic changes. |
| `OutputBodyCertificate.lean` and generated `OutputBodyLines*.lean` | Regenerate using the normal generator and retain/check its actual changed buckets. Do not hand-edit generated chunks or assume all eight buckets changed. |

The zero-input proof has a small direct route. For a Boolean formal, unfold
`readCondition` and `readRelation`; the latter rejects zero before inspecting
context, and `invalidCondition.after = 0`. The proof already appears in
`PredicateBodyProperties.readCondition_zero`, but importing that module into
`PredicateCallAdmission` would cycle through `PredicateFunctionCallReadings`.
Use the local definitional argument, or move a genuinely shared foundational
lemma only if necessary; do not add that backward import. For a scalar formal,
`readScalarInFlow` delegates to `ScalarExpression.read`; prove its zero result
using the read/parse definitions and the existing zero-parse argument. Existing
`parseFuel_zero` and `parseWithArrays_zero` show the intended facts, but their
native modules need not be imported if a short local cases proof avoids a larger
dependency. Then one unfolding of `actualsAfter` and `actualAfter_zero` proves
`actualsAfter_zero` without recursive induction. These lemmas must be unconditional
because the model-denotation and normalization zero branches are unconditional.
The private `FunctionDeclarationModelContracts.actual_post` provides corroborating
positive-input reasoning but has validity premises and is not a replacement for
that unconditional shared fact.

Rebuild/check at least these exact source leaves and their aggregate/import
closure: `FunctionSourceParts/CallsActualsModelBody.lean`,
`FunctionSourceParts/DeclarationOrdinaryFunctionReturnAfter.lean`, and
`FunctionSourceParts/DeclarationLoopParameterFrame.lean`, plus the scalar and
Boolean header candidates and the typed-tree/scoping checks affected by the new
guards. The leaves may need no text edits if their imported render/expected body
supplies the updated proposition, but their old objects cannot establish the new
source claim.

`PredicateFunctionCallSource.Checked` checks the `Actuals_After` headers and its
static postcondition, but has no hand-written implementation-body shape for its
loop. Its implementation link is the complete native proof of equality with
`Actuals_Model`. Prove that existing link; do not introduce an unrelated new
source-check mechanism. The scalar/Boolean source denotations and model frame
facts already describe preserved fields, so stronger native export contracts do
not require a changed model or new assumed Lean preservation fact.
`FrameEquations.parameterFrame` continues to rely on the same checked native
static equality, now discharged by the corrected implementation. No premise
weakening or assumed equality is permitted.

## Bounded native checks, then complete validation

On the exact combined candidate, run full selected-subprogram checks for these
six targets under the original settings:

| Body selector in `silver_output_profile.adb` | Function | Purpose |
| ---: | --- | --- |
| 1512 | `Scalar_Declaration_At` | Discharge strengthened frame postcondition. |
| 4457 | `Boolean_Declaration_At` | Discharge strengthened frame postcondition. |
| 4803 | `Actuals_Model` | Discharge full guarded recursive model contract. |
| 4828 | `Actuals_After` | Discharge guarded loop and unchanged static equality. |
| 5628 | `Function_Local_At` | Discharge unchanged wrapper contract using proved exports. |
| 5747 | `Function_Return_After` | Discharge full guarded return-reader contract. |

The guard's `Parameter_Frame` body shifts to line 5718; its separately successful
focus selected line 5710 on the guard base. Do not confuse those input versions.
The next complete native run must include it on final inputs; an identical guard
focus alone need not be repeated merely because preceding lines moved.

Use the managed runner, actual host paths from `scripts/dev.py paths`, standard
project, `-u silver_output_profile.adb`, and the established
`--limit-subp=silver_output_profile.adb:<body line>` form. Retain the original
all/report/warnings/checks, level 2, prover list and 30 s timeout settings; use a
separate exploratory output/cache and a four-worker managed reservation after
checking current run summary/headroom. If combining selectors is not supported,
run sequential selections. Do not narrow to one line, omit subprogram checks,
disable an assertion level or retry a recurring failure without its diagnostic
checkpoint. Verify candidate hash and selectors before execution.

Retain source/preflight/tool identity, real exit/outcome, full reports, generated
tasks, sessions and all selected check branches. The prediction that these local
arguments solve the failures is not a proof result. If a focus fails, record the
new exact task and remaining premise before revising the bounded candidate.

After the focused contracts and corresponding Lean/source edits settle, execute
the required complete native obligation/provenance audit and complete Lean/source
correspondence closure on one identified final input set. Audit every required
obligation and the source link; a successful subset, regenerated pin or old
object alone is insufficient. Preserve successful unaffected evidence only with
an explicit input/dependency applicability argument.

## Regression applicability after these changes

The accepted 637-ID composition remains evidence for
`5aa1509fc5ac2d6f2dc02c5803d94da7e201aaf1`, extended by the reviewed docs-only
comparison to `d396db2aeb498cd132bbe4b9f0ea3f0fb93687f8`. It is not automatic
acceptance of this candidate. The original full run remains failed with 635
passes and 2 errors; repairs supplement it and do not rewrite that outcome.

- Changed parser/compiler bytes invalidate blanket reuse for tests that build
  or exercise that compiler, including native/compiler/sample behavior and
  source/provenance checks bound to those bytes.
- Changed Lean/source inputs invalidate affected source-policy and import-closure
  claims. The platform fixture copies the complete production Lean tree and
  source fixture inputs, so its old successful wrapper does not validate this
  changed fixture. Reassess and run the affected platform scope on the final tree.
- Synthetic fixture methods may retain applicability only after per-ID direct
  and transitive input comparison. Do not automatically reuse the old 619 passes
  as a single unaffected group, or infer that every synthetic test became stale.
- The repaired chunk fixture uses synthetic Ada text and seven fixed production
  Lean helpers. Its old evidence can remain applicable if every actual copied
  helper/test/generator/tool input stays identical; a production parser change
  alone is not that fixture's synthetic input. Verify its dependency set again.
- Rosetta promotion still requires its three fresh tests after its patch. These
  native repairs do not satisfy or cancel that separate requirement.

Reconcile the final discovered test inventory by unique ID with retained and
fresh outcomes, dependency rationale and exact final inputs. Run the affected
methods needed to close gaps; a blind complete rerun is neither assumed necessary
nor prohibited if final dependency analysis warrants it. This is an assurance
repair within the existing capability, not a new language admission or Oracle
amendment.
