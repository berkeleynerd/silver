# Integer overflow

**Excluded from Silver: run-time error.** The task deliberately performs overflowing fixed-size arithmetic, whereas every admitted Silver program must prove its overflow checks; catching the resulting Constraint_Error cannot discharge those obligations.

## Language surface recorded by this assessment

Integers.

## Oracle conflicts

- **run-time error**: The task requires performing arithmetic "such that the result would overflow" and demonstrating what happens. Rule 2 requires every Silver program to be proved free of overflow and range check failures, so no admitted program can perform or observe an overflowing computation.

## External effects

- **console output** (allowed): The program prints the result of each expression, or the behavior it shows, for each integer type.

Initially assessed on 2026-10-15 against page revision 413751 of the [task](https://rosettacode.org/wiki/Integer_overflow) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-15 by Codex through targeted source review; see the [review record](../../review-343c2f8.md).
