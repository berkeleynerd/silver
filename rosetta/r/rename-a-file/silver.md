# Rename a file

**Excluded from Silver: directories.** The task renames one file and one directory, once in the current directory and once in the filesystem root. That needs only an admitted rename operation with specified failure outcomes (for example a missing source or a permission error). Nothing in it breaks an Oracle rule.

## External effects

- **directories** (not allowed): Renames the directory docs to mydocs, in the current directory and in the filesystem root.
- **files** (allowed): Renames the file input.txt to output.txt, in the current directory and in the filesystem root.

Assessed on 2026-10-15 against page revision 415104 of the [task](https://rosettacode.org/wiki/Rename_a_file) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
