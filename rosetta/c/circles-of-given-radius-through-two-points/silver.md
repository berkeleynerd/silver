# Circles of given radius through two points

**Candidate: proofs plausibly discharge automatically.** The task is a short closed-form float computation with explicit guards for every special case, so the checks follow from bounded float subtypes and guards, but float overflow proofs through the division and sqrt need careful range shaping, hence plausible.

Position 1000 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Define a bounded Coordinate float subtype and a Point record, embed the five test cases in an array of records, and write a procedure Solve that classifies each case with if/elsif guards (coincident points, radius below half the distance, otherwise two centres), printing a message for each special case. For the general case it guards the sqrt argument to be non-negative and the divisor to be non-zero, then computes the two centres by a rotation about the midpoint and prints them using float formatting in a for loop over the cases. About 110 lines.

## Proof obligations to watch

- **floating point**: Each float operation must be proven free of overflow and NaN, so coordinates and radius are held in a bounded float subtype and the sqrt argument is guarded to be non-negative before the call.
- **division**: The division by the half-distance is guarded by an explicit test that it is non-zero, but a tiny nonzero divisor could make the quotient overflow, so the program must use a range guard or a normalised formulation that keeps the quotient bounded.
- **overflow**: The squares of radius and half-distance and the products with the offset rely on the declared coordinate and radius ranges being small enough that every product stays finite.
- **range**: Intermediate sums such as (x1+x2)/2 can leave the coordinate subtype unless the subtype is wide enough or the intermediates use a wider float subtype.

## Language surface recorded by this assessment

Floating point, floating-point images, ranged subtypes, records, arrays, for loops, procedures, Put without a newline, integers, Boolean objects and string building.

## External effects

- **console output** (allowed): Prints each test case's inputs and the resulting circle centres or a special-case message.

Assessed on 2026-10-15 against page revision 412465 of the [task](https://rosettacode.org/wiki/Circles_of_given_radius_through_two_points) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
