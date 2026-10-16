# Cross compilation

**Candidate: proofs likely to discharge automatically.** The program is a fixed sequence of Put_Line calls on literals, which Silver already supports, so no run-time check can arise. The task needs no new language surface and has no Oracle conflict.

Position 31 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The task asks only for a prose explanation under a "baked in" or "third party" header, so the program is a parameterless Main that prints that explanation (the header, the toolchain needed, the target and architecture options, runtime and platform-specific notes) as a fixed sequence of Put_Line calls on String literals. There is no input, no loop and no arithmetic, so there is nothing to guard. About 30 lines.

## External effects

- **console output** (allowed): The program prints the cross-compilation explanation as lines of text with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 327303 of the [task](https://rosettacode.org/wiki/Cross_compilation) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
