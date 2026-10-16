# Sorting algorithms/Merge sort

**Candidate: proofs plausibly discharge automatically.** Everything is a fixed-size array sorted by index arithmetic in procedures, so checks reduce to guarded cursor comparisons and bounded subtypes, though several loop-carried indices need careful guard placement without invariants.

Position 919 in the [progression](../../../progression.md#stage-16), in stage 16.

## Approach

Embed an 8-element array of Integer, and implement merge sort bottom-up and iteratively in a procedure: a while loop doubles the run width, an inner loop walks run pairs, and a merge loop copies from the source array into a scratch array using guarded cursors before copying the scratch array back. The recursive top-down form is replaced by this equivalent bottom-up divide-and-conquer, and the lists are printed before and after via bounded string building with 'Image. About 70 lines.

## Proof obligations to watch

- **index**: The merge cursors and run boundaries are loop-carried, so each array access is preceded by an explicit guard that the cursor is within the run and within the array bounds, with cursor subtypes capped at N+1.
- **overflow**: The doubling width and run-end computations (start + 2*width) are discharged by clamping to N before use and by subtype ranges bounded by N.
- **termination**: All while loops are inside procedures, which get no termination check, and the pass loop is bounded by a width that doubles up to N.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building, Boolean objects and conditional expressions.

## External effects

- **console output** (allowed): Prints the unsorted and sorted lists as text lines.

Assessed on 2026-10-15 against page revision 414501 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Merge_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
