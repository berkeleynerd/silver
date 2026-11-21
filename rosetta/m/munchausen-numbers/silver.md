# Munchausen numbers

**Candidate: proofs likely to discharge automatically.** All checks follow from small declared ranges, constant table indexing by a mod 10 digit, and one guard on the accumulator, and the only while loop sits in a procedure so no termination annotation is needed.

Position 205 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A constant array of ten digit powers (with 0 taking the value 0, as the task's convention) is indexed by digit; a for loop over 1 .. 5000 calls a procedure that peels digits with mod 10 and / 10 in a while loop while N > 0, accumulating the sum only while it is at most 5000. Each M whose sum equals M is printed via an image conversion with Put_Line in the main procedure. About 35 lines.

## Proof obligations to watch

- **overflow**: The loop-carried digit-power sum is only added to when it is at most 5000, so the sum stays below 5000 + 9**9 and fits in a 32-bit range type, and exceeding 5000 already rules out a match without changing any result.
- **range**: The remaining number is a loop-carried value in 0 .. 5000 whose division by 10 stays in its type, and the digit is a mod 10 result used to index a 0 .. 9 table, so both follow from types.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each Munchausen number found between 1 and 5000.

Assessed on 2026-10-15 against page revision 414353 of the [task](https://rosettacode.org/wiki/Munchausen_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
