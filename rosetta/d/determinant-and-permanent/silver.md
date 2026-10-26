# Determinant and permanent

**Candidate: proofs plausibly discharge automatically.** The Leibniz-style sum over permutations needs no recursion or annotations, and bounded entries plus guards before each loop-carried addition and index use should let overflow and index checks discharge, though the iterative permutation generator makes the shape delicate.

Position 922 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Matrices are constrained 2D Integer arrays in a fixed maximum size (5x5) with ranged entries and an order n, and the three example matrices are embedded as aggregates. A procedure enumerates permutations iteratively (next-permutation or Heap's algorithm with a bounded counter), tracking sign by swap parity and accumulating the product sum for both determinant and permanent with a guarded overflow check. Main loops over the examples and prints the results with Put_Line using 'Image. About 110 lines.

## Proof obligations to watch

- **overflow**: Row-product and the sum over up to 120 permutations are loop-carried, so entries are a small ranged subtype, products use a 64-bit type, and the accumulator gets an explicit guard before each addition that rejects out-of-bound sums.
- **index**: Permutation indices are updated in while loops without invariants, so they are held in ranged subtypes with a guard just before each array access.
- **termination**: Permutation enumeration (an iterative next-permutation procedure) uses while loops, so it lives in a procedure and is bounded by an explicit step counter instead of recursion or Laplace expansion.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, while loops, procedures, functions, 'Image of scalars, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the determinant and permanent of the embedded 2x2, 4x4 and 5x5 example matrices.

Assessed on 2026-10-15 against page revision 414153 of the [task](https://rosettacode.org/wiki/Determinant_and_permanent) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
