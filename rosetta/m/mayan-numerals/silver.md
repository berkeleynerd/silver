# Mayan numerals

**Candidate: proofs likely to discharge automatically.** Everything is a bounded for-loop over fixed-size arrays and buffers with types that bound every loop-carried value, so every check follows from types and static bounds, and no annotation, recursion, or while loop is needed.

Position 808 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Each embedded number (4005, 8017, 326205, 886205, plus 16000) is held in a Natural-range variable, and a fixed for loop of five iterations splits it into base-20 digits in an Integer-ranged array of 5, using mod 20 and /20, which stay in range. A for loop then finds the most significant nonzero digit, with a guard that keeps at least one digit for the value 0. A procedure builds each of the six cartouche rows into a fixed-length String buffer by writing characters at computed, range-bounded indices (glyph rows come from a case statement on the digit's dots and bars), and prints each row with Put_Line. About 150 lines.

## Proof obligations to watch

- **index**: Buffer positions are computed from the digit position (5 columns each), so the index arithmetic is bounded by the loop range over the 5 digit positions and the fixed buffer length (at most 26 characters), which makes it routine for the provers.
- **range**: The digit extraction repeatedly divides a loop-carried value, but the value's Natural type bounds it and mod 20 gives 0..19, so the digit conversions into the 0..19 subtype need no invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, case statements, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The cartouches are printed as ASCII art lines with Put_Line.

Assessed on 2026-10-15 against page revision 414335 of the [task](https://rosettacode.org/wiki/Mayan_numerals) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
