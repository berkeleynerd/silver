# Final regression queue checkpoint

This file preserves preparation and running checkpoints as history. The final
completion/queue section below and [outcome record](README.md) supersede the
earlier holds and active-run checkpoint.

Owner-authorized #298 / PR #339 regression orchestration. No merge,
publication or source/proof/tooling modifications are authorized in this
subthread. Worktree: `tmp/scalar-functions-298`, branch
`feat/scalar-functions-298-20261107`, frozen at
`eb72b5217e0d8728033150fee8f79986e7920996`.

The original tracked tree was clean before a verified fast-forward from
`2603f6a800`; pre-existing untracked `tmp/` and all installation/output files
were preserved. Native sources equal `9469d5632b`; output-profile SHA-256 is
`9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f`.
The preflight inventory captures 1,023 source, proof, script, test, sample,
catalogue, project and Rosetta files. It is a preparatory snapshot, not test
or assurance success.

Native Linux x86-64 has the private pinned Lean 4.34.1 installation at
`.tools/linux-x86_64/lean`, compiler commit
`5045d0056413266e57c625dcd7c365b10e377c52`. No toolchain copy or bootstrap was
needed: runtime/configuration inputs are unchanged. Build remains necessary
for the final assertion/report repairs. Installed Lean satisfies all native
Lean test availability guards; actual skips must still be checked in results.

No build or test has started. The last managed summary shows all 22 workers
reserved: focused Lean `20261107T230910-a15a07ea6dd4` has 10 and native full
proof `20261107T231059-a9f0c12c8350` has 12. The lead authorized a two-worker
build as soon as capacity permits. Complete tests are now explicitly held
pending the delivery agent's exact final proof snapshot because the focused
run reported a proof-only `PredicateOuterEquations` failure.

Read-only watcher: tool session `56992`, shell PID/PGID `212382`, Python PID
`212383`. Every 15 seconds it reads managed status, and exits after printing
the focused run's terminal state and current capacity when that run becomes
inactive. It launches no build/test and holds no managed worker reservation.

Next commands, subject to refreshed managed summary and the final proof
snapshot instruction:

```sh
python3 -B scripts/dev.py build --jobs 2 --task '#298 final regression' \
  --reason 'Build final native9469d5632b/profile9ec28d94 in original private installation after assertion/report repairs;2workers alongside other checkpoints'
python3 -B scripts/dev.py test --jobs 2 --task '#298 final regression' \
  --reason 'Complete final regression/sample inventory on the final proof snapshot; pinned native Lean installed, no exclusions or timeout changes;2worker allocation alongside other checkpoints'
```

Retain complete managed logs/events/input inventory and a test census, inspect
failures/skips without exclusions, and report errors to the delivery lead.
Only a final evidence commit under this directory is owned by this subthread.

Selected orchestration settings: GPT-6.1 Sol / High, confirmed by the parent
from spawn settings. Independent runtime model identity, token/cost evidence
and active work time are unavailable. Both subthread and lead reported no
active harness goal. This queue checkpoint is retained at the delivery lead's
request to free the agent slot for bounded proof review; regression work is
still outstanding.

## 2026-11-08 resumed hold

The delivery lead resumed this subthread after bounded proof-repair review.
The original watcher was no longer live; its replacement is read-only tool
session `2594`, Python PID `244467`, with the same terminal-focused-run
notification trigger and no build/test launch.

Before any build started, the delivery lead reported three compiler flow
warnings in `silver_library_reports.adb` from the final native audit and a
pending source cleanup. Both build and complete tests are now held until the
lead supplies the exact integrated native and proof repair snapshot, even if
the focused Lean lease releases first. The original worktree remains at
`eb72b5217e`; the preparatory inventory above retains the old inputs honestly
and must be supplemented for the eventual final snapshot. No build/test
success is claimed.

## 2026-11-08 active run, 04:11 UTC checkpoint

The delivery lead supplied and authorized exact repaired snapshot
`c437a41d30dbdbd174773cab1f5d647dc6e7bbf3`. The original branch fast-forwarded
there with tracked files clean and unrelated `tmp/` preserved. Native sources
equal `560144172c`; only `silver_library_reports.adb` and five reviewed proof
files changed since the preparatory inventory. `delivery-input-inventory.json`
captures all 1,023 final delivery inputs.

Managed two-worker build `20261108T021805-6a448d871b26` passed. The compiler
binary SHA-256 is
`cd6412e50ad7ea77205c5bca82ca38b4eece3b33b9b23c24cb503b15107e1de2`.
Its full events/log are retained in the matching directory here. The complete
suite `20261108T021923-5ef7f9b81de7` is still running on frozen `c437a41d30`,
tool session `9569`, Python managed-run PID `381636`, PGID `381635`. Keep the
agent turn active while productive processes remain; process persistence
across turn completion is not established.

