# Integer overflow

**Excluded from Silver: run-time error, exception handling.** The task exists to run computations that overflow fixed-size integers and show the result, which for Ada means a raised and caught Constraint_Error. Silver requires automatic proof that no overflow or exception can occur and has no exception handlers, so this sample cannot be included.

## Language surface beyond today's Silver

Integers.

## Oracle conflicts

- **run-time error**: The task requires performing arithmetic "such that the result would overflow" and demonstrating what happens. Rule 2 requires every Silver program to be proved free of overflow and range check failures, so no admitted program can perform or observe an overflowing computation.
- **exception handling**: In Ada, overflow raises Constraint_Error, and the task says that when overflow triggers an exception the program must show how it is caught. Rule 8 means exception handlers are never available in SPARK/Silver.

## External effects

- **console output** (allowed): The program prints the result of each expression, or the behavior it shows, for each integer type.

Assessed on 2026-10-15 against page revision 413751 of the [task](https://rosettacode.org/wiki/Integer_overflow) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
