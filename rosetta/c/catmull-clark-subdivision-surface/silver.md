# Catmull–Clark subdivision surface

**Candidate: proofs plausibly discharge automatically.** Every check can be tied to array bounds, ranged counters and pre-use guards with no annotation, but the bounded floating-point arithmetic and several loop-carried counters make discharge depend on careful program shape.

Position 1033 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

The program embeds the cube (8 vertices, 6 quad faces) in constrained arrays of a point record with bounded Float components, then in procedures computes face points, a deduplicated edge table (with a second adjacent-face slot and a hole check), edge points, new vertex positions, and the new quad face table, all with for loops over fixed-capacity arrays. It prints coordinates and faces as text for one or two rounds, and guards n = 0 and capacity overflows with explicit rejection outcomes. About 260 lines.

## Proof obligations to watch

- **floating point**: Averages and the m1/m2/m3 weighting must stay finite, which discharges only if coordinates are a bounded float subtype and the embedded cube data is small, though provers handle float range reasoning weakly.
- **division**: Dividing by a face's vertex count or a vertex's face count n is guarded by a visible check that skips or rejects vertices with n = 0, and the counts are also typed as at least 1 where known.
- **index**: Edge lookup, edge-point numbering and new-face writes index fixed-capacity arrays with loop-carried counters (edge count, next point number, next face), so each increment needs an explicit capacity guard just before use.
- **range**: The edge count and new-vertex numbers grow across loop iterations with no invariant, so they must be typed to the capacity range and guarded before each increment, with overflow of capacity giving a specified rejection outcome.
- **initialization**: Arrays of points, edges and face tables must be fully initialized by aggregate before the loops fill them, since partial fills cannot be proven by flow analysis.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, floating point, floating-point images, 'Image of scalars, arrays, multidimensional arrays, records, for loops, procedures, functions, Put without a newline, string building and conditional expressions.

## External effects

- **console output** (allowed): The program prints the refined mesh's vertex coordinates and face index lists as text, which satisfies the render requirement without a display.

Assessed on 2026-10-15 against page revision 414106 of the [task](https://rosettacode.org/wiki/Catmull%E2%80%93Clark_subdivision_surface) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
