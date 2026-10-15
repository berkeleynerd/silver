# Ackermann function

**Candidate: proofs likely to discharge automatically.** The program uses no recursion, runs its while loop inside a procedure that gets no termination check, and guards every index and increment just before use, so each check follows from local guards and declared ranges. Arbitrary precision is optional, so Natural values with a reported capacity limit are enough.

Position 209 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

An Ackermann procedure takes M and N and returns the result through an out parameter plus a Boolean success flag. It replaces recursion with an explicit stack: a fixed-capacity array of pending M values with a ranged Top index, driven by a while loop that pops M and applies the three defining cases. Explicit guards before each push and each increment turn stack or Natural exhaustion into a reported capacity failure. Main loops over M in 0 .. 3 and N in 0 .. 6 and prints each result with 'Image. About 50 lines.

## Proof obligations to watch

- **index**: Pushes are guarded by a test that Top is at most Capacity minus 2 just before the stores, and pops happen only under the loop condition Top > 0, so every stack index is in range.
- **overflow**: The N + 1 step is guarded by N < Natural'Last just before it, and M - 1 and N - 1 occur only in branches where M > 0 or N > 0 was just tested.
- **termination**: The while loop that simulates recursion with an explicit stack sits in a procedure, so GNATprove raises no termination check, and the task's own statement that A always terminates makes this sound.
- **other**: If the fixed stack capacity or Natural range would be exceeded, the procedure stops and reports a visible capacity-exceeded outcome instead of a value, which counts as a documented resource limit under rule 7.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, while loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints A(m, n) for an embedded table of small arguments with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415535 of the [task](https://rosettacode.org/wiki/Ackermann_function) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
