# Magic squares of singly even order

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-size for-loop and mod arithmetic over small declared ranges, so index and range checks follow from types, but the loop-carried Siamese position and swap indexes need careful subtyping, hence plausible rather than likely.

Position 694 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Fixed n=6 with a 6x6 array of subtype 1..36; build the 3x3 odd magic square by the Siamese method with a for loop over 1..9 and position held in subtype 0..2 using mod, then fill the four quadrants with offsets 0, 9*3, 9*2, 9*1 per the A/C/D/B pattern and swap the left and right column blocks (with the middle-row indent) using for loops. Print the constant 111 and each row as a padded text line via 'Image; the construction is deterministic so no input validation is needed, and the row and column sums are not rechecked at run time. About 70 lines.

## Proof obligations to watch

- **index**: The Siamese-method cell position is carried across loop iterations, so it is kept in a subtype 0..2 and advanced with (p + 1) mod 3 and (p + 2) mod 3, which keeps indexes in range without an invariant.
- **range**: Cell values are computed as base + offset*9 from loop indexes with small declared ranges, so the results stay inside the 1..36 element subtype by static range reasoning.
- **length**: Each output row is assembled in a fixed 18-character buffer, padding each 'Image of a 1..36 value to width 3, so the bounded-string length checks follow from static bounds.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the magic constant and the 6x6 grid as text lines.

Assessed on 2026-10-15 against page revision 414324 of the [task](https://rosettacode.org/wiki/Magic_squares_of_singly_even_order) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
