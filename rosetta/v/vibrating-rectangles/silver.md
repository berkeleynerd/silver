# Vibrating rectangles

**Candidate: proofs likely to discharge automatically.** All indices and levels come from for-loop ranges over constant bounds and explicit clamps, so no loop-carried value needs an invariant and the animation is a finite, fixed-length text rendering.

Position 668 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

A 41 by 41 Character grid is cleared to spaces each frame, then for each of 20 rectangles (half-size 1 to 20 steps of one, spaced so none touch) the four edges are drawn with for loops, using a digit for the fade level computed from frame number minus rectangle index and clamped to 0..9. A fixed outer for loop of about 30 frames prints each grid row through a String row buffer with Put_Line, so the fade travels from the outermost to the innermost rectangle; all loops are for loops in procedures. About 70 lines.

## Proof obligations to watch

- **index**: Rectangle edge coordinates are computed as center plus or minus a half-size from a for-loop index over 1..20, so they stay inside the 41 by 41 grid by subtype ranges, with the loop index type bounding the arithmetic.
- **range**: The fade level is clamped with an explicit if to 0..9 before conversion to a digit Character, so the Character'Val check follows from the guard.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, multidimensional arrays, for loops, string indexing, procedures, integer division and Put without a newline.

## External effects

- **console output** (allowed): Each animation frame is printed as text art of 20 nested rectangles whose fade level is shown by a digit character.

Assessed on 2026-10-15 against page revision 414574 of the [task](https://rosettacode.org/wiki/Vibrating_rectangles) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
