# Array concatenation

**Candidate: proofs likely to discharge automatically.** All indexes come from for loops over static ranges and the offset index 3 + I lies within 4..6, so every index and range check follows from static bounds, with no loop-carried values.

Position 45 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Declare constrained Integer arrays A (1..3) and B (1..3) as constants with aggregates, plus a result array C (1..6). Two for loops over the arrays' own ranges copy A into C(I) and B into C(3 + I), then a final for loop prints each element with Integer'Image through Put and ends the line. About 30 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The program prints the concatenated array elements to standard output.

Assessed on 2026-10-15 against page revision 414063 of the [task](https://rosettacode.org/wiki/Array_concatenation) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
