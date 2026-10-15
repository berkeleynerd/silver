# Terminal control/Coloured text

**Excluded from Silver: terminal control.** Everything is a fixed loop over a constant array with literal data and no loop-carried values, so index and length checks follow from static bounds. The only new needs are Character'Val and bounded concatenation with a Character, both routine.

## Approach

Declare an ESC Character constant (Character'Val (27)) and a constant array indexed by a 1 .. 6 subtype holding six equal-length colour code Strings such as "[31m" through "[36m". A for loop over the array's own range builds ESC & code & "Rosetta" & ESC & "[0m" by bounded concatenation and prints it with Silver_IO.Put_Line. About 24 lines.

## Language surface beyond today's Silver

Characters, arrays, ranged subtypes, for loops and string building.

## External effects

- **console output** (allowed): Prints each coloured word as a line of text on standard output.
- **terminal control** (not allowed): The colour is selected by ANSI escape sequences that the terminal interprets, with the escape byte emitted as ordinary output text.

Assessed on 2026-10-15 against page revision 415052 of the [task](https://rosettacode.org/wiki/Terminal_control/Coloured_text) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
