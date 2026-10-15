# Create your own text control codes

**Candidate: proofs plausibly discharge automatically.** The task is a self-written formatting routine over embedded data, which needs only bounded buffers, guarded indexing and simple integer arithmetic, so no annotation should be needed beyond careful guards on the loop-carried buffer position.

Position 816 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

The program embeds a constant format string and the argument values (an integer and a text string), and a procedure scans it with a for loop, copying characters into a fixed-capacity output buffer with a length counter. Control codes %d, %s, the new %y (integer with thousands commas) and %z (reversed string) are handled by a case statement, with backslash-n producing a line break by emitting the buffer in separate Put_Line calls. Every append is guarded by a capacity check and unknown codes are copied literally, giving a specified outcome for every input. About 90 lines.

## Proof obligations to watch

- **index**: The output buffer position is loop-carried, so each append is guarded by an explicit capacity test that rejects the run visibly instead of truncating.
- **range**: The format-string scan index advances by one or two inside the loop, so a guard that the next character exists is placed before each lookahead after % or backslash.
- **overflow**: Digit extraction and comma insertion use a constant embedded Integer value whose type range bounds the divisions, so the digit loop is a bounded for loop.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, string indexing, string building, 'Image of scalars, case statements, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The program prints the formatted result lines to standard output.

Assessed on 2026-10-15 against page revision 409929 of the [task](https://rosettacode.org/wiki/Create_your_own_text_control_codes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
