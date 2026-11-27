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

## Complete Call success

`20261122T191156-df67d2d4c1c4` passed the complete Package_Call_At contract
on source `c37214cd9bc8772c84b2f4cd775d6582748e4499f829bf282bfe81e1264871af`:
**85 checks (13 flow, 72 proof), one selected helper**, canonical final-policy,
917.314 seconds, two managed workers. Every runtime, flow, precondition,
postcondition, invariant initialization/preservation and termination check passed.
The overwritten-initializer warning is resolved by verified assignment before
read. No obligation was suppressed or skipped; the original entry domain remains.

The six formerly failed checks now pass. The original failure remains retained
as failure. The matching raw writable-target guard/effect model passed the
separate focused run recorded in `../call-target-guard-model/`; complete typed
actual/source interpretation and the other helper/caller checks remain pending.

## Complete Routine_Frame boundary

`20261122T192845-3ee5a4e23fe9` failed after 355.515 seconds on the same
`c37214cd9` source. Exactly two obligations remain: Hide_Outer requires the
parser state's retained validity at line 9188, and Append_Package_Formal requires
the validated Body_Name at line 9196. Termination and the complete result
postcondition passed. The failure log, reports and exact input remain retained.

The next repair carries Valid_State at the Boolean-forget loop boundary and
Valid_State plus every already-validated body-name span at the hide-loop boundary.
This changes annotations only. The subsequent append loop reads the unchanged
Info table; no metadata-validity or reachable-state precondition is added. The
first repaired complete-helper check remains pending. Primary source is frozen
for its productive authoritative source run; independent same-byte caller checks
can proceed while the private annotation patch is prepared.

## Complete Application_Basic contract

Linux x86-64 run `20261122T193745-91cca7ff3c43` passed the complete
`Application_Basic` selector on `c37214cd9bc8772c84b2f4cd775d6582748e4499f829bf282bfe81e1264871af`.
The retained final-policy report covers one subprogram, three flow checks and
44 proof checks. Both skip lists are empty. The runner used two workers for
323.551 seconds. The subsequent Routine_Frame annotation repair begins after
this helper, and the prepared event preserves the proof input hash.

## Repaired Routine_Frame contract

Linux x86-64 run `20261127T120823-f71ab3de8038` passed the complete
`Routine_Frame` selector at line 9161 on
`2e055cecc2d9eb6000490f4aa4d3d589d0cc9bbd91b55d0c65619599cfc56004`.
The final-policy report covers one subprogram, four flow checks and 18 proof
checks in 117.869 seconds with two workers. Both skip lists are empty. The
Hide_Outer and Append_Package_Formal preconditions, the state and name loop
invariants, and the result postcondition all discharged. The earlier failure
on `c37214cd9` remains in its original evidence packet.

## Complete Application_Tail contract

Linux x86-64 run `20261127T121117-3d399c0e30f1` passed the complete
`Application_Tail` selector at line 8958 on the same `2e055cec` source.
The final-policy report selected one helper, with three flow checks and 22
proof checks in 75.838 seconds on two workers. Both skip lists are empty.
The loop invariants, recursive variant, dependent statement call and result
contract each discharged.

## Completion and package body caller prerequisites

On November 27 the `Package_Object_At` postcondition was extended to export
both initializer endpoints' upper bounds, including failure results.
`Package_Completion_At` now exports successful cursor and completion-count
progress. Its local declaration and output initializer loops retain a positive
valid frame. The package body loops retain a positive valid global frame.
Before forming the tail context, Completion tests `Valid_State (Text, Frame)`
after appending the output formals. The preceding append operation accepts
arbitrary formal bounds. The guard checks this concrete state before passing
it to the tail reader. For matched formals, Signature has compared each bound
to a successful `Package_Type_At` result with nonempty bounds.

The updated source hash is `d3103d20a1a57388d68f4ffdf8d0a091face76de7ad586a29631f1250a91d6b2`.
Object's prior complete result refers to its original postcondition. The next
canonical selector covers the strengthened Object contract, followed by
Completion's use of its initializer endpoints and Body's use of Completion
progress. Complete source correspondence for the guard and the earlier
partial-state behavior belongs to the matching typed body.

## Application_Statement inner flow

Linux x86-64 run [20261127T121829-562685cbce5e](20261127T121829-562685cbce5e/outcome.json)
selected the complete `Application_Statement` on source `2e055cec`. It proved
all 11 flow checks and 124 of 125 proof checks in 2,082.160 seconds with two
workers. All three provers timed out on the recursive `Application_Tail`
precondition at line 9134, column 23. The counterexample prover also timed
out. The retained Why3 session has one open subgoal, `def'vc.628`. Its shape
contains `Valid_Flow` on the extended inner scan. Both skip lists are empty.

