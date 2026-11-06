# Eight-chunk matched candidate — 2026-11-06

Run `20261106T142121-11c72098823f` passed the complete **4,915 line-certificate**
workload in eight modules on Linux x86-64 with Lean 4.34.1. The selected line
object families were absent before the timed run; common imports were reused.
The fresh focused audit covered **14 modules and 19,852 declarations**, using
only `propext`, `Classical.choice` and `Quot.sound`.

Frozen governed source is `0f3076d3da`, identical to author candidate
`ec2c6f474b` in the captured implementation inputs. The post-run documentation
head was `18e471409e`. Independent
[source/tool inspection](source-input-verification.json) matched 745 captured
shared inputs, all 638 workspace module sources (including 36 generated
candidates), and both executable hashes to current bytes and immutable Git
blobs. All **630 common `.olean` hashes** match both this case's
[preparation record](measurement-preparation.json.gz) and the four-control
preparation. All 4,915 ordered declaration texts also match the immutable
four-chunk baseline. No deduplication occurred.

| Boundary | Seconds |
| --- | ---: |
| External wrapper | 1341.952163 |
| Runner reported elapsed | 1338.216 |
| Managed run | 1335.617132 |
| Lake build phase | 1318.594 |
| Fresh focused audit | 7.655 |
| Reaped command-tree user CPU | 8300.566250 |
| Reaped command-tree system CPU | 539.627034 |

The [retained wrapper](observe_lean.py) measures the before/after difference in
`resource.getrusage(resource.RUSAGE_CHILDREN)` after reaping the command. CPU
totals include generation, build and audit; they are not line-module-only
costs. Its post-run bytes are retained and indexed; the launch record did not
capture a wrapper source hash.

The run reserved **eight Lake workers**, selected **12 threads per Lean process
automatically**, and used a **6144 MiB per-process** Lean allowance. Sampled
peak summed RSS was **8,124,977,152 bytes**; minimum host available memory was
**28,993,937,408 bytes**. No 4 GiB host-available pause occurred. Summed RSS can
count shared pages and approximately five-second samples can miss activity.
The Lean threshold is neither an aggregate budget nor an OS hard cap.

[Summary](summary.json) retains commands, timing boundaries, resource policy,
cache preparation and scope. [Artifact hashes](artifacts-index.json) bind the
immutable terminal ledger/log/evidence, completed observations, source wrapper
and post-terminal inventories. The [cache seed](lean-cache-seed.json) records
the independent idle-workspace copy. No compiled objects were copied here.

The lead reported no competing proof/native/test jobs. Ordinary source editing
and static review overlapped, as did 8.109 seconds of post-terminal retention
and read-only hashing in the idle four-control workspace. The matched cases ran
sequentially. This packet adds no validation, test or review run. Its retention
and hashing took 2.137 seconds; GPT-6.1 Sol / Extra High was selected, runtime
settings were not independently confirmed, and token/cost measurements are
unavailable. All requested comparisons passed without rework.

The lead selected eight chunks from this single ordered pair: wrapper wall time
fell **32.96%**, with **21.88% more command-tree CPU** and **45.39% higher sampled
summed RSS**. See the [comparison](../comparison.json) and
[independent review](../../../reviews/review-lean-incremental-throughput-20261106.md).
The observation has no replicate/variance estimate or independently controlled
host load. Aggregator/reconstruction and whole-project costs are outside the
measurement. Complete final integrated source/kernel/native assurance remains
pending; this focused result cannot replace it.
