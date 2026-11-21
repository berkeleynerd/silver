# Named Integer-array inputs assessment — 2026-11-21

This assessment covers **Dot product** (cached revision 413360) and **Horner's
rule for polynomial evaluation** (411617), the two drivers for the owner-selected
[named array parameter capability](../docs/named-array-parameters.md), #410.
It records task fidelity and independently derived results; complete feature
validation and the supported-mapping update remain pending in draft PR #412.

The 2026-10-15 assessment of Dot product was selected as Claude Sonnet 5.5 at
medium effort; Horner's rule was selected as Claude Opus 5.5 at high effort.
Their original attribution remains in `coverage.json`. Those approaches used
unconstrained arrays. The current constrained versions preserve each task's
required callable interface without claiming unconstrained-array support.

## Dot product

The task requires a function multiplying corresponding entries and summing them;
arbitrary vector length is optional. The [sample](../samples/rosetta_dot_product.adb)
uses the named three-element `Vector` type for both read-only arguments, giving
equal bounds by nominal type identity. Its function uses First/Last queries and
three products. Every component is in -10..10, every product in -100..100, and
the complete sum in -300..300. This argument applies to all declared inputs,
independently of Main's two example aggregates.

For `[1, 3, -5]` and `[4, -2, -1]`, independent arithmetic gives
`1*4 + 3*(-2) + (-5)*(-1) = 3`. The exact output is `Dot product: 3` followed
by LF, including Integer Image's leading space before a positive value.

## Horner's rule

The task requires a routine receiving coefficients in increasing power order
and a value of x. The [sample](../samples/rosetta_horner_polynomial.adb) passes a
named four-element polynomial to a procedure with a scalar x and scalar outputs.
Reverse iteration over the input's Range visits its coefficients in the order
needed by Horner's recurrence.

Coefficient bounds are -20..20, x is -10..10 and the accumulator is -1000..1000.
Before each multiply-add, the executable -98..98 accumulator guard bounds the
product by -980..980 and the sum by -1000..1000. The success flag preserves no
implicit range fact: every performed update has its own explicit guard. Once
a step is refused, subsequent steps preserve failure, and the procedure returns
zero with `Succeeded = False` rather than exposing a partial polynomial value.

At x=3, the accumulator sequence is `0, 6, 14, 49, 128`. At x=10 it is
`0, 6, 56, 567`, then the guard refuses the last update. The predicted output is:

```text
At 3: 128
At 10: capacity exceeded
```

## Delivery state

The prepared fragment uses the precise identifier
`named-integer-array-parameters`, covering constrained named Integer-array types,
read-only function/procedure array inputs and static bounds queries. Existing
scalar functions/procedures, integer subtypes, mutable scalars, Boolean state,
guards, counted loops and Integer Image retain their existing identifiers.
Broad arrays, writable or unconstrained parameters and array results remain
outside this assessment.

Targeted delivery preparation reread each cached task and its Ada solution;
Dot product's retained SPARK solution was also checked. The task text makes
arbitrary vector length optional, and Horner's text requires a coefficient list
in increasing-power order with a value of x. The fixed nominal types preserve
these required callable interfaces. The draft coverage records preserve original
assessment model/effort/date fields and give this current review separate
metadata. No other corpus assessment is revised.

The precise identifier remains absent from `supported`. The current render
therefore presents both tasks as candidates for a pending construct. Final
promotion requires updating the current-language description and pending
summary/review wording, adding that identifier, rerendering and reconciling the
stage issue; the lead retains ownership of that final assurance checkpoint.

The feature regression's five compile/prove/run routes passed in managed run
`20261121T125607-826b7d51ebf2`; the sample manifest also specifies the exact outputs
above. This record does not infer whole-language assurance from those examples.
Complete native/Lean/source verification, final regression coverage and independent
delivery review remain required before promoting the supported mappings.

Documentation validation on native Linux x86_64: managed render
`20261121T132946-af74581a2ce2` completed using one worker (automatic availability
12). A final direct deterministic render corrected the Horner source count to
55 lines; Dot product has 25. Managed `test_rosetta.py` run
`20261121T133012-5136c8f61666` passed all 12 refresh/render tests in 6.336 s,
using one worker (automatic availability 18). That suite includes deterministic
rendering across hash seeds. The pending output groups the two drivers in
Stage 38, ranks 1568 and 1569. Regenerated positions in other pages do not revise
their assessments. No native compiler/prover was rerun by this preparation.

This task/source assessment and independent arithmetic were performed by the
integration lead under the repository's Astra Extra High role selection. Live
runtime model and effort are not independently exposed. This is an implementing
team assessment, not an external review.
