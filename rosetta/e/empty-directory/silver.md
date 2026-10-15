# Empty directory

**Excluded from Silver: directories.** The task takes a path and decides whether the directory has any entries besides '.' and '..'. A bounded-string path and a loop over directory entries would do it. No Oracle rule is broken, and the only missing pieces are directory inspection, an argument and console output. Missing or non-directory paths give a visible outcome.

## External effects

- **arguments** (allowed): The directory path is the task's input and can be supplied as a command-line argument.
- **directories** (not allowed): The program must inspect a directory's entries to decide whether it holds anything other than '.' and '..'. It must also report a path that does not exist or is not a directory.
- **console output** (allowed): The program prints the verdict: empty, not empty, not a directory, or does not exist.

Assessed on 2026-10-15 against page revision 414942 of the [task](https://rosettacode.org/wiki/Empty_directory) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
