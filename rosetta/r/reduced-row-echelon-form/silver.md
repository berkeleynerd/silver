# Reduced row echelon form

**Candidate: proofs plausibly discharge automatically.** The algorithm is simple loops over fixed array ranges, so index checks are routine, but the float arithmetic carried through loops needs magnitude guards with visible rejection to discharge overflow and division checks, hence plausible rather than likely.

Position 1085 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

The 3x4 example matrix is embedded as a constrained two-dimensional Float array with a bounded-magnitude element subtype. Procedures implement the Wikipedia pseudocode: a while loop searches for a nonzero pivot with explicit guards on the row and lead indexes, then swap, divide and eliminate loops run over the array's own ranges, with any out-of-bound result or too-small pivot rejected visibly. The original and reduced matrices are printed with a float-to-text routine. About 110 lines.

## Proof obligations to watch

- **floating point**: Every row operation writes a loop-carried float into the matrix, so each result is computed in a wide base type and checked against a declared magnitude bound with a visible rejection outcome before being stored, otherwise the overflow check cannot discharge.
- **division**: Dividing a row by its pivot is guarded by a pivot-nonzero test, and a minimum pivot magnitude is also required (rejecting smaller pivots visibly) so the quotient cannot overflow.
- **index**: The pivot-search while loop advances the row and lead column indexes, which are guarded against the matrix bounds before each use and are otherwise known only by their subtype range.
- **overflow**: Products of two bounded elements stay far below the float limit by choice of the bound, but the nonlinear arithmetic needs the provers to bound it from the subtype ranges.

## Language surface recorded by this assessment

Floating point, ranged subtypes, multidimensional arrays, for loops, while loops, procedures, floating-point images, Put without a newline, integers, Boolean objects and conditional expressions.

## External effects

- **console output** (allowed): Prints the input matrix and its reduced form to standard output.

Assessed on 2026-10-15 against page revision 413880 of the [task](https://rosettacode.org/wiki/Reduced_row_echelon_form) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
