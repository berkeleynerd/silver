# Guard source-candidate elaboration repair — 2026-10-26

The five reported errors have **two local causes**: the Read_Body header proof
asks kernel reduction to normalize an imported mutual renderer directly, and two
private header lemmas spell their expected lexer as `Source.lex` while the
required interface uses `Source.lexLine`. The smallest proposed repair changes
only PredicateSourceCandidate.lean: explicitly normalize the typed renderer in
one proof, and correct those two lexer spellings. No source requirement, native
contract, semantic definition, public endpoint statement or Ada source changes.
The final renderer correction explicitly uses `ModelExpr.render.eq_def` and
`ModelExpr.renderElse.eq_def`; the ordinary-import renderer-only check now passes.
The initial shorthand normalization below failed and is retained as diagnostic
history. The final patch and bounded success are recorded at the end.

This is a static diagnosis and patch review with attributed, subsequently read
renderer-only validation, **not a successful full-candidate elaboration claim**.
No validator, proof-workspace/source edit or Git/GitHub mutation was performed
by this reviewer.
Only this report is written. The active run and its captured inputs are left
intact. Selected reviewer remains GPT-6 Astra at Extra High, confirmed by the
lead; runtime model/effort are unexposed. Review began at 09:07:26 UTC. Token/cost
measurements are unavailable; final elapsed time is recorded below.

## Exact inputs and observed failure

Canonical checkout: tmp/scalar-guard-refinement, HEAD
`b4b2e79aaa099422494c352b5f069d19e37d5a1c`. The five proof files below are unchanged
from the prior `bc9b0815eb` integration, and independently recomputed hashes match
the active workspace's captured files byte for byte:

| File under proof/Silver | SHA-256 |
| --- | --- |
| PredicateSourceCandidate.lean | `1ca4c654328841835a62904993210071847a716d2481f1efe04e44564eb1a29e` |
| PredicateSourceRequirements.lean | `59149beae0b1fdfb59f819c8e53c7729ad8708045abb946f4a23673687bc2552` |
| PredicateBodyExpressions.lean | `4941ac3c5e93d1b508d807a4354a9f9bc21de3108d4abcfd0a84854f085277b5` |
| PredicateBodyCandidates.lean | `890c42cb661c9bc4af832815cef8869e6cde26fae46622193844f9ca5136703c` |
| SourceLexer.lean | `6c2824f4ed5b303b3a3f3ec94d8cdb650ffbd86103eef842a32a3c6f3755a8eb` |

Read the tail of root checkout
tmp/review-b79-b1-lean/tmp/guard-final-source-check.log. It reports
PredicateSourceCandidate failing after 4,153 seconds at lines 396, 555, 561,
679 and 681. The same retained log records successful PredicateBodyCandidates
(8.2 seconds) and PredicateSourceRequirements (7.2 seconds). The complete run
remains incomplete, with OutputBodyCertificate still active according to the
lead. These partial observations do not establish full validation.

## Why this repair addresses the reported causes

**Read_Body renderer.** PredicateBodyExpressions already has an exposed public
section and is publicly imported through PredicateBodyCandidates and
PredicateSourceRequirements. The symbol is resolved correctly; this is not a
missing namespace/import error. `ModelExpr.render`/`renderElse` are mutually
defined. The failed `decide +kernel` residual reaches
`BodyNative.readContractBody.render` while comparing the expected token list.
The directly relevant successful precedent is
PredicateBodyCandidates.rendered_body_tail_model: it explicitly rewrites
`ModelExpr.render`, `ModelExpr.renderElse`, ScanExpr, Test and StopRef equations
before invoking `decide +kernel`. Reuse that local normalization pattern for
readContractBody. No broad `import all Silver...`, extra exposure annotation,
definition replacement or kernel option is needed for the proposed repair.

This diagnosis does not pretend to have identified a deeper generated Lean
auxiliary constant from the log alone. The observed obstacle is direct kernel
normalization of this renderer expression; its existing public equations provide
the bounded repair without depending on hidden implementation details.

**Header lexer.** SourceLexer defines `lexLine` directly over the restricted
lexer, whereas `lex` splits a complete source into lines and calls `lexLines`.
The failed private candidate lemmas use the latter. Requirements lines 419 and
421 explicitly require `Source.lexLine`, causing both unreduced `decide` goals
and the later record-field type mismatches. Correct the two private candidate
propositions to exactly those required types. The strings themselves remain
unchanged and contain no newline. Do not change Requirements to `Source.lex` or
import hidden string-splitting code to keep the accidental spelling.

