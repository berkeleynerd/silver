# Department numbers

**Candidate: proofs likely to discharge automatically.** Every check follows from the 1 .. 7 loop index ranges (the sum is at most 21, 'Image strings are short and bounded) and for loops terminate by themselves, so no annotation is needed. Nothing is carried across iterations and the output is fixed and deterministic.

Position 110 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Main prints a header, then three nested for loops over 1 .. 7 for police, sanitation and fire, with the loop indexes as the only data. An if statement tests Police mod 2 = 0, the three inequalities and a sum of 12, and prints the three values with 'Image and bounded concatenation. All state is loop indexes, so no loop-carried values exist. About 22 lines.

## Language surface beyond today's Silver

Integers, integer division, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints a header line and the 14 valid combinations with Put_Line.

Assessed on 2026-10-15 against page revision 415394 of the [task](https://rosettacode.org/wiki/Department_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
