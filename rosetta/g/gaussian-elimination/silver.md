# Gaussian elimination

**Candidate: proofs plausibly discharge automatically.** All indexing, loops and termination are routine, but floating-point loop-carried values need explicit magnitude and pivot guards with visible rejection outcomes, so discharge depends on careful program shape without needing annotations. Singular or overly large systems get a defined rejection rather than altered results.

Position 1079 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Fixed 6x6 Real matrix and 6-element vector are embedded as constants, copied into working arrays, and solved by a procedure using for loops for pivot search with row scaling, row swaps, elimination and reverse back substitution. Every division is preceded by an epsilon pivot guard and every stored result by a magnitude guard, both reporting a specified rejection message on failure, and the six results are printed as text via float image. About 110 lines.

## Proof obligations to watch

- **floating point**: Elimination updates are loop-carried matrix entries, so each result is computed in a wide base type from operands bounded by a subtype and rejected through a visible guard if it exceeds the bound, which keeps products and differences finite.
- **division**: The pivot is guarded by abs(pivot) >= a small epsilon before every division in elimination and back substitution, and a singular system is rejected with a specified message.
- **range**: Row and column indexes come from for loops over the matrix's own constant range, and the pivot-row index is a variable of the index subtype, so index checks follow from types.
- **overflow**: Assigning a result back into a range-restricted element needs the guard-before-store pattern, otherwise the subtype range check is unprovable after the first iteration.

## Language surface recorded by this assessment

Floating point, floating-point images, multidimensional arrays, arrays, ranged subtypes, integers, for loops, procedures, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): The solution vector is printed as text on standard output.

Assessed on 2026-10-15 against page revision 414231 of the [task](https://rosettacode.org/wiki/Gaussian_elimination) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
