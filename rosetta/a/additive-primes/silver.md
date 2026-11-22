# Additive primes

**Candidate: proofs likely to discharge automatically.** Every composite N >= 4 has a divisor in 2..N/2; empty loops accept two and three. Three digit extractions cover the complete helper domain, and at most two earlier digits give a sum <=18, so the guard preserves the exact decimal digit sum. Main covers every required candidate below 500. Independent sieve and decimal-text expectations match all 54 selected values. No sieve array, while loop, output buffer or extra procedure is required by the task. The [reconciliation](../../../rosetta/assessment-scalar-function-batch-20261108.md) preserves the original assessment attribution and links the separately reviewed Linux application evidence; final combined integration and independent delivery status remain in the batch delivery record.

Position 86 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_additive_primes.adb: Is_Prime on 0..499 rejects zero and one and tests all divisors 2..N/2. Digit_Sum extracts three decimal digits with a <=18 pre-addition guard and returns 0..27. Main scans 2..499, assigns primality, digit-sum and digit-primality calls to scalar locals and prints candidates for which both flags are true. About 46 lines.

## Proof obligations to watch

- **division**: The N >= 2 guard checks the positive half bound, and each executed trial divisor is at least two; decimal divisions use literal ten.
- **range**: The exact three-digit sum fits 0..27, and its full declared result range fits the 0..499 primality formal without relying on call-specific correlations.

## Language surface recorded by this assessment

Named Integer subtypes, bounded components and scalar signatures, small nonrecursive scalar functions, bounded mutable Integer objects, scalar Boolean objects and expressions, Integer range for loops, interval-checked Integer division, scalar guard refinement and Integer image.

## External effects

- **console output** (allowed): Prints all 54 additive primes less than 500, one per line; the optional count is omitted.

Initially assessed on 2026-10-15 against page revision 411689 of the [task](https://rosettacode.org/wiki/Additive_primes) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-08 by Codex through targeted source review; see the [review record](../../assessment-scalar-function-batch-20261108.md).
