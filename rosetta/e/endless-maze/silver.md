# Endless maze

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic with an explicit guard before each move, and the interactive while loop sits in a procedure, so no annotation is needed; the plausible rating reflects the modular hash, the grid-edge guards and the stdin line reading.

Position 1304 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The maze is a bounded grid (for example 0..255 on each axis, a documented limit that stands in for 'endless') in which each wall between two adjacent cells is open or closed according to a deterministic modular-type hash of the lower cell's coordinates, an axis and a fixed seed, so both neighbours agree without storing anything. A procedure holds the position and facing direction (a 0..3 subtype) and loops: it prints the open directions as ahead, right, back and left, reads a line, maps it to a relative direction or quit, and moves only if the wall is open and the target is inside the grid, otherwise printing 'No path.'. Unknown commands print 'Invalid input.' and end of input exits like quit. About 95 lines.

## Proof obligations to watch

- **overflow**: The cell hash is computed in a modular type so wraparound is by definition, and the coordinates are subtypes bounded to a fixed grid with a guard before each step that prints 'No path.' at the grid edge.
- **range**: Moving a coordinate by one is guarded by an explicit comparison against the grid limit just before the update, so the subtype range check discharges.
- **termination**: The interactive loop lives in a procedure (no termination check) and ends on 'quit' or end of input.
- **length**: Input lines longer than the fixed buffer are treated as invalid input and compared only after a length guard, so string comparisons stay within bounds.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, modular types, Boolean objects, case statements, while loops, procedures, functions, standard input and Put without a newline.

## External effects

- **standard input** (allowed): The player's direction commands (ahead, right, back, left, quit) are read as lines from standard input.
- **console output** (allowed): Each cell prints its open directions relative to the facing direction, plus 'No path.' and 'Invalid input.' messages.

Assessed on 2026-10-15 against page revision 414181 of the [task](https://rosettacode.org/wiki/Endless_maze) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
