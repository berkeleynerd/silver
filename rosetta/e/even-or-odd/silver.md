# Even or odd

**Candidate: proofs likely to discharge automatically.** The seven-value demonstration classifies the required integer inputs by remainder, including negative odd values. The literal divisor 2 excludes division by zero. The exact source passed admission, complete required application/library proof audit, build and manifest execution in integration run 20261107T164659-9f6192441d21; the linked assessment records the evidence scope. The linked delivery record carries the independent closing review status.

Position 17 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main loops over -3 .. 3 and tests (Number rem 2) = 0, printing Integer'Image (Number) followed by ": even" or ": odd". The seven actual integer values include negatives, zero and positives of both parities. About 12 lines.

## Language surface recorded by this assessment

Integer range for loops, interval-checked Integer division and Integer image.

## External effects

- **console output** (allowed): Prints seven labelled parity verdicts, one for each integer from -3 through 3.

Initially assessed on 2026-10-15 against page revision 415382 of the [task](https://rosettacode.org/wiki/Even_or_odd) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../assessment-sample-expansion-20261107.md).
