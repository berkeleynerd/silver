# Cousin primes

**Candidate: proofs likely to discharge automatically.** Every check follows from small declared ranges, fixed for-loop bounds and a guard before the counter increment, so no loop invariant or variant is needed. The program is only a bounded trial-division loop with 'Image output, which is within reach once integers, for loops, functions and Put exist.

Position 317 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

An Is_Prime function takes a subtype Natural 0 .. 1003 and tests divisors D in 2 .. 31 with a for loop (31 squared is below 1000, 32 squared is above), returning False on D*D < N with N mod D = 0. The main procedure loops N in 1 .. 995, prints each pair using Integer'Image into Put calls, breaks the line when the guarded Count mod 8 = 0, and prints the final count with Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: The pair counter is a loop-carried value, so it is declared as a subtype with range 0 .. 1000 and incremented only under a guard that it is below 1000, which the 995 candidates can never reach.
- **termination**: Is_Prime uses only a for loop over the fixed divisor range 2 .. 31, so the function termination check discharges without a variant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, 'Image of scalars, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints each cousin prime pair and the final pair count to standard output.

Assessed on 2026-10-15 against page revision 406195 of the [task](https://rosettacode.org/wiki/Cousin_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
