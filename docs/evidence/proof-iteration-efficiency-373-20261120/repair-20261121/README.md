# PR #406 repair validation, 2026-11-21

The complete native audit, complete Lean/source/module/axiom check and actual
build invocation passed on repaired implementation
`c2b60470aec145d28206cbd27f79ff7f63cb9378`. These are fresh current-runner
invocations on native Linux x86-64, machine `silver`, under task
`#407-final-repair`. [Structured results](summary.json) retain commands, reasons,
allocations, phase results, binary identities and timing scopes.

| Check | Managed run | Result | Managed seconds | Wrapper seconds |
| --- | --- | --- | ---: | ---: |
| Complete native audit | `20261121T024227-a19b938a6d86` | 78 units / 1,252 entities / 19,726 checks | 46.663743393 | 47.442439756 |
| Complete Lean check | `20261121T024324-385324656492` | 1,035 modules / 166,332 declarations | 25.319934612 | 26.195677059 |
| Native build invocation | `20261121T024405-83ca2639949a` | Both existing binaries up to date | 2.084117508 | 2.895598513 |

All three automatically allocated 22 workers; Lean also automatically allocated
22 threads per process, with no explicit memory threshold. Each wrapper recorded
stack limits `[16777216, -1]` bytes and exit zero. Successful managed context-manager
finish events have their normal null returncode; producer phases record zero.

The [native producer archive](native/producer-reports.tar.gz) retains all 82
report/metadata files. The complete provenance and initial-input manifests agree
with the managed prepared inputs. All 80 report hashes were checked against both
managed copies and root outputs, all 2,585 native input hashes were rechecked,
and all 12 selected native tool binaries were rehashed. All 78 expected units
have complete reports: 1,751 flow plus 17,975 proof checks, with 1,252 entity
coverage entries and no skipped flow/proof or assumed checks. The successful
SARIF invocation matches provenance. This forced full warm audit used `-f` and
the canonical 30-second timeout, retaining existing sessions and solver cache;
it makes no cold-solve or cache-hit-count claim.

The [Lean evidence](lean/lean-evidence.json.gz) and [log](lean/lean-proof.log.gz)
retain complete incremental scope and a fresh axiom audit. The module set matches
all 1,035 fresh audit module lines; 166,332 declarations passed with foundations
`propext`, `Classical.choice`, `Quot.sound`. Cached Lake build took 4.946 seconds
and fresh audit took 7.230 seconds. Both selected Lean tools were rehashed.
There was no clean build or independent kernel replay. Artifact hashes are
retained in producer evidence; this collector did not independently rehash
compiled artifacts. The independent review supplies any additional artifact
verification claim.

The [build log](build/native.log.gz) records both binaries up to date, and its
captured native inputs equal the proof run's. No recompilation is claimed.
Binary hashes and modification times are retained in the structured results.

## Regression census and preserved failure

[Exact-ID accounting](regression-census.json) independently discovers 759 current
IDs without running tests, with bytecode writes disabled. Raw unittest headers
from current and retained logs reconcile every ID:

- 42 fresh passes from `20261121T024106-8380ee364bdf`, covering all of
  `test_dev_runs.DevRunTests`, including both new alias tests.
- 242 retained passes from the previous 282-test tooling run
  `20261120T152415-e5e1f5ee6934`, excluding its former 40 `test_dev_runs` results.
- 475 retained passes from full run `20261120T130632-15ab84282224` (724 tests).

No IDs are uncovered. Actual `tests.test_shared_bindings.*` IDs remain distinct
from `test_shared_bindings.*`; no normalization fabricates or merges IDs.
The prior [accounting and raw logs](../README.md) retain their exact IDs and
run identities. The census checks their raw header sets against the prior JSON.

The [baseline log](tests/baseline-failed/native.log.gz) preserves run
`20261121T024037-07bacaed43db` as failed: two tests, four subtest failures and two
subtest errors. Its captured inputs differ from current root only in the
pre-fix `scripts/focused_proof.py`; those exact pre-fix bytes are retained beside
the log and checked against the repaired commit's parent. Targeted repair run
`20261121T024049-e15f45e8ad9f` passed both tests. Both successful repair runs'
1,342 captured input hashes match current root/external-tool bytes after mapping
their original worktree paths. Managed events and logs for all three are kept.

Applicability of retained results is attributed to the independent review in
[the response record](../../../reviews/review-8dc409b303-response.md), including
its determination that only `test_dev_runs` depends on the changed
`FocusedProof.scope` path. This collector establishes exact census/input
identity and recorded outcomes; it does not substitute its own dependency
judgment for that review.

## Input binding and archive limits

[The input map](input-map.json) binds 1,347 current source/setup inputs and all
1,037 Lean workspace inputs. Every mapped source byte was checked against root;
all 1,341 tracked source inputs also match exact Git blobs at the repaired
revision. Six generated setup files are bound by their observed hashes.

Unchanged source bytes reference the previous
[`final/source-inputs.tar.gz`](../final/source-inputs.tar.gz), and unchanged
workspace bytes reference
[`final/workspace-inputs.tar.gz`](../final/workspace-inputs.tar.gz).
Both previous archive hashes and every member hash were independently rechecked
against their inventory before reference. Another 194 unchanged tracked inputs,
new to this packet's test inventory, reference their exact Git blobs at previous
implementation `f0a773fbcb9eea9574b037812e888029b7f970cb`; these bytes were
checked at both revisions. Only the two changed source files
`scripts/focused_proof.py` and `tests/test_dev_runs.py` are newly copied in
[the delta archive](changed-source-inputs.tar.gz). No workspace input changed.
This avoids copying either previous complete source/workspace archive.

[Prepared inputs](prepared-inputs.json.gz) retain native/build/test input maps
and selected tool identities. [The archive manifest](archive-manifest.json)
binds every file in this packet except itself. Producer reports and retained
logs remain authoritative; the JSON summaries are extraction records.

The selected collection setting was GPT-6.1 Sol / High; live model/effort were
not independently exposed to this collector. The final collection script took
about 7 seconds; this excludes drafting and earlier extraction attempts, so
whole-subthread elapsed time is unavailable. Token/cost measurements are
unavailable. Wrapper child usage is retained verbatim, including its warning
that maximum child RSS is not simultaneous process-tree peak. No comparative
performance, memory peak or speedup claim follows from these warm executions.
No tests, proofs, builds or GitHub mutations were initiated by this collector.
