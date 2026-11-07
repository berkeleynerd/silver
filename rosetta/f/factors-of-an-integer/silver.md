# Factors of an integer

**Candidate: proofs likely to discharge automatically.** Every positive divisor is at most the positive input, so exhaustive counted trial division produces the complete ascending list. Cases include 1, primes and composites; zero and negative inputs are outside the task requirement. The exact source passed admission, complete required application/library proof audit, build and manifest execution in integration run 20261107T164659-9f6192441d21; the linked assessment records the evidence scope. The linked delivery record carries the independent closing review status.

Position 35 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main iterates over the constant Positive_Input array (1, 2, 6, 12, 13, 28, 36, 97, 100), with component range 1 .. 100. For each Number it tests every Divisor in 1 .. Number and prints Divisor when (Number mod Divisor) = 0, forming one labelled divisor-list line per input. About 18 lines.

## Proof obligations to watch

- **division**: The captured divisor range begins at 1 and ends at a positive value at most 100, so modulo never uses zero.

## Language surface recorded by this assessment

Put without a newline, Integer range for loops, Integer image, interval-checked Integer division, fixed-size Integer arrays, constant Integer-array iteration and named Integer subtypes and bounded components.

## External effects

- **console output** (allowed): Prints nine labelled complete positive-divisor lists, including 1 and the input itself.

Initially assessed on 2026-10-15 against page revision 413796 of the [task](https://rosettacode.org/wiki/Factors_of_an_integer) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../assessment-sample-expansion-20261107.md).
