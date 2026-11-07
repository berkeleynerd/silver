# Floyd's triangle

**Candidate: proofs likely to discharge automatically.** All values are bounded by small declared ranges (at most 105 and 14 rows), numbers come from closed-form arithmetic rather than loop-carried state, and loops are for loops, so every check follows from types and static bounds.

Position 503 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A procedure Print_Triangle takes a row count in a declared range 1..14 and is called for 5 and 14; each number is computed in closed form as r*(r-1)/2+i, so no loop-carried accumulator exists. The column width for each column is the digit count of the last row's number in that column (found by comparing against 10 and 100), and each cell is right-aligned into a fixed 64-character buffer with a single separating space. The filled prefix of the buffer is then emitted with Put_Line, using two nested for loops over bounded ranges. About 45 lines.

## Proof obligations to watch

- **index**: The row buffer is sized for the widest row (14 columns of at most 3 digits plus separators), and a for loop over the columns with a width of at most 4 per column keeps the write position within bounds by static arithmetic.
- **overflow**: Row and column indexes are declared subtypes (1..14) so the running value r*(r-1)/2+i is at most 105 and fits its declared range without any loop-carried accumulator.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, procedures, string building, 'Image of scalars and string indexing.

## External effects

- **console output** (allowed): Each triangle row is written as one line through Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415484 of the [task](https://rosettacode.org/wiki/Floyd's_triangle) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
