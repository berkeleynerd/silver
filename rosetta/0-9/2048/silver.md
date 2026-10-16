# 2048

**Candidate: proofs plausibly discharge automatically.** All indexes are range-typed constants 1..4 and merges use for loops over fixed arrays, so checks follow from types and guards, but capped tile and score arithmetic and the generator's modular arithmetic need careful range guards, hence plausible rather than likely.

Position 1554 in the [progression](../../progression.md#stage-33), in stage 33.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The 4x4 board is a two-dimensional array of tiles with a capped range type, and a single slide-and-merge procedure works on one line copied into a 4-element buffer, with a mapping function selecting rows or columns and forward or reverse order for each direction so merges follow the move direction and each tile merges once per move. Each turn reads a direction line from stdin, applies the move to a copy, rejects the move visibly if the board is unchanged, reports a win if a 2048 tile exists, otherwise spawns a 2 (or a 4 one time in ten) at a k-th empty cell chosen by a fixed-seed linear congruential generator, then checks for loss by scanning for empty cells and equal neighbours. The board is rendered with Put and 'Image into fixed-width cell text. About 230 lines.

## Proof obligations to watch

- **overflow**: Tile doubling and score accumulation are loop-carried, so tile and score types carry documented caps (for example 2**30) and a guard before each addition ends the game with a visible limit message instead of changing results.
- **index**: Direction-dependent cell addressing is computed by a function over 1..4 range-typed line and position indexes, so every index stays inside the 4x4 bounds by type.
- **range**: The deterministic generator's multiplication and mod need a state type small enough that the product fits in 64 bits, and the empty-cell choice is reduced by mod with a guard that the empty count is positive.
- **termination**: The turn loop is a while loop in a procedure bounded by end of input, so no termination check applies, and merging uses only for loops over fixed ranges.
- **initialization**: The board, score and generator state are fully initialised by aggregates before the first turn.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions, Put without a newline, standard input and membership tests.

## External effects

- **console output** (allowed): Prints the board, score and the invalid-move, win and lose messages.
- **standard input** (allowed): Reads one line per turn holding the chosen direction, with end of input and unrecognised input having specified outcomes.

Assessed on 2026-10-15 against page revision 414921 of the [task](https://rosettacode.org/wiki/2048) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
