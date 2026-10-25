# Convert decimal number to rational

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged types and guards before each accumulation, and the only loops with loop-carried state are for loops or a gcd while loop inside a procedure, so no annotation is needed, though the guarded parse and string building need careful shape.

Position 1129 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the three example decimals as String constants ("0.75", "0.9054054", "0.518518"), and a parsing procedure scans each character, rejecting anything other than digits and one point, accumulating the digits into a ranged integer numerator and counting fraction digits (at most 17) with a guard before each multiply-add. The denominator is built as a power of ten by a for loop over the digit count, a procedure computes the gcd by Euclid's while loop, and both numerator and denominator are divided by it and printed as "N / D" in a bounded buffer, with invalid input printed as a specified rejection line. About 90 lines.

## Proof obligations to watch

- **overflow**: Digits are accumulated into a 64-bit value and the parser rejects any input with more than 17 digits, so Value*10+Digit stays in range via a guard before each step.
- **termination**: Euclid's gcd loop lives in a procedure, which gets no termination check, and its mod divisor is guarded to be nonzero by the loop condition.
- **range**: The loop-carried accumulator and scale carry no invariant, so they are typed with ranged subtypes (digit count 0..17, value 0..10**17) and guarded before each update.
- **length**: Output text is built in a fixed-size buffer sized for two 18-digit numbers plus separators, with the scalar image lengths bounded by the ranged types.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops and procedures.

## External effects

- **console output** (allowed): Prints each decimal with its reduced fraction, one line per example.

Assessed on 2026-10-15 against page revision 409785 of the [task](https://rosettacode.org/wiki/Convert_decimal_number_to_rational) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
