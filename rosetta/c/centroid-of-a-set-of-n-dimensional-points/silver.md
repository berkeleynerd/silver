# Centroid of a set of N-dimensional points

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded subtypes, array index ranges and guards before the sum and division, though the loop-carried sum and the decimal formatting need careful shape. Scaled-integer arithmetic avoids floating point and nothing requires an annotation.

Position 732 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Coordinates are stored as integers scaled by 1000 in a bounded subtype inside a constrained two-dimensional array (max points by max dimensions) with separate count and dimension values. A procedure sums each dimension with a for loop into a wide accumulator guarded before each add, rejects a zero point count, divides by the count, and then formats each value as decimal text in a bounded buffer and prints each embedded test set with its centroid. The 3D plot stretch is skipped as optional. About 150 lines.

## Proof obligations to watch

- **overflow**: The per-dimension sum is a loop-carried accumulator, so it is held in a wide Long_Long_Integer with coordinates in a bounded subtype and a guard just before each addition that rejects out-of-bound running sums.
- **division**: The division by the point count is guarded by an explicit check that the count is at least 1 before dividing, with a visible rejection otherwise.
- **index**: Loops run over the arrays' own index ranges up to the declared maximum point and dimension counts, with the actual count and dimension parameters checked against those maxima before use.
- **length**: Text for numbers is built in a fixed-capacity buffer sized for the worst-case digits, signs, point and separators, with a guard before each append.
- **range**: Fractional output (e.g. 3.1, -1.475) uses thousandths-scaled integers split into whole and fraction parts with mod and rem on bounded values, so conversions stay within declared subtypes.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, 'Image of scalars, string building, Put without a newline and characters.

## External effects

- **console output** (allowed): Prints each point set and its centroid to standard output.

Assessed on 2026-10-15 against page revision 414792 of the [task](https://rosettacode.org/wiki/Centroid_of_a_set_of_N-dimensional_points) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
