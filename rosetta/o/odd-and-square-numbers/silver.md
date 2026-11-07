# Odd and square numbers

**Candidate: proofs likely to discharge automatically.** The index covers every positive square root of a three-digit square. Modulo by 2 selects the eleven odd squares; the largest intermediate is 961 and the divisor is nonzero.

Position 22 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main loops over I in 11 .. 31. If (I mod 2) /= 0, Put writes Integer'Image ((I * I)); a final empty Put_Line terminates the row. The square is an expression, with no object or declared subtype. About 13 lines.

## Language surface recorded by this assessment

Integer range for loops, immutable Integer arithmetic, interval-checked Integer division, Integer image and Put without a newline.

## External effects

- **console output** (allowed): Prints the odd squares between 100 and 999 on one line.

Initially assessed on 2026-10-15 against page revision 414368 of the [task](https://rosettacode.org/wiki/Odd_and_square_numbers) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-division-20261025.md).
