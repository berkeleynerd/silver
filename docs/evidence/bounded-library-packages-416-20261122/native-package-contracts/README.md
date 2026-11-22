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
