# Geocentric model

**Candidate: proofs likely to discharge automatically.** Rotation is rendered as deterministic text-art frames from an integer lookup table, so every check follows from declared ranges, for-loop indexes and mod reductions without loop-carried facts needing an invariant. The task is a graphical animation, but text frames satisfy it and no recursion, floating point or timing is needed.

Position 676 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the six bodies (distance, angular speed in whole degrees per frame, glyph) as constant arrays and a 360-entry integer sine table scaled by 1000, then for a fixed number of frames compute each body's angle with mod 360, derive x and y on a small character grid, and print the grid rows as text art with orbit points and planet glyphs. All loops are for loops over constant ranges inside procedures, with the grid cleared and rows output through Put_Line after building each row string in a bounded buffer. About 110 lines.

## Proof obligations to watch

- **index**: Planet grid coordinates come from table-based integer sine and cosine times a fixed radius, so each is clamped by guard or ranged subtype to the grid bounds before indexing.
- **overflow**: Angle accumulation is reduced with mod 360 each frame and the frame count is a small declared range, so products with scaled sine values stay far below 32-bit limits.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, for loops, procedures, functions, records, string building and Put without a newline.

## External effects

- **console output** (allowed): Each frame of the planet positions is printed as text art lines to standard output.

Assessed on 2026-10-15 against page revision 414863 of the [task](https://rosettacode.org/wiki/Geocentric_model) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
