# Serialized complete cached checkpoint — passed

Run `20261116T233445-6dce1a7dbb80` checked the frozen implementation
`d60bd8a899fcc66e5ef40112423b7f94b2e4becc` on Linux ARM64. The complete
incremental build and a fresh whole-project axiom audit both passed. The actual
audit, manifest, shared project and proof-workspace inventories agree exactly:
**1,009 modules, 162,274 declarations**, with only
`[propext, Classical.choice, Quot.sound]`. No proof, linter or source-correspondence
diagnostic occurred. The fresh audit covers all 40 generated candidate modules
and all 32 authoritative embedded sources; the source link still names the
repository's actual `src/` tree.

The [exact supervised command](run-complete.py) was
`python3 scripts/check_lean.py --workers 1 --memory-mb 8192 --provenance --task '#391'`,
with the recorded rationale. The lead authorized one worker after the
[previous two-worker attempt](../attempt-2/README.md) measured dense candidate
overlap above the agreed aggregate RSS guard. Threads remained automatic:
**12 threads per Lean process** on 12 available CPUs. The 8192 MiB threshold is
periodic and per process; the two-second 10 GiB aggregate RSS-tree and 1.5 GiB
host `MemAvailable` guards are monitoring limits, not hard OS caps. RSS can count
shared pages more than once. There was no native or regression job overlap,
source edit, repeated focused check, clean build or independent kernel replay.

Across 1,511 samples, peak process-tree RSS was **8.601334 GiB** and minimum
host available memory was **7.725693 GiB**. Neither guard fired. Build elapsed
time was **3,020.479 seconds**, fresh audit time **2.133 seconds**, manifest
elapsed time **3,029.716 seconds**, and original supervised terminal time
**3,029.938 seconds**. The run began on November 16 and finished at
`2026-11-17T00:25:15.552639+00:00`. The log contains 290 successful Silver build
entries; Lake's final `1048/1048` is scheduler progress, not the module-coverage
count. Own-process argument/module attribution is retained in
[resources.jsonl](resources.jsonl).

Original tool session **85539** collected terminal **exit 0**. The managed run
reports success and `active: false`; the original process group has exited and
the worker reservation was released. The parent was promptly notified and owns
the subsequent regression suite, final integration and publication.

[verify-packet.py](verify-packet.py) performs read-only inspection and copies
the completed canonical evidence. Its [summary](verification-summary.json)
verifies every manifest hash: **1,116 repository inputs, 1,011 workspace inputs,
6,046 compiled artifacts, two Lean/Lake executables**, and the exact log. All
captured repository bytes match the frozen commit's Git blobs. The input digest
is `b6f83b0aa0395d585f1e97004eda9d7884b7abdf4d1cec79fbf05a3d766d67a0`.
All 998 pre-run primary objects remain present: 983 are byte-identical and 15
were recompiled. Eleven previously missing objects were rebuilt, bringing the
inventory to 1,009. No cache was cleared or restored by guessing applicability.
[preflight.json](preflight.json) retains the unchanged embedded-source check
against the previous complete success and the reuse of the accepted focused
Domain gate. The exact final manifest, log, original terminal, launcher,
managed events and managed summary are retained alongside this record. Runtime
lease files are deliberately omitted.

The inherited subthread model/effort and independent runtime identity remain
unavailable; no saved default is presented as a confirmed live setting. The
source repair was reviewed by the parent-assigned Astra Max reviewer. Actual
native timings and resource samples are above; whole-subthread time, token and
monetary-cost totals are unavailable. Earlier interruptions remain retained as
interruptions. This completes the required cached Lean checkpoint for these
exact inputs; it does not claim an uncached build or independent kernel replay.
No CLI memory update, push, merge or work on #373 was performed here.
