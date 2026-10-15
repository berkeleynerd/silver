# Sum of primes in odd positions is prime

**Candidate: proofs likely to discharge automatically.** Every check follows from bounded subtypes, fixed for-loop bounds and a guard before the one loop-carried addition, and no while loop or recursion is needed. Only new surface (functions, integers, loops, 'Image) is required, with no annotations.

Position 769 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

A function Is_Prime on a bounded Natural subtype (up to 100000) tests divisibility by a for loop over 2 .. 316 with a guard d*d <= n before the mod. The main procedure runs a for loop p over 2 .. 999, counts the prime index i, and on odd i adds p to a bounded sum after a guard, then prints i, p and sum if the sum is prime. Numbers are rendered with 'Image and printed with Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: The running prefix sum is loop-carried, so it is declared in a bounded range subtype and an explicit guard before each addition rejects the case where the sum would exceed the bound, which never happens for primes below 1000 (total 76127).
- **range**: Trial division uses a for loop up to a fixed bound of 281 with a guard d*d <= n, so the product d*d stays within the declared range and the modulus is never zero.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, case statements, 'Image of scalars, string building, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints one line per qualifying index, prime and prefix sum.

Assessed on 2026-10-15 against page revision 400625 of the [task](https://rosettacode.org/wiki/Sum_of_primes_in_odd_positions_is_prime) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
