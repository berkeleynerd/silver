# Missing ScalarFunctionFrameFlow import — bounded diagnosis

The complete run failed because one independently retained lemma module was
absent from the actual imported audit environment. The smallest correction is
one public import in `proof/Silver.lean`'s existing independent-lemma section.
No semantic consumer, theorem statement, declared domain or audit rule needs to
change. This is a proposed import repair, not a successful Lean check or final
delivery acceptance.

## Exact target and failed evidence

The task target was integration `0912a5e153114b29122e6d5dfa5b4ac6167a4e01`, with
governed inputs `f6308191545c1012d76132ae535977e55fd4f018`. Evidence-only commit
`e43329d491d588660de8b01bb2c2b7227c546e96` was observed while preparing the patch.
The coordinator subsequently reported integration of separately reviewed auditor
53d3 as `dfda468593`; this does not alter the proposed Lean facade change.

Run `20261108T094147-fb5330310904` actually failed at 17:19:12.814259 UTC.
The owning tool exited 1 and its observer exited 0. The retained log records
successful build 856/856, followed by a freshly executed audit of 145,517
declarations using only propext, Classical.choice and Quot.sound. The mandatory
closure comparison then found exactly `Silver.ScalarFunctionFrameFlow` missing.
No successful complete `lean-evidence.json` was produced. The completed build
and logical-assumption audit do not supersede that failed coverage result.

Read-only comparison independently found 820 project modules and 819 actual
`SILVER_MODULE` names, with no unexpected module. A static graph including
ordinary, public, meta and import-all forms agrees exactly with those 819 actual
modules. Both direct dependencies of the missing module were already audited.
The original failed packet is retained under
`docs/evidence/scalar-functions-20261107/complete-lean/20261108T094147-fb5330310904`.
Its summary records 927 matching captured inputs and 911 memory observations;
no new bulk input or memory audit was needed for this diagnosis.

## Role of the missing module

`ScalarFunctionFrameFlow.lean` imports `ScalarFunctionFrame` and
`PredicateLoopFlowValidity`. It defines `parameterBinding` and five elementary
lemmas about an appended Integer formal: refinability, immutability, nonstatic
status, context readiness and flow readiness. The constructor sets mutable and
static flags to false while preserving the supplied declared bounds. The
readiness proofs use the established immutable-suffix lemmas. All original
hypotheses and full declared domains remain in the proposed repair.

No project module imports this file, and none of its six declared names appears
elsewhere in project proof source. Its comment explicitly keeps these
parser-domain lemmas outside execution models. It is therefore an orphan in the
whole-project import inventory, not a missing imported premise in an existing
consumer proof.

The active semantic chain is separate: `ScalarFunctionDefinition` uses
`ScalarFunctionFrame`'s binding/range model, and `ScalarFunctionSemantics` derives
`Definition.frame_fits` through `bindArguments_fits`. Actual parser-domain frame
readiness is established in `FunctionBodyFrameReadiness`; `FunctionBodySource`
uses `parameterFrame_contextReady` and `parameterFrame_flowReady`, and
`FunctionDeclarationBodyDomains` uses the corresponding generic frame results.
Those modules belong to the existing actual audit closure. This bounded check
does not repeat their previously completed semantic/source reviews.

The missing file still must compile and be audited. Its orphan status is not a
reason to delete it, exempt it from the inventory or narrow its statements.
Static inspection does not claim its current proof terms have been accepted.

## Exact proposed change

`proposed-import.patch` changes only `proof/Silver.lean`:

```diff
 -- Independent fragment and recursion lemmas retained in the whole-project audit.
 public import Silver.ComposeExecution
 public import Silver.BranchingDisjoint
+public import Silver.ScalarFunctionFrameFlow
```

The facade already retains independent developments in this section, so this
does not create a false semantic dependency in execution models or introduce
an import cycle. With the virtual new edge, the static `Silver.Audit` closure
contains all 820 current project modules and no extras. `Audit.lean` and
`AxiomAudit.lean` retain their legacy imports and fresh private-declaration
audit; `check_lean.py` continues to require exact whole-project coverage.

Patch SHA256:
`379d93d4fc0dd1adc0d1615496aaa3de9d67583b77fe80b4841d89c4dea2937e`.
Before facade SHA256:
`91804ec555e9382ac5884d5a0a69c1b30502e7287096539d680fae8adc107dad`.
Candidate facade SHA256:
`d71d991818e9bc5178c73546dbf9fc7fef199d7232d550da217dfb58eb663d44`.
Read-only `git apply --check` passed in the isolated review worktree, whose
facade bytes match the integration target. No tracked file was changed here.

## Next smallest checks and evidence applicability

After coordinator review/application and actual release of the regression
reservation, use the existing integration workspace and managed runner:

```sh
python3 scripts/check_lean.py --target Silver.ScalarFunctionFrameFlow --task '#298' --reason 'Check the retained frame-flow lemmas before complete module-closure refresh'
```

Require actual focused success, including this module's complete original lemma
statements and the fresh actual-import/axiom audit. If it fails, retain the exact
error and diagnose before a complete attempt. Do not alter statements merely to
pass. The focused check deliberately does not claim to validate the umbrella's
new import edge.

Then run the ordinary cached complete check on the final combined inputs:

```sh
python3 scripts/check_lean.py --task '#298' --reason 'Complete audit after independent frame-flow import and reviewed auditor integration'
```

Use automatic worker/thread defaults once the actual host is free; do not inherit
the earlier two-worker/two-thread constraint. The coordinator owns resource and
session monitoring. No clean or replay mode is selected. Keep the original
workspace and all cached source objects. The missing leaf, umbrella and audit
may rebuild; unchanged source certificates and semantic dependencies remain
eligible for cache reuse. Require actual completion, exact current module
inventory and fresh axiom audit. Do not predict the new declaration total or
call the old failed run successful.

This `.lean` import change is outside native proof-provenance inputs, which
capture Ada/generated sources, scripts, project files and native configuration,
not general `.lean` files. It changes no native code, build option, helper
contract, compiler binary or application input. The successful native155015
checkpoint needs no rerun for this issue. The separate auditor integration
retains its independently reviewed applicability requirements.

The Lean shared-input digest changes, so complete Lean evidence must be refreshed.
The pending platform wrapper copies all production Lean files and must use the
updated facade. Other source-inventory/import-policy test applicability can be
resolved by the ordinary bounded dependency comparison; there is no test-code
or inventory-ID change in this patch. The successful chunk fixture copies a
fixed helper set and synthesizes its own facade, so this import alone does not
invalidate it. Native application/sample successes are unaffected. Final
regression composition, Rosetta reconciliation and delivery acceptance remain
separate pending work.

## Reviewer scope

Selected configuration: GPT-6 Astra / Max. Independent runtime confirmation,
elapsed-review and token/cost telemetry are unavailable. Host is Linux x86-64;
the pinned Lean toolchain is v4.34.1. Goal last read null; CLI recall was not
updated. This diagnosis owns only scratch and the proposed patch in
`scalar-functions-final-review-298`. No integration edit, build/proof/test,
generator, signal, lease/cache change, GitHub mutation or push occurred.
`analysis.json` retains the exact source hashes, declarations, consumer search,
actual and proposed closure inventories, original failure summary and patch
identities. Final overall acceptance remains held.
