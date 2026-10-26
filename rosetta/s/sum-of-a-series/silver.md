# Sum of a series

**Candidate: proofs plausibly discharge automatically.** Everything is a bounded for loop over a literal range with integer arithmetic whose operands are bounded by types, so only the accumulating sum needs a careful guard or wide range and no annotations are required. Using scaled integers rather than Long_Float avoids unprovable float-overflow on the loop-carried sum, at the cost of a documented 12-digit precision.

Position 539 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Use scaled integer fixed-point (units of 10**-12) in a ranged integer subtype instead of floating point, looping k from 1 to 1000 and adding a rounded 10**12 divided by k*k to the sum. After the loop, split into integer part and 12 fractional digits (filled into a fixed-length String by a for loop with mod/div by 10), and print with Put_Line using concatenation of Image output. About 35 lines.

## Proof obligations to watch

- **overflow**: The loop-carried scaled sum has no invariant, so each addition is guarded (or the sum is held in a wide type whose range covers 1000 terms of at most 10**12) to let the prover see no overflow or range violation.
- **division**: The divisor k*k comes from a for-loop index over 1..1000, so it is statically positive and at most 10**6.
- **range**: Splitting the sum into integer and 12-digit fractional parts uses constant divisors and a for loop over fixed digit positions, with each digit mod 10 mapped via Character'Val into a bounded String buffer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, characters, string indexing, string building and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the computed value of S_1000 as a decimal line.

Assessed on 2026-10-15 against page revision 414530 of the [task](https://rosettacode.org/wiki/Sum_of_a_series) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
