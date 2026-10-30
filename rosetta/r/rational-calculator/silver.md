# Rational calculator

**Candidate: proofs plausibly discharge automatically.** The task is plain exact arithmetic plus a line-oriented expression parser, and every check can be bounded by range-limited rationals, capacity guards and an iterative evaluator in procedures, so no annotation is needed. The nonlinear cross-multiplication and parser state carried through loops make discharge depend on careful program shape, hence plausible.

Position 1247 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Rationals are a record of range-limited numerator and positive denominator, normalized by an iterative gcd procedure; each input line (bounded length, longer lines rejected) is scanned by index into numbers, '@' (the stored previous result), operators, abs and parentheses, evaluated by a shunting-yard style loop with bounded operand and operator stacks. Every syntax error, zero divisor, capacity or range overflow prints a specified message and leaves the previous result unchanged, and results print as the exact fraction or integer (the recurring-decimal bonus is left out). About 260 lines.

## Proof obligations to watch

- **overflow**: Rational add, sub and mul cross-products are discharged by bounding numerator and denominator to a declared range (for example 10**9) so 64-bit products cannot overflow, and any result outside the range is reported as 'Too large number' rather than altered.
- **division**: A zero divisor is explicitly tested before each division with a visible 'Zero divisor' message, and gcd and normalization divide only by a guarded positive value.
- **termination**: gcd and the token scan loop live in procedures, which get no termination check, and the expression evaluator is an iterative operator-precedence loop with fixed-size stacks instead of recursive descent.
- **index**: Stack pushes and line positions are guarded by explicit capacity and length tests that reject over-long or too deeply nested input with a specified message.
- **range**: Digit accumulation in the number scanner is a loop-carried value, so each step is guarded against the declared limit before multiplying by ten.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, Put without a newline and standard input.

## External effects

- **standard input** (allowed): Reads expression lines until an empty line or end of input.
- **console output** (allowed): Prints the prompt, each result or a specified error message per line.

Assessed on 2026-10-15 against page revision 412990 of the [task](https://rosettacode.org/wiki/Rational_calculator) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
