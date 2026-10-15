# Check that file exists

**Excluded from Silver: directories.** The task checks that a file and a directory exist, in the current directory and in the root, and reports the results. That needs only a specified existence and kind query operation (which returns a Boolean rather than failing) plus text output. Nothing in it breaks an Oracle rule, so it is a candidate once such a library operation is admitted.

## External effects

- **directories** (not allowed): Needs an existence and kind query (file vs directory) for input.txt and docs, relative to the current directory and in the filesystem root.
- **console output** (allowed): Prints whether each file and directory exists.

Assessed on 2026-10-15 against page revision 412701 of the [task](https://rosettacode.org/wiki/Check_that_file_exists) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
