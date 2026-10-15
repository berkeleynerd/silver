# Zsigmondy numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from subtype ranges and guards just before each multiply, divide and gcd step, and the divide-out method avoids divisor enumeration, but loop-carried accumulators in nested while loops make discharge depend on careful guard placement. The largest value, 7**20, fits in 64 bits, so the required 10 terms per radix set need no big numbers.

Position 715 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the 10 radix pairs in a constant 2D array and, for each pair and n = 1..20, compute p = a^n - b^n by a guarded multiply loop in a procedure. Then for each m < n compute q = a^m - b^m and, while gcd(z, q) > 1, divide z by that gcd (Euclid in a procedure), which yields the greatest divisor of p coprime to all earlier terms without any factorization. Print each result with scalar image and Put, one line per radix pair. About 90 lines.

## Proof obligations to watch

- **overflow**: Computing a**m by repeated multiplication in a loop-carried accumulator needs an explicit guard (acc <= Limit / a) before each multiply, with Limit above 7**20 so all required terms fit in 64-bit integers and larger input is rejected visibly.
- **range**: Dividing z by gcd g in a loop needs a guard (1 < g and g <= z) so the quotient stays within a positive subtype without an invariant.
- **termination**: Euclid's gcd and the divide-out loop use while loops, so they must be procedures (which have no termination check) rather than functions.
- **division**: Divisors in gcd and the divide-out step are guarded nonzero just before use; a^m - b^m is positive because a > b >= 1 is a subtype constraint.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints each radix pair's first 20 Zsigmondy numbers as text lines.

Assessed on 2026-10-15 against page revision 413140 of the [task](https://rosettacode.org/wiki/Zsigmondy_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
