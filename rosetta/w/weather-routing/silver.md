# Weather routing

**Candidate: proofs plausibly discharge automatically.** The task is an open-ended draft, so a small embedded-data grid search is faithful, and all checks come from fixed array bounds and guards; the main difficulty is floating-point trigonometry and interpolation, which is why it is plausible rather than likely.

Position 1120 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed a small fixed grid (for example 9x9) of per-cell wind and current records, a constant polar table, and an obstacle mask in constant arrays. A Dijkstra-style earliest-arrival search runs inside a procedure over a fixed-size settled/time array, using bounded for loops to pick the minimum cell and relax its eight neighbors, with explicit bounds guards and a floored boat-speed so division is safe. It predecessor-tracks the path in an index array, then prints the route and arrival time, or a specified "no route" message if the destination is unreachable. About 230 lines.

## Proof obligations to watch

- **floating point**: Haversine, trigonometry, sqrt and division in the travel-time model need range-guarded operands (sqrt argument clamped visibly, non-zero speed floor, bounded angles) so no overflow, NaN or division check can fail.
- **overflow**: Accumulated times along a path are loop-carried floats and would need a bounded float type with an explicit cap that rejects the route rather than silently clamping.
- **index**: Grid neighbor, time-slice and polar-table interpolation indexes are computed values, so each needs a guard just before use or a subtype-constrained range.
- **termination**: The earliest-arrival search is a while loop and must live in a procedure, with the frontier bounded by a fixed grid and each cell settled once.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, floating point, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, floating-point images, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the computed route, its waypoints and the arrival time.

Assessed on 2026-10-15 against page revision 406929 of the [task](https://rosettacode.org/wiki/Weather_routing) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
