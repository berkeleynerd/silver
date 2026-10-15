# Ray-casting algorithm

**Candidate: proofs likely to discharge automatically.** Scaled integers with cross-multiplication replace floating point and division, so all checks follow from the coordinate subtype bounds and bounded for-loops with no loop-carried value needing an invariant.

Position 618 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Coordinates are integers scaled by 100000 (so 2.5 is 250000 and epsilon is 1) stored in a ranged subtype, with a Point record and fixed-capacity arrays of vertices per polygon, each polygon embedded as constants with a vertex count. A function tests whether the ray hits a side by ordering the endpoints, applying the epsilon nudge, doing the bounding tests and then comparing slopes by cross-multiplication instead of division, and a for-loop over the sides counts crossings and returns the parity. A procedure loops over the seven test points and four polygons printing each result with Put and Put_Line, formatting coordinates from integer images. About 130 lines.

## Proof obligations to watch

- **overflow**: The slope comparison is done by cross-multiplying coordinate differences in a wide integer type, and it discharges because coordinates are a declared subtype of at most a few million so every product stays far below 2**63.
- **division**: Cross-multiplication replaces the slope divisions and the infinite-slope cases, so no division by zero can arise.
- **range**: The epsilon nudge adds one scaled unit to a Y coordinate whose subtype leaves headroom, and the side counter stays within Natural because it is incremented at most once per for-loop iteration over a bounded array.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, functions, procedures, Put without a newline, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints one inside/outside line per test point for each of the four embedded polygons.

Assessed on 2026-10-15 against page revision 414433 of the [task](https://rosettacode.org/wiki/Ray-casting_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
