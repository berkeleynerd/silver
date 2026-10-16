# Multisplit

**Candidate: proofs plausibly discharge automatically.** All checks come from ranged position subtypes, fixed capacities and guards placed just before each slice comparison, but several loop-carried positions need careful guards, so the outlook is plausible rather than likely.

Position 1488 in the [progression](../../progression.md#stage-29), in stage 29.

## Approach

The test string and the three separators are embedded as constants, stored in a fixed-capacity bounded buffer with a length, and a procedure scans position by position, trying each separator in priority order with a guarded slice comparison. Matches and the text between them are recorded in fixed-size arrays of records (start, length, separator index) with a count, and a final loop prints each piece and separator, including the extra-credit separator index and position. Overflow of the tables or of the position counters is guarded and reported as a rejection. About 110 lines.

## Proof obligations to watch

- **index**: Slice bounds Pos .. Pos+Len-1 are guarded by testing Len <= Source'Last - Pos + 1 just before the compare, with Pos kept in a bounded subtype.
- **overflow**: Position counters live in ranged subtypes bounded by the fixed input capacity, and each increment is guarded by a check against the limit.
- **length**: Result arrays of pieces and separator records have fixed capacity, and a full table leads to a visible rejection message rather than truncation.
- **termination**: The scanning loop is a while loop inside a procedure, which gets no termination check, and Pos increases on every iteration.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, records, string indexing, string building, string ordering, for loops, while loops, procedures, functions, Put without a newline, 'Image of scalars and Boolean objects.

## External effects

- **console output** (allowed): Prints the pieces and matched separators with their positions.

Assessed on 2026-10-15 against page revision 414352 of the [task](https://rosettacode.org/wiki/Multisplit) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
