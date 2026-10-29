# Complete native audit workspace reuse

Issue [#286](https://github.com/berkeleynerd/silver/issues/286). Native Linux
x86-64; selected native worker GPT-6 Astra / Extra High. Runtime model
confirmation and token/cost measurements are unavailable.

The first complete run, `20261029T154107-1e953acac4e4`, was interrupted on the
lead's instruction for a performance reason. At its retained checkpoint, 20 unit
reports contained 2,534 proof and 186 flow checks with no unresolved check
entries; 162 current Why3 sessions had all goals proved. The output-profile
feature unit had not started. The original workspace, sessions, cache and
reports remain preserved. Its partial reports and progress do not constitute
complete assurance.

Read-only assessment found that `tmp/constant-array-native` retained the
successful complete run `20261029T084357-2ecc23128d69` (435.871 seconds), with
411 Why3 sessions, 773 GNAT tasks and 76 unit reports. Its complete manifest
still matched every current native input and all 78 recorded report hashes.
The tracked native input comparison found exactly six changed source files.
The fresh-workspace run still had 51 unchanged units, with no source `with`
dependency path to those changed units, corresponding to 10,333 prior proof and
870 flow checks. This supports reusing the established workspace; it does not
predict the time required to prove the modified feature units.

After the first run stopped cleanly, only the six differing native source files
were synchronized from integration `957e403a17`. All 143 tracked native proof
inputs then matched integration. `workspace-reuse.json` records each before and
after hash and preserves the preexisting dirty-file identities. The unrelated
`PredicateLoopCandidate.lean` and the already-matching dirty `silver.adb` were
left untouched, with local backups retained. Full before/after native input maps
and the prior complete provenance record are compressed alongside this record.
No sessions were copied, and no second proof ran concurrently with the first.

The replacement invocation is the normal managed `dev.py prove --full` with four
workers and unchanged strict production proof settings. Complete obligation,
coverage, report and provenance auditing remains mandatory. Existing workspace
reuse is neither a cold run nor a replay-only assurance claim.

The [2026-10-29 20:28 UTC diagnostic](body-tail-diagnostic/README.md) records
one unresolved `Body_Tail` static postcondition found while the replacement
run was still active. Earlier all-proved session progress did not establish
that session's completed result. The [terminal failed packet](failed-full/README.md)
retains all 78 emitted reports, inputs and logs: the run ended at 20:29 UTC with
15,384 of 15,385 proof entries and every one of 1,432 flow entries proved.
The one static equality obligation prevents complete native assurance; no
complete audit or success manifest was produced. Original sessions, caches and
stable source inputs remain intact.
