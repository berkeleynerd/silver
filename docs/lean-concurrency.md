# Lean concurrency tuning — 2026-10-10

The owner requested tuning Lean for maximum useful concurrency and offered more
RAM if measurements justify it. This authorizes scheduling experiments on the
current proofs and a corresponding runner change. The language, source
certificates and assurance requirements remain unchanged. The earlier
[certificate-representation investigation](certificate-performance.md) remains
closed at `5668806`; this work does not introduce another representation candidate.
GitHub Actions remains disabled; validation runs locally.

The selected defaults use all available CPUs for both Lake's worker pool and
each Lean build/audit process: 12 of each on this host. The measured handwritten
module rebuild took 21% less wall time, with no additional RAM needed for that
workload. Native regression tests, full Lean validation and the cached full
compiler audit passed. The proof sources and assurance requirements are unchanged.

## Host and controls

The native Linux x86-64 sandbox has 12 available CPUs and 31.42 GiB RAM, with
no swap or additional observed cgroup CPU/memory quota. Lean is pinned to 4.34.1,
commit `5045d0056413266e57c625dcd7c365b10e377c52`; bundled Lake is
5.0.0-src+5045d00. See [host readiness](host-readiness.md) for the installation
and preceding full native validation.

The runner exposes two independent controls:

| Option | Meaning |
| --- | --- |
| `--workers N` | Lake workers for independent modules; `0` selects available CPUs and is the default. |
| `--threads N` | Worker threads within each Lean build/audit process; `0` selects available CPUs and is the default. |
| `--memory-mb N` | Optional internal resident-memory threshold in MiB per Lean build/audit process, checked periodically. |

CPU detection respects the process affinity mask and Python's CPU-count
override, with a portable system-count fallback. Affinity does not describe
CPU-time quotas or competing workloads; those can require an explicit lower
worker setting. Lake receives `LEAN_NUM_THREADS` in its subprocess environment
after ambient Lean/Lake settings have been removed. The explicit `-jN` argument
separately configures Lean processes. No global environment or tool setting changes.
The lakefile falls back to one Lean thread when elaborated without
`silverThreads`. Direct Lake builds in an existing workspace can retain cached
`silverThreads` and `silverMemoryMb` settings. The runner reconfigures Lake on
each invocation; use `scripts/check_lean.py` for reliable resource selection.

