# Literals/Integer

**Candidate: proofs likely to discharge automatically.** Current Integer numerals already cover decimal and every based literal base from 2 through 16, hash and colon delimiters, digit separators, nonnegative exponents and the signed Integer endpoints. Numeral interpretation is performed by the language, with Image used only to display the resulting values.

Position 47 in the [progression](../../../progression.md#stage-1), in stage 1.

## Approach

Explain the complete parameterized syntax: B is a decimal base from 2 through 16; write B#digits# or B:digits: using digit values below B, with case-insensitive A through F for values 10 through 15. Single underscores may separate digits. A nonnegative E exponent multiplies a based numeral by B raised to that exponent, while a decimal numeral uses base 10; the current exponent resource bound is 4096 and the resulting signed value must fit Integer. Demonstrate representative bases 2, 8, 10 and 16, both delimiters, separators, 727E0, 7#1#E3 and the signed endpoints using literal Integer initializers, not parsing/conversion calls. The first seven examples denote 727; 7#1#E3 denotes 343. Unary minus forms the negative endpoint expression. Current Silver has one predefined signed Integer type; no additional integer type or unsigned suffix syntax is claimed. About 29 lines.

## Language surface recorded by this assessment

Immutable Integer arithmetic and Integer image.

## External effects

- **console output** (allowed): Prints the value of each based literal with Silver_IO.Put_Line.

Initially assessed on 2026-10-15 against page revision 412883 of the [task](https://rosettacode.org/wiki/Literals/Integer) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../../assessment-reconciliation-20261025.md).
