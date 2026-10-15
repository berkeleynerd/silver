# Expression Headroom

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
