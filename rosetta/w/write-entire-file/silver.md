# Write entire file

**Candidate: proofs likely to discharge automatically.** The task is a single library call with constant data and no loops or arithmetic, so every check is trivial and the only missing piece is an admitted file-writing operation with specified failure outcomes. The Ada solution's exception handler for Name_Error is replaced by the library's status result.

Position 1417 in the [progression](../../progression.md#stage-26), in stage 26, which adds file output.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

Main holds a fixed file name constant and an embedded String constant (the task text), then calls an admitted library procedure that overwrites the file with that string and reports a success flag. An if statement on the flag prints a visible failure message and sets a nonzero exit status when the write fails, so no exception handler is needed. About 12 lines.

## Language surface recorded by this assessment

File output and procedures.

## External effects

- **files** (allowed): The program must create or overwrite a named file so that it contains a string.
- **console output** (allowed): A rejection or failure message is printed when the file cannot be written.
- **exit status** (allowed): A write failure should be reported through a nonzero exit status.

Assessed on 2026-10-15 against page revision 415149 of the [task](https://rosettacode.org/wiki/Write_entire_file) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
