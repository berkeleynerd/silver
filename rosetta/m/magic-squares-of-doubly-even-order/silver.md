# Magic squares of doubly even order

**Candidate: proofs likely to discharge automatically.** The task is a fixed-size 8x8 fill by a closed-form formula with for loops over static ranges, so every index and range check follows from types and loop bounds with no loop-carried unbounded values. Only the new surface for 2D arrays, integer-to-text conversion and Put is missing.

Position 655 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Declare a constant N = 8 and a 2D Integer array subtype range 1..64 indexed by 1..N; two nested for loops compute each cell from the row and column indexes, taking the number itself when exactly one of row or column lies in the middle band 3..6 and its complement 65 minus the number otherwise. A second nested loop appends each value as a fixed-width field via 'Image with a guard for single digits and prints each row with Put and Put_Line. All indexes come from the loops over the array's own range, so no guards beyond width padding are needed. About 45 lines.

## Proof obligations to watch

- **range**: The loop-carried counter and the complement 65 minus counter stay inside 1..64 because the counter is derived directly from the row and column loop indexes (8*(r-1)+c) rather than accumulated, so the type range and static loop bounds discharge it.
- **length**: Each output row is built into a fixed 8-cell buffer with fixed-width 3-character fields, so concatenation lengths are static; the integer text is padded using a guard on whether the value is below 10.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 8x8 square one row per line, with an optional magic-sum header line.

Assessed on 2026-10-15 against page revision 414322 of the [task](https://rosettacode.org/wiki/Magic_squares_of_doubly_even_order) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
