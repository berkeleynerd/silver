# Associative array/Merging

**Candidate: proofs likely to discharge automatically.** Every index is a for-loop index over a bounded range or a guarded Count+1, and all loops are for loops in procedures, so no invariant or variant is needed.

Position 100 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

Tables are fixed-capacity (6) arrays of fixed-width padded key and value Strings plus a Count subtype 0..6, with the example data embedded as constants and values kept as text. A Merge procedure copies base into a fresh result, then for each update entry scans the result with a for loop over 1..Count comparing keys by equality, replacing the value on a match or appending after a capacity guard, so inputs are never mutated. Each table is printed by a for loop with Put_Line of key and value concatenations. About 80 lines.

## Proof obligations to watch

- **index**: Appending a new key writes slot Count+1 only inside an if Count < Capacity guard, and the else branch has a specified outcome of rejecting the merge as over capacity.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, for loops and procedures.

## External effects

- **console output** (allowed): Prints the base, update and merged tables with Put_Line.

Assessed on 2026-10-15 against page revision 415339 of the [task](https://rosettacode.org/wiki/Associative_array/Merging) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
