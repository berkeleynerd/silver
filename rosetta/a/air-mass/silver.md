# Air mass

**Candidate: proofs plausibly discharge automatically.** Nothing needs an annotation, but the program depends on admitted floating-point elementary functions with verified contracts and on finite-range reasoning for accumulating floats through a loop, so discharge depends on careful program shape.

Position 1568 in the [progression](../../progression.md#stage-37), in stage 37, which adds fixed point.

## Approach

Embed Earth radius, scale height and the two altitudes as constants, and compute column density by numerical integration in a procedure using a for loop over a fixed number of steps with a geometrically growing step size, avoiding an unbounded while loop. Loop over zenith angles 0..90 step 5 with an integer for loop, convert to radians, compute air mass as the ratio of slant to zenith column density with a positive-denominator guard, and print each row for both altitudes via bounded text formatting. About 70 lines.

## Proof obligations to watch

- **floating point**: Exp, Sqrt and Cos need admitted library operations with verified contracts, and the sqrt argument must be shown nonnegative by a guard (clamp to zero would alter results, so the geometry must make it provably nonnegative or reject).
- **overflow**: The loop-carried sum and distance are floating-point values that only their type bounds constrain, so range-limited float subtypes and a bounded step count (a for loop over a fixed iteration count with a geometrically growing step) are needed to keep each addition finite.
- **division**: Dividing by the zenith column density needs a guard that it is positive, with a specified rejection outcome otherwise.
- **termination**: The integration is written as a for loop over a fixed step count inside a procedure, so no variant is needed.
- **other**: Formatting floats with fixed decimals requires a bounded-string float formatter, which must be an admitted library operation with a specified range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, floating point, fixed point, for loops, while loops, functions, procedures, 'Image of scalars, floating-point images, string building, Put without a newline and arrays.

## External effects

- **console output** (allowed): Prints the table of zenith angles and air mass values.

Assessed on 2026-10-15 against page revision 415526 of the [task](https://rosettacode.org/wiki/Air_mass) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
