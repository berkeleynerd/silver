# Centre and radius of a circle passing through 3 points in a plane

**Candidate: proofs plausibly discharge automatically.** Everything is straight-line code with no loops, so the only difficulty is floating-point overflow, division by zero and sqrt-domain checks, which range-bounded subtypes and explicit guards can address, though float formatting and sqrt need admitted library support.

Position 1052 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Define a bounded float subtype for coordinates, a Point record, and a procedure Find_Circle computing the centre with the determinant formula on embedded sample points, rejecting collinear points when the denominator is zero. Compute the radius with a square root guarded by a nonnegative test, then print centre and radius with a bounded fixed-decimal formatting routine. About 70 lines.

## Proof obligations to watch

- **floating point**: Squares, products and the divisions cannot overflow only if the coordinate type is a bounded float subtype, and the sqrt argument must be shown nonnegative by an explicit guard.
- **division**: The two determinant denominators are guarded against zero with an explicit collinear-points rejection that prints a visible outcome.
- **range**: Float-to-text formatting to two decimals needs an admitted library routine with a bounded input range, since 'Image on floats is not provable to a fixed format.
- **floating point**: Provers must bound intermediate products of nonlinear float expressions, so subtypes with small ranges (such as plus or minus 1000.0) are needed and the guard on the sqrt argument may not be provable by simple range reasoning.

## Language surface recorded by this assessment

Floating point, records, procedures, floating-point images, Put without a newline, Boolean objects and ranged subtypes.

## External effects

- **console output** (allowed): Prints the centre coordinates and radius as text lines.

Assessed on 2026-10-15 against page revision 413662 of the [task](https://rosettacode.org/wiki/Centre_and_radius_of_a_circle_passing_through_3_points_in_a_plane) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
