# Infinity

**Candidate: proofs likely to discharge automatically.** The task needs no arithmetic, loop or input, only returning and formatting the constant Float'Last, so every check is trivial once floating-point constants and float-to-text formatting exist.

Position 1035 in the [progression](../../progression.md#stage-18), in stage 18, which adds floating-point images.

## Approach

A function Sup returns Float'Last, since SPARK floating point is proved finite and so has no infinity, which is the task's fallback branch of returning the largest positive float. Main calls Sup and prints "Supremum" followed by Float'Image of the result, with no loops, guards or input. About 12 lines.

## Language surface recorded by this assessment

Floating point, floating-point images and functions.

## External effects

- **console output** (allowed): Prints the returned largest positive float with Put_Line.

Assessed on 2026-10-15 against page revision 412846 of the [task](https://rosettacode.org/wiki/Infinity) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
