# Sorting algorithms/Cocktail sort

**Candidate: proofs likely to discharge automatically.** Every index I and I+1 lies within the static range 1..32 because the for loops run over literal bounds inside the string's own range, and the outer loop sits in a procedure with only a Boolean carried across iterations, so no invariant is needed.

Position 488 in the [progression](../../../progression.md#stage-10), in stage 10.

## Approach

Main holds the 32-character example as a fixed-length String variable and a Boolean Swapped flag, then runs an outer loop with exit when not Swapped containing a forward for loop and a reverse for loop over 1 .. 31, each comparing and swapping adjacent characters via a Character temporary. The sort is inlined in Main so all bounds are static literals, and Data is printed before and after. About 32 lines.

## Language surface recorded by this assessment

String indexing, characters, Boolean objects, for loops and while loops.

## External effects

- **console output** (allowed): Prints the string before and after sorting with Put_Line.

Assessed on 2026-10-15 against page revision 414493 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Cocktail_sort) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
