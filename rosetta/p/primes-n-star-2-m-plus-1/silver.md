# Primes: n\*2^m+1

**Candidate: proofs plausibly discharge automatically.** The core 45 results fit in 64-bit integers so every check follows from types and a bound guard, but loop-carried doubling and trial-division bounds need careful guards; the stretch tasks would need big numbers and are optional.

Position 368 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

For n in 1..45 (the core task, whose largest answer is 1217) a for loop searches m in a small bounded range, doubling a Long_Long_Integer candidate under an explicit size guard and testing n*2^m+1 with a trial-division function using a for loop over divisors up to the candidate. Each result line is built from 'Image texts and printed with Put_Line, and a search that exhausts the bound ends in a specified rejection. The stretch parts (n=47 needs m=583, n up to 400 needs far larger) would need a fixed-capacity big-number library with modular multiplication and Miller-Rabin and are left optional. About 55 lines.

## Proof obligations to watch

- **overflow**: The doubling of the loop-carried candidate n*2^m is guarded by a visible bound check (reject beyond 10**9) so the 64-bit product and the +1 cannot overflow.
- **termination**: The trial-division primality test is a for loop over a divisor range bounded by the candidate, and the m search is a bounded for loop, so no function needs a variant.
- **division**: The mod divisor is a loop index starting at 2, so its non-zero range follows from the loop bounds.
- **length**: Concatenating the 'Image texts into a bounded output line needs a buffer size that covers the longest line, which is a static bound.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, while loops, 'Image of scalars, string building, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints one line per n giving n, the smallest m and the prime n*2^m+1.

Assessed on 2026-10-15 against page revision 414418 of the [task](https://rosettacode.org/wiki/Primes:_n%2A2%5Em%2B1) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
