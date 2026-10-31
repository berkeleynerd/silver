# Body_Tail repair: final build and regression refresh

The final repaired implementation is `6020416906b5fc3d2bd10d012e70937c80f0617c`; the compiler source
`src/silver_output_profile.adb` has SHA-256
`84779089d15b9e7990fd806de3a8965edfb5bdeacac2c02544cb0c9d28ba6a8a`.
The native build and all **46 refreshed regression identities passed** on
native Linux x86_64. Complete native proof/audit and Lean/source/module/axiom
assurance are separate checkpoints, not established by this packet.

Actual execution used `tmp/constant-array-iteration`, branch
`validation/named-integer-subtypes`, committed validation snapshot
`b05fc811831934057b47f2aa8b662c2f9be72b2b`. Preflight compared all 787 governed tracked
inputs with `97312a790fb11a83a9607ad48ddab491711f2c3d`, found no drift, and then
synchronized only the repaired source, `ReviewedOutputShape.lean` and
`OutputBodyCertificate.lean`. All governed bytes subsequently matched the final
implementation. Unrelated untracked scratch was preserved. The evidence worktree
is `tmp/subtypes-repair-regression-records`, based on `32880032da`.

Selected execution model/effort: GPT-6.1 Sol / Extra High. Runtime model/effort
confirmation and token/cost measurements are unavailable. This round intended
to close the final build and the independently identified affected regressions;
it achieved those checks without implementation or test changes. The existing
[source/applicability review](../../../reviews/review-named-integer-subtypes-body-tail-equality-20261029.md)
provides the Static-erasure and dependency argument; this execution does not
repeat that independent review.

| Managed run | Scope | Result | Managed duration | Unittest duration |
| --- | --- | --- | --- | --- |
| `20261029T210150-1086727daf3c` | build | Build passed | 13.114 s | — |
| `20261029T210251-939fbc67799b` | lean-source | 12 passed | 74.458 s | 71.856 s |
| `20261029T210409-2c895b357da6` | platforms | 16 passed | 260.701 s | 257.942 s |
| `20261029T210832-732f9cd37a16` | output-integrity | 17 passed | 44.925 s | 41.819 s |
| `20261029T210920-b4b0cd40fe3c` | silver-tool-failures | 1 passed | 17.220 s | 14.634 s |

The four test selections were exactly `test_lean_source.py` (12),
`test_platforms.py` (16), `test_output_integrity.py` (17), and
`test_silver.py -k test_tool_failures_and_source_changes_do_not_report_success`
(1). Neither the whole Silver integration module nor the full suite was rerun.
The source tests include certificate parity and native Lean witness checks;
they do not establish complete project source correspondence. Platform tests
use mocked host/tool routing and are not native macOS execution or Lean proof
validity. The output-integrity and selected Silver fixtures rebuild and execute
the real compiler with fixture-specific installation paths, while their external
tool/report scenarios remain controlled fixtures.

[Coverage](coverage.json) matches every fresh identity against the existing
555-identity inventory and explicitly lists the 509 retained identities.
The final reconciliation is **509 applicable original full-suite results plus
46 new passes = 555 identities**, representing 546 distinct methods after the
nine imported duplicates. The earlier successful full suite and its 28 later
reruns remain unchanged history; the prior reconciliation is retained
[byte-for-byte](prior-test-reconciliation.json). The 52 sample sources and
108 application executions remain retained results under the cited independent
applicability review, not fresh sample executions.

Each run reserved four managed workers. The unittest processes and descendants
were restricted to CPUs 8–11; each managed runner retained CPUs 0–11. The
[affinity record](affinity.json) contains actual process observations, including
inherited child affinities. The retained [driver](affinity-driver.py) performs
this scheduling outside production code. Application prover settings, including
production `-j0`, were unchanged. The root's independent complete Lean checkpoint
reserved one worker concurrently. The [memory observations](memory-observations.json)
record available memory at sampled times; they are not a measured peak or hard
memory reservation. No unexpected memory pressure was observed.

`runs/` preserves original managed logs/events with unchanged decompressed bytes;
each `retained.json` records their original locations, SHA-256 values and terminal
event. [Input comparisons](input-comparisons.json) compare every captured tracked
input with the final implementation and preserve external/generated/tool input
identities. No stale source result was promoted to a final proof result.
