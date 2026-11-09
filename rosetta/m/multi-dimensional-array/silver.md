# Multi-dimensional array

**Candidate: proofs likely to discharge automatically.** All indexing uses static literals or for-loop indexes over the array's own ranges and values are small constants, so every check follows from types and bounds.

Position 652 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Declare a four-dimensional constrained Integer array type with index ranges 1..5, 1..4, 1..3 and 1..2, then initialize it to zero with four nested for loops over the array's own ranges. Set element (2,3,2,1) to a value, print it, set it to another value, print it, and print each extent and the language-storage statements as literal text. Every index is either a literal inside the static bounds or a for-loop index over the array's own range, so no guard is needed. About 45 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The program prints the array extents, the stored values and the explanatory statements.

Assessed on 2026-10-15 against page revision 414849 of the [task](https://rosettacode.org/wiki/Multi-dimensional_array) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
