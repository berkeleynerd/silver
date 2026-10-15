# Unix/ls

**Excluded from Silver: directories.** The program lists the current directory and prints the names sorted. That needs an admitted directory-listing operation with specified failure outcomes, plus a bounded sort over fixed-capacity name storage, so no Oracle rule is broken.

## Language surface beyond today's Silver

Arrays, string operations, loops and subprograms.

## External effects

- **directories** (not allowed): Lists the entries of the current directory.
- **console output** (allowed): Prints the sorted entry names, one per line.

Assessed on 2026-10-15 against page revision 414669 of the [task](https://rosettacode.org/wiki/Unix/ls) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
