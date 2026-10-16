# File modification time

**Excluded from Silver: directories.** The task is to get and set a file's modification time, which needs admitted library operations for file metadata (read and write timestamps) with specified failure outcomes (missing file, permission denied). Nothing conflicts with the Oracle rules; these are effects Silver lacks today.

## Language surface recorded by this assessment

String operations and records.

## External effects

- **files** (allowed): Reads and sets the modification time of a named file.
- **directories** (not allowed): File metadata (modification timestamp) is read and written.
- **console output** (allowed): Prints the retrieved modification time.
- **arguments** (allowed): The target file name is taken from the command line.

Assessed on 2026-10-15 against page revision 413541 of the [task](https://rosettacode.org/wiki/File_modification_time) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
