# Superseded Boolean native unit diagnostic

Issue #291, native Linux, 2026-10-30. Managed exploratory run
`20261030T094353-9ea6896732dc` was interrupted at 13:48:06 UTC after
14,650.469 s while `Read_Chain_Into` was still active. It did not complete the
output-profile unit and is not complete compiler proof evidence.

The frozen source was the initial Boolean implementation at `828dd16e6e`, before
the later xor restriction and the three native equality repairs. All 131
captured source hashes were checked against the still-frozen worktree before
installing the final snapshot. Exact inputs, terminal event and native log are retained here. All 378 available
report/task/session artifacts remain in the local managed ledger under
`runs/20261030T094353-9ea6896732dc/supplemental-diagnostic/reports/`, as well as the
preserved exploratory directory. Their timestamps and hashes are in
`retained-artifacts.json`. The feature packet omits those bulky superseded tasks;
the three relevant failure tasks are already retained in the repair record.
Collecting the directory does not assert that every retained artifact was
freshly completed during this run. No complete unit `.spark` report was available
at interruption.

The completed `Read_Condition_Into` session marks all 480 Why3 goals proved;
`Read_Relation_Into` marks all 711 proved. `Read_Chain_Into` had not written a
completed session when interrupted, so there is no completed result for it.
The three previously observed unproved primitives were the array declaration
`.247`, string reader `.75`, and primary reader `.355`. Their separate final
repairs passed 37, 18, and 79 selected native checks, respectively; see the
[repair record](../native-repair.md). The original failed artifacts remain
retained and are not relabelled as successful.

The diagnostic's managed process group was interrupted deliberately because the
final source, including xor changes, requires complete strict proof anyway.
The old process group exited and its managed lease was released before its
installed worktree was reused. Its exploratory report directory and solver
cache remain intact. This released the roughly 4.3 GiB active Why3 allocation
and avoided waiting indefinitely for a superseded entity while the full
regression suite and complete Lean audit were running.

The separate final strict run is `20261030T135033-a26eefd72a3a`, using
`dev.py prove --full --jobs 2`. It uses the normal compiler report directory,
not this exploratory directory. The 143 tracked source/script/project inputs
match integration snapshot `927cc5e178` exactly; only the output-profile body
and spec required temporary replacement. Original bytes are backed up locally
for restoration after that complete run terminates.

Before starting the final run, the terminal diagnostic's 20,087 solver-cache
files were manually copied to the previously absent normal strict cache selected
by the same installed toolchain lock. `cache-seed.json` records the actual donor
and destination. GNATprove remains responsible for task matching and cache
validity; copied cache entries are not an assurance result. No proof option,
contract, domain or tool installation was changed. Final source and complete
native obligation/provenance audits remain required independently.

Selected native subthread: GPT-6 Astra / Extra High. Live runtime model
confirmation and token/cost measurements are unavailable. The purpose of this
round was to preserve useful diagnostics and release capacity for current-source
validation; its measured duration does not establish a model-quality comparison.
