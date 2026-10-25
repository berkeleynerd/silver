# Unit testing

**Candidate: proofs likely to discharge automatically.** A hand-written test driver needs only bounded integer arithmetic, Boolean flags, straight-line calls and if comparisons, with no loops or loop-carried values, so every check follows from declared ranges. Assertions and contracts are not needed because failures are detected by explicit comparisons with visible outcomes.

Position 1341 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The program defines a small pure function over a declared integer range (for example squaring a bounded value) and a Check procedure that compares an actual result with an expected value, prints PASS or FAIL with the case name, and clears an in out Boolean All_Passed flag on failure. Main runs a straight-line sequence of embedded test cases, prints a summary plus a statement that Ada's unit testing support (such as AUnit) is external to the compiler, and sets a nonzero exit status if any case failed. About 45 lines.

## Proof obligations to watch

- **overflow**: The function under test multiplies values of a declared small range whose result subtype is sized for the maximum product, so the nonlinear multiplication is bounded by types alone.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, functions, procedures and exit status.

## External effects

- **console output** (allowed): The test driver prints a PASS or FAIL line per test case, a summary, and a line stating that the testing support is external to the compiler.
- **exit status** (allowed): The driver reports overall test failure through a nonzero process exit status, as unit-test runners conventionally do.

Assessed on 2026-10-15 against page revision 386871 of the [task](https://rosettacode.org/wiki/Unit_testing) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
