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
