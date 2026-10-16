# Numbers k such that the last letter of k is the same as the first letter of k+1

**Candidate: proofs plausibly discharge automatically.** Every check follows from small constant tables, range subtypes and division/mod on a bounded k, but the carried counters and the 10-million-iteration scan need careful guard placement without invariants, so discharge depends on program shape.

Position 854 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Compute the first and last letter of the English name of any n below 100,000,000 directly (without building the name) from constant Character tables for 0..19, tens, and the magnitude words, using a loop-free case/if decomposition by millions, thousands and hundreds. A procedure scans k upward with a bounded while loop, compares last_letter(k) with first_letter(k+1), records the first 50 values, bumps a 10-entry array of per-final-digit counts, and at 1,000, 10,000, 100,000 and 1,000,000 qualifiers prints the number and the breakdown as bounded string lines. Counts and k are range-typed and guarded, with the loop exiting at the millionth qualifier. About 170 lines.

## Proof obligations to watch

- **overflow**: Loop-carried counters (qualifier count, per-digit counts, candidate k) are bounded by declared ranges and an explicit guard that ends the loop or rejects before any increment, since no invariant can be written.
- **termination**: The scan is a while loop inside a procedure (no termination check) or a for loop over a fixed range, and the letter-lookup functions are loop-free so they need no variant.
- **range**: Letter lookups decompose a bounded number (below 100,000,000) with division and mod into subtype-ranged parts that index constant name tables, which discharges from the subtype bounds.
- **length**: Output lines are built in fixed-capacity buffers sized for the largest value, with padding computed from 'Image lengths that the bounded number range limits.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 50 qualifying numbers, the 1,000th to millionth qualifying numbers and the final-digit breakdowns.

Assessed on 2026-10-15 against page revision 414363 of the [task](https://rosettacode.org/wiki/Numbers_k_such_that_the_last_letter_of_k_is_the_same_as_the_first_letter_of_k%2B1) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
