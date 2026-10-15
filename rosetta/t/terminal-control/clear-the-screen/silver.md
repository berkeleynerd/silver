# Terminal control/Clear the screen

**Excluded from Silver: terminal control.** The program is a single constant string written to the console, so every check is static and nothing needs an annotation. The only gap is an admitted terminal-clear operation, or Put plus a way to form the ESC character.

## Approach

A Main procedure declares a constant 4-character String built from Character'Val (27) followed by the literal "[2J", then writes it once with a no-newline Put. There are no loops, arrays or inputs, so no guards are needed. About 12 lines.

## Language surface beyond today's Silver

Characters, Put without a newline and string building.

## External effects

- **terminal control** (not allowed): The program clears the terminal window by emitting the ANSI clear-screen sequence (ESC [ 2 J).
- **console output** (allowed): The escape sequence is written to standard output without a line terminator.

Assessed on 2026-10-15 against page revision 414173 of the [task](https://rosettacode.org/wiki/Terminal_control/Clear_the_screen) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
