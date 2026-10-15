# Commatizing numbers

**Candidate: proofs plausibly discharge automatically.** Everything is bounded character scanning and copying in procedures with ranged indices and capacity guards, needing no annotations, though several loop-carried positions need careful typing and guards.

Position 578 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Each sample is embedded as a String constant and copied into a fixed 512-character buffer with a length; a procedure Commatize takes the buffer, its length, a separator string, a period length and a start position, finds the first nonzero digit at or after start, scans the following digit run, and then copies characters to an output buffer inserting the separator whenever the remaining digits in the run are a positive multiple of the period. Invalid options (period 0, start outside the text, or capacity exceeded) leave the text unchanged and print it as is, and a main procedure calls it for the eleven required strings with the pi (blank separator, period 5, start after the point) and Zimbabwe (period separator) variants and prints each result. About 170 lines.

## Proof obligations to watch

- **index**: Scan positions and the copy-out position into the 512-character output buffer are loop-carried, so each use is guarded by explicit bound tests or typed as ranged subtypes before indexing.
- **length**: Output growth is bounded because each sample is at most about 160 characters and a separator of at most 3 characters is added per group, with an explicit capacity guard that rejects (visibly) rather than truncates.
- **overflow**: The digit-run length and the separator-count arithmetic are held in subtypes bounded by the buffer capacity, so additions and the mod by the period length (at least 1, guarded) stay in range.
- **termination**: Scanning uses for loops, or while loops inside procedures only, so no function termination check applies.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, string indexing, string building, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Each embedded sample string is printed in commatized form with Put_Line.

Assessed on 2026-10-15 against page revision 413668 of the [task](https://rosettacode.org/wiki/Commatizing_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
