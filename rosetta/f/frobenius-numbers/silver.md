# Frobenius numbers

**Candidate: proofs likely to discharge automatically.** Everything is small bounded integer arithmetic in for loops with no loop-carried values needing invariants, so checks follow from range subtypes. The only non-trivial item is the output cutoff and number-to-text formatting, which are routine.

Position 322 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A function Is_Prime(N) uses a for loop over divisors 2 to N-1 (or up to a fixed bound) with an early-result flag; the main procedure loops over odd candidates 3..9999 with a for loop, tracking the previous prime in a variable of a bounded range subtype. For each new prime it computes F = Prev*P - Prev - P, which fits in Integer given the range, stops printing when F >= 10000 (the task says below 10,000), and prints each value with 'Image-based string building via Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: Primes are bounded by a range subtype up to 10000 so p*q - p - q fits in Integer, and the product is range-guarded before the output cutoff test.
- **termination**: Primality testing uses a for loop over a bounded range inside a function, so no while loop or variant is needed.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, functions, procedures, for loops, while loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 25 Frobenius numbers, one per line.

Assessed on 2026-10-15 against page revision 394962 of the [task](https://rosettacode.org/wiki/Frobenius_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
