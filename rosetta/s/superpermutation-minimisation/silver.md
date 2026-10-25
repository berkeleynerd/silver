# Superpermutation minimisation

**Candidate: proofs plausibly discharge automatically.** Everything runs in procedures over fixed-bound arrays with ranged indexes and explicit capacity guards, but many loop-carried lengths and offsets without invariants make discharge depend on careful program shape rather than being routine.

Position 568 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Keep the current superpermutation in a fixed Character array of 6000 with a ranged length, and for each N from 1 to 7 build it by the standard expansion: for each window of the previous string with distinct characters, form window+new digit+window and merge it by searching the longest overlap with a bounded for loop. Compare the result length with the obvious N!*N and the factorial-sum size, print one row per N, and print the string only for N below 5; every append is guarded by a capacity check and overflow is reported as a rejection. About 130 lines.

## Proof obligations to watch

- **index**: The growing superpermutation buffer index is loop-carried through while loops, so each append and each prefix/suffix overlap comparison is guarded by an explicit capacity test against a 6000-character buffer, with a visible reject outcome on overflow.
- **overflow**: Lengths and factorial sums are held in ranged subtypes bounded by the buffer capacity and by 7!, and the loop-carried length is guarded before each increment.
- **termination**: The overlap search runs as a decreasing for loop in a procedure, so no variant is needed and procedures get no termination check.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, functions, string indexing, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints N, the obvious N!*N size, the constructed superpermutation length, and the string itself for small N.

Assessed on 2026-10-15 against page revision 414537 of the [task](https://rosettacode.org/wiki/Superpermutation_minimisation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
