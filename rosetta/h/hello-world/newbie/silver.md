# Hello world/Newbie

**Candidate: proofs likely to discharge automatically.** The task is satisfied by printing embedded instruction text, which uses only constructs Silver already has, so there are no run-time checks, loops or annotations to discharge.

Position 42 in the [progression](../../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main procedure with SPARK_Mode (On) emits a fixed sequence of Put_Line calls on String literals, covering install steps, choice of a plain text editor, saving, compiling and running the Hello world program, and where to view the output (the terminal). There are no variables, loops or inputs, so no guards are needed. About 25 lines.

## External effects

- **console output** (allowed): The installation and run instructions are printed to standard output with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415273 of the [task](https://rosettacode.org/wiki/Hello_world/Newbie) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
