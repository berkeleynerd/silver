# Final current-runner assurance, 2026-11-20

**The final native build invocation, complete native proof/report/provenance audit
and complete Lean/source/module/axiom check passed on the reviewed runner.**
The root validated at `8836c38bac64de991acc56c8f683ea65ae5912e5` with code, tests and proof/compiler sources
matching reviewed implementation `f0a773fbcb9eea9574b037812e888029b7f970cb`.
[Structured results](final-summary.json) retain the exact validation-root revision,
run IDs, settings and timing scopes. The unrelated local session-memory changes
were preserved and are outside captured proof inputs.

These are final changed-runner results, distinct from the
[old-runner preparation](../preparation/README.md). The
[actual canonical focused CLI checks](../focused-native/README.md) and
[complete regression accounting](../README.md) supply their separate scopes:
282 fresh affected tests plus 475 reviewed retained passes cover all 757 current
IDs. Closing evidence applicability and review are recorded by the delivery lead;
this packet supplies results without claiming a merge or a later review outcome.

| Check | Managed run | Result | Managed seconds | Wrapper seconds |
| --- | --- | --- | ---: | ---: |
| Native build invocation | `20261120T184456-c31fb2e1ef2e` | Both existing binaries up to date | 2.436460362 | 3.1956054430047516 |
| Complete Lean check | `20261120T184511-73f46c783731` | 1,035 modules / 166,332 declarations; fresh audit passed | 26.068828777 | 26.960301038008765 |
| Complete native audit | `20261120T184557-91d29a88ed8f` | 78 units / 1,252 entities / 19,726 checks; report and provenance audits passed | 47.259882843 | 48.245459934012615 |

All three ran natively on **Linux x86-64**, machine `silver`, with **22 automatically allocated
workers** and no explicit allocation reduction.
Lean also selected automatic **22 process threads**, with no explicit per-process
memory threshold. Each wrapper recorded an invoking stack soft limit of
**16,384 KiB** and unlimited hard limit. Wrapper exit codes were zero. Managed
successful context-manager events have their normal null `returncode`; explicit
native/build phase events and Lean build/audit results record zero.

## Native build and executable identities

The [build log](build/native.log.gz), [events](build/events.jsonl.gz),
[wrapper](build/wrapper.log.gz) and [timing](build/wrapper.timing.json) retain a
fresh `dev.py build` invocation. GPRbuild reported both `silver` and
`silver_image_adapter` **up to date**. No recompilation is claimed. The actual
final executable identities available for regression applicability review are:

| Binary | Bytes | SHA-256 |
| --- | ---: | --- |
| `silver` | 2,957,352 | `b27ae765f286949d3814810d25d9fe6a2dcbbdd058830ea628064207df67ffe7` |
| `silver_image_adapter` | 2,014,816 | `4076e918b5e9cd2c1da29e5dd562ef6163aab6a62aabcce72381f4d05f80b2f3` |

Paths and modification timestamps are retained in the structured summary. The final build and full-proof preflight records captured the same source/setup
inventory.
No new sample route or executable-output test was run by this archival step.

## Complete warm native audit

The command was `dev.py prove --full`, with the canonical compiler solver/budget
options, including `--prover=cvc5,z3,altergo --timeout=30`. It forced all compiler
units with `-U` and `-f` and reused existing sessions and the normal lock-keyed
file cache. Its manifest records both `sessions_present: true` and
`cache_entries_present: true`. This is a **complete warm forced audit**, not a
cold solve. Actual solver cache-hit counts were not observed; no fresh-only solver
work or speedup is claimed.

The [native log](native/native.log.gz), [events](native/events.jsonl.gz),
[wrapper](native/wrapper.log.gz), [timing](native/wrapper.timing.json) and
[producer archive](native/producer-reports.tar.gz) retain the successful run.
Unlike incremental preparation's inherited metadata, this archive contains a
**current complete `proof-provenance.json` and current `proof-inputs.json`**.
The provenance inventory and managed prepared inputs agree exactly; both bind
the same 12 selected tool identities. All **80 report hashes** in the complete
manifest were rechecked against both the retained managed copies and root outputs.
The one successful SARIF invocation matches the manifest command exactly.

