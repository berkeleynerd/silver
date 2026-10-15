# Detect division by zero

**Excluded from Silver: run-time error, exception handling.** Excluded. The task requires detecting a divide-by-zero error without checking whether the denominator is zero, so the error must be allowed to occur and then be observed. Silver must prove such an error impossible, which needs exactly that denominator check, and it cannot handle exceptions.

## Language surface beyond today's Silver

Integers, floating point and subprograms.

## Oracle conflicts

- **run-time error**: The task requires letting a division by zero actually happen and detecting the resulting error (Constraint_Error, a trap, or an IEEE infinity) without first checking the denominator. Oracle rule 2 says every admitted program must prove that no division-by-zero check can fail and that floating-point division never overflows to an infinity. The only way to prove that is the explicit denominator guard the task forbids.
- **exception handling**: Without testing the denominator, the only way an Ada program can detect integer division by zero is to handle the Constraint_Error it raises. SPARK, and therefore Silver, excludes exception handlers (Oracle rule 8).

## External effects

- **console output** (allowed): Prints a message reporting that a division by zero was detected.

Assessed on 2026-10-15 against page revision 415395 of the [task](https://rosettacode.org/wiki/Detect_division_by_zero) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
