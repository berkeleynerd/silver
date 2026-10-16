# Peripheral drift illusion

**Candidate: proofs likely to discharge automatically.** The program is fixed-size table lookups and nested for loops over constant ranges with no loop-carried values, so every index and length check follows from static bounds, and the task's picture requirement is met by text art.

Position 784 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the 12x12 square-kind grid as twelve constant 12-character strings (codes L, T, R, B for the white-edge corner pairs), then for each grid row and each of three text sub-lines fill a fixed 36-character buffer by looking up a constant 3x3 glyph pattern per code. Loops are for loops over the constant 1..12 and 1..3 ranges, every index is derived from those ranges, and each buffer is printed with Put_Line. About 70 lines.

## Language surface recorded by this assessment

Characters, arrays, multidimensional arrays, for loops, ranged subtypes, string indexing, string building, case statements, procedures and Put without a newline.

## External effects

- **console output** (allowed): The text-art rendering of the static illusion is printed line by line to standard output.

Assessed on 2026-10-15 against page revision 415281 of the [task](https://rosettacode.org/wiki/Peripheral_drift_illusion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
