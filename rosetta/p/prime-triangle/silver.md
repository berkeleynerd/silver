# Prime triangle

**Candidate: proofs plausibly discharge automatically.** Every check follows from small ranged subtypes and guards on bounded arrays, and the work is done in a procedure with while loops, but the loop-carried position, candidate and counter values need careful guarding, so discharge is plausible rather than certain.

Position 281 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A constant Boolean array marks primes up to 40, and a procedure Count_Arrangements (S) runs an iterative depth-first backtracking search over a ranged-subtype position index with a Used Boolean array and an Arrangement array, fixing 1 first and S last. Candidate values are tried in an inner while loop with guards before every index, the first solution found is saved and printed with Put, and the count is accumulated in a bounded counter. The main procedure loops S from 2 to 20 printing each first solution as a triangle, then loops again printing the counts. About 110 lines.

## Proof obligations to watch

- **index**: The backtracking position and candidate values are loop-carried, so each array access is guarded by an explicit range test just before use and the position is a ranged subtype that is only moved after a bounds guard.
- **overflow**: Solution counts reach about a million for S=20, so the counter is a ranged type with a generous upper bound and an explicit guard before each increment, with a visible reject outcome if ever reached.
- **termination**: The search loop is a while loop inside a procedure, which receives no termination check, and no function contains a loop.
- **other**: The prime table is a fixed Boolean aggregate for sums up to 39, so no sieve loop with loop-carried indexes is needed.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints one example arrangement per S from 2 to 20 and then the arrangement counts.

Assessed on 2026-10-15 against page revision 414009 of the [task](https://rosettacode.org/wiki/Prime_triangle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
