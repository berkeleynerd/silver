# Pascal matrix generation

**Candidate: proofs likely to discharge automatically.** All indices come from for loops over the array's own ranges and cell sums are bounded by the declared cell range plus a visible guard, so every check follows from types and local guards; only the row-formatting buffer arithmetic needs careful shape.

Position 894 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Use a constrained 0..4 by 0..4 array of a ranged cell subtype and three functions (upper, lower, symmetric) that fill it with for loops using the recurrence C(a,b)=C(a-1,b-1)+C(a,b-1) with guarded sums, or the symmetric recurrence from the left and upper neighbours. A procedure prints a heading then each row as one Put_Line of a bounded buffer assembled from fixed-width right-aligned images of the cells, so rows and matrices are visibly distinguished. Everything is embedded for n=5, with no input. About 90 lines.

## Proof obligations to watch

- **overflow**: The additions of two neighbouring cells inside the loops are discharged by giving cells a declared range (such as 0..1_000_000) so the sum cannot overflow Integer.
- **range**: Storing a sum back into a ranged cell is discharged by an explicit guard before the assignment that rejects the run if the sum exceeds the cell limit, a branch never taken for 5-by-5.
- **length**: Row text is built in a fixed buffer with a per-cell width, and the 5-cell bound with a maximum image length keeps every slice and concatenation within the buffer.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, functions, procedures, 'Image of scalars, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints a heading line and one line per matrix row for each of the three 5-by-5 matrices.

Assessed on 2026-10-15 against page revision 413836 of the [task](https://rosettacode.org/wiki/Pascal_matrix_generation) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
