# Fixed-array external review response evidence

Historical review checkpoint, 2026-10-28. The subsequently integrated frontend
repair #284 and owner-authorized final merge use the
[combined validation packet](../array-final-validation-20261029/README.md).
That later packet records current outcomes; the interrupted run and earlier
configuration-specific results below retain their original scope and status.

This packet records the response to [review-10cdcd274c](../../reviews/review-10cdcd274c.md),
stacked above PR #266 at `873f5910d2`. The implementation snapshot is
`5e53345a00`, published for review in [PR #283](https://github.com/berkeleynerd/silver/pull/283).
The owner proposed reviewing the revisions and incorporating feedback before the
complete Lean/source checkpoint. Run `20261028T185441-7fe036b871f3` was therefore
interrupted cleanly after 530.958 s, preserving completed caches. No complete
Lean success is claimed for the response. Both PRs remain open; that checkpoint
is required on stable final inputs before merge. No language rule or Oracle
guarantee changes.

Managed events and logs are retained under `runs/`, compressed without changing
the decompressed bytes. Each `retained.json` gives hashes and the original
finished event. Failed runs remain failed. The native refresh uses the existing
successful sessions/cache; no clean build or independent kernel replay is claimed.

| Run | Scope | Result |
| --- | --- | --- |
| `20261028T182547-62c76ca0dd75` | Rosetta capture regression before repair | Expected failure |
| `20261028T182607-8b55cdee57a3` | Managed-runner tests | 26 passed |
| `20261028T182622-c23cff9b9c3e` | Build with corrected catalogue | Passed |
| `20261028T182645-200a4889f24e` | Catalogue parity and description assertions | Passed |
| `20261028T182657-152f444d7d05` | Rosetta capture on tooling snapshot | Three passed; all three actual renderer inputs match the response |
| `20261028T183946-c9c0249f72f8` | Complete native proof and coverage/provenance audit | Passed: 16,711 checks, 76 units, 1,068 entities; 92.552 s with retained sessions/cache, four workers |
| `20261028T184201-a36497f8e938` | Build after native refresh | Passed; 10.579 s |
| `20261028T182856-80672b38d6db` | Initial focused guard run | Failed on private regression-fixture visibility; retained as failed |
| `20261028T183022-b6f6878a4f91` | Guards, current trees and indexed source candidate | Passed; 1,173.268 s build and 9.795 s fresh 19,970-declaration audit |
| `20261028T185112-d630b7abbbea` | Final private counterexample controls | Passed; 54.986 s build and 4.517 s fresh 15,099-declaration audit |
| `20261028T185332-76aab44e2c25` | Source policy and certificate parity | All 12 passed |
| `20261028T185511-862e99ae419a` | Platform and installation routing | All 16 passed; 246.994 s test time |
| `20261028T185441-7fe036b871f3` | Complete Lean/source checkpoint | Interrupted for review-first sequencing after 530.958 s; composition candidate unfinished, no final audit |

[Native input applicability](native-input-applicability.json) verifies all 143
tracked inputs against the response and all 78 retained report digests. The
native provenance includes 2,561 inputs in total, including generated/toolchain
files; its initial state records both sessions and solver-cache entries present.

The [independent guard review](../../reviews/review-array-precedence-repair-20261028.md)
checks the exact final repair, including authoritative wiring and private
counterexamples. Renderers, evaluators, current checked trees, endpoint statements
and source pins are unchanged. Its one fixture-quality note was corrected and
rechecked; neither focused result substitutes for the deferred complete checkpoint.
The [regression applicability review](../../reviews/review-array-response-applicability-20261028.md)
accounts for 542 final test identities: 484 applicable earlier passes, 30 successful
response passes and 28 successful proof-sensitive reruns (12 source and 16 platform
tests). The [final inventory](test-inventory.json) and
[per-identity coverage](regression-applicability.json) retain that partition;
[input comparisons](regression-input-applicability.json) verify all 783 captured
non-generated worktree inputs of each final rerun against the response. The earlier
full 540-test run remains failed.

## Stack observations

The exact [counted-loop fixture](stack/count-143.adb) is 4,079 bytes with 143
nested loops. The [constant-array foreach fixture](stack/foreach-source-bound.adb)
is 4,091 bytes with 159 nested loops; another level of this same source shape
would exceed 4,096 bytes. Neither statement asserts a universal maximum over
all possible programs.

The [harness](stack/observe.py) set the actual child stack limit to 8,192 KiB for
admission, compilation and execution. Both fixtures passed all three phases,
with all 66 emitted native checks proved and execution exiting zero. No source
or production prover option changed.

| Fixture | Managed run | Compile time | Generated workspace |
| --- | --- | --- | --- |
| Counted loops | `20261028T183837-8e184380a34d` | 24.494 s | `program-BituXE` |
| Constant-array foreach | `20261028T183918-0e17269350ef` | 32.486 s | `program-D6RcLV` |

[Summary](stack/summary.json), [fixture identities](stack/fixtures-manifest.json),
[checksums](stack/sha256.json) and the per-phase outputs retain the exact bytes,
commands, exits and input identities. The binary was built from tooling snapshot
`1fae7c1f5f`, with compiler sources equal to the response. Each observation reserved
two workers and inherited CPU affinity `0,1`; the unchanged driver uses `-j0`,
which expanded internally to 12 prover workers despite that affinity. These are
concrete successful observations on Linux, not a universal stack or runtime bound.
No fresh `.su` frame-size report was available; the external frame-size and
minimum-recognition-stack figures remain attributed to the external review.

## Work and review rounds

| Round | Selected settings | Outcome and measurement |
| --- | --- | --- |
| Catalogue and runner repair | GPT-6.1 Sol / High | Five condition descriptions corrected; exactly three Rosetta test inputs captured, with two regression methods. Focused results retained above. |
| Record reconciliation | GPT-6.1 Sol / High | Current claims, historical cache conditions, attribution and missing rounds corrected. Historical seed origins not retrospectively invented. |
| Stack observations | GPT-6.1 Sol / High | Two concrete 8 MiB passes above, preserving production options. |
| Precedence repair and independent review | GPT-6 Astra / Extra High for each bounded subthread | Focused guard/candidate checks passed, with one visibility repair and one private-fixture correction. Independent review found no remaining blocking defect; complete source validation was interrupted for the owner-proposed review-first sequence. |
| Regression and record applicability review | GPT-6 Astra / Extra High | Identified the 28 affected identities and corrected overlapping cache-count wording. Earlier passing results retained only where inputs/dependencies apply. |

These are selected settings, not independently confirmed runtime settings. Lead
runtime settings and token/cost measurements are unavailable. No macOS or hosted
CI result is claimed.

## Remaining checkpoint

Review #283 together with its #266 base, integrate relevant feedback, and freeze
the resulting implementation inputs. The reusable proof workspace is
`tmp/constant-array-source`, branch `validation/array-review-lean`, at
`5e53345a00`; the interrupted candidate's in-process work must be recomputed,
while completed artifacts remain available. Run the ordinary complete
`scripts/check_lean.py` checkpoint there at one worker/thread and the previously
successful 24 GiB process threshold, without a clean build or optional replay.
Refresh native/build/regression checks only if feedback changes their inputs or
dependencies. Complete validation and an evidence confirmation remain mandatory
before merge; this packet is a review checkpoint, not a completed delivery claim.
