# Summation of primes

**Candidate: proofs likely to discharge automatically.** Every check follows from declared ranges, for-loop indexes and a single guard before the accumulator addition, and no loop needs an invariant or variant, so proofs should discharge automatically.

Position 326 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Define a bounded integer subtype for candidates 2..1_999_999 and a wide range type for the sum, with a Boolean Is_Prime function doing trial division by a for loop over 2..1414 that exits once D*D exceeds N. The main for loop over candidates adds each prime to Sum after a guard that Sum plus the candidate stays within the sum type's maximum (rejecting otherwise), then prints the result using 'Image concatenated onto a label with Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: The loop-carried Sum is discharged by declaring it in a wide range type and guarding each addition with a comparison against the type maximum, with a visible reject outcome that can never trigger in practice.
- **overflow**: The D*D product in trial division is bounded because D is a for-loop index limited to 2..1414 so the square fits easily in Integer.
- **termination**: Is_Prime uses only for loops with an exit, which terminate by construction, so no variant is required even inside a function.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the single result line with the sum of primes below two million.

Assessed on 2026-10-15 against page revision 405497 of the [task](https://rosettacode.org/wiki/Summation_of_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
