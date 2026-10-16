# Matrix multiplication

**Candidate: proofs likely to discharge automatically.** All indices come from the arrays' own ranges and the bounded element subtype makes every product sum overflow-free without an invariant, so the checks are routine; the open work is admitting multidimensional arrays and number formatting.

Position 656 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Declare a ranged element subtype, constrained 2x3 and 3x2 matrix constants embedded in the program, and a 2x2 result array, with the dimension compatibility fixed statically by the index types. Compute each result cell with for loops over the result's own index ranges using an unrolled three-term dot product, then format each row from Integer'Image pieces into a bounded buffer and print it with Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: Elements are a subtype of -1000..1000 and the 3-term inner product is written as one unrolled expression, so no loop-carried accumulator is needed and the sum stays far below Integer'Last.
- **length**: Each output row is built in a bounded buffer sized for the worst-case image widths, with the length known from the fixed element range.

## Language surface recorded by this assessment

Integers, ranged subtypes, multidimensional arrays, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints the product matrix one row per line.

Assessed on 2026-10-15 against page revision 411623 of the [task](https://rosettacode.org/wiki/Matrix_multiplication) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
