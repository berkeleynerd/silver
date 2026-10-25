# Sorting algorithms/Gnome sort

**Candidate: proofs likely to discharge automatically.** Gnome sort is a small while loop over a fixed 10-element array whose indices are bounded by types and guards just before each access, and it sits in a procedure so no variant is needed.

Position 199 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

Embed a constant 10-element Integer array in a fixed-range indexed array variable, then run gnome sort inside a Main procedure using a while loop with integer indices I and J (both ranged Integer subtypes) and a Temp swap variable. Guards before every a(I-1)/a(I) access keep indexes in range, and the loop is in a procedure so no termination check applies. Print the array before and after using Integer'Image concatenated into a bounded String buffer and Put_Line. About 45 lines.

## Proof obligations to watch

- **index**: The loop-carried index I is typed Positive-ranged and each array access is guarded by explicit tests (I >= 2 and I <= size) just before use, so the checks discharge without an invariant.
- **overflow**: The counter J is bounded by a guard (J <= Size + 1) with an explicit visible outcome of stopping, and since the Size is 10 the sort cannot exceed it in practice, but the guard is what lets the prover accept J + 1.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, while loops, 'Image of scalars, string building, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints the array before and after sorting.

Assessed on 2026-10-15 against page revision 414498 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Gnome_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
