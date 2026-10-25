# Matrix chain multiplication

**Candidate: proofs plausibly discharge automatically.** Everything is bounded dynamic programming with for loops and type-bounded arithmetic, and the only non-routine parts are guarding the loop-carried split table and the explicit-stack reconstruction, which need no annotations but careful shape.

Position 715 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the three dimension lists as constant arrays with dimensions subtyped 1..1000 and a fixed maximum chain length, and run the classic dynamic program in a procedure over 2D cost and split tables using for loops with Long_Long_Integer arithmetic. Reconstruct the parenthesization iteratively with an explicit work stack and a bounded output String buffer, guarding split points and buffer length before each use, then print the cost and expression per list. About 110 lines.

## Proof obligations to watch

- **overflow**: The triple product and the sum of sub-costs are computed in a 64-bit type from dimensions subtyped to 1..1000 and costs capped by a range, which discharge by type bounds without nonlinear reasoning beyond bounded operands.
- **range**: Cost entries are initialized to a cap and assigned only inside the guard that the new cost is below the current entry, so the assignment is in range by the guard.
- **index**: The split point read back from the table is not known to lie in I..J-1 without an invariant, so each use (K+1 and sub-range indexes) needs an explicit guard with a visible rejection outcome.
- **termination**: The parenthesization is printed by an iterative while loop with an explicit bounded stack inside a procedure, which avoids recursion and function variant checks, but stack-overflow guards must reject rather than alter output.
- **initialization**: The cost and split tables are filled fully in the loops, but flow analysis of 2D array element-wise initialization may need whole-array initial values in the declaration.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, multidimensional arrays, for loops, while loops, procedures, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the dimension list, the optimal cost and the parenthesization for each of the example lists.

Assessed on 2026-10-15 against page revision 414331 of the [task](https://rosettacode.org/wiki/Matrix_chain_multiplication) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
