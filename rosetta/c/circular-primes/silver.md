# Circular primes

**Candidate: proofs plausibly discharge automatically.** All checks follow from fixed type ranges, for-loop indexes and a bounded trial-division loop, but the digit-rotation arithmetic needs careful shaping so loop-carried values stay in range without invariants. The big-number repunit and stretch parts are optional and omitted.

Position 382 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Restrict the 19-prime part to Integer arithmetic (largest result 199933, all rotations below 1,000,000) and skip the optional arbitrary-precision repunit parts. A function Is_Prime uses a for loop with exit over divisors up to 999; a function Is_Circular extracts the digits of a candidate into a six-element array, rotates through indexes with a for loop, recomposes each rotation, rejects any rotation that is smaller than the candidate or not prime, and the Main procedure loops over candidates and prints each hit via Put_Line of the image until 19 are found. About 70 lines.

## Proof obligations to watch

- **overflow**: Rotation and digit-recomposition arithmetic is loop-carried, so it is kept in a subtype bounded to six digits (values below 1,000,000) with a digit array so each product and sum is bounded by types and guards.
- **range**: The search is a for loop over a fixed candidate range with a count guard, since 199933 is the largest result, so no unbounded counter is needed.
- **termination**: Primality is trial division in a for loop over 2..999 with an early exit when d*d exceeds the candidate, so no while loop or variant is needed inside a function.
- **division**: Divisors are loop indexes starting at 2 and powers of ten are constants, so every division and mod has a statically nonzero divisor.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, functions, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each of the first 19 circular primes to standard output.

Assessed on 2026-10-15 against page revision 414640 of the [task](https://rosettacode.org/wiki/Circular_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
