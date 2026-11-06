# Length of an arc between two angles

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded integer arithmetic over declared ranged subtypes with no loops or recursion, so every overflow, range and division check follows from the types; the only extra surface is decimal text formatting of a scaled integer.

Position 301 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Use ranged subtypes for angles in degrees (0..360) and radius (0..1000), and a function Major_Arc_Length that computes (360 - abs (A2 - A1)) * Pi_Scaled * Radius / 180 in scaled-integer arithmetic (Pi scaled by 10**6, result in millionths), avoiding floating point. The main procedure embeds the example (radius 10, angles 10 and 120), then prints the integer part, a decimal point and four fractional digits using integer division/mod and a small bounded text buffer, with no loops needed. About 35 lines.

## Proof obligations to watch

- **overflow**: Scaled integer products such as 360 * 3141593 * Radius stay far below 2**63 because Angle (0..360) and Radius (0..1000) are declared subtypes, so the checks follow from the type ranges.
- **range**: The absolute angle difference is at most 360 and the major angle 360 - diff is within 0..360 because the angle subtypes bound it, so no guard is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the computed arc length of about 43.6332 for the radius 10, 10 to 120 degree example.

Assessed on 2026-10-15 against page revision 395909 of the [task](https://rosettacode.org/wiki/Length_of_an_arc_between_two_angles) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
