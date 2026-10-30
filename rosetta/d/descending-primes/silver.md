# Descending primes

**Candidate: proofs plausibly discharge automatically.** The task is bounded (1023 candidates, at most 10 digits) with no recursion or heap, so every check follows from types and for-loop bounds, but the loop-carried number construction and 64-bit arithmetic need careful guards.

Position 357 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Enumerate every non-empty subset of the digits 0..9 as a mask from 1 to 1023, using a constant array of powers of two; for each mask, build the number by scanning digits 9 down to 0 and appending those present, with a guard before each multiply by 10. Test primality with a function that trial-divides by a for loop to 99999 (exiting once d*d exceeds the value), and print each prime with 'Image through Put_Line. Results can be printed in mask order or ordered by length by looping over digit count. About 45 lines.

## Proof obligations to watch

- **overflow**: The loop-carried value (value*10 + digit) is only bounded by its type after the first iteration, so it needs a 64-bit type with an explicit guard just before the multiplication (or a precomputed place-value table) to prove no overflow.
- **range**: Numbers reach 9876543210, beyond 32-bit Integer, so a 64-bit integer type is required and the conversion to a narrower digit subtype must be guarded.
- **termination**: Trial division uses a for loop with an early exit and a fixed divisor ceiling of 99999, so the function needs no variant.
- **overflow**: The square test d*d is safe because d is bounded by the for-loop range, so the product fits in 64 bits.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each prime with strictly descending digits, one per line or in bounded text lines.

Assessed on 2026-10-15 against page revision 414152 of the [task](https://rosettacode.org/wiki/Descending_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
