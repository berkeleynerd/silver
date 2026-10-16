# Walsh matrix

**Candidate: proofs likely to discharge automatically.** The Kronecker doubling is nested for-loops over bounded indexes with a constant power table, so every index and negation check follows from declared ranges and for-loop bounds with no loop-carried invariants.

Position 669 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Store the matrix in a fixed 32 by 32 array of a cell subtype ranging -1 .. 1, and build it iteratively by doubling: for each step, copy the current top-left Half by Half block into the right and lower blocks and negate it into the lower-right block, with Half read from a constant power-of-two table. A procedure takes an order K limited to 0 .. 5 by its subtype and prints the 2**K rows with Put for each cell and Put_Line at the row end, called for several embedded values of K; the optional sequency ordering is left out. About 70 lines.

## Proof obligations to watch

- **index**: Block offsets like R + Half index a fixed 32 by 32 array, discharged because Half comes from a constant table typed 1 .. 16 and R is a for-loop variable over 0 .. Half - 1, so R + Half is at most 31.
- **initialization**: The out matrix parameter must be fully assigned before reads, discharged by an initial nested for-loop that sets every cell before the doubling loop.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The program prints a few generated matrices as rows of 1 and -1 text.

Assessed on 2026-10-15 against page revision 412136 of the [task](https://rosettacode.org/wiki/Walsh_matrix) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
