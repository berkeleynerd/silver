# Loops/Infinite

**Candidate: proofs likely to discharge automatically.** The program has no arithmetic, indexing or loop-carried data, so no run-time check needs discharging. The loop never ends, but it is in a procedure, which gets no termination check, so only the bare loop construct must be added to Silver.

Position 182 in the [progression](../../../progression.md#stage-9), in stage 9, which adds while loops.

## Approach

A parameterless Main procedure with pragma SPARK_Mode (On) runs a plain loop ... end loop with no exit. Its body is a single Silver_IO.Put_Line ("SPAM"), so there is no data, no arithmetic and no guard. About 8 lines.

## Proof obligations to watch

- **termination**: The loop has no exit and never terminates, which is allowed because it sits in the Main procedure, and procedures get no termination check.

## Language surface beyond today's Silver

While loops.

## External effects

- **console output** (allowed): The program prints the line SPAM to standard output on every iteration, forever.

Assessed on 2026-10-15 against page revision 408712 of the [task](https://rosettacode.org/wiki/Loops/Infinite) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
