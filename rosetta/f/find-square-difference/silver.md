# Find square difference

**Candidate: proofs likely to discharge automatically.** The loop index interval 1 .. 1000 bounds each arithmetic operation within signed 32-bit Integer. Every assignment stores an index in Answer's declared range 0 .. 1000; scalar guard refinement and loop-carried arithmetic are unnecessary. The loop is finite, and standard Integer'Image has a bounded result length.

Position 18 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main declares Answer : Integer range 0 .. 1000 := 0. A counted loop over N in 1 .. 1000 tests Answer = 0 and then ((N * N) - ((N - 1) * (N - 1))) > 1000, assigning N to Answer only while Answer is zero. After the loop Silver_IO.Put_Line (Integer'Image (Answer)) prints 501 with Ada's leading space. Each binary arithmetic operation is explicitly grouped. No accumulator, exit statement, declared subtype or scalar conversion is needed. About 12 lines.

## Language surface recorded by this assessment

Bounded mutable Integer objects, Integer range for loops and Integer image.

## External effects

- **console output** (allowed): The program prints the single result line 501 via Put_Line.

Initially assessed on 2026-10-15 against page revision 412795 of the [task](https://rosettacode.org/wiki/Find_square_difference) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-17 by Codex through targeted source review; see the [review record](../../bounded-mutable-integers-delivery-review.md).
