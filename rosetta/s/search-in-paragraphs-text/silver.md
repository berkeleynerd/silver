# Search in paragraph's text

**Candidate: proofs likely to discharge automatically.** Every check follows from declared line-length bounds, for-loop indexes over buffer ranges and length guards before each substring comparison, and no recursion, input or termination annotation is needed because all loops are in procedures or are for loops. The embedded text keeps the task faithful without file input, though the long data table makes the program lengthy.

Position 613 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

The example text is embedded as a constant array of about 70 line records (a fixed-capacity character buffer plus a length bounded by a ranged subtype), with empty lines separating paragraphs. A for loop walks the lines, splitting them into paragraphs at empty lines. For each paragraph a helper function scans its lines for "SystemError" and for the first "Traceback (most recent call last):" using bounded nested for loops guarded by length, and the procedure then prints the first Traceback line from its offset, the remaining lines, and the "----------------" separator. About 170 lines.

## Proof obligations to watch

- **index**: Substring matching and printing from the Traceback offset index into fixed line buffers, discharged because every index is bounded by a for-loop range derived from the stored line length, which is a subtype-bounded field, with the match loop upper bound computed only after guarding Length >= pattern length.
- **length**: Building the output slice from the Traceback offset to the line end needs a computed-length bounded buffer or a slice, discharged by guarding offset <= length before the slice and capping buffer capacity at the embedded maximum line length.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): The matching paragraphs and the separator lines are written with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413901 of the [task](https://rosettacode.org/wiki/Search_in_paragraph's_text) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
