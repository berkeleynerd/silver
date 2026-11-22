# Dominoes

**Candidate: proofs plausibly discharge automatically.** All indexes are bounded by ranged subtypes and explicit guards and the search is a while loop in a procedure, so no annotation is needed, but the several loop-carried positions and the explicit stack make careful program shape necessary.

Position 742 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the two 7 by 8 tableaux as constant two-dimensional arrays of a 0..6 subtype, and solve each with an iterative backtracking procedure that scans for the first empty cell, tries a horizontal then a vertical placement guarded by bounds, emptiness and an unused 7 by 7 value-pair table, and keeps per-depth choice state in a fixed 28-entry stack. The first complete layout is copied into a character grid and printed row by row with plus signs marking pairs, followed by the layout count; the extra-credit counting is omitted as optional. About 170 lines.

## Proof obligations to watch

- **index**: The explicit backtracking stack depth and the row and column positions are loop-carried, so each is a ranged subtype and every access is preceded by a guard on the neighbour cell (column below 7, row below 6) and on the depth limit.
- **termination**: The exhaustive search runs as a while loop inside a procedure, which gets no termination check, and the recursion is replaced by an explicit per-depth choice stack.
- **overflow**: The layout counter is a ranged subtype and is only incremented under a guard against its limit, with the limit exceeding the 2025 layouts the task data produces.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string building, 'Image of scalars, for loops, while loops and procedures.

## External effects

- **console output** (allowed): Prints each tableau with the located dominoes marked and the number of layouts found.

Assessed on 2026-10-15 against page revision 414164 of the [task](https://rosettacode.org/wiki/Dominoes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
