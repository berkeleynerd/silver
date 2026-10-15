# Möbius strip

**Candidate: proofs plausibly discharge automatically.** The task only asks for a picture, which text art satisfies, and all arithmetic is bounded integer math over table lookups with guarded grid indexes, so checks follow from types and guards but need careful shape for the nested loops and projection.

Position 696 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed an integer sine/cosine table (scaled by 100) covering the angle steps as constant arrays, avoiding floating point, and compute the strip's edge and interior points x=(R+v*cos(u/2))*cos(u), y=(R+v*cos(u/2))*sin(u), z=v*sin(u/2) in nested for loops over u and v. Project each point onto a fixed 2D Character grid with an oblique shift by z, guard the computed row and column against the grid bounds before storing a mark character, then print each grid row with Put_Line from a fixed-length String buffer. About 70 lines.

## Proof obligations to watch

- **index**: Projected plot coordinates are computed from table values and are guarded by explicit range comparisons against the grid bounds just before each store, so out-of-grid points are visibly skipped.
- **overflow**: Integer sine/cosine lookup tables scaled to small constants and ranged subtypes for angle and width keep all products far below the 32-bit limit.
- **initialization**: The character grid is fully filled with blanks by nested for loops before any plotting, and each output row is built into a fixed-length buffer in a for loop.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, for loops, procedures, string building and Put without a newline.

## External effects

- **console output** (allowed): The strip is drawn as text art lines written to standard output.

Assessed on 2026-10-15 against page revision 414810 of the [task](https://rosettacode.org/wiki/M%C3%B6bius_strip) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
