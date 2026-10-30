# Emirp primes

**Candidate: proofs plausibly discharge automatically.** Every check follows from a fixed-size sieve array and bounded six-digit numbers, but the sieve stepping index and the reversal accumulator are loop-carried values that need explicit guards, so discharge depends on careful program shape rather than annotations.

Position 1117 in the [progression](../../progression.md#stage-18), in stage 18.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

A fixed Boolean sieve array over 2..1_000_000 is built in a procedure, which covers the 10,000th emirp (948349) and the reversals of all six-digit candidates. A procedure reverses each candidate's digits with a guarded accumulator and checks that the number differs from its reversal and that both are prime, and the main program counts emirps for the requested mode chosen from the first argument. Output is built as text and printed with Put_Line, and a count or range limit stops the scan. About 90 lines.

## Proof obligations to watch

- **overflow**: The digit-reversal accumulator is carried through a loop, so the program guards the multiply-add (reject if the accumulator exceeds a bound) or limits the loop to six digits so the result stays within 0..999999.
- **index**: Sieve marking uses a computed index stepping by the prime, discharged by a while loop in a procedure with a guard that the next multiple does not exceed the limit minus the step.
- **range**: Indexing the sieve with the reversed number needs the reversed value typed or guarded to stay within 1..1_000_000, which holds because every candidate has at most six digits.
- **termination**: Sieve marking and the reversal loop are while loops, which are only acceptable inside procedures, so reversal and marking are written as procedures or as for loops over bounded digit counts.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline, case statements and text parsing.

## External effects

- **console output** (allowed): Prints the first twenty emirps, the emirps between 7700 and 8000, and the 10,000th emirp.
- **arguments** (allowed): The first argument selects which of the three task requirements to run, with invalid input rejected.

Assessed on 2026-10-15 against page revision 414179 of the [task](https://rosettacode.org/wiki/Emirp_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
