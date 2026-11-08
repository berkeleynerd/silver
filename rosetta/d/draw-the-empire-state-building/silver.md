# Draw the Empire State Building

**Candidate: proofs likely to discharge automatically.** The task only asks for a picture, which text art satisfies, and a straight sequence of Put_Line calls on literals needs no proof beyond what Silver already discharges.

Position 70 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The program is a parameterless Main procedure that emits a fixed ASCII-art silhouette of the Empire State Building (spire, mast, stepped setbacks, window rows, base) as a sequence of Silver_IO.Put_Line calls with String literals. There is no input, no loop and no arithmetic, and the optional rotation extra credit is omitted. About 45 lines.

## External effects

- **console output** (allowed): The program prints the text-art building to standard output line by line.

Assessed on 2026-10-15 against page revision 415500 of the [task](https://rosettacode.org/wiki/Draw_the_Empire_State_Building) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
