# Spiral matrix

**Candidate: proofs likely to discharge automatically.** Every cell is computed independently from its indices with small ranged arithmetic and explicit side guards inside for loops over the array's own range, so checks follow from types and guards without loop invariants.

Position 883 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Declare a constant N = 5, a 2-D array of a ranged subtype 0..N*N-1 indexed 0..N-1, and fill it with nested for loops that compute each cell directly from its ring (the minimum distance to an edge) and which side of the ring it lies on, so no loop-carried counter exists. Then print each row with nested for loops, formatting each value into a fixed-width text field using a small bounded buffer with Put, ending each row with a line terminator. About 45 lines.

## Proof obligations to watch

- **overflow**: The per-cell ring and offset arithmetic is nonlinear (ring times side length) but all operands come from small ranged subtypes for N=5, so bounds follow from the types.
- **range**: Each computed value must be shown to lie in 0..24 for the array element subtype, which the prover must derive from case-wise guards on ring and position and may need the ranged intermediate subtypes to make easy.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, 'Image of scalars, string building, Put without a newline, procedures and conditional expressions.

## External effects

- **console output** (allowed): The 5x5 spiral is printed to standard output as five rows of aligned numbers.

Assessed on 2026-10-15 against page revision 414512 of the [task](https://rosettacode.org/wiki/Spiral_matrix) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
