# Current regression applicability — 2026-11-08

The [independent review](../../../../reviews/review-scalar-functions-delivery-20261108.md#repaired-input-regression-applicability-resolution--2026-11-08)
at `412de80b29` accepts 621 successful outcomes for exact target `3d38fedb68`,
whose governed inputs remain `f630819154`. It accepts all 286 proposed reused
outcomes (285 original passes and the unchanged chunk fixture) and the 335
actual passes in failed repaired-compiler run `093645`. No proposed reuse was
rejected. This is a partial applicability result, not a completed 637-test run.

Exactly sixteen IDs remain pending: the three compilation timeouts, the original
platform wrapper, and its twelve nested bodies. Their reviewed serialized
follow-ups remain queued until the complete native and Lean audits finish. The
three current Rosetta results will also require fresh results after promotion;
they already belong to this inventory, not three additional IDs. Original failed
runs keep their failed outcomes.

The [analysis](ANALYSIS.md), [summary](summary.json) and
[per-ID overview](resolution-overview.json) retain the exact source/tool/test
identity scope and indirect-dependency findings. The review checked 8,866 tracked
inputs, 1,115 prepared selector members and bytes, native/tool maps, helper
normalization, raw outcome origins and twenty unchanged chunk-fixture inputs.
Actual compiler execution belongs to the source-equivalent regression checkout;
the integration checkout has no installed compiler or adapter.

The coordinator independently verified the exact 25-member [bundle](evidence.tar.gz)
and every indexed payload length/hash before retention. The [index](index.json)
also hashes the manifest. No test or proof was rerun for this review. Complete
native/Lean assurance, the pending regressions, final Rosetta reconciliation and
final delivery review remain required. Reviewer selection was GPT-6 Astra / Extra
High for this already-started bounded inventory audit; runtime settings and
token/cost telemetry were unavailable. The later owner policy requires explicit
Astra Max selection for future critical proof reviews.
