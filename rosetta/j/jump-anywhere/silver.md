# Jump anywhere

**Candidate: proofs likely to discharge automatically.** The task lets each language show only the jumps it has, so a Silver program can leave out goto, exceptions and continuations and still be faithful. The program needs only bounded for-loop indexes, a small counter with its own range and a procedure whose early return is plain control flow, so every check follows from types and static bounds.

Position 203 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

The task asks a language to show the jumps it supports, so the program shows the structured jumps SPARK keeps: exit when from a plain loop, an exit from a named outer loop out of nested for loops over 1 .. 5, and an early return from a helper procedure. Each jump prints a Put_Line with the static loop index ('Image) where it happened. Loop indexes are static ranges and the plain loop exits through a guarded small counter, so there is no data-dependent arithmetic. About 45 lines.

## Language surface beyond today's Silver

Integers, for loops, while loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Each demonstrated jump prints a line showing where control went.

Assessed on 2026-10-15 against page revision 414959 of the [task](https://rosettacode.org/wiki/Jump_anywhere) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
