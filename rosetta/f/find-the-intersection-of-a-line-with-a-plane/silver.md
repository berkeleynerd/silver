# Find the intersection of a line with a plane

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded float subtypes, a for loop over the array's own range and explicit guards before the division and the final range conversion, but floating-point reasoning makes the discharge depend on careful program shape.

Position 1046 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Represent vectors as a constrained array of three values of a bounded float subtype, with the task's direction, point, normal and plane point embedded as constants. A function computes the dot product with a for loop, and the main body computes the denominator, prints a rejection line if the line is parallel to the plane (denominator within epsilon of zero), and otherwise computes the scale and the point and prints the three coordinates. About 45 lines.

## Proof obligations to watch

- **floating point**: Dot products and the scale computation use floats whose operands are bounded by a declared range subtype (for example -1000.0 .. 1000.0) so no product or sum can overflow.
- **division**: The division by the direction-normal dot product is guarded by an explicit test that its absolute value exceeds a small epsilon, with a visible rejection message otherwise, and the quotient is range-guarded before conversion back to the bounded subtype.
- **range**: The computed intersection coordinates must be checked against the bounded subtype before assignment, so a guard with a specified outcome is needed for out-of-range results.

## Language surface beyond today's Silver

Floating point, ranged subtypes, arrays, for loops, functions, floating-point images and Put without a newline.

## External effects

- **console output** (allowed): The program prints the intersection point to standard output.

Assessed on 2026-10-15 against page revision 413180 of the [task](https://rosettacode.org/wiki/Find_the_intersection_of_a_line_with_a_plane) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
