# Golden ratio/Convergence

**Candidate: proofs plausibly discharge automatically.** The task needs only a small floating-point loop with no input, and the reciprocal is safe because the ranged subtype keeps the divisor at least 1.0, but floating-point range proofs for 1 + 1/x are the only non-routine part and need no annotations.

Position 1039 in the [progression](../../../progression.md#stage-17), in stage 17.

## Approach

A Main procedure holds phi0 and phi1 as a Float subtype ranged 1.0 .. 2.0, an Integer count subtype, and a literal constant for (1 + sqrt 5)/2. A while loop in the procedure iterates phi1 := 1.0 + 1.0 / phi0 until the absolute difference is at most 1.0e-5, with an iteration cap that prints a specified failure line if reached. It then prints the final value, the count and the error using image conversions and Put_Line. About 45 lines.

## Proof obligations to watch

- **floating point**: The reciprocal 1.0 / phi and the result range need phi bounded away from zero, which a Float subtype range of 1.0 .. 2.0 supplies, and the provers must show 1.0 + 1.0 / x stays within 1.0 .. 2.0 for x in that range.
- **range**: Assigning the loop-carried phi back into the ranged subtype needs the bound on 1 + 1/x, which is nonlinear and may need the provers to handle division carefully.
- **overflow**: The iteration counter is a loop-carried value, so it uses a bounded integer subtype with a guarded increment against a fixed cap.
- **termination**: The while loop sits in a procedure so no termination check applies, and a fixed iteration cap with a visible failure message keeps termination explicit and the behavior unchanged for the real 14-iteration run.
- **floating point**: Formatting floating-point values as text with fixed digit and exponent handling relies on the admitted image library's contracts.

## Language surface recorded by this assessment

Floating point, floating-point images, 'Image of scalars, integers, ranged subtypes, while loops, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the final value, iteration count and error as text lines.

Assessed on 2026-10-15 against page revision 415506 of the [task](https://rosettacode.org/wiki/Golden_ratio/Convergence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
