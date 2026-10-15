# Josephus problem

**Candidate: proofs likely to discharge automatically.** The O(n) recurrence needs only a for loop and a bounded mod, so every check follows from declared ranges and the loop index with no annotation needed.

Position 112 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Embed N = 41 and K = 3 as constants and compute the survivor with the iterative recurrence J(1) = 0, J(i) = (J(i-1) + K) mod i in a for loop over 2 .. N, holding J in a ranged subtype 0 .. N-1. Print the final survivor (0-based, stated in the output) with Put_Line using 'Image concatenation; the optional extra of m survivors is omitted. About 22 lines.

## Proof obligations to watch

- **range**: The loop-carried survivor index is a subtype 0 .. 40 and the assignment (J + K) mod I is bounded by I - 1 <= 40 because I is a for-loop index in 2 .. 41, which the provers handle without an invariant.
- **division**: The mod divisor I is the for-loop index starting at 2, so it is statically nonzero.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the survivor number with Put_Line.

Assessed on 2026-10-15 against page revision 414279 of the [task](https://rosettacode.org/wiki/Josephus_problem) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
