# Fibonacci sequence

**Candidate: proofs likely to discharge automatically.** Iterative Fibonacci uses a for loop with a guard before each addition, so overflow checks discharge without invariants and no recursion, while loops or annotations are needed. The 92-term limit is a documented resource bound with a specified rejection outcome.

Position 293 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

An iterative function over a subtype N_Range of 0..92 keeps two previous terms in 64-bit integer variables inside a for loop, with an explicit guard before each addition so it cannot overflow. A procedure loops N from 0 to 10 (the embedded example) and prints each result with 'Image through Put_Line; larger n is outside the stated range and is rejected. Negative n is optional and omitted. About 35 lines.

## Proof obligations to watch

- **overflow**: The loop-carried sum of the two previous terms is unbounded by type alone, so the program guards each addition against the 64-bit maximum and rejects with a visible outcome, which also documents the supported range of n up to 92.

## Language surface recorded by this assessment

Integers, ranged subtypes, for loops, functions, 'Image of scalars, string building and procedures.

## External effects

- **console output** (allowed): Prints each Fibonacci number with Put_Line.

Assessed on 2026-10-15 against page revision 415533 of the [task](https://rosettacode.org/wiki/Fibonacci_sequence) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
