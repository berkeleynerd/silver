# Sierpinski sponge of the 2nd order

**Candidate: proofs likely to discharge automatically.** The task is a fixed-size, input-free text rendering of a 9x9x9 voxel pattern, so every check follows from loop ranges and ranged subtypes. The task's 'draw on this page' wording is met by text art, and nothing needs an invariant or variant.

Position 654 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Render a 9x9x9 order-2 Menger sponge as a text-art orthographic projection: a for loop over the three cell coordinates (0..8) marks each voxel solid unless at least two of its base-3 digits at either level equal 1, using only digit extraction with mod and / on bounded subtypes. A fixed Boolean 3D (or flattened) array stores the voxels, and the front face of the sponge, plus optionally a few depth layers, is printed row by row by filling a fixed-length String line buffer with '#' and ' ' and calling Put_Line. No recursion, while loops or input are needed. About 55 lines.

## Proof obligations to watch

- **index**: Cell coordinates are decomposed into base-3 digits inside for loops over fixed ranges, so every array index stays within the declared 27x27 grid by type and loop bounds.
- **overflow**: All arithmetic is on small ranged subtypes (0..26 coordinates, 0..2 digits), so no sum or product can exceed Integer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, for loops, procedures, string building and Put without a newline.

## External effects

- **console output** (allowed): The sponge is rendered as text art written line by line to standard output.

Assessed on 2026-10-15 against page revision 413609 of the [task](https://rosettacode.org/wiki/Sierpinski_sponge_of_the_2nd_order) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
