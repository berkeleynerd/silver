# Lean cache preparation and interruptions, 2026-11-20

These are **old-runner preparation results**, not final assurance for the changed
#373 runner. The preparation used root revision `a412827d6c54f925cf4e55cac128eb4ef48647ad`
on Linux x86-64, with unchanged proof/language sources; integration code/tests
remain at reviewed `f0a773fbcb9eea9574b037812e888029b7f970cb`. The
[summary](preparation-summary.json) separates the interrupted initial run, completed
focused continuation, source/cache origins and timing scopes. Complete final
native and Lean/source/module/axiom audits remain outstanding. The actual focused
CLI probe was pending when these records were collected; the subsequent
[subprogram and unit checks](../focused-native/README.md) passed. No cold rebuild
or independent kernel replay is claimed.

## Seed and input provenance

[Cache preflight](cache-seed-preflight.json) identifies the preserved Linux
x86-64 **#370 partial/focused cache** donor and root destination. No ARM proof
objects were imported. The original [seed hash manifest](seed-file-hashes.json.gz)
retains 16,661 file entries. Its recorded copy/hash verification was not repeated
against the full donor or the now-active destination build during this archival
step. A seed permits reuse subject to normal Lake dependency checks; it is not
proof of final current-input assurance.

[Source comparison](seed-source-comparison.json) records **925 same, 73 changed
and 38 missing/new** proof-source files relative to that seed. This extraction
rechecked all 1,036 classifications against the seed's source hashes and current
tracked proof sources. It also rechecked all 1,142 source-input hashes captured
by the completed focused run against the unchanged root inputs.

The root and integration `lean` and `lake` binary hashes match both the recorded
seed preflight and focused evidence. Exact values and current root runner-script
hashes are in [the summary](preparation-summary.json). This verifies same-tool
reuse across these two x86 workspaces; it does not import another architecture's
proofs or infer applicability from a Git revision alone.

## Interrupted initial preparation

Managed run `20261120T151148-c537ca7f0c50` started at 15:11:49.169964 UTC,
using **one Lake worker and 22 threads per process**. The worker reduction was
recorded for previously observed dense-module memory demand alongside native
work. The [original wrapper output](lean-preparation.log) records successful
`Silver.OutputBodyLines0` and `Lines1` builds, with producer-reported durations
of **867 seconds** and **862 seconds**. These coarse module durations are not
precise wrapper timings or a controlled performance comparison.

The lead deliberately interrupted its own Lean process group with SIGINT after
the Lines1 completion boundary, retaining completed objects. The
[interruption record](lean-boundary-interruption.json) timestamps that action at
15:41:11.491269 UTC and records **32 completed artifact hashes**. The native group
was left untouched. The [checkpoint](boundary-checkpoint.json) records the
collected execution exit 130 and the reason: use existing focused targets to
parallelize the six remaining independent low-memory chunks while budgeting
dense consumers separately.

[Original managed events](original-run/events.jsonl.gz) end with
`phase_interrupted` and contain **no `finished` event**. The killed outer timing
wrapper produced no completion timing or exit file. No total wall, CPU or peak
RSS is invented for that interrupted attempt. The artifact hashes are the lead's
boundary snapshot; active destination build artifacts were not reread during
archival. Historical `original-run/previous-evidence/` files are preserved as the
run's prior-evidence backup, not as its successful result.

## Completed focused continuation

Managed run `20261120T154149-a6ad9b1bd8e1`, task `#373-lean-chunks`, completed
successfully with **eight actual Lake workers**, 22 threads per process and no
explicit per-process memory threshold. The request used automatic workers; the
actual grant reflected concurrent managed reservations. It selected only
`Silver.OutputBodyLines2` through `Lines7` and their focused import closure.

| Completed chunk | Producer-reported build seconds |
| --- | ---: |
| `Silver.OutputBodyLines2` | 1,210 |
| `Silver.OutputBodyLines3` | 1,310 |
| `Silver.OutputBodyLines4` | 1,318 |
| `Silver.OutputBodyLines5` | 1,239 |
| `Silver.OutputBodyLines6` | 1,265 |
| `Silver.OutputBodyLines7` | 1,294 |

The [wrapper output](lean-chunks.log) reports a successful **13-job focused
build**, **1,323.587 seconds** of build phase and **3.975 seconds** of fresh
focused audit. The audit covered **12 modules / 18,218 declarations**, with only
`propext`, `Classical.choice` and `Quot.sound` foundations. This is explicitly
partial validation. [Managed events](focused-run/events.jsonl.gz), the retained
[focused log](focused-run/lean-focused.log.gz) and
[focused evidence](focused-run/lean-focused-evidence.json.gz) retain exact selected
inputs, output hashes, tools, command settings and successful audits. The archived
focused-log hash matches that evidence's recorded `log_sha256`.

The outer [timing wrapper](timed_run.py) measured **1,346.6617900690035 seconds**,
with exit zero retained in [its timing](lean-chunks.timing.json) and
[exit record](lean-chunks.exit). The managed interval was **1,344.968356359 seconds**;
the proof evidence's elapsed field was **1,346.079 seconds**. These are distinct
measurement boundaries. The outer wrapper observed 7,288.5715 child user seconds,
366.056649 child system seconds and 1,737,212 KiB maximum child RSS. The latter
is not a simultaneous process-tree peak, host peak or full concurrent-workload
measurement. The wrapper captured an invoking stack soft limit of 16,384 KiB
and unlimited hard limit. No speedup is inferred by subtracting interrupted,
parallel, donor or different-source timings.

