# Prime numbers which contain 123

**Candidate: proofs likely to discharge automatically.** Every check follows from a ranged array, ranged subtypes and guards placed immediately before each addition or index, and no loop needs an invariant because loop-carried values are either type-bounded or tested by the loop condition. Only the loop-carried counter and sieve step need a little care in program shape.

Position 347 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A Boolean sieve array indexed 0..999_999 is filled by a procedure using a for loop over candidates and a while loop stepping through multiples guarded by j <= Limit. A second pass checks each prime for the digits 123 by stripping digits with mod 1000 = 123 and division by 10, counts matches under a bounded counter, and prints those below 100,000 via Integer'Image and Put_Line, then prints both counts. About 60 lines.

## Proof obligations to watch

- **overflow**: The sieve's multiple-stepping variable and the match counter are loop-carried, so each is guarded by its while condition or an explicit bound check just before the addition.
- **index**: Sieve array indexes are protected by the loop condition j <= Limit and by for-loop indexes over the array's own range.
- **termination**: All while loops (sieve stepping and digit stripping) live in procedures, which get no termination check, and functions contain only for loops.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 46 matching primes below 100,000 and the two counts.

Assessed on 2026-10-15 against page revision 406124 of the [task](https://rosettacode.org/wiki/Prime_numbers_which_contain_123) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
