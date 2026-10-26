# Documentation

**Candidate: proofs likely to discharge automatically.** The task asks only to show how to document code, which plain Ada comments plus text output do using constructs Silver already supports, so there are no proof obligations beyond trivial ones.

Position 34 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main procedure carries ordinary Ada "--" comments documenting the unit, a String constant and a String variable, and then prints a few String literals stating that documentation is built in as comments and that no external tool is required. It uses only straight-line Put_Line statements with no loops, arithmetic or arguments. About 22 lines.

## External effects

- **console output** (allowed): The program prints a short explanation of Silver's documentation mechanism (Ada comments) with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413697 of the [task](https://rosettacode.org/wiki/Documentation) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
