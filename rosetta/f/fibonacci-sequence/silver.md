# Fibonacci sequence

**Candidate: proofs likely to discharge automatically.** The callable function preserves F0 = 0 and F1 = 1. Before step i its pair is F(i-2), F(i-1); for i <= 46 both static guard bounds hold. The last addition produces F46 = 1836311903 and no unused F47 is computed. This is the complete nonnegative Fibonacci-index domain whose result fits Integer. Negative indices are optional and omitted. The [reconciliation](../../../rosetta/assessment-scalar-function-batch-20261108.md) preserves the original assessment attribution and links the separately reviewed Linux application evidence; final combined integration and independent delivery status remain in the batch delivery record.

Position 70 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_fibonacci_sequence.adb: Fibonacci(N : in Fibonacci_Index) returns Fibonacci_Value for N in 0..46 and values in 0..1836311903. Handle zero explicitly; otherwise iterate Index in 2..N, guarding Previous <= 701408733 and Current <= 1134903170 before computing Next_Value and shifting the pair. Main assigns calls to a scalar and prints every input. About 30 lines.

## Proof obligations to watch

- **overflow**: The two static guards bound the sum by 701408733 + 1134903170 = 1836311903; the recurrence argument establishes that neither guard suppresses a required step.
- **range**: The initial values, shifted pair, addition and terminal result all fit Fibonacci_Value over the full 0..46 domain, including empty loops for zero and one.

## Language surface recorded by this assessment

Named Integer subtypes, bounded components and scalar signatures, small nonrecursive scalar functions, bounded mutable Integer objects, Integer range for loops, scalar guard refinement and Integer image.

## External effects

- **console output** (allowed): Prints every computed Fibonacci value F0 through F46 with Put_Line.

Initially assessed on 2026-10-15 against page revision 415533 of the [task](https://rosettacode.org/wiki/Fibonacci_sequence) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-08 by Codex through targeted source review; see the [review record](../../assessment-scalar-function-batch-20261108.md).
