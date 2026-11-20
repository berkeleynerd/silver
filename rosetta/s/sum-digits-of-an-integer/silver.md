# Sum digits of an integer

**Candidate: proofs likely to discharge automatically.** Since N < 2^31 and Base >= 2, thirty-one divisions consume every digit throughout the declared formal-domain product. Extra leading zero digits contribute nothing. Before any addition at most thirty digits of value <=35 give Total <=1050, so the guard never discards a digit and the result fits 1085. The four primary examples give 1, 10, 29 and 29. The analytical argument covers all declared inputs; retained finite checks do not claim exhaustive enumeration of that domain. The [reconciliation](../../../rosetta/assessment-scalar-function-batch-20261108.md) preserves the original assessment attribution and links the separately reviewed Linux application evidence; final combined integration and independent delivery status remain in the batch delivery record.

Position 80 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_sum_digits_of_an_integer.adb: Sum_Digits takes N in 0..2147483647 and Base in 2..36 and returns 0..1085. Thirty-one counted iterations add Remaining mod Base under Total <= 1050, then divide Remaining by Base. Main indexes constant input/base arrays and assigns calls before printing; decimal inputs 254 and 3854 with base 16 are the required FE and F0E examples. About 39 lines.

## Proof obligations to watch

- **division**: The full 2..36 base range excludes zero for every / and mod operation.
- **range**: Each digit is in 0..35; the static <=1050 guard bounds the sum after addition by 1085 and never truncates a required digit.
- **termination**: The fixed thirty-one-step loop terminates; N < 2^31 and Base >= 2 separately establish complete extraction for every declared input.

## Language surface recorded by this assessment

Named Integer subtypes, bounded components and scalar signatures, small nonrecursive scalar functions, bounded mutable Integer objects, Integer range for loops, interval-checked Integer division, scalar guard refinement, fixed-size Integer arrays and Integer image.

## External effects

- **console output** (allowed): Prints seventeen digit sums including all four required decimal/base-16 examples and zero, base and Integer-boundary cases.

Initially assessed on 2026-10-15 against page revision 413075 of the [task](https://rosettacode.org/wiki/Sum_digits_of_an_integer) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-08 by Codex through targeted source review; see the [review record](../../assessment-scalar-function-batch-20261108.md).
