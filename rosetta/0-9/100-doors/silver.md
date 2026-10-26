# 100 doors

**Candidate: proofs likely to discharge automatically.** Door toggles are independent, so exchanging loop order and counting visits preserves the complete task. Before any increment there are at most 99 prior visits; the guard suppresses no required toggle. Static nonzero pass bounds justify modulo, and the bare-name/static-threshold guard justifies the bounded increment. Expected bytes are derived independently by pass-major toggles. Delivery metadata is prepared; complete Silver assurance and validation remain pending.

Position 33 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

For each door from 1 through 100, reset a Visits : Integer range 0 .. 100 counter, then scan passes 1 through 100 and increment it when Door mod Pass = 0 and then Visits < 100. Print every door with Integer'Image and either " is open" or " is closed" according to odd or even visit parity. This is samples/rosetta_100_doors.adb, using the exact discovered source bytes. About 21 lines.

## Language surface recorded by this assessment

Bounded mutable Integer objects, interval-checked Integer division, Integer range for loops, Integer image and scalar guard refinement.

## External effects

- **console output** (allowed): Prints one line per door stating whether it is open or closed.

Initially assessed on 2026-10-26 against page revision 414028 of the [task](https://rosettacode.org/wiki/100_doors) by gpt-6.1-sol at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-26 by Codex through targeted source review; see the [review record](../../../docs/scalar-guard-refinement.md).
