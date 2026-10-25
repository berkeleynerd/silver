# N-queens minimum and knights and bishops

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged subtypes, fixed 10x10 bounds and guards before each stack or board access, and all unbounded looping sits in procedures, so no annotation should be needed, though several loop-carried counters and indices demand careful guard placement.

Position 1190 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Boards are fixed 10x10 Boolean and small-integer arrays with N a ranged subtype 1..10, and a piece-kind enumeration selects the attack rule in a pure function that tests attack with range-guarded coordinate differences. An iterative depth-first search in a procedure keeps an explicit stack of placed squares in a bounded array, iterates the target piece count upward, and places on squares that are non-attacked and attack the first undominated square, undoing placements by popping the stack. Results are printed with Image-based line building and the N=8 Queens and Bishops layouts are rendered as text rows. About 170 lines.

## Proof obligations to watch

- **index**: The explicit backtracking stack depth and the board row/column coordinates are loop-carried, so each use is preceded by a guard (depth below capacity, coordinates within 1..N) or has a ranged subtype that makes it safe.
- **overflow**: Per-square attack counters and the piece count are incremented in while loops, so they use ranged subtypes capped by a guard before each increment (at most 100 pieces, at most 100 attackers per square).
- **termination**: The search runs in procedures with while loops, which get no termination check, while the helper functions use only for loops over fixed ranges.
- **other**: Knights on 10x10 need an exhaustive search of roughly 16 pieces that is slow at run time, which is a performance matter and not a proof obligation.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the minimum counts for N=1 to 10 per piece kind and the N=8 Queens and Bishops boards.

Assessed on 2026-10-15 against page revision 387024 of the [task](https://rosettacode.org/wiki/N-queens_minimum_and_knights_and_bishops) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
