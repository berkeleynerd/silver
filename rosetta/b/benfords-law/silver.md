# Benford's law

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared digit and count ranges plus a carry-out guard, and no loop needs an invariant, but the nested carry loops and guarded counters need careful shape; floating point is avoided with embedded expected constants.

Position 1371 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Two fixed-capacity little-endian decimal digit arrays (220 digits, each element a 0..9 subtype) hold consecutive Fibonacci numbers and are advanced 1000 times by a for loop whose inner for loop does ripple-carry addition. After each step a for loop over the array finds the most significant nonzero digit, which increments a guarded count in a nine-element array. The table of count, expected count, actual percent and expected percent (embedded integer constants, integer division for the actual values) is printed by a for loop over digits 1..9 using 'Image and bounded concatenation. About 110 lines.

## Proof obligations to watch

- **overflow**: The digit-array addition carries through loops, so each digit sum is bounded by the 0..9 digit subtype (at most 19) and a leftover carry out of the top digit is rejected visibly by a guard, since the 1000th Fibonacci number needs only 209 of 220 digits.
- **range**: The per-digit counters are incremented in a loop with no invariant, so each increment is guarded by a comparison against the counter subtype's upper bound with Reject as the visible outcome.
- **index**: The first-digit scan walks a for loop over the digit array's own range and keeps the highest nonzero digit found, so every index is within bounds by construction.
- **floating point**: Avoided by embedding the expected Benford percentages as integer hundredths constants instead of computing log10, and computing actual percentages with integer division.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, big numbers, string building and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the actual versus expected first-digit table with Put_Line.

Assessed on 2026-10-15 against page revision 414927 of the [task](https://rosettacode.org/wiki/Benford's_law) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
