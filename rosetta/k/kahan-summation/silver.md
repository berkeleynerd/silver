# Kahan summation

**Candidate: proofs plausibly discharge automatically.** Everything is straight-line or a short for loop over a three-element array, so the checks follow from a bounded Float subtype and guards, with the main uncertainty being floating-point provers and a float-formatting library operation. No annotations are needed.

Position 1067 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The program uses the task's floating-point alternative, stating that it does so because Silver has no six-digit decimal type, with a Float subtype bounded to a small range. A procedure computes epsilon by a while loop, a three-element array holds 1.0, epsilon and -epsilon, and a procedure with a for loop runs the Kahan update on a sum and carry pair. It prints the naive left-to-right sum and the Kahan sum with guards before each assignment. About 70 lines.

## Proof obligations to watch

- **floating point**: Float additions and subtractions must be proven free of overflow and non-finite results, which works only because operands are held in a narrow declared subtype and the array has three elements.
- **range**: Assigning the running sum and carry back into a bounded subtype needs an explicit guard with a visible rejection outcome, since the loop has no invariant.
- **termination**: The epsilon-halving while loop sits in a procedure so no termination check applies, and the value halves toward a fixed positive floor so it ends in practice.
- **other**: The task needs float formatting with fixed fractional digits, which depends on an admitted library operation Silver lacks today.

## Language surface beyond today's Silver

Floating point, floating-point images, ranged subtypes, arrays, records, procedures, for loops, while loops, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): Prints epsilon, the naive sum and the Kahan sum to standard output.

Assessed on 2026-10-15 against page revision 406158 of the [task](https://rosettacode.org/wiki/Kahan_summation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
