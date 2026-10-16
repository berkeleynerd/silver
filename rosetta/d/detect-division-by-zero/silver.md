# Detect division by zero

**Excluded from Silver: run-time error.** The task requires observing a failed division-by-zero check without a preceding denominator guard, whereas every admitted Silver program must prove that check cannot fail.

## Language surface recorded by this assessment

Integers, floating point and subprograms.

## Oracle conflicts

- **run-time error**: The task requires letting a division by zero actually happen and detecting the resulting error (Constraint_Error, a trap, or an IEEE infinity) without first checking the denominator. Oracle rule 2 says every admitted program must prove that no division-by-zero check can fail and that floating-point division never overflows to an infinity. The only way to prove that is the explicit denominator guard the task forbids.

## External effects

- **console output** (allowed): Prints a message reporting that a division by zero was detected.

Initially assessed on 2026-10-15 against page revision 415395 of the [task](https://rosettacode.org/wiki/Detect_division_by_zero) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-15 by Codex through targeted source review; see the [review record](../../review-343c2f8.md).
