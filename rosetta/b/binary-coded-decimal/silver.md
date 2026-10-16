# Binary coded decimal

**Candidate: proofs likely to discharge automatically.** Every operation is bounded digit arithmetic in for loops over fixed arrays whose carry, borrow and digits are limited by subtypes or an immediate guard, so no annotation is needed. The only care is subtraction digit range and string-buffer indexing, both handled by guards just before use.

Position 1290 in the [progression](../../progression.md#stage-22), in stage 22.

## Approach

Digits are stored little-endian in a fixed 4-element array of a 0..9 subtype for unpacked BCD, and in a 2-element array of bytes of two nibbles (mod 256 type with divide and mod by 16) for packed BCD. Procedures Add and Subtract run a for loop over the array range carrying a 0..1 carry or borrow, with an overflow flag if a carry leaves the top digit. The three embedded test cases are printed by building decimal text, with leading zeros stripped, and hex text from digit characters into a bounded buffer, then calling Put_Line. About 130 lines.

## Proof obligations to watch

- **range**: Subtraction digit Diff + 10 - Right stays in 0..9 only through the branch condition Diff < Right, which is a linear fact the guard provides just before the use.
- **overflow**: Carry and borrow are a 0..1 subtype and digit sums are at most 19, so loop-carried values are bounded by their types alone.
- **index**: Text rendering indexes a fixed buffer with the loop index and a length counter, which needs a guard that the counter stays within the buffer capacity.
- **other**: A carry out of the top digit is reported as an explicit overflow outcome rather than dropped, though the three test cases never reach it.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, procedures, functions, string building, string indexing, modular types and case statements.

## External effects

- **console output** (allowed): The program prints each test case's decimal and hexadecimal result lines with Put_Line.

Assessed on 2026-10-15 against page revision 393356 of the [task](https://rosettacode.org/wiki/Binary_coded_decimal) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
