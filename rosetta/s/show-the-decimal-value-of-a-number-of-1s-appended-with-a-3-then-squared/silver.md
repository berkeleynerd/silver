# Show the (decimal) value of a number of 1s appended with a 3, then squared

**Candidate: proofs likely to discharge automatically.** The task is eight fixed values with a single squaring, so overflow and index checks follow directly from the declared subtype ranges and the for loop over the array's own range. The only new needs are integer-to-text conversion and bounded string building.

Position 76 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

Hold the eight roots (3, 13, 113, ..., 11111113) as a constant array of a ranged 64-bit integer subtype indexed 0..7, then loop over the array's own range with a for loop, squaring each root and printing the root and its square through 'Image with Put_Line. There is no loop-carried state, so every check follows from the subtype bounds. About 35 lines.

## Proof obligations to watch

- **overflow**: Each root is at most 111111113, so the square is at most about 1.3e16, which fits in a 64-bit range type and is checked from the declared subtype bounds.
- **length**: The line buffer is sized for two 'Image results plus separators, and each Image length is bounded by the subtype range so the concatenation fits.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints eight lines, one per n, showing the number and its square.

Assessed on 2026-10-15 against page revision 407865 of the [task](https://rosettacode.org/wiki/Show_the_%28decimal%29_value_of_a_number_of_1s_appended_with_a_3,_then_squared) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
