# Checksumcolor

**Excluded from Silver: terminal control.** The utility reads checksum lines from stdin, splits the hex digest into groups of 3 or 6 digits, maps each group's RGB value to the nearest console color by integer arithmetic, and prints it with color codes (or plain text if not a terminal). This needs bounded line buffers, validation of malformed lines, stdin, console output and terminal detection, and fits no fixed Oracle conflict.

## Language surface recorded by this assessment

String operations, characters, integers, arrays, loops, subprograms and enumerations.

## External effects

- **standard input** (allowed): Reads md5sum/shaXsum output lines piped in on standard input.
- **console output** (allowed): Prints each line, with the checksum recolored using console color escape codes, or unchanged when output is not a terminal.
- **terminal control** (not allowed): Must detect whether stdout is a terminal and emit console color codes for the closest of the console colors.

Assessed on 2026-10-15 against page revision 380975 of the [task](https://rosettacode.org/wiki/Checksumcolor) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
