# Maze solving

**Candidate: proofs plausibly discharge automatically.** Everything reduces to fixed-size array indexing, ranged distance labels and for loops with guards placed just before each neighbour access, so no annotation is needed, though loop-carried position and distance values need careful subtype ranges and guards.

Position 717 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The maze is an embedded fixed-size constant grid of walls and open cells, with a distance array of ranged naturals initialized to unreached. Bounded for-loop relaxation passes label each open cell with its distance from the start, using bounds-guarded neighbour checks (no recursion or queue); then a bounded for-loop traceback from the finish steps to any neighbour whose label is one less, marking path cells with '*' in a copy of the maze, and the program prints the result, or a no-path message if the finish stayed unreached. About 95 lines.

## Proof obligations to watch

- **index**: Neighbour lookups use a guard on the row and column bounds just before each array access, so they discharge.
- **range**: The loop-carried path position has a subtype type range, and each step is guarded by an in-bounds test before it is assigned.
- **overflow**: Distance labels are assigned from for-loop indexes whose range sits inside the label subtype, and the traceback subtracts 1 only after a guard that the label is above 0.
- **termination**: Every iteration is a bounded for loop (a relaxation pass count equal to the cell count, then a traceback of the same bound) so no while loop or recursion is needed.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, for loops and procedures.

## External effects

- **console output** (allowed): Prints the embedded maze and then the maze with the shortest path marked, or a no-path message, via Put_Line.

Assessed on 2026-10-15 against page revision 414336 of the [task](https://rosettacode.org/wiki/Maze_solving) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
