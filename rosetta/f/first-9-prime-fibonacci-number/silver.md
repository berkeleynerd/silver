# First 9 prime Fibonacci number

**Candidate: proofs likely to discharge automatically.** Every check follows from declared ranges, a guard before the addition and a static for-loop range, and the while loop lives in a procedure so no variant is needed. The only extra surface is integer arithmetic, mod, 'Image and loops.

Position 203 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Keep two 64-bit Fibonacci values in a subtype capped at 10**9 and advance them in a while loop in Main, stopping with a visible message if the cap would be exceeded. For each value test primality with a for loop over divisors 2..1000, using a Boolean flag set when D*D <= A and A mod D = 0, and print each prime with 'Image (leading space trimmed by building the string) via Put_Line until nine are found. About 45 lines.

## Proof obligations to watch

- **overflow**: The Fibonacci sum is loop-carried, so the loop first checks that both operands are at most 1_000_000 (a visible stop outcome otherwise) and the values live in a 64-bit type, which makes the addition safe.
- **termination**: The count-driven while loop sits in the Main procedure, which gets no termination check, and a hard bound on the Fibonacci value also ends it.
- **range**: In the trial-division for loop the product D*D is bounded by the loop's static range 2..1000, so it cannot overflow, and the remainder is guarded by D being nonzero.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, 'Image of scalars, for loops, while loops and string building.

## External effects

- **console output** (allowed): Prints the nine prime Fibonacci numbers one per line.

Assessed on 2026-10-15 against page revision 406207 of the [task](https://rosettacode.org/wiki/First_9_prime_Fibonacci_number) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
