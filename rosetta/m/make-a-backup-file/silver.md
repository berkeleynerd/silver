# Make a backup file

**Excluded from Silver: directories.** The task needs a file rename (not copy), symlink-target resolution, and writing new text, all doable through a specified file and directory library operation with defined failure outcomes. Nothing in it breaks an Oracle rule; it only needs file and directory effects Silver lacks today.

## Language surface beyond today's Silver

String operations.

## External effects

- **files** (allowed): Renames the existing target file to a backup name and writes new text to a new file under the original name.
- **directories** (not allowed): Must resolve symlinks to their target and check that the file exists, so it needs file metadata and link resolution.
- **arguments** (allowed): The file name to back up and rewrite is most naturally given as a command-line argument.
- **console output** (allowed): Reports the outcome, including a rejected missing file.

Assessed on 2026-10-15 against page revision 410706 of the [task](https://rosettacode.org/wiki/Make_a_backup_file) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
