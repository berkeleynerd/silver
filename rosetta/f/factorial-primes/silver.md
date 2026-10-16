# Factorial primes

**Candidate: proofs plausibly discharge automatically.** All values for the first 10 factorial primes (up to 87178291199) fit in 64-bit integers, and every check follows from subtype ranges and a guard before the multiply, so no annotation is needed. Plausible rather than likely because of the guarded loop-carried factorial and the nonlinear square in trial division.

Position 377 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Iterate n from 1 to 20 in a for loop, keeping the factorial in a subtype ranged to 2**62 and multiplying only after a division guard, then test Fact-1 and Fact+1 with an Is_Prime function that does trial division over a for loop on 2..3_037_000_499 with exit when D*D exceeds N. Each hit increments a bounded counter and prints a line built from 'Image of the index, n, the sign and the value with Put_Line, exiting after ten. The stretch part with big integers is left out as optional. About 60 lines.

## Proof obligations to watch

- **overflow**: The running factorial is loop-carried, so each step is guarded by a comparison against Long_Long_Integer'Last divided by the multiplier, with a visible stop outcome if the guard fails (20! fits, so the required output is unaffected).
- **overflow**: Trial-division squares D*D are safe because the for-loop index is typed 2..3_037_000_499, whose square fits in 63 bits.
- **termination**: Primality uses a for loop with an early exit (no while inside a function), and the outer search is a bounded for loop over 1..20 with exit once ten primes are found.
- **other**: Count reaching 10 relies on Count being a bounded subtype incremented only after a guard, since no invariant ties it to the loop.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, 'Image of scalars, procedures and while loops.

## External effects

- **console output** (allowed): Prints one line per factorial prime with its index, n, the sign and the value.

Assessed on 2026-10-15 against page revision 411961 of the [task](https://rosettacode.org/wiki/Factorial_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
