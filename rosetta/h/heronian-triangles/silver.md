# Heronian triangles

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged subtypes, fixed array capacity with a guard, and for loops or procedure-only while loops, so no annotation is needed. The risk is moderate because the nonlinear product, the sort indexing and the manual padded text formatting all depend on careful program shape.

Position 426 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Triple for loops over a<=b<=c<=200 with c<a+b call a GCD procedure and a Hero function (16*area^2 product, integer square root by bounded for-loop search, exact-square test); primitive Heronian triangles go into fixed arrays of sides, perimeter and area, guarded by capacity. A procedure insertion-sorts indices by a combined (area, perimeter, max side) comparison, then a printing procedure builds padded row strings with 'Image and Put_Line for the first ten rows and for the area-210 rows. About 170 lines.

## Proof obligations to watch

- **overflow**: The four-factor Heron product is computed in a 64-bit range type from sides subtyped 1..200, so every factor and the product are statically bounded.
- **index**: Appending to the result arrays is guarded by Count < capacity (600, above the 517 required), and a full table is a visible rejection rather than a silent drop.
- **termination**: Euclid's GCD and the insertion sort use while loops, so they are procedures (no termination check), and the integer square root uses a for loop over a fixed candidate range.
- **index**: Insertion sort shifts with a while loop whose index is guarded by J > 1 before every array access, since no invariant can be written.
- **range**: Loop-carried values such as the Euclid remainders and the sort key are declared with ranged subtypes so type bounds alone make later arithmetic safe.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The count, the two table headers and the table rows are written as text lines.

Assessed on 2026-10-15 against page revision 414248 of the [task](https://rosettacode.org/wiki/Heronian_triangles) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
