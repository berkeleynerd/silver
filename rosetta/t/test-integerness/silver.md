# Test integerness

**Candidate: proofs plausibly discharge automatically.** Decimal text parsed with guarded bounded-integer counters can decide integerness, including the huge -2.1e120 case, without floats or big numbers, so proofs should discharge with careful guards. The risk is loop-carried exponent and position arithmetic, but no annotation is needed.

Position 1136 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Test values are embedded as decimal text (for example "25.000000", "-2.1e120", "-5e-2", "NaN", "Inf", and a complex pair as two such strings), and a procedure scans each string with for loops over its own index range, validating the sign, digits, point and exponent and rejecting anything malformed (NaN, Inf) with a printed "false" outcome. Digits are counted in bounded Natural counters and the exponent is accumulated in a bounded integer with a guard against too many exponent digits, so integerness is decided as "the number of nonzero fractional digits after applying the exponent is zero" using only range-guarded integer arithmetic. The tolerance extra credit is left out, and each result is printed with Put_Line. About 150 lines.

## Proof obligations to watch

- **overflow**: The exponent accumulator is loop-carried, so each step is guarded by a digit-count cap that rejects over-long exponents with a visible outcome, keeping the value within its declared range.
- **range**: Positions computed from the decimal-point location plus the exponent are loop-carried and must be clamped by explicit guards against the string bounds before indexing.
- **floating point**: Handling values as text avoids floating-point entirely, at the cost that NaN and Inf exist only as rejected spellings rather than as real float values.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, text parsing, for loops, while loops, procedures, functions, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Each test case and its true/false verdict is printed to standard output.

Assessed on 2026-10-15 against page revision 413943 of the [task](https://rosettacode.org/wiki/Test_integerness) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
