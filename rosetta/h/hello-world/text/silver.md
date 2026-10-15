# Hello world/Text

**Candidate: proofs likely to discharge automatically.** The task needs only a String literal passed to Silver_IO.Put_Line, which Silver already supports, so there are no run-time checks to prove.

Position 3 in the [progression](../../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main procedure with pragma SPARK_Mode (On) and a with/use of Silver_IO calls Silver_IO.Put_Line with the String literal "Hello world!". There is no data, no loop and no input, so no guards are needed. About 6 lines.

## External effects

- **console output** (allowed): The program prints the line Hello world! to the console.

Assessed on 2026-10-15 against page revision 415455 of the [task](https://rosettacode.org/wiki/Hello_world/Text) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
