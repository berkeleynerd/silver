# Exceptions

**Excluded from Silver: exception handling.** The task asks for code that raises a new exception and handles it. Exception handlers are outside SPARK, and Silver's rule that no exception may be raised forbids this, so no future Silver program can meet the task.

## Language surface beyond today's Silver

Subprograms.

## Oracle conflicts

- **exception handling**: The task's whole requirement is to show an exception handling routine and to throw (raise) a new exception. SPARK does not allow exception handlers, and Silver requires every program to prove that no exception is raised.

## External effects

- **console output** (allowed): Printing a message to show that the exception was caught.

Assessed on 2026-10-15 against page revision 415544 of the [task](https://rosettacode.org/wiki/Exceptions) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
