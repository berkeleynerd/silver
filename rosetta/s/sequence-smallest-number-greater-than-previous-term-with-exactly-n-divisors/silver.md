# Sequence: smallest number greater than previous term with exactly n divisors

**Candidate: proofs likely to discharge automatically.** Every check follows from declared subtype ranges and guards placed just before the increments, the divisor-count function uses only a for loop, and the unbounded-looking search is in a procedure with an explicit limit, so no annotation is required (the largest term is 4624 versus a 100000 limit).

Position 326 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Declare subtype Candidate is Integer range 1 .. 100000 and a function Count_Divisors(N) that loops I in 1 .. 100000, testing I <= N and N mod I = 0 and incrementing a guarded Count. The Main procedure loops D in 1 .. 15 and uses a while loop to advance N (starting from the previous term plus one) under a guard N < Limit until Count_Divisors(N) = D, then prints N with 'Image, or prints a visible failure message if the limit is reached. About 45 lines.

## Proof obligations to watch

- **overflow**: The divisor count and candidate N are subtypes bounded at 100000 and the count increment is guarded by Count < Limit, so the addition is provable from the type range without an invariant.
- **termination**: The while search lives in the Main procedure (no termination check) and exits with a visible rejection message if N reaches the fixed limit, so it always ends.
- **range**: The loop-carried N is incremented only under a guard N < Limit, so the subtype range check discharges just before use.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 15 terms to standard output.

Assessed on 2026-10-15 against page revision 414460 of the [task](https://rosettacode.org/wiki/Sequence:_smallest_number_greater_than_previous_term_with_exactly_n_divisors) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
