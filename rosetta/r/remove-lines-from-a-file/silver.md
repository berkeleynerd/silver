# Remove lines from a file

**Excluded from Silver: directories.** All arithmetic is on bounded integer ranges and the loops are while loops in procedures, so no annotations are needed, but the proof depends on admitted file, argument and rename operations that do not exist in Silver yet.

## Approach

The Main procedure parses three arguments (filename, first line, count) with validation and rejects bad input with a usage message and nonzero status. It then reads the file line by line into a bounded buffer with a counter, writes lines outside the removed range to a temporary file, and renames it over the original only if the range lay within the file. If the range extends beyond the end, it prints a message, leaves the original untouched and sets a nonzero status. About 90 lines.

## Proof obligations to watch

- **index**: Each line sits in a bounded buffer with a tracked length, and a line longer than the capacity is rejected before any copy so every index is guarded.
- **overflow**: The end line is first plus count minus one, so both numbers are parsed into a declared range and the sum is computed in a wider range, which makes the check routine.
- **termination**: The line-reading loop is a while loop inside a procedure, which receives no termination check, so no variant is needed.
- **other**: The file operations depend on admitted library operations that specify their failure outcomes, including a failed read, write or rename.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, text parsing, for loops, while loops, procedures, functions, further arguments, exit status, file input and file output.

## External effects

- **arguments** (allowed): Filename, starting line and count come from the command line, so more than the first argument is needed.
- **files** (allowed): Reads the named file line by line and writes the remaining lines to a temporary file.
- **directories** (not allowed): Replacing the original with the temporary file needs a rename of a file in its directory.
- **console output** (allowed): Reports usage errors and an attempt to remove lines beyond the end of the file.
- **exit status** (allowed): Invalid arguments, missing files and out-of-range removal should end with a nonzero status.

Assessed on 2026-10-15 against page revision 414748 of the [task](https://rosettacode.org/wiki/Remove_lines_from_a_file) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
