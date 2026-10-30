# Box the compass

**Candidate: proofs likely to discharge automatically.** Every value is a small bounded integer and every loop is a for loop over fixed ranges, so all checks follow from subtype ranges and a few length guards; the only care needed is the string-building buffer and fixed-width number formatting.

Position 783 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Headings are held as integer hundredths of a degree (i*1125 plus or minus 562 by i mod 3) in a ranged subtype, so no floating point is needed; the point index is (2*h+1125)/2250 mod 32, which rounds exactly as the task's 5.62/5.63 boundaries need. A constant array of 32 four-character abbreviations is expanded by a for loop over its characters into a bounded buffer with a length guard before each append, and each row is printed with Put, a hand-formatted decimal angle (whole part and two-digit fraction from / and mod) and the 'Image of the index. About 95 lines.

## Proof obligations to watch

- **index**: Writing the expanded name into a fixed 32-character buffer needs a guard that the next append fits, and the abbreviations are 4 characters expanding to at most 18, so a length guard before each append discharges it.
- **range**: Computing the point index from hundredths of a degree uses division and mod on an integer bounded by the declared heading range, so the result stays within 0..32 and mod 32 gives a valid array index.
- **overflow**: Heading arithmetic in hundredths (at most 35999 times 2 plus 1125) is tiny against Integer, so the nonlinear products are bounded by the heading subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, for loops, case statements, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The program prints a header, a separator and 33 table rows to standard output.

Assessed on 2026-10-15 against page revision 415348 of the [task](https://rosettacode.org/wiki/Box_the_compass) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
