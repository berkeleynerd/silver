# Anti-primes

**Candidate: proofs plausibly discharge automatically.** Everything is for loops and mod on guarded ranged integers with a fixed-size result array, so no annotation is needed, but the loop-carried counters need careful guards and the scan limit must be big enough to reach the twentieth anti-prime (7560).

Position 371 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A procedure scans candidates with a for loop over 1 .. 7560 (a documented limit), counting divisors with an inner for loop using mod, and records each candidate whose count exceeds the running maximum into a 20-element Integer array, guarded by Found < 20. A second for loop over the array prints each value via 'Image into a bounded line buffer, then Put_Line emits the heading and the line. All loop-carried counters are guarded or bounded by declared ranges. About 55 lines.

## Proof obligations to watch

- **overflow**: The divisor counter and candidate are loop-carried, so each increment sits behind a guard against a documented limit (for example Count < 10000) that never fires for the first twenty anti-primes.
- **index**: Storing into the 20-element result array is guarded by Found < 20 because no invariant can show the number of results found stays within the array bounds.
- **division**: The mod operand comes from a for-loop index over 1 .. Candidate, whose type range excludes zero, so the check discharges.
- **length**: The output line is built in a fixed-capacity buffer sized for twenty values of at most five digits plus separators, with writes guarded by the remaining capacity.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, 'Image of scalars, string building, Put without a newline, procedures and functions.

## External effects

- **console output** (allowed): Prints a heading line and the twenty anti-primes.

Assessed on 2026-10-15 against page revision 415333 of the [task](https://rosettacode.org/wiki/Anti-primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
