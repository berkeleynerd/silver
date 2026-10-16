# Permuted multiples

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed-range for loops, bounded subtypes and small guards on the loop-carried counts, with no annotations or recursion, though the guard shape needs care; the answer 142857 lies well within the documented limit.

Position 912 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A Digit_Counts array indexed by 0..9 holds the digit histogram of a value, computed by a function using a fixed 8-iteration for loop with mod 10 and /10 on a Natural-ranged copy and guarded increments. The main for loop over n in 1 .. 1_000_000 compares the histogram of each of 2n..6n with that of 2n (via an inner for loop over i and digits) and exits on the first match, then prints n and its multiples with Integer'Image concatenation. If none is found within the documented limit it prints a not-found line. About 55 lines.

## Proof obligations to watch

- **overflow**: Digit counts are loop-carried and incremented without an invariant, so each increment is guarded by a comparison against the maximum digit count (at most 8) that never changes the result.
- **range**: The search runs n over a for loop bounded to 1 .. 1_000_000 so 6*n fits a declared subtype, and an explicit not-found line is the visible outcome when no n exists in the limit.
- **termination**: All loops are for loops with fixed ranges (digit extraction uses a fixed 8-position loop rather than a while loop on the value), so no variant is needed even inside functions.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints the found n and its multiples (or a not-found message) with Put_Line.

Assessed on 2026-10-15 against page revision 406126 of the [task](https://rosettacode.org/wiki/Permuted_multiples) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
