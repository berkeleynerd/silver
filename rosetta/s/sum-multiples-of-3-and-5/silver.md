# Sum multiples of 3 and 5

**Candidate: proofs likely to discharge automatically.** For positive N each quotient counts multiples strictly below N. Each numerator d*q*(q+1) is even, so division by two is exact, and subtracting the multiples of 15 removes double counting. All intermediates fit Integer over 0..1000. Demonstrations cover zero, strict boundaries, the overlap at 15, 999 and 1000. The task marks efficient 10^20 inputs as extra credit; the delivered callable domain is explicit. The [reconciliation](../../../rosetta/assessment-scalar-function-batch-20261108.md) preserves the original assessment attribution and links the separately reviewed Linux application evidence; final combined integration and independent delivery status remain in the batch delivery record.

Position 76 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_sum_multiples_of_3_and_5.adb: Sum_Multiples(N : in Input_Value) returns Integer for N in 0..1000. Return the initialized zero for N = 0; otherwise set Upper to N-1, obtain the quotients by 3, 5 and 15, and apply the arithmetic-series identity with inclusion-exclusion. Main iterates eleven constant-array cases, assigning each call to a scalar before output. About 35 lines.

## Proof obligations to watch

- **overflow**: The declared quotient ranges 0..333, 0..199 and 0..66 bound the three numerators by 333666, 199000 and 66330; even conservative independent-interval addition/subtraction fits Integer.

## Language surface recorded by this assessment

Named Integer subtypes, bounded components and scalar signatures, small nonrecursive scalar functions, bounded mutable Integer objects, interval-checked Integer division, scalar guard refinement, fixed-size Integer arrays, constant Integer-array iteration and Integer image.

## External effects

- **console output** (allowed): Prints eleven computed cases including the required n = 1000 result 233168.

Initially assessed on 2026-10-15 against page revision 413418 of the [task](https://rosettacode.org/wiki/Sum_multiples_of_3_and_5) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-08 by Codex through targeted source review; see the [review record](../../assessment-scalar-function-batch-20261108.md).
