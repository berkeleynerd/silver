# Numerical integration/Adaptive Simpson's method

**Candidate: proofs plausibly discharge automatically.** The task is plain bounded floating-point arithmetic with recursion convertible to an explicit stack in a procedure, so no annotation is needed, but float range proofs through loop-carried values need careful guarding. The expected output 0.459698 is a bounded computation with depth cap, so it is faithful under the Oracle.

Position 1081 in the [progression](../../../progression.md#stage-17), in stage 17.

## Approach

Intervals are records of (a, fa, b, fb, tol, whole, m, fm, depth) held in a fixed-capacity array used as an explicit stack inside a procedure, replacing the recursion, with a while loop popping an interval, applying the Simpson test, and either adding to the accumulator or pushing two halves when depth and stack capacity allow. The integrand is a function computing sin by a fixed-term Taylor series on a bounded float subtype, and the result is printed with a float-to-text conversion. Guards on depth, stack index and value ranges lead to a specified rejection message. About 110 lines.

## Proof obligations to watch

- **floating point**: Every float operation must be shown finite, so all values live in bounded subtypes and each stored sum is guarded against leaving the range with a visible rejection outcome.
- **termination**: The recursion is replaced by an explicit fixed-capacity work stack in a procedure with a while loop, which gets no termination check, and a depth cap bounds the stack so push never overflows.
- **index**: Stack pushes are guarded by a depth limit strictly below the array capacity, so the index check follows from the guard just before each push.
- **range**: Accumulating the result across loop iterations loses all facts except the type range, so the accumulator is clamped by a guard that rejects out-of-range totals rather than silently altering the answer.
- **floating point**: sin must come from a hand-written Taylor series over a bounded argument in 0..1 in a for loop, whose nonlinear float arithmetic discharges only because operands are range-bounded.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, arrays, records, floating-point images, for loops, while loops, procedures, functions, Put without a newline, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints the integral estimate for sin(x) from 0 to 1.

Assessed on 2026-10-15 against page revision 405830 of the [task](https://rosettacode.org/wiki/Numerical_integration/Adaptive_Simpson's_method) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
