# Complete cached Lean refresh for #391

## Final result — passed on the frozen repaired implementation

The [serialized complete checkpoint](attempt-3/README.md) passed on
`d60bd8a899fcc66e5ef40112423b7f94b2e4becc` in managed run
`20261116T233445-6dce1a7dbb80`. All **1,009 modules and 162,274 declarations**
were freshly audited with only `[propext, Classical.choice, Quot.sound]`.
All input, tool, workspace, artifact and log hashes were independently inspected;
all 40 generated candidates and 32 authoritative sources are covered. Original
terminal `85539` returned 0 and the reservation was released. This is a cached
complete build and fresh audit, with no clean build or independent replay.

After the first interruption and the successful Domain-focused gate below,
the [two-worker complete attempt](attempt-2/README.md) on the final repaired
implementation hit the measured aggregate RSS guard without a proof diagnostic.
All 998 pre-run primary objects survived unchanged. The lead authorized
serialization based on that observed overlap. The final run used one worker,
automatic 12 threads and the retained 8192 MiB periodic per-process threshold;
peak sampled tree RSS was 8.601334 GiB and minimum host available memory was
7.725693 GiB. Neither retained guard fired. Full details and provenance are in
[the successful packet](attempt-3/README.md). The earlier records below describe
their historical snapshots and results.

## First attempt — retained interruption

The frozen implementation was `2288af60031763d808b8cd1e024f8fcf7cdc7135`.
The retained workspace was switched to that detached commit with the unrelated
`tmp/` and all caches preserved. The managed summary showed no active run.
[preflight.json](preflight.json) verifies all 1,116 captured repository inputs
against that commit's Git blobs, all 1,009 project modules, all 1,009 primary
objects and the 32 unchanged authoritative embedded sources. Lean/Lake bytes
matched the retained focused evidence. Captured changes from the previous
complete success were the seven bounded Lean files and the two auditors plus
the report-specification comment; no embedded source changed.

The complete cached command, without `--target`, `--clean` or `--replay`, was
`python3 scripts/check_lean.py --memory-mb 8192 --provenance --task '#391'`, with
the exact rationale and supervision retained in
[run-complete.py](run-complete.py). Automatic allocation was actually 12 Lake
workers and 12 threads per Lean process on Linux ARM64. The 8192 MiB setting is
a periodic per-process threshold. Two-second monitoring enforced the agreed
10 GiB aggregate RSS-tree/1.5 GiB host `MemAvailable` guard limits; none is a hard
OS cap, and RSS can count shared pages repeatedly.

Managed run `20261116T225232-a8d95d91b22a` was **interrupted**, not passed.
Its sole build diagnostic was the ambiguous `Expressions` open at
`ComposeBooleanDeclarationMeaning.lean:13:15`, exposed by the Boolean native
module's new public import. At 12.018 seconds the aggregate sampled RSS reached
11.224838 GiB while host `MemAvailable` was 9.687332 GiB; the largest sampled
Lean child was 1.446838 GiB. The agreed RSS guard sent SIGINT to the original
process group. Tool session `98276` collected its original terminal: runner
exit -2, supervising launcher exit 130 after 12.135 seconds. No group member
remained. The full axiom/module audit did not run.

Nineteen jobs completed before interruption. Lake removed 13 original target
objects when starting interrupted recompilation; their exact list is retained,
and all 996 surviving primary objects were byte-identical to preflight. No
manual deletion, object-restoration guess, clean build or automatic retry was
performed. The missing targets can be rebuilt normally. Exact command/input
events, original terminal, managed log, per-process samples and diagnostics are
in [attempt-1](attempt-1/), particularly
[inspection-summary.json](attempt-1/inspection-summary.json) and
[build-diagnostics.json](attempt-1/build-diagnostics.json).

The subthread's inherited model/effort and runtime identity remain independently
unavailable; no setting is inferred from configuration. The parent assigned
the unresolved import question to an Astra Max reviewer. That diagnosis led to
the explicitly authorized two-file move described in
[the dated repair](../README.md#2026-11-16-follow-up--restore-the-boolean-modules-import-boundary).
[import-repair-preservation.json](import-repair-preservation.json) verifies its
exact scope. Subthread-wide time/token/cost measurements are unavailable;
actual native timings and resource samples are retained above.

The native full audit owned the worker allocation at that handoff. After its
release, the repaired `Silver.ComposeBooleanDeclarationDomain` target passed
at two workers/default threads/8192 MiB, selected in response to the observed
12-worker aggregate guard. The [focused packet](domain-focused/README.md)
records its exact scope and fresh audit. At that historical handoff, a complete
cached refresh remained required after the native repair's final-source
integration. The final success is recorded above.
