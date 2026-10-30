# Names to numbers

**Candidate: proofs plausibly discharge automatically.** All arithmetic is on small integers bounded by subtype ranges and explicit pre-operation guards, and loops are either for loops or while loops in procedures, so no annotation is needed, though the tokenizer and fold carry several loop-carried indexes that need careful guards.

Position 570 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed a table of number words (one to nineteen, tens, hundred, thousand, million) as a constant array of fixed-width padded strings with a parallel array of values, and embed a dozen test phrases (including 'minus', hyphens, commas and 'and') in fixed-size buffers. A procedure tokenizes each phrase with a while loop into a bounded word buffer, then a second procedure folds the words into a group and total using range-guarded integer arithmetic, with each malformed, unknown-word or too-large phrase producing a specified rejection message. Results print via Put_Line using 'Image. About 170 lines.

## Proof obligations to watch

- **overflow**: The running total and current group live in bounded subtypes (to 999_999_999 and 999_999) and each add or multiply is preceded by an explicit guard that rejects the phrase when the result would exceed the bound.
- **index**: The tokenizer's scan position and word start and end are loop-carried in a while loop, so each slice and element access is guarded by a comparison against the padded buffer's bounds just before use.
- **length**: Word lookup compares fixed-width padded words against table entries, requiring each word to be copied into a fixed-length buffer only after a guard that its length fits the maximum word width, else the phrase is rejected.
- **termination**: The while loops are placed only in procedures, which get no termination check, and the lookup uses for loops.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, for loops, while loops, procedures, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Each embedded test phrase and its parsed value or rejection message is printed with Put_Line.

Assessed on 2026-10-15 against page revision 408181 of the [task](https://rosettacode.org/wiki/Names_to_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
