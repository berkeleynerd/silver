# Four-chunk matched control — 2026-11-06

Run `20261106T134724-a836b1157415` passed the complete **4,915 line-certificate**
workload in four modules on Linux x86-64 with Lean 4.34.1. All four selected
object families were removed before the timed run; common imports were reused.
The fresh focused audit covered **10 modules and 19,232 declarations**, using
only `propext`, `Classical.choice` and `Quot.sound`.

The frozen source baseline is `c062d5253e`. The independent
[source/tool comparison](source-input-verification.json) matched 745 captured
shared inputs, all 634 workspace module sources (including 32 generated
candidates), and both executable hashes against current bytes and immutable
Git blobs. All **630 common `.olean` hashes** still match the
[preparation record](measurement-preparation.json.gz). No deduplication occurred.

| Boundary | Seconds |
| --- | ---: |
| External wrapper | 2001.802817 |
| Runner reported elapsed | 1999.863 |
| Managed run | 1996.972412 |
| Lake build phase | 1979.452 |
| Fresh focused audit | 7.757 |
| Reaped command-tree user CPU | 6845.365969 |
| Reaped command-tree system CPU | 407.662273 |

The [retained wrapper](observe_lean.py) obtains CPU counters from
`resource.getrusage(resource.RUSAGE_CHILDREN)` before launch and after reaping
the command. These totals include generation, build and audit; they are not
line-module-only CPU costs. The original launch record did not capture the
wrapper source hash; its post-run bytes are retained and indexed here.

The run reserved **four Lake workers**, selected **12 threads per Lean process
automatically**, and used a **6144 MiB per-process** Lean allowance. Sampled
peak summed RSS was **5,588,283,392 bytes**; minimum host available memory was
**29,645,819,904 bytes**. No 4 GiB host-available pause occurred. Summed RSS can
count shared pages and approximately five-second samples can miss activity.
The Lean threshold is neither an aggregate budget nor an OS hard cap.

[Summary](summary.json) retains commands, timing boundaries, resource policy,
cache preparation and scope. [Artifact hashes](artifacts-index.json) bind the
finished immutable ledger/log/evidence, completed observations, source wrapper
and post-terminal inventories. The [cache seed](lean-cache-seed.json) records
the independent idle-workspace copy. No compiled objects were copied here.

The lead reported no competing proof jobs. Cheap eight-candidate generation
and static inspection occurred separately while this control ran. Retention
and read-only hashing of this now-idle workspace overlap the eight-case run,
as requested; no active eight-case output or cache is inspected. This packet
contains no new validation, test or review run and no performance-improvement
claim. Reconstruction, aggregator and whole-project costs are outside this
focused measurement.
