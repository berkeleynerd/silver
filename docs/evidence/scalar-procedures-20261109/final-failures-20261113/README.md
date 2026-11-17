# Final checkpoint failures — 2026-11-13

Both complete checkpoints remain unaccepted. This packet preserves their exact
terminal evidence and the independently successful output certificate. It does
not establish procedure support, complete source correspondence or a final
regression result. Earlier [failed attempts](../final-attempts-20261111/README.md),
[controlled interruptions](../qualified-validity-390-20261113/README.md) and
[focused repair successes](../qualified-validity-repair-20261113/README.md)
retain their original scopes and outcomes.

## Native complete checkpoint: failed

`20261113T121730-28547dbc0d87` actually exited **1** at 17:58:24 UTC after
20,451.885 managed seconds (5 h 40 min 52 s). Its original launcher took
20,454.171 seconds. The native run was never signaled or restarted. It used
canonical full/all/all, level 2, 30-second CVC5/Z3/Alt-Ergo, 14 workers and
normal sessions/cache reuse, initially alongside eight Lean workers.

The sole unresolved obligation is
`silver_output_profile.adb:2340:32:VC_ASSERT`, in `Array_Declaration_At`:
`Same_Parser_State (Result, Array_Declaration_Model (Text, State, Arguments))`.
All three solver attempts timed out at 30 seconds. Its failure record says
time limit, not memory exhaustion. Its session was written at 13:13, before
the later source OOM incident; no unique cause is inferred. Its complete
helper fragment is byte-identical to the retained earlier attempts, including
the Nov 10 report where this assertion was proved. A suggested precondition
change is not authorization to narrow the declared domain.

The 78 unit reports contain 1,232 audited implementation entities,
1,715 flow checks and 17,730 proof records: 17,729 proved/info and one
unproved. Strict complete obligation/source-policy/coverage auditing **fails**.
Strict completed-provenance auditing **fails** because the failed proof emitted
no `proof-provenance.json`. `complete_native_success` is false. The diagnostic
enumeration traversed 1,051,208 existing auditor requirements and found four
consequences of the failure; it is not a passing audit or a policy change.

Named current-report scopes: `Actual_Name_Step` passed 26 proof/5 flow records;
`Procedure_Updates` passed 36/3; `Procedure_Call_Body` passed 17/2.
`Array_Declaration_At` has 56/57 proved proof records and two successful flow
checks. These scoped successes do not establish complete native assurance.

All 2,595 native input copies and 81 report/snapshot files are retained.
Preparation, launch, current inputs and retained copies match; tool/project
identities were revalidated. Parser SHA-256:
`619f4fb8e2b0f318dac7c6278d5f644198816ce7733959ed71ca03917546b2b8`.
The observed primary HEAD was `e1ffc5f7b83ed8789b1ed3689a97584ebc7b2ec8`;
native implementation is the reviewed `c1bbdc8e5f`, followed by proof and records.
The separate 15-file generated-helper archive preserves current generated
inputs, sessions and shapes for the failed array helper and two repaired helpers.

## Source certificate: separately successful

`20261113T122134-87078e539c6a` actually exited **0** for
`Silver.OutputBodyCertificate`. With eight Lake workers/22 Lean threads,
four changed chunks and the aggregate built successfully. Build took
10,511.530 seconds; fresh audit 48.859 seconds; total 10,651.965 seconds.
The audit covered 16 imported modules/51,101 declarations with only `propext`,
`Classical.choice` and `Quot.sound`. This was incremental, with no independent
kernel replay. Exact evidence, generated inputs and artifact hashes are
retained. The original 144 binary artifact files (438,406,605 bytes) remain
in their existing source-worktree retention directory; they are not duplicated
in this committed packet. Their matching terminal verification is retained.
This success does not establish the complete project audit.

## Complete source checkpoint: module failure, then controlled interruption

`20261113T152103-cead6d46c85e` used eight Lake workers/22 Lean threads over
1,104 captured input files, 997 project modules and 40 generated candidates.
It completed 312 new module builds, including `ComposeContractSourceCandidate`
and `ComposeDeclarationSourceCandidate`, before termination. No complete
module/axiom audit ran; completed builds and existing cache hashes are not
fresh complete assurance.

