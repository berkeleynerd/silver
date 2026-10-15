# Babylonian spiral

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic in nested for loops inside a procedure, with no recursion or floats, so checks follow from subtype ranges and a few guards on the carried position and length; the nonlinear products stay within Integer because the window is small.

Position 924 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Use pure integer arithmetic instead of floating point: keep the previous step as (dx, dy) and its squared length, and for each of 40 steps scan a bounded window of candidate vectors with nested for loops. Choose the smallest squared length strictly above the previous one, among those the smallest clockwise bend, ordered by the sign of cross products and a half-plane test, excluding collinear same-direction candidates. Then update the position behind a range guard, print the coordinates with 'Image text, and skip the optional 10000-point plot. About 90 lines.

## Proof obligations to watch

- **overflow**: Cross and dot products of candidate vectors are nonlinear but discharge because vector components are subtypes bounded to a small window, so every product fits Integer.
- **range**: The loop-carried position and previous squared length know only their subtype ranges, so each update is preceded by an explicit guard that rejects the run (visible outcome) if the new value would leave the declared range.
- **other**: The nearest-longer-vector search uses a fixed-size window, so if no candidate is found the program rejects visibly, a documented resource limit that is never hit for 40 points.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, 'Image of scalars, string building, for loops, procedures and conditional expressions.

## External effects

- **console output** (allowed): The first 40 coordinates are printed as text lines.

Assessed on 2026-10-15 against page revision 415237 of the [task](https://rosettacode.org/wiki/Babylonian_spiral) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
