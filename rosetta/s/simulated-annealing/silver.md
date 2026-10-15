# Simulated annealing

**Candidate: proofs plausibly discharge automatically.** Everything is bounded array and for-loop work with no recursion or annotations, but the floating-point exp, the million-iteration loop-carried energy and the formatting of scaled values need careful guards, so discharge is plausible rather than routine.

Position 1319 in the [progression](../../progression.md#stage-23), in stage 23.

## Approach

The path is an array 0..99 of cities with an inverse position array; a distance table indexed by (di,dj) holds scaled integer distances, and a neighbour list is built per city from guarded grid offsets. A deterministic LCG drives the initial Fisher-Yates shuffle and a for loop of 1,000,000 iterations in a procedure that swaps two neighbouring cities, computes the energy delta incrementally from the affected edges, and accepts by comparing a Float exp series with a random fraction. Progress lines and the final path are built in bounded String buffers using integer 'Image and fixed-point-style formatting of scaled integers. About 230 lines.

## Proof obligations to watch

- **overflow**: The running energy E and the path-length sum are loop-carried over a million iterations, so each addition needs a guard against a fixed bound (or a type range tight enough), which never triggers in practice but must be written as a visible outcome.
- **floating point**: The acceptance test needs exp(-dE/T); it is computed with a hand-written bounded series on Float after guarding dE/T to a small range (above it the move is rejected), since no elementary-function library is admitted, and the prover must bound each intermediate.
- **index**: Random picks go through a modular LCG reduced with mod into 1..99 or 1..neighbour count, and neighbour tables are indexed by guarded grid coordinates, which discharge from the mod ranges and explicit boundary guards.
- **overflow**: The 64-bit LCG step multiply needs a modulus and multiplier chosen so the product fits the integer type, or a modular type with wraparound.
- **termination**: All loops are for loops or live in procedures, and the swap uses a position array rather than a search while loop, so no variant is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, modular types, Boolean objects, arrays, multidimensional arrays, floating point, for loops, while loops, procedures, functions, string building, 'Image of scalars, Put without a newline and case statements.

## External effects

- **console output** (allowed): Prints eleven progress lines (k, T, E) and the final path with its length.

Assessed on 2026-10-15 against page revision 392711 of the [task](https://rosettacode.org/wiki/Simulated_annealing) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
