# Search a list of records

**Candidate: proofs likely to discharge automatically.** All data is static and every loop is a for loop over the array's own range, so index and range checks follow from types and a found guard; the only care needed is formatting hundredths without float.

Position 781 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Cities are a constant array of 10 records holding a fixed-capacity padded name with its length and a population stored as integer hundredths (e.g. 458), which keeps the values exact and avoids floating point. A generic reusable finder is replaced by three small for-loop functions (by name, by population below a limit, by first letter) that each return the first matching index or a not-found value, and the main procedure guards on found before printing. Output formats the index and the population as hundredths split into whole and fraction digits using integer division and 'Image. About 90 lines.

## Proof obligations to watch

- **index**: Each search is a for loop over the array's own range with a not-found sentinel, and the result is read only after a Found guard, so index checks are routine.
- **length**: Names are stored in fixed 20-character padded buffers with a stored length, and slices for output use that length, which is bounded by the buffer type.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, records, string indexing, string building, 'Image of scalars, for loops, case statements, functions, procedures, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints the index, the name and the population of the three search results.

Assessed on 2026-10-15 against page revision 413222 of the [task](https://rosettacode.org/wiki/Search_a_list_of_records) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
