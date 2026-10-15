# Perfect totient numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from array bounds and subtype ranges, with the only loop-carried arithmetic (the chain sum and sieve multiple) kept safe by a guard before use, so it should discharge without annotations but depends on careful program shape.

Position 221 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Sieve a constant-bounded array Phi (1..5600) of totients by a prime-stepping while loop, then for each candidate from 3 upward follow the chain Phi(n), Phi(Phi(n)), ... down to 1 while accumulating a sum, exiting early if the sum exceeds the limit. Print each candidate whose sum equals itself with Put_Line of its image, stopping once twenty are found; all of this is inside the Main procedure. About 45 lines.

## Proof obligations to watch

- **overflow**: The loop-carried sum of the totient chain is discharged by exiting once the sum exceeds the search limit before adding the next term, which cannot change the result since such a sum never equals the candidate.
- **index**: Chain values and sieve multiples are indexed only after a guard or via a subtype restricted to 1..Limit, so the loop-carried values stay in the array bounds.
- **range**: The sieve multiple m advances by p inside a while loop, so the loop condition m <= Limit must bound m before m + p and before the array index.
- **termination**: All while loops sit in a procedure, which gets no termination check, so no variant is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the first twenty perfect totient numbers one per line.

Assessed on 2026-10-15 against page revision 411874 of the [task](https://rosettacode.org/wiki/Perfect_totient_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