`Silver.FunctionSourceParts.DeclarationLoopFunctionLocals` failed with **Lean
exit 137** after 452 seconds. Sampled source RSS reached 55.66 GiB and host
available memory about 1.5 GiB. Kernel evidence records a global OOM killing
a Lean process at 17:22:30 UTC. The kernel PID cannot be mapped directly to
the disappeared inner source PID; the recorded timing and exhausted headroom
support the incident account without inventing that identity mapping.

Lake continued allocating after the failed module. The source owner notified
the lead, whose agent was completed; queued messages did not restart it. After
the native monitor independently confirmed critical headroom, the source owner
sent SIGINT only to verified source group 139414 at 17:25:17 UTC. No native
process was signaled. Original source exec actually exited **130**; the managed
final state is **interrupted / KeyboardInterrupt**, after the recorded module
failure 137. Build interruption elapsed 7,375.741 seconds; managed duration
7,450.004 seconds. This is a failed complete checkpoint followed by a controlled
stop, not merely an unexplained interruption. All source processes and leases
were released; the native computation continued independently to its own failure.

Captured source HEAD is `623a3ce1d41e48e0f3340d3deb6dc968b550fd94`, integrated
as primary `51371ef82f`. Terminal comparisons found no differences in the
1,104 shared input bytes or two tool identities against primary
`e1ffc5f7b83ed8789b1ed3689a97584ebc7b2ec8`. The packet retains exact inputs,
candidates, resource/kernel/process/stop evidence, failure manifests and logs.
The 5,861 existing compiled-artifact hash entries identify preserved cache
state; their presence does not supply a completed audit.

## Handoff and next work

Root resumed focused diagnosis at 21:10 UTC, about 3 h 12 min after the native
exit and more than three hours after the monitor handoffs. The queued incident
messages had not automatically resumed the completed lead. The earlier merge
estimate was withdrawn. This operational gap is not an application guarantee.
Root assigned Astra Max native proof diagnosis and an isolated source memory
check on unchanged inputs, with a one-worker source run justified by the measured
memory constraint. No blind full rerun, domain/obligation weakening, timeout
increase, new architecture or successor work is selected here.

Complete native assurance and complete Lean/actual-source/facade/module/axiom/
provenance validation remain mandatory after diagnosis and focused success.
No generated-candidate integration or full regression suite followed the failed
checkpoints. The discovered final inventory remains 691 test identities,
not a successful suite. #375 and #390 remain internal to #370; final critical
acceptance, Rosetta reconciliation and delivery/issue closeout remain pending.

## Retention map

`retained-files.json` gives archive SHA-256, sizes, member counts and source
paths; copied archive members were byte-verified after packing.

| File | Contents |
| --- | --- |
| `native-failure.tar.gz` | Exact 2,595 inputs/81 report files; terminal diagnostics, command/events/log; no old cache or prior-report duplicates |
| `native-generated-helpers.tar.gz` | Original 15 generated-input/session/shape files, 28,823,022 uncompressed bytes; inventory/verification in native archive |
| `source-resource-failure.tar.gz` | Exact 1,104 inputs/40 candidates; complete-run logs/events, resource incident, controlled stop, failure/cache manifests |
| `source-aggregate-success.tar.gz` | Aggregate summary/log/provenance/events, 40 generated inputs and binary-artifact hashes; no 438 MB binary copy |

Original native packet:
`/home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-procedures-370/tmp/final-native-qualified-20261113/`.
Original source packet:
`/home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-procedures-source-semantic-370/tmp/final-source-qualified-20261113/`.
These are different worktrees beneath the root checkout's `tmp/` directory.
Only existing stable retained packets were read for this preparation; no proof,
build, test, source/cache mutation or GitHub operation was performed. Root owns
application, review, publication and the next validation decisions. Routine
monitoring/record preparation selected GPT-6.1 Sol / High; proof diagnosis uses
Astra / Max. Actual live model/effort and token/cost telemetry are not independently
exposed. No CLI memory update is claimed.
