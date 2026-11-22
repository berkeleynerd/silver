# Plasma effect

**Candidate: proofs likely to discharge automatically.** Text-art output meets the picture requirement, and an integer sine table with fixed grid bounds keeps every arithmetic and index check derivable from subtype ranges, so no loop invariant is needed.

Position 532 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed a 256-entry integer sine table as a constant array aggregate (replacing floating-point Sin and Sqrt) and a 10-character brightness ramp String, then loop over a fixed 64x32 grid with nested for loops. For each cell, sum four table lookups indexed by mod 256 of x, y, x+y and a squared-distance term from a centre, scale the sum into a 1..10 ramp index, store the ramp character in a 64-character row buffer, and print each finished row with Put_Line. About 75 lines.

## Proof obligations to watch

- **overflow**: The sum of four table values and the squared-distance term are bounded by ranged subtypes (table entries in -127..127, coordinates in small ranges), so every addition and multiplication is provable from types alone.
- **index**: Each table index is reduced with mod 256 of a non-negative bounded value and the ramp index is a bounded quotient into 1..10, so the checks follow from subtype ranges without loop-carried facts.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, string indexing, string building, for loops and procedures.

## External effects

- **console output** (allowed): The plasma frame is printed as rows of text-art characters with Put_Line.

Assessed on 2026-10-15 against page revision 414978 of the [task](https://rosettacode.org/wiki/Plasma_effect) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
