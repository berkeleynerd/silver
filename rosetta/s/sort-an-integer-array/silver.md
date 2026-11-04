# Sort an integer array

**Candidate: proofs likely to discharge automatically.** Sorting a fixed-size array by comparisons and swaps needs only for-loop indexes over the array range and no arithmetic on element values, so every check follows from types and bounds. The standard generic sort library is not available in Silver, so a hand-written O(n^2) sort in a procedure is used.

Position 86 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

The program embeds a constrained array of 9 integers (the example data) and sorts it in place with insertion sort or selection sort in a procedure using nested for loops over the index subtype. A swap uses a temporary Integer, and the inner step for insertion sort is written with explicit index guards, or as selection sort it uses only for-loop indexes. It then prints each element on its own line using 'Image and Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: Integer elements are only compared and swapped, never added, so no arithmetic can overflow.
- **index**: Insertion sort uses for loops over the array's own index range, with the inner index guarded just before each use, so the index checks follow from types and guards.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, Put without a newline, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Print the sorted array so the result is visible.

Assessed on 2026-10-15 against page revision 414484 of the [task](https://rosettacode.org/wiki/Sort_an_integer_array) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
