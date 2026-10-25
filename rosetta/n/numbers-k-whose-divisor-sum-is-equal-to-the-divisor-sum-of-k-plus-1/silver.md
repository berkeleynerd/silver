# Numbers k whose divisor sum is equal to the divisor sum of k + 1

**Candidate: proofs plausibly discharge automatically.** Everything is small integer arithmetic with for-loop indexes and a capped accumulator guard, so it should discharge with careful program shape, though the accumulator and search limit need explicit guards. No annotations, recursion, or exotic effects are needed beyond console output.

Position 901 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

A function Sigma(N) loops I in 1 .. N with trial division (N mod I = 0), adding I to a guarded accumulator typed as a range-bounded integer; a Main procedure scans K from 1 upward in a while loop bounded by a fixed search limit, comparing Sigma(K) and Sigma(K+1) and counting matches until 50. Each hit is printed with Put_Line using the count and K images; reaching the limit before 50 prints a specified failure line. The full trial-division loop over 1 .. N avoids the square-root bound, which needs floating point or nonlinear reasoning. About 45 lines.

## Proof obligations to watch

- **overflow**: The divisor-sum accumulator is loop-carried with no invariant, so each addition is guarded against a declared 64-bit-range cap, and exceeding the cap yields a visible rejection rather than a changed result.
- **range**: The scan counter K and found count are bounded by an explicit search limit and a count limit checked in the loop condition, with a visible failure message if the limit is reached before 50 members.
- **termination**: The search uses a while loop inside a procedure (no termination check), while the divisor-sum function uses only a for loop, so no variant is needed.
- **division**: The mod divisor is the for-loop index starting at 1, so it is statically nonzero.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, functions, 'Image of scalars, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints the 50 members, one line each, with Put_Line.

Assessed on 2026-10-15 against page revision 401058 of the [task](https://rosettacode.org/wiki/Numbers_k_whose_divisor_sum_is_equal_to_the_divisor_sum_of_k_%2B_1) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
