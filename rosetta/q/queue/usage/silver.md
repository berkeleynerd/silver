# Queue/Usage

**Candidate: proofs likely to discharge automatically.** The task is a bounded circular-buffer queue with guarded push and pop and no unbounded loop-carried values, so every check follows from subtypes and guards placed just before use.

Position 593 in the [progression](../../../progression.md#stage-11), in stage 11.

## Approach

A record holds a constant-capacity Integer array, a Head index and a Count in 0 .. capacity. Push and Pop are procedures that check full or empty first and report success through a Boolean out parameter, Is_Empty is a function returning Count = 0, and Main replays the embedded push and pop sequence and prints the final Is_Empty line with if statements choosing the text. About 60 lines.

## Proof obligations to watch

- **index**: Push and Pop use a fixed-capacity circular array indexed by a ranged subtype, with full and empty guards placed before each access and a visible Boolean failure outcome.
- **range**: Count and head index updates wrap by explicit if comparisons, so they stay within their subtypes.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, records, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the final Is_Empty result line.

Assessed on 2026-10-15 against page revision 411822 of the [task](https://rosettacode.org/wiki/Queue/Usage) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
