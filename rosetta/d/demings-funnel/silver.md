# Deming's funnel

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared ranges, fixed array bounds and guards before loop-carried additions, with no recursion or annotations, but nonlinear sums of squares, the square root and decimal formatting need careful shaping.

Position 413 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Embed the 100 dx and dy values as constant arrays of scaled integers (thousandths) and compute each rule's positions in a procedure with a for loop, carrying the funnel offset in a wide ranged integer with a guard before each update. Compute mean and variance with for loops over the array's own range, take the standard deviation with a bounded integer square root, and print four-decimal results through 'Image-based string building and Put_Line for each rule. About 170 lines.

## Proof obligations to watch

- **overflow**: Rule 3 and Rule 4 funnel offsets and the sums of squares are loop-carried, so each loop step guards the running value against a wide fixed bound and rejects visibly if exceeded, while the data keeps it far inside the bound.
- **range**: Mean and variance accumulators have only their type range after the first iteration, so the types are declared wide enough (scaled integers) and a guard precedes each addition and multiplication.
- **termination**: An integer square root for the standard deviation is a while loop that must live in a procedure, or a for loop over a fixed bound, to avoid needing a variant.
- **division**: Division by the sample count uses a constant count of 100, so it is never zero.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints mean and standard deviation of x and y for each of the four rules.

Assessed on 2026-10-15 against page revision 414151 of the [task](https://rosettacode.org/wiki/Deming's_funnel) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