The ordered census contains 637 unique test IDs. At 04:11:32 UTC, 538 methods
had completed: 536 passed, two reported `ERROR`, none skipped. The active
method is `SupportedSampleTests.test_manifest_samples`, proving, compiling,
auditing and running all 72 manifest samples; its current compile was manifest
position 55, `rosetta_common_list_elements.adb`. Native Lean availability guards
were satisfied and native audit, dependency, certificate and module tests ran.

The two errors are:

- `test_lean_modules.LeanModuleTests.test_output_body_chunks_reuse_objects_across_content_and_occurrence_edits`
- `test_platforms.InstallationEnvironmentTests.test_symlinked_tmpdir_preserves_platform_setup_and_routing`

Unittest has not yet emitted its end-of-suite tracebacks. No exception cause,
including timeout or contention, is inferred. No rerun, timeout adjustment,
exclusion, active input edit or test interruption has occurred. Retain the full
failed run honestly and diagnose the exact exceptions before follow-up work.
The first fixture's temporary workspace was already removed by its automatic
cleanup. The second fixture runs the full `PlatformIsolationTests` subprocess
under a symlinked TMPDIR with its existing 180-second boundary; nested worker
boundaries are 60 seconds and the concurrent-worker barrier is 15 seconds.
The external native/Lean tools are mocked in that fixture; actual Python
certificate generators run.

The ledger reservation is two workers, while admitted-program proof commands
retain the existing `-j0`, resolving to a 22-worker pool. The timestamped nested
worker observation records actual children, CPU sample and memory separately;
the reservation is not an OS/subprocess cap. The delivery lead reviewed the
observed host headroom and instructed preservation of productive work without
changing source or proof settings.

Later governed integration proof changes remain outside this frozen worktree.
At `f00205b5f8`, they affect `ComposeBooleanDeclarationLibraries`,
`ComposeSourceBridge`, `PredicateBasicSourceCandidate`, `PredicateLoopCandidate`
and `PredicateSourceRequirements`; a `PredicateEquations` annotation is pending.
None intersects the first failed fixture's seven copied production modules.
The second failed fixture copies all production proof files, so its required
passing rerun must use the final governed proof snapshot. Source, scripts,
tests, samples and toolchains remain unchanged by those later proof repairs.
The delivery lead owns final applicability review and remaining complete Lean
assurance. This subthread owns evidence only and must obtain any source or
proof changes from that lead.

## 2026-11-08 completed full run and queued follow-ups

The full suite finished at 04:44:35 UTC with 637 outcomes: 635 passed, two
`ERROR`, zero skips. Both exact exceptions are `subprocess.TimeoutExpired`:
the initial chunk-reuse fixture build exceeded its existing 60-second boundary,
and the outer symlinked-TMPDIR fixture suite exceeded its existing 180-second
boundary. Full logs/events, exact tracebacks and all outcomes are retained in
`20261108T021923-5ef7f9b81de7/`. Independent comparison found zero drift in all
1,031 prepared inputs before any sync; compiler, adapter, Lean and Lake hashes
were unchanged. The full run remains failed.

The coordinator authorized copying exactly six reviewed proof files from
`2a3badff5c1304291b1d583156d5b1449a327668`, recorded as local validation snapshot
`eb27aef3569ac89846f52f94d845c09540974f32`. All other source/test inputs are
unchanged; `proof-sync-input-inventory.json` retains exact before/after hashes.
An additional candidate-only proof repair is pending in the coordinator's
worktree. Do not alter this recorded sync point until the coordinator provides
the exact final snapshot and authorizes any additional file sync.

No build/test process remains active in this subthread and no rerun has started.
The delivery coordinator requested an evidence-only commit, then temporary turn
completion to free the agent slot. The separate local proof-sync commit is not
part of the evidence-only cherry-pick. Follow-up fixtures remain queued until
the coordinator reports final proof inputs, complete-Lean release and suitable
headroom. Run them serially, with the existing options and deadlines:

```sh
python3 -B scripts/dev.py test --jobs 2 --task '#298 final regression' \
  --reason 'Focused failed-fixture follow-up on final proof snapshot after resource release; retain existing options and timeout' \
  -- -p test_lean_modules.py -k test_output_body_chunks_reuse_objects_across_content_and_occurrence_edits
python3 -B scripts/dev.py test --jobs 2 --task '#298 final regression' \
  --reason 'Focused symlinked-TMPDIR fixture on final governed proof snapshot after resource release; retain existing options and timeout' \
  -- -p test_platforms.py -k test_symlinked_tmpdir_preserves_platform_setup_and_routing
```

Keep the agent turn active during each productive follow-up process. Retain
original failures as failures, report each exact managed result, and return any
uncertain diagnosis or required source/test change to the coordinator. Final
applicability review, passing failed/affected fixture reruns and independent
complete assurance remain outstanding. Live harness goal recheck returned
`null`; this subthread did not update CLI memory.
