# Apply a digital filter (direct form II transposed)

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-size arrays and for loops, so indexing, initialization and termination are routine, but Float overflow checks on loop-carried filter state need bounding guards and floating-point provers, so discharge depends on careful program shape.

Position 1059 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Embed the a and b coefficients and the 20-sample signal as constant Float arrays, keep a 3-element delay-line array in a procedure, and loop with a for loop over the signal applying the direct form II transposed recurrence (the state update is an inner for loop over the fixed indexes). Before each arithmetic step an if guard checks that the output and state magnitudes stay within a declared bound and rejects otherwise, then each result is formatted to six decimals and printed with Put_Line. About 70 lines.

## Proof obligations to watch

- **floating point**: The delay-line values are loop-carried so after the first sample only their type range is known, hence each product and sum needs a range-bounded float subtype and an explicit guard before use that prints a visible rejection when a magnitude bound is exceeded.
- **overflow**: Float multiplication and addition in the recurrence can overflow unless operands are guarded to a bounded range such as plus or minus 1.0e6, which the provers must then handle as nonlinear floating-point reasoning.
- **range**: Assigning the new state value to a bounded float subtype needs a guard on the computed result just before the assignment, which is expressible as an if that rejects out-of-bound output.
- **other**: Formatting a Float to six decimals needs an admitted library routine with a verified length bound, otherwise the text conversion cannot be proved.

## Language surface beyond today's Silver

Floating point, ranged subtypes, arrays, for loops, procedures and floating-point images.

## External effects

- **console output** (allowed): Prints the 20 filtered samples one per line.

Assessed on 2026-10-15 against page revision 413639 of the [task](https://rosettacode.org/wiki/Apply_a_digital_filter_%28direct_form_II_transposed%29) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
