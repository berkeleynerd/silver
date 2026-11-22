# Sum of divisors

**Candidate: proofs likely to discharge automatically.** The inclusive divisor scan visits every positive divisor exactly once. Before candidate d <= 100 the sum is at most d*(d-1)/2 <= 4950, so the static guard never discards a contribution. The full required range 1..100 is computed and printed; the primary task specifies no column arrangement. No output buffer or additional procedure is needed. The [reconciliation](../../../rosetta/assessment-scalar-function-batch-20261108.md) preserves the original assessment attribution and links the separately reviewed Linux application evidence; final combined integration and independent delivery status remain in the batch delivery record.

Position 59 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_sum_of_divisors.adb: Sum_Of_Divisors(N : in Positive_Input), N in 1..100, returns a 0..5050 result. Its loop tests each Divisor in 1..N with mod and adds exactly matching divisors under Result <= 4950. Main calls the function for every required input and prints the assigned result with Integer Image. About 25 lines.

## Proof obligations to watch

- **overflow**: The prefix bound <=4950 and divisor <=100 justify every guarded addition into 0..5050 without changing the mathematical sum.
- **division**: Every executed divisor is in 1..N, so the modulo divisor excludes zero.

## Language surface recorded by this assessment

Named Integer subtypes, bounded components and scalar signatures, small nonrecursive scalar functions, bounded mutable Integer objects, Integer range for loops, interval-checked Integer division, scalar guard refinement and Integer image.

## External effects

- **console output** (allowed): Prints the positive-divisor sum for every required input 1..100, one labelled line per input.

Initially assessed on 2026-10-15 against page revision 404133 of the [task](https://rosettacode.org/wiki/Sum_of_divisors) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-08 by Codex through targeted source review; see the [review record](../../assessment-scalar-function-batch-20261108.md).
