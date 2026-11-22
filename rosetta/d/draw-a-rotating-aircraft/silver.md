# Draw a rotating aircraft

**Candidate: proofs likely to discharge automatically.** The task has no required input, so it reduces to a bounded integer rasterizer with a precomputed trig table, in which all checks follow from small declared subtypes and for-loop ranges with no loop-carried values. The only unusual part is replacing a live window with printed text frames and floating-point trig with a fixed-point table, which the task permits.

Position 539 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The program holds a constant 12-entry table of sine and cosine values scaled by 1024 and prints one text-art frame per angle. For each frame it loops over every cell of a 40 by 20 grid, inverse-rotates the cell offset from the aircraft centre with integer arithmetic, and tests it against integer rectangle and triangle inequalities for fuselage, wing, tail and nose. Each row is built in a fixed-length String by assigning characters at loop indexes and printed with Put_Line, followed by a frame label from 'Image. About 110 lines.

## Proof obligations to watch

- **overflow**: The fixed-point rotation products of pixel offsets and 1024-scaled sine and cosine values stay far below the 32-bit limit because the offsets and table entries are in small declared subtypes.
- **index**: Row-buffer and table indexes come from for-loop variables over the arrays' own ranges, and the angle index is a ranged subtype, so no extra guard is needed.
- **range**: Inverse-rotated coordinates are only compared against shape bounds and never used as indexes, so no conversion into a narrower subtype is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, 'Image of scalars, for loops, procedures and functions.

## External effects

- **console output** (allowed): Each rotation frame is printed as text art lines through Put_Line, which meets the task without a window.

Assessed on 2026-10-15 against page revision 414801 of the [task](https://rosettacode.org/wiki/Draw_a_rotating_aircraft) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
