# Sorting algorithms/Pancake sort

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static ranges and every loop-carried index has a subtype that bounds it, so index and range checks follow from types and the program needs no annotations. The only nontrivial part is the swap index arithmetic, which is linear and bounded.

Position 153 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

A constrained array of 8 Integers indexed by a subtype 1 .. 8 holds the embedded sample data, and a procedure Flip reverses the prefix up to a given index by swapping pairs in a for loop. The sort uses nested for loops, with the inner loop tracking the largest position in an index-typed variable, then flips it to the front and then to its final position, guarded by the usual inequality tests. The program prints the list before and after sorting through a bounded text buffer and Put_Line. About 45 lines.

## Proof obligations to watch

- **index**: The in-place flip swaps Data(I) with Data(Up_To+1-I) for I in 1 .. Up_To/2, which stays within 1 .. Up_To because Up_To is a subtype-bounded index, a small linear fact provers discharge.
- **length**: The printed line is built by appending Integer'Image of each of 8 elements into a bounded buffer sized for 8 maximum-width images, so the capacity is a static bound.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the initial and final lists to standard output.

Assessed on 2026-10-15 against page revision 414502 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Pancake_sort) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
