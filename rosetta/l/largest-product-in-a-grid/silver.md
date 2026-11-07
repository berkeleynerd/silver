# Largest product in a grid

**Candidate: proofs likely to discharge automatically.** Every index is a for-loop variable over a fixed subtype range with offsets of at most 3 inside the 20-wide array, and the product is bounded by the cell subtype, so all checks follow from types and no loop invariant is needed.

Position 654 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The 20x20 grid is a constant two-dimensional array of a Cell subtype 0..99 with the task data embedded as an aggregate. Two nested for-loop passes (down over rows 1..17, across over columns 1..17) compute the product of four adjacent cells, keeping a running maximum and its row, column and direction when a larger product is found. The result is printed with Put_Line using a concatenation of Integer'Image values. About 55 lines.

## Proof obligations to watch

- **overflow**: Each product of four cells is bounded by 99^4 (about 98 million) because the cell subtype is 0..99, which fits in Integer and is routine for the provers given the declared ranges.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, multidimensional arrays, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the largest product, its row and column, and its direction.

Assessed on 2026-10-15 against page revision 390287 of the [task](https://rosettacode.org/wiki/Largest_product_in_a_grid) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
