# Roots of a quadratic function

**Candidate: proofs plausibly discharge automatically.** The program is straight-line floating-point code with no loops, so every check is a range, division or sqrt-domain check dischargeable by bounded subtypes and local guards, but it hinges on a new floating-point type, an admitted Sqrt with a contract, and float formatting.

Position 963 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed a=1, b=-1.0e9, c=1 as constants of a range-bounded Long_Float subtype, reject a=0.0 visibly, and compute the discriminant. If it is non-negative, use the sign-aware stable formula (X = (-B - sign(B)*SD)/(2A), other root C/(A*X)) and print both real roots; otherwise print the complex pair as real and imaginary parts. About 45 lines.

## Proof obligations to watch

- **floating point**: The square root needs an admitted library Sqrt with a verified non-negative-argument contract, and the discriminant is guarded to be non-negative before the call.
- **overflow**: Coefficients are declared in a bounded Long_Float subtype (for example magnitude at most 1.0e9) so B*B and 4.0*A*C stay finite, which is a documented resource limit.
- **division**: The division by 2.0*A is guarded by an explicit A /= 0.0 rejection, and the stable-formula divisions by X are guarded by tests that the denominator is nonzero because floating-point underflow could otherwise produce zero.
- **floating point**: Provers must show -B+SD has the same sign and magnitude at least |B| so the stable root is nonzero, which is nonlinear float reasoning that may need guard-shaped code.

## Language surface recorded by this assessment

Floating point, floating-point images, ranged subtypes and conditional expressions.

## External effects

- **console output** (allowed): Prints the two roots (real, or real and imaginary parts) with Put_Line.

Assessed on 2026-10-15 against page revision 413885 of the [task](https://rosettacode.org/wiki/Roots_of_a_quadratic_function) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
