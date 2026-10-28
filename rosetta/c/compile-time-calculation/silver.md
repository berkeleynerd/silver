# Compile-time calculation

**Candidate: proofs likely to discharge automatically.** The existing immutable Integer and Image fragment covers this task. The fully grouped Ada-static multiplication for 10! evaluates to 3628800, with every intermediate inside signed 32-bit Integer. No new integer type, loop form, contract or image operation is needed.

Position 14 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main declares Factorial_10 : constant Integer using a fully parenthesized product of 10 through 1 and prints "10! =" concatenated with Integer'Image (Factorial_10). The product is Ada-static; output is "10! = 3628800" followed by LF. Explain that the current Silver scalar domain is signed 32-bit Integer, every static intermediate must fit, binary arithmetic is fully grouped, the shared arithmetic/concatenation budget is 63 operators, and source is at most 4096 ASCII bytes. In particular, 13! exceeds Integer and is excluded. There is no user-defined compile-time function facility in the current language. About 10 lines.

## Language surface recorded by this assessment

Immutable Integer arithmetic and Integer image.

## External effects

- **console output** (allowed): The program prints the precomputed value of 10! with Silver_IO.Put_Line.

Initially assessed on 2026-10-15 against page revision 403674 of the [task](https://rosettacode.org/wiki/Compile-time_calculation) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-reconciliation-20261025.md).
