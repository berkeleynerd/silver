# Flow-control structures

**Candidate: proofs likely to discharge automatically.** The task asks only to document flow-control structures, with goto as one example. A program that demonstrates labeled exit, exit when, and early return in procedures meets it without goto or asynchronous transfer of control. All of its checks follow from static loop ranges and guards placed just before each operation.

Position 210 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Main shows the flow-control constructs SPARK keeps. It uses a labeled outer for loop over small static ranges with `exit Outer when` on a product test to leave nested loops, and a plain `loop ... exit when` counter loop guarded before its increment. It also calls a user procedure that uses an early `return` when an if-guard holds, and prints each outcome with Put_Line and Integer'Image. About 55 lines.

## Proof obligations to watch

- **overflow**: The counter in the plain loop is incremented only after an `exit when Count >= Limit` test just before it, so the increment is bounded by that guard without an invariant.

## Language surface recorded by this assessment

Integers, 'Image of scalars, for loops, while loops and procedures.

## External effects

- **console output** (allowed): Each flow-control demonstration prints lines that show which path was taken.

Assessed on 2026-10-15 against page revision 415483 of the [task](https://rosettacode.org/wiki/Flow-control_structures) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
