# Sort numbers lexicographically

**Candidate: proofs plausibly discharge automatically.** The task has a fixed small input and generates the order directly with integer arithmetic, so every check follows from a bounded subtype plus guards placed just before the operations, though the loop-carried current value needs careful guarding.

Position 222 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A procedure Show (N : Limit_Range) walks 1..N in lexicographic order without sorting: starting at 1, a for loop runs N times, printing the current value with 'Image via Put, then computing the next value (multiply by 10 if the result stays at most N, otherwise strip a trailing digit when at or above N, increment, and strip trailing zeros in a while loop). Main calls Show (13) and Show (21) and ends each line with a line terminator, with all arithmetic guarded to stay inside a bounded integer subtype. About 45 lines.

## Proof obligations to watch

- **overflow**: The loop-carried current value is typed with a bounded subtype, so each multiply by 10 and each increment is guarded just before use (cur*10 compared to n, cur below the subtype maximum) and discharges from the guard.
- **range**: Dividing by 10 to step back up the tree can reach zero when n is below 10, so the step is guarded with cur >= 10 and the next-value step is skipped after the last element.
- **termination**: The trailing-zero while loop sits in a procedure, which gets no termination check, and it halts anyway because each division by 10 shrinks the value.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the lexicographic ordering for n = 13 and n = 21 as text lines.

Assessed on 2026-10-15 against page revision 414487 of the [task](https://rosettacode.org/wiki/Sort_numbers_lexicographically) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
