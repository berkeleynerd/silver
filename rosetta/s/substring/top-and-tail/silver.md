# Substring/Top and tail

**Candidate: proofs likely to discharge automatically.** The only new surface is slicing a String by static bounds, and every slice bound is statically within the constant's range so the index and length checks discharge without guards. There are no loops, arithmetic or input.

Position 479 in the [progression](../../../progression.md#stage-10), in stage 10, which adds string indexing.

## Approach

Declare a constant String "upraisers" (ASCII, an 8-bit encoding the task exempts from full Unicode handling) and print the original and three slices with literal bounds 2..9, 1..8 and 2..8, each concatenated into a labeled quoted line using the existing bounded concatenation and Put_Line. No loops or inputs are involved, so all index and length checks are static. About 12 lines.

## Language surface recorded by this assessment

String indexing and Put without a newline.

## External effects

- **console output** (allowed): Prints the full string and the three trimmed variants with Put_Line.

Assessed on 2026-10-15 against page revision 415058 of the [task](https://rosettacode.org/wiki/Substring/Top_and_tail) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
