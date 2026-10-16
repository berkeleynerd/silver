# Extreme floating point values

**Excluded from Silver: run-time error.** Excluded: the task's core requirement is to produce NaN and plus and minus infinity by arithmetic on normal floats, which needs a floating-point overflow or a division by zero. Under Oracle rule 2, every such check must be proved never to fail, so no future Silver program can meet the task.

## Language surface recorded by this assessment

Floating point.

## Oracle conflicts

- **run-time error**: The task requires computing NaN and plus and minus infinity from ordinary floating-point expressions and assigning them to variables. The only way to get them is a floating-point overflow or a division by zero, such as 1.0/0.0 or 0.0/0.0. SPARK treats both as failing run-time checks, and its model of floating point has no non-finite values. A Silver program must prove at Silver level that no overflow or division-by-zero check can fail, so it cannot produce these values.

## External effects

- **console output** (allowed): Prints the extreme values and the results of arithmetic on them.

Assessed on 2026-10-15 against page revision 412782 of the [task](https://rosettacode.org/wiki/Extreme_floating_point_values) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
