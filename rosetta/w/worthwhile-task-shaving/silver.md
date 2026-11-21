# Worthwhile task shaving

**Candidate: proofs likely to discharge automatically.** Every operand is bounded by constant tables and a wide declared integer range, loops are for loops over array ranges, and output is plain text, so all checks follow from types and static bounds. The only care needed is the 64-bit product range and fixed-width cell buffer lengths.

Position 461 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Constant arrays hold the nine shaved-seconds values, the six per-five-year frequencies (using integer 365-day-year constants) and the unit labels; a nested for loop over the array index ranges computes t and picks a unit via an if/elsif chain with constant divisors. Each cell is formatted into a fixed 13-character buffer by a procedure using 'Image of a small bounded count plus pluralised unit text, and rows are emitted with Put and Put_Line. Blank cells are emitted as spaces for the over-a-year cases. About 95 lines.

## Proof obligations to watch

- **overflow**: The product of frequency, shaved seconds and five years reaches about 8e9, so it is computed in a declared 64-bit range type whose constant array elements bound every operand.
- **length**: Each cell is built in a fixed 13-character buffer with a padding procedure that guards the number's digit count before copying, so no slice can exceed the buffer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building, Put without a newline and characters.

## External effects

- **console output** (allowed): The table is printed as text lines to standard output.

Assessed on 2026-10-15 against page revision 414589 of the [task](https://rosettacode.org/wiki/Worthwhile_task_shaving) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
