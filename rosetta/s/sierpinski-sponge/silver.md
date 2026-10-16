# Sierpinski sponge

**Candidate: proofs likely to discharge automatically.** The task is satisfied by text art, and every loop is a bounded for loop over ranged subtypes with a pure solid-voxel function, so all checks follow from declared ranges and no invariant or variant is needed. The only mild care is keeping the buffer indices statically within the row length.

Position 456 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Render a level-2 Menger sponge (27x27x27 voxels) as an oblique-projection text picture: a pure function decides whether voxel (x,y,z) is solid by checking the base-3 digits of its coordinates for two digits equal to 1 at the same position (using mod and / by 3 in a fixed 2-iteration for loop). For each output row and column a for loop over depth z marches front to back to find the first solid voxel, choosing a shading character by which face (front, top or side) was hit, and each completed row is built in a fixed-length String buffer and printed with Silver_IO.Put_Line. About 70 lines.

## Proof obligations to watch

- **index**: The row buffer index is computed from loop variables of declared ranged subtypes, so a static bound on the buffer length lets it discharge without a loop invariant.
- **overflow**: Voxel coordinates and base-3 digit extraction use small ranged integers (0..26) with mod and / by 3, so every intermediate stays far inside Integer.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, string building, for loops, procedures, functions and arrays.

## External effects

- **console output** (allowed): The sponge is drawn as text art written line by line to standard output.

Assessed on 2026-10-15 against page revision 414017 of the [task](https://rosettacode.org/wiki/Sierpinski_sponge) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
