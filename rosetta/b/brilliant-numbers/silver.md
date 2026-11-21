# Brilliant numbers

**Candidate: proofs likely to discharge automatically.** All arithmetic stays within small declared ranges (n up to about 1.1 million, divisors up to about 1,010, a sieve to 10,000) using only for loops and guards in procedures, so every check follows from types and guards and no annotation is needed.

Position 1537 in the [progression](../../progression.md#stage-32), in stage 32.

## Approach

Embed a sieve of primes up to 10_000 as a Boolean array built with nested for loops (i in 2..100, j in 2..10_000/i), then a single for loop over n in 4..1_100_000 in a procedure that scans a candidate factor p in 2..1_010 for the smallest divisor, requiring the cofactor q=n/p to be a sieve-prime below 10_000 with the same digit count as p (digit counts via comparison against powers of ten). Each brilliant number is counted behind a guard on a capped Natural counter; the first 100 are printed six per line and the first at or above each of 10^1..10^6 is printed with its position using scalar images and unterminated Put. About 90 lines.

## Proof obligations to watch

- **overflow**: The brilliant-number counter and the products i*j in the sieve are bounded by a capped counter type with a guard before each increment and by the loop ranges i<=100 and j<=10_000/i, so no overflow check needs a loop invariant.
- **division**: The divisor p comes from a for-loop index starting at 2 and the found-factor variable is only used for n/p behind a guard p /= 0, so the division check follows from the guard.
- **index**: The sieve index q is checked to be at most 10_000 by the digit-count test before use as an array index, so the index check follows from a guard just before the lookup.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline and membership tests.

## External effects

- **console output** (allowed): Prints the first 100 brilliant numbers and the order-of-magnitude table to standard output.

Assessed on 2026-10-15 against page revision 414753 of the [task](https://rosettacode.org/wiki/Brilliant_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
