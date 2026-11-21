# Unprimeable numbers

**Candidate: proofs likely to discharge automatically.** Every check follows from small bounded subtypes, for-loop-only primality testing in a function, and a count guard before array stores, so no annotations are needed. The nonlinear digit arithmetic is bounded by subtypes and the place guard, making discharge likely.

Position 366 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Declare a subtype Num 0..9999, a function Is_Prime using a for loop over divisors 2..99, and a procedure that, for each N in 2..9999, tries replacing each decimal digit at places 1, 10, 100, 1000 (only those not exceeding N) with 0..9 and records N in a 600-element array when no variant is prime, guarding the count before each store. The main body then prints a title, the first 35 entries with Put, and the 600th entry via 'Image; the search limit 9999 covers the 600th value 5242, and a visible message is printed if fewer than 600 were found. The optional per-last-digit minima are omitted because some exceed 1,000,000 and would need a much larger bound. About 80 lines.

## Proof obligations to watch

- **overflow**: Digit replacement computes N - digit*place + d*place on a subtype bounded to 0..9999, with the place restricted to 1, 10, 100 or 1000 and at most N, so the result stays within 0..9999 by type ranges and a guard.
- **range**: The array of 600 results is indexed by a count that is guarded to be below 600 before each store, which is needed because the count is loop-carried and has no invariant.
- **termination**: Primality uses a for loop over divisors 2..99 (since 99*99 exceeds 9999) inside a function, so no variant is needed, and the outer search is a for loop over 1..9999.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints a title line, the first 35 unprimeable numbers on one line, and the 600th.

Assessed on 2026-10-15 against page revision 414565 of the [task](https://rosettacode.org/wiki/Unprimeable_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
