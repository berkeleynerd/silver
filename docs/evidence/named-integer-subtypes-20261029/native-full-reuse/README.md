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

After the [focused Body_Tail repair](body-tail-repair/README.md) passed, the
lead integrated repaired implementation `6020416906b5fc3d2bd10d012e70937c80f0617c`.
The [repaired preflight](repaired-preflight.json) checked all 143 tracked native
inputs against the previous implementation before synchronizing only
`src/silver_output_profile.adb`. All 143 then matched the repaired implementation;
the complete 2,561-input maps differed only in that file. The unrelated dirty
files and original sessions/cache remained intact. Compressed before/after maps
are retained alongside the preflight.

The final build and all 46 affected regression tests passed before the new full
native run started. Run `20261029T211041-a76eb6753f23` began at 21:10:43 UTC in
the same established workspace with four workers and unchanged strict options.
The earlier failed and interrupted outcomes retain their original status;
the new run must independently complete every obligation and the complete
coverage/provenance audit before native assurance is established.

That [complete repaired run](../native-full/README.md) subsequently passed at
2026-10-30 00:32:43 UTC: 16,825 checks and the complete coverage/provenance
audit, with all 143 tracked inputs matching the repaired implementation.
Its original reports, manifest, inputs and logs are retained separately;
no earlier failed or interrupted outcome is relabelled.
