# Multidimensional Newton-Raphson method

**Candidate: proofs plausibly discharge automatically.** All indexes and loops are statically bounded and divisions are guarded, but floating-point arithmetic through the Newton and elimination loops needs careful range guards to discharge overflow checks without invariants, so the outcome depends on program shape.

Position 1092 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Fixed-capacity 3x3 Float matrices and 3-element vectors with an active size, a procedure per system evaluating residuals and Jacobian directly (no function pointers), and a Newton procedure running a for loop of at most 12 iterations, solving J*delta=f by Gaussian elimination with partial pivoting and an epsilon guard on the pivot. Guesses are bounded by a constrained float subtype, and a magnitude check after each update reports divergence or singularity as a visible failure; results are printed with a hand-written fixed-point formatter. About 120 lines.

## Proof obligations to watch

- **floating point**: Newton updates, Jacobian entries and Gaussian elimination use Float arithmetic whose overflow checks need operands bounded by a constrained float subtype, with out-of-bound values reported as a visible failure.
- **division**: Pivot division requires a guard that the absolute pivot exceeds a small epsilon, with a singular-Jacobian outcome printed as a visible failure.
- **overflow**: Each updated guess is checked against a fixed magnitude bound before storing, since loop-carried float values are known only by their type range without an invariant.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, floating-point images, arrays, multidimensional arrays, for loops, procedures, functions, Boolean objects, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the approximate roots of the two embedded systems.

Assessed on 2026-10-15 against page revision 386476 of the [task](https://rosettacode.org/wiki/Multidimensional_Newton-Raphson_method) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
