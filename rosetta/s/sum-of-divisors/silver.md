# Sum of divisors

**Candidate: proofs likely to discharge automatically.** Simple nested for loops with static bounds and a guarded accumulator need no annotations, since the inner D range 1..N excludes zero and the sum is guarded before each addition. The only new needs are integer arithmetic, mod, for loops and integer-to-text output.

Position 128 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Main runs an outer for loop N in 1..100 and an inner for loop D in 1..N, adding D to a Natural accumulator whenever N mod D = 0, which avoids while loops and any termination question. Before each addition a guard checks that the sum stays within the subtype limit and otherwise prints a rejection message, then each result is printed as its image followed by a space via Put (and a final New_Line or Put_Line). All loop bounds are static, so mod has a nonzero divisor from the for-loop range. About 30 lines.

## Proof obligations to watch

- **overflow**: The accumulator is loop-carried and unbounded after the first iteration, so each addition is preceded by an explicit guard against the subtype's upper limit with a visible rejection outcome, which GNATprove discharges directly from the guard.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): The 100 divisor sums are written to standard output.

Assessed on 2026-10-15 against page revision 404133 of the [task](https://rosettacode.org/wiki/Sum_of_divisors) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
