# Rotating Rubik's cube

**Candidate: proofs plausibly discharge automatically.** The task has only the one-line requirement to show a rotating Rubik's cube, so text-art frames computed with bounded integer trigonometry fit Silver and every check follows from declared ranges and guards before grid writes. The work is mostly new surface (arrays, records, loops, procedures) rather than hard proof.

Position 1466 in the [progression](../../progression.md#stage-27), in stage 27.

## Approach

The cube is 8 vertex records with small integer coordinates held in a constant array, plus a constant table of integer-scaled sine and cosine values for a fixed number of rotation steps. A for loop over the frames rotates each vertex with integer arithmetic, projects it to an edge-sampled position in a fixed-size character grid with clamping guards, and prints the grid rows with Put_Line as one text frame per step. The grid is a bounded two-dimensional Character array cleared before each frame. About 120 lines.

## Proof obligations to watch

- **overflow**: Rotation uses fixed-point integer arithmetic on small coordinates with a precomputed sine and cosine table, so the products stay inside declared ranges and bounded subtypes keep every intermediate in range.
- **index**: Projecting vertices onto the character grid needs the computed row and column to be guarded against the grid bounds before each store, with out-of-range points simply skipped, which is visible clipping rather than a behavior change.
- **termination**: All loops are for loops over fixed frame, vertex and grid ranges inside procedures, so no loop variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, for loops, procedures, functions, string building, 'Image of scalars, Put without a newline and packages.

## External effects

- **console output** (allowed): The program writes a text-art frame sequence of the rotating cube to standard output, which satisfies the draw-without-display allowance.

Assessed on 2026-10-15 against page revision 415492 of the [task](https://rosettacode.org/wiki/Rotating_Rubik's_cube) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
