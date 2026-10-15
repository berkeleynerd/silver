# Terminal control/Display an extended character

**Candidate: proofs likely to discharge automatically.** The program is straight-line code over constants with a single output call, so every check follows from static values and the only new surface is Character'Val with Character values.

Position 432 in the [progression](../../../progression.md#stage-11), in stage 11, which adds characters.

## Approach

Declare a constant two-character String made of Character'Val (194) and Character'Val (163), the UTF-8 encoding of the GBP sign, concatenated using the existing bounded String concatenation, and print it with Silver_IO.Put_Line. There are no loops, no input and no data-dependent control flow. About 8 lines.

## Language surface beyond today's Silver

Characters.

## External effects

- **console output** (allowed): The program writes the pound sign to standard output, with its terminal encoding (UTF-8 bytes C2 A3) an environmental assumption of the output operation.

Assessed on 2026-10-15 against page revision 415091 of the [task](https://rosettacode.org/wiki/Terminal_control/Display_an_extended_character) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
