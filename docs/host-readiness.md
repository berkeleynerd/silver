# Replacement-host readiness

Restoration began on 2026-10-09 at source/documentation baseline
`69d294c35297d6facc7473c3275721a2675129bc`; native validation completed on
2026-10-10. This task restores the development environment and records its
actual validation scope. It starts no language
expansion or further certificate-performance investigation. The implementation
and external-review target remains `96b4e3a22194a1ae96d446938d5e94d702b014b4`;
the performance decision remains `5668806`. The live harness returned no goal
in this new session; the completed old goal has not been recreated.

## Host and installation

The actual sandbox is Ubuntu 26.04 LTS, Linux x86-64, hostname `codex-silver`,
kernel `7.0.14`, with 12 visible CPUs, approximately 31 GiB usable RAM and no
swap. Its process cgroup reports no additional memory or CPU quota. These are
sandbox observations, not independent verification of the owner's physical
96-GB host. Python is 3.14.4.

| Filesystem | Observed capacity and free space before tool installation |
| --- | --- |
| Mounted checkout (`virtiofs`) | 937 GiB total, approximately 604 GiB free |
| Sandbox root (`overlay`) | 20 GiB total, approximately 18 GiB free |
| Docker storage (`/var/lib/docker`, ext4) | 63 GiB total, approximately 60 GiB free |

Docker storage is consistent with the recommended 64-GiB allocation; it is
separate from the mounted workspace and root filesystem. The RAM allocation is
consistent with the recommended 32 GiB. No storage or resource settings changed.
The final October 10 audit reconfirmed 12 CPUs and 31.42 GiB RAM, with 562.12 GiB
free in the workspace, 17.27 GiB on root and 59.23 GiB in Docker storage.

`python3 scripts/dev.py paths` selects `linux-x86_64` and the installation root
`/home/canto/src/github.com/berkeleynerd/silver`. There was no native installation
or cache to reuse. Installed the missing Ubuntu `libc6-dev` package, then ran
`python3 scripts/bootstrap.py` and `python3 scripts/bootstrap_lean.py` successfully.
Their pinned archive checks and native version checks passed:

- Alire 2.1.1; indexed GNAT and GNATprove 16.1.0; GPRbuild package 26.0.1
  (the executable reports 26.0.0, within the supported family).
- Lean 4.34.1, native x86-64 release.

Generated installation bindings, tools, downloads and subsequent caches stay in
`.tools/linux-x86_64/` and `.silver/linux-x86_64/`. Preserve them for subsequent
work. Installation logs and the initial host inventory are retained under
`.silver/linux-x86_64/host-readiness-2026-10-09/`.

## New native validation

Native build passed in 2.572 seconds. The complete suite passed all **139 tests**
in 447.621 seconds (447.975 seconds for the wrapper), including every manifest
sample, native boundary and output/failure checks, report/provenance mutations,
platform routing and real Lean cache/resource regressions. No tests were skipped.

The full SPARK audit passed in 1129.448 seconds with four workers: 16 units,
203 entities, 383 flow checks and 2233 proof checks (2616 total), with complete
coverage and provenance. Its manifest is
`.silver/linux-x86_64/compiler/obj/gnatprove/proof-provenance.json`. The recorded
initial state has no sessions or solver-cache entries. This used `--full` in
the ordinary native workspace, not the separately allocated `--cold` mode.
No retry was needed, and this fresh-state success does not establish a repair
of the historical reused-state failure.

An independent read-only check revalidated all 2389 captured inputs, 18 reports
and 12 tool identities, and reran the existing coverage/source audit. Its record
is `independent-evidence-check.json` in the readiness directory. The completed
compiler manifest SHA256 is
`6d863e33593d7aa64c51e908b8559108293ca0be1cd24313e7a851a8a2c34b72`.
The readiness directory also preserves 25 files under `compiler-final-record/`:
all 18 reports, both provenance/input manifests and five generated/native inputs.
Every copy matched its original hash; the originals and caches remain intact.

