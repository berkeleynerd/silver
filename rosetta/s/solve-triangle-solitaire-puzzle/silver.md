# Solve triangle solitaire puzzle

**Candidate: proofs plausibly discharge automatically.** Every check is an index or counter bounded by declared subtypes and guards, there is no function-level loop or recursion, and the search runs in a procedure, so no annotation is needed. The risk is only that the loop-carried stack depth and cursor need careful guard placement.

Position 724 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The program stores the board as a 15-element Boolean array and the 36 legal jumps (from, over, to) as constant integer arrays of peg numbers, with the empty start hole embedded as a constant. A single procedure runs an iterative depth-first search with an explicit stack of per-depth jump cursors and undo records (no recursion), advancing until 13 jumps leave one peg or the stack empties, then prints the starting board and the board after each jump as text rows built in a fixed-length String. Every array index is a ranged subtype guarded just before use, and the no-solution case prints an explicit message. About 110 lines.

## Proof obligations to watch

- **index**: Peg numbers, the 36-entry jump table and the explicit search stack are indexed through subtypes 1..15, 1..36 and 0..13, with a guard on the depth before every stack access.
- **overflow**: The depth and next-candidate counters are loop-carried in a while loop, so they get ranged subtypes and are tested against their limits just before each increment.
- **termination**: The backtracking search is a while loop inside a procedure, which gets no termination check, and the search space is finite anyway.
- **other**: Failure to find a solution (for example if a different empty starting hole were used) needs a specified printed outcome, which the fixed-start design reports with an explicit no-solution message.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops and procedures.

## External effects

- **console output** (allowed): Prints the starting board and each of the 13 jump boards or moves of the found solution.

Assessed on 2026-10-15 against page revision 401710 of the [task](https://rosettacode.org/wiki/Solve_triangle_solitaire_puzzle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
