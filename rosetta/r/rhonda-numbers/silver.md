# Rhonda numbers

**Candidate: proofs plausibly discharge automatically.** All arithmetic is small integer work bounded by a documented search limit, and the only loop-carried hazards (digit product and factor sum) can be handled with caps and range types without annotations, though the careful shape makes discharge plausible rather than routine.

Position 398 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Iterate bases 2 to 16 with a for loop, skip primes by trial division, and for each non-prime base scan candidates n upward in a bounded while loop inside a procedure, storing hits in a ten-element array. Digit product uses a for loop of fixed maximum digit count with a cap guard, factor sum uses trial division with a for loop over divisors and an inner while that divides out each factor, and results are printed via Image with Put and Put_Line. About 90 lines.

## Proof obligations to watch

- **overflow**: The digit product is a loop-carried accumulator, so the loop caps it at a guard value above any possible base times factor sum, which keeps the Rhonda test faithful and keeps the multiplication within Integer.
- **overflow**: The factor sum is also loop-carried, but it is bounded by a subtype range and each addition is guarded or the sum is computed in a wide integer type, since the sum of prime factors never exceeds the candidate value.
- **termination**: Trial division and the candidate search are while loops, so they live in procedures (no termination check) and the search is capped at a documented limit with a visible 'not found' line if ten are not reached.
- **division**: Divisors are the base (at least 2) and the trial factor (at least 2), both visible from their subtypes or loop ranges.
- **index**: The results array is indexed only after a guard that the count is below ten.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first ten Rhonda numbers in base 10 for each non-prime base from 4 to 16.

Assessed on 2026-10-15 against page revision 413406 of the [task](https://rosettacode.org/wiki/Rhonda_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
