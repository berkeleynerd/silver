# Complete Lean checkpoint: retained failed run

Run `20261106T230229-b9a860723df5` finished **failed** on native Linux x86_64
at `2026-11-07T01:36:31.875219+00:00`. Build elapsed time was 9,229.662 s;
managed elapsed time was 9,238.583973006 s. It requested the complete project
with four Lake workers, twelve threads per Lean process, and 24,576 MiB per
process. There was no clean build or independent kernel replay.

The build did not reach the fresh module/axiom audit. This packet establishes
no successful complete source correspondence, audited declaration count, or
audited axiom set. The verified project inventory contains **655 modules**;
earlier preparation records that mention 654 are not this final inventory.

Three modules failed:

| Module | Actual failure |
| --- | --- |
| `Silver.OutputBodyCertificate` | External global OOM killed the stopped reconstruction; Lake reported exit 137. |
| `Silver.PredicateNativeShapeCandidate` | The root coordinator explicitly authorized terminating this stopped 8.54 GiB heap to recover enough memory for other scheduled work. Lake reported exit 137. |
| `Silver.PredicateFlags` | Missing Boolean-array assignment cases in `Flag.source` at line 24 and `basic_flags` at line 55. |

The Flags diagnostics appeared during its earlier build. The monitoring
subthread missed them while following changing log tails and reported them
when scanning the complete terminal log. The log and terminal managed event
retain those diagnostics without reclassifying the failed run.

All 175 unique successful module builds visible in this log are inventoried
in [the result](failed-result.json). They include the three changed output
line buckets, Boolean-array helper/source checks, ScalarBody, Flow, Body and
NativeHelpers candidates, later model/example work, and
`ComposeBooleanDeclarationCandidate`. Lake timings include recorded pauses;
they must not be summed as independent wall time. Completed objects remain in
the original workspace. Every paused original child was resumed to success,
apart from the two explicitly recorded process terminations above; no stopped
original process remains.

At terminal snapshot HEAD `689aef86bf9a0b33d0fcf13dee212e069d07cb64`, all
762 captured source/proof/tooling inputs matched both filesystem and Git bytes,
both captured tool hashes matched, and all 657 proof-workspace input hashes
matched the inventory captured during the active run (its exact baseline and
terminal times are in the result). The non-provenance runner did not separately
persist its internal pre-build workspace inventory. Shared and workspace inventories matched exactly, including
the authoritative `src` link. The test-only change in `tests/test_silver.py`
was outside this Lean input capture. Later repairs are separate inputs.

Retained records:

- [Result manifest](failed-result.json.gz) and [diagnosis](failure-diagnostic.json.gz).
- [Full build log](failed-lean-proof.log.gz) and [managed events](failed-run-events.jsonl.gz).
- [Captured-input correspondence](input-correspondence.json.gz) and
  [workspace inventory](workspace-input-inventory.json.gz).
- [Exact resource actions](resource-events.jsonl.gz),
  [five-second samples after the emergency](resource-samples.jsonl.gz), and
  [kernel OOM log](oom-kernel-tail.log.gz).
- [Final monitor policy](monitor-policy.json) and
  [monitor utility](resource-monitor.py). Earlier sampling used inline
  versions; resource events retain actual actions and the policy changes.

The OOM kernel log uses host PIDs. Its killed Lean PID 26541 and
14,225,856 KiB anonymous RSS correspond to the reconstruction observed as
container PID 218676; Lake separately identifies that module's exit 137.
Stopping a process retains its heap. Transient garbage-collection lows did
not establish enough capacity for concurrent dense proofs, so the coordinator
harvested one dense source job at a time, then allowed two model/example jobs
after dense work and regression reservations cleared.

Ordinary local Lake objects, sidecars, traces, and earlier transfers retain
the cache attribution and trusted-boundary limits in the parent
[inventory](../README.md), including the later
[fixed-word transfer](../shared-type-word/cache-import-fixed-word.json).
This subthread introduced no cache transfer, trace rewrite, proof option
change, or successful-run restart. Successful builds inside this failed run
remain reusable subject to ordinary dependency validation; they do not form
a complete audit.

The next smallest check is to repair and focused-check `PredicateFlags`, then
run the root-authorized complete incremental checkpoint with one Lake worker,
retaining `-j12`, `-M24576`, source bytes and successful objects. That retry
must rebuild the failed and blocked source chain and freshly audit the whole
actual project. No new expensive run was started by this subthread.
