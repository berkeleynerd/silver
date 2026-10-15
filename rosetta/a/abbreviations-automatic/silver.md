# Abbreviations, automatic

**Candidate: proofs plausibly discharge automatically.** Everything is bounded for loops over small fixed arrays with explicit guards before each String index, so no annotation is needed, but loop-carried start and stop positions require careful guarding, hence plausible rather than likely.

Position 1014 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Embed the first five lines of the list (plus the blank-line case) as String constants and process each with a procedure that tokenizes in one for pass into start and stop arrays bounded at 7 words (more words or an over-long line is rejected visibly). A function then tries each abbreviation length from 1 up to the longest word with nested for loops over word pairs, comparing truncated prefixes character by character under explicit index guards, returning the first length with no duplicate, and 0 for an empty line. The result is printed as its image, a blank and the line. About 90 lines.

## Proof obligations to watch

- **index**: Word start and stop positions are stored in arrays and read back as loop-carried values, so every Line index is preceded by an explicit guard that the stop is within Line'Last and the offset is within the word.
- **overflow**: Counters and index sums are bounded by Line'Length being checked against a small declared limit before processing, with element subtypes ranged to that limit.
- **length**: The printed result concatenates a short image of the length, a blank and the line, which fits a declared output bound once the line length limit is checked, with an over-long line rejected visibly.
- **termination**: All iteration uses for loops inside functions, with the tokenizer written as a single for pass over Line'Range, so no variant is needed.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, unconstrained arrays, string indexing, string building, 'Image of scalars, for loops, procedures and functions.

## External effects

- **console output** (allowed): Each processed line is printed with its computed minimum abbreviation length via Put_Line.

Assessed on 2026-10-15 against page revision 413629 of the [task](https://rosettacode.org/wiki/Abbreviations,_automatic) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
