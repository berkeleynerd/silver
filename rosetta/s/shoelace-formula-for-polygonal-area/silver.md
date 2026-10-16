# Shoelace formula for polygonal area

**Candidate: proofs likely to discharge automatically.** All data is embedded and bounded by declared ranges, so every overflow and index check follows from types and a fixed small loop with no annotation; floating point is avoided by working in integers (expected output 30.0).

Position 584 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Store the five embedded vertices as a constant array of records with coordinates in a ranged subtype 0..1000, compute twice the signed area as the difference of the two cross-product sums using a for loop over the fixed index range with wraparound to the first index, take abs, then print the half (whole part plus ".0" or ".5") built into a bounded string. There is no input, so no validation is needed and all indexes come from the array's own range. About 35 lines.

## Proof obligations to watch

- **overflow**: The two sums accumulate in a loop, but coordinates in a small declared range (0..1000) and a fixed 5-vertex array keep every sum far below the Integer limit, and the loop can be written as one explicit expression of 10 products if the prover does not unroll it.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, records, for loops, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the computed area as a line of text.

Assessed on 2026-10-15 against page revision 414466 of the [task](https://rosettacode.org/wiki/Shoelace_formula_for_polygonal_area) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
