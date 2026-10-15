# Jury stability criterion

**Candidate: proofs plausibly discharge automatically.** The algorithm is a fixed-shape loop nest over small bounded integer arrays with no recursion, so only the quadratic growth of the row entries and shrinking row indices need care, which range-limited subtypes and guards can cover without annotations. The floating-point coefficients of the original are replaced by bounded integers, a documented resource limit.

Position 733 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Use integer coefficients (a documented, bounded stand-in for real coefficients) for a few embedded polynomials of degree at most 4, stored in a constrained array with a degree subtype. Evaluate P(1) and (-1)^n P(-1) with a for loop, check |an| < a0, then build the Jury rows in a small two-dimensional array with for loops, comparing |first| > |last| at each reduction step, and print a verdict for each polynomial. Inputs outside the coefficient or degree limits are rejected with a visible message. About 130 lines.

## Proof obligations to watch

- **overflow**: Each Jury row squares the magnitude of the previous one, so coefficients are restricted to a small documented range (for example -20..20) and the table is held in a wide integer subtype so that products of loop-carried row entries cannot overflow.
- **range**: Row lengths shrink with the row index and the loop-carried index arithmetic (n - i) needs explicit guards or for-loop ranges derived from a bounded degree subtype to discharge index checks without an invariant.
- **index**: Reading the first and last entries of a shrinking row requires the row length to be tracked in a variable that is only bounded by its subtype, so each access is guarded just before use.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, functions, 'Image of scalars, Put without a newline, string building and records.

## External effects

- **console output** (allowed): Prints each embedded polynomial, its Jury table rows and the stable/unstable verdict.

Assessed on 2026-10-15 against page revision 414281 of the [task](https://rosettacode.org/wiki/Jury_stability_criterion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
