# Strip whitespace from a string/Top and tail

**Candidate: proofs likely to discharge automatically.** Every check is an index or range check on scan variables bounded by subtypes and guarded by and then tests, in plain procedure-level while loops, so no annotation is needed. The only new surface is Character comparison, String slicing and while loops.

Position 484 in the [progression](../../../progression.md#stage-10), in stage 10.

## Approach

Embed a constant String with leading and trailing spaces and tabs (tabs built via Character'Val(9) concatenation), then in Main use two while loops with guarded indexes, treating any Character <= ' ' as whitespace, to find the first and last non-whitespace positions. Print the left-trimmed, right-trimmed and both-trimmed slices of the constant, each wrapped in quote marks, with an all-whitespace case producing an empty slice naturally. About 30 lines.

## Proof obligations to watch

- **index**: The scan indexes are subtypes ranging from 0 to N+1 and each Text(I) read is guarded by an and then bound test just before it, so slice and element checks follow from the loop conditions.
- **overflow**: Each increment or decrement happens inside a loop whose condition keeps the index strictly inside the subtype range, so the type range alone discharges it.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, while loops and for loops.

## External effects

- **console output** (allowed): The three trimmed strings are printed with Put_Line, each wrapped in quotes.

Assessed on 2026-10-15 against page revision 413617 of the [task](https://rosettacode.org/wiki/Strip_whitespace_from_a_string/Top_and_tail) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