**Preservation.** The Read_Body requirement still concatenates the same
lexLine-derived prefix, `BodyNative.readContractBody.render`, and lexLine-derived
suffix. Its native header at src/silver_output_profile.adb:2802 still states the
same Static conditional expression:

```ada
(if Statement_Body (Text, Context, Scan).Position = 0
 then Invalid_Body (Statement_Body (Text, Context, Scan))
 else Body_Tail_Model (Text, Context, Statement_Body (Text, Context, Scan), Stop))
```

The existing typed definition is exactly the grouped zero-test, invalid branch
and tailModel branch for that expression. PredicateBodyEquations.read_eval and
all evaluator/rendering definitions remain untouched. The repair only invokes
their existing rendering equations while proving the unchanged header equality.
Both corrected private header propositions now supply exactly the unchanged
Checked.valid_flow_header and Checked.included_header fields. No requirement is
removed or weakened; the private helpers' erroneous lexer spelling is corrected.

## Initial proposed patch — renderer proof failed; superseded below

Apply to the exact candidate hash above. This patch was prepared by inspection;
the reviewer has not applied or elaborated it.

```diff
diff --git a/proof/Silver/PredicateSourceCandidate.lean b/proof/Silver/PredicateSourceCandidate.lean
--- a/proof/Silver/PredicateSourceCandidate.lean
+++ b/proof/Silver/PredicateSourceCandidate.lean
@@
 private theorem candidate_body_read_body_spec_header : functionHeader "read_body" ";" SourceShape.bodyTokens = some body_read_body_spec_header := by
+  unfold body_read_body_spec_header
+  simp only [BodyNative.readContractBody, BodyNative.ModelExpr.render,
+    BodyNative.ModelExpr.renderElse, BodyNative.ScanExpr.render,
+    BodyNative.Test.render, BodyNative.StopRef.render]
   decide +kernel
@@
-private theorem candidate_valid_flow_header : functionHeader "valid_flow" "is" SourceShape.bodyTokens = some ((Source.lex "(Context : Body_Context; Facts : Scalar_Flow) return Boolean").getD []) := by
+private theorem candidate_valid_flow_header : functionHeader "valid_flow" "is" SourceShape.bodyTokens = some ((Source.lexLine "(Context : Body_Context; Facts : Scalar_Flow) return Boolean").getD []) := by
   decide +kernel
@@
-private theorem candidate_included_header : functionHeader "included" "is" SourceShape.bodyTokens = some ((Source.lex "(Value, Bounds : Scalars.Interval) return Boolean").getD []) := by
+private theorem candidate_included_header : functionHeader "included" "is" SourceShape.bodyTokens = some ((Source.lexLine "(Value, Bounds : Scalars.Interval) return Boolean").getD []) := by
   decide +kernel
```

## Initial three-goal preflight — renderer proof failed; superseded below

First let the active complete run finish and retain its successfully built
objects. Do not alter its inputs or run a second writer. The lead can then use
the pinned Lean 4.34.1 environment and a managed scratch check containing the
three propositions below. It imports the already-built Requirements rather
than PredicateSourceCandidate, so it does not execute the other candidate
proofs. It checks the actual three formerly failing extraction propositions,
including the exact types needed by the final assembly. This is a local
diagnostic preflight, not a substitute for the final project runner/audit.

```lean
module
import Silver.PredicateSourceRequirements
import all Init.Data.Repr

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Predicate.SourceChecks
open Silver.SourceBridge

example : functionHeader "read_body" ";" SourceShape.bodyTokens =
    some body_read_body_spec_header := by
  unfold body_read_body_spec_header
  simp only [BodyNative.readContractBody, BodyNative.ModelExpr.render,
    BodyNative.ModelExpr.renderElse, BodyNative.ScanExpr.render,
    BodyNative.Test.render, BodyNative.StopRef.render]
  decide +kernel

example : functionHeader "valid_flow" "is" SourceShape.bodyTokens =
    some ((Source.lexLine
      "(Context : Body_Context; Facts : Scalar_Flow) return Boolean").getD []) := by
  decide +kernel

example : functionHeader "included" "is" SourceShape.bodyTokens =
    some ((Source.lexLine
      "(Value, Bounds : Scalars.Interval) return Boolean").getD []) := by
  decide +kernel

end Silver.Predicate.SourceChecks
```

