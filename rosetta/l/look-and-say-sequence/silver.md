# Look-and-say sequence

**Candidate: proofs plausibly discharge automatically.** All checks are index and range checks on loop-carried positions that explicit capacity guards just before each access can discharge without invariants, and loops live in procedures so no variants are needed. The guards give a visible rejection outcome for overflow cases that the actual sequence never reaches within the chosen term count.

Position 461 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Hold the current term as a fixed-capacity Character array (capacity 256) plus a length, start with "1", and print the first 15 members via a for loop over steps. Each step is a procedure that scans runs with a while loop, counting equal adjacent characters, and appends the count digit and the digit character to a second buffer, with explicit guards before every index and a Reject when capacity or a one-digit count would be exceeded; then the new buffer is copied back and printed with Put_Line from the buffer's slice or via Put per character. About 60 lines.

## Proof obligations to watch

- **index**: Run scanning and output writes use loop-carried positions, so each read and write is preceded by an explicit guard (position <= Len, Out_Len + 2 <= Max) that rejects on overflow of the fixed buffer.
- **range**: The run count is loop-carried and must become one digit, so a guard (Count <= 9) is placed before Character'Val and rejects visibly otherwise, though the real sequence from 1 never exceeds 3.
- **overflow**: Counters are subtypes bounded by the buffer capacity (about 256) so increments stay in range after a guard against the bound.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, for loops, while loops, procedures, string building and Put without a newline.

## External effects

- **console output** (allowed): Each sequence member is printed as a line of text.

Assessed on 2026-10-15 against page revision 411621 of the [task](https://rosettacode.org/wiki/Look-and-say_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
