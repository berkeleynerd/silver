# Longest common prefix

**Candidate: proofs likely to discharge automatically.** The program is a bounded for-loop character comparison over constant strings, so every index and length check follows from the clamped loop bound computed just before use and no loop-carried fact needs an invariant. The only new surface is unconstrained String parameters, string indexing and slices, and Natural counters.

Position 985 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

The first string of each test set is kept as a constant, and a procedure Narrow (First, Other : String; Len : in out Natural) clamps Len to the minimum of Len and both lengths, then scans with a for loop and sets Len to I - 1 at the first mismatching character, exiting the loop. Main embeds the nine test sets as String constants, calls Narrow once per further string, and prints the prefix slice First (First'First .. First'First + Len - 1) via Put_Line; the empty set prints an empty line, and no input is read, so no validation is needed. About 80 lines.

## Proof obligations to watch

- **index**: Indexing both strings at First + I - 1 is safe because the for loop bound is the minimum of the current prefix length and both string lengths, computed just before the loop.
- **overflow**: Computing A'First + I - 1 for an unconstrained String could in principle overflow, but I is bounded by A'Length so the sum stays at or below A'Last.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, unconstrained arrays, string indexing, for loops, procedures, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): Each test case's longest common prefix is printed with Put_Line.

Assessed on 2026-10-15 against page revision 411109 of the [task](https://rosettacode.org/wiki/Longest_common_prefix) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
