# Exceptions/Catch an exception thrown in a nested call

**Excluded from Silver: exception handling, run-time error.** Excluded. The whole task is to raise user-defined exceptions in a nested call and catch one of them while the other goes uncaught. That needs exception handlers and run-time exception propagation, which SPARK and the Oracle rule against any raised exception make permanently unavailable.

## Language surface beyond today's Silver

Subprograms.

## Oracle conflicts

- **exception handling**: The task requires declaring two user-defined exceptions U0 and U1, raising them from baz, and catching U0 (but not U1) in foo. Exception handlers are excluded by SPARK and Oracle rule 8, and rule 2 forbids any exception being raised.
- **run-time error**: U1 is deliberately left uncaught, so the task requires showing an unhandled exception propagating and ending the program. Rule 2 says every admitted program must prove that no exception is raised.

## External effects

- **console output** (allowed): The program must print what happens when it runs: that U0 was caught and U1 propagated.

Assessed on 2026-10-15 against page revision 413261 of the [task](https://rosettacode.org/wiki/Exceptions/Catch_an_exception_thrown_in_a_nested_call) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
