# Sorting algorithms/Quicksort

**Candidate: proofs plausibly discharge automatically.** Quicksort restructured as an iterative, explicit-stack procedure over a fixed integer array has only range-typed indices and guarded loop-carried counters, so no annotation is needed, but the many loop-carried indices make discharge depend on careful guard placement.

Position 244 in the [progression](../../../progression.md#stage-8), in stage 8.

## Approach

Embed a constant array of about 10 integers in a small Index subtype, copy it to a variable, and sort in place with an iterative quicksort procedure that keeps pending (Lo, Hi) ranges on a fixed-capacity array stack and loops while the stack is non-empty. Each popped range with Lo < Hi is partitioned by Lomuto using a for loop over Lo .. Hi-1 with guarded increment of the store index and a swap, then the two sub-ranges are pushed only if non-empty and the stack has room, otherwise a documented rejection message is printed. The array is printed before and after via Put_Line of 'Image text. About 70 lines.

## Proof obligations to watch

- **index**: Lomuto partition indices and the explicit-stack pointer are loop-carried, so each increment, decrement and array access is preceded by a guard (I < Hi, Top < Capacity, Lo < Hi) rather than relying on an invariant.
- **overflow**: Lo-1 and Pivot+1 sub-range bounds and the middle-pivot computation Lo + (Hi - Lo) / 2 stay inside a small declared Index subtype, with explicit checks before subtracting or adding one.
- **stack**: Recursion is replaced by an explicit fixed-capacity stack of (Lo, Hi) pairs, and a full stack leads to a visible rejection outcome, so no input-dependent recursion depth exists.
- **termination**: The work-list while loop lives in a procedure, which gets no termination check, so no variant is needed.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, while loops, procedures, Put without a newline, 'Image of scalars, string building and integer division.

## External effects

- **console output** (allowed): The unsorted and sorted arrays are printed with Put_Line (and Put for single-line rows).

Assessed on 2026-10-15 against page revision 415545 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Quicksort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
