# Incremental proof workflow

This records the pre-1.0 workflow changes following the second review of
`8b8619f`. The admitted null-only language and all Ada implementation sources
remain unchanged. The earlier proof and platform results in
[review-repairs.md](review-repairs.md) are historical evidence for that baseline.

## Scope

Everyday GNATprove checks use native incremental analysis and a local filesystem
solver cache. Full validation retains complete unit/report auditing and current
input/tool provenance. Lean keeps its native build cache, tracks embedded Ada
dependencies and executes the axiom/module audit afresh. Full validation adds the
independent kernel recheck; clean validation rebuilds the host workspace.

The temporary-directory fixture is corrected to canonicalize its root, with a
subprocess regression under a deliberately symlinked `TMPDIR`. No sample
migration, output library, binary attestation or language-version machinery is
introduced. See [development.md](../development.md) for commands and policy.

## Baseline macOS evidence

The external review reported native macOS ARM64 proof, build and evidence-audit
success for `8b8619f`: 662 compiler checks and a clean Lean replay with a fresh
kernel recheck over 17 modules and 3,828 declarations. It reported 58 of 61 tests
passing; three fixture errors occurred under symlinked temporary directories.

Read-only checks in the Linux environment corroborated all 2,359 recorded
compiler-proof input hashes and 10 report hashes, plus the retained Lean input,
workspace, artifact and log hashes. The Lean evidence SHA256 was
`7bc1dab2dd1ac53f22ef8b6d7c415a4e95aaf6291b5f40918d4edc4711aa8a32`.
Its recorded duration was 410.098 seconds. No macOS tool was executed in those
corroboration checks. Those artifacts do not validate the newer workflows.

## Initial Linux validation of the incremental workflows

Validation ran on Linux ARM64 on 2026-10-08, with 12 detected CPUs. Tool versions
remain GNAT/GNATprove 16.1.0, GPRbuild package 26.0.1 and Lean 4.34.1.
Durations below are observations on this host, not performance thresholds or
controlled comparisons. Some checks overlapped the initial Lean build.

| Check | Result | Elapsed time |
| --- | --- | --- |
| First full GNATprove run, populating the native cache | All 662 checks; complete audit passed | 609.900 s |
| Subsequent incremental GNATprove runs | All 662 checks reported; developer feedback without a new full-audit manifest | 10.47 s with one worker; 14.0 s and 3.65 s with all cores |
| Final `dev.py prove --full`, using the populated cache | All 662 checks; complete current-input audit passed | 32.886 s |
| Initial `check_lean.py`, after tool-cache invalidation | All modules built; fresh axiom audit passed | 919.302 s |
| Unchanged `check_lean.py`, using the populated cache | Proof objects reused; fresh axiom audit passed | 12.171 s |
| `check_lean.py --full`, using the populated cache | Fresh axiom audit and independent `leanchecker --fresh` passed | 634.001 s |
| `dev.py build` | Native compiler up to date | 2.476 s |
| `dev.py test`, with a deliberately symlinked `TMPDIR` | All 78 tests passed, including actual Lake dependency checks | 110.930 s |

The final compiler audit covers eight units and 73 entities: 125 flow checks,
537 proof checks, 12 classified optional limitation notes and 11 trusted imported
entities. Its provenance binds 2,359 input hashes, 10 report hashes and 12 tool
identities. A separate invocation of `scripts/check_evidence.py` also passed.
The first full run preceded the SARIF path-serialization correction; the final
full run covers the scripts at that stage. Build and final tests overlapped the initial
Lean build. The test runner itself reported 110.214 seconds; the table includes
wrapper overhead.

The complete suite exercises native compiler admission/proof/build/execution,
report validation, host isolation, symlinked temporary directories and Lean
incremental behavior. A real small Lake project confirms unchanged proof-object
bytes and modification times are reused. Changing either embedded Ada file,
including a line-ending byte change with the old timestamp restored, rebuilds
and rejects a stale proof. Other regressions cover removed modules, changed
tool identities, fresh audit execution and full/clean mode routing.

The native Lean build covers 17 project modules and audits 3,828 declarations,
using only `propext`, `Classical.choice` and `Quot.sound`. The initial check
rebuilt the project after tool-cache invalidation; it did not use `--clean` or
perform the separate kernel recheck. The warm run preserved all 17 `.olean`
files' bytes and modification times. Lake's `--rehash` refreshed hash-sidecar
timestamps without changing their contents; those are distinct from the proof
objects. Cached Lake audit messages were followed by a separate fresh audit.
Full validation also preserved the proof objects and passed the independent
kernel recheck. No native `--clean` invocation ran for these changes; initial
cache invalidation rebuilt every module, and clean-mode routing is tested.
The evidence records the actual modes and `clean_replay: false`.

Final checks confirmed all local links in the changed Markdown documents resolve,
`git diff --check` passes, and no Ada implementation, proof theorem, catalogue
or sample file changed.

### Validation diagnostics

