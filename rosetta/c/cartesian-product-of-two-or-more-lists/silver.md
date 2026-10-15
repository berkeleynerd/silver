# Cartesian product of two or more lists

**Candidate: proofs plausibly discharge automatically.** The task only needs bounded arrays, nested for loops and integer-to-text output, all of which have types or guards bounding every index and length, and no recursion or heap is required. Plausible rather than likely because the n-ary odometer and text-buffer building carry loop-carried values that need careful range-bounded subtypes.

Position 727 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Lists are fixed-capacity arrays (a 2D array of values plus an array of lengths, bounded subtypes) holding the embedded example data. A procedure prints the n-ary product by walking an odometer of index positions (a for loop over the total tuple count, deriving each position by integer division and mod), appending 'Image digits into a bounded line buffer and printing with Put_Line. An empty list gives product count zero, so the output is {}. About 120 lines.

## Proof obligations to watch

- **index**: Odometer-style indexing of lists by loop-carried positions needs each index held in a subtype bounded by the fixed list capacity, so the type range discharges the check.
- **overflow**: Loop-carried odometer positions and output-buffer lengths are bounded by their subtype ranges and guarded before each increment, with the buffer sized for the largest product (24 tuples).
- **length**: Appending numbers to a bounded text buffer needs a guard that remaining capacity covers the digits, with a visible reject outcome otherwise.
- **termination**: All iteration is done in procedures with for loops or one while loop over a bounded odometer, so no function termination check arises.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, multidimensional arrays, records, for loops, while loops, procedures, 'Image of scalars, string building, Put without a newline, characters and string indexing.

## External effects

- **console output** (allowed): Prints each product as a line of text such as {(1,3),(1,4),...}.

Assessed on 2026-10-15 against page revision 415350 of the [task](https://rosettacode.org/wiki/Cartesian_product_of_two_or_more_lists) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
