# Native timeout policy — 2026-11-28

The owner authorized doubling default timeouts where useful. The retained
read-only assessment of active run `20261127T195636-5b2a2f886237` identifies six
provisional array-declaration roots, each with CVC5/Z3/Alt-Ergo timeout results
under the 30-second native compiler policy (18 attempts in total). Six separate
counterexample attempts timed out under their 10-second diagnostic limit.
The session XML omits measured attempt durations. No counterexample, invalid
or unknown result was recorded for these six roots; final report classification
is still pending. Their two helper declarations/contracts/bodies are unchanged
from the recorded main baseline; surrounding proof contexts may have changed.

The shared `PROOF_OPTIONS` now requests 60 seconds per prover. Canonical focused
and complete compiler checks consume that same constant and retain their existing
policy-separated workspaces and audit rules. Existing 30-second records retain
their actual configuration and outcome. The live run is preserved; integrate
this change after its terminal boundary, then focus the affected whole helpers
before the final complete checkpoint. No success or performance gain is claimed
until that probe passes. Lean has no managed wall-clock timeout to double.

Managed runner tests passed all 43 tests in `20261128T004533-c470b1b1fcb1`;
provenance tests passed all 27 tests in `20261128T004557-6680fce1c29f`.
Both used two automatically allocated workers with guest affinity 4–5, borrowed
from the completed source-bridge run. Commands and logs are retained here.
These are mocked-tool runner/provenance checks, not native prover results.

The additional auditor run `20261128T004617-980fe8fbe747` passed 78 of 79 tests.
Its existing `test_current_report_body_uses_reviewed_source_policy` failed on
two qualified metadata `Hide_Info` targets introduced by `e35fd0a741`.
The original 30-second baseline auditor reproduces the same rejection; the
timeout edit does not cause it. Its record remains failed. Review and repair
of that source-policy mismatch are separate remaining #416 integration work.

The 60-second native helper probe remains pending at the live run's terminal
boundary. Native proof, complete obligation discharge and source-correspondence
requirements are unchanged. No theorem, contract or source admission rule changed.
