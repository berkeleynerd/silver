# 15 puzzle solver

**Candidate: proofs plausibly discharge automatically.** All indexing and arithmetic are bounded by ranged subtypes and explicit guards, and the recursive search is replaced by a procedure-only iterative stack so no variant is needed, but the many loop-carried values in the search need careful shaping to discharge.

Position 1197 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

Embed the puzzle as a flat 16-element array of a ranged tile subtype, with a stack of records (board, blank position, last move, cost) in a fixed-size array. A procedure runs iterative-deepening search, increasing a capped bound in an outer while loop and doing explicit-stack depth-first search in an inner while loop, pruning on a Manhattan-distance estimate and guarding each blank move by row and column tests. On success it prints the move count and direction letters, and if the bound or stack cap is reached it prints a no-solution message. About 170 lines.

## Proof obligations to watch

- **index**: Moving the blank is guarded by row/column bounds tests just before each neighbour index, and the flat 0..15 board and 0..Max_Depth stack are indexed through ranged subtypes, so checks follow from guards.
- **range**: The explicit stack depth is capped at a documented maximum (80, the longest possible optimal solution), and a push is guarded so overflow yields a visible no-solution outcome rather than a failed check.
- **overflow**: Cost, bound and iteration values are held in ranged subtypes (Manhattan cost at most 16*6, bound at most 80) with the bound-increase loop guarded by the cap, so loop-carried arithmetic is bounded by types.
- **termination**: Recursive IDA* is rewritten as an iterative depth-first search with an explicit stack inside a procedure using while loops, which get no termination check; helper functions are loop-free.
- **other**: Search work for the optimal 52-move puzzle is large but only affects run time, not proof, and the extra-credit puzzle is treated as optional.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, records, case statements, for loops, while loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the solved-in-N-moves line and the move letters, or a visible no-solution message.

Assessed on 2026-10-15 against page revision 414031 of the [task](https://rosettacode.org/wiki/15_puzzle_solver) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
