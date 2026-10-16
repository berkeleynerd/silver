# Pentagram

**Candidate: proofs likely to discharge automatically.** Everything is bounded for-loop integer arithmetic over ranged types and constant-size arrays with no loop-carried values, so all checks follow from types and static bounds; the task allows text art with distinct stroke, fill and background tokens.

Position 671 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The five star vertices are embedded as integer constants on a roughly 41 by 21 character grid, avoiding floating point and system graphics. A nested for loop fills each cell with a fill character when at least four of five integer orientation tests are positive, otherwise background, and a second for loop over the five edges interpolates points with a constant divisor to write the stroke character. Each row is copied into a fixed-length String and printed with Put_Line. About 85 lines.

## Proof obligations to watch

- **overflow**: The orientation products and sums use small ranged coordinate subtypes, so they stay far below the Integer limit and discharge from types alone.
- **index**: Edge-drawing coordinates are computed by interpolation with a constant divisor, so the prover must show they stay in the grid ranges, which a clamp guard or ranged subtype makes routine.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, for loops, procedures and functions.

## External effects

- **console output** (allowed): The pentagram is printed as text art, one Put_Line per grid row.

Assessed on 2026-10-15 against page revision 414386 of the [task](https://rosettacode.org/wiki/Pentagram) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
