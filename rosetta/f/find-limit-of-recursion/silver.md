# Find limit of recursion

**Excluded from Silver: run-time error.** The task deliberately exhausts the stack to discover its limit, which violates the sufficient-memory premise; a fixed bounded recursion depth would change the required result.

## Language surface beyond today's Silver

Recursion, integers and subprograms.

## Oracle conflicts

- **run-time error**: The task is to find the recursion limit, which means recursing until the stack runs out and then observing that failure (the Ada solution catches Storage_Error). Silver programs must be proved free of run-time errors and resource exhaustion, so a program cannot be written to reach that limit and watch it happen.

## External effects

- **console output** (allowed): Prints the recursion depth reached.

Initially assessed on 2026-10-15 against page revision 413486 of the [task](https://rosettacode.org/wiki/Find_limit_of_recursion) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-15 by Codex through targeted source review; see the [review record](../../review-343c2f8.md).
