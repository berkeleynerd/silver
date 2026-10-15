# Range expansion

**Candidate: proofs plausibly discharge automatically.** Every check follows from a bounded value subtype and cursor guards placed just before each String access, but the loop-carried cursor and accumulator need careful guard placement, hence plausible rather than likely.

Position 1136 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

The task string is embedded as a constant String, and a single procedure scans it with a cursor in a while loop, parsing an optionally signed bounded integer, then either a single value or a '-' followed by a second signed integer. Each value of a range is emitted directly by a for loop with Put of the integer image and a comma separator flag, so no result array is needed. Malformed syntax, oversized numbers or a descending range set a Boolean invalid flag that leads to a specified rejection message instead of the list. About 80 lines.

## Proof obligations to watch

- **overflow**: Digit accumulation in a while loop is guarded by a check that the value stays below a declared limit (for example 1_000_000) before each multiply-add, rejecting larger numbers visibly.
- **index**: The cursor is loop-carried, so every Text(P) access, including the lookahead after a minus sign, is preceded by an explicit P <= Text'Last guard.
- **range**: Parsed values are held in a ranged subtype with negation and range-end results bounded by the same limit so the for loop bounds and the Image conversions stay in range.
- **termination**: All while loops live in a procedure, which gets no termination check, and each iteration advances the cursor.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, string indexing, 'Image of scalars, text parsing, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The expanded comma-separated list is written to standard output, plus a rejection message for malformed input.

Assessed on 2026-10-15 against page revision 414429 of the [task](https://rosettacode.org/wiki/Range_expansion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
