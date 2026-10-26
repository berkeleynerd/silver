# Sorting algorithms/Cycle sort

**Candidate: proofs likely to discharge automatically.** Every array index and counter is bounded by a fixed-length index subtype and the loop-carried position can be guarded in the loop condition, so no annotation is needed. The procedure form avoids termination checks, and the only care needed is the duplicate-skip and cycle-rotation guards.

Position 1530 in the [progression](../../../progression.md#stage-31), in stage 31.

## Approach

Embed the two example integer arrays as constant aggregates copied into fixed-size ranged-index array variables, and sort them in place with a procedure implementing cycle sort using for loops to count smaller items and while loops to skip duplicates and rotate cycles, with the write count as an out parameter. Print each array before and after using a bounded text buffer built from 'Image of each element and Put_Line, together with the write count. About 70 lines.

## Proof obligations to watch

- **index**: The duplicate-skipping while loop indexes array(position) with a loop-carried position, so a guard 'position < Last' is placed in the loop condition and an out-of-range exit is a specified outcome (stop skipping), which is safe because an equal item is always found within the array in correct runs.
- **overflow**: Position and the write counter are declared as ranged subtypes bounded by the fixed array length so increments cannot overflow, with the counter guarded before each increment.
- **termination**: All loops are in procedures, which get no termination check, and the cycle-rotation while loop is bounded by a guard on the write counter at the array length.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, 'Image of scalars, string building, for loops, while loops, procedures, Put without a newline and block statements.

## External effects

- **console output** (allowed): Prints the array before sorting, the write count, and the sorted array.

Assessed on 2026-10-15 against page revision 414497 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Cycle_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