If the first goal still reports a reduction obstacle, isolate only
`BodyNative.readContractBody.render` against the lexLine tokens of the displayed
conditional expression using the same simp list. That distinguishes renderer
normalization from full-source header extraction without another hour-long
candidate run. Do not increase heartbeats or alter requirements to hide an
unexplained mismatch. Once the three direct goals pass, integrate this candidate
patch and run the normal focused PredicateSourceCandidate check, followed by the
already-required complete final-source validation. Retain source-certificate
objects whose captured inputs are still current; the final nine-line source
refresh remains a separate pending input change.

## Final handoff

Report and preflight preparation completed at 09:12:12 UTC. The lead confirmed
receipt and selected the three-goal preflight after the active workspace becomes
free. Final handoff clock: **2026-10-26 09:13:27 UTC**, **361 seconds** elapsed
since review start, including report preparation and coordination. No validation
was rerun to obtain these measurements; token/cost measurements remain
unavailable.

At that handoff, HEAD had advanced by documentation changes to
`8a47bb714908083d30524fd33c93d6faa64a090e`, and the lead had applied the candidate
repair as pending source edits. Its new SHA-256 is
`be7a197ab24f3f70fcb229d27cc75c744734d43a24e78284461ced00cd6f5d1e`.
The reviewer read that final diff: it contains exactly the proposed renderer
normalization and the two lexLine corrections. This is a static patch recheck,
not a proof-success claim. The active native/certificate checkpoints remain
untouched by this reviewer.

## Follow-up: explicit mutual-renderer equation — 09:27 UTC onward

The first proposed renderer proof above **did not elaborate**. The lead's
three-goal preflight log, tmp/review-b79-b1-lean/tmp/guard-candidate-repair-preflight.log,
records 203 seconds in GuardCandidateRepairCheck (312.726 seconds for its build
phase including dependencies). The two corrected lexLine goals produced no
errors; the Read_Body goal still failed. Its residual exposes
`BodyNative.ModelExpr.render._mutual (PSum.inl (...).group)`. Four downstream simp
arguments were unused because normalization had not passed that group node.
Thus the original suggestion's claim that the existing shorthand simp pattern
would suffice is superseded. Do not retry full-source extraction with that
unchanged proof.

The follow-up began at 2026-10-26 09:27:35 UTC, selected GPT-6 Astra/Extra High as
before. This reviewer performed only read-only source/log inspection and report
edits; the lead performed every managed diagnostic.

The lead next tried import-all plus direct `decide +kernel` on only
readContractBody.render and its expected token list. That failed in two seconds
(15.413-second build phase). This rules out that combination as a complete
repair; adding import-all is not itself an unfolding theorem.

The retained diagnostic log
tmp/review-b79-b1-lean/tmp/guard-renderer-equations-diagnostic.log then printed
the actual declarations:

- ModelExpr.render is an `@[irreducible]` wrapper whose body applies
  ModelExpr.render._mutual to `PSum.inl`.
- ModelExpr.render.eq_def is a proved equation exposing the complete five-case
  match. It **already contains**
  `.group expression => ["("] ++ expression.render ++ [")"]`.
- ModelExpr.renderElse.eq_def supplies its complete match, including the
  ordinary else case.
- The packed `_mutual.eq_def` proof uses WellFounded.fix_eq. This is a proved
  unfolding step, distinct from kernel computation through an opaque or
  irreducible fixed-point implementation.

The pinned Lean source inspected here corroborates that construction:
Lean/Elab/PreDefinition/WF/PackMutual.lean creates the PSum `_mutual` function;
WF/Main.lean creates the individual binary unfolding equations; and
PreDefinition/Mutual.lean marks the original definitions irreducible before
enabling equation realizations. The earlier failed shorthand simp unfolded the
wrapper instead of using the needed full-match equation. The successful
tailModelBody candidate has no `.group` node, so it did not establish this
constructor's normalization path. The printed full equation disproves the
suggestion that the typed renderer itself lacks the group case.

The reviewer also suggested `#print prefix`, which is not valid syntax in the
pinned toolchain. That diagnostic command failed after the relevant equations
had printed; no semantic conclusion is drawn from that command's failure.

The lead's next renderer-only check uses **ordinary**
`import Silver.PredicateBodyExpressions`, followed by the exact same concrete
renderer goal, with:

