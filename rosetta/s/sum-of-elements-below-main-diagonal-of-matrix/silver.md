# Sum of elements below main diagonal of matrix

**Candidate: proofs likely to discharge automatically.** All indexes come from for-loop ranges within static array bounds, and the accumulator addition is bounded by the element subtype and the fixed 25-element count, so no annotation is needed.

Position 649 in the [progression](../../progression.md#stage-13), in stage 13, which adds multidimensional arrays.

## Approach

Embed the 5x5 matrix as a constant two-dimensional array of a small integer subtype, indexed by a 1..5 subtype. Use nested for loops where the inner range is 1 .. Row - 1, so every index comes from the array's own range, accumulate into an Integer, and print the label and 'Image of the sum with Put_Line. About 25 lines.

## Proof obligations to watch

- **overflow**: The accumulator is a loop-carried value, but it is declared with a bounded range wide enough for 25 elements of at most 20 each, or the elements are a small subtype, so the addition check follows from types.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the sum 69 as a line of text.

Assessed on 2026-10-15 against page revision 414531 of the [task](https://rosettacode.org/wiki/Sum_of_elements_below_main_diagonal_of_matrix) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
