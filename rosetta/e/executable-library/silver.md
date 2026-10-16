# Executable library

**Candidate: proofs plausibly discharge automatically.** All arithmetic and index checks follow from type ranges plus a couple of visible guards placed in the loop body, and nothing needs an annotation, but the while loop must stay in a procedure and the guards must be placed carefully.

Position 1472 in the [progression](../../progression.md#stage-29), in stage 29.

## Approach

A package Hailstones with a procedure Compute(N, Seq, Len, Ok) fills a fixed 512-element Long_Long_Integer array using a while loop, guarding the length against capacity and N against a 2**60 bound before 3*N+1. Main embeds the library demonstrations: it shows Compute(27), loops over 1..99,999 tracking the longest length, then tallies lengths in a 512-element count array and scans for the most frequent length, printing results with 'Image concatenation via Put_Line. The library/CLI duality is satisfied by one package plus the main procedure in the same source, and the second executable is folded into the same program. About 110 lines.

## Proof obligations to watch

- **overflow**: The 3*N+1 step inside a while loop has only the type range for N, so an explicit guard N <= 2**60 before the step (rejecting otherwise) is needed, and the true maximum of about 1.57 billion is far below it.
- **index**: Storing the sequence and counting lengths needs a guard that the length is below the array capacity (512) before each store, else the run is rejected visibly, and this is sound since the real maximum is 351.
- **termination**: The Collatz while loop must live in a procedure (no termination check there), so hailstone is written as a procedure with an out length rather than a function.
- **overflow**: Counting 100,000 starts in a count array uses a range-bounded element type so increments (at most 100,000) cannot overflow after a cap guard.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, packages, 'Image of scalars, string building, Boolean objects and conditional expressions.

## External effects

- **console output** (allowed): Prints the 27 sequence summary, the longest-sequence result below 100,000, and the most frequent length.

Assessed on 2026-10-15 against page revision 414191 of the [task](https://rosettacode.org/wiki/Executable_library) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