The first full Lean invocation was interrupted by a sandbox/container restart,
observed at 21:21 UTC and recorded in `validation.json` at 21:23:04 UTC.
No proof process survived and no successful Lean evidence
was produced. Its logs and memory samples are preserved under
`lean-full-interrupted-2026-10-09/`; 57 completed native module objects survived.
The resumed invocation was also interrupted by an owner-reported host restart.
Its last retained memory sample was at 4160.307 seconds, before the output-body
certificate completed. No proof process survived; the same 57 completed native
objects remained. This attempt's logs and phase record are preserved under
`lean-full-resumed-interrupted-20261009T224134Z/`. A second resumption,
`lean-full-resumed-2`, uses those objects without discarding the cache. All 68
native project modules built successfully (79 Lake jobs), including the
output-body certificate in 5403 seconds. The fresh axiom audit passed for 19993
project declarations, using only `propext`, `Classical.choice` and `Quot.sound`.
The independent `leanchecker --fresh Silver.Audit` recheck passed. The final
invocation completed at 00:33:02 UTC on October 10 in 6653.018 seconds
(6653.145 seconds for the wrapper). This is full validation with reuse of
completed native modules after interruption, not a clean rebuild.

All native validation phases passed. `validation.json` in the readiness evidence
directory records phase commands, times and exit status; each phase has its own
log and host-memory samples. The proof commands are
`dev.py prove --full --jobs 4`, then
`check_lean.py --full --threads 1 --memory-mb 6144`. Heavy proof phases execute
separately. No foreign-host cache was used for native validation, and no
existing cache was discarded.

The Lean allowance applies per build/audit process, not to aggregate RSS or the
separate `leanchecker`. This successful run establishes its actual x86-64
input/tool scope; it does not recreate historical review or failure evidence.
See [the assurance argument](assurance.md) and
[trusted boundary](trusted-boundary.md) for exact proof claims and premises.

The final read-only corroboration passed in `final-native-evidence-check.json`.
It revalidated compiler coverage/provenance and all Lean identities: 93
source/script inputs, 70 workspace inputs, 136 compiled artifacts and three
tools. All ten regenerated source certificates match their checked-in
candidates. All 133 tracked implementation, proof, script, test, sample,
catalogue, workflow, Oracle and language files in the checked scope match both
implementation/review target `96b4e3a` and initial checkout `69d294c`.

The native Lean manifest SHA256 is
`02ed2c8db726cb1752cbd4e069de1c87375561b10a8cd3b27f73e273d6674b1c`.
Seven hash-matched copies under `lean-final-record/` preserve that manifest,
the proof log, final phase record, wrapper log/resource samples, corroboration
record and its checker. Originals and all caches remain in place. No native
validation phase remains pending.

## Parallelism and cache settings

The host exposes 12 CPUs. Routine `python3 scripts/dev.py prove` defaults to
`--jobs 0` (all available cores), incremental analysis and the native filesystem
solver cache. The completed recovery audit explicitly used four workers under
the conservative handoff settings; it does not measure all-core performance.
Ordinary `--full` retains that cache, while optional `--cold` allocates separate
fresh state.

Lean retains compiled modules and preserves unchanged source timestamps. Lake
schedules independent modules concurrently; the recovery-time default `--threads 1` set
declaration threads within each Lean build/audit process. The recovery run also
set `--memory-mb 6144` per process. These are conservative settings, not a
measured optimum for the replacement host. The separate fresh kernel checker
does not receive those thread or memory arguments. Increasing declaration
threads does not establish proportional speedup and can multiply memory use
across concurrently building modules. No tuning experiment was performed during
recovery. The owner subsequently authorized [Lean concurrency tuning](lean-concurrency.md);
that separate record supplies the measured settings for ongoing work.

Every ordinary Lean invocation executes the axiom audit afresh; `--full` adds
the fresh kernel recheck, and optional `--clean` discards native module caches.
Use ordinary cached commands for development and the existing full-validation
workflow when its assurance record is needed. A change to any embedded Ada source
invalidates the whole Silver Lean library, as required by its source dependencies.
The earlier bounded certificate-performance investigation remains closed at
`5668806`; this host recovery does not claim a new performance improvement.

## Snapshot recovery

