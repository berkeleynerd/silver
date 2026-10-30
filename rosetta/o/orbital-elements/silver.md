# Orbital elements

**Candidate: proofs plausibly discharge automatically.** The task is a short straight-line floating-point computation with no loops over carried values, so proofs depend on bounded real subtypes, guarded divisions and sqrt arguments, and admitted elementary functions. It is plausible rather than likely because floating-point range reasoning and float formatting need library support Silver lacks today.

Position 1070 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

The program uses a bounded floating-point subtype Real, a 3-element array for vectors and a record holding position and speed, with procedures for rotation and for state computation. The example elements (a=1, e=0.1, rotation angle 355/678) are embedded as constants, Rotate uses admitted Sin and Cos, and guards on e, L, R and the speed magnitude reject invalid or degenerate input visibly. Output is formatted to six decimals through an admitted float-image operation and printed with Put and Put_Line. About 90 lines.

## Proof obligations to watch

- **floating point**: Sin, Cos and Sqrt must be admitted library operations, with the sqrt argument 2/R - 1/a guarded as non-negative and the sine and cosine arguments in a bounded range.
- **division**: The divisions by L, by 1 + e*cos, by the speed magnitude and by a are each guarded explicitly, with a rejected-input outcome if the denominator is zero.
- **overflow**: Floating-point operands are given bounded subtypes (for example a in 0.1..100.0 and e in 0.0..0.95) so no intermediate result can overflow or become infinite.
- **floating point**: Formatting reals as fixed six-decimal text requires an admitted float-to-text operation with a bounded magnitude, as Float_IO is not available.

## Language surface recorded by this assessment

Floating point, ranged subtypes, arrays, records, procedures, functions, for loops, floating-point images, Put without a newline, string building, Boolean objects and conditional expressions.

## External effects

- **console output** (allowed): Prints the position and speed vectors as text lines.

Assessed on 2026-10-15 against page revision 407328 of the [task](https://rosettacode.org/wiki/Orbital_elements) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
