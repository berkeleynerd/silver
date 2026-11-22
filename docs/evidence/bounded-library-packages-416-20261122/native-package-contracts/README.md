# Package helper contract diagnosis — 2026-11-22

Linux x86-64, selected proof/diagnosis role GPT-6 Astra Max. Actual live model
settings and whole-team token/cost data are not independently exposed.

The original complete Package_Spec_At check `20261122T154517-101a5dc5fa74`
failed at one postcondition and eight preconditions after 2,235.074 seconds.
Eight obligations need retained loop state/cursor facts; the Hide_Name call also
needs a successful Signature result to expose the newly stored name span.
Failed evidence remains failed. No complete native checkpoint is claimed.

The smallest repair adds the exact-effect Append_Package_Formal postcondition
over its unchanged entry domain, Signature state/count/span loop invariants and
successful stored-name span, and Spec state/cursor loop invariants. It changes
no executable branch, accepted source, input domain or obligation policy.
The retained Ada snapshot binds the first repaired input bytes.

Complete Append_Package_Formal passed `20261122T163240-25edb73c029b`: one entity,
9 checks (1 flow, 8 proof), 32.854 seconds, two workers within the shared eight-CPU
host allocation. Command: `python3 scripts/dev.py prove --subprogram
silver_output_profile.adb:8302 --task packages-416-append-formal-contract --jobs 2
--resource-reason "Share the host eight-CPU allocation with concurrent package
source and semantic proof checks"`. The canonical final-policy focus retains
all checks, level 2, cvc5/z3/altergo and the unchanged 30-second timeout.

Signature and Spec remain pending at this retained helper checkpoint. Successful
callee proof does not replace caller, other helper or complete compiler assurance.
Managed records retain exact inputs/tool identities; compressed native logs and
selected reports distinguish failure from successful whole-helper coverage.

## Signature diagnosis and explicit preserved components

Run `20261122T163400-329302598e53` checked the complete Signature helper on
the first repaired input. It failed after 968.467 seconds: 66 obligations total,
14 flow plus 50 proof discharged, with two unproved checks. The successful
stored-name postcondition and all cursor/count/span invariants passed. The two
failures are state-loop preservation (array metadata) and the later result-type
parser precondition (function metadata), both requiring unchanged frame fields.

The second repair retains the exact-effect postcondition and additionally exposes
the unchanged components directly. The first attempt
`20261122T165344-79c744c44108` stopped before obligations because equality for
Array_Bindings.Environment needed a visible operator. Adding its ordinary
`use type` clause resolved that compilation error. Full Append verification then
passed `20261122T165616-d68c94f0ca7f` again with 9 checks (1 flow, 8 proof).
This input is retained separately in `preserved-components-input.adb.gz`; the
Signature retry uses the same bytes. No precondition/domain narrowing, executable
branch change, suppression or alternate solver policy was introduced.

## Repeated Signature boundary and next diagnosis

The second complete Signature check `20261122T165753-f61735da6ae4` failed after
1,091.957 seconds with the same two unresolved obligations: loop preservation at
8432 (reported Array_Bindings.Valid_Environment) and the result-type parser
precondition at 8511 (reported Functions.Valid_Metadata). There were 66 checks:
14 flow and 50 proof checks passed, two proof checks remain unproved. The source
SHA256 was `c1a59b4b655fec3a25f6d27eaa56b3a20572441d41fa6532e054a7cfd81efec5`.
The unchanged `preserved-components-input.adb.gz` binds these bytes. Both calls
retain all checks, canonical final-policy solvers and timeout, and two workers.

Direct unchanged-field equalities therefore do not resolve this caller's
quantified validity obligations. No third identical retry was started. The next
diagnostic inspects the generated checks and whether explicit component validity
cut points can preserve the complete Valid_State requirement while splitting
the monolithic quantified proof. No domain restriction or validity conjunct may
be removed. The failed result is a checkpoint, not successful helper evidence.

`coverage.json` records retained whole-unit successes and current package-helper
status. Append is the only new Output_Profile helper with complete canonical
success so far. Signature and Spec remain unresolved, all other new package
helpers and affected callers need complete coverage, and the later integrated
native/source checkpoint remains required. The existing runner takes one unit
or one subprogram selector; no multi-subprogram batching is claimed.

## Signature complete success after checked validity assertions

