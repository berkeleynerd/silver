# Find limit of recursion

**Excluded from Silver: run-time error, exception handling.** Not a candidate. The task needs unbounded recursion until the stack overflows, plus a way to detect that overflow. Silver forbids exhausting the stack and handling exceptions, and a fixed, documented depth limit would not report the system's real limit.

## Language surface beyond today's Silver

Recursion, integers and subprograms.

## Oracle conflicts

- **run-time error**: The task is to find the recursion limit, which means recursing until the stack runs out and then observing that failure (the Ada solution catches Storage_Error). Silver programs must be proved free of run-time errors and resource exhaustion, so a program cannot be written to reach that limit and watch it happen.
- **exception handling**: The only way to see the limit from inside the program is to handle the stack-overflow exception (Storage_Error). SPARK does not allow exception handlers.

## External effects

- **console output** (allowed): Prints the recursion depth reached.

Assessed on 2026-10-15 against page revision 413486 of the [task](https://rosettacode.org/wiki/Find_limit_of_recursion) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
