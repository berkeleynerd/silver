# Append numbers at same position in strings

**Candidate: proofs likely to discharge automatically.** All data is embedded, the loop indexes are the arrays' own range, and the value ranges are tiny, so every check follows from types and static bounds with no loop-carried state.

Position 125 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Embed the three lists as constant arrays of a ranged subtype (0..99) indexed 1..9, and loop over the index with a for loop; for each element compute the digit count by comparing with 10 (all values are under 100) and form the decimal concatenation arithmetically, or build the text in a bounded 16-character buffer via 'Image with the leading space dropped. Print the results with Put, separators and brackets inside a procedure, since no input is read and every index is the loop's own array range. About 35 lines.

## Proof obligations to watch

- **overflow**: The concatenated value is computed as a*10^(digits of b and c) + b*10^(digits of c) + c with all inputs bounded by embedded constant arrays of values up to 27, so a Long_Long_Integer or 64-bit range subtype keeps it far from overflow.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the nine resulting numbers as a bracketed list.

Assessed on 2026-10-15 against page revision 415427 of the [task](https://rosettacode.org/wiki/Append_numbers_at_same_position_in_strings) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
