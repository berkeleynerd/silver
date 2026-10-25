# Summarize primes

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic in for loops with guarded accumulators, so no annotation is needed, but the loop-carried sum and count need careful guards and the output formatting needs bounded string building.

Position 369 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A function Is_Prime uses a for loop over divisors 2 up to N-1 with a guard for N below 2, avoiding any sieve array or while loop. The main procedure loops candidates 2..999, and for each prime adds it to a subtype-bounded running Sum and Count after guarded range checks, then calls Is_Prime on the Sum and prints Count, the prime and Sum using Image text with fixed separators. Trial division over about 168 sums up to 76127 is fast enough, so no nonlinear arithmetic or invariants are needed. About 55 lines.

## Proof obligations to watch

- **overflow**: The running sum and count are loop-carried, so each addition is preceded by an explicit guard against the declared subtype bounds (80000 and 1000) that rejects visibly and never triggers in practice.
- **range**: The primality function tests any candidate up to 80000 using for-loop divisors from 2 to the candidate minus 1, so index and mod checks follow from the loop range and a guard for candidates below 2.
- **length**: Each output line is built in a fixed-size String buffer from the Image of three bounded integers, so the concatenation length must be provably within the buffer, which needs bounded subtypes and careful padding.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints one line per qualifying sequence with its length, last prime and sum.

Assessed on 2026-10-15 against page revision 412042 of the [task](https://rosettacode.org/wiki/Summarize_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
