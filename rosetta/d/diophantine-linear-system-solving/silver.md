# Diophantine linear system solving

**Candidate: proofs plausibly discharge automatically.** All checks are range or guard checks on indices and arithmetic, but the loop-carried matrix entries have no invariants, so each nonlinear operation needs an explicit magnitude guard with a visible rejection, which makes discharge plausible rather than likely.

Position 760 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Use the integral LLLHnf variant with Long_Long_Integer matrices of fixed maximum size (about 10 by 12) for A, the Gram lambda coefficients and the sub-determinants d, with the test systems embedded as constant data and processed by a procedure per system. A while loop in a procedure runs the swap, reduce and size-reduction steps, every arithmetic step goes through guarded checked-multiply, checked-subtract and floor-division helpers that reject on overflow, and results are printed with Put_Line using integer 'Image into bounded line buffers. About 380 lines.

## Proof obligations to watch

- **overflow**: Every product and difference on the loop-carried matrix, Gram determinant and lambda entries is nonlinear and unbounded by types, so each is routed through a guarded helper that checks operand magnitudes beforehand and sets a visible 'coefficient too large' rejection flag, with the 64-bit limit documented as a resource limit.
- **division**: Floor division by a pivot or d(t) is guarded by a non-zero test and by excluding the First/-1 case just before the division.
- **index**: Matrix indices such as k-1, t-1 and the d(-1) offset are guarded by loop bounds and explicit tests against fixed maximum dimensions.
- **termination**: The LLL main loop is a while loop with no variant, which is acceptable only because it lives in a procedure and the rejection flag plus a documented iteration cap give a specified outcome.
- **range**: Integer replacement of the floating-point Gram-Schmidt rounding must keep every intermediate in range, which is why the integral LLL variant is used and overflow is rejected rather than approximated.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The P and Hnf matrices, solution and inconsistent markers, null-space lengths squared and loop counts are printed as text.

Assessed on 2026-10-15 against page revision 399488 of the [task](https://rosettacode.org/wiki/Diophantine_linear_system_solving) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