At initial inspection, `.silver/`, `.tools/`, `tmp/` and `.vscode/` were absent.
The owner subsequently supplied the old artifact/tool trees through the
[Silver snapshot](https://github.com/berkeleynerd/silver/blob/1bf065de18e1e33bbc36bb15894e104f27bae3b2/silver/README.md)
and [tool snapshot](https://github.com/berkeleynerd/silver/blob/1bf065de18e1e33bbc36bb15894e104f27bae3b2/tools/README.md).
After the sandbox restart, the shared repository had eight fetched migration
commits ending at `1bf065de18e1e33bbc36bb15894e104f27bae3b2`. Local main was
fast-forwarded to that commit after preserving the documentation draft; both
sets of handoff changes were merged. The migration changes only archives,
their attributes and documentation, leaving implementation/proof inputs unchanged.
All 2389 native compiler input hashes still matched after the restart and merge.

Both snapshots were verified against every part hash, the complete compressed
archive hash and recorded byte sizes before extraction into fresh staging.
Extracted inventories matched exactly, and full decoded GNU tar comparisons
passed without differences. The manifests record capture at 20:43:42 UTC from
`69d294c`:

| Snapshot | Parts | Restored regular files | Regular-file bytes | Symlinks |
| --- | ---: | ---: | ---: | ---: |
| `.silver/` | 18 | 183611 | 4537235396 | 1032 |
| `.tools/` | 126 | 81697 | 15538483416 | 100 |

Restored `linux-aarch64`, `macos-aarch64` and legacy entries under their original
live dot directories. There were no collisions and neither archive contained a
`linux-x86_64` entry. Existing native x86-64 state was preserved. Original paths,
symlink targets, executable modes and nested repositories were retained; no
foreign executable was run or evidence manifest rewritten. The committed
snapshot archives remain intact in Git history at the snapshot commit above.
Detailed recovery checks and logs are under
`.silver/linux-x86_64/host-readiness-2026-10-09/restoration/`.
`recovery-summary.json`, `restoration.json` and
`historical-evidence-verification.json` distinguish archive integrity,
restoration and historical provenance. Approximately 564 GiB remained free in
the mounted workspace after recovery; root and Docker storage were unchanged.

Recovered historical state includes guarded-greeting final validation and
failed/interrupted attempts, `cold-tline0db` compiler provenance, Lean proof
objects and solver caches, both bounded performance investigations, and macOS
baseline review records. Both documented final ARM64 manifest SHA256s match
the [capability record](command-line-greeting.md). Read-only checks also matched
archived source inputs, reports, proof-workspace inputs, compiled proof artifacts
and tool bytes against their original platform/input records. The old Linux
system Python and macOS Homebrew Python binaries were outside the snapshots;
their recorded identities cannot be revalidated here. They are not substituted
with this host's Python. This is restoration/corroboration of historical evidence,
not new execution on ARM64 or validation of the sixth form on macOS.

| Historical evidence | Compiler inputs / reports / archived tools | Lean source inputs / workspace inputs / artifacts / tools |
| --- | --- | --- |
| Linux ARM64, `96b4e3a` | 2389 / 18 / 11 | 93 / 70 / 136 / 3 |
| macOS ARM64, `a73f85e` | 2374 / 18 / 11 | 83 / 60 / 116 / 3 |

All hashes in these groups matched. Both Lean logs, the reviewed-code identities
and representative failed/interrupted attempts were retained and checked. The
initial broader historical checker lookup and its corrected classification of
unarchived system Python are both preserved in the recovery directory.

The top-level old `tmp/`, `.vscode/`, CLI memory and checkout `.git` local state
were not included in these two snapshots and remain unavailable here. The
current Git history and nested repositories in the snapshots are distinct from
recovering those omitted local files. Preserve any remaining old VM/backup until
that separate local state is accounted for. The
[performance record](certificate-performance.md) retains its original negative
result; no further candidate was attempted.

On October 10 the owner clarified that a reference to a non-dot `codex/` backup
meant `silver/`. Both intended snapshot directories, `silver/` and `tools/`, have
therefore been recovered; there is no outstanding request to locate a separate
`codex/` tree. This clarification does not add the omitted local state to either
archive.

After verified recovery, the owner authorized removing the temporary non-dot
`silver/` and `tools/` archive directories from the current tree and synchronizing
the remote. The restored `.silver/` and `.tools/` trees, including native and
foreign-host evidence and caches, remain preserved. This removes the migration
copies from the current tree without rewriting Git history; the original archives
and checksums remain recoverable at `1bf065de18e1e33bbc36bb15894e104f27bae3b2`.
See the [recovery guidance](../RESUME.md#recover-and-preserve-the-old-vm-evidence)
for retrieving those archives and extracting them into separate staging.

## Git, remote and hosted CI

Initial `main`, cached `origin/main` and cached `origin/HEAD` all pointed to
`69d294c35297d6facc7473c3275721a2675129bc`, with zero cached divergence and a
clean worktree. The repository is nonshallow and `git fsck --no-reflogs` passed.
It passed again after incorporating the migration snapshots; informational
dangling objects were preserved, with no pruning or garbage collection.
The cached remote-tracking reflog records a pull at 20:03:44 UTC. Origin remains
`git@github.com:berkeleynerd/silver.git`.

Fresh remote/CI verification at 20:36:59 UTC was blocked: the supplied `GH_TOKEN`
returns HTTP 401, removing environment tokens reveals no stored `gh` login,
and SSH lookup fails host-key verification with no local SSH identity present.
An anonymous lookup returns 404 for the private repository. No credential or
remote configuration was changed; cached refs are not a fresh remote check.
Rechecks through 22:29:15 UTC, including after the first sandbox restart, still
failed. The configured forwarded SSH agent also failed communication
(`ssh-add -l`), and token-free noninteractive HTTPS Git lookup had no username
available. Those failures are historical; authentication recovered after the
second restart, as confirmed by `gh api user` at 22:41:35 UTC.

Authenticated API checks at 22:42:39–43 UTC confirmed remote `main` at
`1bf065de18e1e33bbc36bb15894e104f27bae3b2`, matching local main and cached refs.
An HTTPS fetch using the command-scoped `gh` credential helper succeeded without
changing origin configuration. Repository permissions include push access.
The exact remote/CI responses are retained in
`authenticated-remote-ci-audit-20261009T224239Z.json` in the readiness directory.

The latest previously documented hosted run is
[37983290787](https://github.com/berkeleynerd/silver/actions/runs/37983290787)
for `9731278`, then reported in progress. The authenticated API now returns 404
for that run, lists zero repository runs, and returns no check runs for either
`9731278` or `1bf065d`. Its final jobs/results are unavailable, not inferred to
have succeeded or failed. `Verify Silver` was already `disabled_manually`, while
repository-wide Actions was initially enabled. The owner then explicitly
instructed that GitHub CI be disabled entirely because validation runs locally.
Repository Actions permissions were changed to `enabled: false` and read back
successfully; the existing workflow remains manually disabled and no run was
dispatched. `github-actions-disabled-by-owner.json` records the authorization,
before/after settings and verification times. Hosted validation is outside the
requested local workflow, not a readiness blocker or a follow-up to enable.
The dormant checked-in workflow defines native and Lean jobs on
Ubuntu x86-64, Ubuntu ARM64, macOS Intel and macOS ARM64, with 30/120-minute
timeouts; its definition establishes no hosted success and remains unchanged.

Continuing publication authorization is recorded in
[session memory](session-memory.md). The earlier documentation checkpoint
preserved completed recovery while Lean was still pending across host restarts.
The checkpoint was committed and published as `eb7262a`; an authenticated
October 10 audit confirmed local `main`, cached `origin/main` and remote `main`
at that commit, with no divergence. The safety stash `a48321d` remains preserved.
Actions was still disabled repository-wide, `Verify Silver` manually disabled,
and the run list empty. The audit, including final host resources and native
tool versions, is `final-host-remote-audit-20261010T002233Z.json`. The latest
native result is recorded above; this completion follow-up leaves the
feature-review target unchanged. Publication remains authorized; its closing
commit and actual remote outcome are reported at handoff.

## CLI memory and remaining scope

CLI memory remained unavailable at the October 10, 00:21:30 UTC final recheck:
`CODEX_HOME` is `/home/agent/.codex`,
the memory directory and old ad-hoc notes are absent, and `codex features list`
reports `memories` disabled. No memory tools are exposed. No recall file was
updated and no global feature setting was changed. The check is recorded in
`cli-memory-final-audit-20261010T002130Z.json`. Checked-in
[session memory](session-memory.md) remains the durable handoff; this is not a
claim about asynchronous background memory generation.

Independent macOS validation of the sixth form and AdaCore GNAT Pro validation
remain outside this native run. The reused-state GNATprove `DOC_END` failure
remains unresolved; fresh-state success does not establish its repair. Faithful
complete obligation generation, concrete pinned-solver completion and the other
documented frontend/runtime/environment premises remain explicit. No Oracle,
source, catalogue, proof or language changes are part of this readiness task.