All 78 expected source units have reports, with no missing/extra unit. The raw
reports record successful analysis and no skipped proof/flow or assumed checks;
**1,751 flow + 17,975 proof = 19,726 checks** passed. The 1,252 entity coverage
entries comprise 1,172 `all` and 80 `spec` entries, interpreted through the complete
source-bound auditor and its admitted origin rules. The actual managed audit
completed after proof generation; raw counts alone are not used as its substitute.
The [report inventory](native/report-inventory.json) binds all 82 archived report
and metadata files. Assembly additionally rechecked **all 2,585 captured native
input hashes** and all **12 selected tool binary hashes** against current bytes.

The native wrapper ran **18:45:57.169428–18:46:45.414860 UTC**. Its child usage
was 79.132029 user seconds, 85.930924 system seconds and 665,908 KiB maximum child
RSS. The last value is not a simultaneous process-tree peak.

## Complete cached Lean check and fresh audit

The command was `check_lean.py --provenance` with automatic worker/thread
allocation, complete scope and incremental mode. The
[proof log](lean/lean-proof.log.gz), [evidence](lean/lean-evidence.json.gz),
[events](lean/events.jsonl.gz), [wrapper](lean/wrapper.log.gz) and
[timing](lean/wrapper.timing.json) retain the result. The cached Lake build took
**4.840 seconds**, followed by a **7.126-second fresh complete audit** of
**1,035 unique modules / 166,332 declarations** with foundations limited to
`propext`, `Classical.choice` and `Quot.sound`.

The evidence's module set matches the fresh audit's module lines exactly.
Lake's build output includes replayed cached diagnostics; that is ordinary cached
build behavior, not optional independent kernel replay. The recorded mode is
incremental, `clean_build: false` and `kernel_recheck: null`. The proof evidence
retains **1,143 source-input hashes**, **1,037 proof-workspace input hashes** and
**6,202 output artifact hashes**, with successful source/module/provenance checks.
Root and managed final log/evidence copies matched byte-for-byte, and the log hash
matches its proof manifest. No cold rebuild or independent kernel replay was run.

The wrapper ran **18:45:11.470847–18:45:38.431134 UTC**. The proof evidence's
elapsed field was **26.592 seconds**, distinct from managed and wrapper intervals.
Child usage was 19.610174 user seconds, 13.024258 system seconds and 2,374,408 KiB
maximum child RSS. This is not a combined-workload or host-memory peak. Large
compiled Lean objects were not copied or rehashed again by the collector; their
recorded provenance checks belong to the successful completed run.

## Retained inputs and archive verification

[Prepared source/tool identities](prepared-source-tool-identities.json.gz)
retain the actual native/build prepared inventories and Lean tool identities.
The exact union of authored/setup input bytes is in
[source inputs](source-inputs.tar.gz): **1,152 files**, of which **1,146 tracked
inputs were independently matched against the reviewed `f0a773fbcb` Git blobs**.
The other six are generated/local installation inputs. The
[workspace inputs](workspace-inputs.tar.gz) retain all **1,037 captured proof
workspace input files**. Their hashes match the final manifests; the
[source inventory](source-snapshot-inventory.json) binds every archived member.

[Archive manifest](archive-manifest.json) records hashes, sizes and source paths
for each copied raw record; tar metadata and gzip mtime are normalized. All
archive hashes and tar member bytes were verified. Preparation and final records
retain their own run settings and timings; comparing their different cache states
and scopes would not establish a controlled performance gain.

This was read-only evidence collection apart from owned archive/scratch writes.
No root source/tool/cache/job modification, proof/test invocation, GitHub action,
Worca run, commit or CLI memory update was performed by the collector. Selected
role: GPT-6.1 Sol / High; independent runtime model/effort and token/cost telemetry
were unavailable.
