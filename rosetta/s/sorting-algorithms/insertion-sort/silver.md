# Sorting algorithms/Insertion sort

**Candidate: proofs likely to discharge automatically.** Every check follows from the index subtype and the J > 0 guard evaluated just before use, and the while loop sits in a procedure so no variant is needed, hence no annotation is required.

Position 191 in the [progression](../../../progression.md#stage-8), in stage 8.

## Approach

An embedded constant-initialised variable array of 10 Integers indexed 1 .. 10 is sorted in place by a for loop I in 2 .. 10 holding Value := A(I) and J of subtype 0 .. 9 set to I-1, then a while loop with condition J > 0 and then A(J) > Value shifts A(J) up and decrements J. After the loop A(J+1) := Value, and a final for loop prints each element via Integer'Image through Put_Line, all inside Main, so no termination check applies. About 30 lines.

## Proof obligations to watch

- **index**: The loop-carried shift index J is declared with a subtype 0 .. N-1, so A(J+1) stays within 1 .. N from its type alone and A(J) and J-1 are guarded by J > 0 in the while condition, with no invariant needed.
- **overflow**: The Integer values are only compared, copied and printed (no arithmetic on them), and index arithmetic is bounded by the small index subtypes.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, while loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the sorted integers with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414500 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Insertion_sort) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