Canonical whole-helper run `20261122T172039-c364b0adf1b1` passed **77 checks**
(14 flow and 63 proof) in 1107.200 seconds, with two managed
workers. The source hash is
`9450a06ef818cb329cfe09d3ab22caf4362e0ece6f684a5dc7e79a87ec334b4a`, retained
in `signature-cut-points-input.adb.gz`. All assertions, preconditions, loop
initialization/preservation, variant, output initialization and full postcondition
passed; no selected proof/flow obligation or entity was skipped.

The six checked assertions expose Array_Names/Functions validity after Hide_Outer
and after Append, then positive cursor and the complete Valid_State before the
successful loop exit. The original full Valid_State loop invariant, all input
domains, native branches, solver policy and timeout remain. The successful
complete check supports the earlier diagnosis of solver visibility/quantified
VC difficulty, rather than establishing a counterexample to preserved validity.
The assertions are retained as verified cut points; no identical-success rerun
is needed to remove them. Append and Signature now have complete focused success.
Spec and the other pending helpers/callers still require complete coverage,
and full native/source assurance remains outstanding.

## Independent name and type helper coverage

Six further canonical complete-helper checks passed on that unchanged source,
with two managed workers each and the same solver policy and timeout:

| Helper | Managed run | Checks (flow + proof) | Seconds |
| --- | --- | --- | --- |
| Package_Word | `20261122T174316-72d68ed05168` | 10 (2 + 8) | 31.701 |
| Spark_Pragma_After | `20261122T174440-cefef5afe8c6` | 11 (2 + 9) | 30.286 |
| Package_Name_Allowed | `20261122T174625-977fe4992c25` | 38 (2 + 36) | 34.815 |
| Package_Name_Fresh | `20261122T174750-0f1c9c8ac0bd` | 6 (2 + 4) | 28.293 |
| Package_Type_At | `20261122T174921-80fa287eba55` | 13 (2 + 11) | 53.353 |
| Outer_Declaration | `20261122T175048-543c2ea12434` | 4 (2 + 2) | 27.977 |

Each selected report identifies its one whole helper, with no selected skipped
flow/proof checks or unresolved obligations. All 82 checks passed. This supplies
the independent name/type prerequisites for the remaining declaration helpers;
Hide_Outer, Static Boolean readers, Object, Spec and affected callers remain
pending. `coverage.json` now uses the current source line positions throughout.

`Hide_Outer` subsequently passed all 37 checks (2 flow, 35 proof) in complete
canonical run `20261122T175214-5b46f509c5da`, 83.290 seconds, on unchanged input.
Its three full-array filtering loops, all index/call obligations and complete
Valid_State postcondition passed. Static Boolean and later declaration/caller
coverage remains pending.

## Static Boolean native checks and loop diagnostic

Three complete recursive-helper checks passed on the same source:

| Helper | Managed run | Checks (flow + proof) | Seconds |
| --- | --- | --- | --- |
| Static_Boolean_Primary | `20261122T175440-e22bd3c6f341` | 24 (3 + 21) | 76.008 |
| Static_Boolean_Factor | `20261122T175649-1db5b6f73ba7` | 11 (2 + 9) | 39.777 |
| Static_Boolean_Relation | `20261122T175841-8a64b605158d` | 20 (6 + 14) | 69.233 |

The complete condition helper run `20261122T180017-09a08f285cf5` **failed** after
55.038 seconds. Its report has 5 successful flow checks and 17 successful proof
checks, plus one flow warning: `STABLE`, "loop condition is stable", at line
8119. The canonical `--warnings=error` policy rejects that warning. There are
no skipped proof/flow entries or unresolved proof checks, but this is not a
successful whole-helper gate.

The proposed source repair removes the constant while condition and trailing
return, retaining an unconditional loop with its existing current-operator
No_Chain return and unchanged selected-operator/progress checks. If the initial
Selected is No_Chain, the same pure Chain_Token call returns the initial result
on the first iteration. Otherwise Selected remains nonempty and the old and new
iteration decisions coincide. The model, typed tree and candidate must change
with this source, then the complete native helper must pass again. No warning
or obligation is suppressed.

