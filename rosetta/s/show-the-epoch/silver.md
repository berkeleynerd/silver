# Show the epoch

**Candidate: proofs likely to discharge automatically.** The task explicitly accepts documentation text where a demonstration is impractical, so printing literal epoch text needs only today's Silver and every check is trivial. A live demonstration through a date library would need an admitted calendar operation, but the text form already satisfies the task.

Position 8 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The program is a parameterless Main procedure that prints a few String literal lines with Silver_IO.Put_Line, stating the epoch used by the Unix-seconds conversion (1970-01-01 00:00:00 UTC) and the implementation-defined epoch of Ada.Calendar's private Time type. It has no loops, arithmetic or inputs, so there is nothing to guard. About 8 lines.

## External effects

- **console output** (allowed): Prints the epoch date of the date libraries as text lines.

Assessed on 2026-10-15 against page revision 413303 of the [task](https://rosettacode.org/wiki/Show_the_epoch) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
