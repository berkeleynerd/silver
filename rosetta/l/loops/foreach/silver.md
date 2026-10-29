# Loops/Foreach

**Candidate: proofs likely to discharge automatically.** The exact source uses a nonempty explicitly initialized constant Integer array and an immutable, nonstatic foreach element with full Integer entry bounds. Integer Image accepts every such value. The five output lines are -1, then 0, 1, 2 and 3 with Ada's leading space on each non-negative value; each line ends with LF. Broader arrays remain unsupported. Assurance and validation status is recorded separately in docs/constant-array-iteration.md; this static assessment establishes no native or universal validation evidence.

Position 13 in the [progression](../../../progression.md#stage-1), in stage 1.

## Approach

Declare Values : constant array (1 .. 5) of Integer := (-1, 0, 1, 2, 3), then use for Value of Values loop and Silver_IO.Put_Line (Integer'Image (Value)). This is samples/rosetta_loops_foreach.adb: Ada's foreach visits every element in collection order, without an indexed-loop substitute or a user-defined procedure. About 9 lines.

## Language surface recorded by this assessment

Fixed-size Integer arrays, constant Integer-array iteration and Integer image.

## External effects

- **console output** (allowed): Prints each element of the collection to standard output.

Initially assessed on 2026-10-15 against page revision 415246 of the [task](https://rosettacode.org/wiki/Loops/Foreach) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-28 by Codex through targeted source review; see the [review record](../../../assessment-constant-array-iteration-20261028.md).