The first warm incremental GNATprove invocation returned failure after 10.052
seconds with `GNAT BUG DETECTED` and `1:0: value expected (got DOC_END)` while
processing `silver_profile.adb`. The GNATCOLL JSON parser reached end-of-input
before its first value, but the log identifies neither that input nor a failed
writer. A parallel race and a serial workaround have not been established.
Its cause remains unresolved; a later recurrence is recorded below. The inspected
cache entries were valid JSON; that does not diagnose the failure. Three manual
reruns passed, followed by the final full audit. No automatic retry or success
override was added. Retain the diagnostic if it recurs and investigate before
claiming a successful check.

An isolated native probe established that GNATprove serializes its SARIF
`commandLine` as arguments joined by spaces, without shell quoting. Parsing that
field with `shlex.split` fails for an ordinary path containing an apostrophe.
Full audits now compare the producer string to captured argv and inspect those
actual argument boundaries. Tests cover spaces, quotes, option-like path text,
real option overrides and command mismatches. This is a path-portability repair.

The first complete test run found a stale mock expectation after the auditor
began receiving captured argv. Updating that expectation resolved both the
direct failure and its nested symlinked-TMPDIR regression; the final suite passed.

### Resource use and remaining cost

GNATprove defaults to all detected cores and permits `--jobs N`. Lake schedules
independent modules, but the generated source-certificate module dominates cold
Lean builds. One declaration thread per process is a conservative memory setting,
not an established optimum. Higher thread counts have not been comparatively
benchmarked. `--threads N` and `--memory-mb N` permit machine-specific tuning;
incremental reuse avoids rebuilding unchanged certificates. This paragraph records the pre-output baseline. The output capability later
added a statement bridge and split certificates into seven independently
scheduled modules; see [hello-world.md](hello-world.md) and the subsequent
[review repairs](hello-review-repairs.md).

On that historical monolithic run Lake reported 802 seconds for `SourceCertificates` alone. Caching
improves unchanged checks; it does not remove that cost when the certificate's
inputs change.

### Retained local artifacts

Logs and timing records are under the ignored
`.silver/linux-aarch64/workflow-validation/` directory. They include the initial
GNATprove failure and all subsequent successful runs. The final compiler
provenance is `compiler/obj/gnatprove/proof-provenance.json` under that host,
also copied to `workflow-validation/gnat-final-provenance.json`. Its SHA256 is
`287e8419277395cb0376e6ef73abf42b968019589399a0760869da36eaaf488d`.
These hashes identify local evidence; they do not attest a distributed binary.

That iteration's `.silver/linux-aarch64/lean-evidence.json`, copied to
`workflow-validation/lean-full-evidence.json`, has SHA256
`38ffcbc1e97b197bd43552f68041a15ac573706b17c16c8e9199a4e27cdfd380`.
Its 37 input hashes, 19 workspace-input hashes, 34 artifact hashes, three tool
hashes and log hash were checked again after completion. The warm incremental
record is retained separately as `workflow-validation/lean-warm-evidence.json`,
SHA256 `c16f1ac7343f577bdc6dfe0b9539b3e646de4a2e90c38d2b4be2b1045efef2a6`.
Matching build/audit logs and proof-object snapshots remain beside those copies.

## Subsequent native macOS workflow review

An independent review on macOS ARM64 ran the staged incremental workflows before
the cold-proof option and exploratory guard were added. It reported these native
results:

| Check | Result | Reported elapsed time |
| --- | --- | --- |
| Incremental compiler proof | 662 checks | 14 s |
| Full compiler proof, build and evidence audit | Complete audit passed; build up to date | 4 s proof; less than 1 s build; 1 s audit |
| Tests with default symlinked `TMPDIR` | 78 passed, none skipped | 31 s |
| Lean initial incremental build | 17 modules, fresh audit of 3,828 declarations | 174 s |
| Lean warm incremental check | Objects reused; fresh audit | 1.6 s |
| Lean full check | Fresh audit and independent kernel recheck | 135 s |
| Lean clean check | Workspace rebuilt; fresh audit and independent kernel recheck | 288 s |

Linux-side read-only corroboration matched all 2,359 compiler input hashes and
10 report hashes to the then-current tree. The report auditor independently
accepted all 662 checks. Eleven available compiler-tool hashes matched; the
reviewer's external macOS Python executable was unavailable from Linux.
The compiler provenance SHA256 is
`60840985a108e2fd87e7a4d360b9854c71f10db73ec754b2de7357bc5c1e4355`.

The retained final Lean evidence records `mode: clean`, `clean_replay: true`,
the independent kernel recheck, and 287.757 seconds. Its 37 input, 19 workspace,
34 artifact and three tool hashes, plus the log hash, all matched. Its SHA256 is
`3eca76790cabf3f87314c1a35acee294aef4502932e180186024364e5049be8d`.
The intermediate Lean modes and test-suite result are attributed to the reviewer;
the final clean artifacts were independently corroborated. No macOS executable
was run in the Linux corroboration. These results validate that staged iteration,
not the subsequently added cold mode and exploratory guard.

