# Wireworld

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds, enumeration cases and explicit edge guards, with only the neighbour counter and line-reading loop needing careful shape, so proofs should likely discharge with no annotations. The main new work is Silver's file input, 2D arrays and enumerations.

Position 1327 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

The program reads the first argument as a file name, then reads lines into a fixed 32x64 grid of an enumeration type (Empty, Head, Tail, Conductor), mapping the characters ' ', 'H', 't' and '.' and rejecting any other character, an over-long line or too many rows. It then runs a fixed number of generations, each computing a second grid from the first with a for loop over all cells and a guarded 3x3 neighbour scan, and prints each frame as text lines with a separator. All I/O and the while-based line reading are in procedures. About 110 lines.

## Proof obligations to watch

- **index**: Neighbour lookups at the grid edges are each guarded by explicit row and column bounds tests, so the index checks discharge from the guards.
- **overflow**: The neighbour-head counter is a loop-carried value, so it is incremented only under a guard (Count < 8) or kept in a wide range, since no invariant is allowed.
- **length**: File lines longer than the fixed grid width, or files with more rows than the grid holds, are rejected with a specified outcome rather than truncated.
- **initialization**: Both grids are fully initialized to empty cells before reading, and the next-generation grid is filled completely in each step.
- **termination**: The file-reading while loop and any generation loop live in procedures, which get no termination check, and the generation count is a fixed for loop.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, enumerations, multidimensional arrays, arrays, string indexing, case statements, for loops, while loops, procedures, file input, Put without a newline, 'Image of scalars and text parsing.

## External effects

- **files** (allowed): The task reads the Wireworld description from a named file.
- **console output** (allowed): Each generation is printed as a text frame, which satisfies the animation.
- **arguments** (allowed): The input file name comes from the first command-line argument.

Assessed on 2026-10-15 against page revision 414994 of the [task](https://rosettacode.org/wiki/Wireworld) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
