# Complete native run: one unresolved Body_Tail postcondition

Issue #291, native Linux x86_64, 2026-10-30–31. Complete strict run
`20261030T214853-f14ff090b11a` failed at 2026-10-31 02:03:39 UTC after
15,283.832 s (4 h 14 m 43.832 s). It analyzed 76 units and reported 17,225
checks: 1,468 flow, 15,756 proved and one unproved. The subsequent complete
report and provenance audits did not run. This is not a successful assurance
checkpoint, and neither source restoration nor the regression handoff occurred.

The frozen source is native commit `598a56b969cc0f5b68de7f674ac8bd9c48b602fd`,
with output-profile body SHA-256
`88b54a1df3e6cb1b59c482d36cd29a9f15c2506c69227fbef78c9ab93ab67ddb`.
All 143 tracked native inputs also match the lead's integration checkpoint
`87dd912436e35569f12cf95be639e4a534dea978`. The matching compiler build passed
before this run; its retained command, input checks and binary identities are in
[full-native-build](../full-native-build/README.md).

Both repaired readers discharged in the complete run: 53 proof checks for
`Read_Boolean_Relation_Into` and 200 for `Read_Chain_Into`. The sole failed check
is `silver_output_profile.adb:4003:20:VC_POSTCONDITION`, the exact Static equality
`Body_Tail'Result = Body_Tail_Model (Text, Context, Scan, Stop)`.
`Body_Tail` discharged 61 of its 62 proof checks. CVC5 and Alt-Ergo timed out at
the unchanged 30-second limit; Z3 reached its original 1000 MiB limit after
15.775 s. The counterexample attempt timed out at 10 seconds; no counterexample
was reported. The failed primitive session goal is `def'vc.360`, with introduced
counterexample child `def'vc.360.0`. This is a merged postcondition for all three
returns, so the failure alone does not identify a particular return branch.

The Body_Tail model, specification and body are byte-identical to the earlier
reviewed baseline `b6aeb9f978597ac025de21a8574c76c42389cf82`; the region digest
and precise failed check are retained separately. The failure is therefore not
evidence that those source statements changed. Independent diagnosis is examining
the actual equality task and the existing return-path proof anchors before a
focused discriminator or source repair. Exact contracts, helper domains,
executable behavior and production proof limits remain requirements.

All 2,561 captured input hashes still match at terminal retention. The exact 143
tracked native inputs, complete unit reports, summary, SARIF, preflight input
manifest, original journal/log, failed session, previous session and shapes are
retained here. No complete provenance manifest was created. The full available native artifact inventory is
retained locally: 2,827 files, with 806 changed/new files (577,299,756 bytes)
newly copied and byte-verified; 2,021 identical files reference existing verified
snapshots. `retained-sha256.json` records the full index and compressed failed
task path and hashes. Large native artifacts are not duplicated into Git.
The two original source backups and the seven unrelated dirty-file hashes/modes
were verified unchanged. The installed validation source remains frozen.

The effective production command and tools are identical to failed run 194142;
only the output-profile source input changed. The normal managed proof cache
remained populated and unchanged in configuration. This was a forced complete
run with current reports, not a cold-cache measurement.

During overlap, available memory fell to about 6.5 GiB on the 32 GiB host. At
00:29:35 UTC the separate Lean process group was temporarily suspended after
verifying its process identities. Its source, processes, session and worker lease
were preserved; the native run and all proof settings continued unchanged.
A detached guard resumed the same Lean process group at 02:03:40 UTC after the
native terminal event, a scheduling suspension of 5,644.958 s. Resumption was
verified. `memory-coordination.json` and the retained guard/log record the actual
times and identities. This is neither a Lean terminal result nor a harness-goal
pause; complete Lean/source assurance remains a separate pending obligation.

Selected native worker: GPT-6 Astra / Extra High; runtime model confirmation and
token/cost measurements are unavailable. The duration above is managed native
execution, not total team elapsed time or a controlled performance comparison.
The round discharged both earlier repaired-reader obligations and isolated the
remaining complete-run failure to the exact Body_Tail postcondition.
