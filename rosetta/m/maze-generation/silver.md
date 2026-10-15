# Maze generation

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged subtypes, loop bounds and boundary or capacity guards placed right before each use, and the recursion becomes a procedure-level while loop with an explicit stack. It is plausible rather than likely because the stack pointer and current cell are loop-carried values needing careful guards, and the 2D wall updates need index reasoning.

Position 828 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Fixed-size grid (for example 8 by 11) of cells with wall flags and a visited flag in constant-bound 2D Boolean arrays, plus an explicit stack array of cell coordinates replacing recursion. A deterministic LCG picks the start cell and a random order among unvisited in-bounds neighbors, removing walls and pushing, popping when none remain. Output prints the walls as '+---+' text art rows using fixed-length String buffers filled by index and Put_Line. About 110 lines.

## Proof obligations to watch

- **index**: The explicit DFS stack pointer is loop-carried, so each push is guarded by a check against the stack capacity (and each pop by sp > 0) with a visible 'generation aborted' outcome, though it can never fire since depth is at most the cell count.
- **index**: Neighbor row and column computations are guarded by boundary comparisons just before each step, and loop-carried current row and column are ranged subtypes so their type ranges bound them.
- **overflow**: The LCG seed is kept in a bounded integer range via mod after a multiply whose operands are small, so the product cannot overflow.
- **termination**: The DFS runs as a while loop inside a procedure (no termination check) and recursion is replaced by an explicit stack, so no variant is needed.
- **length**: Each output line is built in a fixed-length buffer sized 4*Width+1 and filled by index in for loops, so slice and assignment lengths are static.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, case statements, for loops, while loops and procedures.

## External effects

- **console output** (allowed): The generated maze is printed as text art lines.

Assessed on 2026-10-15 against page revision 414969 of the [task](https://rosettacode.org/wiki/Maze_generation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
