# Named Integer subtype drivers

Targeted source reconciliation: 2026-10-29. Final delivery confirmation:
2026-10-30, for [#286](https://github.com/berkeleynerd/silver/issues/286).
The two mapped drivers are implemented and validated on Linux in
[PR #289](https://github.com/berkeleynerd/silver/pull/289), awaiting the owner's
merge instruction. The [delivery record](../docs/named-integer-subtypes.md#delivery-assurance-and-validation)
identifies the complete native and Lean/source audits, regression applicability
and independent reviews.

The integration lead read the cached task descriptions, existing assessments,
candidate language rules and sample sources at `39d96fa9e5`. The live lead model
and effort, whole-round elapsed time and token/cost measurements are unavailable.
This static reconciliation is separate from the delivery's independent review
and native/Lean validation.

**Sum of squares**, task revision 415389, asks for a numeric vector's squared
sum, including zero for an empty vector. The
[driver](../samples/rosetta_sum_of_squares.adb) represents a vector with fixed
capacity and a logical count. Its first loop has `Count = 0`, executes no body,
and prints zero. A second loop traverses the actual array `3,1,4,1,5,9`, whose
component subtype is `0..9`. Its guarded accumulation computes
`9 + 1 + 16 + 1 + 25 + 81 = 133`. The manifest expects ` 0\n 133\n`, including
Ada Integer Image's leading spaces. This needs no null Ada array or helper
procedure. The array bounds contain the complete possible counted index range;
the subtype bounds justify the square, and the guard justifies each addition.

**Sum and product of an array**, task revision 413444, asks for those two
aggregations over integers. Its [driver](../samples/rosetta_sum_and_product.adb)
iterates the actual array `1..10`, with component subtype `1..10`, and updates
guarded accumulators. The independent expected values are
`10 * 11 / 2 = 55` and `10! = 3628800`; the manifest expects
` 55\n 3628800\n`. Guards use constant thresholds derived from the component
upper bound and cannot fail for this sample. No division expression, Boolean
object, procedure or array attribute is needed in the Silver source.

Only these two task approaches are revised. Their original 2026-10-15
Claude Sonnet assessment dates, revisions, model and effort fields remain
historical; neither entry had an intervening review object. The `review`
metadata retains the targeted source review date and separately records the
final delivery confirmation. The supported list gains only
`named-integer-subtypes`; the broad `ranged-subtypes` and `arrays` identifiers
retain their unimplemented scope. The existing fixed-array and constant-array
iteration descriptions now refer to declared component bounds. Broad stage
issues #11 and #12 remain open and Backlog.

`python3 rosetta/refresh.py --render` rendered all 1,782 tasks on Linux.
Stage 1 grows from 51 to 53 assessments; the progression retains 1,576 candidates
in 44 stages, with broad subtype and array stages still 2 and 3.
The two drivers' execution evidence is retained in the
[delivery record](../docs/named-integer-subtypes.md#delivery-assurance-and-validation),
with 52 sample sources and 108 executions in the applicable full-suite evidence.
Final delivery confirmation checks these mappings against that evidence and the
complete audits; it is separate from the scoped independent reviews and claims
no external approval. Static output derivation and rendering alone do not
establish proof, compilation or execution.

Delivery documentation selected GPT-6.1 Sol / High. Its exact inputs are this
record, the two coverage entries, the linked capability/evidence records and
implementation/review target `d4e2be67b5de7fcc2919cf9eac6efb217e5ca672`.
Runtime settings, whole-round elapsed time and token/cost measurements are not
independently exposed.
