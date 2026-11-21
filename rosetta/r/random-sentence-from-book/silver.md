# Random sentence from book

**Candidate: proofs plausibly discharge automatically.** Every check reduces to fixed-capacity array indexes, ranged counters and modular PRNG arithmetic with guards before each use, and all loops live in procedures, so no annotation is needed, but the many loop-carried counters and table lookups make discharge depend on careful program shape.

Position 1488 in the [progression](../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

The program reads the book file with a file-input library, skips to the start marker, lowercases and strips characters into words, and stores a bounded vocabulary table of fixed-length words with indexes into it. It counts bigram and trigram followers in fixed-capacity record arrays found by guarded linear search, then generates a few sentences starting after a full stop using a modular-type LCG and a cumulative-sum weighted pick, stopping at sentence-ending punctuation or a fixed word cap. Every table insertion is guarded by a capacity check, and a missing file or exceeded capacity is rejected with a specified message. About 260 lines.

## Proof obligations to watch

- **index**: Word, pair and triple tables are fixed-capacity arrays with a count variable, so every insertion and lookup is guarded by a capacity check just before the index is used, and overflow rejects the input visibly.
- **overflow**: Occurrence counts and weighted-choice running sums are carried through loops, so they use ranged counters bounded by the table capacity and a guarded increment.
- **length**: Lines and words are read into bounded buffers with explicit length guards, and an over-long line or word is rejected rather than truncated.
- **termination**: All reading, scanning and generation loops are while loops inside procedures, which get no termination check, and sentence length is bounded by a fixed word cap with a specified visible outcome.
- **overflow**: A linear congruential pseudo-random generator is written in a modular type so wraparound is intended, and the weighted pick reduces it into a range with mod by a guarded nonzero total.
- **heap**: Tables for tens of thousands of words are sized statically, and their large size is a documented resource limit outside any proof.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, string ordering, for loops, while loops, procedures, functions, Put without a newline, file input, text parsing and case statements.

## External effects

- **files** (allowed): The program reads the book text file line by line, and a missing or unreadable file must have a specified rejection outcome.
- **console output** (allowed): The generated sentences are printed to standard output.

Assessed on 2026-10-15 against page revision 413878 of the [task](https://rosettacode.org/wiki/Random_sentence_from_book) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
