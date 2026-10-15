# Bézier curves/Intersections

**Candidate: proofs plausibly discharge automatically.** Everything is a fixed-count for loop over bounded floats with no loop-carried values beyond bracket endpoints whose subtype range keeps arithmetic safe, so it should prove without annotations, but floating-point range bounding and float output make it need careful shaping.

Position 1078 in the [progression](../../../progression.md#stage-18), in stage 18.

## Approach

Reduce the two parabolas analytically to y = 5(1-x^2) and x = 2 - 20s + 20s^2 with s = (y-1)/2, giving a quartic residual f(x) in x alone. Search x in [-1,2] with a fixed table of sub-intervals (sampled by a for loop) to find sign changes, then refine each by a fixed-count (e.g. 60) bisection for loop in a procedure on a bounded float subtype, storing the roots in a 4-element array and printing x and y for each. If the number of sign changes found is not four, print a specified failure message. About 90 lines.

## Proof obligations to watch

- **floating point**: Polynomial evaluation of the curve difference must not overflow or produce infinities, discharged by declaring x and y as a bounded float subtype (about -100.0 to 100.0) so every intermediate product stays within range.
- **range**: The bisection midpoint and the stored root must stay inside the declared subtype, which holds because the midpoint of two in-range bounds is in range given the bounded subtype.
- **termination**: Bisection uses a for loop over a fixed iteration count inside a procedure, so no variant is needed.
- **other**: Float-to-text formatting of the coordinates must come from an admitted library operation, since 'Image on floats is not yet available.

## Language surface beyond today's Silver

Floating point, floating-point images, ranged subtypes, arrays, for loops, procedures, functions, Boolean objects, integers, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the four intersection points' (x,y) coordinates.

Assessed on 2026-10-15 against page revision 414097 of the [task](https://rosettacode.org/wiki/B%C3%A9zier_curves/Intersections) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
