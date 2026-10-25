# Percolation/Bond percolation

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed grid bounds, guarded neighbour indexes and ranged integer types, and the only unbounded-looking loop is a while loop in a procedure, so no annotation is needed. It is plausible rather than likely because of the nonlinear PRNG arithmetic and the several loop-carried counters that need careful typing.

Position 727 in the [progression](../../../progression.md#stage-12), in stage 12.

## Approach

The program stores the vertical and horizontal walls of the 10x10 grid in two Boolean 2D arrays, filled from a deterministic linear congruential generator with a threshold of p in tenths (0..10) compared against a value in 0..9, so no floating point is needed. Fluid is spread by a procedure that seeds the top row and sweeps the grid repeatedly, using a Changed flag and guarded neighbour checks (left, right, up, down) until a sweep adds no cell, then reports whether any bottom cell with an open bottom wall was reached. The main procedure loops p over 0..10 for 100 trials each and prints "p = 0.x : 0.yy" lines built from the integer count in a bounded string buffer. About 130 lines.

## Proof obligations to watch

- **overflow**: The LCG multiply is nonlinear, but the state is a ranged subtype of 0..2**31-1 and the multiplier is a small constant, so the product fits in 64 bits and the provers can discharge it from the types alone.
- **index**: Neighbour cells are only touched after explicit guards on row and column bounds (for example Col > 0 before Col - 1), so each index check follows from the guard just before it.
- **termination**: The flood-fill sweeps repeat in a while loop until nothing changes, but this lives in a procedure, which gets no termination check, and the number of sweeps is in fact bounded by the 100 cells.
- **range**: Counts and percentages are loop-carried, so they are typed as 0..100 and 0..10 subtypes with guards before increments to keep range checks provable.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the eleven rows of p versus estimated percolation fraction.

Assessed on 2026-10-15 against page revision 414389 of the [task](https://rosettacode.org/wiki/Percolation/Bond_percolation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
