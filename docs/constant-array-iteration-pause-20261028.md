# Constant-array iteration: VM-upgrade pause, 2026-10-28

Historical pause snapshot: the owner subsequently instructed “Please continue.”
The [capability record](constant-array-iteration.md#resumed-complete-checkpoint-2026-10-28)
records the resumed validation. Preserve this snapshot and backup as recovery history.

The owner requested pausing for the sbx VM upgrade to `.50`, with possible
restart and loss of `tmp`. Feature work is paused; resume only on the owner's
instruction. [PR #266](https://github.com/berkeleynerd/silver/pull/266) remains
draft and open, stacked on `feat/fixed-integer-arrays` at `0a85336c83`.
[#264](https://github.com/berkeleynerd/silver/issues/264) and
[#267](https://github.com/berkeleynerd/silver/issues/267) remain unfinished.
No harness goal exists, and no merge or support promotion occurred.

## Preserved state

Implementation, the final typed bridge, catalogue repair and reviewed regression
coverage are complete. The exact final source/proof/script snapshot is
`1e7f42f0c1` (validation branch); the equivalent integrated bridge is `fd9761af5c`.
All 647 captured Lean source inputs and all 143 tracked native provenance inputs
match the integration branch. Later integration commits contain records only.

| Worktree under the repository's `tmp/` | Branch / saved implementation | Purpose |
| --- | --- | --- |
| `constant-array-iteration` | `feat/constant-array-iteration`; implementation and pause records published in PR #266 | Integration and final publication |
| `constant-array-source` | `validate/constant-array-iteration`, `1e7f42f0c1` | Final proof inputs; completed composition/typed artifacts |
| `constant-array-core` | `feat/constant-array-core`, `12ae7f13bd` | Successful byte certificate and all four source bridges |
| `constant-array-native` | `feat/constant-array-native`, `d155e60ccc` | Final native inputs, completed solver cache and partial reports |
| `constant-array-rosetta` | `docs/constant-array-rosetta`, `c5a23c13f4` | Reviewed metadata prepared for integration after assurance |

The native worktree also retains a local `PredicateLoopCandidate.lean` edit and
scratch material. It is included in the backup; the final candidate is already
integrated and reviewed. Do not accidentally commit unrelated native scratch.

## Validation at the pause

The [evidence packet](evidence/constant-array-iteration-20261028/README.md) retains
original logs, events and reports, with their actual outcomes.

| Run | Result |
| --- | --- |
| `20261028T103900-407484c4629b` | Output-body certificate passed: 10,706.620 s build, 24.945 s fresh audit, 28,400 declarations |
| `20261028T134726-e1a9c7080656` | Output/named/argument/lexical source bridges passed: 685.722 s build, 9.638 s fresh audit, 48,060 declarations |
| `20261028T113210-1ee519cf63b5` | Interrupted at 14:02:44 UTC on owner request. Composition candidate built in 6,034 s; predicate candidate and focused audit unfinished |
| `20261028T131912-7b62c2a618ba` | Interrupted at 14:02:44 UTC on owner request. Final native inputs include #267 and restored parent cache; 75 partial reports retained, complete audit/provenance unfinished |

The two interrupted managed process groups received SIGINT and exited with
status 130. No failed required obligation was diagnosed before interruption;
no full assurance success is claimed. Completed Lake objects and solver-cache
entries remain reusable. The unfinished predicate module itself must restart.
The original native attempt `20261028T104216-2bf8dc56c8ec` also remains interrupted,
for the separately documented missing-cache correction.

Independent regression review covers all 540 IDs: 512 applicable retained passes
and 28 rerun passes. The full suite remains failed on its single timed-out
fixture; the unchanged fixture and all other platform tests passed their rerun.
All 50 samples / 106 executions passed. The prepared Rosetta changes still need
their three metadata tests after integration. Neither interrupted proof run
invalidates these completed test results.

## Recovery location

The local preservation directory is outside both system `/tmp` and repository
`tmp`:

```text
/home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/vm-upgrade-20261028-264/
```

`worktrees/` holds complete copies of the five worktrees, including `.silver`
and `.tools`, ordinary/private/server Lean objects, IR, hashes, Lake traces,
native sessions and solver caches. `scratch/` holds the continuation notes,
retention/transfer helpers and reviewer reports formerly under `/tmp`.
`preservation.json` records copied worktrees and their state. No tool/cache
symlink in these trees depended on another temporary worktree at the pause.
The shared Git object store and managed ledger already live outside `tmp` in the
main repository's `.git`. PR #266 and the separately published prepared Rosetta
branch preserve tracked work remotely; large local caches remain in this local
backup.

If `tmp` survives, use the existing worktrees and retain the backup. If it is
lost, restore the saved worktree directories to their original repository
`tmp/<name>` paths before using them. Their `.git` files and tool/build paths
refer to those original locations. Do not operate directly inside the backup
copies. Check Git/worktree state and managed-run status after restoration.
If the upgrade makes those paths unavailable, recreate worktrees outside `tmp`
from the recorded branches, retain the saved caches and follow the existing
platform/bootstrap relocation instructions; do not assume moved native artifacts
are an already-valid checkpoint.

This preserves temporary-directory loss, not deletion of the repository's
persistent storage. No background validation or automatic resume is scheduled.

## Smallest continuation after resumption

1. Read current PR #263 review feedback, Git status, this handoff and the managed
   run summary. Preserve the final inputs and existing caches.
2. Resume the two unfinished validations through the managed runners. In
   `constant-array-source`, repeat the composition/predicate candidate command
   with one worker/thread and 24,576 MiB; Lake should retain the completed
   composition and dependencies. In `constant-array-native`, run the complete
   native proof/audit with four workers and the saved solver cache. Record the
   owner-requested interruption as the rerun reason.
3. After candidate success and with both Lean workspaces idle, use the preserved
   `silver-264-transfer-certificate.py` helper (review it first) to transfer only
   the matching successful certificate, reviewed shape and four bridge module
   families from core to source. Its candidate-run success guard names the old
   interrupted run: update that guard to the successful continuation run. The
   helper has not been executed. It compares source/tool dependencies and retains
   the full artifact families; it is experiment scratch, not supported tooling.
4. Run the complete project `scripts/check_lean.py` in the final source snapshot,
   using one worker/thread and 24,576 MiB. Retain complete native/Lean evidence
   and exact input applicability; no independent kernel replay is required.
5. Finish the existing Astra / Extra High review of complete assurance. Reuse
   the closed core, producer, typed-bridge and regression reviews. The
   [integration report](reviews/review-constant-array-iteration-integration-20261028.md)
   includes bounded review of the prepared Rosetta mapping and focused results;
   it does not yet close whole assurance or artifact transfer applicability.
6. Only after complete assurance passes, integrate `c5a23c13f4`, run the three
   Rosetta tests, and update final regression applicability. Update README,
   language, roadmap, assurance/trusted-boundary status and capability/session
   records with actual results. Keep mutable/general iteration and broad arrays
   excluded. Finish #264/#267 through the completion commit, publish PR #266 as
   ready, and move the issues to In review. Leave the PR open during parent review.

The owner requested keeping solutions proportionate. This pause adds no new
runner, assurance mode, performance project or approval ceremony. CLI memory is
unavailable and was not updated.
