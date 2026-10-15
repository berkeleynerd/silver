# Expression Headroom

The subsequent authorized [production adoption](#production-adoption) is tracked
below. The original experiment and its unchanged-production decision retain their
historical scope.

Status: bounded solver-budget investigation complete, authorized and completed
2026-10-15.
Baseline: `c2c1585e4bc13c6ac1bf2492f3d5e00fd23a9907` on Linux x86-64.

## Question and scope

Do the retained static and dynamic 64-leaf concatenation failures prove when
GNATprove's step allowance increases from 10,000 to 100,000? The earlier runs
left one of 63 Main range checks unproved; the final proof attempts reached step
limits, with a subsequent counterexample timeout. They did not establish memory
exhaustion. Additional RAM does not itself increase that search allowance.

Keep each original source, project and runtime snapshot unchanged. Compare fresh
10,000-step and 100,000-step runs sequentially, with separate exploratory output
and filesystem caches. Preserve the selected prover set, proof level, warnings,
worker count and zero configured timeout/memory limit. An external ten-minute
experiment budget prevents an unbounded trial; reaching it is an interrupted
experiment, not proof failure or evidence of nonmembership.

Record exact inputs/options, tool versions, time, process memory, report sizes
and remaining solver statuses. The original sources exceed current expression
limits and remain excluded. No production source, proof, admission rule, solver
setting or Oracle change is included. A successful pair would justify considering
a larger-fragment follow-up, not establish universal completion for that fragment.

## Evidence

The retained originals are `dynamic-operands64` under
`.silver/linux-x86_64/restrictions-capacity-20261012T170230Z/cases/` and
`static-mutable-flat64` under
`.silver/linux-x86_64/common-expressions-probes/20261013T152332Z/cases/`.
`tmp/expression-headroom-active.json` identifies the new isolated evidence.
Original artifacts and canonical native/Lean caches remain preserved.

Both retained argument-library snapshots predate the later invalid-input
empty-result postcondition and early return. The other four runtime files match
the current runtime. This experiment deliberately preserves those older bytes
in both arms of each comparison; it is not current-runtime validation.

The fresh runs use GNATprove 16.1.0, Why3 1.8.2+git, CVC5 1.3.2, Z3 4.15.4
and Alt-Ergo 2.6.1, matching the recorded tool versions. The environment exposes
12 CPUs and about 31.4 GiB RAM. No other proof workload runs alongside these trials.
Memory sampling every 0.2 seconds sums RSS across the isolated process session;
shared pages may be counted more than once and shorter peaks may be missed.
The separate Linux `wait4` maximum RSS is a largest-process high-water measurement,
not the simultaneous total. Both are retained rather than conflated. Historical
runs did not measure memory, so comparisons use the new paired runs.

## Results

All four runs used fresh isolated proof sessions and filesystem caches, with no
historical objects copied. The OS page cache was not cleared. Source/project/runtime
hashes matched before and after; the only proof option changed within each
pair was `--steps`. The dynamic case retained `--warnings=error`; the static case
retained `--warnings=continue` for its ineffective-initialization advisory.

| Retained case | Steps | Main range checks proved | Wall seconds | Sampled process-session RSS peak, MiB | Largest process peak, MiB | Main report bytes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Dynamic, 64 leaves | 10,000 | 62/63 | 101.818 | 1,040.7 | 373.9 | 111,898 |
| Dynamic, 64 leaves | 100,000 | 63/63 | 55.857 | 1,248.8 | 371.5 | 112,002 |
| Static mutable, 64 leaves | 10,000 | 62/63 | 91.577 | 967.2 | 279.6 | 110,546 |
| Static mutable, 64 leaves | 100,000 | 63/63 | 46.187 | 1,112.9 | 279.5 | 110,449 |

Both 10,000-step controls finished with exit 1 and the expected single unproved
check. Their `unproved_status` records `memory=false`, `steps=true`, `time=true`;
the main attempts reached their step limits and the subsequent counterexample
attempt timed out. Both 100,000-step runs finished with exit 0 and GNATprove's
complete summary **all 107 checks proved**, including the selected runtime.
No run reached the external experiment timeout.

Z3 discharged the formerly unproved dynamic check at source column 345 using
10,738 normalized steps, and the static check at column 227 using 11,609. The
100,000 allowance was headroom, not the work actually required for those checks.
It was not a minimum-budget search. Single paired measurements show successful
runs finishing sooner than failing controls; they do not establish a general
speedup or a bound on other expressions. Memory use stayed far below this host's
available RAM. The evidence supports step exhaustion as the cause of these
specific failures.

## Decision and handoff

Retain production settings and the current language unchanged. For the broader
expression-capacity follow-up, try a modest step-budget adjustment before a proof
refactor. These two failures provide no reason to increase host RAM. Before
expanding admission, validate the current runtime and the intended larger fragment
across initialization, assignment, comparison, output and their compositions,
with matching universal/source proofs and report-capacity evidence. The historical
programs' success alone does not close that larger task.

The complete local record is
`.silver/linux-x86_64/expression-headroom-20261015T015646Z/`: runner copy, tool
versions, exact inputs, commands, all proof/session/cache outputs, 0.2-second
memory samples and results. Original Main SHA256 values are:

```text
dynamic: 3dfeee525b935212f90c161d4eadc87ac1707aa1f33f347bcc008b2ef75ffbae
static:  b401cbbcd28225baf1cec80d42eec780aed559740f0c7f8de3113f783a2d56a2
```

Independent read-only review checked the runner, input identity and final evidence.
No compiler, proof, script, test, catalogue or sample input changed; the completed
Admission Repairs native/Lean evidence remains applicable. Documentation received
link, consistency and whitespace checks. No full suite, Lean rebuild, independent
replay, macOS proof or hosted CI run was needed for this experiment record.

## Production adoption

Status: complete on Linux x86-64, authorized and completed 2026-10-15 against
baseline `dd26125318`.
The owner requested the 100,000-step production allowance following the experiment
and recommendation. Only the application proof command in `src/silver.adb` changes.
Compiler-development proof settings, Lean limits, solver selection, timeout/memory
options, evidence acceptance, source identity and language admission remain unchanged.

Validation covers the retained 64-leaf sources with current runtime snapshots,
supported application compilation and failure handling, full native compiler
proof/provenance, and the complete cached Lean check with a fresh axiom audit.
The driver is not an embedded Lean source-certificate input, but its bytes belong
to the complete evidence digest. No source-pin or theorem change is required.

The current-runtime confirmation preserved each retained Main and project while
copying all six runtime files from the current source. Each had fresh proof
sessions and caches. The dynamic and static cases both proved all 107 checks
(63 Main checks, 31 runtime proof checks and 13 flow checks), built, and passed
five combined execution probes. Their Main reports were 111,917 and 110,462 bytes.
The formerly failing checks still used 10,738 and 11,609 normalized Z3 steps.
Elapsed proof times were 54.180 and 41.094 seconds; sampled session RSS peaks were
1,253.0 and 1,107.1 MiB. These are supporting measurements, not a matched benchmark;
other validation could run concurrently. The exact command retains `--memlimit=0`,
but the observed internal `gnatwhy3` command uses `--memlimit 1000`; the flag alone
is not evidence of unlimited solver memory. Both sources still return membership
rejection (status 2), because the 16-leaf and 30-concatenation limits are unchanged.

The compiler rebuilt successfully. The full native audit proved **3,172 checks**
(572 flow and 2,600 proof), with 20 units and 313 entities; completed provenance
binds 2,408 inputs and 22 reports. It forced complete analysis with existing
sessions/cache available, not a cold proof experiment. All **18 focused tests**
passed: nine general driver tests and nine output-integrity tests, covering null
compilation, tool failure, rejected/missing/incomplete evidence and source drift.

Two real supported sample compilations, `string_assignment.adb` and
`common_expressions.adb`, passed the unchanged proof-report checks, built and
matched all five manifest execution cases. Their SARIF invocation records each
contain exactly one `--steps=100000`. The driver preserved each source byte-for-byte.
All 343 captured source/proof/script/test/sample/catalogue inputs were identical
before and after this focused validation. The full 307-test suite was not rerun
for this proof-option change; its earlier scope remains in Admission Repairs.

The complete cached Lean 4.34.1 check passed **252 modules**, with a fresh audit
of **56,876 declarations** using only `propext`, `Classical.choice` and `Quot.sound`.
It took 15.505 seconds (7.094 build, 5.236 audit), without a source-certificate
rebuild or independent kernel replay. The final input digest is:

```text
01b7c8ea2a9535a364b186d9f1830f87fb569fc0c8b7d541bb0d6631839123d2
```

Independent read-only review checked the one-line implementation change,
validation runner, actual commands, input identity and final results. The digest
and native provenance were revalidated against the final implementation. Only
documentation changed after validation. No broader language claim follows from
the exploratory programs; larger-expression admission remains separate work.

Evidence is under `.silver/linux-x86_64/step-budget-adoption-20261015T113937Z/`,
located by `tmp/step-budget-adoption-active.json`. Current-runtime probes are
under `.silver/linux-x86_64/step-budget-runtime-20261015T113750Z/`, located by
`tmp/step-budget-runtime-active.json`. Reports, exact inputs, commands, isolated
caches, successful program directories and prior evidence are preserved. Git
identifies the implementation commit containing this adoption record. macOS,
hosted CI and independent replay were outside scope.
