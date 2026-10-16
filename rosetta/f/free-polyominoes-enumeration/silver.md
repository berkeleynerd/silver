# Free polyominoes enumeration

**Candidate: proofs plausibly discharge automatically.** Everything is bounded for-loop work over fixed-size Boolean grids in procedures, so the index and range checks follow from subtype ranges and local guards, though the many loop-carried shift and bounding-box values make the program shape delicate. No recursion, heap or annotations are needed, so it is plausible rather than certain.

Position 757 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Represent each polyomino as a fixed-size Boolean grid (record with a cell count) in a bounded array of canonical forms; build rank k from rank k-1 by adding each empty edge-adjacent cell in a padded grid, shifting to the origin, generating the eight rotations and reflections by index arithmetic, and keeping the lexicographically smallest grid as the canonical form. Duplicates are rejected by a linear for-loop comparison against the stored list, and a capacity guard stops insertion when full. Output prints the rank-5 shapes as '#' text art line by line, followed by the count sequence for small ranks. About 260 lines.

## Proof obligations to watch

- **index**: Neighbor cells and 8-way symmetry transforms compute coordinates like x-1 or N-1-x, so each is guarded by an explicit bounds test or confined to a padded grid whose subtype range makes the index provably valid.
- **range**: Bounding-box minima and shift offsets are loop-carried values that need guards or subtype ranges because there is no invariant to carry their bounds.
- **overflow**: The result counters and list indices are bounded by a declared capacity (for example 1285 for rank 9) and a guard rejects insertion when the list is full, which is a visible outcome.
- **termination**: All loops live in procedures or are for loops, so no function needs a variant.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The program prints each free polyomino of the chosen rank as ASCII art plus the count sequence.

Assessed on 2026-10-15 against page revision 414224 of the [task](https://rosettacode.org/wiki/Free_polyominoes_enumeration) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
