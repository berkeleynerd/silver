# Sorting algorithms/Counting sort

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared subtypes and short guards, but the loop-carried write position and the count increments need a guard each, so the proof depends on careful program shape rather than being fully routine.

Position 82 in the [progression](../../../progression.md#stage-6), in stage 6.

## Approach

The program embeds a constant 30-element array of values in the subtype 0 .. 99, builds a count array indexed 0 .. 99 with a bounded count subtype, then rewrites the output array by walking the count array with nested for loops and a guarded write position. It prints the before and after lists with 'Image into bounded buffers, using a procedure with Put_Line. Min and max are the known a priori range 0 .. 99, so no min/max scan is needed. About 55 lines.

## Proof obligations to watch

- **overflow**: Each count is a subtype bounded by the array length (0 .. 30) and is incremented only under an explicit guard against that bound, so the increment cannot overflow.
- **index**: The write position in the output pass is a loop-carried value, so it is guarded with a visible rejection outcome before each store, and the value-indexed count access is safe because input values have a subtype 0 .. 99 that matches the count array's index range.
- **range**: The inner for loop runs over 1 .. Count(I), which is bounded by the count subtype, so no accumulator needs an invariant.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, Put without a newline, string building and procedures.

## External effects

- **console output** (allowed): Prints the unsorted and sorted lists of numbers to standard output.

Assessed on 2026-10-15 against page revision 414496 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Counting_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
