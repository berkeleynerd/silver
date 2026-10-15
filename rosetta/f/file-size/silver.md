# File size

**Excluded from Silver: directories.** The task only needs to query the byte size of two named files (./input.txt and /input.txt) and print them, which requires a file-metadata effect and console output. A missing file can be reported as a specified outcome, so no fixed Oracle rule is violated.

## Language surface beyond today's Silver

Integers and string operations.

## External effects

- **directories** (not allowed): Needs file metadata (size in bytes) of input.txt in the current working directory and in the file system root.
- **console output** (allowed): Prints the verified sizes, or a specified message when a file is missing.

Assessed on 2026-10-15 against page revision 411610 of the [task](https://rosettacode.org/wiki/File_size) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
