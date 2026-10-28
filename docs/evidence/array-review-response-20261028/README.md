# Fixed-array external review response evidence

This packet records the response to [review-10cdcd274c](../../reviews/review-10cdcd274c.md),
stacked above PR #266 at `873f5910d2`. Implementation and validation are in
progress; the proof-side precedence repair still needs the complete Lean/source
checkpoint. Both PRs remain open. No language rule or Oracle guarantee changes.

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

[Native input applicability](native-input-applicability.json) verifies all 143
tracked inputs against the response and all 78 retained report digests. The
native provenance includes 2,561 inputs in total, including generated/toolchain
files; its initial state records both sessions and solver-cache entries present.

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
| Precedence repair and independent review | GPT-6 Astra / Extra High for each bounded subthread | Focused checking and review in progress; complete source validation pending. |

These are selected settings, not independently confirmed runtime settings. Lead
runtime settings and token/cost measurements are unavailable. No macOS or hosted
CI result is claimed.
