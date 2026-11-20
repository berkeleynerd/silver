# Tau function

**Candidate: proofs likely to discharge automatically.** Before candidate d there are at most d-1 <= 99 earlier contributions, so the increment guard is always true when needed. The resulting count includes both one and N and is exact for every required input, including primes and perfect squares. The task requires the first hundred results and no ten-column layout. The [reconciliation](../../../rosetta/assessment-scalar-function-batch-20261108.md) preserves the original assessment attribution and links the separately reviewed Linux application evidence; final combined integration and independent delivery status remain in the batch delivery record.

Position 59 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_tau_function.adb: Tau(N : in Positive_Input), N in 1..100, returns Divisor_Count in 0..100. Scan Divisor in 1..N, count exact divisors under Count < 100 and return once. Main assigns each call result before printing all one hundred inputs with Integer Image. About 25 lines.

## Proof obligations to watch

- **range**: Count < 100 narrows the pre-increment value to 0..99; the candidate-prefix argument establishes that the guard never truncates the true divisor count.
- **division**: Every executed divisor lies in the positive range 1..N, excluding a zero modulo divisor.

## Language surface recorded by this assessment

Named Integer subtypes, bounded components and scalar signatures, small nonrecursive scalar functions, bounded mutable Integer objects, Integer range for loops, interval-checked Integer division, scalar guard refinement and Integer image.

## External effects

- **console output** (allowed): Prints the positive-divisor count for every required input 1..100, one labelled line per input.

Initially assessed on 2026-10-15 against page revision 413079 of the [task](https://rosettacode.org/wiki/Tau_function) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-08 by Codex through targeted source review; see the [review record](../../assessment-scalar-function-batch-20261108.md).
