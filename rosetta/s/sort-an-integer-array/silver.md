# Sort an integer array

**Candidate: proofs likely to discharge automatically.** Nine shrinking adjacent-swap passes suffice for ten elements, and early inactivity follows only a complete pass without swaps. The ascending result is (-100, -5, -5, 0, 0, 3, 7, 12, 12, 100), preserving duplicates. One source supplies both task mappings without a user procedure, while loop or generic sorting facility. The exact source passed admission, complete required application/library proof audit, build and manifest execution in integration run 20261107T164659-9f6192441d21; the linked assessment records the evidence scope. The linked delivery record carries the independent closing review status.

Position 78 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main initializes ten Element values (-5, 0, 12, -5, 7, 100, -100, 12, 0, 3), with Element range -100 .. 100. For Pass in 1 .. 9, a Boolean Changed enables adjacent comparisons over 1 .. (10 - Pass), swapping through a bounded temporary. A pass without swaps disables later pass bodies. Before and after arrays are displayed. About 39 lines.

## Proof obligations to watch

- **index**: Pass is 1 .. 9, so each comparison index I lies in 1 .. 9 and I + 1 lies in 2 .. 10; the shrinking upper bound is captured on loop entry.
- **range**: Swaps copy only Element values into the same -100 .. 100 component and temporary ranges; element arithmetic is unnecessary.

## Language surface recorded by this assessment

Put without a newline, Integer range for loops, immutable Integer arithmetic, Integer image, bounded mutable Integer objects, fixed-size Integer arrays, named Integer subtypes, bounded components and scalar signatures and scalar Boolean objects and expressions.

## External effects

- **console output** (allowed): Prints the ten-element input and ascending result on labelled Before and After lines.

Initially assessed on 2026-10-15 against page revision 414484 of the [task](https://rosettacode.org/wiki/Sort_an_integer_array) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../assessment-sample-expansion-20261107.md).