Lean's `-M` threshold checks process RSS periodically in the pinned
[runtime](https://github.com/leanprover/lean4/blob/5045d0056413266e57c625dcd7c365b10e377c52/src/runtime/memory.cpp#L145).
The [shell conversion](https://github.com/leanprover/lean4/blob/5045d0056413266e57c625dcd7c365b10e377c52/src/Lean/Shell.lean#L476)
uses MiB. This is neither a cumulative allocation counter nor a hard OS-enforced
cap, and it does not bound the combined memory of concurrent processes.

These worker counts are scheduling controls, not strict OS-thread caps. Process
main threads, dedicated I/O workers and replacement workers for blocked tasks
can add threads. Selecting all CPUs for both independent controls can multiply
thread pools across concurrent modules; it does not establish higher throughput.

## Completed measurements

Trials re-elaborated the exact current `Silver.ProfileBodyCertificate` using
the native pinned tool and identical imported artifacts in an isolated copy.
The authoritative source link still resolves to the actual repository `src/`.
Output files and measurements stay outside the ordinary proof workspace. All
trials used `-M6144` and treated warnings as errors.

| Lean threads | Wall time | Average CPU cores used | Peak process RSS | Result |
| ---: | ---: | ---: | ---: | --- |
| 1 | 196.126 s | 0.988 | 1.535 GiB | Passed |
| 2 | 194.133 s | 1.017 | 1.465 GiB | Passed |
| 12 | 202.110 s | 1.016 | 1.486 GiB | Passed |

The generated `.olean`, `.ilean` and C outputs matched byte for byte. The
ordinary native proof tree and copied baseline remained unchanged. These are
single trials in sequential order (1, 12, then 2), with approximately two-second
completion polling, not repeated statistical estimates. Twelve threads showed
no speedup for this certificate.

The same comparison on the handwritten `Silver.GuardedSourceBridge` gives:

| Lean threads | Wall time | Average CPU cores used | Peak process RSS | Result |
| ---: | ---: | ---: | ---: | --- |
| 1 | 94.087 s | 0.982 | 2.947 GiB | Passed |
| 2 | 76.069 s | 1.370 | 2.945 GiB | Passed |
| 12 | 56.050 s | 2.068 | 3.582 GiB | Passed |

Its `.olean`, `.ilean` and C outputs also matched across all three settings.
Twelve threads reduced this module's wall time by about 40% relative to one,
with higher CPU use and memory. This measures rebuilding that theorem module
with its imports cached; it does not establish a whole clean-build speedup.

### Combined handwritten-module rebuild

Two isolated copies retained the ten source certificates and their five imported
dependencies, then rebuilt the other 53 handwritten modules. Lake workers stayed
at 12; each trial used the same source/tool/import identities and `-M6144`.
Cache-only preflights confirmed that the retained modules needed no rebuilding.

| Threads per Lean process | Wall time | Average CPU cores used | Peak sampled sum of RSS | Minimum host memory available |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 295.361 s | 1.825 | 10.592 GiB | 24.720 GiB |
| 12 | 232.213 s | 2.610 | 10.273 GiB | 25.034 GiB |

Both trials passed. Twelve threads reduced wall time by 21.38% (1.272×
throughput), using more CPU time: 606.169 versus 538.910 CPU-seconds. All 68
module `.olean` files matched between settings. The 15 retained modules kept
their hashes and modification times, with no certificate compilation. The
normal proof tree and isolated baseline also kept their complete file hashes;
all 136 normal compiled-artifact modification times remained unchanged.

These are single sequential trials with 0.5-second resource sampling, not
statistical estimates or a clean build of the entire library. Summed process RSS
can count shared pages repeatedly; it is not unique physical memory use. Neither
trial approached the 2-GiB available-memory stop threshold. The higher setting
reached eight simultaneous Lean processes, with dependency chains limiting
whole-run CPU utilization. Allocating more RAM has no demonstrated benefit for
this workload. A complete certificate rebuild at the new setting was not timed;
its combined peak memory is not established by these retained-certificate trials.
The selected setting is the fastest tested for this combined workload. Other
hosts and changed proof dependency graphs may have different optima.

These historical trials used `--memory-mb 6144`; the setting applied per Lean
process. The [handoff](../RESUME.md) records current host settings, and the
[development workflow](../development.md#proof-loop-and-validation) describes
focused checks, complete checkpoints and optional `--replay`. Explicit
`--workers N` and `--threads N` remain available when other workloads or host
limits require lower counts.

## What can run concurrently

Lake already schedules independent modules. A disposable native scheduler probe
built six independent modules with finite sleeps: setting Lake workers to
1, 2 and 4 produced observed maxima of exactly 1, 2 and 4 simultaneous module
compiler processes. This verifies the control on the pinned toolchain; its
sleep timings are not Silver proof-throughput measurements.
Lake already selected hardware concurrency on this host before the new explicit
worker control; the measured improvement comes from increasing per-process
Lean threads, with Lake workers held constant.

Installed Lean source explains the certificate result. Definition bodies
elaborate synchronously, and their asynchronous kernel checks depend on the
preceding checked environment. More workers can overlap elaboration, checking
and compilation, but cannot parallelize every individual reduction. The largest
output-body certificate has 3,940 definitions and only three final theorems.
Independent certificate modules can still build concurrently. Eligible theorem
bodies have additional asynchronous elaboration opportunities.

The pinned `leanchecker --fresh Silver.Audit` replays declarations sequentially
from an empty kernel environment. It has no thread or memory-limit CLI control;
extra worker settings cannot parallelize this phase. The existing full check
is preserved, with its actual input/tool scope and assurance meaning unchanged.

## Runner validation and review

`python3 -m unittest tests.test_lean_evidence tests.test_platforms -v` passed all
33 tests in 49.426 seconds with no skips. These include native Lake configuration,
worker-environment, cache retention and embedded-source invalidation checks, plus
automatic/explicit resource selection, CPU fallback and environment isolation.
Foreign-platform routing is mocked; this is not new native macOS validation.
The initial run found a missing `IO Unit` annotation in the new Lean test fixture.
The fixture was corrected and the passing rerun retained alongside the initial
failure; no production runner change was needed for that failure.

Independent runner and benchmark reviews found no blocking issue. They checked
resource-control semantics, cache preservation, unchanged audit/kernel behavior,
test coverage and the limits of the performance claims. The stale recovery-time
default wording was corrected, and raw bridge/aggregate evidence links were added.

`python3 scripts/check_lean.py --full --memory-mb 6144` passed in 982.288 seconds
(982.883 seconds including the recording wrapper). It resolved both concurrency
settings to 12, reused the existing compiled modules, freshly audited all 19,993
project declarations and passed `leanchecker --fresh Silver.Audit`. Only the
standard `propext`, `Classical.choice` and `Quot.sound` foundations were used.
This is cached full validation of the final runner, not a clean rebuild. The
wrapper sampled 5.732 GiB peak summed process RSS and at least 27.003 GiB of
host memory available. The kernel phase still dominates this full invocation.

`python3 scripts/dev.py prove --full` passed with the all-core default and native
solver cache in 10.013 seconds including its recording wrapper: 16 units, 203
entities, 383 flow checks and 2,233 proof checks, all discharged. Sessions and
cache entries were present at the start. This is an ordinary full audit with
reuse, not a cold proof measurement or evidence that the historical warm-state
`DOC_END` defect is repaired. The runner script is among the compiler audit's
captured inputs, so this run refreshes that provenance despite unchanged compiler
and proof sources. The existing native compiler binary needed no rebuild.

Independent final corroboration passed against the actual completed records.
All 108 protected implementation/proof/specification inputs match `04c6cb7`.
Lean's source, workspace, tool, log and artifact identities match the final
manifest; its 136 compiled-artifact hashes match the preserved recovery evidence,
and all 68 module `.olean` modification times are unchanged. Compiler coverage
and provenance also passed revalidation. The final test log and all seven
captured test-input hashes match. This confirms cache reuse and the final
input scope; historical macOS evidence retains its earlier scope.

The later [external review](command-line-greeting.md#external-review-disposition)
reported native macOS validation with all-core defaults and no swap. That report
is distinct from the Linux measurements above; its raw records are unavailable
here, and obtaining or corroborating them is entirely optional.

## Cache preservation and evidence

Per-process thread/memory flags remain `weakLeanArgs`, preserving accepted module
caches when resource settings change. The Lake worker environment does not
change object trace inputs. Lake configuration is re-elaborated so each invocation
applies the requested options. Unchanged source timestamps, authoritative Ada
dependencies, tool/input hashes and module coverage checks remain in place.
Every runner invocation executes a fresh axiom audit; `--full` still adds the
independent fresh kernel replay. None of the module timing trials substitutes
for a completed full-validation record.

## Runner follow-up

On 2026-10-10 the owner authorized folding bounded Lean workflow improvements
into the [assignment review follow-up](string-assignment.md#external-review-disposition).
All-core scheduling and retained module caches were already enabled. The useful
additional saving is avoiding later verification phases when a run is already
invalidated: re-enumerate shared and workspace inputs, compare paths and bytes
at phase boundaries, and check fresh audit success and module coverage before
starting the independent kernel replay. Detecting such a failure after the build
retains its useful compiled artifacts while avoiding the remaining audit/replay
cost. Successful unchanged runs still perform the same checks.

This also closes the prior final-inventory gap: hashing only the originally
captured paths detected edits and deletions but missed additions. Shared inputs,
handwritten workspace files and regenerated candidates retain their distinct
roles. Tool identities, authoritative source links and compiled artifacts remain
checked. These controls do not establish adversarial workspace security.

Build, audit and kernel output now streams to the existing log and console, with
phase timing and status. This preserves partial diagnostics and makes the phase
responsible for a delay visible; a silent Lean reduction still emits no progress.
It is not a computational speedup. No faster certificate representation or new
steady-state throughput result is claimed for that runner follow-up. The
subsequent [source/dependency partition](lean-compartmentalization.md) and
[proof-only native I/O change](native-io-performance.md) are complete; their
separate records contain their measurements and validation.

Use focused Python runner tests for runner-only edits and focused Lean arguments
during proof iteration. Keep the complete checkpoint on stable capability inputs,
as specified in the [development workflow](../development.md#proof-loop-and-validation).
Extra RAM supplies headroom rather than parallelizing serial reductions or the
fresh checker. No additional macOS proof work is part of this follow-up.

Follow-up evidence is retained under
`.silver/linux-x86_64/review-44fd8ea/follow-up/`:

- `runner-tests.json` and `.log`: all 43 focused runner/platform tests passed in
  54.381 seconds, including disposable native Lake fixtures and early-failure
  and partial-output regressions. Platform routing fixtures remain mocked.
- `test-evidence-result.json` and `helper-mutation-closure/summary.json`: all 29
  evidence-helper tests passed; the new cases catch all seven individual guard
  deletions and their combined deletion in isolated copies.
- `lean-smoke-result.json` and `lean-smoke-corroboration.json`: the cached Linux
  build and fresh axiom audit passed in 5.928 seconds including the wrapper.
  All 75 modules and 21,443 declarations were audited with standard axioms only.
  The 75 `.olean` and 75 `.ilean` objects retained their bytes and timestamps.
  An overly broad wrapper assertion also compared the 75 `.olean.hash` sidecar
  timestamps, which the existing `--rehash` option rewrites. Corroboration verified
  their unchanged bytes; both records remain preserved without rerunning Lean.

This was a cached incremental check, not a cold build or new full kernel replay.
The earlier full evidence was copied before the check and retains its original
scope. Compiler and proof sources were unchanged; the smoke timing measures
this invocation only, not a before/after speedup. Independent review found no
blocking issue in the runner or documentation changes.

## Retained concurrency evidence

Ignored evidence is retained under
`.silver/linux-x86_64/lean-concurrency-2026-10-10/`:

- `benchmarks/pilot-results.json` records exact commands, source/tool/output
  identities and completed certificate results; trial directories contain logs
  and resource samples. `benchmarks/bridge-pilot-results.json` records the three
  handwritten bridge trials.
- `benchmarks/aggregate-preparation.json` and `aggregate-results.json` record the
  isolated copies, retained/forced module sets, commands and combined measurements.
  `benchmarks/final-benchmark-corroboration.json` records cache/output identity
  checks; `benchmark-summary.json` summarizes the completed measurements.
- `benchmarks/native-proof-hashes-before.json` and `baseline-hashes.json`
  preserve the normal workspace and isolated baseline identities.
- `internals/lake-probe/` contains the disposable scheduler sources, logs and
  sampled processes; `summary.json` summarizes its observations.
- `internals/findings.md` and `source-identities.json` identify the installed
  source and pinned upstream runtime code supporting the scheduling claims.
- `host-remote-memory.json` records host capacity, authenticated remote identity,
  disabled Actions and unavailable CLI memory at the tuning checkpoint.
- `runner-tests.json` and `.log` record the final tests and input identities;
  `runner-tests-initial.json` and `.log` retain the repaired fixture failure.
- `lean-full/result.json`, `command.log`, `resources.jsonl` and `before/`/`after/`
  retain the complete native full run, resource samples and both old/new evidence.
- `compiler-full/` retains the corresponding cached full audit, with its previous
  and refreshed reports/provenance. `final-validation-check.json` records the
  independent identity/coverage checks against the final inputs and preserved
  recovery artifacts.
- `resume-checkpoint.json` records the tuning scope and handoff status.

The preceding completed native Lean evidence is separately preserved under
`.silver/linux-x86_64/host-readiness-2026-10-09/lean-final-record/`. Existing
native and foreign-host evidence, tools and caches remain intact. The scheduling
change is reviewed separately from feature implementation/review target `96b4e3a`;
the prior recovery handoff is `04c6cb7`. Git history identifies the commit carrying
this record, and `publication.json` records its actual remote outcome. Actions
remains disabled. CLI memory remains disabled and absent; no CLI recall was
updated. Checked-in [session memory](session-memory.md) and [RESUME.md](../RESUME.md)
carry the durable handoff. No additional language work is authorized by this task.
