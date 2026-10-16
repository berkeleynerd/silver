# Calendar - for "REAL" programmers

**Candidate: proofs likely to discharge automatically.** Every check follows from for-loop indexes over small constant ranges and a guard that the day number lies in 1..month length before it is converted to digits, with no loop-carried values or recursion. The only effect is console output of fixed-size text.

Position 541 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The year is fixed at 1969 (not a leap year), with embedded constant arrays for month lengths, Jan-1-weekday-derived start offsets per month, and one fixed-width month-name text. Nested for loops over month group (3), week row (6) and month in group (4) with day columns (7) fill a String(1..132) buffer with blanks, day-number digits via mod/div on Character'Val/'Pos, and then call Put_Line per line, after the centered placeholder and the NINETEEN-SIXTY-NINE title. All code is written in uppercase, which Ada's case-insensitivity permits. About 110 lines.

## Proof obligations to watch

- **index**: Column positions in the 132-character line buffer and month-name slices are computed from for-loop indexes with small declared ranges, so the bounds follow from types and static ranges.
- **overflow**: Day-number arithmetic (row*7 + column - start offset) uses small ranged subtypes and a guarded 1..days test before digit conversion, so no overflow or range check is left open.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, for loops and procedures.

## External effects

- **console output** (allowed): Prints the 132-column 1969 calendar with the Snoopy placeholder and title lines via Put_Line.

Assessed on 2026-10-15 against page revision 408028 of the [task](https://rosettacode.org/wiki/Calendar_-_for_%22REAL%22_programmers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
