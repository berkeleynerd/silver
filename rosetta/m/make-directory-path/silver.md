# Make directory path

**Excluded from Silver: directories.** The task is to create a directory path with the same behavior as mkdir -p, succeeding if it already exists. This needs a directory-creation effect that Silver does not yet have, plus string handling to split the path, but it breaks no fixed Oracle rule. Bounded path length and a specified failure outcome (non-zero exit status) fit Silver.

## Language surface beyond today's Silver

String operations and loops.

## External effects

- **directories** (not allowed): Creates a directory and any missing parent directories, and must succeed quietly if the directory already exists.
- **arguments** (allowed): The path string is naturally supplied as a command-line argument by a runnable program.
- **exit status** (allowed): A Silver program needs to report success or failure of directory creation, including an invalid path or a failed creation, through its exit status.

Assessed on 2026-10-15 against page revision 415241 of the [task](https://rosettacode.org/wiki/Make_directory_path) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
