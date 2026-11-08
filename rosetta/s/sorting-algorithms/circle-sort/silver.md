# Sorting algorithms/Circle sort

**Candidate: proofs plausibly discharge automatically.** Every array access is bounded by declared index ranges and guards before use, and the recursion can be replaced by a bounded explicit stack inside procedures, so nothing needs an annotation, but the loop-carried segment bounds and stack pointer need careful guard placement.

Position 242 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

Hold the 15 embedded integers in a constrained array and sort it in a procedure that replaces the recursion with an explicit fixed-capacity stack of (lo, hi) segment pairs, pushing the two halves after each compare-and-swap sweep and guarding stack capacity. An outer while loop repeats whole passes until a pass makes zero swaps, and the unsorted and sorted lists are printed with a for loop over the array using Integer'Image and Put. About 70 lines.

## Proof obligations to watch

- **index**: Segment bounds and the lo+1 and hi-1 stepping are loop-carried, so lo, hi and the hi+1 comparison are held in a ranged subtype wider than the array index range and guarded just before each array access.
- **overflow**: The segment stack pointer and swap counter are loop-carried, so the counter is a bounded range reset each pass and pushes are guarded by a capacity check.
- **termination**: The pass-until-no-swaps and segment loops are while loops in procedures, which get no termination check, and the sort lives in a procedure rather than a function.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints the initial unsorted list and the final sorted list.

Assessed on 2026-10-15 against page revision 414492 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Circle_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
