# Vector products

**Candidate: proofs likely to discharge automatically.** The task is fixed-size integer arithmetic on 3-vectors with embedded data, so every overflow and index check follows from declared ranges and no loop carries an unbounded value. Using integers (the task's values are integral) avoids floating-point proof difficulty.

Position 359 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Vectors are constrained 3-element arrays of a ranged integer component subtype, with the task's integer example data embedded as constants; dot, cross, scalar triple and vector triple products are straight-line functions using wider range subtypes for intermediate results. A small output procedure prints each vector or scalar via 'Image into bounded text with Put, and all indexing uses the fixed 1..3 range so no guards are needed. About 70 lines.

## Proof obligations to watch

- **overflow**: Products and sums are discharged by declaring components as a small range (-1000..1000) and results in a 64-bit-range subtype, so the worst-case triple-product magnitude (about 6e9) is provably in range with no loop-carried values.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, functions, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the dot product, cross product, scalar triple product and vector triple product results as text lines.

Assessed on 2026-10-15 against page revision 413117 of the [task](https://rosettacode.org/wiki/Vector_products) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
