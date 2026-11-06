# Complete integrated Lean checkpoint — 2026-11-06

Managed Linux x86-64 run `20261106T150342-2526cc1a0ef4` passed the ordinary cached complete build
and freshly executed whole-project import/axiom audit on governed source
`524dbfbd4084c79f7048b1710dd3a7af76affe59`. The fresh audit covers **638 project modules
and 128,514 declarations**, with only `propext`, `Classical.choice`
and `Quot.sound` as foundations. It checks the final output reconstruction and
dependent actual-source bridges after adopting eight stable content buckets.

Independent [source/tool inspection](source-input-verification.json) matched
all **745 captured shared inputs**, **36 generated candidates**,
and all 638 workspace module sources against the captured records, current
frozen bytes and immutable governed Git blobs. Both executable hashes match
their captured identities.
The [workspace inventory](workspace-inputs-sha256.json.gz) retains 640 source/build-input
hashes. Current `src`, `scripts`, `proof` and `tests` trees match the governed
source; the retention documentation head is `2f3aaa0de9c986a1d01ea7360c8edbd171d431d2`. The wrapper
did not record its launch checkout commit. Generated sources retain 4,915
ordered occurrences and 3,278 unique exact-text line certificates.

| Timing boundary | Seconds |
| --- | ---: |
| External observed wrapper | 3438.193843690 |
| Checker reported elapsed | 3437.293 |
| Managed run | 3434.203343898 |
| Lake build phase | 3413.676 |
| Fresh audit phase | 10.601 |
| Reaped command-tree user CPU | 10249.006576 |
| Reaped command-tree system CPU | 674.929818 |

[Summary](summary.json) retains every Lake-formatted rebuilt-module duration,
exact command and timing boundary. CPU counters cover the entire reaped managed
command tree, including generation/build/audit. This is an ordinary cached
checkpoint, not a clean build, independent kernel replay or matched speedup
experiment; the earlier controlled four/eight measurement has its own inputs.

Lake workers and threads per Lean process both selected 12 automatically.
The 24576 MiB memory allowance is a periodically checked per-process threshold,
not an aggregate or OS hard cap. Sampled peak summed RSS was
**24,852,279,296 bytes**, and minimum host available memory was
**9,174,548,480 bytes**. The 4 GiB available-memory pause guard
did not fire. Summed RSS can double-count shared pages; approximately five-second
samples can miss activity and are not exact physical peak measurements.

[Artifact hashes](artifacts-index.json) bind the immutable terminal ledger,
result, proof log, completed observations and retained wrapper source. Its
post-run bytes match the earlier retained wrapper; no launch-time source hash
was captured. The runner did not select detailed compiled-object provenance;
the independent source inventory is not object attestation.

The [original idle-cache seed](../eight-candidate/lean-cache-seed.json) and
[matched eight case](../eight-candidate/README.md) record prior reuse in this
workspace. The final normal runner regenerated the content buckets, resolved
dependencies and freshly audited the complete project. Retention copied no
compiled objects or caches. [Native proof/build](../native/README.md) and
[90 scoped test methods plus the edit pilot](../tests/README.md) retain their own
applicability and limitations; no whole application suite, macOS or hosted-CI
result is added here.

Retention selected GPT-6.1 Sol / Extra High; runtime confirmation and token/cost
measurements are unavailable. Terminal packet construction and source/tool
hashing took 2.247 seconds, excluding preparation/waiting.
Retention launched no validation or review run.
