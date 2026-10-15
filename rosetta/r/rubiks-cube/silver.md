# Rubik's cube

**Candidate: proofs likely to discharge automatically.** The task only asks for a drawing of a Rubik's cube, and a text-art picture is made of constant Put_Line calls that Silver already supports, so no run-time check or loop exists to prove.

Position 23 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The program is a Main procedure that prints a fixed text-art picture of a solved 3x3x3 cube, with the top, front and right faces drawn as 3x3 grids of colour letters (W, G, R). It uses only String literals and Silver_IO.Put_Line, with one Put_Line per row, so there are no loops, arithmetic or guards. About 22 lines.

## External effects

- **console output** (allowed): The text-art cube is written to standard output line by line.

Assessed on 2026-10-15 against page revision 414783 of the [task](https://rosettacode.org/wiki/Rubik's_cube) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
