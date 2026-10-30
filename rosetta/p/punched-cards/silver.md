# Punched cards

**Candidate: proofs likely to discharge automatically.** Every check follows from fixed array bounds, for loops over bounded ranges, a length guard before indexing and case-range-bounded row arithmetic, with no loop-carried values and no function loops. The only new surface is arrays, string indexing, case statements and a procedure, all within the usual routine proofs.

Position 988 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A Punch procedure takes an unconstrained String, rejects over-80-column text and unmapped characters with a visible message, and sets Boolean flags in a card array indexed by column 1..80 and row 0..12 using a case statement over each character. It then builds each of the 13 output lines in a fixed 82-character String buffer by indexed assignment, prints them with Put_Line, and finally prints the top and bottom border lines from constants. Main calls Punch on the full character-set line and on the embedded Hello World program lines, with a Put_Line of the greeting between them. About 170 lines.

## Proof obligations to watch

- **index**: Card columns are addressed as I with I in 1..Text'Length after an explicit Text'Length > 80 rejection guard, and the source character as Text (Text'First + I - 1), which follows from the guard and the loop range.
- **range**: Each case alternative computes a row from Character'Pos differences, which the case choice range ('A'..'I', 'J'..'R', 'S'..'Z', 'a'..'i', 'j'..'r', 's'..'z', '0'..'9') bounds inside 0..12.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, multidimensional arrays, unconstrained arrays, string indexing, string building, case statements, for loops and procedures.

## External effects

- **console output** (allowed): Prints the 13-line card picture for each embedded text line with Put_Line.

Assessed on 2026-10-15 against page revision 414419 of the [task](https://rosettacode.org/wiki/Punched_cards) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
