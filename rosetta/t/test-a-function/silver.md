# Test a function

**Candidate: proofs likely to discharge automatically.** The testing library is replaced by plain executable checks over a simple for-loop palindrome function, whose index and overflow checks follow from the loop range and Text'Length without annotations. The loop is terminating by construction and the test counter is bounded by the fixed number of cases, so nothing needs an invariant.

Position 1348 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Define a non-recursive Palindrome function over an unconstrained String using a for loop on Offset in 0 .. Text'Length / 2 - 1 that returns False on the first mismatch, then a Main procedure that applies it to embedded cases such as "racecar", "wombat", the empty string, a single character and an even-length palindrome. Each case is an explicit if comparing the result with the expected Boolean, printing PASS or FAIL via Put_Line and counting failures in a small bounded Integer, and the program sets a nonzero exit status if any test failed. No assertions, contracts or pragmas are used, since the tests are executable checks with visible outcomes. About 45 lines.

## Proof obligations to watch

- **index**: Text(Text'First + Offset) and Text(Text'Last - Offset) stay within bounds because Offset is below Text'Length / 2, which the provers handle from the for-loop range without an invariant.
- **overflow**: Text'First + Offset cannot overflow since Offset is less than Text'Length and the sum is at most Text'Last, which is a simple linear fact.

## Language surface beyond today's Silver

Functions, Boolean objects, for loops, integers, integer division, unconstrained arrays, string indexing, procedures and exit status.

## External effects

- **console output** (allowed): Each test prints a pass or fail line and a final summary through Put_Line.
- **exit status** (allowed): A failing test should set a nonzero process exit status so the test run is machine-checkable.

Assessed on 2026-10-15 against page revision 413942 of the [task](https://rosettacode.org/wiki/Test_a_function) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
