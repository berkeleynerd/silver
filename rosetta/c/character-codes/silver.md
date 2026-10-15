# Character codes

**Candidate: proofs likely to discharge automatically.** Every check is static: Character'Val of a constant in 0..255 cannot fail the range check, and the concatenated image length is bounded by Integer'Image's known maximum. No loops, recursion or input are involved, so no annotations are needed.

Position 434 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

The program embeds the character 'a' and the code 97 as constants, computes Character'Pos of the character and Character'Val of the code, and prints both with Put_Line. Output lines are built by concatenating text, a Character and Integer'Image of the position. There are no loops or input, so no guards are needed because the constant 97 is statically within Character's range. About 12 lines.

## Language surface beyond today's Silver

Characters, integers, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the code of a character and the character for a code with Put_Line.

Assessed on 2026-10-15 against page revision 415359 of the [task](https://rosettacode.org/wiki/Character_codes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
