# Sexy primes

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds, ranged subtypes and guards placed just before each access, with no function-level loops needing variants, but the sieve's loop-carried index and the many look-ahead guards need careful program shape.

Position 294 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A Boolean array indexed 0..1_000_040 holds a sieve of Eratosthenes built in a procedure with a while loop for composite marking, whose multiple variable is a ranged subtype guarded against the limit. A for loop over the primes below 1_000_035 classifies each prime by testing p+6, p+12, p+18, p+24 and p-6 with explicit bound guards, accumulating the pair, triplet, quadruplet, quintuplet and unsexy counts. A backward scan collects the last five of each group type and the last ten unsexy primes into small fixed arrays, then prints them ascending using Integer'Image concatenation. About 130 lines.

## Proof obligations to watch

- **overflow**: The sieve's loop-carried multiple is declared in a range up to twice the limit and guarded by a test against the limit before each use, so the addition and the index both discharge from types and the guard.
- **index**: Look-ahead and look-behind reads such as p+12 and p-6 are each guarded by an explicit bound test just before the access, and the sieve is sized past the limit to cover p+6.
- **range**: Counters and the found-so-far count for the last-five lists are subtypes bounded by the limit and guarded by a test before each increment, so they cannot exceed their ranges.
- **stack**: A million-element Boolean sieve is a fixed-size local array and its stack use is outside what GNATprove checks, so it rests on the fixed-memory premise.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the counts and the last few groups of each kind as lines of text.

Assessed on 2026-10-15 against page revision 415159 of the [task](https://rosettacode.org/wiki/Sexy_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
