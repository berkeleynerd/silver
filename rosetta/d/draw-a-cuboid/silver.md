# Draw a cuboid

**Candidate: proofs likely to discharge automatically.** The task is satisfied by a fixed-size ASCII-art grid with static dimensions and for loops only, so all index and range checks follow from constants and loop ranges without any annotation.

Position 654 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Use a constant 10x11 Character grid (Height 3, Width 2, Depth 4 as static constants) initialised to spaces, fill corners, dashes, bars and slashes with for loops whose indexes are static-range affine expressions, then print each row from the top down, emitting the row's 11 characters by Put per character (or assembling a fixed-length String and calling Put_Line). No functions, recursion or contracts are needed, and the dimensions are fixed constants so no input validation is required. About 45 lines.

## Proof obligations to watch

- **index**: Every Result(row, col) index is an affine expression of for-loop variables with constant Width, Height and Depth, so a fixed-size subtype-ranged array with static bounds lets the provers discharge each index check.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, multidimensional arrays, for loops, procedures, Put without a newline and string building.

## External effects

- **console output** (allowed): The ASCII-art cuboid is written to standard output line by line.

Assessed on 2026-10-15 against page revision 415030 of the [task](https://rosettacode.org/wiki/Draw_a_cuboid) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
