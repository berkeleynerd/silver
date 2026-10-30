# Formatted numeric output

**Candidate: proofs likely to discharge automatically.** Every index is a static loop bound, and the digit is N mod 10 (so always 0..9) before Character'Val, so the checks follow from types and no annotation is needed. The values are small and bounded, so there is no nonlinear arithmetic and no overflow risk.

Position 468 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Represent 7.125 as the scaled integer 7125 thousandths in a range-bounded subtype, and fill a fixed 9-character String buffer from right to left with a for loop, taking each digit as N mod 10 and then dividing N by 10. The decimal point is written at position 6 and the digit positions are 1..5 and 7..9, so every index is a static loop bound. The buffer is printed with Silver_IO.Put_Line. About 22 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string indexing, string building and for loops.

## External effects

- **console output** (allowed): The formatted string is printed with Put_Line.

Assessed on 2026-10-15 against page revision 412804 of the [task](https://rosettacode.org/wiki/Formatted_numeric_output) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
