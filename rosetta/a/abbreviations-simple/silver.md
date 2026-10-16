# Abbreviations, simple

**Candidate: proofs plausibly discharge automatically.** Every check is an index or length bound on a fixed-size string and the number accumulation is capped by a guard, but tokenizer positions are loop-carried and need careful guards, so the program needs a deliberate shape and no annotation.

Position 1027 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

The command table and the sample input are embedded as constant Strings; a procedure scans the table with an index loop, splitting it into words and treating an all-digit token after a word as that word's minimum length (a word with no number gets its full length). For each input word, a function compares case-insensitively, using Character'Pos arithmetic to upper-case, against each table entry in order, requiring that the word is at least the minimum length and no longer than the entry. The first match gives the upper-cased entry, otherwise "*error*", and a blank input gives an empty result, all appended to a bounded result buffer and printed with Put and Put_Line. About 150 lines.

## Proof obligations to watch

- **index**: Token start and end positions carried across loop iterations have only their subtype range, so each slice or character access is preceded by an explicit bound guard (for example Pos <= Text'Last).
- **overflow**: The minimum-length number is accumulated digit by digit in a ranged subtype, and a guard rejects a value above a small cap before multiplying, so the arithmetic cannot overflow.
- **length**: The output buffer is fixed-capacity, and a guard before each append checks remaining room and otherwise reports a visible overflow outcome rather than truncating.
- **termination**: The tokenizing scans are written as for loops, and the one while loop sits in a procedure, so no termination check is generated.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, string indexing, string building, unconstrained arrays, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints one line per test input, or the single result line, showing the expanded command words.

Assessed on 2026-10-15 against page revision 412634 of the [task](https://rosettacode.org/wiki/Abbreviations,_simple) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
