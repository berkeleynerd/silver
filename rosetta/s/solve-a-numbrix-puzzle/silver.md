# Solve a Numbrix puzzle

**Candidate: proofs plausibly discharge automatically.** Every check follows from small bounded subtypes and bounds guards before each array access, with no recursion needed because the backtracking uses an explicit stack in a procedure, but the many loop-carried indices and counters need careful guard placement.

Position 746 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the two puzzles as constant 9x9 integer arrays, copy each into a working grid, and find the start cell holding 1 and the largest clue. A procedure runs iterative backtracking with an explicit fixed-size stack of cell positions and next-direction counters in a while loop, trying the four neighbours in bounds, accepting a cell only if it is empty or already holds the next number, and rejecting an empty cell when the next number is a given clue elsewhere. Finally a procedure prints each grid row using Integer'Image padded into a bounded string, or reports that no solution exists. About 170 lines.

## Proof obligations to watch

- **index**: Neighbour coordinates r+dr and c+dc are checked against the grid bounds (or a padded border of blocked cells) by an explicit guard just before each array access.
- **overflow**: The step counter, row, column and direction variables are declared with subtypes bounded by 81, 9 and 4, and increments are guarded by comparisons before the assignment.
- **range**: Loop-carried values in the iterative backtracking loop (current count, stack depth, direction) are known only by type range, so each increment and decrement needs a guard just before it, such as testing count < 81 or count > 1.
- **initialization**: The grid, the fixed-size position stack and the clue table are fully initialised by aggregates or loops before the search starts.
- **termination**: The backtracking while loop lives in a procedure so no termination check applies, although running time is exponential in the worst case and not proven.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline and integer division.

## External effects

- **console output** (allowed): The program prints the two solved 9x9 grids as rows of aligned numbers.

Assessed on 2026-10-15 against page revision 413919 of the [task](https://rosettacode.org/wiki/Solve_a_Numbrix_puzzle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
