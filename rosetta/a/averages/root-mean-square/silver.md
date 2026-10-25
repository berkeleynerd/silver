# Averages/Root mean square

**Candidate: proofs likely to discharge automatically.** All data is fixed and small, so loop-carried values fit wide integer types by declaration and the root search is bounded by an explicit guard, avoiding the floating-point Sqrt precondition and any annotation. The only extra work is formatting the decimal output with bounded string building.

Position 183 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

Compute the sum of squares 1..10 in a for loop with a wide integer accumulator, scale it by a fixed power of ten (385 * 10^10 / 10), and find the integer square root by a guarded linear or bisection search in a procedure, avoiding floating point. Then split the result into integer and six fractional digits and build the text "6.204836" in a bounded String buffer with leading-zero padding before calling Put_Line. About 35 lines.

## Proof obligations to watch

- **overflow**: The sum of squares uses a for loop over 1..10 with a Long_Long_Integer accumulator whose subtype bound is far above 385, and the root search candidate is bounded by a guard of 2_000_000 before squaring so the square stays below 4e12.
- **range**: The fractional digits are produced by mod and / on a value in a ranged subtype, so Image slices have statically bounded length.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the root mean square of 1..10 as a decimal line.

Assessed on 2026-10-15 against page revision 414068 of the [task](https://rosettacode.org/wiki/Averages/Root_mean_square) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
