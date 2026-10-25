# Simple turtle graphics

**Candidate: proofs plausibly discharge automatically.** Everything is bounded array drawing with explicit clipping guards and for loops, with no recursion or annotations needed, though loop-carried turtle coordinates and the scaling arithmetic need careful range guards. The existing interactive menu is not required, so embedded data and text-art output suffice.

Position 1188 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Represent the canvas as a fixed 2D Character array and the turtle as a record of x, y, heading (a 4-direction enumeration) and pen state, with procedures Forward, Turn, Pen_Up/Down. A House procedure draws a square and triangular roof using only axis-aligned moves and diagonal steps by 45-degree headings (or a staircase roof), and a Bar_Chart procedure scales an embedded array of non-negative values to the square and draws bars; each saves and restores turtle state, and the canvas is printed row by row with Put_Line. About 150 lines.

## Proof obligations to watch

- **index**: Turtle moves are drawn only after a guard confirms the new cell lies inside the fixed canvas, and out-of-range steps are visibly clipped (not drawn) so the pen still returns correctly.
- **overflow**: Heading steps use a small enumeration or table of direction offsets, and positions are range-subtyped and guarded, so loop-carried coordinates stay in bounds.
- **division**: Bar-chart scaling divides by the maximum value, which is guarded against zero by drawing nothing and giving a visible all-zero outcome.
- **overflow**: Scaled bar heights multiply value by square size, so values are range-limited by their type and an oversized value is rejected visibly.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, for loops, while loops, case statements, procedures, Put without a newline, string building and 'Image of scalars.

## External effects

- **console output** (allowed): The turtle's drawing is rendered as a text-art grid printed to standard output.

Assessed on 2026-10-15 against page revision 414470 of the [task](https://rosettacode.org/wiki/Simple_turtle_graphics) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
