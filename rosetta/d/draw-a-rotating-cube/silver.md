# Draw a rotating cube

**Candidate: proofs plausibly discharge automatically.** The task only needs text-art output of bounded integer arithmetic, with indices guarded and loops all for loops, so nothing requires an annotation, but the fixed-point bounds and the line-stepping coordinates need careful typing and guards.

Position 816 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The cube's 8 vertices are stored in a constant array of integer triples, and a constant table of 360 sine and cosine values scaled by a fixed integer factor stands in for floating point. For each of a fixed number of frames, a procedure rotates the vertices with bounded integer arithmetic, orthographically projects them, clears a small character grid, draws the 12 edges with a stepping loop, guards each cell index, and prints the grid row by row. The initial orientation with one vertex pointing up comes from a fixed tilt of about 35.26 degrees applied before the animation. About 110 lines.

## Proof obligations to watch

- **overflow**: Rotation uses fixed-point integer arithmetic on coordinates held in small declared ranges with a lookup table of precomputed sine and cosine values, so each product and sum is bounded by types and discharges, though the bounds must be chosen with care.
- **index**: Projected coordinates are mapped to grid cells and are guarded by explicit range checks just before each write, so out-of-grid points are skipped as a documented clipping outcome.
- **range**: Line drawing between two vertices uses a step loop with loop-carried interpolated coordinates whose types bound them, and a clamp guard before indexing is needed because no invariant can be written.
- **termination**: All loops are for loops or live in procedures, so the frame loop is a fixed count and no termination check can fail.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, string building, Put without a newline and case statements.

## External effects

- **console output** (allowed): Each frame of the rotating wire-frame cube is printed as a text-art grid of lines.

Assessed on 2026-10-15 against page revision 414939 of the [task](https://rosettacode.org/wiki/Draw_a_rotating_cube) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
