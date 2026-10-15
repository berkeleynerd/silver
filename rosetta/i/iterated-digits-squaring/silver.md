# Iterated digits squaring

**Candidate: proofs likely to discharge automatically.** Every check follows from ranged subtypes, array bounds and non-loop-carried digit expressions, with the only loop-carried values being a 64-bit counter and a range-typed chain value inside a procedure, so no annotation is needed.

Position 340 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A procedure fills a Boolean table Ends_89 over 0..648 by following each value's chain with a while loop and a three-digit square-sum step written as an explicit expression; the main loop then runs a for loop over 1..99_999_999, sums the squares of the eight digits with an unrolled expression using a constant squares array, indexes the table, and increments a 64-bit Count. It prints the count when A = 999_999 and again at the end using 'Image, with all loop-carried values held in ranged subtypes. About 55 lines.

## Proof obligations to watch

- **overflow**: The Count accumulator is loop-carried, so it is declared in a 64-bit integer range type (or guarded below its bound) so that Count + 1 cannot overflow after the first iteration.
- **range**: The eight-term digit-square sum is written as one non-loop-carried expression of table lookups bounded by 81 each, so the 0..648 result range check is a linear fact over constant array values that the provers should discharge.
- **termination**: The chain-following while loop (until the value is 1 or 89) lives in a procedure that fills the 0..648 lookup table, so no termination check applies.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the two counts (below 1_000_000 and below 100_000_000) with Put_Line.

Assessed on 2026-10-15 against page revision 414274 of the [task](https://rosettacode.org/wiki/Iterated_digits_squaring) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
