# Sorting algorithms/Cocktail sort with shifting bounds

**Candidate: proofs plausibly discharge automatically.** Every check is about indexing with shifting bounds held in loop-carried variables, which discharge through widened types plus guards just before each access, and the while loop is in a procedure so no variant is required; the careful shape needed makes it plausible rather than likely.

Position 812 in the [progression](../../../progression.md#stage-15), in stage 15.

## Approach

The program holds the example ten Integers in a constrained array of a ranged index subtype, and a Cocktail_Sort procedure with in out array parameter runs a while loop with forward and reverse for loops using shifting bounds kept in variables over a widened range. Each swap and comparison is guarded by an explicit test that both indexes lie within the array, and the array is printed before and after with Put and Integer'Image into a bounded line via Put_Line. All of it lives in procedures called from Main. About 55 lines.

## Proof obligations to watch

- **index**: Loop-carried Begin_Idx and End_Idx are only known by type after the first iteration, so the program declares them as Integer-typed variables over a range wider than the array (0 .. N+1) and guards each use (Idx < End and Idx + 1 in bounds) just before indexing A(Idx+1).
- **range**: The updates End := NewEnd - 1 and Begin := NewBegin + 1 could leave the declared range, so the range is widened by one on each side and a guard clamps via loop exit when bounds cross, with no change to the sorted result.
- **termination**: The while loop sits in a procedure, which gets no termination check, so no variant is needed.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, while loops, procedures, Put without a newline, 'Image of scalars and case statements.

## External effects

- **console output** (allowed): Prints the unsorted and sorted embedded arrays as text lines.

Assessed on 2026-10-15 against page revision 414494 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Cocktail_sort_with_shifting_bounds) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