The macOS full-proof timing shows the benefit of native reuse; it does not by
itself identify every executed prover or demonstrate uncached performance.
Installed Why3 configurations pass the timeout to the solver-cache wrapper's
key input. The review's specific claim that a 600-second solver-cache result
would be accepted under a 30-second setting was not reproduced. Why3 sessions
are a separate reuse mechanism. Full validation audits current obligations and
coverage, while uncached resource measurements require a cold run.

## Cold mode and exploratory-state follow-up

The owner approved an optional `prove --cold`, a small guard for direct
exploratory GNATprove invocations, and documentation corrections. Cold runs
start with new native-host object/session/cache directories and perform the
complete audit; they preserve ordinary warm state. The real session layout is
per-subprogram directories below `gnatprove/`, so starting fresh avoids relying
on a nonexistent default `gnatprove/sessions` directory. Exploratory commands
use the reserved `explore` output subdirectory and a separate cache. These are
conveniences for avoiding accidental state mixing, not a hostile-user boundary.

The first native cold run passed all 662 checks in 62.852 seconds and preserved
the ordinary report/session/cache contents byte for byte. The subsequent warm
full run failed after 2.398 seconds with the same `DOC_END` diagnostic in
`silver_numbers.adb` and `silver_platform.adb`. Its reports, sessions, cache and
logs were copied before further diagnostics. The failure invalidated completed
warm success evidence as intended; the independent cold evidence remained valid.

A bounded manual comparison then passed all 662 checks and complete audits with
one worker (22.226 seconds), followed by all cores (20.454 seconds). This is a
second observed failure, including during a forced full run. It does not
establish a parallel-write race or a serial workaround, and no automatic retry
was added. The captured cache contained 3,733 nonempty hashed entries, including
51 valid JSON result envelopes. Some scratch or output files were empty; none
was conclusively linked to the parser input. Both
the symptom and uncertainty remain recorded for further diagnosis if it recurs.

Final current-input validation after correcting relative report-path handling:

| Check | Result | Elapsed time |
| --- | --- | --- |
| `dev.py prove --cold` | 662 checks; complete audit; both initial session/cache flags false | 58.423 s |
| Standalone audit using the cold report's relative path | Complete audit passed | 0.398 s |
| `dev.py prove --full` | 662 checks; complete audit; both initial session/cache flags true | 3.489 s |
| `dev.py build` | Native compiler up to date | 0.347 s |
| `dev.py test`, symlinked `TMPDIR` | 84 tests passed | 20.445 s |
| `check_lean.py` | Fresh audit of 3,828 declarations; all 17 proof objects reused | 6.574 s |

The final cold run used
`.silver/linux-aarch64/compiler/obj/cold-eqgtjts5/gnatprove/`; all 4,162 existing
warm report/session/cache files retained their contents. Cold and full records
identify their mode and observed initial session/cache presence; these
observations do not authenticate the workspace against an adversarial writer.
Cold provenance SHA256 is
`b5a265e3ee7bc46972c1a3dbdba89f11b63e10c95ca14dc6acc8adfbbe74e43c`;
final warm provenance SHA256 is
`5a0d525a3440fcaacc184d70898139c267457cb3b9a7a833256ce3ec10883071`.

The final Lean check ran alongside the test suite and reused every `.olean`
file's bytes and modification time. Its artifact hashes, tool hashes and
workspace-input hashes equal those in the earlier independent full kernel
recheck. Only `scripts/dev.py` and `scripts/proof_provenance.py` changed among
the captured inputs; neither the Lean checker nor any proof source changed in
this follow-up. The independent kernel recheck was not repeated. Current
incremental evidence SHA256 is
`53a11a69a798a3da429daf4fd30c9744e75e42b0e09dd067a6c7f6d579cad7d3`.
Its mode is explicitly incremental. Final logs, timing records and copied
manifests use the `final-` prefix in `review-followup-validation/`.

The full suite includes cold-run isolation and failure behavior, truthful mode
and starting-state records, direct exploratory-command routing, and equivalent
absolute/relative report-path validation. Markdown links and whitespace checks
also pass. No Ada implementation, proof theorem, catalogue or sample changed.

Prior Linux/macOS manifests and Lean logs are retained under the ignored
`.silver/linux-aarch64/review-followup-validation/` directory before refreshing
Linux evidence. The earlier records above remain historical once script inputs
change; source-level compiler and language proofs are unchanged.

## Deferred work

Compiler-binary attestations and comprehensive per-program dependency manifests
remain deferred. Development builds do not require proof evidence. Current
assurance records describe the checked inputs/results, not authenticated
distributed binaries. Additional adversarial hardening and stable-release
compatibility machinery can be added when their use is justified.

Native validation of the cold option and exploratory guard on macOS, and all
x86-64 validation, remains independent and pending.
CI is configured for full SPARK and clean Lean checks, but no remote CI run
exists; repository work remains local at the owner's request.
