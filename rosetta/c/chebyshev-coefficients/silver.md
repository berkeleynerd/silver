# Chebyshev coefficients

**Candidate: proofs plausibly discharge automatically.** All indices and loop bounds are static, so only the float accumulator in the nested loop and the Cos contract are non-routine, making discharge plausible with careful range subtypes and guards but no annotations.

Position 968 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A procedure Main declares a constant N of 10 and two arrays of bounded float subtype, fills the sampled cosine values in one for loop, then computes each coefficient with a nested for loop over the 10 samples using Cos from an admitted elementary-functions library. Each running sum is guarded against leaving its declared range with a visible Reject outcome, and the ten lines are printed through an admitted float-to-text and Put_Line. About 55 lines.

## Proof obligations to watch

- **floating point**: The Cos calls and the pi/n*(i+1/2) arguments must be provably finite, which needs an admitted Cos contract bounding the result to -1.0..1.0 and bounded float subtypes for arguments.
- **overflow**: The accumulator w is loop-carried and with no invariant is known only by its type, so it needs a bounded float subtype and a visible rejection guard before each addition, which the provers can discharge only if the guard is checked on w plus the term of magnitude at most 1.
- **range**: Assigning the sum back into a bounded float subtype needs the guard to dominate the assignment, and the nonlinear products with the index need declared ranges on the operands.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, arrays, for loops, floating-point images, 'Image of scalars, string building, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints the ten index and coefficient lines to standard output.

Assessed on 2026-10-15 against page revision 415360 of the [task](https://rosettacode.org/wiki/Chebyshev_coefficients) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
