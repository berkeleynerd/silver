# Routh–Hurwitz stability criterion

**Candidate: proofs plausibly discharge automatically.** The task is bounded array arithmetic with for loops, so all checks come from subtypes and guards, but loop-carried row growth and the special cases mean the guards must be placed carefully; integer scaling avoids floating point and division.

Position 934 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Integer coefficients of embedded test polynomials (degree up to about 6) go into a bounded array, and the Routh table is a fixed 2D array of a wide ranged integer subtype built row by row with nested for loops. Each new row uses sign-preserving cross-multiplication scaled by the positive pivot magnitude instead of division, with magnitude guards before every product, a replacement of a zero pivot by a small positive value, and the auxiliary-polynomial derivative for an all-zero row. A procedure then counts first-column sign changes and prints the table and the verdict, with oversized or degenerate input rejected visibly. About 130 lines.

## Proof obligations to watch

- **overflow**: Row entries are cross-products of the previous two rows so they grow with each row, and the program discharges this by storing them in a wide bounded integer subtype and testing both operand magnitudes against a limit before each product, printing an explicit 'coefficients too large' rejection otherwise.
- **range**: Loop-carried table entries are known only by their subtype, so every sum and product must be guarded just before use rather than relying on an invariant.
- **division**: The program avoids division by scaling each row with the positive magnitude of the pivot instead of dividing, which preserves signs and keeps the sign-change count correct.
- **other**: The zero-pivot and all-zero-row special cases must be implemented explicitly (small positive epsilon via scaled integers, auxiliary-polynomial derivative) with guards, which raises program-shape complexity but needs no annotation.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, 'Image of scalars, string building, for loops, procedures, functions, conditional expressions and Put without a newline.

## External effects

- **console output** (allowed): Prints each embedded test polynomial's Routh table, sign-change count and STABLE or UNSTABLE verdict.

Assessed on 2026-10-15 against page revision 413894 of the [task](https://rosettacode.org/wiki/Routh%E2%80%93Hurwitz_stability_criterion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
