# Sierpinski pentagon

**Candidate: proofs likely to discharge automatically.** All loops are for loops with static bounds, and the fixed-point coordinates live in bounded subtypes with convex-combination updates, so the checks follow from types and linear arithmetic with no recursion or floating point.

Position 667 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the five pentagon vertex coordinates as a constant array of fixed-point integers scaled by 1000. For each order N from 1 to 5, a for loop runs over every index 0..5**N-1 (bounded by 3125), peels off base-5 digits with mod and /, and applies the contractive map toward the chosen vertex for each digit. Each resulting point is marked in a fixed 2D Character grid, and the grid is then written out row by row with Put_Line, the order-1 case being a single pentagon. About 90 lines.

## Proof obligations to watch

- **overflow**: The per-level map x' = (v*618 + x*382)/1000 is a convex combination of values in a declared subtype -1000..1000, so the result stays in range from the type alone, with every constant visible to the prover.
- **index**: Grid row and column are computed as (coordinate+1000)*size/2001 from range-typed values, so they land in the grid bounds by linear arithmetic, and a guard before each plot makes this certain.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, for loops and procedures.

## External effects

- **console output** (allowed): Each order from 1 to 5 is printed as lines of ASCII art.

Assessed on 2026-10-15 against page revision 414984 of the [task](https://rosettacode.org/wiki/Sierpinski_pentagon) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
