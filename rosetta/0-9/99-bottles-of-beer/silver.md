# 99 bottles of beer

**Candidate: proofs likely to discharge automatically.** The complete lyrics include every verse from 99 through the transition to zero, preserving the standard leading spaces from nonnegative Integer Image. The expected output is 495 lines and 11,357 bytes, compared in full rather than through a try-service preview. Existing counted-loop, immutable Integer arithmetic and Integer Image/output forms suffice; no string-building identifier is needed. The linked capability record distinguishes inherited D3 evidence from final-input validation.

Position 23 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main loops for N in reverse 1 .. 99 and prints five lines per verse: the wall line, the bottles line, Take one down, pass it around, the next wall line with (N - 1), and an empty separator. Count lines concatenate standard Integer Image with fixed text directly in Put_Line; no buffer building or user subprogram is required. Optional singular grammar is omitted. About 14 lines.

## Language surface recorded by this assessment

Integer range for loops, immutable Integer arithmetic and Integer image.

## External effects

- **console output** (allowed): The program prints the full lyrics line by line to standard output.

Initially assessed on 2026-10-15 against page revision 415384 of the [task](https://rosettacode.org/wiki/99_bottles_of_beer) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-18 by Codex through targeted source review; see the [review record](../../../docs/bounded-string-building-samples.md).
