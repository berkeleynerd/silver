# Rubik's Magic Simulation

**Candidate: proofs likely to discharge automatically.** The task is under-specified and a text-art walk through the folding states meets it with only literal output, so every check is trivially discharged and no new surface is needed.

Position 34 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The program embeds the five fold states (2x4 flat start, 2x2 thick square, closed loop, shifted loop, 3x3 with missing corner) as String literal text-art frames and prints each with Silver_IO.Put_Line in order. There are no loops, inputs or computed values, so control flow is a straight statement sequence. About 40 lines.

## External effects

- **console output** (allowed): Prints each of the five folding states as a title line followed by a text-art grid of the eight panels.

Assessed on 2026-10-15 against page revision 415559 of the [task](https://rosettacode.org/wiki/Rubik's_Magic_Simulation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
