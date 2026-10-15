# Cramer's rule

**Candidate: proofs plausibly discharge automatically.** Integer coefficients with ranged types make Cramer's rule a bounded straight-line computation with for loops only, so overflow and division checks should discharge from type ranges and a nonzero-denominator guard, though nonlinear products make provers need careful bounds.

Position 700 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Use a ranged Integer subtype for a constant 4x4 matrix and right-hand side vector embedded in the program, and compute 4x4 determinants with a function that expands along the first row into explicit 3x3 determinant functions (no recursion). For each column, copy the matrix into a local array, substitute the right-hand side with for loops, compute the numerator, and in a procedure guard the denominator being nonzero before dividing and printing each value via 'Image concatenation. About 80 lines.

## Proof obligations to watch

- **overflow**: Determinant products of four bounded entries are nonlinear, so entries are a declared range (for example -1000..1000) and sums are computed in Long_Long_Integer so the provers can bound every product and sum from types alone.
- **division**: Each quotient is guarded by an explicit test that the determinant is nonzero, with a visible rejection message otherwise.
- **range**: Cramer's rule gives a rational result, so the program checks the remainder is zero before dividing and otherwise prints the numerator and denominator, which avoids silently truncating results.
- **index**: Minor extraction indexes a 4x4 array with for-loop variables over its own ranges, which is routine, but skipping a row or column needs guarded index arithmetic.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, 'Image of scalars, string building, for loops, procedures and functions.

## External effects

- **console output** (allowed): Prints the four solved values w, x, y and z one per line with Put_Line.

Assessed on 2026-10-15 against page revision 414136 of the [task](https://rosettacode.org/wiki/Cramer's_rule) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
