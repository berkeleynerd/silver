# Element-wise operations

**Candidate: proofs plausibly discharge automatically.** All indexes come from the arrays' own ranges and every arithmetic result is guarded against the declared Element range before storing, so only the exponentiation loop and the text-building need careful shaping, with no annotations required.

Position 831 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Represent a matrix as a 3x3 two-dimensional array of a ranged Element subtype (about -10_000..10_000) with embedded example matrices. Procedures apply addition, subtraction, multiplication, division, mod and exponentiation element-wise for both matrix-scalar and matrix-matrix operands inside nested for loops over the array's own index ranges, with an Ok out flag set false on any overflow, zero divisor or out-of-range exponent. Main prints each result via integer 'Image text built row by row into a bounded buffer with Put_Line, printing a rejection message when Ok is false. About 130 lines.

## Proof obligations to watch

- **overflow**: Add, subtract and multiply on Element values are computed in a wider Integer range and then tested against the Element bounds before storing, with an overflowing cell producing a visible rejection message rather than a clipped value.
- **division**: Division, mod and rem by zero are guarded by an explicit test on the divisor (matrix cell or scalar) that leads to a printed rejection.
- **overflow**: Exponentiation uses a small loop with a bounded exponent (0..8) and a range check on the running product each iteration, because no invariant can carry the bound across iterations, so the guard must reject before multiplying.
- **length**: Image text is built into a fixed-capacity buffer sized for 3x3 cells of at most 8 characters plus separators, so the length check follows from static bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, multidimensional arrays, arrays, for loops, procedures, functions, 'Image of scalars, string building, string indexing and case statements.

## External effects

- **console output** (allowed): Each operation's resulting matrix is printed as text lines with Put_Line.

Assessed on 2026-10-15 against page revision 414176 of the [task](https://rosettacode.org/wiki/Element-wise_operations) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
