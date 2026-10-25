# Include a file

**Candidate: proofs likely to discharge automatically.** The program only needs a with clause on a user package in another file and one call to a procedure that prints a literal, so every check is trivial. Silver needs user packages and procedures plus multi-file support, and nothing in the Oracle conflicts with this.

Position 1455 in the [progression](../../progression.md#stage-27), in stage 27, which adds packages.

## Approach

A small package in its own source file declares one parameterless procedure that calls Silver_IO.Put_Line with a fixed message, and Main withs that package and calls the procedure. There are no loops, arithmetic or data, so control flow is a single call, and the only new capability needed is multi-file compilation units with user-defined packages. About 20 lines.

## Language surface recorded by this assessment

Packages and procedures.

## External effects

- **console output** (allowed): The included package's procedure prints a line to show that the other file's code was used.

Assessed on 2026-10-15 against page revision 412843 of the [task](https://rosettacode.org/wiki/Include_a_file) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
