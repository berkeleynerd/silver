# Percolation/Mean cluster density

**Candidate: proofs plausibly discharge automatically.** Every check follows from subtype ranges and explicit bounds guards before each neighbour access, and the only unbounded loop is a while loop in a procedure, so no annotation is needed; the main care is shaping the stack and counter ranges and avoiding floating point by using scaled integers.

Position 734 in the [progression](../../../progression.md#stage-12), in stage 12.

## Approach

Fixed-capacity 1000x1000 Boolean grid (sized by a constant, with n from the table 4 to 1000 as a literal list) filled by an integer LCG with mod reduction, p=0.5 as seed parity-free threshold comparison, and clusters counted by an iterative flood fill using an explicit integer stack array in a procedure. A 15x15 grid is labelled with letters (label index guarded to a letter, else '?') and printed row by row with Put, then for each n five runs are summed as integer cluster counts and the mean density is printed as an integer scaled by 1,000,000 formatted to six decimals via string building. About 150 lines.

## Proof obligations to watch

- **overflow**: The linear congruential generator and the density sum use bounded 64-bit ranges with mod reduction, and the scaled density (sum times 1,000,000, with sum at most 5,000,000) stays far below the limit.
- **index**: Flood fill pushes neighbours only after explicit row and column bounds guards and a stack-capacity guard (capacity n*n with each cell pushed at most once because it is marked when pushed), so no index check relies on a loop invariant.
- **range**: The stack pointer and cluster counter are loop-carried, so they are declared with types whose ranges cover n*n and the push guard keeps the pointer inside its subtype.
- **termination**: The flood-fill while loop lives in a procedure, which GNATprove does not check for termination, and the outer scans are for loops.
- **stack**: A 1000x1000 grid plus a million-entry stack is a fixed-size resource limit that is outside the proof and relies on the environmental memory premise.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 15x15 labelled cluster grid and a table of n versus mean cluster density.

Assessed on 2026-10-15 against page revision 414390 of the [task](https://rosettacode.org/wiki/Percolation/Mean_cluster_density) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