That repair passed complete canonical run `20261122T180644-1f5eefc02619`:
22 checks (5 flow, 17 proof), 54.366 seconds, no warnings. Source SHA256 is now
`e181c06fc2ac104092b9166eb276338feeca254ad21446fdfc3903cd81a7dc02`, retained
in `unconditional-boolean-loop-input.adb.gz`. The corresponding typed-loop and
candidate audit is recorded in `../static-unconditional-loop`. The other three
Boolean helper bodies/contracts are unchanged and their successful evidence is
retained with its original inputs. Complete Object/Spec/caller coverage and
integrated source/native assurance remain outstanding.

## Package object complete success

`Package_Object_At` passed canonical complete-helper run
`20261122T180815-378d8355adc0`: 28 checks (7 flow, 21 proof),
452.468 seconds, two managed workers. The selected report contains the one
whole helper and no skipped flow/proof checks or unresolved obligations. Source
SHA256 remains `e181c06fc2ac104092b9166eb276338feeca254ad21446fdfc3903cd81a7dc02`,
retained in `unconditional-boolean-loop-input.adb.gz`. Full-domain initializer,
state-extension, metadata-update and postcondition obligations passed.

The dependent Spec check is next, followed by the remaining helpers/callers.
Complete native and authoritative-source assurance remain outstanding.

## Package specification complete success

`Package_Spec_At` passed complete canonical run `20261122T181702-5e3c1450b9d5`:
43 checks (9 flow, 34 proof), 233.679 seconds,
two managed workers. All selected flow/proof obligations and the one complete
helper passed. Source remains the retained `e181c06fc2ac` input. The earlier
nine-obligation failure remains recorded; the repaired state/cursor invariants
and Signature success contract now close the dependent Spec obligations.
Remaining application helpers/callers and final native/source assurance are pending.

## Application wrapper complete checks

Both expression helpers passed complete canonical selectors on the unchanged
`e181c06fc2ac` source. Each selected report has exactly its whole helper,
termination and discriminant obligations, with no expanded caller or skipped
obligation. Two managed workers were used.

| Helper | Run | Checks (flow + proof) | Seconds |
| --- | --- | --- | --- |
| Application_Of | `20261122T182141-e8a459c49fff` | 2 (1 + 1) | 27.406 |
| Invalid_Application | `20261122T182245-200596709485` | 2 (1 + 1) | 27.952 |

## State effects and callee complete checks

Four further complete canonical helpers passed on unchanged `e181c06fc2ac`
source, with two managed workers each. Each report selects its complete helper
with no skipped or unresolved flow/proof obligation. No source or contract
changed during this group. The main Package_Call_At check follows.

| Helper | Run | Checks (flow + proof) | Seconds |
| --- | --- | --- | --- |
| Visible_State | `20261122T182543-3f813ace70a3` | 12 (4 + 8) | 36.649 |
| State_Target | `20261122T182648-adfcc33cbbd5` | 10 (2 + 8) | 36.213 |
| State_Reads | `20261122T182838-66d41187d493` | 10 (2 + 8) | 35.634 |
| Package_Callee | `20261122T183016-b28ca489391a` | 11 (3 + 8) | 36.085 |

## Complete Call failure and first repair

Canonical run `20261122T183136-3e6f28606690` failed after 1,980.083 seconds
on `e181c06fc2ac104092b9166eb276338feeca254ad21446fdfc3903cd81a7dc02`,
with six unresolved obligations: cursor bounds at Skip_At, Actual_After,
Procedure_Target_Actual and State_Target; stored actual span bounds at
Actual_Name_Free; and the stored scalar index into flow values. The overwritten
Call_Writes initializer was also rejected by the warnings-as-errors policy.
The complete failure packet and exact source are retained here.

The repair carries the positive bounded cursor, every stored actual span,
conditional successful target validity and every target scalar bound across
the filling loop. It removes the overwritten initializer and explicitly rejects
a zero writable-target endpoint before the alias calls, preserving all native
entry domains and required obligations. Successful explicit writable actuals
already pass a strict positive-progress guard; this local rejection makes their
use safe without assuming formal-slot permutation coverage. Matching raw and
typed alias-model updates and the canonical whole-helper recheck are pending
at this source-only checkpoint. No complete-helper success is claimed.

The same source includes the approved Routine_Frame guard rejecting
Routine > Info.Routine_Count before its body observes the Item. Its original
precondition/declarations remain; inactive storage is unobserved on early return.
Architecture owns the matching full-domain frame interpretation. Routine_Frame
and its caller contracts still need canonical complete-helper checks.
