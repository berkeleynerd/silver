# Hailstone sequence

**Candidate: proofs plausibly discharge automatically.** Every check follows from range types and explicit guards just before the arithmetic and array store, and the unannotatable termination question is avoided by using a procedure, so no annotation is needed but several loop-carried values need careful guards.

Position 233 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A Hailstone procedure takes a start value in a 1..100_000 subtype and fills a fixed 512-element array of a 64-bit range type, returning the element count and an ok flag via out parameters. A while loop applies n/2 or 3*n+1 with a guard on n's limit and the array capacity before each step, setting ok False if a guard fails. Main runs it for 27 and prints the count, first four and last four with Put and Image, then a for loop over 1..99_999 tracks the longest count and prints it. About 70 lines.

## Proof obligations to watch

- **overflow**: 3*n+1 on a loop-carried value is discharged by declaring n in a 64-bit range type and guarding n against a limit far above the task's peak of about 1.6 billion, with a visible reject outcome if exceeded.
- **index**: The element counter and array index are loop-carried, so a guard that the count is below the fixed array capacity (512, above the 351 maximum) precedes each store and its failure rejects visibly.
- **termination**: The Collatz while loop has no variant, so it is placed in a procedure, which gets no termination check.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the length and first and last four elements for 27, then the longest start below 100,000 and its length.

Assessed on 2026-10-15 against page revision 415511 of the [task](https://rosettacode.org/wiki/Hailstone_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
