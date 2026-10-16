# Matrix transposition

**Candidate: proofs likely to discharge automatically.** Every index is a for-loop variable over the array's own static ranges and the only arithmetic is copying elements, so all checks follow from declarations and no loop-carried value needs an invariant. The arbitrary-size requirement is met by documented fixed bounds.

Position 650 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Declare a constant 3-by-4 Integer matrix with the example values (tenths scaled to integers, avoiding floating point) and a 4-by-3 result array, then fill the result with nested for loops over the source array's own index ranges so Result(J, I) := Source(I, J). A print procedure walks each matrix with for loops, emitting each element via Integer'Image with Put and ending rows with Put_Line, once before and once after transposition. About 40 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, 'Image of scalars, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints the matrix before and after transposition as text rows.

Assessed on 2026-10-15 against page revision 414332 of the [task](https://rosettacode.org/wiki/Matrix_transposition) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
