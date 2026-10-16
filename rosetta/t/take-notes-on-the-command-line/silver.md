# Take notes on the command line

**Excluded from Silver: clock.** The task reads or appends to a local NOTES.TXT, using the command-line arguments and the current date and time, and prints the file when no arguments are given. It needs only effects (arguments, files, clock, console output) and bounded strings, so it can be covered once Silver admits those operations. Failure outcomes (missing file, unwritable file) can be specified by the library operations.

## Language surface recorded by this assessment

String operations, loops, arrays, characters and subprograms.

## External effects

- **arguments** (allowed): Detect whether any arguments were given and join all of them with spaces.
- **files** (allowed): Read NOTES.TXT, or append to it and create it when missing.
- **clock** (not allowed): The current date and time are appended to the notes file.
- **console output** (allowed): With no arguments, the contents of NOTES.TXT are printed.

Assessed on 2026-10-15 against page revision 413940 of the [task](https://rosettacode.org/wiki/Take_notes_on_the_command_line) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
