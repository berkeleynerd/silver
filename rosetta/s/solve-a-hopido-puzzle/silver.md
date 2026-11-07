# Solve a Hopido puzzle

**Candidate: proofs plausibly discharge automatically.** Replacing the recursive search with an explicit bounded stack in a procedure keeps every index and arithmetic check derivable from ranged types or an adjacent guard, so no annotation is needed, though the stack-depth and position guards require careful shape.

Position 717 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The 7x6 puzzle is embedded as a constant mask in a 2D array of path numbers, and the search is an iterative depth-first backtracker in one procedure using explicit stack arrays of cell coordinates and next-move index over a constant table of the eight hop offsets. Neighbour coordinates are computed in a wide range and guarded against the grid bounds and visited state before each array access, and the stack depth is guarded against its capacity of 27. On success each row is built into a fixed 21-character buffer with two-digit numbers and printed with Put_Line, otherwise a no-solution line is printed. About 110 lines.

## Proof obligations to watch

- **index**: Neighbour coordinates are computed in a wider integer range and each is guarded against the 0..6 and 0..5 grid bounds immediately before the array access.
- **index**: The explicit backtracking stack depth is loop-carried, so every push is guarded by a depth less than the fixed capacity of 27 and every pop by depth greater than zero, with exhaustion giving a visible no-solution outcome.
- **overflow**: The step counter and path numbers are bounded by the declared ranges of their types, so increments are guarded to stay within them.
- **termination**: The search loop is a while loop inside a procedure, which GNATprove does not check for termination, and it is not claimed to be bounded.
- **length**: Each printed row is assembled in a fixed-length buffer with a computed write position guarded by the buffer size, and path numbers 1..27 are split into two digits with / and mod.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops and procedures.

## External effects

- **console output** (allowed): The solved grid (or a no-solution message) is printed line by line.

Assessed on 2026-10-15 against page revision 414480 of the [task](https://rosettacode.org/wiki/Solve_a_Hopido_puzzle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
