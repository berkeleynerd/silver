# FizzBuzz

**Candidate: proofs likely to discharge automatically.** The source computes the complete required sequence, including the multiples of both three and five. Static loop bounds and literal nonzero divisors use the existing narrow Integer-loop, division and Image rules. The exact source passed admission, complete required application/library proof audit, build and manifest execution in integration run 20261107T164659-9f6192441d21; the linked assessment records the evidence scope. The linked delivery record carries the independent closing review status.

Position 30 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main loops over 1 .. 100, testing Number mod 15, then mod 3, then mod 5. It prints FizzBuzz, Fizz or Buzz for the matching branch, otherwise Integer'Image (Number), retaining Ada's leading space for positive numbers. About 16 lines.

## Language surface recorded by this assessment

Integer range for loops, interval-checked Integer division and Integer image.

## External effects

- **console output** (allowed): Prints exactly 100 lines for 1 through 100, with the required substitutions and ordinary Integer Image for other values.

Initially assessed on 2026-10-15 against page revision 415487 of the [task](https://rosettacode.org/wiki/FizzBuzz) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../assessment-sample-expansion-20261107.md).
