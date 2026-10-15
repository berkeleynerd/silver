# Distance and Bearing

**Candidate: proofs plausibly discharge automatically.** Nothing needs an annotation, but the program relies on admitted file input, text parsing and floating-point trig/sqrt contracts, and the proofs hinge on range-guarding the float operands and conversions in loop-carried code. That makes discharge plausible rather than likely.

Position 1344 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

A fixed observer position is a constant, and a procedure reads airports.dat line by line into a bounded buffer, splits quoted CSV fields by an index-guarded scan, parses latitude and longitude with validation into ranged Long_Float values, and skips rows with a counted rejection. Each valid airport gets haversine distance and initial bearing, and is insertion-sorted into a 20-element record array of bounded name, country and ICAO strings, scaled integers for tenths of NM and whole degrees. A final for loop prints the table with Put and integer-to-text formatting, and a missing or unreadable file gives a specified error message. About 260 lines.

## Proof obligations to watch

- **floating point**: Haversine and bearing need sin, cos, sqrt and arctan2 whose admitted-library contracts must bound results, so latitude and longitude are validated into -90..90 and -180..180 before use and the sqrt argument is clamped to 0..1 with a visible reject path.
- **range**: Converting the Long_Float distance and bearing to scaled integers for printing needs guards on the value range before rounding, which holds because validated inputs bound distance to about 10800 NM and bearing to 0..360.
- **index**: Parsing quoted CSV fields and the insertion-sort shift of the 20-entry nearest list use while loops in procedures with indexes guarded just before each access, and over-long lines or fields are rejected or counted as skipped rows rather than truncated.
- **length**: Names and country strings are copied into fixed-capacity bounded buffers, so each copy is preceded by a length guard with a specified outcome for oversize fields.
- **termination**: The line-reading and field-scanning loops are while loops that must live in procedures because functions would need a variant, which restructures the parser as procedures with out parameters.

## Language surface beyond today's Silver

Floating point, ranged subtypes, arrays, records, string indexing, string building, text parsing, 'Image of scalars, floating-point images, characters, integers, integer division, Boolean objects, for loops, while loops, procedures, functions, Put without a newline and file input.

## External effects

- **files** (allowed): Reads the openflights airports.dat CSV file, with a specified outcome when it is missing or unreadable.
- **console output** (allowed): Prints the 20-row report of name, country, ICAO, distance in NM and bearing in degrees.

Assessed on 2026-10-15 against page revision 414850 of the [task](https://rosettacode.org/wiki/Distance_and_Bearing) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
