# Walk a directory/Non-recursively

**Excluded from Silver: directories.** The task lists one directory and prints names matching a pattern. The pattern syntax is left open, so a simple substring match is enough. This needs only directory enumeration, argument input and text output, which Silver lacks today but which fit its rules once a specified library operation exists.

## Language surface beyond today's Silver

String operations, loops and subprograms.

## External effects

- **directories** (not allowed): Reads the entries of a single directory (non-recursive listing).
- **console output** (allowed): Prints the names of matching entries.
- **arguments** (allowed): The directory and pattern are supplied by the caller, most simply as command-line arguments.

Assessed on 2026-10-15 against page revision 411786 of the [task](https://rosettacode.org/wiki/Walk_a_directory/Non-recursively) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
