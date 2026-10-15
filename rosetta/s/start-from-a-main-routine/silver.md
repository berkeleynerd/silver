# Start from a main routine

**Candidate: proofs likely to discharge automatically.** The task only needs a parameterless main procedure that runs at startup, which Silver already supports, and it has no run-time checks to prove.

Position 4 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main procedure with pragma SPARK_Mode (On) is the program's entry point, with no event loop or window. Its body prints one String literal with Silver_IO.Put_Line to demonstrate that startup goes straight to the main routine. There is no data, no loop and no guard. About 6 lines.

## External effects

- **console output** (allowed): The main procedure prints a line through Silver_IO.Put_Line to show it ran.

Assessed on 2026-10-15 against page revision 413054 of the [task](https://rosettacode.org/wiki/Start_from_a_main_routine) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
