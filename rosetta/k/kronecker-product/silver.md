# Kronecker product

**Candidate: proofs plausibly discharge automatically.** All loops are for loops over array ranges with ranged element types, so only the nonlinear block-index arithmetic and the bounded row-text building need guards, and neither requires an annotation.

Position 1010 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Matrices are two-dimensional arrays of a ranged element subtype, with the two sample inputs embedded as constants and the result sized as the product of the dimensions. A Kronecker procedure loops with for loops over the rows and columns of both inputs and writes each product to the computed output index, guarded by a dimension-equality check; a print procedure builds each row in a bounded String using 'Image and emits it with Put_Line, with a blank line between samples. About 95 lines.

## Proof obligations to watch

- **index**: Result indices (I-A'First)*Rows(B)+(K-B'First) are nonlinear, so the procedure first guards that the output dimensions equal the products of the input dimensions, and otherwise takes a visible reject path.
- **overflow**: Elements are a declared subtype 0..1000 so each product is at most 10**6 and the products of dimensions stay within the small bounded matrix sizes, discharging by types.
- **length**: Each output row is built in a fixed-capacity String buffer whose size covers 12 right-aligned columns of at most 7 characters, with the fill position guarded before each append.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, unconstrained arrays, 'Image of scalars, string building, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Both result matrices are printed row by row to standard output.

Assessed on 2026-10-15 against page revision 414296 of the [task](https://rosettacode.org/wiki/Kronecker_product) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
