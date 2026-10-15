# Sorting algorithms/Comb sort

**Candidate: proofs likely to discharge automatically.** Every index and arithmetic check follows from the array bounds, the bounded Gap subtype and for-loop ranges, with the only unbounded loop in a procedure where termination is not checked. The data are small fixed integers, so no annotation is needed.

Position 194 in the [progression](../../../progression.md#stage-9), in stage 9.

## Approach

The program holds the example values in a constrained Integer array of fixed length 7 and keeps the gap as a subtype Integer range 1 .. 7 in a Main-level while loop that exits when Gap = 1 and no swap occurred. Each pass shrinks the gap by integer division (Gap * 4 / 5) clamped to at least 1, runs a for loop I in 1 .. N - Gap comparing and swapping Data (I) and Data (I + Gap) through a temporary, then prints the elements with Put of the image and Put_Line at the end. About 35 lines.

## Proof obligations to watch

- **termination**: The outer exit-when-sorted loop sits in the Main procedure, which gets no termination check, so no variant is needed.
- **overflow**: The gap update Gap * 4 / 5 stays in Integer range because Gap is a subtype bounded by the array length, and a guard clamps the result to at least 1.
- **index**: Index I + Gap is safe because the for loop runs I from 1 to N - Gap, which gives I + Gap <= N, and the outer for-loop index range comes from the array bounds.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the sorted example array to standard output.

Assessed on 2026-10-15 against page revision 414495 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Comb_sort) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
