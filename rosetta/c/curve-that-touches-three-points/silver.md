# Curve that touches three points

**Candidate: proofs likely to discharge automatically.** The task asks only for a drawn curve, which text art satisfies, and a fixed-coefficient integer parabola over a ranged x with for loops and a bounded grid gives every check from types and a guard. Nothing needs an invariant, recursion or floating point.

Position 653 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The curve is the unique parabola y = 10 + 19*(x-10)*(200-x)/900 through the three points, written as a hand-coded integer curve function with a range-typed x and constant divisor. A for loop over x in 10..200 computes y, maps it to a row and column of a fixed 2D Character grid (blank background, '*' for the curve, 'O' for the three given points), and then a for loop over rows copies each row into a String buffer and prints it with Put_Line. The scaling to grid cells uses constant divisors and a guard that skips out-of-range rows. About 45 lines.

## Proof obligations to watch

- **index**: The computed row index is clamped to the grid range by an explicit guard just before the grid store, so the index check discharges from the guard.
- **overflow**: The product 19*(x-10)*(200-x) is bounded by the declared range of x (at most 171,475), so the integer arithmetic cannot overflow.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, for loops, string building and procedures.

## External effects

- **console output** (allowed): The program prints the curve as text art, one row per line, to standard output.

Assessed on 2026-10-15 against page revision 414141 of the [task](https://rosettacode.org/wiki/Curve_that_touches_three_points) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
