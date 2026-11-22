# Abbreviations, easy

**Candidate: proofs plausibly discharge automatically.** All indexes come from for loops over the constants' own ranges and the loop-carried positions and counters have bounded subtypes with guards, so no annotation is needed. The outlook is plausible rather than likely because the nested word scanning and buffer appends need careful guard placement.

Position 573 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The command table and the sample input are embedded String constants; for loops over their indexes split them into words by tracking an in-word flag and the word start, and when a word ends a procedure scans the table the same way. For each table word it counts leading capitals, checks the input length is at least that count and at most the word length, and compares characters case-insensitively using Character 'Pos arithmetic; the first match appends the uppercased command, otherwise "*error*", into a fixed-capacity output buffer, which is then printed with spaces between results. About 150 lines.

## Proof obligations to watch

- **index**: Word start and end positions are loop-carried, so they are held in subtypes of the table's and input's index range and each substring or character access is guarded by a start-not-after-end check just before use.
- **length**: The output buffer has a fixed capacity and a guard before each append rejects (visibly reports) results that would not fit, while the embedded input is sized so the required output always fits.
- **overflow**: The output length counter and the capital-letter count are declared with ranges bounded by the buffer and table sizes and are incremented only under guards.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, string indexing, string building, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The program prints the resulting line of uppercase commands and *error* markers.

Assessed on 2026-10-15 against page revision 414046 of the [task](https://rosettacode.org/wiki/Abbreviations,_easy) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
