# Parser-state logical equality repair

Issue: [#286](https://github.com/berkeleynerd/silver/issues/286).
Native Linux x86-64; selected native implementation worker GPT-6 Astra / Extra
High. Runtime model confirmation, token and cost measurements are unavailable.

The exploratory run `20261029T133938-2410f672293c`, using source implementation
`a0d1a69463`, encountered an unresolved annotation verification condition:
`GP_Check:397:VC_INLINE_CHECK:silver_output_profile.adb:1196:8`, goal `def'vc.5`.
It asserts that `Same_Parser_State` equals logical equality of the complete
`Parser_State` record. Its new fixed Boolean array `Subtype_Visibility` was the
only array field compared directly rather than through an extensional
`Logical_Equal` helper. Alt-Ergo and Z3 timed out; CVC5 returned unknown.

`before.json` identifies and hashes the preserved source, exact generated task,
Why3 attempts, partial log and completed scalar/array reports. The original
session tree and separate solver cache remain in the native worktree. The
managed checkpoint and diagnostic preceded a targeted SIGINT to that run's
verified `dev.py` process; its ledger records `KeyboardInterrupt` at
2026-10-29 15:15:21 UTC. The incomplete output-profile run is not full assurance.
Completed scalar/array reports contained respectively 190/63 proof checks and
38/16 flow checks, with zero unproved. These reports describe their actual old
source inputs and are not final repaired-source evidence.

The repair adds `Same_Parser_Subtype_Visibility`, checking array first/last
bounds and every `Names.Operation_Kind` element, with the same static
`Logical_Equal` annotation used for the existing fixed-array wrappers. The
record wrapper calls this helper. A `use type Names.Operation_Kind` clause makes
the index-bound equality visible. No parser runtime expression or admission
domain is changed. The changed Ada bytes still require fresh source binding,
source-shape review and complete native/provenance assurance.

The first focused run `20261029T151618-5af56bee713b` failed in the frontend because
the enum equality was not directly visible; `first-focused-frontend.log.gz`
retains that failure. The use-type clause repairs it. The next focused run is
`20261029T151702-6fc5f2e5c88c`, covering only lines 1181 through 1205 of
`silver_output_profile.adb`, using a separate exploratory output directory,
two managed workers and the retained separate cache. It retains production
level 2, CVC5/Z3/Alt-Ergo and 30-second timeout settings. A focused result does
not replace the required complete native audit.

The focused repaired run completed successfully at 15:25:32 UTC in 507.443
managed seconds: **289 checks proved**, comprising the two targeted
`Logical_Equal` proof checks and 287 unit flow checks, with no unproved checks.
The detailed `.spark` report also retains **50 warning entries**: five
`array-initialization`, 26 `contracts-recursive` and 19 `numeric-variant`.
The initial evidence summary incorrectly reported no warnings; independent
review found this reporting defect. This correction preserves the original
report and does not classify those entries as discharged by a focused proof.
The complete native audit must apply the existing warning/advisory policy. `after.json` records the exact repaired source hash and retained
complete focused report/log plus the two successful Why3 sessions. The
`Same_Parser_State` annotation at line 1205 is the repaired form of the original
failed line 1196 obligation. No broader proof scope is inferred from this result.
