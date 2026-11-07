# Next special primes

**Candidate: proofs likely to discharge automatically.** Everything is small bounded integer arithmetic with trial division in a for-loop function, and the only while loop is in the Main procedure with a guard condition that bounds all loop-carried values.

Position 306 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A function Is_Prime on a ranged subtype (0 .. 2200) does trial division with a for loop over D in 2 .. 46, testing D < N and then N mod D = 0. The Main procedure prints 2 and 3, then runs a while loop with P (last term) and I (even step, starting at 2) bounded by subtypes, adding P + I to the list when it is prime, then increasing I by 2 while P + I < 1050. Each term is printed with Put_Line (Integer'Image), one per line. About 35 lines.

## Proof obligations to watch

- **overflow**: The loop-carried P and I are declared with ranged subtypes and the while condition P + I < 1050 is tested just before P + I and I + 2, so both stay in range without an invariant.
- **termination**: The primality test is a function containing only a for loop over a fixed range, and the while loop lives in the Main procedure, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, while loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each special prime below 1050 on its own line.

Assessed on 2026-10-15 against page revision 393532 of the [task](https://rosettacode.org/wiki/Next_special_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
