# Bitmap/Bézier curves/Quadratic

**Candidate: proofs plausibly discharge automatically.** Everything uses bounded integer ranges, for loops and fixed arrays, with no loop-carried accumulators, so checks follow from types and local guards, though the nonlinear integer arithmetic and the need for explicit pixel-range guards make careful shape necessary.

Position 691 in the [progression](../../../../progression.md#stage-14), in stage 14.

## Approach

The program holds a 16x16 Character array filled with spaces, computes 21 curve points with integer Bernstein weights (parameter I over N=20, divided by 400) into an array of coordinates, and joins consecutive points with a stateless interpolated line routine in a for loop that sets pixels to a mark character under range guards. It then copies each row into a fixed 16-character String by index and prints it with Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: The weighted sums (N-I)^2*P1 + 2*I*(N-I)*P2 + I^2*P3 are nonlinear but discharge because coordinates are subtypes of 1..16 and I is a for-loop index in 0..20, so the maximum is a few thousand.
- **index**: Each computed pixel coordinate must be shown to lie in 1..16 after integer division, which the provers may not derive from the convex-combination structure, so an explicit visible range guard before each store (skipping out-of-range points) is used.
- **division**: Line interpolation divides by the step count, which is guarded to be at least 1 immediately before the division, and the curve division is by the constant 400.
- **range**: Line points are computed as x0 + (x1-x0)*k/steps with no loop-carried state (rather than Bresenham error accumulation) so each value is bounded by types and guards without an invariant.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, for loops, string indexing, string building and procedures.

## External effects

- **console output** (allowed): The 16x16 text-art bitmap is printed row by row to standard output.

Assessed on 2026-10-15 against page revision 414084 of the [task](https://rosettacode.org/wiki/Bitmap/B%C3%A9zier_curves/Quadratic) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
