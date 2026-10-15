# Integer sequence

**Candidate: proofs likely to discharge automatically.** The for loop's index stays inside its static range, so nothing can overflow and the loop ends on its own, and the image of an Integer is always a short, bounded string. Every check therefore follows from types and static bounds, with no annotation needed.

Position 37 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Main runs a single for loop, `for Value in 1 .. Integer'Last loop`, and prints `Integer'Image (Value)` with Silver_IO.Put_Line on each pass. The task allows stopping at an implementation limit, so the program ends at Integer'Last, which is the documented resource limit. The arbitrary-precision variant is optional and is left out. About 10 lines.

## Language surface beyond today's Silver

Integers, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Each integer in the sequence is written to standard output on its own line with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 404486 of the [task](https://rosettacode.org/wiki/Integer_sequence) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