## Completed native incremental preparation

Managed run `20261120T151148-8deddffbf5cf`, task
`#373-native-cache-preparation`, completed successfully on the unchanged old
root runner. Its command was ordinary `dev.py prove --jobs 12`, with canonical
`--mode=all --prover=cvc5,z3,altergo --timeout=30` and normal root proof sessions
and lock-keyed file cache. It was neither `--full` nor `--cold`, and did not pass
GNATprove's force-all `-f` flag. The retained `--reason` explains the deliberate
12-worker allocation alongside Lean preparation and serial runner tests; this
old-runner record does not exercise the later proof-only `--resource-reason`
gate. At launch, the host exposed 22 CPUs and granted all 12 requested workers.
No actual cache-hit count or fresh-only solver-work claim is available.

The [native wrapper](native-preparation/wrapper.log.gz),
[managed log](native-preparation/native.log.gz),
[events](native-preparation/events.jsonl.gz),
[timing](native-preparation/wrapper-timing.json) and
[exit record](native-preparation/wrapper.exit) retain success and settings.
The native phase and wrapper exited zero. The managed finished event's normal
null `returncode` is accompanied by an explicit zero native-phase result; it is
not an unresolved process outcome.

The wrapper started **15:11:47.811475 UTC**, finished **18:10:21.491782 UTC** and
measured **10,713.478406580005 seconds**. Managed elapsed was
**10,712.555089664 seconds**. Child usage was 39,107.697326 user seconds,
529.42516 system seconds and 6,492,768 KiB maximum child RSS. The latter is not
a simultaneous process-tree or host peak. The wrapper recorded a 16,384 KiB
invoking stack soft limit and unlimited hard limit. These observations include
concurrent Lean and other work and do not establish a speedup or a benchmark.

The producer reported **all 19,726 checks proved**. The archived
[producer reports](native-preparation/producer-reports.tar.gz) contain all **78
expected unit `.spark` files**, plus `gnatprove.out`, SARIF and the inherited
`proof-inputs.json` discussed below. Expected unit names were derived from current
`src/` and generated Ada sources; none was missing or extra. All 78 reports
record `PROGRESS_PROOF` / `STOP_REASON_NONE`; their **1,751 flow** and **17,975
proof** records are successful, with no failed entries or skip/assume arrays.
The raw coverage maps contain 1,172 `all` and 80 `spec` entries. These inventory
statistics do not replace the complete auditor's semantic/source-bound coverage
and allowed-origin checks. The one SARIF invocation records successful exit zero
and matches the ledger's effective vendor command exactly.

[Report inventory](native-preparation/report-inventory.json) retains every
archived file's hash, per-unit counts and the separately archived
[25 prior reports](native-preparation/previous-reports.tar.gz). The
[prepared input record](native-preparation/prepared-inputs.json.gz) captures
**2,584 input hashes and 12 selected tool identities**. Assembly rechecked all
**153 non-tool input hashes**, all **12 selected tool binary hashes**, and the
**147 captured tracked inputs against `a412827d6c` Git blobs**. The old runner
and current proof/compiler source inputs therefore remain explicit; this is not
retrospective changed-runner provenance.

There is **no current `proof-provenance.json`** from this incremental run.
Its `proof-inputs.json` is byte-identical to the prior-reports backup, labels
itself `full`, and contains a different input inventory from this run's prepared
ledger record. It is preserved as inherited metadata, **not a current audit
manifest**. The successful raw report set is useful solver/cache preparation;
the final changed-runner complete native proof/report/provenance audit remains
required. The Lean cache donor's 16,661-file record above does not describe this
native session/file-cache origin, and no large compiler objects or solver-cache
contents are archived here.

## Launcher failures and active-run exclusions

The first [Lean launcher](lean-launcher-time-unavailable.log) and
[native launcher](native-launcher-time-unavailable.log) both exited **127** because
`/usr/bin/time` was unavailable. Their separate exit files are retained. These
were launcher failures before proof execution; they are not failed proof attempts.
The subsequent Python wrapper above supplied timing without that executable.

The replacement dense Lean preparation remained active when the native archival
continuation was assembled. Its outputs, events and running cache remain absent
here pending completion; the completed native preparation is now archived above.
No process was signaled, resumed or otherwise controlled by this evidence-collection
step. The successful focused
preparation does not finish the replacement complete run, establish final
changed-runner provenance, or complete deferred #381/#382 experiments. It uses
existing focused targets/reservations, not new scheduler implementation.

[Archive manifest](archive-manifest.json) retains source paths, byte counts and
SHA-256 hashes for every copied original; gzip records use deterministic mtime
zero. Previous-evidence backups remain explicitly historical. Assembly changed
only this preparation packet and integration scratch. No test/proof execution,
GitHub update, commit, Worca action or CLI memory update was performed. Selected
collector: GPT-6.1 Sol / High; independent runtime, token and cost telemetry were
unavailable.
