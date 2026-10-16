# Identity matrix

**Candidate: proofs likely to discharge automatically.** Every check is an index or range check on for-loop variables bounded by a guarded N, with no loop-carried values or recursion, so proofs should discharge automatically. The only new library need is validated integer parsing of the argument, which the Oracle's admitted operations must supply.

Position 1122 in the [progression](../../progression.md#stage-20), in stage 20, which adds text parsing.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

Declare a bounded square array type Matrix (1..16, 1..16) of a 0..1 subtype, parse the first argument to a size N, and reject it with a visible message unless 1 <= N <= 16. Initialize the matrix to all zeros with an aggregate, set the diagonal with a for loop over 1..N, then print the top-left N-by-N block with nested for loops using Put per element and Put_Line at row ends. About 40 lines.

## Proof obligations to watch

- **range**: The parsed size must be checked against the fixed capacity 1..16 by an explicit guard before it is converted to the size subtype, with out-of-range input rejected visibly.
- **initialization**: The matrix is fully initialized by an others => 0 aggregate before the diagonal loop, so flow analysis passes; the loop writes only in-range indexes of the for-loop variable.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, text parsing, Put without a newline and procedures.

## External effects

- **arguments** (allowed): The matrix size is read from the first command-line argument, since the task says the size is known at run-time.
- **console output** (allowed): The resulting matrix is printed row by row to standard output.
- **exit status** (allowed): An invalid or out-of-range size argument is rejected with a specified failure outcome.

Assessed on 2026-10-15 against page revision 415271 of the [task](https://rosettacode.org/wiki/Identity_matrix) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
