# Count the occurrence of each digit in e

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds and loop indexes except the loop-carried carry, which needs two visible guards but no annotation, so discharge depends on careful program shape.

Position 162 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Port Ken Thompson's spigot with a constrained Integer array v of fixed size (say 2000, all 1s) and a ten-element counter array pre-seeded with the leading 2; nested for loops compute each digit with the divisor derived from the inner index, guarding the carry before the multiply-add and before indexing the counters. Counts are printed in a procedure with Put and 'Image, rejecting visibly if a guard ever fails. About 45 lines.

## Proof obligations to watch

- **overflow**: The carry c is loop-carried with no invariant, so a guard before each c + v(i)*10 rejects the run if c exceeds a fixed bound, which a Long_Long_Integer type makes provable at the guard.
- **index**: The digit index dcount(c) depends on the loop-carried carry, so an explicit guard that c is in 0..9 (otherwise Reject) precedes the increment.
- **division**: The divisor a is computed as N+1-i from the for-loop index rather than carried, so its range 1..N+1 follows from the loop bounds.
- **range**: Storing c mod a into the digit-state array needs the element subtype to cover 0..N, which follows from a's bounds, and the incremented counters need a bounded subtype with a guard against exceeding it.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, 'Image of scalars, string building, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints the ten digit counts to standard output.

Assessed on 2026-10-15 against page revision 401722 of the [task](https://rosettacode.org/wiki/Count_the_occurrence_of_each_digit_in_e) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
