# Sierpinski arrowhead curve

**Candidate: proofs plausibly discharge automatically.** Every check reduces to bounded array indexing and small ranged counters with guards just before each write, and all loops sit in procedures as for loops, so nothing needs an annotation, though the loop-carried turtle position and buffer lengths demand careful guard placement.

Position 1176 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Build the arrowhead L-system string for a fixed order of 4 by iterative rewriting (A to B-A-B, B to A+B+A) between two fixed-capacity Character arrays inside for loops in a procedure, then walk it with a turtle whose heading is 0..5 and whose position moves on a doubled-width character grid using a case statement on heading. Each plotted cell is guarded against the grid bounds, and the grid rows are then printed with Put_Line from fixed-length String rows, with no recursion. About 90 lines.

## Proof obligations to watch

- **index**: The turtle's grid position is loop-carried, so each step is guarded by an explicit bounds test before the cell is written, with an out-of-grid step ending the walk and printing a visible error line.
- **range**: The heading is a modular-style 0..5 value updated with explicit wrap-around if-tests, so it stays within its subtype without an invariant.
- **length**: L-system rewriting between two fixed-capacity character buffers guards each append against the capacity, reporting a visible error if the limit would be exceeded rather than truncating.
- **overflow**: The symbol count and position coordinates are held in ranged subtypes small enough that increments are guarded and cannot overflow.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, enumerations, arrays, multidimensional arrays, string indexing, string building, case statements, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The ASCII-art curve is printed line by line to standard output.

Assessed on 2026-10-15 against page revision 411681 of the [task](https://rosettacode.org/wiki/Sierpinski_arrowhead_curve) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
