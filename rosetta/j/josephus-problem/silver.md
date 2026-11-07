# Josephus problem

**Candidate: proofs likely to discharge automatically.** The incoming Survivor interval is 0..40, Survivor+K is 3..43 and the divisor I is 2..41. Modulo yields 0..40, preserving the declared range without guard or update refinement. The independently derived incident answer is zero-based 30.

Position 23 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main fixes N=41 and K=3 and initializes Survivor : Integer range 0 .. 40 := 0. An Integer range loop over 2 .. N assigns Survivor := ((Survivor + K) mod I), then prints the zero-based survivor with Integer'Image and Put_Line. This implements the task's (41,3) incident; it is not an arbitrary positive-n,k API or the optional m-survivor extension. About 14 lines.

## Language surface recorded by this assessment

Integer range for loops, immutable Integer arithmetic, interval-checked Integer division, bounded mutable Integer objects and Integer image.

## External effects

- **console output** (allowed): Prints the survivor number with Put_Line.

Initially assessed on 2026-10-15 against page revision 414279 of the [task](https://rosettacode.org/wiki/Josephus_problem) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-division-20261025.md).
