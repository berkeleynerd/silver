# Alternade words

**Candidate: proofs plausibly discharge automatically.** Every index and length is bounded by declared subtypes and explicit capacity guards, and all while loops are in procedures, so no annotation is needed, though the file-reading loop and binary-search bounds need careful shaping.

Position 1479 in the [progression](../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

The program reads unixdict.txt into a fixed-capacity array of records (a bounded word buffer plus length), rejecting input that exceeds the capacity or line width. For each word of length 6 or more it builds the odd-position and even-position letters into bounded buffers with for loops, then checks each against the sorted list by a binary search in a procedure using a while loop. Matches print the word and its two parts with Put_Line and Put, with padding computed from the lengths. About 110 lines.

## Proof obligations to watch

- **index**: Binary-search midpoint and the odd/even letter positions are indexed into bounded buffers, discharged because low and high are ranged-subtype variables whose type bounds the midpoint and the extraction loops run over the target buffer's own range with positions bounded by the word length type.
- **heap**: The roughly 25,000-word dictionary is held in a fixed-capacity static array of fixed-width entries, with a visible rejection if the file has more words or longer lines than the limits.
- **overflow**: Loop-carried search bounds and the word count stay within declared subtypes, so low+high and the 2*(i-1) position arithmetic fit the type range without invariants.
- **termination**: The binary-search and read-loop whiles sit in procedures, which get no termination check, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, string ordering, for loops, while loops, procedures, file input and Put without a newline.

## External effects

- **files** (allowed): Reads the word list unixdict.txt line by line.
- **console output** (allowed): Prints each alternade with its two component words.

Assessed on 2026-10-15 against page revision 409701 of the [task](https://rosettacode.org/wiki/Alternade_words) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
