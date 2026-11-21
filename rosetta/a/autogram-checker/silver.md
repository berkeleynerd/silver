# Autogram checker

**Candidate: proofs plausibly discharge automatically.** All arithmetic is on small ranged counts and all indices are guardable in procedure while loops, so nothing needs an invariant or variant, but the large amount of hand-written parsing with loop-carried indices means success depends on careful guard placement.

Position 1491 in the [progression](../../progression.md#stage-28), in stage 28.

## Approach

Embed the eight sentences as String constants, copy each into a 512-character bounded buffer with a length, lowercase it and tally letter (and, for sentences 3 and 7, comma, apostrophe, hyphen and exclamation) counts in a ranged-subtype array. A procedure then tokenizes the text into comma-separated mentions, converts the leading number words via a constant word table (with 'single' and hundred/and handling) into a ranged value, identifies the counted symbol (letter, plural name, or the word 'letters') and compares it to the tally, also verifying that every counted symbol with a nonzero tally was mentioned. Each sentence prints a valid or not-valid line with the reason, using guarded indexing and integer-to-text conversion for the messages. About 320 lines.

## Proof obligations to watch

- **index**: Scanning for words, commas and the character before each letter name uses String indexing in while loops inside procedures, so every index needs an explicit bound guard just before use because no invariant ties it to the string range.
- **overflow**: Per-character tallies and the running number value are declared as small ranged subtypes (0..1000) and incremented only after a guard against the cap, with an over-cap sentence rejected visibly as unsupported.
- **length**: Each sentence is copied into a fixed 512-character buffer with a stored length after a guard that rejects longer input, and word buffers are capped the same way.
- **termination**: All scanning loops are while loops in procedures (no termination check), and number-word lookup is a for loop over a constant table, with no functions containing while loops.
- **other**: Faithful handling of hyphenated and unhyphenated number words, 'single', 'hundred and', plural 'commas/apostrophes/hyphens' and the sentence 3 and 7 punctuation rules makes the parser logic branchy but needs no annotation.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, records, string indexing, string building, string ordering, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints one verdict line per test sentence, with the reason for any failure.

Assessed on 2026-10-15 against page revision 412092 of the [task](https://rosettacode.org/wiki/Autogram_checker) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
