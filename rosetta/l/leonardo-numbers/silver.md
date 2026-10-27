# Leonardo numbers

**Candidate: proofs likely to discharge automatically.** The task is a small bounded recurrence on a fixed-size array where the values fit comfortably in a ranged subtype and a guard before each addition removes the only loop-carried overflow risk, so no annotation is needed.

Position 62 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

A procedure Show (First, Second, Add) fills a constant-size array of 25 values of a bounded integer subtype using a for loop over the array's indexes, guarding each sum against the subtype limit before computing it, then prints each value with Put and 'Image in a second for loop over the array's own range. The main program calls Show with (1, 1, 1) and (0, 1, 0), with the seeds embedded as literals, and the overflow guard emits a specified message and stops filling. About 45 lines.

## Proof obligations to watch

- **overflow**: The recurrence L(n-1)+L(n-2)+Add is loop-carried, so each step is preceded by a guard comparing the operands against the subtype's upper limit and rejecting visibly instead of altering results.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the two 25-number sequences and their headings to standard output.

Assessed on 2026-10-15 against page revision 411765 of the [task](https://rosettacode.org/wiki/Leonardo_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
