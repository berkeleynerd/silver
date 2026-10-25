# Abundant odd numbers

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by declared ranges and guards (n at most about 1.1e9, sums well under 2**62) and the loops sit in procedures needing no variants, but loop-carried accumulators and the 64-bit nonlinear d*d need careful range shaping.

Position 246 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A procedure computes the proper divisor sum of an odd candidate by trial division with a while loop (d*d <= n, pairing d and n/d, handling perfect squares), using a 64-bit ranged accumulator guarded before each addition. The main procedure iterates odd candidates with counters in ranged subtypes, printing the first 25, the 1000th, and the first above 10**9 using 'Image and Put for fixed columns. About 90 lines.

## Proof obligations to watch

- **overflow**: The divisor-sum accumulator is loop-carried, so it uses a wide ranged subtype with a guard before each addition, and the sigma bound for n up to about 1.1e9 fits easily.
- **overflow**: The candidate counter advances by 2 in an outer loop, so it is a ranged subtype bounded well above 10**9 with a guard before each increment.
- **termination**: The trial-division and candidate-search while loops live in procedures, which get no termination check, so no variant is needed.
- **division**: The divisor d is a loop counter starting at 1 and incremented only under a guard, but its lower bound must come from its subtype since an invariant cannot be written.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, procedures, while loops, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the table of abundant odd numbers and their divisor sums.

Assessed on 2026-10-15 against page revision 414051 of the [task](https://rosettacode.org/wiki/Abundant_odd_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
