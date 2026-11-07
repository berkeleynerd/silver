# Smallest multiple

**Candidate: proofs likely to discharge automatically.** Only a bounded accumulator multiplication and mod are involved, with for loops that terminate by themselves, so overflow and division checks discharge from the explicit guard and constant divisors in 1..20.

Position 122 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Keep an accumulator in a Long_Long_Integer variable starting at 1; for each divisor I in 1..20, a nested for loop over multiplier K in 1..20 finds the first K such that (acc * K) mod I = 0, guarded beforehand by a check that acc is at most 10**9, and acc is then replaced by acc * K, giving the running LCM. After the loops the accumulator is printed with 'Image via Put_Line, and any guard failure goes to a specified Reject outcome. About 30 lines.

## Proof obligations to watch

- **overflow**: The loop-carried accumulator is a 64-bit integer, so each multiplication is guarded by an explicit check that the accumulator is below a fixed limit, with a visible Reject outcome otherwise.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the result 232792560 to standard output.

Assessed on 2026-10-15 against page revision 409624 of the [task](https://rosettacode.org/wiki/Smallest_multiple) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
