# Empty program

**Candidate: proofs likely to discharge automatically.** The program has no data, no operations and no loops, so no check can arise and Bronze and Silver proofs discharge trivially with no new surface.

Position 2 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main procedure with pragma SPARK_Mode (On) whose body is a single null statement. It has no data, no control flow and no guards, and it does only what today's Silver already supports. About 4 lines.

Assessed on 2026-10-15 against page revision 415414 of the [task](https://rosettacode.org/wiki/Empty_program) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
