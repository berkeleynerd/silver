# Write language name in 3D ASCII

**Candidate: proofs likely to discharge automatically.** The task is fixed text output, which today's Silver (String literals and Put_Line) already expresses, and there are no run-time checks to prove.

Position 20 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The program embeds the nine pre-indented lines of the slanted-shadow "Ada" banner as String literals and emits each with Silver_IO.Put_Line in a straight statement sequence. There are no loops, variables, arithmetic or inputs, so no guards are needed; backslashes are ordinary characters in Ada string literals. About 16 lines.

## External effects

- **console output** (allowed): Prints the nine lines of 3D ASCII art of the language name to standard output.

Assessed on 2026-10-15 against page revision 415097 of the [task](https://rosettacode.org/wiki/Write_language_name_in_3D_ASCII) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
