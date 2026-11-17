# Array concatenation

**Candidate: proofs likely to discharge automatically.** The two fixed copy ranges cover every result index once, yielding (-3, 0, 5, 5, 8, -1, 2). The source uses indexed copies rather than a general whole-array concatenation operation. The exact source passed admission, complete required application/library proof audit, build and manifest execution in integration run 20261107T164659-9f6192441d21; the linked assessment records the evidence scope. The linked delivery record carries the independent closing review status.

Position 72 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main declares Element range -9 .. 9, First = (-3, 0, 5, 5), Second = (8, -1, 2) and an initialized seven-element Combined array. It copies First into indexes 1 .. 4 and Second into 4 + I for I in 1 .. 3, then displays all three arrays using Put and Integer Image. About 39 lines.

## Proof obligations to watch

- **index**: The first copy uses indexes 1 .. 4; the second reads 1 .. 3 and writes 5 .. 7. Every display index is within its fixed array bounds.

## Language surface recorded by this assessment

Put without a newline, Integer range for loops, immutable Integer arithmetic, Integer image, fixed-size Integer arrays and named Integer subtypes, bounded components and scalar signatures.

## External effects

- **console output** (allowed): Prints First, Second and Combined on three labelled lines, preserving order, the duplicate 5 and Ada Integer Image spaces.

Initially assessed on 2026-10-15 against page revision 414063 of the [task](https://rosettacode.org/wiki/Array_concatenation) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../assessment-sample-expansion-20261107.md).
