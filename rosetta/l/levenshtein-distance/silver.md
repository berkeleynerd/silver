# Levenshtein distance

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static ranges and every cell value is bounded by a ranged subtype, so index and overflow checks follow from types and guards without invariants.

Position 651 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Use a procedure Main with a fixed-size 2D array (0..16, 0..16) of a ranged subtype for the DP matrix, computing the distance for each embedded string pair with nested for loops over 1..Length of constant strings and if/elsif minimum selection. Print the results with Silver_IO.Put_Line after converting the small integer with 'Image. Strings are String constants, so lengths are static and every index is bounded by the loop range. About 45 lines.

## Proof obligations to watch

- **index**: Matrix indices I-1 and J-1 are safe because for loops run over 1..Length of constant strings inside a matrix declared 0..Max.
- **overflow**: Each cell is a ranged subtype wider than the longest string, and a loop-carried cell read after the first iteration is only known by type, so a guard before the +1 keeps the cell within range while still computing the true minimum.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, 'Image of scalars and for loops.

## External effects

- **console output** (allowed): Prints the two distances for the example pairs.

Assessed on 2026-10-15 against page revision 415116 of the [task](https://rosettacode.org/wiki/Levenshtein_distance) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
