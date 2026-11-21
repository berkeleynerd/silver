# Textonyms

**Candidate: proofs plausibly discharge automatically.** Everything is bounded for-loop work over small fixed arrays with character-to-digit mapping, so checks follow from declared ranges and capacity guards, but the quadratic distinct-key counting and string-key comparison need careful shape to avoid loop-carried counter overflow.

Position 1479 in the [progression](../../progression.md#stage-28), in stage 28.

## Approach

Embed a modest fixed word list (the task allows a list at the author's discretion; no file reading is required) as an array of bounded strings, map each letter to its digit via a case statement, and build a fixed-length digit-key string per word, skipping words with non-letters. Count represented words, then count distinct keys and keys shared by more than one word using nested for loops over the table with a first-occurrence flag per entry, then print the report and a couple of example textonyms. All loops are for loops over array ranges inside procedures, with capacity guards before each insertion. About 110 lines.

## Proof obligations to watch

- **index**: Word table, digit-key buffer and per-key counters are fixed-capacity arrays; indexes come from for-loop ranges or are guarded by capacity checks before each insertion.
- **overflow**: Counters are declared as ranged subtypes bounded by the word capacity, and an explicit guard rejects overflow of the table before incrementing.
- **length**: Words longer than the fixed buffer length are counted as an explicit rejected or unrepresentable outcome rather than being truncated, so string lengths stay within declared bounds.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, records, string indexing, string ordering, 'Image of scalars, string building, for loops, while loops, procedures, functions, case statements, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): Prints the three-line report and a few example textonyms.

Assessed on 2026-10-15 against page revision 413946 of the [task](https://rosettacode.org/wiki/Textonyms) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
