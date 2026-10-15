# Averages/Pythagorean means

**Candidate: proofs plausibly discharge automatically.** The task has no Oracle conflict and needs only floats, arrays and for loops, but float arithmetic in loop-carried accumulators and bisection depends on range subtypes and guards that provers may only discharge with careful shape.

Position 1053 in the [progression](../../../progression.md#stage-18), in stage 18.

## Approach

Embed the integers 1 to 10 in a constant array of a bounded float subtype and compute the arithmetic sum, harmonic reciprocal sum and product in for loops over the array's own range. Find the geometric mean by a fixed-iteration bisection for loop on a lo/hi interval, comparing the 10th power to the product, then guard the divisions, print the three images, and print whether A >= G >= H holds via if statements. About 55 lines.

## Proof obligations to watch

- **floating point**: Float sum, product and reciprocal accumulators lose their bounds after the first iteration, so the program uses a bounded float subtype and each accumulator is kept within range by the fixed small data (10 values of 1.0 to 10.0), which provers may find hard without an invariant.
- **floating point**: The geometric mean is found by a fixed-count bisection for loop on x**10 (no elementary-function library), whose midpoint and power values need range guards so no overflow or non-finite check can fail.
- **division**: The harmonic mean divides by the reciprocal sum, so a guard on the sum being positive precedes the division with a visible rejection outcome.
- **overflow**: Float'Image output of computed values must stay within bounded string buffers sized for the maximum image length.

## Language surface beyond today's Silver

Floating point, floating-point images, ranged subtypes, arrays, for loops, integers, conditional expressions and string building.

## External effects

- **console output** (allowed): Prints the three means and the A >= G >= H comparison result with Put_Line.

Assessed on 2026-10-15 against page revision 414670 of the [task](https://rosettacode.org/wiki/Averages/Pythagorean_means) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
