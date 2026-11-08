# Sorting algorithms/Patience sort

**Candidate: proofs plausibly discharge automatically.** Fixed-size arrays, for loops and subtype-bounded indices let nearly every check follow from types and guards just before use, but the loop-carried pile and link indices need careful guards, so the outlook is plausible rather than likely.

Position 120 in the [progression](../../../progression.md#stage-5), in stage 5.

## Approach

Embed the 25 example integers in a constant array; deal each element in a for loop by scanning the pile tops (stored as indices in a 0..25 array with a links array) for the first pile whose top is greater than or equal to it, opening a new pile when none is found and rejecting if capacity would be exceeded. Merge with a for loop of 25 steps that scans all piles for the smallest non-empty top, appends it to a sorted array, and pops that pile through the links array. Print both arrays with Put and 'Image in for loops. About 75 lines.

## Proof obligations to watch

- **range**: The pile count and the pile-top and link indices are loop-carried, so they are declared with subtypes 0..25 and every increment or array access is preceded by an explicit guard (pile count below 25, top index not 0) with a Reject outcome.
- **index**: Each array access through a stored pile top or link index is guarded by a non-zero test just before use, since no invariant ties these values to the 1..25 array range.
- **overflow**: Element values are held in a bounded integer subtype so comparisons and the image conversion cannot overflow.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the unsorted and sorted number lists with Put and Put_Line.

Assessed on 2026-10-15 against page revision 413042 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Patience_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
