# Rosetta Code/Find bare lang tags

**Candidate: proofs plausibly discharge automatically.** Everything is bounded loops over embedded fixed-size text with slice comparisons and small bounded counters, so checks follow from types and positional guards, but several loop-carried counters and padded-name handling need careful guard placement.

Position 564 in the [progression](../../../progression.md#stage-10), in stage 10.

## Approach

Embed the example pages as a constant array of fixed-width padded text lines, and keep a bounded table of language names (padded fixed-length Strings) with a range-typed count array. A for loop walks the lines, and an inner for loop over start positions detects the header marker (updating the current language from the text up to the closing braces) or the bare lang tag via slice equality, then looks up or appends the language in the table. Finally it prints the total and each 'count in language' line using integer image text, with explicit guards that print a specified message when a capacity is exceeded. About 110 lines.

## Proof obligations to watch

- **index**: Slice comparisons for '<lang>' and the header marker slide over fixed-length padded lines, so each is guarded by a position bound check just before the slice and for-loop ranges stop early enough to keep indexes in range.
- **overflow**: Per-language and total counters are loop-carried, so they use bounded range types and an explicit guard that prints a specified 'capacity exceeded' message instead of incrementing past the limit.
- **length**: The language name extracted between the header marker and the closing braces is copied into a fixed-width padded buffer, with an explicit guard that rejects over-long names with a visible message.
- **index**: The language table lookup and insertion use a bounded entry count, with a guard that reports a full table visibly rather than dropping the tag.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the total bare-tag count and one 'N in language' line per language section.

Assessed on 2026-10-15 against page revision 413888 of the [task](https://rosettacode.org/wiki/Rosetta_Code/Find_bare_lang_tags) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
