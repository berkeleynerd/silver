# Print debugging statement

**Candidate: proofs likely to discharge automatically.** The program is only String literals and Put_Line, which Silver already supports, so no check can fail and nothing needs a loop or annotation. Provenance is written as literal text because the task only asks to show source information in print statements.

Position 28 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main procedure runs a few steps and, before each, prints a trace line of fixed String literals naming the file, line, column and a code fragment (for example "TRACE main.adb:12:7 Put_Line step one"). There are no loops, inputs or arithmetic, so the program is a straight sequence of Put_Line calls. About 15 lines.

## External effects

- **console output** (allowed): Trace lines are written to standard output with Put_Line.

Assessed on 2026-10-15 against page revision 400822 of the [task](https://rosettacode.org/wiki/Print_debugging_statement) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
