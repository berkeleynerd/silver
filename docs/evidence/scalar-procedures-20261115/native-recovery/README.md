# Native array-declaration recovery — 2026-11-15

This is focused recovery work within authorized #370. Complete native and
Lean/source assurance remain required; this packet does not promote procedure
support or close the issue.

## Retained diagnosis

The Nov 13 complete native checkpoint failed only
`silver_output_profile.adb:2340:32:VC_ASSERT`, the logical state equality in
`Array_Declaration_At`. Its retained generated session has one unresolved main
goal, `def'vc.412`; CVC5, Z3 and Alt-Ergo each reached the canonical 30-second
limit with a 1,000 MiB process limit. The backup has the same unresolved goal
and the identical shape file. No memory failure is reported for that obligation.
The original inputs and generated sessions remain in the
[Nov 13 packet](../../scalar-procedures-20261109/final-failures-20261113/README.md).

The earlier complete helper success reused a Z3 proof of this assertion,
reported as 73,959 normalized steps and zero fresh elapsed time. The retained
session inventory includes exactly one step-budget attempt per main prover
among the array helper's otherwise canonical attempts. Thus the earlier
requested 30-second command is not evidence of a fresh 30-second solve of this
obligation. [Assertion history](assertion-history.json) and
[attempt limits](earlier-array-attempt-limits.json) preserve these observations.
The older broader gate remains failed on its other obligations.

The runtime initializer is exactly the model expression after substituting
`Boolean_Array_Values_Model` and `Array_Values_Model` for their runtime helpers;
their complete contracts already supply both raw and logical equality.
[The comparison](initializer-comparison.json) records the normalized hashes.
[The exact generated assertion node](failed-assertion-gnat-node.json) shows
logical `=` against the model call's epsilon/guard term. No semantic defect or
unique reason for the previous timeouts has been established.

## Host recovery and current experiment

The new host is Linux ARM64 with 12 available CPUs and about 15.8 GiB RAM;
the earlier evidence is Linux x86_64. The initial focused run
`20261115T165617-180373f5f92a` stopped in translation with `Too many open files`,
before solver verification. Both Linux open-file limits were 1,048,576 and the
system-wide open-file table was far below its limit. An independent Lean launch
hit the same mounted-filesystem failure. This is retained as an unsuccessful
host attempt, not an assertion result.

The lead provided a dedicated Docker volume at
`/home/agent/silver-workspaces/recovery-volume/native`. The native tools were
copied into the isolated worktree and bootstrap regenerated installation paths.
The mounted packet and tools remain intact. The unchanged focused experiment
checks every line of the complete `Array_Declaration_At` declaration/body and
its direct `Declaration_At` caller, including runtime, contract and flow checks.
It uses all mode, all reports, warnings/checks as errors, level 2, all three
canonical provers and the unchanged 30-second timeout. Two managed workers
reserve headroom for the concurrent isolated Lean check; native RSS and host
available memory are sampled every ten seconds.

## Fresh complete-helper result: failed

Native-volume run `20261115T170136-e1c83ecc05db` exited **1** at 17:14:57 UTC
after 801.067 launcher seconds / 800.829 managed seconds. The complete
`Array_Declaration_At` has 56/57 proved proof records and two successful flow
records. The sole failure is the same assertion and generated goal; all three
canonical attempts again timed out at 30 seconds. Its 10-second counterexample
attempt also timed out. The run therefore remains failed.

The complete direct caller `Declaration_At` independently passed all 11 proof
and two flow records. Both selected entities are in `all` mode. The report has
494 successful flow records overall, no skipped proof/flow and no pragma-assume
entries. All 2,606 prepared input hashes and 12 tool identities matched at the
terminal check. Sampled native process RSS peaked at 2,559,392 KiB, and the
smallest sampled host available memory was 5,669,424 KiB. These are process-RSS
and host-headroom observations, not a hard memory cap.

No source, contract, declared domain, proof obligation or compiler/application
policy changed for this baseline. A diagnostic checkpoint in the managed ledger
records the failed assertion, retained evidence and next hypothesis. The
follow-up experiment binds the same model call once as a `Ghost => Static`
constant before the assertion. Its in-progress source edit and result are
separate from this retained baseline evidence. The existing successful caller
can be retained only while its complete source and the helper's exported
contract remain unchanged. Complete assurance and the actual-source wrapper
proof remain mandatory.

## Retention

| Archive | Scope |
| --- | --- |
| `setup-and-mounted-failure.tar.gz` | Relocation/bootstrap logs; original mounted failure command, actual exit, reports, managed events and all 2,606 matching prepared inputs |
| `fresh-baseline-failure.tar.gz` | Native-volume command, exit, resource samples, reports, both selected generated helpers/sessions, managed diagnostic, terminal verification and all 2,606 matching prepared inputs |

The archives contain source/configuration inputs and tool identities, not copied
tool binaries or a proof cache. `retained-files.json` records archive hashes,
sizes and member counts; all packed file bytes were compared with their retained
source files. The mounted originals remain in the original native worktree.
The native-volume originals remain under `tmp/native-recovery-20261115/` in
the dedicated native worktree. Historical evidence keeps its original platform,
settings and outcome; no completed provenance or complete-assurance manifest is
claimed for either failed run.
