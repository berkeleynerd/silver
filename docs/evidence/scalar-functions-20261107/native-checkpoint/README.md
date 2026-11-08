# Complete native checkpoint — failed warnings-as-errors run retained

Final native source is authoritative integration commit `9469d5632b`, native
identical to `bc800d4e82`. This isolated validation worktree imported only
`src/silver_output_profile.adb` in sync-only commit `3b3e5e3990`; do not cherry-pick
that source-sync commit into the implementation branch. All 276 selected native
source/script/test/sample/project files match the final reference byte for byte.
The output-profile SHA-256 is
`9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f`.
`final-native-inputs.json` records the complete selected inventory. Lean sources
are outside this native inventory; independent proof integration can continue.

The complete native build/full proof reserved 12 workers, leaving ten
for the lead's Lean work. Native options/timeouts were unchanged; successful
full proof requires the existing complete obligation, coverage and provenance audit.
Final native build `20261107T231009-eb3a58439773` passed in 26.437 s with
12 workers. Complete native proof/audit `20261107T231059-a9f0c12c8350` finished
with **failure**, exit code 1, at `2026-11-08T01:37:06Z`, after 8,765.212 s on
the same frozen inputs. Its recorded command and input hashes are authoritative.
No full tests were launched in this leased workspace. Actual host was Linux
x86_64; this is separate from retained macOS or independent Lean evidence.

## Final native result and exact limits

`final-report-inventory.json` records all 66 final SPARK units. Each reports
`PROGRESS_PROOF` and `STOP_REASON_NONE`, with no skipped proof/flow or pragma
Assume statements. There are 11,575 proof records and 983 flow records with
severity `info`; `gnatprove.out` totals 12,558 checks and no unproved checks.
`final-session-inventory.json` separately records all 585 saved Why3 root goals
as proved. These are native proof results, not an independent universal
assurance claim or successful complete audit.

The native tool exited unsuccessfully because `--warnings=error` rejected three
flow diagnostics in `silver_library_reports.adb`: the ineffective initializer
of Entity_Name's Result at line 1210, and unused Source formals of
Expected_Entity/Expected_Coverage at lines 1826/1859. The exact records are in
the inventory and final SPARK report; the initializer trace is retained.
No `might fail` diagnostic occurred. The mandatory proof-provenance certificate
was **not generated**, so obligation/coverage/provenance audit completion is
not established. The application-only advisory exception is inapplicable to
these compiler diagnostics; no warnings or required checks were suppressed.

`runs/20261107T231059-a9f0c12c8350/index.json` identifies 1,382 retained gzip
artifacts by uncompressed SHA-256: final managed log/events, all SPARK reports,
SARIF and text summary, proof inputs and solver config, every saved session and
shape, native/generated source bodies/specs, and project files. All copies were
stable while read, after managed completion. These artifacts retain successful
solver work for the required corrected-source continuation; they do not turn
the failed managed outcome into success.

The coordinator reviewed a scratch-only minimal cleanup removing the redundant
initializer and unused Source formals/actuals in five private policy helpers.
After this checkpoint is committed, the coordinator authorized applying those
exact bytes in the native worktree, a focused flow check, rebuild, and another
complete native proof/audit using retained sessions. That later source and run
must receive their own evidence. The frozen output-profile bytes stay unchanged.

## Superseded old-source exploration

`original-181811-before-stop/` retains read-only active-run diagnostic inputs
for `20261107T181811-5b7564ac5afc`, original source `2603f6a800`, before a planned
superseding interrupt. It contains every frozen source file, source projects,
managed events/log, all 146 currently readable entity sessions and shapes, exact
generated tasks for the five unresolved roots, existing report files, process
group and generated-task inventories. The gzip SHA-256 records apply to the
uncompressed contents. Each copied file was stable while read; the collection
is a non-atomic active-run snapshot.

At capture `2026-11-07T23:07:57Z`, 141 of 146 root goals were proved through
valid proof/complete transformation children. Array_Declaration_At,
Boolean_Array_Values_At, Same_Parser_State, Read_Primary_Into and
Read_Relation_Into remained unresolved; there were no additional unresolved
readable roots. A readable session is not the complete planned run inventory:
192 generated task files were present, and queued/active tasks had unfinished
work. The original run has no successful managed outcome. Later focused repairs
and the final complete proof must establish their own scopes on repaired inputs.

The recorded process group is PGID 70173, shell leader 70173, managed PID 70174,
with expected frozen-worktree Alire/GNATprove/Why3 descendants. The lead verified and interrupted the process group at 23:09:09 UTC; a residual
Read_Chain_Into child was terminated separately. The group and lease were then
clear. This orchestration thread did not signal the old processes. Original
output directories remain intact. `original-181811-after-stop/` retains the actual
interrupted managed outcome and final log/events (17,457.922 s duration). Do not reinterpret the
interrupted old-source run as a success or delete its completed objects.

Selected orchestration setting: GPT-6.1 Sol / High. Runtime model/effort and
whole-round elapsed/token/cost telemetry are unavailable; actual tool workers,
commands, inputs and timing belong to the managed records.
