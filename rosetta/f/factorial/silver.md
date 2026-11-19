# Factorial

**Candidate: proofs likely to discharge automatically.** The primary task requires a real factorial function and permits iteration. The empty loop returns 0! = 1. Before step i <= 12 the exact accumulator is (i-1)! <= 39916800, so the static guard never skips a product; 12! = 479001600 fits Integer, while 13! does not. The sample covers the complete nonnegative argument domain whose factorial fits this Integer representation; optional negative-input handling is omitted. The [reconciliation](../../../rosetta/assessment-scalar-function-batch-20261108.md) preserves the original assessment attribution and links the separately reviewed Linux application evidence; final combined integration and independent delivery status remain in the batch delivery record.

Position 47 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_factorial.adb: Factorial(N : in Factorial_Argument) returns Factorial_Value, with argument range 0..12 and result range 1..479001600. Its initialized local Result is multiplied by every Factor in 1..N under Result <= 39916800, followed by one terminal return. Main assigns each call result to a scalar and prints all thirteen inputs with Integer Image. About 22 lines.

## Proof obligations to watch

- **overflow**: The bare-local static guard Result <= 39916800 and Factor <= 12 bound each admitted product by 479001600; the factorial-prefix argument establishes that the guard preserves every required update.
- **range**: Every computed product and the terminal return fit the declared 1..479001600 result range over the full 0..12 formal domain.

## Language surface recorded by this assessment

Named Integer subtypes, bounded components and scalar signatures, small nonrecursive scalar functions, bounded mutable Integer objects, Integer range for loops, scalar guard refinement and Integer image.

## External effects

- **console output** (allowed): Prints the input and its computed factorial for every integer 0..12 with Put_Line.

Initially assessed on 2026-10-15 against page revision 415532 of the [task](https://rosettacode.org/wiki/Factorial) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-08 by Codex through targeted source review; see the [review record](../../assessment-scalar-function-batch-20261108.md).