```lean
  simp only [readContractBody, ModelExpr.render.eq_def,
    ModelExpr.renderElse.eq_def, ScanExpr.render, Test.render, StopRef.render]
  decide +kernel
```

This tests the published equations directly without private implementation
imports or a source-header scan. If it passes, the only required adjustment to
the earlier candidate patch is replacing `BodyNative.ModelExpr.render` and
`BodyNative.ModelExpr.renderElse` in its simp list with their `.eq_def` theorems.
Retain the existing unfold of body_read_body_spec_header, all other proof
arguments and the two lexLine corrections. No public type, requirement,
renderer/evaluator definition, native source or assurance premise changes.
Do not return to the complete source candidate until this tiny goal has passed.

The diagnostic conclusions above are based on actual printed declarations,
not a claimed successful result of the new ordinary-import equation check.

## Final correction and successful renderer-only check

Managed run **20261026T093333-027143e77aea** passed the ordinary-import
renderer-only goal using the two explicit public `.eq_def` theorems. The
reviewer read the complete retained
tmp/review-b79-b1-lean/tmp/guard-renderer-equations-preflight.log: the target
built in 20 seconds; the build phase took 33.875 seconds, and the fresh audit of
**14,718 declarations** passed in 17.566 seconds with the existing foundations
`propext`, `Classical.choice` and `Quot.sound`. The lead supplied the run ID;
the logged result was independently read. This reviewer did not execute it.

The exact scratch goal source,
tmp/review-b79-b1-lean/proof/Silver/GuardRendererRepairCheck.lean, has SHA-256
`77f343a44f2a545d04ad2ddb8664ab8f3c09d3ed583295d8b67f688694ccaa1b`.
It imports ordinary Silver.PredicateBodyExpressions and the existing
Init.Data.Repr compatibility import, then proves only the concrete unchanged
readContractBody renderer equation against its lexLine token list. It introduces
no extra assumptions, altered model or kernel bypass.

The lead's final pending PredicateSourceCandidate.lean has SHA-256
**`ab16a4e477e3fc8c21a2d4439cb7f0d902969ac3fa89a8ec053b73d6c47e4edf`**.
The reviewer independently recomputed that hash and inspected its complete diff:
six inserted lines and two removed lines, comprising only the two earlier
lexLine corrections and this final proof body:

```lean
private theorem candidate_body_read_body_spec_header :
    functionHeader "read_body" ";" SourceShape.bodyTokens =
      some body_read_body_spec_header := by
  unfold body_read_body_spec_header
  simp only [BodyNative.readContractBody, BodyNative.ModelExpr.render.eq_def,
    BodyNative.ModelExpr.renderElse.eq_def, BodyNative.ScanExpr.render,
    BodyNative.Test.render, BodyNative.StopRef.render]
  decide +kernel
```

No import-all line or defining-module change is required. The remaining two
private header lemmas use exactly the unchanged requirement strings with
Source.lexLine. All native source, formal definitions, required public theorem
types and assurance premises remain unchanged.

The lead has started the three actual header extraction goals against final
`ec2f...` source-shape inputs, logged separately in
tmp/review-b79-b1-lean/tmp/guard-candidate-repair-final-preflight.log. That check,
the complete candidate build and the final source/native assurance checkpoint
remain separate evidence; no result is inferred for them here.

Follow-up inspection/report handoff: **2026-10-26 09:35:50 UTC**, **495 seconds**
since the 09:27:35 follow-up start, including source inspection, diagnostic
coordination and report preparation. The selected model/effort remained
GPT-6 Astra/Extra High; runtime settings and token/cost measurements remain
unavailable. This round isolated the exact well-founded unfolding equation and
replaced the failed shorthand proposal with a checked renderer normalization.


## Lead integration and source-header validation

The reviewed repair is committed at `d039e68dba`. Managed run
`20261026T093522-12961dacbd93` subsequently passed all three direct source-header
extraction goals against the final parser shape. Its build/audit phases took
168.087/15.926 seconds; the fresh audit covered 24,365 declarations with the
unchanged foundations. [Retained inputs, results and diagnostics](../evidence/scalar-guard-refinement/candidate-repair-20261026/index.json)
keep this partial check separate from the earlier renderer-only success and
failed complete run.

The preceding complete run had already failed its candidate module. Its one
remaining certificate worker used the superseded parser and was deliberately
interrupted after retaining the log and every completed object. No completion
is claimed for that run. The final complete source build/audit now runs against
`d039e68dba`; the unchanged native checkpoint remains independent.
