# Numeric error propagation

**Candidate: proofs plausibly discharge automatically.** The program is loop-free with bounded float operands, so each check follows from subtype ranges and guards just before the operation, but it depends on Float arithmetic and an admitted Sqrt with nonnegativity provable, which makes proof discharge depend on careful range guards.

Position 1518 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

Represent an uncertain number as a record of Value, Sigma and a Valid flag over a bounded Float subtype, with straight-line functions for subtract, add, multiply, integer power and square root that guard operand magnitudes and zero divisors before each floating-point step. Main embeds the four example coordinates, computes d = sqrt((x1-x2)^2 + (y1-y2)^2) with no loops, and prints the value and error rounded to two decimals through a bounded string-building routine, or a visible rejection message if any guard failed. About 110 lines.

## Proof obligations to watch

- **floating point**: Every Float operation needs a no-overflow and finite-result proof, which the program obtains by declaring a bounded Float subtype (for example magnitude up to 1.0E6) and guarding operands before each multiply, square and divide.
- **division**: Sigma/Value division requires Value /= 0.0, discharged by an explicit guard whose failure yields a visible rejection flag in the result rather than a silently altered number.
- **range**: Sqrt requires a nonnegative argument, which the prover must infer from a sum of squares (nonlinear floating point), so the code guards the argument with an explicit check before calling the admitted Sqrt.
- **overflow**: Result magnitudes after each operation must fit the bounded subtype, so each operation checks the result bound in a guard and reports an error outcome otherwise.

## Language surface beyond today's Silver

Floating point, ranged subtypes, records, functions, procedures, Boolean objects, exponentiation, floating-point images, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the distance and its propagated error as a line of text.

Assessed on 2026-10-15 against page revision 413812 of the [task](https://rosettacode.org/wiki/Numeric_error_propagation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
