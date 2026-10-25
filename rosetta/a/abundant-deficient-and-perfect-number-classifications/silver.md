# Abundant, deficient and perfect number classifications

**Candidate: proofs likely to discharge automatically.** Every check follows from static for-loop bounds, a nonzero divisor D and guards placed just before the loop-carried additions, with no recursion or annotation needed. The only care is capping the divisor sum and the counters with visible guards that cannot alter the required classification.

Position 131 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Main iterates N over 1 .. 20_000 with a nested for loop over D in 1 .. N/2, adding D to a bounded Natural sum when N mod D = 0 and the sum is within its guard. It then compares the sum with N using if/elsif/else to increment one of three guarded counters, and finally prints each class name, its count and the total using 'Image and Put_Line. About 40 lines.

## Proof obligations to watch

- **overflow**: The divisor-sum accumulator is loop-carried, so the program adds a divisor only when a guard shows the sum is at most 100000, which keeps the addition within the Integer range and cannot change the class because any sum above 20000 is already abundant.
- **overflow**: The three class counters are loop-carried, so each increment sits behind a guard that the counter is below 20000 or is typed as a range sized to the 20000 iterations.
- **termination**: All loops are for loops in the Main procedure with static bounds, so no termination check applies.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, 'Image of scalars, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints the three class counts and their total as text lines.

Assessed on 2026-10-15 against page revision 415331 of the [task](https://rosettacode.org/wiki/Abundant,_deficient_and_perfect_number_classifications) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
