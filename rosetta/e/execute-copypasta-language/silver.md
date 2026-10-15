# Execute CopyPasta Language

**Candidate: proofs plausibly discharge automatically.** Everything is bounded buffers, guarded indexes and procedure-only loops, so no annotation should be needed, but loop-carried cursors and lengths each need a guard placed just before use, which makes discharge depend on careful program shape.

Position 1339 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

The program holds the source and clipboard in fixed-capacity character buffers with explicit lengths, loads the source from the file named by the first argument or an embedded sample, and splits it into trimmed lines with a guarded scan. A while loop in a procedure dispatches on each command line (Copy, CopyFile, Duplicate, Pasta!), checking capacity before every append, parsing the Duplicate count with validation, and printing a specified error for unknown commands, bad counts, missing files or a missing Pasta!. About 170 lines.

## Proof obligations to watch

- **length**: Duplicate can grow the clipboard exponentially, so the program checks the new length against the fixed clipboard capacity before each append and reports a specified overflow message instead of truncating.
- **overflow**: The repetition count is parsed digit by digit with a guard against exceeding a small cap, and clipboard length times count is only computed after that bound is checked.
- **index**: The line cursor is a loop-carried value in a while loop, so each line scan is guarded by explicit bounds tests against the program length just before every character read.
- **termination**: The interpreter loop is a procedure with a strictly advancing cursor, so no termination check applies.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, text parsing, case statements, for loops, while loops, procedures, functions, Put without a newline and file input.

## External effects

- **console output** (allowed): Pasta! prints the clipboard and error messages for unknown commands or bad repetition counts go to the console.
- **files** (allowed): CopyFile reads the named text file (or the program's own source for TheF*ckingCode), with a specified outcome when the file cannot be opened.
- **arguments** (allowed): The first argument names the CopyPasta program file to interpret, falling back to embedded sample programs.

Assessed on 2026-10-15 against page revision 402571 of the [task](https://rosettacode.org/wiki/Execute_CopyPasta_Language) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
