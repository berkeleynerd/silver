# JortSort

**Candidate: proofs likely to discharge automatically.** All loops are for loops over the array's own index range and the only arithmetic is the J+1 index bounded by the loop range, so every check follows from types and static bounds; the function has no while loops or recursion, so no termination annotation is needed.

Position 326 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Define a fixed-length Integer array type of 8 elements, a procedure that bubble-sorts a copy using nested for loops and a temporary for swaps, and a Boolean function Jort_Sort that copies its argument, sorts the copy, and compares it element by element with a for loop. Main applies it to two embedded arrays (one sorted, one not) and prints a verdict with if/else and Put_Line. About 45 lines.

## Proof obligations to watch

- **index**: The bubble-sort inner access to J+1 is safe because the inner for loop bound is N-I with I in 1..N-1, which the provers derive from the loop index ranges without an invariant.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, procedures and functions.

## External effects

- **console output** (allowed): Prints a sorted or not-sorted verdict for each embedded example array with Put_Line.

Assessed on 2026-10-15 against page revision 412862 of the [task](https://rosettacode.org/wiki/JortSort) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
