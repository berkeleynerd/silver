# Draw a torus

**Candidate: proofs plausibly discharge automatically.** The task asks only for a drawn torus, which text art satisfies, and a table-driven integer renderer needs only for loops with types, ranges and guards just before each division and index, so it should discharge without annotations although the many nonlinear products make it dependent on careful range declarations.

Position 702 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed 64-entry integer sine and cosine tables (scaled by 256) as constant arrays, then loop with nested for loops over ring angle and tube angle indexes, computing the rotated 3D point and a luminance with integer arithmetic only. Project with a guarded integer division onto a 2D Character grid with a depth buffer of integers, keeping the nearest point per cell, then print each grid row with Silver_IO.Put_Line using a ramp of characters for brightness. All writes are guarded by explicit bounds tests and no loop-carried value is needed. About 90 lines.

## Proof obligations to watch

- **overflow**: Fixed-point products of sine/cosine table entries and radii stay within Integer because table elements and coordinates are declared with narrow ranged subtypes so each product's bound follows from types.
- **division**: The perspective divide uses a depth offset that is guarded to be positive immediately before the division, and points failing the guard are skipped.
- **index**: Projected column and row are range-tested against the grid bounds just before the buffer write, and luminance is clamped before indexing the character ramp.
- **range**: Intermediate coordinates are computed into wider declared subtypes and tested against the buffer range before conversion, so narrowing conversions are guarded.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building and for loops.

## External effects

- **console output** (allowed): The torus is rendered as text art and printed line by line to the console.

Assessed on 2026-10-15 against page revision 414775 of the [task](https://rosettacode.org/wiki/Draw_a_torus) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
