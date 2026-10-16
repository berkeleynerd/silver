# Sierpinski triangle/Graphical

**Candidate: proofs likely to discharge automatically.** Everything is a nested for loop over fixed ranges with a validated order, so index and range checks follow from types and guards, and the only new needs are file output and text parsing; no loop-carried value needs an invariant.

Position 1427 in the [progression](../../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

Parse the order from the first argument, rejecting anything outside 0..8, then fill a constrained 2-D Boolean array of 256x256 by for loops, marking pixel (x, y) when no bit position has both x and y bits set (the Sierpinski pattern via Pascal's triangle mod 2), using a bounded inner loop over bits with a Boolean flag. A second procedure writes the grid as a plain-text PBM (P1) image into a fixed-capacity String buffer and then to a named file, so no recursion or turtle is needed. About 70 lines.

## Proof obligations to watch

- **index**: Pixel indices are bounded by a fixed 256x256 array and for loops over the array's own ranges, so each access follows from the declared ranges.
- **range**: The order is parsed and guarded to 0..8 before use, with an invalid value rejected visibly, so the grid size derived from it stays within the array.
- **overflow**: All values are at most 2**8, so the bitwise-free test (x and y) = 0 is replaced by a bounded per-bit loop over small ranged integers, with no overflow.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, for loops, procedures, string building, 'Image of scalars, text parsing, file output and Put without a newline.

## External effects

- **files** (allowed): Writes the picture as a plain-text PBM image file, which meets the graphical requirement without a display.
- **arguments** (allowed): Reads the order N from the first command-line argument, with validation and a specified rejection for bad input.

Assessed on 2026-10-15 against page revision 411684 of the [task](https://rosettacode.org/wiki/Sierpinski_triangle/Graphical) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
