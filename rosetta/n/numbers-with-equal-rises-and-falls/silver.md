# Numbers with equal rises and falls

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged types, the fixed-length digit loop and small guards before each carried increment, and the roughly 42 million iterations are a runtime cost, not a proof issue; the main work is careful guard placement for the counters, hence plausible.

Position 376 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A pure Boolean function copies the candidate into a local, then runs a fixed 10-iteration for loop that peels off the last two digits with mod and / 10, counting rises and falls in guarded counters and comparing them at the end. A procedure with a while loop on Count below 10,000,000 increments a ranged candidate (rejecting at the type's upper bound), prints the first 200 hits via Put and Integer'Image padded into rows of 20, and prints the 10,000,000th hit (41,909,002) with Put_Line. About 60 lines.

## Proof obligations to watch

- **overflow**: The Rises and Falls counters and the candidate Value are loop-carried, so each increment is preceded by an explicit guard against the type's upper bound, and the outer loop stops with a visible rejection if Value reaches its limit.
- **termination**: The digit scan is a for loop over a fixed 10 positions inside a function, so no variant is needed, while the unbounded candidate search with a while loop lives in a procedure with no termination check.
- **division**: Only division and mod by the literal 10 are used, so no zero-divisor check arises.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 200 sequence numbers in rows of 20 and the 10,000,000th number.

Assessed on 2026-10-15 against page revision 413513 of the [task](https://rosettacode.org/wiki/Numbers_with_equal_rises_and_falls) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
