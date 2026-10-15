# Create an HTML table

**Candidate: proofs likely to discharge automatically.** Everything is a fixed-size for-loop over a small constant array with values bounded by a ranged subtype, so all checks follow from types and static bounds. The only new surface is arrays, integer image, bounded string building and non-newline Put.

Position 651 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Store a 3-row by 3-column array of a 0..9999 subtype filled with sequential or LCG-derived values, then print the fixed header lines, and for each row loop over columns, appending the 'Image of the row number and each value to a bounded buffer and printing it with Put and Put_Line. The row number column is the for-loop index and every cell uses the same right-aligned td tags. All loops are for loops over the array's own ranges inside the Main procedure. About 45 lines.

## Proof obligations to watch

- **overflow**: A deterministic linear generator (or plain sequential values) is kept inside a 0..9999 subtype by reducing with mod before each assignment, so the arithmetic is bounded by the types.
- **length**: Each row is assembled into a fixed-capacity buffer sized for the worst case of four 4-digit numbers plus tags, so concatenations cannot exceed it.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, records, for loops, 'Image of scalars, string building, procedures and Put without a newline.

## External effects

- **console output** (allowed): The program prints the HTML table text line by line to standard output.

Assessed on 2026-10-15 against page revision 415282 of the [task](https://rosettacode.org/wiki/Create_an_HTML_table) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
