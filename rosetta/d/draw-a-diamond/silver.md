# Draw a diamond

**Candidate: proofs likely to discharge automatically.** The task only asks for a diamond drawing in the language, text art satisfies it, and a sequence of Put_Line calls on literals needs nothing beyond today's Silver and generates no run-time checks.

Position 23 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The program is a parameterless Main procedure that prints a fixed text-art picture of a faceted diamond (a wide top, facet lines, and an inverted-pyramid tip) as a sequence of Silver_IO.Put_Line calls on String literals. There are no variables, loops, inputs or arithmetic, so control flow is a straight statement sequence. About 16 lines.

## External effects

- **console output** (allowed): The diamond is printed as text art with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414804 of the [task](https://rosettacode.org/wiki/Draw_a_diamond) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
