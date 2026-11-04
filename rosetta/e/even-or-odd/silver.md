# Even or odd

**Candidate: proofs likely to discharge automatically.** Remainder by literal 2 and the static loop range -1000 through 1000 fit the delivered interval-integer-division rules, including negative dividends and zero. The external review confirmed admission of this approach. This is a current-language assessment, not a delivered manifest sample or a new proof/build/execution record.

Position 29 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main loops directly over the Integer range -1000 .. 1000. For each immutable index N, an if statement tests (N rem 2) = 0 and prints Integer'Image (N) concatenated with the literal even or odd verdict through Put_Line. The bounded literal range includes negative values and zero. No declared subtype, user-defined procedure or separate Put call is needed. About 16 lines.

## Language surface recorded by this assessment

Integer range for loops, interval-checked Integer division and Integer image.

## External effects

- **console output** (allowed): Prints whether each sample integer is even or odd.

Initially assessed on 2026-10-15 against page revision 415382 of the [task](https://rosettacode.org/wiki/Even_or_odd) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-27 by Codex through targeted source review; see the [review record](../../assessment-arrays-20261027.md).
