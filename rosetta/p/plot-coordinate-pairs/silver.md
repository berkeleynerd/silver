# Plot coordinate pairs

**Candidate: proofs likely to discharge automatically.** All loops are for loops over array ranges and the data is fixed, so every index and arithmetic check follows from declared ranges and one clamp; text art satisfies the task since no display is required.

Position 658 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed x and y as constant Integer arrays of 10 elements (y in tenths, e.g. 27, 28, 314), then fill a constrained 2D Character grid (about 20 rows by 10 columns) with spaces and place a '*' at the row scaled from y/10 (integer division, guarded to the row range) for each x. Print the grid row by row from top to bottom with a for loop over the rows and Put/Put_Line, with axis labels as literal text. About 45 lines.

## Proof obligations to watch

- **index**: Scaling y to a row index is nonlinear and is discharged by clamping the computed row into the grid's row subtype before indexing.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The text-art plot is printed line by line to standard output.

Assessed on 2026-10-15 against page revision 414979 of the [task](https://rosettacode.org/wiki/Plot_coordinate_pairs) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
