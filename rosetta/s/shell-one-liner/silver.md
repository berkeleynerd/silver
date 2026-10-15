# Shell one-liner

**Candidate: proofs likely to discharge automatically.** The only Silver code is a Main procedure whose one statement is Put_Line of a literal, which today's Silver already admits and which raises no run-time checks. The shell side of the task is how the toolchain is invoked, not part of the program, so it does not conflict with the Oracle.

Position 1 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The program is one line of Silver: a parameterless Main procedure with pragma SPARK_Mode (On) that calls Silver_IO.Put_Line with a String literal. A single shell line passes it to the toolchain, for example echo writing main.adb and then the Silver build and run commands. Writing, compiling and running the file is the toolchain's job, so the program needs no guards and no surface beyond what Silver has today. About 1 line.

## External effects

- **console output** (allowed): The one-line program prints a greeting with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 409023 of the [task](https://rosettacode.org/wiki/Shell_one-liner) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
