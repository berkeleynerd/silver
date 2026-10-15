# Create a file on magnetic tape

**Excluded from Silver: hardware.** The task is to create a file named TAPE.FILE on magnetic tape, which needs a file-creation operation and tape hardware access. No Oracle rule is broken, so Silver could cover it once admitted library operations exist for file creation and tape hardware.

## External effects

- **files** (allowed): Create a new file named TAPE.FILE on the tape device or a tape-mounted path, and write content to it.
- **hardware** (not allowed): The task requires the file to be on magnetic tape, a physical storage device.

Assessed on 2026-10-15 against page revision 410069 of the [task](https://rosettacode.org/wiki/Create_a_file_on_magnetic_tape) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