The prepared repair uses the same Static assertions as the inherited
`Loop_Body` to expose the widened outer flow, the copied values and binding
prefix, the declaration count and the fresh immutable index's inclusion in
its bounds. The final assertion checks `Valid_Flow (Inner, Inside.Scan.Facts)`
before the recursive call. The repaired source is
`91933dc67619610c7ad5fc026c03663cb84269608e2c37e1710f524ac4392bfa`.
The next complete `Application_Statement` check selects line 8944.

## Strengthened Package_Object_At contract

Linux x86-64 run [20261127T125548-44ef65f45db0](20261127T125548-44ef65f45db0/outcome.json)
proved all 30 checks at line 8221, including both initializer endpoint bounds
in the strengthened postcondition. The whole-helper report covers seven flow
checks and 23 proof checks on source `d3103d20`, with empty skip lists.
It took 398.983 seconds on two workers.

## Repaired Statement precondition and whole-unit legality

Complete native run [20261127T130601-2687d262ec8e](20261127T130601-2687d262ec8e/outcome.json)
on Linux x86-64 used two workers and source `91933dc6`. It passed 11 flow
and 139 proof checks. A single proof check timed out at 9149:23 in
`Application_Tail`'s precondition after 2,067.697 seconds total. The
counted-loop assertions, including the complete `Valid_Flow` immediately
before the call, all passed. The UTC run ledger has the diagnosis, and the
packet retains the proof report, Why3 session and shapes. Why3 recorded CVC5,
Z3 and Alt-Ergo timeouts on `def'vc.671` and a counterexample timeout. The
goal shape contains the position/target/flow body guard and context validity
on the actual recursive-call arguments.

A [source-isolated GNATprove experiment](20261127T130601-2687d262ec8e/region-flow.log.gz),
`20261127T135056-554813d76be1`, added four assertions beside that call and
selected only their lines through the call. Its process exited zero. The
[SPARK report](20261127T130601-2687d262ec8e/region-flow.spark.gz) contains
zero proof rows and stops at `STOP_REASON_ERROR_FLOW`. Its 298 SPARK entities
produced 682 informational flow results and exactly two flow errors. Both
were variable inputs to subtype constraints, in `Package_Completion_At` on
`Input.Count` and in `Imported_Package` on the mutable candidate name span.
Their primary-source positions are 9316:42 and 9656:60. The probe's four
added lines precede both diagnostics. The earlier focused successes remain
scoped to their selected helpers. Both affected helpers and their direct
package Body/Main callers are pending in the coverage inventory.

## Statement recursive call after the constraint repairs

On Linux x86-64, the [isolated region check](20261127T135353-ae9ac5772cde/)
proved all ten obligations selected at lines 9149 through 9153 on source
`95c0f3b33e522adb0bec348520b196a51d8d700ef5bae754056f247fa83c9b09`.
The revised Completion scan count and Imported_Package result length use
constants in their subtype constraints. SPARK completed the unit flow phase
with 697 informational rows, `STOP_REASON_NONE` and empty skip lists.

Four Static assertions expose the inner context validity, position bound,
target bound and complete body validity, in that order. The selected proof
rows cover all four assertions, their checks and the recursive call's
precondition, variant and discriminant. The managed experiment took 830.888
seconds on two workers. The canonical complete `Application_Statement` gate
on this source selects its declaration at line 8944.

The [complete helper run](20261127T141021-61ebae4a0685/outcome.json)
proved all 11 flow checks and 147 proof checks on this same source and
selector under the final policy. It took 1,813.670 seconds on two workers.
The [SPARK report](20261127T141021-61ebae4a0685/silver_output_profile.spark.gz)
records `STOP_REASON_NONE` and empty skip lists. Its scope includes the
recursive tail precondition that timed out in both earlier whole-helper runs.

## Package completion

The [canonical complete `Package_Completion_At` run](20261127T144204-d3e112615a84/outcome.json)
proved 15 flow checks and 44 proof checks at selector 9229 on the same
`95c0f3b3` Ada source. It covered the new progress postcondition and its
call to `Application_Tail`. All report severities were informational.
GNATprove recorded `STOP_REASON_NONE` and empty skip lists. The run took
1,093.308 seconds on two Linux x86-64 workers.
[SPARK report](20261127T144204-d3e112615a84/silver_output_profile.spark.gz)

Its caller, `Package_Body_At`, passed its [complete check](20261127T150147-298ed1b9d8ea/outcome.json)
at selector 9358. The final-policy run proved seven flow checks and 29 proof
checks in 184.576 seconds on the same source and two Linux x86-64 workers.
The [SPARK report](20261127T150147-298ed1b9d8ea/silver_output_profile.spark.gz)
has empty skip lists and `STOP_REASON_NONE`.

The same Ada inputs passed the canonical complete checks of `Imported_Frame`
(two flow and seven proof checks) and `Same_Package_Spelling` (two flow and four
proof checks). Both SPARK reports have empty skip lists and `STOP_REASON_NONE`.
[Imported frame](20261127T150627-336b243e0551/outcome.json) ·
[Package spelling](20261127T150951-fcf99a0aab8e/outcome.json)
