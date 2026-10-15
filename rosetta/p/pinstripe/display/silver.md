# Pinstripe/Display

**Candidate: proofs likely to discharge automatically.** The task only needs fixed-size text art, and every index and divisor follows from for-loop ranges and subtype bounds, so no loop invariant or other annotation is needed. Drawing to a real display is replaced by console text art, which the task permits.

Position 495 in the [progression](../../../progression.md#stage-12), in stage 12.

## Approach

Render the display as text art: a fixed 64-column by 16-row grid, where band B in 1..4 covers 4 rows and uses stripe width B. A nested for loop over the band and column fills a 64-character String row buffer with '#' or ' ' according to ((Column - 1) / Band) mod 2, then writes it with Put_Line once per row of the band. All loop indexes are ranged subtypes, so the buffer index and the divisor are within range by their types. About 35 lines.

## Language surface beyond today's Silver

Integers, integer division, characters, ranged subtypes, string indexing, for loops and procedures.

## External effects

- **console output** (allowed): The pinstripe test card is rendered as text art, one line per pixel row, through Put_Line.

Assessed on 2026-10-15 against page revision 414896 of the [task](https://rosettacode.org/wiki/Pinstripe/Display) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
