# Integer sequence

**Candidate: proofs likely to discharge automatically.** The current finite Integer-loop and standard Integer Image fragment can express the task's explicitly permitted implementation limit, 2147483647. This is language eligibility, not evidence that a complete 2147483647-line execution was performed; a normal sample-run disposition remains separate.

Position 8 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main uses for Value in 1 .. 2147483647 loop and calls Silver_IO.Put_Line (Integer'Image (Value)). The explicit literal is the current signed 32-bit Integer maximum; Integer'Last is not admitted syntax. Successful execution emits exactly 2147483647 lines, one for every integer from 1 through 2147483647 inclusive. Each line is one ASCII space, the ordinary decimal digits of Value, then LF. No arbitrary precision example is claimed. Do not cap this source or treat a prefix execution as complete task execution; keep the full-run validation disposition explicit. About 8 lines.

## Language surface recorded by this assessment

Integer range for loops and Integer image.

## External effects

- **console output** (allowed): Each integer in the sequence is written to standard output on its own line with Silver_IO.Put_Line.

Initially assessed on 2026-10-15 against page revision 404486 of the [task](https://rosettacode.org/wiki/Integer_sequence) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-reconciliation-20261025.md).
