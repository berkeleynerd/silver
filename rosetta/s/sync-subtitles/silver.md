# Sync subtitles

**Candidate: proofs likely to discharge automatically.** Every check follows from fixed array bounds, bounded millisecond subtypes and a guard on the shifted value, and all loops are for loops in procedures, so no annotations are needed.

Position 1125 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

The 12 cue timestamps (start and end) and text lines of the example are embedded as constants in fixed-length String arrays; a procedure parses each 12-character HH:MM:SS,mmm string by digit positions into a bounded millisecond count. A for loop over the cues applies the shift (+9 s, then -9 s), guards against results below zero or above a day, and rebuilds the timestamp with / and mod into a fixed 12-character buffer, then prints the cue with Put_Line. Text lines are output unchanged. About 110 lines.

## Proof obligations to watch

- **overflow**: Millisecond totals are held in a range-bounded subtype (0 to 86_399_999 plus the shift), so the arithmetic is bounded by types and a guard before subtraction.
- **range**: A negative result after rolling back is rejected by an explicit guard that prints a specified error line, rather than wrapping around midnight.
- **index**: Digit extraction and formatting use fixed 12-character timestamp strings indexed with static constants, and the digit-to-Character conversion follows from a 0..9 subtype produced by mod 10.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, text parsing, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The program prints the shifted subtitle excerpt for the +9 and -9 second cases to standard output.

Assessed on 2026-10-15 against page revision 413938 of the [task](https://rosettacode.org/wiki/Sync_subtitles) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
