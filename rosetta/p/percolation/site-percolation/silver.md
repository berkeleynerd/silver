# Percolation/Site percolation

**Candidate: proofs likely to discharge automatically.** Every check follows from array bounds, loop-bounded indices, a modular or range-bounded generator and edge guards, and the recursive flood fill of the existing solution is replaced by bounded iterative sweeps in a procedure so no variant is needed.

Position 1286 in the [progression](../../../progression.md#stage-23), in stage 23.

## Approach

The grid is a 15x15 Boolean array of filled cells, generated from a deterministic modular linear congruential generator by comparing each draw against p expressed as an integer tenth, with a second Boolean array marking wet cells. A procedure seeds row 0 from filled cells, then repeats a bounded number of sweeps over all cells, wetting any filled cell with a wet guarded neighbour, and the trial percolates if any row 14 cell is wet. The main loops run p from 0 to 10 and 100 trials each, then print the percent count with 'Image through Put and Put_Line, plus an optional text depiction of one grid. About 95 lines.

## Proof obligations to watch

- **overflow**: The pseudo-random generator multiplies a state by a constant, which is discharged by using a modular type (or a ranged state small enough that the product fits in 64 bits) with the result reduced by mod.
- **index**: Flood-fill neighbour accesses at row and column edges are each guarded by explicit bounds comparisons just before the array index, with row and column as loop-bounded subtypes.
- **termination**: Reachability is propagated by a bounded for loop of at most 225 sweeps inside a procedure, avoiding recursion and unbounded while loops.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, modular types, Boolean objects, characters, arrays, multidimensional arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the percolation fraction for each p from 0.0 to 1.0 and optionally a text depiction of one grid.

Assessed on 2026-10-15 against page revision 414392 of the [task](https://rosettacode.org/wiki/Percolation/Site_percolation) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
