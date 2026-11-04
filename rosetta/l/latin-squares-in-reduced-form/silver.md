# Latin Squares in reduced form

**Candidate: proofs plausibly discharge automatically.** The task fits an iterative bounded backtracking procedure over fixed-size arrays with small ranged integers, so every check follows from types and guards, though cursor and counter bookkeeping in the loop needs careful guarding.

Position 835 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Use a fixed 6x6 Integer array with Boolean used-per-row and used-per-column arrays, and an iterative depth-first search in a procedure that walks cells row-major with an explicit cursor, trying values 2..n that are unused in the row and column and counting or printing each completed square (first row and column pre-set to natural order). A for loop over n=1..6 calls the counter, computes size*n!*(n-1)! in a bounded range type, and prints the table with the expected OEIS A002860 values embedded as a constant array, while the order-4 run prints each square with Put and Put_Line of 'Image text. All indices are ranged subtypes with explicit guards before each array access, and the counter is capped with a rejecting guard. About 130 lines.

## Proof obligations to watch

- **index**: The iterative backtracking cursor (cell position and candidate value) is loop-carried, so it is declared with a ranged subtype and every step and backtrack is guarded just before the array access.
- **overflow**: The solution counter and the size times n! times (n-1)! products are bounded by range types sized for order 6 (9408 and 812851200), with an explicit guard that rejects counts above the documented cap.
- **initialization**: The row, column and used-value arrays are fully initialized by aggregates or for loops before the search loop so flow analysis sees no uninitialized reads.
- **termination**: The unbounded-looking backtracking while loop lives in a procedure, which has no termination check, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline, string building and case statements.

## External effects

- **console output** (allowed): Prints the four order-4 squares and the table of orders 1 to 6 with sizes and totals.

Assessed on 2026-10-15 against page revision 413758 of the [task](https://rosettacode.org/wiki/Latin_Squares_in_reduced_form) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
