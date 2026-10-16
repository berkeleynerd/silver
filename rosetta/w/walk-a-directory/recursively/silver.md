# Walk a directory/Recursively

**Excluded from Silver: directories.** The task asks the program to walk a directory tree and print files matching a pattern. A Silver-friendly solution does this with an explicit stack in a bounded array instead of recursion, plus a bounded wildcard matcher. It needs directory listing, console output and command-line arguments, none of which conflicts with an Oracle rule.

## Language surface recorded by this assessment

String operations, loops, arrays and subprograms.

## External effects

- **directories** (not allowed): Must enumerate the entries of a directory tree and tell files from subdirectories.
- **console output** (allowed): Prints the paths of files whose names match the pattern.
- **arguments** (allowed): The root directory and the pattern are the task's given inputs. The program can take them from the command line.

Assessed on 2026-10-15 against page revision 411839 of the [task](https://rosettacode.org/wiki/Walk_a_directory/Recursively) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
