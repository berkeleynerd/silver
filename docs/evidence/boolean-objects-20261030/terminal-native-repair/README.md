# Focused native equality repair attempts

Issue #291, native Linux, 2026-10-30. These focused attempts do not replace the
complete native proof and source-correspondence checkpoint.

## Expected-only branch cuts: failed

Run `20261030T200101-c56457a2df8d` terminated at 20:18:10 UTC with failure,
return code 1, after 1025.978 s. Exact candidate body SHA-256 is
`c4d4dad3f868910bf1ee86168ee099406ed0c50b74cf39e26135eb662a4a7b79`.
It added a ghost `Expected` value and four checked `Same_Condition` branch
exits to `Read_Boolean_Relation_Into`; its eager-chain helper change was not
selected by this run. The original contracts, domains and executable statement
sequence remain unchanged. This static assessment is not a native proof pass.

All four new assertions failed: lines 3099, 3104, 3109 and 3119, each column 35
except the final column 32. CVC5 and Alt-Ergo reached 30 seconds on every check;
Z3 reached its original 1000 MiB limit on 3099 and 3109, and timed out on the
other two. The subsequent counterexample attempts timed out at their original
10-second limit; no counterexample was recorded. The exact postcondition is
proved only downstream of the unmet assertions, so the candidate remains failed.
The planned chain check did not start.

The retained session goals are `def'vc.57`, `.64`, `.68` and `.101`. Inspection
of the first introduced task shows a logical-record-identity target, while the
preceding `Invalidate_Condition` and factor-reader contracts supply Ada Boolean
record equality. The existing checked `Lemma_Condition_Equality` bridges those
relations. The next bounded diagnosis is whether explicit use of that helper,
with factor-model snapshots and branch facts where needed, establishes these
cuts under unchanged production settings. No new candidate is yet validated.

The `relation/` packet retains the exact source, all focused reports, journal,
log, session and shapes. Its verification record confirms all 2,561 terminal
input hashes; the large original generated task remains locally retained with
its path and hash. The initial launcher was refused before creating a managed
run because the explicit host selector was omitted; adding that selector was
the only launcher correction. The rejection log remains in root `tmp/`.

Selected native worker: GPT-6 Astra / Extra High. Runtime model confirmation and
token/cost measurements are unavailable. The measured duration above is managed
native execution; the unresolved equality transport is being independently
reviewed before another expensive focused attempt.

## First-branch equality transports: passed

Run `20261030T202646-fa34b49690a8` passed in 787.882 s on candidate
`32b2915b2b66bc6e506549c2fb021c9e81814d413b76b4ff9f96b87918efb2c8`.
Its selected region, lines 3093–3105, covers the Expected/model equality helper,
first factor/model helper, checked invalid-branch model fact, invalidator-result
helper and final first-branch equality assertion. GNATprove reports 336 checks:
323 unit flow checks and 13 selected proof checks, all proved. All 2,561 terminal
input hashes match the captured inputs. Original solver settings were retained.

This establishes the selected first branch and its new helper preconditions;
it does not establish the unselected reader branches. The `relation-transport-first/`
packet retains the original reports, session, source and input verification.
Region selection still processes unrelated generated unit tasks; the installed
tool makes subprogram and region selectors mutually exclusive. The run was
preserved rather than restarted. Subsequent whole-reader validation uses the
subprogram selector. Checked transports have now been extended across the
remaining branches for the next complete reader check.

## Complete Boolean relation reader: passed

Run `20261030T204257-8cba82ab7a71` passed all 56 checks (3 flow and 53 proof)
in 570.866 s. It selected the complete `Read_Boolean_Relation_Into` subprogram,
including its original exact Static postcondition and every added helper
precondition/assertion. Candidate source SHA-256 is
`88b54a1df3e6cb1b59c482d36cd29a9f15c2506c69227fbef78c9ab93ab67ddb`;
all 2,561 terminal input hashes match. The `relation-full/` packet retains the
source, reports, session and verification record.

The final relation change explicitly transports the constrained Expected,
Right_Model and Branch_Result values through the already verified equality
helper. Factor-reader and invalidator results receive the same checked
conversion from Ada record equality to logical identity. Each model branch is
established before changing the corresponding runtime result. No contract,
helper domain, runtime statement sequence or proof limit changed. Independent
static review of these exact bytes found no issue. The complete chain result
follows below.

## Complete chain reader: passed

Run `20261030T205242-3d1308b90ec1` passed all 204 checks (4 flow and 200 proof)
in 3020.054 s on the same `88b54a1d` candidate. It selected the complete
`Read_Chain_Into`, including the original exact postcondition, every existing
assertion, and the changed equality-helper call. Its eager branch now supplies
the already established `Right_Model` ghost value, preserving the helper's exact
Ada-equality precondition and logical-equality postcondition. All 2,561 terminal
input hashes match; the `chain/` packet retains the exact source, reports,
session and verification record. Large generated tasks remain in the local
managed ledger with explicit hashes and paths, rather than duplicated in Git.

Both complete focused readers now pass under the original level-2,
30-second, CVC5/Z3/Alt-Ergo settings, with four reserved workers. Independent
Astra/Extra High static review of the exact source found no issue. The successful
round used the same selected native worker, GPT-6 Astra / Extra High; runtime
model confirmation and token/cost measurements remain unavailable. Durations
above measure individual managed native runs, not total team elapsed time or
controlled cache-performance comparisons.

The source repair is ready for integration and source-pin/certificate refresh.
A matching compiler build, complete strict native audit, complete Lean source
correspondence and the reviewed regression scope remain required. The installed
native worktree retains this frozen validation source until the complete native
result is retained and its two original temporary replacements are restored.
