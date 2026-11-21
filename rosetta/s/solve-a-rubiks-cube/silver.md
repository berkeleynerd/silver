# Solve a Rubik's cube

**Candidate: proofs plausibly discharge automatically.** Every array index, orientation sum and stack push is bounded by declared subtypes or an explicit guard, and the search uses an explicit stack in procedures, so no annotation is needed. The outlook is only plausible because the large amount of loop-carried state and the explicit solvability validation demand careful program shape.

Position 1358 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The cube is a record of two fixed arrays (cubie permutation and orientation for 8 corners and 12 edges) parsed and validated from a 54-character facelet argument, with the 18 moves held as constant permutation tables. A Thistlethwaite-style four-phase solver runs a depth-bounded iterative-deepening search in procedures using an explicit move stack array instead of recursion, with each phase's goal test and allowed-move set fixed by constants. The program prints the move sequence, or rejects invalid or unsolvable input, or reports that the fixed depth limit was exhausted. About 450 lines.

## Proof obligations to watch

- **index**: Facelet, cubie and move-stack indexes are discharged by declaring them as ranged subtypes (0..53, 0..19, 1..MaxDepth) and guarding every stack push against the fixed depth limit.
- **overflow**: Cubie permutation and orientation sums stay within small subtypes, and the phase-table coordinates are bounded by their declared ranges so products cannot overflow.
- **termination**: The iterative-deepening search is written with while loops only inside procedures, which get no termination check, and with a fixed maximum depth per phase.
- **other**: Rejecting malformed, unsolvable or beyond-depth-limit cubes with a visible message is required, so the validity check (permutation, orientation sum and parity) must be explicit executable code rather than an assumption.
- **initialization**: All cube-state and table arrays are filled by full-range for loops or aggregates before use, which flow analysis accepts.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, string indexing, string building, case statements, for loops, while loops, procedures, functions, Put without a newline and exit status.

## External effects

- **arguments** (allowed): The cube state is read as a 54-character facelet string from the first command-line argument.
- **console output** (allowed): The move sequence (or a rejection message) is written to standard output.
- **exit status** (allowed): Rejected or unsolvable input is reported with a nonzero exit status.

Assessed on 2026-10-15 against page revision 414985 of the [task](https://rosettacode.org/wiki/Solve_a_Rubik's_cube) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
