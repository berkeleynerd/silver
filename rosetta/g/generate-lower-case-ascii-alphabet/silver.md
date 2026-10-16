# Generate lower case ASCII alphabet

**Candidate: proofs likely to discharge automatically.** Every check (index, range of the computed character, array bounds) follows from a for loop over the array's own range and static type bounds, so no loop-carried value needs an invariant.

Position 437 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Declare a subtype Lower of Character range 'a' .. 'z' and a constrained array type indexed 1 .. 26 of Lower. A for loop over the array's own range fills each element with Character'Val (Character'Pos ('a') + I - 1), which is bounded by the index range, and a second for loop copies the elements into a 26-character String buffer. The program then prints the buffer with Put_Line, using a Put-style call for any separators. About 22 lines.

## Language surface recorded by this assessment

Characters, ranged subtypes, arrays, for loops, string building, Put without a newline and procedures.

## External effects

- **console output** (allowed): The program prints the generated alphabet to standard output.

Assessed on 2026-10-15 against page revision 412816 of the [task](https://rosettacode.org/wiki/Generate_lower_case_ASCII_alphabet) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
