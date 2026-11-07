# Split a character string based on change of character

**Candidate: proofs likely to discharge automatically.** The for loop indexes the constant's own range and the previous-character access is guarded by I > S'First, so all checks are routine and no annotation is needed. Output is a streamed sequence of Put calls, avoiding any bounded output buffer.

Position 479 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed the example string as a String constant and run one for loop over its index range. For each position after the first, print ", " when the character differs from the previous one (guarded by an index greater than S'First), then print the character as a one-character slice, and end with a line terminator. No buffer or loop-carried value is needed, so every index check follows from the loop range and the guard. About 22 lines.

## Language surface recorded by this assessment

Integers, characters, string indexing, for loops and Put without a newline.

## External effects

- **console output** (allowed): The program prints the split string to standard output.

Assessed on 2026-10-15 against page revision 415171 of the [task](https://rosettacode.org/wiki/Split_a_character_string_based_on_change_of_character) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
