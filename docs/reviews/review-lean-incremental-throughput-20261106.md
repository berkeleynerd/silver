# Incremental Lean throughput review — 2026-11-06

Complete Linux Lean/source/module/axiom acceptance, applicable native proof/build
evidence and all 90 focused methods are confirmed for governed source
`524dbfbd4084c79f7048b1710dd3a7af76affe59`. No unresolved review finding or missing
required validation remains for #327/#328. The eight-chunk and stable-content
adoption is supported within the measurement limits below; implementation merge
remains an owner decision. Terminal confirmation supersedes the earlier pending
statuses, which remain as historical review boundaries.

## Initial static boundary — 13:52 UTC

No material static finding remains in the eight-chunk candidate for
[#327](https://github.com/berkeleynerd/silver/issues/327). It is ready for the
planned matched benchmark. Runtime acceptance, performance usefulness and final
integrated assurance remain pending; this review does not establish adoption.

## Scope and exact inputs

The [authorized scope](../lean-incremental-throughput.md) was published through
merged [PR #329](https://github.com/berkeleynerd/silver/pull/329), main commit
`53ef5685a2`. The lead reports #327 In Progress and #328 Ready; the planning
document's initial Backlog wording records an earlier boundary.

- Baseline: `c062d5253e73ad066bf0309eeee505f51f8b0860`.
- Frozen candidate: `ec2c6f474b8516f1fc74bcf08fdd0ee47d97b765`, in
  `tmp/lean-eight-chunks`.
- Integration copy: `0f3076d3daeb5b4baa886761a9c72d1e7a02163b`, in
  `tmp/lean-chunk-reuse`. Independent comparison found no differences in
  `proof/`, `scripts/`, `src/` or `tests/` from the frozen candidate.

Review covered the changed generator, runner, nine generated Lean files and two
test files, their staging/audit consumers, and the applicable authorization and
assurance requirements. No production file was edited and no test, Lean, build
or benchmark job was launched by this reviewer.

## Static preservation and coverage

Independent extraction confirms all **4,915** original declaration texts are
byte-identical, with indices and order exactly `0..4914`. The eight chunk counts
are **614, 614, 615, 614, 614, 615, 614, 615**. No deduplication or content-based
naming is introduced. The entire aggregator differs only by four added imports;
reconstruction through the final source/values/lexer theorems and namespace end
is byte-identical. Literal text, tokens, newline presence and join witnesses
are preserved.

The generator uses eight configured modules and divides by their count. The
runner expands generated candidates from **32 to 36**, retaining the same 28
certificate roots. Existing complete pending-output reads before publication,
unchanged-byte timestamp preservation, protected source bindings, source/input
stability checks and fresh module/axiom auditing remain intact. The project
inventory grows from **634 to 638** Lean modules, adding exactly
`OutputBodyLines4` through `OutputBodyLines7`, with no removals or new
authoritative-source dependency in line leaves.

Source-policy tests require agreement between the generator and runner's eight
paths. Ordered parity, staging, missing-output, cleanup, mocked runner and audit
fixtures use the configured inventory. The tiny native fixture now supplies
eight entries and correctly moves the CRLF-affected chunk from index 3 to 6;
its assertions retain reuse, binding/aggregator invalidation and fresh audit
coverage. This is inspection of test coverage, not a passing execution claim.

All nine hashes in the author's scratch parity record were independently
corroborated. Its reconstruction digest excludes the final namespace terminator;
both that slice and the complete slice including the terminator match baseline.

## Remaining evidence and round record

The lead owns the active four-chunk control `20261106T134724-a836b1157415`, the
eight-chunk comparison, focused test execution and adoption decision. The final
combined reconstruction/source/module/axiom checkpoint remains required.
[#328](https://github.com/berkeleynerd/silver/issues/328) remains a later pilot;
no implementation for it was reviewed.

Selected reviewer: **GPT-6 Astra / Extra High**; runtime settings were not
independently exposed. Observed clock interval: **13:49:03–13:52:35 UTC**, after
initial reads, including coordination; this is not active-compute time.
Token/cost measurements are unavailable. No CLI recall was updated.

## Matched measurement and adoption assessment — 14:47 UTC

Both focused runs finished successfully: four-chunk
`20261106T134724-a836b1157415` at baseline `c062d5253e`, and eight-chunk
`20261106T142121-11c72098823f` with reviewed governed bytes `0f3076d3da`
(`ec2c6f474b`). Review inputs were the retained
[four-control packet](../evidence/lean-incremental-throughput-20261106/four-control/README.md)
and the eight-run immutable ledger, terminal log/evidence and observations,
now retained in the
[eight-candidate packet](../evidence/lean-incremental-throughput-20261106/eight-candidate/summary.json).
The retained [comparison](../evidence/lean-incremental-throughput-20261106/comparison.json)
agrees with the independently recalculated metrics and controls below.

| Observed boundary | Four chunks | Eight chunks |
| --- | ---: | ---: |
| External wrapper wall seconds | 2001.802817 | 1341.952163 |
| Lake build seconds | 1979.452 | 1318.594 |
| Reaped command-tree user + system CPU seconds | 7253.028242 | 8840.193284 |
| Sampled peak summed RSS, GiB | 5.204494 | 7.566975 |

Independent recalculation gives **32.96% less wrapper wall time**, **33.39% less
build wall time**, **21.88% more CPU time** and **45.39% higher sampled peak RSS**.
CPU covers generation, build and audit, not only the line proofs. Approximately
five-second RSS samples may miss peaks and count shared pages more than once.

The records agree on Linux x86-64 host `codex-silver`, Lean 4.34.1 and executable
hashes, 12 available CPUs, automatically selected 12 threads per process and
6144 MiB per-process allowance. Four versus eight Lake workers is the intended
comparison control. All **630 initial common-object hashes** match exactly.
Both workspaces independently copied the same idle completed parent cache;
selected line object families were removed, and logs show all four/eight leaves
rebuilt. The 745 captured shared inputs differ only in the reviewed generator
and runner. The earlier static review establishes the same 4,915 declaration
texts and order. Fresh focused audits passed over all selected leaves and six
common modules with the existing three foundations.

The runs were sequential. The lead reports no competing proof jobs; cheap
generation/editing/static inspection and idle-workspace evidence retention and
hashing overlap are disclosed. Both monitors remained unpaused, with sampled
host available memory never below 27.0 GiB. The retained observation wrappers
are byte-identical; their source hashes were not captured at launch.

This single sequential pair supports the lead's eight-chunk adoption for the
measured workload and observed host headroom. The roughly eleven-minute wall
saving is useful despite the CPU/memory tradeoff. No identified missing control
warrants another expensive comparison. There is no repeatability estimate,
randomized-order result or measured aggregator/reconstruction/whole-project
speedup. Final combined reconstruction/source/module/axiom validation and
applicable regressions remain required. The lead reports #328 active in a
separate worktree; no #328 implementation is reviewed here.

This continuation selected **GPT-6 Astra / Extra High**, without independently
exposed runtime settings or token/cost measurements. Observed inspection
interval: **14:45:44–14:47:18 UTC**. No test, proof, build or benchmark was
launched, and no CLI recall was updated.

## Stable-content component review — 15:01 UTC

No unresolved correctness or scope finding in the frozen #328 implementation
in `tmp/lean-stable-cache`, based on
`18e471409e6a03a7ac59d8979e20beca8dc54766`. The reviewed delta comprises the
generator, nine output-body Lean files and two tests. All 12 file hashes match
the prepared inputs of successful managed fixture
`20261106T145355-acbd4750fe92`, fingerprint
`ed45c92e38b239dbdcd50b469da81a6551c36dcfb660d311d9bd8b637e7012bc`.
The subsequent identity check binds these same 12 reviewed file hashes to
author commit `dd132ecacef8da635f8b9ff9b14d8e3cc8cec8f1`. Integration copy
`524dbfbd4084c79f7048b1710dd3a7af76affe59` has identical `proof/`, `src/`,
`scripts/` and `tests/` bytes. This mapping adds no duplicate validation run.

Independent extraction from the baseline and candidate confirms **4,915 ordered
occurrences** reference **3,278 unique exact-text certificates**, in bucket sizes
**417, 379, 413, 438, 410, 410, 396, 415**. Every baseline literal, token list,
`correct` proof and `noNewline` proof is preserved under its content name.
All nine generated hashes match the author's static record. The complete
aggregator equals baseline after exactly 4,915 single-leaf reference
substitutions: balanced joins, literal equality witnesses, final statements and
imports are unchanged. The other 27 source certificates are unchanged.

The full SHA-256 digest selects the name, its first byte selects one of eight
buckets, and each bucket sorts by digest. Repeated exact text shares a proof;
every occurrence remains in the reconstruction and flattened token sequence.
CR bytes remain part of identity, and splitting on LF retains final empty
entries, including the single entry for empty source. Conflicting texts with
one digest fail before output publication. Digest identity supplies no new
proof trust: literal/token/no-newline checks, reconstruction equality and the
handwritten authoritative-source transport remain the assurance mechanism.

Leaves acquire no source-dependent import or source-wide metadata. Changed
unique text affects its bucket; occurrence-only edits can preserve every leaf.
The runner still stages all nine outputs, preserves unchanged bytes/timestamps,
checks source/workspace stability and performs fresh import/axiom auditing.
Lake's authoritative binary dependency, including restored-timestamp detection,
remains in place. The module inventory is unchanged at 638.

The [retained test packet](../evidence/lean-incremental-throughput-20261106/tests/README.md)
records **90 distinct passing methods**: 63 source/tooling checks in 13.112
seconds, the real fixture below, and 26 run-history/platform consumers in
176.948 seconds. The consumers' managed run
`20261106T145951-7b7c28cabb66` finished successfully in 180.123021 seconds.
The real Linux fixture passed in **340.850 seconds** (**344.237334 seconds**
managed), with one reserved worker, explicit `-j1/-M2048` and the pinned Lean
installation. It exercises no-op plus 11 edits: replacement, append, insertion,
unique deletion, reorder, repetition, repeated-occurrence deletion, CRLF, final
newline removal, empty-line addition and empty source. It checks actual
`.olean`, `.olean.private` and `.olean.server` bytes and timestamps, not merely
names. Reorder, repetition, repeated-occurrence deletion and empty-line addition
each retained all eight buckets and **203,096 object bytes**, while binding and
aggregator changed. A restored-timestamp stale-generation build failed;
regeneration and fresh eight-leaf audits passed. These bounded fixtures support
ordinary-edit reuse, not a production timing or complete-source assurance claim.

The final integrated reconstruction/source/module/axiom checkpoint and remaining
applicable validation still belong to delivery. This reviewer launched no test,
proof, build or benchmark. Selected setting: **GPT-6 Astra / Extra High**;
runtime confirmation and token/cost measurements are unavailable. Preliminary
inspection began at 14:50:16 UTC; the frozen-input review interval was
**14:56:32–15:01:21 UTC**, including waiting. No CLI recall was updated.

## Terminal closing confirmation — 16:04 UTC

The [complete integrated packet](../evidence/lean-incremental-throughput-20261106/integrated-complete/README.md)
confirms successful Linux run `20261106T150342-2526cc1a0ef4`. Its fresh audit
finished at 16:00:57 UTC, followed by managed terminal success at 16:00:59 UTC.
Governed source is `524dbfbd4084c79f7048b1710dd3a7af76affe59`; documentation head
`2f3aaa0de9c986a1d01ea7360c8edbd171d431d2` retains identical `proof/`, `src/`,
`scripts/` and `tests/`. The previous component review and author/integration
mapping therefore remain applicable.

Closing inspection independently matched **745 captured shared inputs**, all
**36 generated candidates**, and **640 shared/workspace source and build-input
hashes**, plus both Lean/Lake executables and the authoritative-source link.
The current project inventory, terminal log's actual imports and evidence module
set agree exactly on **638 modules**. Fresh auditing passed **128,514
declarations** with only `propext`, `Classical.choice` and `Quot.sound`.
This discharges the previously pending complete reconstruction and dependent
source/module/axiom checkpoint under the existing local-cache trust boundary.

The run rebuilt **25 modules**, including every content bucket and the
aggregator. Lake reported leaf durations of 947–1,092 seconds and aggregator
reconstruction of 1,962 seconds. Build and audit phases took **3,413.676** and
**10.601 seconds**; observed wrapper time was **3,438.194 seconds**. Both workers
and per-process threads selected 12 automatically, with a 24,576 MiB
per-process allowance. Sampled summed RSS peaked at **23.145 GiB**, minimum host
available memory was **8.544 GiB**, and the monitor never paused the run.
Sampling and shared-page limitations remain. This cached production checkpoint
is not a matched whole-project speedup or an ordinary-edit timing measurement.

The [native packet](../evidence/lean-incremental-throughput-20261106/native/README.md)
retains successful full proof run `20261106T145116-6582d1e5fcb5`: **17,496 checks**
and complete coverage/report/provenance auditing, using existing sessions and
result cache. Build `20261106T145251-335323a924fa` passed with both executables
up to date. Its applicability record checks 2,586 inputs and 12 tools; this
closing inspection independently reconfirmed all **143 tracked native input
hashes** against current integration bytes. The already reviewed **90 focused
methods**, including actual-object reuse and stale-source rejection, remain
applicable to the unchanged implementation.

The final capability record, roadmap and evidence-index status/performance
claims agree with these results. No concrete gap requires another validation
run. No complete application-suite, independent kernel replay, object
attestation, macOS or hosted-CI result is implied.

This bounded closing confirmation used the prior component review and terminal
evidence; it did not repeat the whole code review or launch tests, proofs or
builds. Selected reviewer: **GPT-6 Astra / Extra High**; runtime confirmation
and token/cost measurements remain unavailable. Observed inspection interval:
**16:02:24–16:04:44 UTC**. No CLI recall was updated.
